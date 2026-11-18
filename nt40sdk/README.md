# nt40sdk

Visual C++ 4.2 (July 1996) and the Win32 SDK for Windows NT 4.0 (1996) in a container. Build programs for Windows NT 4.0 with the original Microsoft tools. They run under Wine on 32-bit Debian.

## What's inside

- `cl` 10.20: the C and C++ compiler. C++ has templates, namespaces, exceptions with `-GX` and RTTI with `-GR`.
- `link` 4.20: the linker.
- `nmake` 1.61, with the SDK's `win32.mak`.
- `lib` 4.20, `rc` 4.00, `cvtres` 4.00, `dumpbin` 4.20, `editbin` 4.20, `bscmake` 4.10, `mc` 1.00, `mktyplib` 2.20, `midl` 3.00, `cvpack`, `makehm`, `uuidgen`.
- The SDK's Win32 headers and libraries for Windows NT 4.0, including DirectX 3 (DirectDraw, Direct3D, DirectSound, DirectPlay), Winsock 2, SetupAPI and OpenGL.
- The headers and libraries of Visual C++ 4.2, after the SDK's.
- MFC 4.2 headers and libraries.
- The redistributable DLLs, such as `MSVCRT.DLL` and `MFC42.DLL`, in `/opt/msdev/redist`.
- No samples, CRT or MFC source, or help files.

The programs you build are i386 programs marked for Windows NT 4.0. They run on Windows NT 4.0 and every later 32-bit Windows. Many also run under Wine in this image.

- **NT 3.51:** build with `nmake APPVER=3.51`, and avoid functions that NT 4.0 added.
- **NT 3.5:** use `tenox7/nt35sdk`.
- **NT 3.1:** use `tenox7/nt31sdk`.

## Quick start

Go to your project folder and run `nmake` there:

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk nmake
```

- `--platform linux/386` stops a warning about the platform.
- On arm64 hosts, such as Apple Silicon Macs, the image runs under emulation, so it is slower.

## A Makefile

```
!include <win32.mak>

all: hello.exe

hello.obj: hello.c
    $(cc) $(cflags) $(cvars) hello.c

hello.exe: hello.obj
    $(link) $(conflags) -out:hello.exe hello.obj $(conlibs)
```

- **GUI program:** use `$(guiflags)` and `$(guilibs)`.
- **Multithreaded C runtime:** use `$(cvarsmt)` with `$(conlibsmt)` or `$(guilibsmt)`.
- **C runtime DLL:** use `$(cvarsdll)` with `$(conlibsdll)` or `$(guilibsdll)`. The program then needs `MSVCRT.DLL`. NT 4.0 has it.
- **OLE:** link `$(olelibs)`.
- **Resources:** run `$(rc) -r app.rc`, then link `app.res` with the objects.
- **Static library:** `$(implib) -out:my.lib a.obj b.obj` runs `lib`.
- **C++:** `$(cflags)` works for C++ too. Add `-GX` for exceptions.
- **C++ library:** `win32.mak` links with `-nodefaultlib`, so name the C++ library yourself, before `$(conlibs)`:
  - `<iostream>`, `<string>`, `<vector>` and the rest: `libcp.lib`, or `libcpmt.lib` with `$(conlibsmt)`, or `msvcprt.lib` with `$(conlibsdll)`.
  - The old `<iostream.h>`: `libci.lib`, or `libcimt.lib` with `$(conlibsmt)`, or `msvcirt.lib` with `$(conlibsdll)`.
  - Without nmake, `cl` finds these by itself.
- **NT 3.51:** `nmake APPVER=3.51` marks the program for NT 3.51.

## Without nmake

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk cl hello.c
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk cl app.c user32.lib -link -subsystem:windows
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk cl -GX -GR app.cpp
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk cl -LD my.c -link -base:0x10000000
```

- **MFC, static:** `cl -MT -GX app.cpp -link -subsystem:windows`
- **MFC, DLL:** `cl -MD -GX -D_AFXDLL app.cpp -link -subsystem:windows`. The program then needs `MFC42.DLL` and `MSVCRT.DLL`. Copies are in `/opt/msdev/redist`.
- **DLL:** `-LD` builds `my.dll` with its import library `my.lib`.
- **NT 3.51:** add `-link -subsystem:console,3.51`, or `windows,3.51` for a GUI program.

## Run one tool

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk dumpbin -headers hello.exe
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk dumpbin -imports hello.exe
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk midl app.idl
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk wine hello.exe
docker run --rm -it --platform linux/386 -v "$PWD":/src tenox7/nt40sdk bash
```

- These tools are commands: `cl link lib nmake rc cvtres dumpbin editbin bscmake mc mktyplib midl cvpack makehm uuidgen`.
- Any other tool: `wine-tool TOOL ARGS`, for example `wine-tool undname`. It looks in the SDK first, then in Visual C++ 4.2.
- With no command, the container prints this text.

## Paths and environment

- Your folder is `/src`, which is `Z:\src` for the tools. Relative paths work.
- An absolute Unix path on the command line becomes a `Z:` path. This works alone, or after an option such as `-Fo/src/out/x.obj` or `-out:/src/x.exe`.
- The SDK is in `/opt/mstools`, with `bin`, `include` and `lib`.
- Visual C++ 4.2 is in `/opt/msdev`, with `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist`.
- The image sets these the way the SDK's `SETENV` does, with the SDK first:
  - `CPU=i386`, for `win32.mak`
  - `INCLUDE=Z:\opt\mstools\include;Z:\opt\msdev\include;Z:\opt\msdev\mfc\include`
  - `LIB=Z:\opt\mstools\lib;Z:\opt\msdev\lib;Z:\opt\msdev\mfc\lib`
  - the tools of both in the Wine path
- To change one, use `-e`, for example `-e 'INCLUDE=Z:\src\inc;Z:\opt\mstools\include;Z:\opt\msdev\include'`.

## Good to know

- **GUI programs need `-link -subsystem:windows`.** Without it, `cl` links a console program and looks for `main`. `$(guiflags)` in `win32.mak` does it.
- **The C++ library is the 1996 draft.** It has no `std::`, and containers need their allocator written out: `vector<int, allocator<int> > v;`. `string`, `vector`, `list`, `map` and `<iostream>` work this way.
- **No rebasing after linking.** `rebase` and `editbin -rebase` fail under Wine. Give a DLL its base address when you link it, with `-base:`.
- **Exit codes come through.** A failed compile makes `nmake` fail, and `docker run` fails too.
- **No input, no waiting.** A tool that asks a question fails at once, unless you run with `-it`.
- **Files belong to root.** The container runs as root, so on Linux the files it writes are owned by root.
- **i386 only.** This is the x86 edition of Visual C++ 4.2. The SDK's MIPS, Alpha and PowerPC tools are not included.

## Build the image

```
docker build --platform linux/386 -t nt40sdk .
```

- `msdev/` must hold the `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` folders. On the Visual C++ 4.2 CD they are in `MSDEV`.
- `mstools/` must hold the SDK's `bin`, `include` and `lib` folders, as its setup lays them out for i386: `MSTOOLS\BIN\I386` with `MSTOOLS\BIN\WINNT\I386`, `MSTOOLS\INCLUDE`, and `MSTOOLS\LIB\I386` with `MSTOOLS\LIB\WINNT\I386`. The SDK CD stores the libraries compressed (`*.LI_`), so expand them first.
