#!/bin/sh

. .build/env

extTmpl=$EXT_TMPL_HTML
extBundle=$EXT_BUNDLE_HTML

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
tmpl=$3

bundle=$(echo $tmpl | sed -e "s:^$src:$dest:" -e "s/\\$extTmpl$/\\$extBundle/")

mkdir -p $(dirname $bundle)
gotmpl2html \
    --basedir=$src \
    $tmpl > $bundle
