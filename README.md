# ntsdk

**Docker Hub:** [tenox7/ntsdk](https://hub.docker.com/r/tenox7/ntsdk)

The original Microsoft tools for Windows NT in one Docker image. Build programs for Windows NT 3.1, 3.5, 3.51 and 4.0, for x86, MIPS, Alpha and PowerPC, for 64-bit Alpha (AXP64) and for Itanium (IA-64), on Linux or macOS.

- The image has the Win32 SDKs for Windows NT 3.1, 3.5 and 4.0 and the Visual C++ of that time, for each CPU.
- It has the Platform SDK for Windows 2000 RC2 with the compiler for 64-bit Alpha too (see AXP64).
- It has the Platform SDK for Windows Server 2003 SP1 with the cross compiler for Itanium too (see Itanium).
- [ntrun](https://github.com/tenox7/ntrun) runs the tools. It is an emulator for 32-bit Windows NT console programs of these four CPUs.
- There is no Wine in the image. The image is a native `linux/amd64` and `linux/arm64` image.
- The programs are the same files as from a build on a real Windows NT machine, but for the time stamps (see Tests).

## Quick start

Go to your project folder and run `nmake` there:

```
docker run --rm -v "$PWD":/src tenox7/ntsdk nmake                 # Windows NT 4.0, x86
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 alpha nmake      # Windows NT 4.0, Alpha
docker run --rm -v "$PWD":/src tenox7/ntsdk nt35 mips nmake       # Windows NT 3.5, MIPS
docker run --rm -v "$PWD":/src tenox7/ntsdk nt31 x86 nmake        # Windows NT 3.1, x86
docker run --rm -v "$PWD":/src tenox7/ntsdk axp64 nmake           # 64-bit Alpha (AXP64)
docker run --rm -v "$PWD":/src tenox7/ntsdk ia64 nmake            # Itanium (IA-64)
```

- The first words are the SDK (`nt31`, `nt35`, `nt40`, `nt50` or `nt52`) and the CPU (`x86`, `mips`, `alpha`, `ppc`, `axp64` or `ia64`). Then comes the command.
- Without them you get `nt40` and `x86`.
- `axp64` is only in `nt50`, and `nt50` has only `axp64`: one of the two words is sufficient. The same for `ia64` and `nt52`.
- With no command, the container prints this text.

## SDKs and CPUs

| SDK | CPU | Tools |
|---|---|---|
| `nt31` | `x86` | Win32 SDK for Windows NT 3.1 (July 1993): `cl386` 8.00, `link32` 2.42, `nmake` 1.12, `rc` 3.10, `lib32`, `masm386`, `midl` 1.00 |
| `nt31` | `mips` | The same SDK: `cl` or `mcl` 8.00 for MIPS, `cc` with `mip2coff`, `link32` 2.42 |
| `nt31` | `alpha` | The SDK with the Alpha tools: `cl` or `claxp` 8.00, `acc` with `a2coff`, `asaxp`, `link32` 2.43 |
| `nt35` | `x86` | Visual C++ 2.0 (`cl` 9.00, `link` 2.50, `nmake` 1.50, MFC 3.0), then the Win32 SDK for Windows NT 3.5 (`masm386`, `midl` 2.00) |
| `nt35` | `mips` | Visual C++ 2.0 for MIPS: `cl` 9.00, `link` 2.50, `nmake` 1.50, MFC 3.0 |
| `nt35` | `alpha` | Win32 SDK for Windows NT 3.5 for Alpha, with its own compiler: `cl` or `claxp` 8.03, `link` 2.50, `nmake` 1.50, `asaxp`, `midl` 2.00 |
| `nt40` | `x86` | Win32 SDK for Windows NT 4.0 (`rc` 4.00, `midl` 3.00), then Visual C++ 4.2 (`cl` 10.20, `link` 4.20, `nmake` 1.61, MFC 4.2) |
| `nt40` | `mips` `alpha` `ppc` | Win32 SDK for Windows NT 4.0, then Visual C++ 4.1 for that CPU (`cl` 10.10, `link` 3.10, `nmake` 1.61, MFC 4.1, `asaxp` for Alpha, `pas` for PowerPC) |
| `nt50` | `axp64` | Platform SDK for Windows 2000 RC2 (September 1999) with its compiler for 64-bit Alpha: `cl` 13.00, `link` 6.20, `rc` 5.00, `mc` 1.11, `midl` 5.03, `asaxp`, MFC 4.2. `nmake` 6.00 is that of Visual C++ 6.0 for Alpha. |
| `nt52` | `ia64` | Platform SDK for Windows Server 2003 SP1 (April 2005) with its cross compiler for Itanium: `cl` 14.00, `link` 8.00, `nmake` 7.00, `rc` 5.2, `mc` 1.12, `midl` 6.00, `ias` 8.00, MFC 4.2 |

- **Windows NT 3.51:** use `nt35`. Its programs are marked for Windows NT 3.10, so they run on 3.5, 3.51 and 4.0.
- **PowerPC:** Windows NT 3.51 was the first Windows NT for PowerPC. Use `nt40 ppc` and link with `-subsystem:console,3.51`, or `windows,3.51` for a program with windows.
- The three folders [nt31sdk](nt31sdk), [nt35sdk](nt35sdk) and [nt40sdk](nt40sdk) tell you how to write a makefile for each SDK. That part is the same for each CPU.

## Use

```
docker run --rm -v "$PWD":/src tenox7/ntsdk cl hello.c                       # nt40, x86
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 ppc cl hello.c
docker run --rm -v "$PWD":/src tenox7/ntsdk nt35 mips cl -DWIN32 hello.c
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 alpha dumpbin -headers hello.exe
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 alpha ntrun hello.exe       # run the program
docker run --rm -v "$PWD":/src tenox7/ntsdk axp64 cl hello.c                 # 64-bit Alpha
docker run --rm -v "$PWD":/src tenox7/ntsdk ia64 cl hello.c bufferoverflowu.lib   # Itanium
docker run --rm -it -v "$PWD":/src tenox7/ntsdk nt31 mips                    # a shell
```

One container can build for each CPU. `ntsdk` is a command in the image too:

```
docker run --rm -v "$PWD":/src tenox7/ntsdk sh -c '
  for cpu in x86 mips alpha ppc; do
    ntsdk nt40 $cpu cl -Fehello-$cpu.exe hello.c || exit 1
  done'
```

- **These tools are commands:** `cl cl386 mcl claxp acc cc link link32 lib lib32 nmake rc cvtres mc midl masm386 asaxp pas ias mip2coff a2coff dumpbin editbin bscmake cvpack cvdump undname uuidgen rebase`. An SDK has only some of them.
- **Any other tool:** `ntrun TOOL ARGS`, for example `ntrun where cl.exe`.
- **Run a program:** `ntrun hello.exe` runs a console program for each of the four CPUs. Programs with windows and programs for AXP64 or Itanium do not run in the image.
- **GNU make** is in the image too.

## Paths and environment

- Your folder is `/src`, which is `Z:\src` for the tools. Relative paths work.
- An absolute Unix path on the command line becomes a `Z:` path. This works alone, or after an option such as `-Fo/src/out/x.obj` or `-out:/src/x.exe`.
- The SDK is drive `C:` for the tools. In the container it is the folder `/opt/SDK/CPU`, for example `/opt/nt40/alpha`.
- `ntsdk` sets these variables:

| Variable | Value |
|---|---|
| `CPU` | `i386`, `MIPS`, `ALPHA`, `PPC`, `ALPHA64` or `IA64`, for the makefiles of the SDKs (`ntwin32.mak`, `win32.mak`) |
| `INCLUDE`, `LIB` | The folders of the SDK and the compiler, see below |
| `NTRUN_PATH` | The `PATH` of the tools |
| `NTRUN_DLLPATH` | The folders with the DLLs of the tools: `redist` of Visual C++ and `/opt/sys/CPU` |
| `NTSDK`, `NTCPU` | The SDK and the CPU, for example `nt40` and `alpha` |
| `PROCESSOR_ARCHITECTURE`, `OS` | As on Windows NT: `x86`, `MIPS`, `ALPHA` or `PPC`, and `Windows_NT`. For `axp64` it is `ALPHA` and for `ia64` it is `x86`, the CPU of the tools. |
| `CL` | For `axp64` only: `-Ap64`, in front of your own `CL` |
| `APPVER`, `TARGETOS` | For `ia64` only: `5.02` and `WINNT`, for `win32.mak` |

| SDK | `INCLUDE` | `LIB` |
|---|---|---|
| `nt31` | `C:\mstools\h` | `C:\mstools\lib` |
| `nt35 x86` | `C:\msvc20\include;C:\msvc20\mfc\include;C:\mstools\h` | `C:\msvc20\lib;C:\msvc20\mfc\lib;C:\mstools\lib` |
| `nt35 mips` | `C:\msvc20\include;C:\msvc20\mfc\include` | `C:\msvc20\lib;C:\msvc20\mfc\lib` |
| `nt35 alpha` | `C:\mstools\h;C:\mstools\h\crt;C:\mstools\idl` | `C:\mstools\lib;C:\mstools\lib\crt` |
| `nt40` | `C:\mstools\include;C:\msdev\include;C:\msdev\mfc\include` | `C:\mstools\lib;C:\msdev\lib;C:\msdev\mfc\lib` |
| `nt50 axp64` | `C:\mssdk\include;C:\mssdk\include\win64\crt;C:\mssdk\include\win64\mfc;C:\mssdk\include\win64\atl;C:\vc98\include` | `C:\mssdk\lib\win64;C:\mssdk\lib\win64\crt;C:\mssdk\lib\win64\mfc;C:\mssdk\lib\win64\atl` |
| `nt52 ia64` | `C:\mssdk\include\crt;C:\mssdk\include\crt\sys;C:\mssdk\include\mfc;C:\mssdk\include\atl;C:\mssdk\include` | `C:\mssdk\lib\ia64;C:\mssdk\lib\ia64\mfc` |

- To change `INCLUDE`, `LIB`, `NTRUN_PATH` or `NTRUN_DLLPATH`, use `-e`, for example `-e 'INCLUDE=Z:\src\inc;C:\mstools\include;C:\msdev\include'`.
- The redistributable DLLs, such as `MSVCRT20.DLL` and `MFC40.DLL`, are in `redist` of Visual C++: `/opt/nt40/alpha/msdev/redist`.

## Good to know

- **nt35 needs `-DWIN32`.** Without it the headers of that time do not compile. `$(cvars)` of `ntwin32.mak` has it.
- **nt35 for Alpha has no `OLDNAMES.LIB`, and its `cl` does not add `kernel32.lib`.** When `cl` links by itself: `cl -DWIN32 hello.c kernel32.lib -link -nodefaultlib:oldnames.lib`. The makefiles with `ntwin32.mak` do not need this.
- **nt31: `link32` cannot read a `.res` file.** Make an object file of it first: `cvtres -$(CPU) app.res -o app.rbj`.
- **nt40 for MIPS, Alpha and PowerPC uses the headers and libraries of the NT 4.0 SDK first**, as for x86. For Visual C++ 4.1 only, add
  `-e 'NTRUN_PATH=C:\msdev\bin' -e 'INCLUDE=C:\msdev\include;C:\msdev\mfc\include' -e 'LIB=C:\msdev\lib;C:\msdev\mfc\lib'`.
- **Programs with windows build, but they do not run in the image.** For that reason `mktyplib` and `makehm` do not run. The help compilers `hc30` and `hc31` are 16-bit DOS programs: they do not run.
- **Exit codes come through.** A failed compile makes `nmake` fail, and `docker run` fails too.
- **Files belong to root.** The container runs as root, so on Linux the files it writes are owned by root.
- The image has no samples, C library or MFC source, or help files.

## AXP64

Windows 2000 for 64-bit Alpha was not released. The Platform SDK for Windows 2000 RC2 has an early compiler, linker and libraries for it. `ReadMe64.Txt` of that SDK is in `/opt/nt50/axp64/mssdk`.

```
docker run --rm -v "$PWD":/src tenox7/ntsdk axp64 cl hello.c
docker run --rm -v "$PWD":/src tenox7/ntsdk axp64 dumpbin -headers hello.exe     # 284 machine (Alpha64), PE32+
```

- **The tools are 32-bit Alpha programs.** `ntrun` runs them. They make 64-bit programs: machine type `0284`, format PE32+.
- **You cannot run these programs in the image.** `ntrun` runs 32-bit programs only.
- **`-Ap64` is the 64-bit mode of the compiler.** `ntsdk` puts it in the variable `CL`, so each `cl` command has it. The compiler then defines `_WIN64`, `_AXP64_` and `_M_AXP64`. Without `-Ap64` the compiler makes 32-bit code, and the link fails.
- **Makefiles with `win32.mak` work.** `CPU` is `ALPHA64`. The options of `win32.mak` are `-D_AXP64_=1 -D_ALPHA64_=1 -DALPHA=1 -DWIN64 -D_WIN64 -DWIN32 -D_WIN32 -Wp64 -W4 -Ap64`.
- **C++ and MFC work.** The MFC 4.2 libraries are the release libraries, static and for the DLL. There is no `MFC42.DLL` or `MSVCRT.DLL` for AXP64.
- **midl:** use `midl -win64`.
- **Debug data:** use a `.pdb` file, which is the default of `link -debug`. `-pdb:none` does not work: `cvpack` of this SDK is the 32-bit tool of Visual C++ 6.0, and it cannot read a 64-bit program.
- **`__FILE__` in a header is the full path**, for example `z:\src\stb_image.h`. A program that uses it has the name of your folder in it.

## Itanium

The Platform SDK for Windows Server 2003 SP1 has a cross compiler for Itanium (IA-64). Its tools are x86 programs, and `ntrun` runs them.

```
docker run --rm -v "$PWD":/src tenox7/ntsdk ia64 cl hello.c bufferoverflowu.lib
docker run --rm -v "$PWD":/src tenox7/ntsdk ia64 dumpbin -headers hello.exe      # 200 machine (IA64), PE32+
```

- **Add `bufferoverflowu.lib` to each link.** The libraries of this SDK need it for the `-GS` check. Without it the linker says `unresolved external symbol __security_cookie`. `win32.mak` adds it.
- **You cannot run these programs in the image.** `ntrun` runs 32-bit programs only.
- **No `.pdb` files.** `cl -Zi` and `link -debug` stop with `MSPDB80.DLL: unable to connect`: these tools use a server program for `.pdb` files, and `ntrun` cannot run it. `cl -Z7` works (debug data in the object file).
- **Makefiles with `win32.mak` work with `nmake NODEBUG=1`.** Without `NODEBUG=1` they use `-Zi`. `CPU` is `IA64` and `APPVER` is `5.02`.
- **C++ and MFC work.** The MFC 4.2 libraries are the release libraries, static and for the DLL.
- **`dumpbin` and `editbin`** are `link -dump` and `link -edit` here. This SDK has no such programs.
- **midl:** use `midl -win64`. **The assembler** is `ias`.
- **The linker writes unused memory into some bytes of a C++ program.** So two links of the same C++ program on two systems do not give the same file. The object files are the same.

## Tests

```
tests/run.sh tenox7/ntsdk
```

- It builds a small program with `nmake` for each SDK and CPU (12 combinations) and runs it with `ntrun`. The AXP64 and Itanium programs cannot run: the test reads their headers with `dumpbin`.
- For x86 it builds the same program with the Wine image of that SDK and compares the files. The object and resource files must be the same.
- The emulator has its own tests in the [ntrun](https://github.com/tenox7/ntrun) repository. They run in this image.

Checked with a larger program (an rsh daemon with a resource file, built with `nmake`):

- `nt31` for x86, MIPS and Alpha: the program is the same file as from a build on Windows NT, but for the time stamps.
- `nt35` and `nt40` for x86: the program is the same file as from a link on Windows NT 3.51, but for the time stamps. The link in the Wine images puts the imports in another order (about 370 bytes of the file).
- `nt40` for MIPS, Alpha and PowerPC with Visual C++ 4.1 only: the same file as from a build on Windows NT, but for the time stamps.
- The object files for x86 are the same as from the Wine images.
- `nt50` for AXP64, two other programs (a console program, and a 628 KB program with windows, compiled with `/Ox`): the same files as from a build with the same tools on Windows for Alpha, but for the time stamps.
- `nt52` for Itanium: there is no build from a real Windows system to compare with. 12 object files (C, C++, MFC, a 500 KB program with `/Ox`, the assembler) and a linked C program are the same files as from the same tools under Wine 8, but for the time stamps. Under Wine the linker of this SDK stops with an internal error for most programs; in this image it does not.

## Build the image

```
docker build -t ntsdk .
docker build --build-context ntrun=../ntrun -t ntsdk .         # ntrun from a local folder
docker buildx build --platform linux/amd64,linux/arm64 -t ntsdk .
```

The Dockerfile gets ntrun from its repository and compiles it. The tools come from these folders:

| Folder | From |
|---|---|
| `nt31sdk/mstools`, `nt35sdk/msvc20`, `nt35sdk/mstools`, `nt40sdk/msdev`, `nt40sdk/mstools` | The x86 tools: the same folders as for the Wine images. Their READMEs tell where they come from. |
| `tools/nt31/mips/mstools` | Win32 SDK for Windows NT 3.1 (July 1993): `MSTOOLS\BIN\MIPS` as `bin`, `MSTOOLS\LIB\MIPS` as `lib`. The headers are those of x86. |
| `tools/nt31/alpha/mstools` | The SDK with the Alpha tools: `MSTOOLS\BIN\ALPHA`, `MSTOOLS\H` and `MSTOOLS\LIB\ALPHA` |
| `tools/nt35/mips/msvc20` | Visual C++ 2.0 for MIPS: `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` of `MSVC20` |
| `tools/nt35/alpha/mstools` | Win32 SDK for Windows NT 3.5 for Alpha: `MSTOOLS\BIN\ALPHA`, `MSTOOLS\H`, `MSTOOLS\IDL`, `MSTOOLS\LIB\ALPHA`, and `MSTOOLS\LIB\CRT\ALPHA` as `lib/crt` |
| `tools/nt40/CPU/msdev` | Visual C++ 4.1 for MIPS, Alpha and PowerPC: `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` of `MSDEV` |
| `tools/nt40/CPU/mstools` | Win32 SDK for Windows NT 4.0: `MSTOOLS\BIN\CPU` with `MSTOOLS\BIN\WINNT\CPU` as `bin`, `MSTOOLS\LIB\CPU` with `MSTOOLS\LIB\WINNT\CPU` as `lib` (expanded). The headers are those of x86. |
| `tools/nt50/axp64/mssdk` | Platform SDK for Windows 2000 RC2 (September 1999), the setup for Alpha (`psdk-alpha.msi`): `Bin\Win64` as `bin/win64`, the console build tools of `Bin` as `bin`, `Include` as `include`, `Lib\Win64` as `lib/win64` (MFC: the release libraries only) |
| `tools/nt50/axp64/vc98` | Visual C++ 6.0 for Alpha: `nmake`, `dumpbin` and `editbin` (`bin`), `MSVCRT.DLL` and `MSVCP60.DLL` for the tools (`redist`), and the 16 headers that the headers of the SDK include and the SDK does not have, such as `zmouse.h` for MFC (`include`) |
| `tools/nt52/ia64/mssdk` | Platform SDK for Windows Server 2003 SP1 (April 2005), the setup for x86 (`PSDK-x86.msi`): `Bin\win64` (the cross compiler for IA-64) as `bin/win64`, `nmake`, `rc`, `mc`, `midl` and `uuidgen` of `Bin` as `bin`, `Include` as `include`, `Lib\IA64` as `lib/ia64` (MFC: the release libraries only) |
| `tools/sys/CPU` | The C runtime DLLs of Windows NT 4.0 for that CPU (`CRTDLL.DLL`, `MSVCRT.DLL` ...). Some tools need them. |

## The Wine images

The three older images are in this repository too. Each has one SDK for x86, and Wine runs the tools:

- [nt31sdk](nt31sdk) — Windows NT 3.1 SDK (1993): [tenox7/nt31sdk](https://hub.docker.com/r/tenox7/nt31sdk)
- [nt35sdk](nt35sdk) — Visual C++ 2.0 and NT 3.5 SDK (1994): [tenox7/nt35sdk](https://hub.docker.com/r/tenox7/nt35sdk)
- [nt40sdk](nt40sdk) — Visual C++ 4.2 and NT 4.0 SDK (1996): [tenox7/nt40sdk](https://hub.docker.com/r/tenox7/nt40sdk)

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk nmake
```

- They are `linux/386` images. On arm64 hosts, such as Apple Silicon Macs, they run under emulation.
- Use them when a tool needs Wine: `mktyplib`, `makehm`, or a program with windows.
