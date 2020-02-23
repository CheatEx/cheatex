{:title "Немного мыслей о тестировании и тестерах"
 :layout :post
 :tags  ["testing" "qa" "thoughts"]}

Последние пара дней отличились интенсивностью общения с группой тестирования, что повлекло ряд мыслей...

Во-первых, какие задачи решают баг-репорты:

1. Идентификационную. Если у нас есть какая-то штука, то мы должны уметь посмотреть на другую и сказать "она такая-же" или "она другая". Тут надо понимать, что имеется в виду не просто уникальная цифра, а именно возможность имея перед глазами какую-то картину, пусть и с затратами, понять сталкивались ли мы с этим раньше(хотя цифра тоже не лишняя: с ней мы изрядно экономим на трафике и длине логов в месенджерах).
2. Документирующую ака историческую. В проекте всё должно быть записано. Потомки должны знать ошибки предыдущих поколений, и знать, что это ошибки, и иметь возможность их найти позже.
3. Коммуникативную. Крайнее Ответственное лицо должно узнать о том, что что-то "не так". Мало того узнав оно должно не бежать в соседнюю комнату или ждать пока к нему подойдут, чтобы потыкать пальцем в монитор. Оно должен после прочтения брать и воспроизводить проблему.

Далее, как метко [подмечает](http://www.slideshare.net/Cartmendum/testlabs09-part-i) товарищ [Сartmendum](http://cartmendum.livejournal.com/) основная боевая мощь живых тестеров сконцентрирована в двух фичах:

1. Способности "смотреть по сторонам". То есть замечать окружение ошибки и передавать важные его особенности.
2. Написании репортов на "человеческом языке". То есть рассказывать не что падает, а как падает.

А теперь, проникнувшись важностью процесса тестирования и благородной миссией людей его выполняющих, закрываем глаза и представляем баг из одного скриншота (в jpg кстати, но это другая история...) с обведённым в пейнте каким-то полем и комментарием типа: "Illegal status of nuclear fusion reactor"... 

Грустно. Сколько задач решает такая штука? А сколько времени убивается на то, чтобы эти задачи всё-таки решить?

А сколько заняло бы создание нормального описания ошибки?