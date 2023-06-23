#!/bin/sh

. .build/env

app=$APP_DIR
extTmpl=$EXT_HTML_TMPL

src=$SRC_DIR
dest=$(echo $1 | cut -d '=' -f 2)
tmpl=$2

html=$(echo $tmpl | sed -e "s:^$src:$dest:" -e "s/\\$extTmpl$/\\.html/")

mkdir -p $(dirname $html)
gotmpl2html --basedir=$src/$app $tmpl > $html
