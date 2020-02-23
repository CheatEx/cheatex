{:title "Сложность vs дублирование"
 :layout :post
 :tags  ["design" "programming"]}

Предпоследняя моя задачка в GGA была весьма символичной.

Краткое описание проблемы. Есть около года кодируемая форма в духе treetable. Работа с данными организована следующим образом: с сервера приходят какие-то структуры, они конвертируются во что-то типа встраиваемой RDB и она подкладывается как модель этой форме. Это буйство технологии несло в себе следующие проблемы:

- Всё, в смысле 80% логики приложения - один класс. (банальность)
- Работа с данными не читабельна на корню. (банальность)
- То, что приходит с (ну потом и уходит на) сервера совпадает с тем, что хранит модель процентов на 60. Что-то вычисляется, что-то нужно для работы самой формы, назначение чего-то никто не знает. (сабж)

Последний пункт вызывал проблемы косвенно, но весьма изрядные: и в модели формы и в структурах, которыми общался сервер был ряд полей реально не используемых на разных этапах жизни этих данных. Кое-что перекладывалось из одного поля в другое в некоторые волшебные моменты времени. В общем удержать в голове что-откуда-куда-зачем было абсолютно нереально.

И вот мне была поставлена задача создать новую модель данных для формы и и продумать какую-то кхм... ну пускай архитектуру для работы с данными. Причём предполагалось добавление альтернативных отображений тех-же данных - с каким-то комбинированием полей, новыми вычислимыми полями и т.п.

Мысль мне пришла достаточно быстро: ввести 3 уровня.

1. Структуры для взаимодействия с сервером, просто структуры.
2. Доменные классы. Несущие только то, что необходимо для операций над данными и показа пользователю.
3. Классы модели для конкретных представлений. Отображение второго уровня под нужны конкретного представления и локально-значимые поля.

И вроде-бы всё хорошо - уровни выделены, для каждой функции боле-менее понятно где она должна лежать, количество информации для единовременного хранения в памяти программиста должно резко пойти на убыль. Вот только повторяются структуры на этих уровнях процентов на 80. Одно и то же поле ObjName, именно оно самое, с нулевой семантической вариацией повторяется 3, а в перспективе и больше раз.

Альтернатива совсем очевидна - дополнить структуры используемые при общении с сервером недостающими полями и логикой. Повторений нет, но один и тот-же класс использовался бы в нескольких местах абсолютно по-разному.

Так что-же получается: выбор дублирование или разрыв мозга? Может есть решение без таких крайностей? Я не нашёл :(

Ещё интересно кто какой вариант выбрал бы в такой ситуации?