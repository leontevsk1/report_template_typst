// Вариант по умолчанию: practice (практика) или lab (лабораторная работа).
// Переопределение из командной строки: typst compile --input report=lab main.typ lab.pdf
#let report-kind = sys.inputs.at("report", default: "practice")

#if report-kind == "practice" {
  include "reports/practice/main.typ"
} else if report-kind == "lab" {
  include "reports/lab/main.typ"
} else {
  panic("Неизвестный вариант отчёта: " + report-kind + ". Допустимы practice и lab.")
}
