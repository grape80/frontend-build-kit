#!/bin/sh

. .build/env

extBundle=$EXT_BUNDLE_JS
extMin=$EXT_MIN_JS

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
bundleJS=$3

minJS=$(echo $bundleJS | sed -e "s:^$src:$dest:" -e "s/\\$extBundle$/\\$extMin/")

mkdir -p $(dirname $minJS)
esbuild $bundleJS --minify --sourcemap --outfile=$minJS
