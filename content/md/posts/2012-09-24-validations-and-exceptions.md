{:title "Validation и исключения: совместная жизнь"
 :layout :post
 :tags  ["scala" "programming" "exceptions" "scalaz" "validation" "error-handling"]}

 Итак, после ознакомления с основными техниками применения валидаций давайте подумаем как их можно использовать в "реальном" проекте. "Реальный" проект подразумевает работу не в интерпретаторе в течении пары миллисекунд, под чутким присмотром автора, а на сервере далеко за океаном. И лишь изредка суровый незнакомый админ будет проверять не сожрала ли программа всю имеющуюся память...

Это значит,что будет происходить много чего о чём автор кода мог даже не догадываться. А о таких вещах JVM извещает код бросая исключения. Да да, возьмёт и бросит, и плевать ей на чистоту.

Ну и есть ещё один момент, не каждый алгоритм так уж легко записать, обрабатывая ошибки с помощью валидаций. Вот, например, такая штука была в какой-то момент у меня в проекте:

```Scala
def readFields(rec: DBObject, ...): GzVal[DataRecord] = {
  val deletedBy =
    for {
      userId <- get[ObjectId](rec, "deleted_by");
      user <- getUserData(userId).toSuccess(MissedEntity(userId.toString, "user"))
    } yield user
  for {
    id <- get[String](rec, "_id")
    content <- get[String](rec, "content")
    updated <- asValidOption(get[DateTime](rec, "upd"))
    //twelve more
    user <- getUserById(userId, currentUserId map (new ObjectId(_)))
      .toSuccess(MissedEntity(userId.toString, "user"): ValidationError)
  } yield DataRecord(/*you not gonna like it*/)
}
```

В общем-то ничего сложного - берём запись из БД, разбираем проверяем значения, создаём объект. При этом что-то может упасть, но что и как упало на этом уровне никого не волнует. Разбор записи надо прекращать сразу независим от от того нарушилась ли консистентность или умерло соединение с БД.

Мои основные мысли на тему Exceptions vs. Validations можно выразить таким вот набором тезисов:

* Валидации позволяют очень выразительно и кратко обрабатывать ошибки в чистом коде.
* При этом используя и смешивая разные стили обработки ошибок.
* Они требуют небольшой синтаксической избыточности на каждую операцию.
* В то же время исключения часто являются вполне достойной абстракцией для обработки ошибок.
* Они создают значительную синтаксическую избыточность, зато сразу на группу операций.
* Суммируя эти наблюдения с тем фактом, что неожиданные исключения всё-равно будут пролетать, я принял на вооружение следующие принципы:
* Высокоуровневые абстракции в приложении стоит строить используя валидации, однако страховать их на случай совсем внезапной ошибки.
* Тот код который легче написать с использованием исключений нужно писать с использованием исключений.
* Исключения из такого кода надо ловить и преобразовывать в валидации.

Далее я попробую описать основные детали того, как я пытался преобразовать эти принципы в работающую архитектуру. Для начала общая картина, срисованная с моего доклада в Минске.

![Architecture diagram](/img/validations-context.png)

Слева располагается достаточно грязный код, связанный с внешними службами вроде хранилища данных. Он бросает исключения как часть логики. Для него нужно выделить некоторый набор интерфейсных методов, которые перехватывают исключения и преобразовывают их в ошибки (символическая зелёная рамка). Преобразование это является по сути простой функцией, которую (не в случае бибилиотечного кода) вполне можно статически задать просто одну на систему ('Exception converter' на диаграмме).

Те, кто находятся правее написаны в более чистом стиле, игнорируют исключения (в смысле прозрачного пробрасывания наверх, а не в смысле подавления). Об их существовании вновь вспоминает лишь тонкая прослойка, между нашим кодом и внешним миром (в моём случае это был Lift, в других может быть сетевая библиотека или GUI).
Давайте рассмотрим несколько фрагментов кода, для более точного представления этих идей. Скажем для нашего HTTP сервиса из предыдущих примеров мы отказались от строки как от типа ошибки, определив такой класс:

```Scala
abstract class Error(
  val httpCode: Int,
  val code: String)
```

И каких-то его потомков, например так:

```Scala
case class MissedEntity(
  id: String, type: String)
extends Error(404, "MISSED_ENTITY")

case class InternalError(
  @transient Throwable cause)
extends Error(cause, "INTERNAL")
```

Тогда можно легко задать функцию преобразования:

```Scala
val dispatchException: Function[Throwable, Error] = {
  case UserNotFound(name) =>
    MissedEntity(name, "user")
  ...
  // Don't remove it!!!
  case t => InternalError(t)
}
```

Имея на руках такую функцию можно написать систему из методов-врапперов для экранирования интерфейсных методов (зелёная рамочка) и собрать из них более или менее абстрактный модуль. Это будет выглядеть примерно так:

```Scala
def safeVal[T]: Catch[ReqVal[T]] =
  handling(classOf[Throwable]) by { e =>
    dispatchException(e).fail
  }

def safe[T](block: => T): ReqVal[T] =
  safeVal( block.success )
```

Здесь используется стандартный модуль `control.Exception`. Описывающий  обработку исключений в функциональном стиле. Если бы хотелось иметь более гибкую связь исключений с нашими ошибками, например иметь несколько стратегий отображения, то именно соединяя этот модуль с разными функциями отображения мы могли бы добиться необходимой адаптивности кода.

Пользоваться этими служебными функциями можно так:

```Scala
def editData(e: Edit):
  ReqVal[Data] = safe {
    //all dangerous stuff here
  }
```

Экранируя подобным образом методы компонентов связанных с вводом-выводом (или ещё чем-то трудно обрабатываемым при помощи валидаций) мы можем создать на определённом уровне глобальный переход от одного способа работы с ошибками к другому. И стоящая выше логика может пользоваться всеми теми приятностями про которые рассказывал ранее. На картинке это уровни 'Services' и 'Controllers'.

Есть ещё один важнейший момент, который подвиг меня на все эти эксперименты, но о котором я не говорил ранее. Дело в том, что конечной целью было построение REST сервиса, использующего протокол HTTP. Замечательной особенностью HTTP, дичайше игнорируемой всеми, является прямая поддержка сообщений об ошибках. В нём есть понятие кода ответа, что позволяет стандартным образом с детально описанной семантикой отвечать любому клиенту и быть понятым. Ещё раз подумайте, до любого клиента, хоть браузера, хоть curl можно донести что пошло не так и как с этим можно побороться... Вместо этого повсеместно практикуется '200 OK... {error: "Failed to..."}'. Зачем???!!!

Ну да, хватит о грустном. Поговорим о весёлом. А состоит оно в том что если мы представить себе, что у нас есть класс `HttpResponse`, позволяющий описать все ответы. То преобразование из результата R выполнения какой-то операции в `HttpResponse` концептуально абсолютно корректно задать как функцию `Validation[R] => HttpResponse`. Которая естественным образом распадается на незатейливый шаблон:

```
r match {
  case Sucess(r) => buildSuccessResponse(r)
  case Failure(f) => buildFailureResponse(f)
}
```

Где `buildFailureResponse`, как не сложно догадаться задаётся один раз на систему, а весь шаблон легко инкапсулируется в простую конструкцию. Предполагая, что у нас определены фунция-сериализатор `decompose: Any=>JSONObject` и преобразование из объекта ошибки в HTTP ответ errorResponse, можно написать такую функцию.

```Scala
def valsToResponse[A](v: ListVal[A]): HttpResponse = v match {
  case Success(res) =>
    JsonResponse(decompose(rel), successCode)
  case Failure(err) => errorResponse(err)
}
```

Имея операцию `op: A=>ListVal[B]`, где `A` и `B` уже специфичные для приложения классы представления запросов и ответов, можно легко строить (нетривиальные!) обработчики запросов в одну строчку.

```Scala
def getUsers(req: Req, namePattern: String): LiftResponse = valsToResponse {
  getUsersInternal(namePattern) map { users =>
    val (count, list) = users
    Map("count" -> count, "items" -> list)
  }
}
```

Здесь для примера я преобразую пришедший список результатов в пару значений длина и собственно список (ну представим что кому-то из клиентов так удобнее ;) ). В таком примере `getUsersInternal` имел бы тип `String => ListVal[List[User]]`.

Такого вида функции тривиально цепляются к REST модулю Lift - не буду тратить место на пример.

Осталось предусмотреть последнюю деталь: возможность выброса исключения кодом высокого уровня. От них трудно страховаться, и глупо готовиться к ним везде в коде программы. Простое решение - перехват исключения с помощью некоторого хука, который предоставляют большинство контейнеров и фреймворков, конвертация в ошибку и преобразование уже её в ответ. В моём случае таким хуком являлся `LiftRules.exceptionHandler`.

Вот в общем и всё. Наверно выглядит немного сумбурно, но примерно так оно и было. Надеюсь этот пример, кому нибудь поможет.
