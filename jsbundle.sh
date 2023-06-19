#!/bin/sh

. .build/env

app=$APP_NAME
srcDir=$SRC_DIR

dest=$(echo $1 | cut -d '=' -f 2)
entryJS=$2
bundleJS=$(echo $entryJS | sed -e "s/^$srcDir/$dest/" -e "s/\\.js$/\\.bundle.js/")

mkdir -p $(dirname $bundleJS)
esbuild $entryJS --bundle --sourcemap --outfile=$bundleJS
