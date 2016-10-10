#!/bin/sh

set -e # exit on errors

srcdir=`dirname $0`
test -z "$srcdir" && srcdir=.

olddir=`pwd`

cd "$srcdir"
mkdir subprojects
cd subprojects
git submodule update --init --recursive

cd "$olddir"

if [ -z "$NOCONFIGURE" ]; then
    mkdir build
    cd build
    meson --enable-debug

    cd "$olddir"

    echo "Now run ninja (or ninja-build) in build director to build Boxes"
fi
