{:title "A Philosophy of Software Design"
 :layout :post
 :tags  ["books" "programming"]
 :draft? true}

С удовольствие и легко прочитал "A Philosophy of Software Design". Отличная, коротка и по делу книга. Возможно и не перевернёт жизнь 10+ лет программиста, но определённо поможет яснее сформулировать некоторые идеи. Кроме того можно советовать начинающим профессионально программировать как краткое введение в вопрос "как не похоронить себя под горой кода?".

Книга начинается тем что пытается определить сложность кода и научиться её видеть. Также автор немного философствует о причинах её появления и накопления. В общем вопрос рассматривается от сравнительно простых и конкретных вещей к более абстрактным. Рассматривается какие альтернативы открываются при дизайне отдельных модулей, их взаимодействии, выстраивании в уровни. Вводит понятие интерфейса и как его можно строить отдельно от реализации, рассматривает обработку ошибок. Очень существенная часть книги посвящена комментариям. Отдельно обсуждается вопрос комментарии vs. именование. В конце обсуждаются вопросы последовательности и очевидности в больших кодовых базах и как они сочетаются с желанием эволюционировать код и продукт.

Очень удачно в книге выделены специальные секции: принципы и красные флаги. Первые - краткие формулировки содержания главы, легко помещающийся и пригодный для быстро коммуникации гайдлайн. Вторые - признак грядущей проблемы с поддержкой кода, заметив который стоит еще немного подумать. Они разбросаны по тексту и удобно повторены в приложении в конце.

Right level of detail

Taking it too far section

Selected ideas:
1. Module deepness
2. Design out of existence
3. Doc close to code in placement and far in level

Missing:
1. Actual collaboration concerns
2. Configurations and deployment discussion
3. Third-party vs self-made