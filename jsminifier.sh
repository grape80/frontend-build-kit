#!/bin/sh

. .build/env

extBundle=$EXT_BUNDLE_JS
extMin=$EXT_MIN_JS

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
bundle=$3

min=$(echo $bundle | sed -e "s:^$src:$dest:" -e "s/\\$extBundle$/\\$extMin/")

mkdir -p $(dirname $min)
esbuild \
    --minify \
    --sourcemap \
    --outfile=$min \
    $bundle
