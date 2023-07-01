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
appJSDir := $(APP_DIR)/$(JS_DIR)
extEntryJS := $(EXT_ENTRY_JS)
extBundleJS := $(EXT_BUNDLE_JS)
extMinJS := $(EXT_MIN_JS)

entryJS := $(shell find $(srcDir)/$(appJSDir) -type f -name '*$(extEntryJS)' -print | grep -v '/_.*\$(extEntryJS)$$')
bundleJS := $(patsubst $(srcDir)/%, $(tmpDir)/%, $(entryJS:$(extEntryJS)=$(extBundleJS)))
minJS := $(patsubst $(tmpDir)/%, $(distDir)/%, $(bundleJS:$(extBundleJS)=$(extMinJS)))

# html
appHTMLDir := $(APP_DIR)
extTmplHTML := $(EXT_TMPL_HTML)
extBundleHTML := $(EXT_BUNDLE_HTML)
extMinHTML := $(EXT_MIN_HTML)

tmplHTML := $(shell find $(srcDir)/$(appHTMLDir) -type f -name '*$(extTmplHTML)' -printf '%P\n' | grep -v '$(l10nDir)')
bundleHTML := $(tmplHTML:$(extTmplHTML)=$(extBundleHTML))
minHTML := $(bundleHTML:$(extBundleHTML)=$(extMinHTML))

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

.PHONY: jsbuild ## Build js.
jsbuild: jsbundle jsminify

.PHONY: jsbundle ## Bundle js.
jsbundle: $(bundleJS)

$(tmpDir)/%$(extBundleJS): $(srcDir)/%$(extEntryJS)
	sh jsbundler.sh --src=$(srcDir)/$(appJSDir) --dest=$(tmpDir)/$(appJSDir) $<

.PHONY: jsminify ## Minify js.
jsminify: $(minJS)

$(distDir)/%$(extMinJS): $(tmpDir)/%$(extBundleJS)
	sh jsminifier.sh --src=$(tmpDir)/$(appJSDir) --dest=$(distDir)/$(appJSDir) $<

##
.PHONY: htmlbuild ## Build html.
htmlbuild: htmlbundle htmlminify

.PHONY: htmlbundle ## Bundle html.
htmlbundle: $(addprefix htmlbundle., $(locales))

htmlbundle.%: $(bundleDir)/$(appDir)/%/$(bundleHTML)
	

$(bundleDir)/$(appDir)/%/$(bundleHTML): $(tmpDir)/$(appDir)/%/$(tmplHTML)
	sh htmlbundler.sh --src=$(tmpDir)/$(appDir)/$* --dest=$(bundleDir)/$(appDir)/$* $<

.PRECIOUS: $(bundleDir)/$(appDir)/%/$(bundleHTML)

.PHONY: htmlminify ## Minify html.
htmlminify: $(addprefix htmlminify., $(locales))

htmlminify.%: $(distDir)/$(appDir)/%/$(minHTML)
	

$(distDir)/$(appDir)/%/$(minHTML): $(bundleDir)/$(appDir)/%/$(bundleHTML)
	sh htmlminifier.sh --src=$(bundleDir)/$(appDir)/$* --dest=$(distDir)/$(appDir)/$* $<

.PRECIOUS: $(distDir)/$(appDir)/%/$(minHTML)

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
.PHONY: clean.live ## Clean live.
clean.live:
	rm -rfv $(liveDir)

.PHONY: clean.tmp ## Clean tmp.
clean.tmp:
	rm -rfv $(tmpDir)

.PHONY: clean.bundle ## Clean bundle.
clean.bundle:
	rm -rfv $(bundleDir)

.PHONY: clean.dist ## Clean dist.
clean.dist:
	rm -rfv $(distDir)

.PHONY: clean.log ## Clean log.
clean.log:
	rm -rfv $(logDir)

.PHONY: clean.all ## Clean all.
clean.all: clean.live clean.tmp clean.bundle clean.dist clean.log
