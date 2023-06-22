#!/bin/sh

. .build/env

ext=$EXT_HTML
extTmpl=$EXT_HTML_TMPL

src=$SRC_DIR/$APP_DIR
dest=$(echo $1 | cut -d '=' -f 2)
tmpl=$2

html=$(echo $tmpl | sed -e "s:^$src:$dest:" -e "s/\\$extTmpl$/\\$ext/")

mkdir -p $(dirname $html)
gotmpl2html --basedir=$src $tmpl > $html
