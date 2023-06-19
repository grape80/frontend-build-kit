#!/bin/sh

. .build/env

app=$APP_NAME
srcDir=$SRC_DIR

dest=$(echo $1 | cut -d '=' -f 2)
gotmpl=$2
html=$(echo $gotmpl | sed -e "s/^$srcDir/$dest/" -e "s/\\.gotmpl$/\\.html/")

mkdir -p `dirname $html`
gotmpl2html --basedir=$srcDir/$app $gotmpl > $html
