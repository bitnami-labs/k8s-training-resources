all: build

build: req-ytt
	ytt -f .

req-%:
	@which $(*) >/dev/null || $(call missing,$(*))

HELP_ytt := -- install from https://github.com/k14s/ytt
missing = { $(eval HELP=$(HELP_$(1))) echo "ERROR: missing '$(1)' tool $(HELP)"; exit 1; }
