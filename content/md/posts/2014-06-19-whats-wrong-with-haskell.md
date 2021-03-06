{:title "Что не так с Хаскелем"
 :layout :post
 :tags  ["haskell" "languages" "thoughts"]}

Недавно тут [вспомнилась](http://eax.me/eaxcast-s02e02/) забавная статья ["Почему язык Haskell так непопулярен"](http://habrahabr.ru/post/163283/) [alt](https://savepearlharbor.com/?p=163283) от одного из вождей соответствующего сообщества. Понял что со времён её публикации мой ответ на заголовок изменился с абстрактного "нихрена не понял" на список из нескольких достаточно конкретных проблем. Их я и попробую тут расписать.

Во-первых нет учебников и справочников по алгоритмам/структурам данных. Большая часть алгоритмов описана в расчёте на дешёвое присваивание и строгие вычисления. Найти описание и анализ нетривиального алгоритма для хаскельных реалий практически не возможно. У того же Окасаки, как я понимаю, половина книги - разработка аппарата для того чтобы только научиться иметь с этим дело.

К предыдущей плотно примыкает проблема номер два. Ленивые вычисления - это фактически полная передача компилятору баланса между потреблением памяти и процессора. Иногда он сдвигает его в совершенно неожиданное место и программа вдруг начинает требовать феерические объёмы ресурсов. Что с этим делать непонятно, гайды которые мне удавалось находить написаны для разрабов этого самого компилятора. В них в принципе нет введений, даже нет ссылок, предполагается что огромная масса знаний о реализации вычислительной модели уже в голове. Что делать человеку который прочитал LYHGG, написал первый алгоритм и получил время выполнение или потребление памяти в районе лунной орбиты непонятно.

Лирическое отступление. Пару лет назад я проходил на курсере курс по алгоритмам. Начать попробовал на хаскеле. Первым заданием было посчитать inversions, то есть нарушения порядка в массиве. Решение я написал сравнительно быстро, мин 40. Проблемы начались при запуске - программа пожирала всю доступную память. Несколько ритуальных плясок в обходе списка позволили программе вмещаться в пару гигабайт памяти и 20 минут. И да, выдавать [корректный](https://twitter.com/puffnfresh) ответ для пары тысяч чисел в первой версии, спустя полтора часа...

Обзор тематических ресурсов подходы к решению проблемы найти не позволил. Консультация с коллегой-фаном хаскеля, который кстати тоже получил что-то не вменяемое в первой версии программы, и перестановка чего-то там в паре выражений (перед глазами встал призрак 2003 студии где перестановка инклудов иногда чинила access violation)  позволили сократить время до нескольких минут. Для интереса сделал тоже на питоне за 10 мин, 20 или 30 секунд выполнения и символическое потребление памяти. Искать с помощью Хаскеля минимальный разрез графа из нескольких тысяч узлов я уже не рискнул.

Ну и главное: нет примеров полномасштабных приложений. Какая нибудь обработка исключений от трёх функций с помощью стрелок находится легко. Исходник простого веб-сервера, без расширений языка, без 90% закопанного в библиотеки найти сложно. Хотелось бы увидеть простой аналог рисовалки или текстового редактора. Что угодно что демонстрирует в рамках 3-4 экранов дизайн полноценного приложения которое читает, пишет, показывает что-то пользователю, реагирует на ошибки и нарушения форматов. Таких примеров нет, невозможно оценить какой массив знаний необходим для создания полноценного приложения. Теркат? Трансформеры? Дисер Окасаки? Свободная навигация по исходникам компилятора? Я за три года так и не понял.

Ещё для меня серьёзной проблемой является типографический кретинизм большинства авторов. Он проявляется в нескольких аспектах. Во-первых для функции нормально [не иметь человеческого имени](http://stackoverflow.com/questions/7746894/are-there-pronounceable-names-for-common-haskell-operators). Пишем <*>, в уме проговариваем "треугольная жопа", как описать код коллеге не понятно. Во-вторых статьи абсолютно всех уровней, от ICFP до очередного тьюториала по монадам в блоге программиста Васи наполнены типографскими аналогами собственно операторов языка, то есть вместо -> везде →. Какая-нибудь тау с нижним и верхним индексом - тоже святое дело. Вообще обучение на примере кода который не запускается - норма для данного сообщества. В том же LYHGG процентов 30 не работало ещё три года назад когда я его читал.

Ну и сообщество. Я там выше давал ссылочку на любителя корректных программ, подпишитесь - понаблюдайте недельку. Подумайте что делать если к такому существу придётся обращаться за поддержкой или оно окажется у вас в команде. Справедливости ради надо заметить что те кто собственно что-то делает, разработчики самого компилятора и популярных билиотек более вменяемы и не лишены кругозора.

Чуть не забыл, данная заметка не претендует на полный охват предмета. Haskell имеет некоторое (конечное) количество положительных черт, но я тут про них умолчал. Жаждущие серебряных пуль могут найти их в интернете во множестве.

UPD: Буду сюда докидывать пруфы

- [Need help - my haskell code is over 50 times slower than equivalent perl implementation](http://www.haskell.org/pipermail/haskell-cafe/2014-June/114724.html)
- [The reasons I don’t write all my code in Haskell](https://codeflow.wordpress.com/2011/02/20/the-reasons-i-dont-write-all-my-code-in-haskell/)
- [Where is Haskell going in industry?](http://ru.reddit.com/r/haskell/comments/2a310v/where_is_haskell_going_in_industry/)
- [What's the performance bottleneck in this prime sieve function?](http://ru.reddit.com/r/haskell/comments/2aerm7/whats_the_performance_bottleneck_in_this_prime/)
- [Beginner - Parse Error on Input '='](http://ru.reddit.com/r/haskell/comments/2ain3c/beginner_parse_error_on_input/)
- [How do you avoid the Cabal Hell™?](http://ru.reddit.com/r/haskell/comments/2al3vx/how_do_you_avoid_the_cabal_hell/) (третий пункт прекрасен, изящный функциональный дизайн типа)
- [Complete roadmap from total novice to Haskell mastery?](http://ru.reddit.com/r/haskell/comments/2ali12/complete_roadmap_from_total_novice_to_haskell/)
- [How do you structure a program to support logging?](http://www.reddit.com/r/haskell/comments/2fxjcg/how_do_you_structure_a_program_to_support_logging/)
- [Why is foldl bad?](http://www.reddit.com/r/haskell/comments/2n0991/how_lazy_evaluation_works/cm9qx7v)
