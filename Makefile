MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

include .build/env
app := $(APP_NAME)
logDir := $(LOG_DIR)
logTestDir := $(LOG_TEST_DIR)
distDir := $(DIST_DIR)
tmpDir := $(TMP_DIR)
liveDir := $(LIVE_DIR)

now = $(shell date '+%Y%m%d-%H%M%S')

.PHONY: help ## Show help.
help:
	@cat $(MAKEFILE_LIST) | grep '##' | grep -v 'MAKEFILE_LIST' | sed s/^.PHONY:// | awk -F \#\# '{ printf "%-20s%s\n", $$1, $$2 }'

##
.PHONY: cssbuild ## Build css.
cssbuild:

.PHONY: imgbuild ## Build img.
imgbuild:

.PHONY: jsbuild ## Build js.
jsbuild:

.PHONY: htmlbuild ## Build html.
htmlbuild:

##
.PHONY: csstest ## Build css test.
csstest:

.PHONY: imgtest ## Build img test.
imgtest:

.PHONY: jstest ## Build js test.
jstest:

.PHONY: htmltest ## Build html test.
htmltest:

##
.PHONY: build ## Build all.
build: cssbuild imgbuild jsbuild htmlbuild

.PHONY: test ## Test all.
test: csstest imgtest jstest htmltest

.PHONY: release ## Build release.
release:

.PHONY: cicd ## Run CI/CD.
cicd: cleanall build test release

##
.PHONY: cleanlive ## Clean live.
cleanlive:
	rm -rfv $(liveDir)

.PHONY: cleantmp ## Clean tmp.
cleantmp:
	rm -rfv $(tmpDir)

.PHONY: cleandist ## Clean dist.
cleandist:
	rm -rfv $(distDir)

.PHONY: cleanlog ## Clean log.
cleanlog:
	rm -rfv $(logDir)

.PHONY: cleanall ## Clean all.
cleanall: cleanlive cleantmp cleandist cleanlog
