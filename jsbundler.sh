#!/bin/sh

. .build/env

extBundle=$EXT_BUNDLE_JS

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
entryJS=$3

bundleJS=$(echo $entryJS | sed -e "s:^$src:$dest:" -e "s/\\.js$/\\$extBundle/")

mkdir -p $(dirname $bundleJS)
esbuild $entryJS --bundle --sourcemap --outfile=$bundleJS
