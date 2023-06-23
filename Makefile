MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

include .build/env

appDir := $(APP_DIR)
srcDir := $(SRC_DIR)
liveDir := $(LIVE_DIR)
tmpDir := $(TMP_DIR)
distDir := $(DIST_DIR)
logDir := $(LOG_DIR)
l10nDir := $(L10N_DIR)

# js
appJSDir := $(APP_DIR)/$(JS_DIR)
extBundleJS := $(EXT_BUNDLE_JS)
extMinJS := $(EXT_MIN_JS)

entryJS := $(shell find $(srcDir)/$(appJSDir) -type f -name '*.js' -print | grep -v '/_.*\.js$$')
bundleJS := $(patsubst $(srcDir)/%, $(distDir)/%, $(entryJS:.js=$(extBundleJS)))
minJS := $(bundleJS:$(extBundleJS)=$(extMinJS))

# html
extHtmlTmpl := $(EXT_HTML_TMPL)

htmlTmpl := $(shell find $(srcDir)/$(appDir) -type f -name '*$(extHtmlTmpl)' -print | grep -v '.*/$(l10nDir)/.*')
html := $(patsubst $(srcDir)/%, $(distDir)/%, $(htmlTmpl:$(extHtmlTmpl)=.html))

now = $(shell date '+%Y%m%d-%H%M%S')

.PHONY: help ## Show help.
help:
	@cat $(MAKEFILE_LIST) | grep '##' | grep -v 'MAKEFILE_LIST' | sed s/^.PHONY:// | awk -F \#\# '{ printf "%-20s%s\n", $$1, $$2 }'

##
.PHONY: imgbuild ## Build img.
imgbuild:

.PHONY: cssbuild ## Build css.
cssbuild:

.PHONY: jsbuild ## Build js.
jsbuild: jsbundle jsminify

.PHONY: jsbundle ## Bundle js.
jsbundle: $(bundleJS)

$(distDir)/%$(extBundleJS): $(srcDir)/%.js
	sh jsbundler.sh --src=$(srcDir) --dest=$(distDir) $<

.PHONY: jsminify ## Minify js.
jsminify: $(minJS)

$(distDir)/%$(extMinJS): $(distDir)/%$(extBundleJS)
	sh jsminifier.sh --src=$(distDir) --dest=$(distDir) $<

.PHONY: htmlbuild ## Build html.
htmlbuild: htmlbundle

.PHONY: htmlbundle ## Bundle html.
htmlbundle: $(html)

$(distDir)/%.html: $(srcDir)/%$(extHtmlTmpl)
	sh htmlbundler.sh --dest=$(distDir) $<

##
.PHONY: imgtest ## Build img test.
imgtest:

.PHONY: csstest ## Build css test.
csstest:

.PHONY: jstest ## Build js test.
jstest:

.PHONY: htmltest ## Build html test.
htmltest:

##
.PHONY: build ## Build all.
build: imgbuild cssbuild jsbuild htmlbuild

.PHONY: test ## Test all.
test: imgtest csstest jstest htmltest

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
