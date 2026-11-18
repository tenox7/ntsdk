# nt31sdk

The Win32 SDK for Windows NT 3.1 (July 1993) in a container. Build programs for Windows NT 3.1 with the original Microsoft tools. They run under Wine on 32-bit Debian.

## What's inside

- `cl386` 8.00.3190a: the C compiler. `cl` is the same compiler.
- `link32` 2.42: the linker. `link32 -dump` works like dumpbin.
- `nmake` 1.12, with the SDK's `ntwin32.mak`.
- `lib32`, `rc`, `cvtres`, `mc`, `masm386` 5.NT.02, `cvdump`, `cvpack`, `undname`, and the rest of the SDK's i386 tools.
- The SDK headers and libraries.
- No SDK samples or other source code.

The programs you build are i386 NT 3.10 console or GUI programs. They run on Windows NT 3.1 and every later 32-bit Windows. Many also run under Wine in this image.

## Quick start

Go to your project folder and run `nmake` there:

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt31sdk nmake
```

- `--platform linux/386` stops a warning about the platform.
- On arm64 hosts, such as Apple Silicon Macs, the image runs under emulation, so it is slower.

## A Makefile

```
!include <ntwin32.mak>

all: hello.exe

hello.obj: hello.c
    $(cc) $(cflags) $(cvars) hello.c

hello.exe: hello.obj
    $(link) $(conflags) -out:hello.exe hello.obj $(conlibs)
```

- **GUI program:** use `$(guiflags)` and `$(guilibs)`.
- **Multithreaded C runtime:** use `$(cvarsmt)` with `$(conlibsmt)` or `$(guilibsmt)`.
- **Resources:** run `$(rc) -r app.rc`, then `$(cvtres) -$(CPU) app.res -o app.rbj`, then link `app.rbj`.
- **Static library:** `$(implib) -out:my.lib a.obj b.obj` runs `lib32`.

## Run one tool

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt31sdk cl386 -c -W3 hello.c
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt31sdk link32 -dump -headers hello.exe
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt31sdk wine hello.exe
docker run --rm -it --platform linux/386 -v "$PWD":/src tenox7/nt31sdk bash
```

- These tools are commands: `cl386 cl link32 lib32 nmake rc cvtres mc masm386 cvdump cvpack undname`.
- Any other tool in the SDK: `wine-mstools TOOL ARGS`, for example `wine-mstools rebase`.
- With no command, the container prints this text.

## Paths and environment

- Your folder is `/src`, which is `Z:\src` for the tools. Relative paths work.
- An absolute Unix path on the command line becomes a `Z:` path. This works alone, or after an option such as `-Fo/src/out/x.obj` or `-out:/src/x.exe`.
- The SDK is in `/opt/mstools`, with `bin`, `h` and `lib`.
- The image sets what `SETENV` sets on NT:
  - `CPU=i386`
  - `INCLUDE=Z:\opt\mstools\h`
  - `LIB=Z:\opt\mstools\lib`
  - the tools in the Wine path
- To change one, use `-e`, for example `-e 'INCLUDE=Z:\src\inc;Z:\opt\mstools\h'`.

## Good to know

- **Exit codes come through.** A failed compile makes `nmake` fail, and `docker run` fails too.
- **`masm386` is MASM 5.** It has no `.model flat`. End its command line with `;` and put quotes around it, so the shell does not take the `;`: `masm386 -Mx "file.asm;"`.
- **No input, no waiting.** A tool that asks a question fails at once, unless you run with `-it`.
- **Files belong to root.** The container runs as root, so on Linux the files it writes are owned by root.
- **i386 only.** The SDK's MIPS tools are not included. They only run on MIPS NT.

## Build the image

```
docker build --platform linux/386 -t nt31sdk .
```

`mstools/` must hold the SDK's `bin`, `h` and `lib` folders. On the NT 3.1 SDK CD they are `MSTOOLS\BIN\I386`, `MSTOOLS\H` and `MSTOOLS\LIB\I386`.
