#! /bin/bash
set -e

CFLAGS="-g -Wall -Wextra"
LDFLAGS="-framework AppKit"

mkdir -p build
clang $CFLAGS $LDFLAGS code/main.m -o build/handmade
