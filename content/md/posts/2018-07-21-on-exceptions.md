{:title "Проблема с исключениями"
 :layout :post
 :tags  ["excetions", "java", "error-handling" "TG repost"]}

С исключениями есть одна большая проблема. В каждой команде которую мне довелось встречать было своё уникальное видение как их "правильно" применять.

Какие? Где кидать? Когда кидать? Где ловить? Все эти вопросы дают комбинаторный взрыв стилей и широкий простор для самовыражения. Каждый вариант ответа имеет свои фатальные недостатки, но их можно и проигнорировать для любимого набора. Носители альтернативного набора ответов обрекают всех окружающих на вечные муки и должны немедленно высылаться прямиком в ад. (Ну или в недельное кодревью хотя бы.)

Набор который мне нравится:

1. В понятных ситуациях кидаем checked ловим как только можем с ними что-то сделать.
2. В непонятных делаем assert, в случае религиозно-операционных трудностей создаем AssertionError.
3. Сторонний код признающийся в выбросе исключений или замеченный за этим заворачивем.
4. Error ловим только на уровне точек входа, вроде запуска потоков или обработки сети.

Да, и у него тоже есть фатальные недостатки.

А еще я не разу встречал различных мнений по тому как использовать [Either](https://www.scala-lang.org/api/2.9.3/scala/Either.html).