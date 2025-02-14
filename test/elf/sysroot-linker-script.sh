#!/bin/bash
export LANG=
set -e
testname=$(basename -s .sh "$0")
echo -n "Testing $testname ... "
cd "$(dirname "$0")"/../..
mold="$(pwd)/mold"
t="$(pwd)/out/test/elf/$testname"
mkdir -p "$t"

cat <<EOF | cc -o "$t"/a.o -c -xc -
void foo() {}
EOF

mkdir -p "$t"/foo/bar
rm -f "$t"/foo/bar/libfoo.a
ar rcs "$t"/foo/bar/libfoo.a "$t"/a.o

cat <<EOF > "$t"/foo/bar/b.script
INPUT(/foo/bar/libfoo.a)
EOF

cat <<EOF | cc -o "$t"/c.o -c -xc -
void foo();
int main() { foo(); }
EOF

clang -fuse-ld="$mold" -o "$t"/exe "$t"/c.o -Wl,--sysroot="$t"/ "$t"/foo/bar/b.script

echo OK
