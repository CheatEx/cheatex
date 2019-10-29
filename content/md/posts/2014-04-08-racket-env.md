{:title "Альтернативная среда для Racket"
 :layout :post
 :tags  ["racket" "lisp" "ide" "sublime"]}

Это последний отчёт о моих опытах с Racket и посвящён он сугубо техническому вопросу, а именно среде разработки. По умолчанию новоиспечённому Racket-разработчику предлагается минимальная среда разработки. Она умеет открывать файлы с исходниками, подсвечивать синтаксис, загружать их в простой (ну очень простой) REPL и запускать под отладкой.

В принципе это не так и мало, но хотелось большего. А именно:

- Полноценного REPL который бы помнил историю команд и умел подгружать изменения без полного перезапуска.
- Быстрой навигации по именам функций и структур.
- Богатого функционалом текстового редактора, в частности мультивыделения и быстрого поиска.
- Поддержки проектов, по крайней мере коллекций файлов по которым можно искать.

REPL достаточно быстро нашёлся, [xrepl](http://docs.racket-lang.org/xrepl/). Он прекрасно помнит историю, умеет (пере)загружать файлы, заходить в них чтобы тестировать не экспортированные функции и органично встраивается в shell. Инструкция по установке на сайте хорошо работает, для полного счастья только пришлось добавить в bash_aliases следующую строчку: `xracket="racket -il xrepl"`. Она запускает Racket в интерактивном режиме и загружает модуль xrepl. Модуль написан таким образом что сам применяет все необходимые хаки для создания полноценной оболочки.

Однако не сразу всё идеально заработало. Файлы с константами было невозможно перезагружать ,rr - Racket выдавал ошибку переопределения имён. Небольшое исследование вопроса показало что это связано с включенными по умолчанию оптимизациями и легко может быть исправлено одной командой, алиас принял вид `xracket="racket -il xrepl --eval '(compile-enforce-module-constants #f)'"`.

Остальные 3 функции поставляет Sublime оставалось только подружить его немного с ЛИСПом, благо я не первый кто этим озадачился. Установка пары плагинов налаживает между крепкую дружбу между Racket и Sublime. Для упрощения жизни я использовал [Package Control](https://sublime.wbond.net/installation#st2).

Первый и самый насущный - конечно отступы :) [lispindent](https://sublime.wbond.net/packages/lispindent) - отлично справляется с этой задачей и даже не пугается квадратных скобок.

Второй - [подсветка синтаксиса](https://github.com/follesoe/sublime-racket). В принципе она уже была, однако некоторые конструкции понимала не корректно. В частности совершенно убивали подсветку литералы #something а также функции и структуры не появлялись в списке символов. За пару дней поправил всё это и даже заслал патч в основную ветку проекта.

Ну и последняя доводка из области эстетства - красивая подсветка скобок и быстрый переход между ними. Делается плагином Bracket Highlighter. Очень удобно показывает границы блока слева, рядом с номерами строк а также позволяет включить "усиленную подсветку" - дополнительно подсветить весь текст принадлежащий выделенному блоку. Плюшки вроде удалить блок или перейти во внешний также присутствуют.

Для того чтобы всё это дружило потребовалось буквально пара настроек.

Во-первых надо включить lispindent для соответствующего языка следующей настройкой в `lispindent.sublime-settings` (если используется Package Control то его можно открыть через меню Preferences->Package settings).
```
{
  "languages": {
    "racket": {
      "syntax": "Racket.tmLanguage"
    }
  }
}
```
В настройках Bracket Highlighter, которые `bh_core.sublime-settings` (также легко открываются через меню Preferences->Package settings) надо только найти и настроить под себя параметр `high_visibility_style`, мне понравился `underline`. Также удобно повесить переключение этого режима на хоткей, для этого в `Default.sublime-keymap` надо дописать
```
{
  "keys": ["ctrl+\\"],
  "command": "bh_toggle_high_visibility"
}
```
Ну и проверить что файлы `.rkt` открываются как Racket по умолчанию.

В принципе это всё. Я первый раз что-то глубоко копал в настройку Sublime и результат мне очень понравился. Всё, вплоть до написания своего плагина, решается достаточно легко и работает вполне безглючно.