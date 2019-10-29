{:title "Land of Lisp"
 :layout :post
 :tags  ["books" "lisp" "racket"]}

Дочитал сабж. Как можно догадаться книга посвящена языку LISP и выстроена очень своеобразным образом. Основная идея: обучить языку через написание игр. Этот, на первый взгляд направленный на детей, подход в моём случае имел изрядный успех.

Писать игры по ходу книги отличная идея по нескольким причинам. Во-первых это заставляет автора начинать с практически важных, базовых элементов языка. С того с чем в будущем придётся сталкиваться чаще всего, а не с того что педагогически "правильнее". Во-вторых иллюстрации получаются заметно увлекательнее. Ну и наконец игры по своей природе открыты для хакинга, придумать дополнение к числам Фибоначчи гораздо сложнее чем к игре "угадай число".

Скажу честно не все примеры я аккуратно реализовывал и запускал, но примерно 60% задач из книги я выполнил. Что-то расширил, где-то поменял структуру кода - подход с созданием игр в книге даёт читателю очень высокий уровень вовлечённости и это прекрасно.

По содержанию... Книжка раскрывает все основные вопросы программирования: встроенные и пользовательские типы данных, основные конструкции языка, способы их расширения, ввод-вывод. Последовательность практических примеров как мне кажется совершенно логична, хотя порядок в котором вводятся языковые средства немного не отточен.

Код примеров на мой вкус немного грязноват. Много где можно радикально улучшить читабельность простыми изменениями вроде добавления структур вместо списков и магических ca*r'ов, заменой анонимных функций на именованные. Стиль который она оставляет после себя как мне кажется нельзя назвать изящным, но это мнение нуба явно тяготеющего к диалектам Scheme-семейства а не Common для которого написана книга.

И да, просто копировать примеры в таком виде было не очень интересно и решение нашлось само собой - я недавно начал ковырять Racket а книжка то написана под Common LISP! Вот и совместил приятное с полезным, [транслировал примеры](https://github.com/CheatEx/land-of-lisp-rkt) на современный Racket. И я теперь практически лисп-переводчик с опытом работы :) Кстати благодаря этой книжке я сделал и небольшой (и кажется первый сколько-нибудь полезный) вклад в опенсурс: изрядно [подвыправил](https://github.com/follesoe/sublime-racket/pull/3) Racket плагин для Sublime.

В общем несмотря на то что книжка вроде не блестящая при должном настрое и желании что-то поделать руками она приночит массу удовольствия. Рекомендую!