{:title "Немного поупражнялся в рефакторинге"
 :layout :post
 :tags  ["java" "scala" "refactoring"]}

Пару дней назад увидел [пост на крайне актуальную тему](http://eao197.blogspot.com/2011/01/progflame-scala.html) в одном занимательном блоге. Суть: автор увидел кусок говнокода на Scala, переписал в цивильном виде, сделал аналог переписанного на Java и сравнил. По итогам сомнения он пришёл к выводу что разница в 30 строк кода из 100 не существенна для выбора языка, а идейной разницы никакой нет.

Надо сказать, что пост задел практически за живое, ибо совсем недавно я занимался валидацией запросов и авторизацией пользователей как раз на Scala :) Так что что мне сразу бросилась в глаза пара некорректных мест в сравнении, которые я и попробую дальше подробно описать.

Во-первых, утверждается, что два текста программ, приводимых в конце, одинаковы. И один имеет не лучшую надёжность, чем другой. Это просто не верно. Дело в том, что несмотря на очень похожую структуру Scala-код имеет на несколько порядков большую "защиту от дурака". Для обеспечения сравнимого уровня пассивной защиты от ошибок на Java требовалось-бы написать как-то так:

```scala
@rest.Method(httpMethod = Array(POST)) 
public void login(final rest.Request request, 
      @rest.Param(name = "login") @Nullable final String login, 
      @rest.Param(name = "password") @Nullable final String password) 
{ 
   debug("accessing login... " + login); 
 
   if( login == null || password == null ) 
      respond(UNAUTHORIZED, "You should provide login and password"); 
   else
      doLogin(request, login, password); 
} 
 
private void doLogin(@NotNull final rest.Request request, @NotNull final String login, @NotNull final String password) 
{ 
   final UserInfo user = AccountsStorage.find(login); 
   if( user == null ) 
      handleUnknownUserLogin(); 
   else
      (new KnownUserLoginHandler(request, login, password, user)).handle(); 
} 
```

И прикрутить сверху проверку статическим анализатором кода. Говорить о читабельности кода после такого преобразования не приходится.

Во-вторых приводится аргумент, что разработчик, с учётом возможностей современных IDE будет руками писать кода Java ничуть не больше(Справедливости ради стоит заметить, что скорее всего даже меньше). Аргумент не очень хороший, в контексте того что код ведь обычно не столько пишут, сколько читают. У меня на строку написанного кода приходится минимум сотня прочитанного, и с пять сотен бегло просмотренного. Во время работы каждый программист возвращается к ранее сделанному много раз и шум вроде повторения списка аттрибутов класс четыре раза в разных обрамлениях мягко говоря не помогает понять свою или чужую мысль.

В-третьих, в примере используется внешняя библиотека (для работы с http судя по всему) совершенно не приспособленная к языку и не использующая его возможностей. Как на образец удачной, основанной на полноценном использовании языка библиотеки можно посмотреть например на Circumflex Web Framework.

Ну и в-четвёртых собственно выразительные возможности скалы используется крайне скупо и внутри самого решения. Естественно, что если писать в точности как на Java то и никаких отличий не обнаружится. В доказательство этого утверждения я попробую решить эту-же задачу в немного более скальном стиле.

Итак, что мне не нравится в предложенном решении и что я собираюсь улучшить:

1. Сквозная связанность всего кода авторизации с классами внешней библиотеки. Не то чтобы переезды целых приложений с одного фреймворка на другой являются обычным делом, но когда они всё-таки происходят...
2. Весь алгоритм по сути выполняет простой выбор: авторизовать пользователя или выдать сообщение о том, почему в авторизации отказано. В предложенном решении для того чтобы это понять требуется отсмотреть всю сотню строк кода, а исключить другие (ошибочные) варианты реакции весьма затруднительно.
3. Сам алгоритм авторизации имеет преимущественно линейную структуру:
 - проверить, что логин и пароль предоставлены;
 - найти соответствующие учётные данные в БД;
 - проверить, что пользователь имеет право на вход;
 - аутентифицировать по паролю.

Несмотря на это код с самого начала начинает ветвиться, полностью скрывая основную идею.

Приступим. Вся процедура авторизации имеет своим результатом или учётные данные авторизованного пользователя, или сообщение об ошибке. Так и запишем:

```scala
type LoginResult = Either[UserInfo, String]
def Success[T, E] = Left[T, E] _
def Failure[T, E] = Right[T, E] _
```

Сама процедура логина получает возможно предоставленные данные, и возвращает описанный выше результат:

```scala
def login(login: Option[String], password: Option[String]): LoginResult = ...
```

Теперь можно отвлечься от деталей процедуры логина и заняться обработкой результатов

```scala
@rest.Method(httpMethod = Array(POST))
def login(request: rest.Request,
    @rest.Param(name = "login")
    loginParam: String,
    @rest.Param(name = "password")
    passwordParam: String): Unit =
  login(Option(loginParam), Option(passwordParam)) match {
    case Left(user) =>
      request.session("user") = user
    case Right(message) =>
      respond(UNAUTHORIZED, message)
  }
```

Здесь важно во-первых что количество вариантов внешней реакции системы явно ограничивается. Во вторых, что на этом уровне заканчиваются все связи с фреймворком, включая возможные null'ы в параметрах вызова (именно по этому я не стал делать процедуры, аналогичной setupSuccessfulAuthResult - она просто не создавала бы никакой полезной абстракции).

Дальше хочется заняться собственно процедурой логина, но стоит снова оставить её в стороне и описать все шаги авторизации. Очевидно, что каждый из шагов будет иметь то-же результат, что и процедура логина в целом, однако будет требовать разных данных на вход. Можно записать каждый шаг в виде отдельной функции:

```scala
def findUser(login: String): LoginResult =
  AccountsStorage.find(login).toLeft( "User not found" )
 
def checkUser(user: UserInfo): LoginResult =
  if (user.inactive) Failure("Account is inactive")
  else Success(user)
 
def doLogin(user: UserInfo, login: String, password: String): LoginResult =
  if (user.authScheme == "PETRIVKA")
    handlePetrivkaAuthSchemeLogin(user, password)
  else
    handleUsualAuthSchemeLogin(user, login, password)
 
def handlePetrivkaAuthSchemeLogin(user: UserInfo, password: String): LoginResult =
  if( user.passwordMatches(password) ) Success(user)
  else Failure("Authentication failed")
 
def handleUsualAuthSchemeLogin(user: UserInfo, login: String, password: String) =
  AccessStorage.access.auth_configs.find(_.key == user.authScheme) match {
    case Some(scheme) =>
      log.debug("authenticating with " + scheme.command)
      val exec = Runtime.getRuntime.exec(
          scheme.command replace("{login}", login) replace("{password}", password))
      if( exec.waitFor == 0 )
        Success(user)
      else
        Failure("Authentication within " + scheme + " failed")
    case None => Failure("Unknown authentication scheme: " + user.authScheme)
  }
```

Если немного помедитировать на handleUsualAuthSchemeLogin, то наверняка можно её сократить и упростить, но это мало повлияет на основную идею решения.

Теперь осталось самое простое - собрать все шаги вместе. Совершенно случайно в Scala завалялась подходящая конструкция :)

```scala
def login(login: Option[String], password: Option[String]): LoginResult =
  for (login <- login.toLeft( "You should provide login" ).left;
       password <- password.toLeft( "You should provide password" ).left;
       user <- findUser(login).left;
       checkedUser <- checkUser(user).left;
       loggedUser <- doLogin(checkedUser, login, password).left
  ) yield loggedUser
```

Не вдаваясь в детали, скажу что выражение for делает очередной шаг и проверяет результат: если он успешен то продолжает цепочку, если неуспешен то прерывает цепочку, возвращая неудачу. То какой вариант сейчас считается успешным мы сообщаем в конце каждого выражения, я соответственно всегда считаю успешным левый. Метод toLeft у класса Option преобразует его в Either, говоря куда помещать существующее значение и чем заменять несуществующее.

Вот и всё. Данный пример исправляет отмеченные ранее недостатки, при этом имеет более простую (7 элементов против 9) и близкую к задаче структуру. Также стоит добавть, что он имеет и существенный недостаток: двойную терминологию. В одних местах используется пара Success-Failure, в других Left-Right. Однако это имеет и положительный эффект - интерпретация результатов всегда отличима от их создания.

[полный исходник с кое-какими моками для компилябельности](https://gist.github.com/CheatEx/2a76c06b3bf5480e62708161a6957b05)
