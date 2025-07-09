DATA := $(shell find data -type f)
DB := bodysafe.db

.DEFAULT_GOAL := dist

$(DB): data.db sql/bodysafe.sql
	sqlite3 -cmd "ATTACH '$<' AS data" $@ <sql/bodysafe.sql

data.db: $(DATA)
	./bin/load $@ data/bodysafe.geojsonl

%.gz: $(DB)
	gzip --force --keep --stdout $< >$@

requirements.txt:
	uv pip compile pyproject.toml >requirements.txt

.PHONY: clean
clean:
	$(RM) -r $(DB) dist/

.PHONY: dist
dist:
	mkdir -p dist
	make dist/$(DB).gz
	cd dist && sha256sum *.gz >SHA256SUMS

.PHONY: fetch
fetch:
	./bin/fetch
