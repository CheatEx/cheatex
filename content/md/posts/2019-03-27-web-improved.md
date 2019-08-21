{:title "The HTML we shouldn't ever have"
 :layout :post
 :tags  ["thoughts" "web" "TG repost"]}

Мне попался [проект как сделать вэб лучше](http://skch.net/view.php?page=articles&post=bhtml) и что-то мне кажется проработан он весьма поверхностно...

Для начала автор сетует что аттрибут `src` не был внедрён повсеместно, а только для `img`. В частности:

> Everyone was fascinated with the new features, and most likely the reason why no one had a wit to ask: why don’t we let all the other HTML elements also use this attribute?
> <h1 src="/website/info/title"> </h1>
> This code means that the browser must load the content of the heading from the provided URL. Maybe it doesn’t make much sense for such a small element, but what about a div or an article?

Дальше больше, автор предлагает ввести подстановки в язык разметки, в духе

```
<div id="name">George</div>
<h1>Welcome, $name</h1>
```

Дело тут какое. Во-первых src много где есть, например в [полюбившемся всем](https://www.owasp.org/index.php/Cross_Frame_Scripting) `iframe`. И кое-где он [уже доставляет](https://www.owasp.org/index.php/Clickjacking).

Во-вторых давайте почитаем что говорит один из авторов современного web про проблемы которые он пытался решить.

Что требовалось от HTML и где он не справился:

> HTML is an example of a media type that, for the most part, has good latency
> characteristics. Information within early HTML could be rendered as it was received...
> 
> However, there are aspects of HTML that were not designed well for latency. Examples include: ...; 
> embedded images without rendering size hints, requiring that the first few bytes of the image 
> (the part that contains the layout size) be received before the rest of the surrounding HTML 
> can be displayed; dynamically sized table columns, requiring that the renderer read 
> and determine sizes for the entire table before it can start displaying the top; ...

В моём понимании рац. предложение из поста - сразу два шага назад. Первый - больше запросов на страницу, второй - еще больше компонентов которые не могут рисоваться до полной загрузки.

Теперь немного оценки `src` в контексте `iframe`.

> ... The introduction of “frames” to the Hypertext Markup Language (HTML) caused
> similar confusion. Frames allow a browser window to be partitioned into subwindows,
> each with its own navigational state. Link selections within a subwindow are
> indistinguishable from normal transitions, but the resulting response representation is
> rendered within the subwindow instead of the full browser application workspace. This is
> fine provided that no link exits the realm of information that is intended for subwindow
> treatment, but when it does occur the user finds themself viewing one application wedged
> within the subcontext of another application.

Здесь нельзя указать на очевидную деградацию, own navigational state вроде не предлагается. Но предлагается использовать в src переменные с не совсем понятной областью видимости персистентностью. Ограничения на куда `src` ходит типа тоже не нужны?

Ничего не сказано о том как читать/писать/переопределять стили и новые $-переменные в подгруженных из src элементах. Без модели каскадирования - это просто размахивание руками. Проблему с ней ведь и пытаемся решить, не?
