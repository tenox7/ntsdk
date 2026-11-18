# nt35sdk

Visual C++ 2.0 and the Win32 SDK for Windows NT 3.5 (September 1994) in a container. Build programs for Windows NT 3.5 with the original Microsoft tools. They run under Wine on 32-bit Debian.

## What's inside

- `cl` 9.00: the C and C++ compiler. C++ has templates, and exceptions with `-GX`.
- `link` 2.50: the linker.
- `nmake` 1.50, with `ntwin32.mak`.
- `lib` 2.50, `rc` 3.50, `cvtres` 3.20, `dumpbin` 2.50, `editbin` 2.50, `bscmake` 2.60, `mc`, `mktyplib` 2.02, `cvpack`, `makehm`, `uuidgen`.
- From the SDK: `masm386` 5.NT.02, `midl` 2.00, and the rest of its i386 tools.
- The Win32 headers and libraries for Windows NT 3.5, with the SDK's extras such as the POSIX libraries.
- MFC 3.0 headers and libraries.
- The redistributable DLLs, such as `MSVCRT20.DLL` and `MFC30.DLL`, in `/opt/msvc20/redist`.
- No samples, MFC source or help files.

The programs you build are i386 programs marked for Windows NT 3.10. They run on Windows NT 3.5, 3.51, 4.0 and every later 32-bit Windows. Many also run under Wine in this image.

NT 3.1 loads them too, but it lacks some NT 3.5 functions. For NT 3.1, use `tenox7/nt31sdk`.

## Quick start

Go to your project folder and run `nmake` there:

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk nmake
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
- **C runtime DLL:** use `$(cvarsdll)` with `$(conlibsdll)` or `$(guilibsdll)`. The program then needs `MSVCRT20.DLL`. NT 4.0 has it. For NT 3.5 and 3.51, copy it from `/opt/msvc20/redist`.
- **Resources:** run `$(rc) -r app.rc`, then link `app.res` with the objects.
- **Static library:** `$(implib) -out:my.lib a.obj b.obj` runs `lib`.
- **C++ with exceptions:** `$(cflags)` turns `try` into the C keyword `__try`. Compile C++ with `$(cc) -c -W3 -GX -D_X86_=1 $(cvars) app.cpp` instead.

## Without nmake

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk cl -DWIN32 hello.c
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk cl -DWIN32 app.c user32.lib -link -subsystem:windows
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk cl -DWIN32 -GX app.cpp
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk cl -DWIN32 -LD my.c -link -base:0x10000000
```

- **MFC, static:** `cl -DWIN32 -MT -GX app.cpp -link -subsystem:windows`
- **MFC, DLL:** `cl -DWIN32 -MD -GX -D_AFXDLL app.cpp -link -subsystem:windows`. The program then needs `MFC30.DLL` and `MSVCRT20.DLL` from `/opt/msvc20/redist`.
- **DLL:** `-LD` builds `my.dll` with its import library `my.lib`.

## Run one tool

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk dumpbin -headers hello.exe
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk dumpbin -imports hello.exe
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk midl app.idl
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk wine hello.exe
docker run --rm -it --platform linux/386 -v "$PWD":/src tenox7/nt35sdk bash
```

- These tools are commands: `cl link lib nmake rc cvtres dumpbin editbin bscmake mc mktyplib cvpack makehm uuidgen masm386 midl`.
- Any other tool: `wine-tool TOOL ARGS`, for example `wine-tool pstat`. It looks in Visual C++ 2.0 first, then in the SDK.
- With no command, the container prints this text.

## Paths and environment

- Your folder is `/src`, which is `Z:\src` for the tools. Relative paths work.
- An absolute Unix path on the command line becomes a `Z:` path. This works alone, or after an option such as `-Fo/src/out/x.obj` or `-out:/src/x.exe`.
- Visual C++ 2.0 is in `/opt/msvc20`, with `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist`.
- The SDK is in `/opt/mstools`, with `bin`, `h` and `lib`.
- The image sets:
  - `CPU=i386`, for `ntwin32.mak`
  - `INCLUDE=Z:\opt\msvc20\include;Z:\opt\msvc20\mfc\include;Z:\opt\mstools\h`
  - `LIB=Z:\opt\msvc20\lib;Z:\opt\msvc20\mfc\lib;Z:\opt\mstools\lib`
  - the tools of both in the Wine path, Visual C++ 2.0 first
- To change one, use `-e`, for example `-e 'INCLUDE=Z:\src\inc;Z:\opt\msvc20\include'`.

## Good to know

- **Always define `WIN32`.** The 1994 headers need it. Without it, a file that includes `windows.h` fails with hundreds of `__export` errors from `OBJBASE.H`. `$(cvars)` defines it. Without nmake, add `-DWIN32`.
- **GUI programs need `-link -subsystem:windows`.** Without it, `cl` links a console program and looks for `main`.
- **`masm386` is MASM 5.** It has no `.model flat`. End its command line with `;` and put quotes around it, so the shell does not take the `;`: `masm386 -Mx "file.asm;"`.
- **No rebasing after linking.** `rebase` and `editbin -rebase` fail under Wine. Give a DLL its base address when you link it, with `-base:`.
- **Exit codes come through.** A failed compile makes `nmake` fail, and `docker run` fails too.
- **No input, no waiting.** A tool that asks a question fails at once, unless you run with `-it`.
- **Files belong to root.** The container runs as root, so on Linux the files it writes are owned by root.
- **i386 only.** This is the x86 edition of Visual C++ 2.0. The SDK's MIPS and Alpha tools are not included. They only run on MIPS and Alpha NT.

## Build the image

```
docker build --platform linux/386 -t nt35sdk .
```

- `msvc20/` must hold the `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` folders. On the Visual C++ 2.0 CD they are in `MSVC20`.
- `mstools/` must hold the SDK's `bin`, `h` and `lib` folders. On the NT 3.5 SDK CD they are `MSTOOLS\BIN\I386`, `MSTOOLS\H` and `MSTOOLS\LIB\I386`.
