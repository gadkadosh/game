#! /bin/bash
set -e

CFLAGS="-g -Wall -Wextra"
LDFLAGS="-framework Cocoa"

mkdir -p build
cd build
clang $CFLAGS $LDFLAGS ../code/main.m -o handmade
