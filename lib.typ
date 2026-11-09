// Шаблон отчёта по ГОСТ Р 7.0.11-2011 для кафедры ВТиЭ АлтГУ.
// Портирован с altsu-report.cls (LaTeX).

#let indent-length = 1.25cm

// Межстрочный интервал: шаг строк 24,05 пт (полуторный для Times New Roman 14 пт),
// как в эталоне; такой же зазор между абзацами, списками и строками реферата.
#let line-gap = 14.35pt

// Нумерация страниц: титульный лист (страница 1) остаётся без номера.
#let page-numbering(n, ..rest) = if n == 1 { [] } else { numbering("1", n) }

// Нумерация заголовков вида "1.", "1.1.", "1.1.1."
#let gost-heading-numbering(..nums) = {
  nums.pos().map(str).join(".") + "."
}

// Нумерация списков по методичке ИВТ п. 2.2.4: "1)", вложенные — "1.1)", "1.1.1)".
#let gost-enum-numbering(..nums) = nums.pos().map(str).join(".") + ")"

// Расшифровка обозначений под формулой: начинается со слова «где», без красной строки
// (методичка ИВТ п. 2.5.2).
#let legend(body) = par(first-line-indent: 0pt, body)

// Признак заголовка приложения: такой заголовок выравнивается вправо.
#let appendix-supplement = [Приложение]

// Нумерация формул вида "(1.1)" в пределах главы (методичка ИВТ п. 2.2.9).
#let gost-eq-numbering(n) = "(" + str(counter(heading).get().first()) + "." + str(n) + ")"

// Нумерация рисунков/таблиц/листингов вида "<номер главы>.<номер элемента>"
#let gost-figure-numbering(n) = {
  let ch = counter(heading).get().first()
  str(ch) + "." + str(n)
}

// Оформление листингов кода (ГОСТ-стиль: рамка, номера строк, аналог minted/frame=lines).
#let code-listing(raw-elem) = {
  set text(font: "DejaVu Sans Mono", size: 8pt)
  set par(leading: 0.55em, spacing: 0.55em)
  block(
    width: 100%,
    stroke: (top: 0.5pt, bottom: 0.5pt),
    inset: (x: 6pt, y: 5pt),
    breakable: true,
    grid(
      columns: (1.3em, 1fr),
      column-gutter: 0.5em,
      row-gutter: 0.4em,
      align: left,
      ..raw-elem.lines.map(line => (
        align(right, text(fill: gray)[#line.number]),
        line.body,
      )).flatten()
    ),
  )
}

// Титульный лист.
#let make-title(
  ministry: "",
  country: "",
  fulluniversityname: "",
  institute: "",
  department: "",
  shortdepartment: "",
  worktype: "",
  title: "",
  author: "",
  groupnumber: "",
  supervisor: "",
  supervisordegree: "",
  date: "",
  ..sink,
) = {
  set align(center)

  [#ministry~#country]
  v(0.5cm)
  upper(fulluniversityname)
  v(0.5cm)
  institute
  v(0.5cm)
  [#department~(#shortdepartment)]
  v(2cm)
  worktype
  v(0.5cm)
  upper(title)
  v(1cm)
  v(29.1pt)

  let blank(w) = box(width: w, line(length: 100%))
  let signer(role, name) = block(width: 45%, above: 0pt, below: 0pt, breakable: false)[
    #set align(left)
    #set par(first-line-indent: 0pt)
    #role \
    #blank(2.3cm) #name \
    «#blank(0.7cm)» #blank(2cm) #datetime.today().year()~г.
  ]
  align(right)[
    #signer([Выполнил студент #groupnumber~группы:], author)
    #v(16.1pt)
    #signer([Проверил: #supervisordegree], supervisor)
  ]

  v(1fr)

  [Барнаул~#date]

  pagebreak()
}

// Страница реферата.
#let make-abstract(
  count-work-page: "",
  count-work-img: "",
  count-work-lit: "",
  count-work-tab: "",
  keys-ru: "",
  abstract-ru: "",
  ..sink,
) = {
  align(center)[РЕФЕРАТ]
  v(1.15em)

  let row(label, value) = {
    [#label #h(1fr) #value]
    parbreak()
  }
  row([Объем работы листов], count-work-page)
  row([Количество рисунков], count-work-img)
  row([Количество используемых источников], count-work-lit)
  row([Количество таблиц], count-work-tab)

  upper(keys-ru) + [.]
  parbreak()

  abstract-ru
  parbreak()

  [Отчёт оформлен с помощью системы компьютерной вёрстки #smallcaps[Typst].]

  pagebreak()
}

#let report(
  ministry: "",
  country: "",
  fulluniversityname: "",
  institute: "",
  department: "",
  shortdepartment: "",
  worktype: "",
  title: "",
  author: "",
  groupnumber: "",
  supervisor: "",
  supervisordegree: "",
  date: "",
  keys-ru: "",
  abstract-ru: "",
  count-work-page: "",
  count-work-img: "",
  count-work-lit: "",
  count-work-tab: "",
  body,
) = {
  set document(title: title, author: author)

  set text(
    font: "Times New Roman",
    lang: "ru",
    size: 14pt,
  )

  set page(
    paper: "a4",
    margin: (left: 3cm, right: 1.5cm, top: 2cm, bottom: 2cm),
    numbering: page-numbering,
    number-align: top + right,
    header-ascent: 30.2pt,
    header: auto,
  )

  set par(
    justify: true,
    leading: line-gap,
    first-line-indent: (amount: indent-length, all: true),
    spacing: line-gap,
  )

  set list(indent: 0pt, body-indent: 0.5em, marker: [-])
  set enum(indent: 0pt, body-indent: 0.5em, numbering: gost-enum-numbering, full: true)

  // Как в altsu-report.cls (labelindent=\parindent у 1-го уровня, 0 у вложенных):
  // номер или маркер списка первого уровня начинается на абзацном отступе.
  // Вложенный список лежит в теле пункта, поэтому его метка стоит там же,
  // где текст пункта уровнем выше.
  let list-depth = state("list-depth", 0)
  let indent-top-level(it) = context {
    if list-depth.get() == 0 {
      list-depth.update(1)
      pad(left: indent-length, it)
      list-depth.update(0)
    } else {
      it
    }
  }
  show list: indent-top-level
  show enum: indent-top-level

  set heading(numbering: gost-heading-numbering)

  show outline.entry.where(level: 1): it => upper(it)

  // Методичка ИВТ п. 2.1.9: переносы в заголовках не допускаются.
  show heading: set text(hyphenate: false)

  // Заголовок главы: сброс нумерации рисунков/таблиц/листингов и оформление.
  // В Typst второй show с тем же селектором перекрывает первый, поэтому сброс
  // и оформление делаем одним правилом — иначе счётчики не сбрасываются.
  show heading.where(level: 1): it => {
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: "listing")).update(0)
    counter(math.equation).update(0)
    pagebreak(weak: true)
    set align(if it.supplement == appendix-supplement { right } else { center })
    set text(size: 14pt, weight: "regular")
    v(line-gap)
    // Методичка ИВТ п. 2.1.11: 12-15 пт между заголовком и текстом (в эталоне 15 пт
    // «после» поверх межстрочного интервала; в Typst block(below) его заменяет).
    block(above: 0pt, below: 28.1pt)[
      #if it.numbering != none [#counter(heading).display() ]
      #upper(it.body)
    ]
  }

  show heading.where(level: 2): it => {
    set text(size: 14pt, weight: "regular")
    block(above: 29.1pt, below: 24.3pt, width: 100%)[
      #h(indent-length)#if it.numbering != none [#counter(heading).display()#h(14pt)]#it.body
    ]
  }

  show heading.where(level: 3): it => {
    set text(size: 14pt, weight: "regular")
    block(above: 22.3pt, below: 22.3pt, width: 100%)[
      #h(indent-length)#if it.numbering != none [#counter(heading).display()#h(14pt)]#it.body
    ]
  }

  // Подписи: таблица — сверху справа, рисунок/листинг — снизу по центру.
  show figure.where(kind: table): set figure.caption(position: top)
  show figure.where(kind: image): set figure.caption(position: bottom)
  show figure.where(kind: "listing"): set figure.caption(position: top)
  show figure.where(kind: "listing"): it => {
    set block(breakable: true)
    show raw.where(block: true): code-listing
    it
  }

  show figure.caption: it => {
    set par(justify: false, first-line-indent: 0pt)
    if it.kind == table or it.kind == "listing" {
      block(width: 100%, breakable: false)[
        #align(right)[#it.supplement~#it.counter.display(it.numbering)]
        #align(center)[#it.body]
      ]
    } else {
      align(center)[#it.supplement~#it.counter.display(it.numbering)#it.separator#it.body]
    }
  }

  set figure(numbering: gost-figure-numbering)
  set figure.caption(separator: [. ])

  set math.equation(numbering: gost-eq-numbering)

  // Методичка ИВТ п. 2.4.3: высота строки таблицы не менее 8 мм.
  set table(stroke: 0.5pt, inset: (x: 5pt, y: 6.5pt))

  // Методичка ИВТ п. 1.7.1: каждая запись списка литературы начинается с красной строки.
  // Записи строятся как block без абзаца, поэтому оборачиваем тело в par.
  show bibliography: it => {
    show block: b => if b.body.func() == par { b } else {
      block(width: 100%, par(first-line-indent: (amount: indent-length, all: true), hanging-indent: 0pt, b.body))
    }
    it
  }

  // Ссылки (@label) показываем только номером, как \ref{} в LaTeX,
  // без слова-подписи («Раздел», «Рис.» и т. п.).
  show ref: it => {
    let el = it.element
    if el != none and el.numbering != none {
      if el.func() == heading {
        context link(el.location(), (el.numbering)(..counter(heading).at(el.location())))
      } else {
        context link(el.location(), el.counter.display(el.numbering, at: el.location()))
      }
    } else {
      it
    }
  }

  body
}
