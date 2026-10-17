# Makefile для сборки отчёта.
# Аналог csae-report/Makefile, но для Typst.

default: help
.PHONY: default

TARGET := main
OUTPUT := $(TARGET).pdf

report:
	typst compile $(TARGET).typ $(OUTPUT)
.PHONY: report

watch:
	typst watch $(TARGET).typ $(OUTPUT)
.PHONY: watch

clean:
	rm -f $(OUTPUT)
.PHONY: clean

help:
	@echo "Цели этого Makefile:"
	@echo "... help (по умолчанию)"
	@echo "... report сборка отчёта"
	@echo "... watch пересборка при изменении"
	@echo "... clean удаление собранного PDF"
.PHONY: help
