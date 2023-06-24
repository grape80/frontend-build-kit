#!/bin/sh

. .build/env

extEntry=$EXT_ENTRY_CSS
extBundle=$EXT_BUNDLE_CSS

src=$(echo $1 | cut -d '=' -f 2)
dest=$(echo $2 | cut -d '=' -f 2)
entry=$3

bundle=$(echo $entry | sed -e "s:^$src:$dest:" -e "s/\\$extEntry$/\\$extBundle/")

mkdir -p $(dirname $bundle)
sass $entry $bundle
