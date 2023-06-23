#!/bin/sh

. .build/env

extEntry=$EXT_ENTRY_JS
extBundle=$EXT_BUNDLE_JS

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
entry=$3

bundle=$(echo $entry | sed -e "s:^$src:$dest:" -e "s/\\$extEntry$/\\$extBundle/")

mkdir -p $(dirname $bundle)
esbuild \
    --bundle \
    --sourcemap \
    --outfile=$bundle \
    $entry
