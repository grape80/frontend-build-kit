MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

include .build/env

appDir := $(APP_DIR)
srcDir := $(SRC_DIR)
liveDir := $(LIVE_DIR)
tmpDir := $(TMP_DIR)
bundleDir := $(BUNDLE_DIR)
distDir := $(DIST_DIR)
logDir := $(LOG_DIR)
l10nDir := $(L10N_DIR)

# css
appCSSDir := $(APP_DIR)/$(CSS_DIR)
extEntryCSS := $(EXT_ENTRY_CSS)
extBundleCSS := $(EXT_BUNDLE_CSS)
extMinCSS := $(EXT_MIN_CSS)

entryCSS := $(shell find $(srcDir)/$(appCSSDir) -type f -name '*$(extEntryCSS)' -print | grep -v '/_.*\$(extEntryCSS)$$')
bundleCSS := $(patsubst $(srcDir)/%, $(tmpDir)/%, $(entryCSS:$(extEntryCSS)=$(extBundleCSS)))
minCSS := $(patsubst $(tmpDir)/%, $(distDir)/%, $(bundleCSS:$(extBundleCSS)=$(extMinCSS)))

# js
extEntryJS := $(EXT_ENTRY_JS)
extBundleJS := $(EXT_BUNDLE_JS)
extMinJS := $(EXT_MIN_JS)

entryJSs := $(shell find $(srcDir)/$(appDir) -type f -name '*$(extEntryJS)' -printf '%P\n' | grep -v '/_.*\$(extEntryJS)$$')
bundleJSs := $(entryJSs:$(extEntryJS)=$(extBundleJS))
minJSs := $(bundleJSs:$(extBundleJS)=$(extMinJS))

# html
extTmplHTML := $(EXT_TMPL_HTML)
extBundleHTML := $(EXT_BUNDLE_HTML)
extMinHTML := $(EXT_MIN_HTML)

tmplHTMLs := $(shell find $(srcDir)/$(appDir) -type f -name '*$(extTmplHTML)' -printf '%P\n' | grep -v '$(l10nDir)')
bundleHTMLs := $(tmplHTMLs:$(extTmplHTML)=$(extBundleHTML))
minHTMLs := $(bundleHTMLs:$(extBundleHTML)=$(extMinHTML))

# l10n
locales := $(shell cat .build/locales | tr '\n' ' ')

now = $(shell date '+%Y%m%d-%H%M%S')

.PHONY: help ## Show help.
help:
	@cat $(MAKEFILE_LIST) | grep '##' | grep -v 'MAKEFILE_LIST' | sed s/^.PHONY:// | awk -F \#\# '{ printf "%-20s%s\n", $$1, $$2 }'

##
.PHONY: l10n ## Build l10n.
l10n: $(addprefix l10n., $(locales))

l10n.%:
	mkdir -p $(tmpDir)/$(appDir)/$*
	cp -pr $(srcDir)/$(appDir)/* $(tmpDir)/$(appDir)/$*
	mv -f $(tmpDir)/$(appDir)/$*/$(l10nDir)/$*/* $(tmpDir)/$(appDir)/$*
	rm -rfv $(tmpDir)/$(appDir)/$*/$(l10nDir)

##
.PHONY: imgbuild ## Build img.
imgbuild:

.PHONY: cssbuild ## Build css.
cssbuild: cssbundle cssminify

.PHONY: cssbundle ## Bundle css.
cssbundle: $(bundleCSS)

$(tmpDir)/%$(extBundleCSS): $(srcDir)/%$(extEntryCSS)
	sh cssbundler.sh --src=$(srcDir)/$(appCSSDir) --dest=$(tmpDir)/$(appCSSDir) $<

.PHONY: cssminify ## Minify css.
cssminify: $(minCSS)

$(distDir)/%$(extMinCSS): $(tmpDir)/%$(extBundleCSS)
	sh cssminifier.sh --src=$(tmpDir)/$(appCSSDir) --dest=$(distDir)/$(appCSSDir) $<

##
.PHONY: js.build ## Build js.
js.build: js.bundle js.minify

.PHONY: js.bundle ## Bundle js for all locales.
js.bundle: $(addprefix js.bundle., $(locales))

.PHONY: js.bundle.%  ## Bundle the specified locale js.
js.bundle.%: $(foreach bundleJS, $(bundleJSs), $(bundleDir)/$(appDir)/%/$(bundleJS))
	

$(bundleDir)/$(appDir)/%$(extBundleJS): $(tmpDir)/$(appDir)/%$(extEntryJS)
	sh jsbundler.sh --src=$(shell echo $< | cut -d '/' -f 1-3) --dest=$(shell echo $@ | cut -d '/' -f 1-3) $<

.PRECIOUS: $(bundleDir)/$(appDir)/%$(extBundleJS)

.PHONY: js.minify ## Minify js for all locales.
js.minify: $(addprefix js.minify., $(locales))

.PHONY: js.minify.% ## Minify the specified locale js.
js.minify.%: $(foreach minJS, $(minJSs), $(distDir)/$(appDir)/%/$(minJS))
	

$(distDir)/$(appDir)/%$(extMinJS): $(bundleDir)/$(appDir)/%$(extBundleJS)
	sh jsminifier.sh --src=$(shell echo $< | cut -d '/' -f 1-3) --dest=$(shell echo $@ | cut -d '/' -f 1-3) $<

.PRECIOUS: $(distDir)/$(appDir)/%$(extMinJS)

##
.PHONY: html.build ## Build html.
html.build: html.bundle html.minify

.PHONY: html.bundle ## Bundle html for all locales.
html.bundle: $(addprefix html.bundle., $(locales))

.PHONY: html.bundle.%  ## Bundle the specified locale html.
html.bundle.%: $(foreach bundleHTML, $(bundleHTMLs), $(bundleDir)/$(appDir)/%/$(bundleHTML))
	

$(bundleDir)/$(appDir)/%$(extBundleHTML): $(tmpDir)/$(appDir)/%$(extTmplHTML)
	sh htmlbundler.sh --src=$(shell echo $< | cut -d '/' -f 1-3) --dest=$(shell echo $@ | cut -d '/' -f 1-3) $<

.PRECIOUS: $(bundleDir)/$(appDir)/%$(extBundleHTML)

.PHONY: html.minify ## Minify html for all locales.
html.minify: $(addprefix html.minify., $(locales))

.PHONY: html.minify.% ## Minify the specified locale html.
html.minify.%: $(foreach minHTML, $(minHTMLs), $(distDir)/$(appDir)/%/$(minHTML))
	

$(distDir)/$(appDir)/%$(extMinHTML): $(bundleDir)/$(appDir)/%$(extBundleHTML)
	sh htmlminifier.sh --src=$(shell echo $< | cut -d '/' -f 1-3) --dest=$(shell echo $@ | cut -d '/' -f 1-3) $<

.PRECIOUS: $(distDir)/$(appDir)/%$(extMinHTML)

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
cicd: clean.all build test release

##
cleanDirs := $(liveDir) $(tmpDir) $(bundleDir) $(distDir) $(logDir)

.PHONY: clean ## Clean all.
clean: $(addprefix clean., $(cleanDirs))

.PHONY: clean.% ## Clean the specified directory.
clean.%:
	test $(findstring $*, $(cleanDirs)) != ''
	rm -rfv $*
