# Run `ytt` to build manifested output as file.yml -> generated/file.yaml,
# doesn't interact with kube api at all.

# All *.yml files except *.lib.yml
SRCFILES=$(filter-out %.lib.yml,$(wildcard *.yml))
# Map file.yml -> generated/file.yaml
OUTFILES=$(patsubst %.yml,generated/%.yaml,$(SRCFILES))

all: build
build: req-ytt $(OUTFILES)

# Running `ytt -f .` would suffice, tho running it per-file
# to map each file.yml to generated/file.yaml
generated/%.yaml: %.yml Makefile
	ytt -f . -f $(<) > $(@)

req-%:
	@which $(*) >/dev/null || $(call missing,$(*))

HELP_ytt := -- install from https://github.com/k14s/ytt
missing = { $(eval HELP=$(HELP_$(1))) echo "ERROR: missing '$(1)' tool $(HELP)"; exit 1; }
