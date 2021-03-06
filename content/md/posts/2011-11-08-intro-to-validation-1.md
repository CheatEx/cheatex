{:title "Введение в Validation: часть 1"
 :layout :post
 :tags  ["scala" "programming" "scalaz" "validation" "error-handling"]}

 В этом посте я хочу подготовить почву для будущего рассказа о подходе к обработке ошибок, который как ни крути получился весьма скомканный без должной политической подготовки аудитории. Его темой будет класс Validation из библиотеки scalaz, некоторые (далеко не все) техники работы с ним и отдельные языковые конструкции, которые я нашёл наиболее полезными.

Этот класс по сути объявлен следующим образом:

```Scala
sealed trait Validation[+E, +A] {
  def isSuccess : Boolean = this match {
    case Success(_) => true
    case Failure(_) => false
  }
  def isFailure : Boolean = !isSuccess
}

final case class Success[E, A](a: A) extends Validation[E, A]
final case class Failure[E, A](e: E) extends Validation[E, A]
```

В объявлении есть ещё ряд интересных методов, но давайте пока оставим их без внимания. Ничего не напоминает? Да это же брат-близнец [`Either`](http://www.scala-lang.org/api/2.9.1/index.html#scala.Either). Опять велик? Спокойно, эта модель обладает рядом важных свойств.

Во-первых у него объявлены методы map и flatMap. В scala это означает, что мы можем использовать экземпляры этого класса (на самом деле trait, но как это блин по-русски сказать то?) в выражении for. Например так (это переписанный код метода login из моего давнего поста на эту же тему):

```Scala
def login(login: Option[String], password: Option[String]): Validation[String, UserInfo] =
  for {
    login <- login.toSuccess( "You should provide login" )
    password <- password.toSuccess( "You should provide password" )
    user <- findUser(login)
    checkedUser <- checkUser(user)
    loggedUser <- doLogin(checkedUser, login, password)
  } yield loggedUser
```

Потратим немного времени и рассмотрим этот пример подробнее. Во-первых имеющиеся логин и пароль пользователя преобразуются из `Option` в `Validation` с помощью метода [`toSuccess`](https://github.com/scalaz/scalaz/blob/6.0.3/core/src/main/scala/scalaz/OptionW.scala#L84), его реализация абсолютно очевидна. Об этой операции можно думать следующим образом: альтернатива из существующего или отсутствующего значения преобразуется в альтернативу из валидного значения или сообщения об ошибке. Во-вторых происходят вызовы методов `findUser`, `checkUser`, `doLogin`. Мне не хочется тратить время на детальное их описание, будем считать что они объявлены принимающими обычные значения (не `Option` или `Validation`, а строки и объекты) и возвращающими `Validation[UserInfo, String]`. То есть каждый из них принимает некоторые данные для проверки и возвращает либо информацию о прошедшем эту проверку пользователе либо сообщение о случившейся ошибке.

Теперь очередь магии внутри выражения `for`. `<-` в данном контексте работает как "Если у нас справа успешное вычисление связать имя слева с его результатом, если неудача - вернуть его как результат всего выражения." А `yield` в свою очередь работает как "Если все связывания были успешны вычислить выражение и вернуть его как успех". Обратите внимание, выбор всё ещё тут, но он спрятан в способе которым выражение for комбинирует свои элементы.

У `Either` методов `map` и `flatMap` нет, есть они только в его "проекциях" ([правой](https://lampsvn.epfl.ch/trac/scala/browser/scala/tags/R_2_9_1_final/src//library/scala/Either.scala#L221) и [левой](https://lampsvn.epfl.ch/trac/scala/browser/scala/tags/R_2_9_1_final/src//library/scala/Either.scala#L120)). На практике это значит, что использование `Validation` практически постоянно экономит нам 5 символов. Сравните код выше с кодом из моего старого поста.

Важно понимать, что этот подход позволяет унифицировано обрабатывать целый ряд проблемных ситуаций: (а) ошибку во входных данных (отсутствие пароля), (б) собственно отказ в обработке основанный на логике (пароль не верен) и (в) ошибку во внешней службе (БД легла в момент сверки пароля). При этом код верхнего уровня даже не упоминает никакие `Failure`, только использует `<-` вместо `=`.

Помимо приятного синтаксического сахара для сокрытия if'ов от нашего взгляда, такой подход к передаче ошибок обладает одним важным свойством - отдельные методы следующие паттерну "значения на вход - валидации на выход" могут легко объединяться вместе рядом других способов помимо `for`. В каком-то смысле они обладают свойством замыкания. Для примера я сейчас построю простой модуль для парсинга параметров http запросов из пары десятков строк (полнофункциональная, боевая её версия около 50, но её я естественно никому не покажу :) ).

Пусть у нас есть класс `Req`, несущий в себе параметры HTTP запроса в форме словаря <имя параметра> - <список значений>. Нам нужен набор функций, позволяющий типобезопасно извлекать из него параметры, при этом возможно применяя некие алгоритмы парсинга (скажем, стандартный `toInt`). Также желательно иметь возможность извлекать необязательный параметры и наборы параметров. Интерфейс такого модуля можно описать следующим образом:

```Scala
trait ReqValidation {
  type ReqVal[T] = Validation[String, T]
  //возвращает значение параметра как есть или сообщение о его отсутствии
  def get(req: Req, name: String): ReqVal[String]
  //возвращает необязательное значение (его выполнение всегда успешно)
  def getOpt(req: Req, name: String): ReqVal[Option[String]]
  //возвращает целое значение или собщение об ошибке парсинга или сообщение об отсутствии параметра
  def getInt(req: Req, name: String): ReqVal[Int]
  //возвращает небязательное целое значение или собщение об ошибке парсинга
  def getOptInt(req: Req, name: String): ReqVal[Option[Int]]
}
```

Во-первых я ввожу новый тип для результата получения параметра. Этот тип параметризован типом успешного результата. Он является псевдонимом для `Validation` со строкой в качестве описания неудачи и его параметром в качестве типа успешного значения.

Давайте последовательно реализуем каждую из этих функций, начнём с get:

```Scala
def get(req: Req, name: String): ReqVal[String] =
  req.param(name).toOption.toSuccess(
    Failure("Missed parameter "+name))
```

Она извлекает значение параметра по имени, преобразует его в стандартный `Option`. И уже его преобразует в `Validation` с соответствующим сообщением об ошибке.
Следующим шагом будет реализация метода `getOpt`. Его можно сделать уже совсем прямолинейным:

```Scala
def getOpt(req: Req, name: String): ReqVal[Option[String]] =
  Success(req.param(name).toOption)
```

Реализацию второй пары методов, подразумевающих парсинг стоит начать с того, что собственно определить парсер:

```Scala
def parseInt(s: String): ReqVal[Int] =
  s.parseInt.fail.map { ne: NumberFormatException =>
      Filure("Value "+s+" is not an integer")
    }.validation
```

Здесь используется стандартный метод `parseInt`, возвращающий `Either`. При помощи метода `fail` мы преобразуем его в [`FailProjection`](https://github.com/scalaz/scalaz/blob/6.0.3/core/src/main/scala/scalaz/Validation.scala#L85) и преобразуем исключение из стандартной библиотеки Java в читаемое сообщение об ошибке. Кагда это сделано результат преобразуется назад в обычный `Validation`. `FailProjection` - это специальная форма `Validation` с инвертированной в каком-то смысле логикой: он сделан для явного манипулирования ошибкой и неявного игнорирования успешного результата.

А также вспомогательный метод для применения `parseInt` и ему подобных к необязательному значению:

```Scala
def parseOption[T](parse: String => ReqVal[T])(opt: Option[String]): ReqVal[Option[T]] =
  opt match {
    case Some(s) => parse(s).lift[Option, T]
    case None => success(None)
  }
```

Метод `lift` берёт успешное значение и дополнительно заворачивает его в указанную "оболочку", в данном случае `Option`.

Теперь можно написать реализацию `getInt`:

```Scala
def getInt(req: Req, name: String): ReqVal[Int] =
  get(req, name) flatMap parseInt _
```

Она предельно проста. Не особо задумываясь мы можем получить и `getOptInt`:

```Scala
def getOptInt(req: Req, name: String): ReqVal[Option[Int]] =
  getOpt(req, name) flatMap parseOption(s, parseInt _)
```

Этот метод очень похож структурно на `getInt`, практически он им и является с той поправкой, что мы трансформируем функцию парсинга для работы с необязательными значениями (продолжая следовать шаблону значение на вход - валидация на выход).

Итак, следуя простому паттерну значения на вход - `Validation` на выход мы получили простой в реализации и использовании модуля для типобезопасного извлечения данных из параметров  HTTP запроса. Он может быть легко расширен как добавлением новых поддерживаемых типов (ну например пишем парсер дат какого-то формата и получаем тривиальное в реализации расширение модуля для работы с датами).

Он не идеален, в нём есть очевидные места дублирования (например необходимость набивать новое семейство функций `getX`, `getOptX` для каждого нового типа, да и от обязательности/необязательности значения кажется можно абстрагироваться), однако для затраченного количества умственных усилий мне кажется неплохо.

Для того, чтобы получить более правдоподобную картину давайте придумаем тестовый пример для этого модуля... Скажем запрос на поиск поста в блоге по названию (параметр запроса "text"), с опцией сортировки по дате публикации (параметр "sort") и указанием ограничения на количество результатов в ответе (параметр `limit`).

И пусть у нас уже есть метод которые делает что надо в БД и метод сериализующий список результатов для передачи по HTTP, как-то так:

```Scala
case class Post(...)
 
sealed abstract class Order
case object Asc extends Order
case object Desc extends Order
 
def searchPosts(text: String, order: Option[Sort], limit: Int): ReqVal[List[Post]] = {...}
 
def serialize(ReqVal[Object]): Response = {...}
```

Давайте подумаем что нам нужно чтобы соединить вместе вышележащую библиотеку для работы с сетевым протоколом и нижележащую функцию работы с БД. Кажется почти всё есть, вот только надо научиться вытаскивать параметр сортировки... А чем порядок хуже числа?

```Scala
def parseOrder(value: String): ReqVal[Order] =
  value match {
    case "asc"  => Success(Asc)
    case "desc" => Success(Desc)
    case _      => Filure("Illegal order value "+value)
  }
 
def getOptOrder(req: Req, name: String): ReqVal[Option[Order]] =
  getOpt(req, name) flatMap parseOption(s, parseOrder _)
```

А теперь можно и написать требуемый код склейки, извлекаюий параметры из запроса и передающий их в функцию работы с БД:

```Scala
def handleSearchPosts(req: Req): Response =
  serialize(
    for {
      text  <- get(req, "text")
      order <- getOptOrder(req, "sort")
      limit <- getInt(req, "limit")
      data  <- searchPosts(text, order, limit)
    } yield data
  )
```

Вот и всё с первой частью моего введения. Далее я покажу как с помощь всё того-же класса `Validation` можно организовывать не только цепочки проверок до первой ошибки но и аккумуляцию нескольких возможных ошибок. Очень надеюсь, что он потребует меньшего времени.
