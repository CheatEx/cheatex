{:title "Erlang and OTP in Action"
 :layout :post
 :tags  ["books" "programming" "erlang" "OTP"]}

Продолжаю разбираться с эрланговым миром и прочитал самую рекомендуемую в интернетах книгу. Несмотря на название она затрагивает самый минимум языка и сконцентрирована на OTP и всякой платформенной инфраструктуре.

В основном содержание посвящено взаимодействию процессов, сообщениям, сигналам, мониторам и gen_server. Мне понравилось как подробное рассмотрение этих топиков так и то что каждый из них применяется в нескольких примерах к разным проблемам дизайна. Вообще по ходу книги пишется где-то 3-4 объёмных примера, не то чтобы имеющие особый прикладной смысл, но дающие представление о заметных объёмах кода. По уже давней традиции я их повторял на другом языке, Эликсире. Во-первых мне интересен в этот язык а во-вторых это лишало возможности подменить понимание копипастой.

Из второстепенных топиков рассматривался gen_event, который не рекомендован к применению в эко Эликсира и тот пример вообще передизайнить пришлось. Были гайды по отладке и логированию, довольно универсальные. Пара вариантов использования Эрлангового API сокетов, push/pull, пре-парсинг HTTP. Обширная глава по интеграции нативного кода, хотя примеры оттуда я воспроизводить не стал.

В общем качественная техническая книга, не особо просвещает опытного программера но хорошо вводит в технологию. При дополнительных вложениях времени в изучение доков помогает и в Эликсире. Также даёт много вариантов поделать что-то руками если нет времени идей для проекта побольше.