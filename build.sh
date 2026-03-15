#! /bin/bash

CFLAGS="-g -Wall -Wextra"
LDFLAGS="-framework Cocoa"

echo "building handmade hero"

mkdir build
pushd build
clang $CFLAGS $LDFLAGS ../code/main.m -o handmade
popd
