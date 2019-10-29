{:title "Нетипичные IDE"
 :layout :post
 :tags  ["ide" "languages" "thoughts"]}

 Не так давно я написал довольно обстоятельный пост про проблемы современных IDE. В частности подробно отписался почему они могут нанести существенный ущерб проекту без должной осторожности и почему заметной пользы они не приносят. Что характерно пост получился самым популярным за историю блога и много народу не поленилось даже отстоять любимый инструмент в твиттере.

Пришло время перейти к конструктиву и немного посмотреть как их можно делать среды которые что-то меняют в процессе разработки. Есть изрядное количество инструментов которые пытаются продвинуться за пределы 95го года и существенно изменить способ взаимодействия программиста и разрабатываемой им программы.

Вот например [Squeake](http://www.squeak.org/), первый релиз 96 год. (Небось думали я с потолка год в прошлом посте взял? Правильно думали на самом деле, да и большинство обсуждаемых далее фич были в [Smalltalk-80](http://weather-dimensions.com/tedkaehler/us/ted/resume/st80release-lic2.jpg)). Я наверно повторяю очень известную вещь, но всё таки: основной чертой Smalltalk является существование live image. В нём нет статического кода и времени исполнения, всё что делает программист порождает объекты в одном образе, этот образ несёт в себе и код и живые объекты на одинаковых правах. Образ содержит и ядро языка, и разрабатываемое приложение, и среду разработки одновременно, при поставке пользователю ненужные классы удаляются.

Подход этот конечно спорный, но он имеет несколько явно положительных результатов. Например при разработке графики можно весьма просто с ней управляться. Например имея нарисованную как-то картинку можно немного её покрутить, примерить к другой картинке, продублировать. [Как-то так](http://www.youtube.com/watch?v=oH-Jj_1v8BM#t=78) или [так](https://www.hpi.uni-potsdam.de/hirschfeld/trac/SqueakCommunityProjects/raw-attachment/wiki/squeak_screencasts/Image-Halos.m4v) (вторая ссылка покороче, но требует скачивания видяшки). А после соответствующего благоустройства среда позволяет [что-то программировать](http://www.youtube.com/watch?v=34cWCnLC5nM) даже детям. Ну и вообще она полна простых приятностей, вот например Object inspector.

![Object inspector](/img/Exploring-ObjectExplorerInspector-2.jpg)

"Чего же тут такого интересного?" - многие спросят. Вроде и ничего, но вот 2014 год на дворе а все популярные среды разработки по-прежнему считают что цвет нормально показывать как десятизначное число.

Второй интересной наработкой Smalltalk является [method finder](http://wiki.squeak.org/squeak/1916). Первая его фича - поиск по ключевым словам более менее освоена современными IDE. А вот вторая, поиск по примеру и сейчас, спустя примерно 30 лет после создания насколько я знаю ни кем не повторена. Если кратко она позволяет ввести пример результата метода при заданных аргументах и получить список методов которые этому примеру удовлетворяют. Например на запрос ' trim my spaces '. 'trim my spaces' он ответит #withBlanksTrimmed.

Ладно, хватит истории, вот пара проектов которые прямо сейчас в разработке. Первый, собравший 300k$ на кикстартере, [Light table](http://www.lighttable.com/). Это IDE которая должна решить несколько известных проблем и серьёзно пересмотреть постановку других. На данный момент она нацелена на поддержку Clojure, JavaScript и Python. Среди наиболее интересных фичей:

- Абстрагирование от файлов проекта, редактор показывает и даёт редактировать функции динамически компонуя их по мере просмотра и редактирования исходников.
- Автоматический показ документации и/или исходников связанных функций.
- Интерактивная отладка, как через горячую подмену кода так и через 'watches' которые позволяют записывать и отображать состояние программы в отдельных точках.

Текущие релизы правда пока сконцентрированы на разработке тюнингуемого редактора. Но разрабы [полны решимости](https://groups.google.com/d/topic/light-table-discussion/1Hyeia7TXag/discussion) довести первоначальную идею до конца, вплоть до запила своего языка с блэкджеком и монадами.

Проект [Lamdu](http://peaker.github.io/lamdu/) параллельно развивает язык и среду разработки для него. Язык построен на основе Haskell с изменениями направленными на большую явность конструкций и адаптацию для визуального представления структуры программ. В частности он вводит обязательные имена параметров для функций и явно отображает типы в лямбда-выражениях.

Среда построена вокруг структурированного представления и редактирования кода с выделением различных элементов шрифтом и цветом.  Редактор позволяет вводить код только в предназначенные для этого слоты, контролирует после ввода тип, предполагаются умные автодополнения. Ошибки типизации получаются хорошо локализованы (не могу не заметить что оригинальный хаскель тут от C++ ушёл совсем не далеко, точность ошибки компенсируется неопределённостью её местоположения).

Редактор автоматически применяет визуальную свёртку сложных языковых конструкций (вроде лямбд и аннотаций параметров как на картинке). Среди целей проекта предоставление билиотекам возможности настраивать отображение для своих структур данных и функций.

![Lamdu](/img/lamdu.png)

Также предполагается поддержка "regression debugging", то есть автоматический контроль хода выполнения теста и поиск изменения которое сломало тест. Примерно можно сказать что IDE будет запоминать все промежуточные результаты вычисления функций и сравнивать их для каждой версии. Хотя в контексте ленивости языка всё явно будет хитрее.

Помимо попыток привнести глобальные улучшения в IDE есть несколько инструментов реализующие какие-то конкретные компоненты гораздо лучше, чем принято в мэйнстриме.

Вот например [Projucer](http://2013.cppnow.org/session/the-projucer-live-coding-with-c-and-the-llvm-jit-engine/), инструмент визуальный разработки для [Juce](http://www.juce.com/). Ничего сверхъестественного, просто быстрая связь кода и картинки, но всё-таки поживее многочисленных SWING-дизайнеров, а пишется одним человеком.

Ещё один проект, коммерческий, [Chronon](http://chrononsystems.com/what-is-chronon). Включает в себя "Time Traveling Debugger". Это забавный инструмент который работает с полной записью исполнения программы. Записи получаются с помощью чёрной магии и второго компонента Chronon'а - "Recording Server". Нам же тут интересен дебаггер.

Его центральной фичей является возможность идти не только вперёд но и назад. Найдя ошибку можно вместо того чтобы расставлять бряки в подозрительных местах и перезапускать программу просто пойти назад и посмотреть "откуда пошло". Есть множество приятностей, вроде подсветки активных путей исполнения, истории состояний для переменных и вызовов методов. Много различных фильтров для поиска нужных значений в истории. Для примера можно посмотреть [вот это видео](http://www.youtube.com/watch?v=X80EdpI9z1Y).

Последний пример с совсем неожиданного направления, из мира железячных корпораций и кровавого геймдева. PhysX debugger - инструмент для физического движка от nVidia. Он создан для отладки поведения физической модели в сложных сценах. И демонстрирует очень высокий уровень использования различных визуализаций. Если вам интересно визуальное программирование я рекомендую потратить 15 мин и посмотреть обзорный ролик целиком: [PVD tutorial video](https://www.youtube.com/watch?feature=player_embedded&v=aKsY-U4kUBA).

В этом инструменте есть множество примеров визуализации разных аспектов динамических сцен и процесса их вычисления, вот [интересный кусочек](https://www.youtube.com/watch?feature=player_embedded&v=aKsY-U4kUBA#t=434) для ленивых (смотреть минуты три). Есть функции бэктрекинга, когда есть бажный объект, есть момент времени когда с ним что-то не так и надо найти откуда проблема появилась. Предусмотрены инструменты для командной работы, можно аннотировать дебаг-сессию оставляя каменты к объектам в определённые моменты времени. Сессия экспортируется и может быть передана коллеге для дальнейшего разбора проблемы. Действительно развитый инструмент для решения весьма нетривиальных задач.

Напоследок уже в который раз не могу не дать ссылку на сайт Bret Victor'а, которого авторы большинства описанных выше проектов называют в числе основных источников идей: [worrydream.com](http://worrydream.com/). Если Вы ещё не изучили все его материалы стоит немедленно начать.