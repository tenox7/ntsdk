#!/bin/sh
# run.sh [IMAGE]: test the ntsdk image (default: ntsdk).
#
# 1. For each SDK and CPU: build the test program (hello.c, hello.rc, makefile) with nmake
#    and run it with ntrun, in the image. The program prints the CPU type of its own file
#    and the version of its compiler.
# 2. x86: build the same program with the Wine image of that SDK and compare the files
#    (pecmp.pl, which does not look at the time stamps). The object and resource files
#    must be the same. A Wine image that is not on this machine is left out.
#    WINE31, WINE35 and WINE40 name the Wine images (default: tenox7/nt31sdk and so on).
#
# KEEP=1 keeps the work folder. The work folder is $WORK (default: /tmp/ntsdk-tests).

here=$(cd "$(dirname "$0")" && pwd)
image=${1:-ntsdk}
work=${WORK:-/tmp/ntsdk-tests}
fail=0
total=0

ok() { total=$((total + 1)); echo "  ok    $1"; }
bad() { total=$((total + 1)); fail=$((fail + 1)); echo "  FAIL  $1"; }

file() { # file FOLDER NAME: the file with that name in any case
    f=$(ls "$1" | grep -i -x -m1 "$2")
    echo "$1/$f"
}

build() { # build FOLDER docker-run-arguments...: copy the test program there and run nmake
    b=$1
    shift
    rm -rf "$b"
    mkdir -p "$b"
    cp "$here"/hello.c "$here"/hello.rc "$here"/makefile "$b"/
    docker run --rm -v "$b":/src "$@" nmake -nologo > "$b/nmake.txt" 2>&1
}

echo "== $image"
while read -r sdk cpu machine compiler; do
    d=$work/$sdk-$cpu
    build "$d" "$image" $sdk $cpu
    docker run --rm -v "$d":/src "$image" $sdk $cpu ntrun hello.exe > "$d/hello.txt" 2> "$d/hello.err"
    printf 'hello: machine %s, compiler %s\n42 7.485471 text from the resources\n' $machine $compiler > "$d/expected.txt"
    if tr -d '\r' < "$d/hello.txt" | cmp -s - "$d/expected.txt"; then
        ok "$sdk $cpu"
    else
        bad "$sdk $cpu (see nmake.txt, hello.txt and hello.err in $d)"
    fi
done << EOF
nt31 x86 014c 800
nt31 mips 0166 800
nt31 alpha 0184 800
nt35 x86 014c 900
nt35 mips 0166 900
nt35 alpha 0184 900
nt40 x86 014c 1020
nt40 mips 0166 1010
nt40 alpha 0184 1010
nt40 ppc 01f0 1010
EOF

echo "== the Wine images"
while read -r sdk wine; do
    if ! docker image inspect "$wine" > /dev/null 2>&1; then
        echo "  left out: $wine is not on this machine"
        continue
    fi
    d=$work/$sdk-x86
    w=$work/$sdk-wine
    build "$w" --platform linux/386 -e NTSDK=$sdk "$wine"
    for f in hello.obj hello.res; do
        r=$(perl "$here/pecmp.pl" "$(file "$d" $f)" "$(file "$w" $f)" 2>&1)
        if [ $? -eq 0 ]; then ok "$sdk $f: $r"; else bad "$sdk $f: $r"; fi
    done
    # Not a test: the linker under Wine puts the imports of some programs in another order.
    echo "        $sdk hello.exe: $(perl "$here/pecmp.pl" "$d/hello.exe" "$w/hello.exe" 2>&1)"
done << EOF
nt31 ${WINE31:-tenox7/nt31sdk}
nt35 ${WINE35:-tenox7/nt35sdk}
nt40 ${WINE40:-tenox7/nt40sdk}
EOF

echo "$((total - fail)) of $total tests passed"
[ -n "$KEEP" ] || [ $fail -ne 0 ] || rm -rf "$work"
[ $fail -eq 0 ]
