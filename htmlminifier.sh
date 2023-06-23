#!/bin/sh

. .build/env

extBundle=$EXT_BUNDLE_HTML
extMin=$EXT_MIN_HTML

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
bundle=$3

min=$(echo $bundle | sed -e "s:^$src:$dest:" -e "s/\\$extBundle$/\\$extMin/")

mkdir -p $(dirname $min)
minify \
    --html-keep-document-tags \
    --html-keep-end-tags \
    --html-keep-quotes \
    -o $min \
    $bundle
