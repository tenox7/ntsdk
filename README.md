# ntsdk

**A cross compiler for Windows NT, in a Docker image.** It builds programs for all Windows NT platforms, on Linux and macOS.

**Docker Hub:** [tenox7/ntsdk](https://hub.docker.com/r/tenox7/ntsdk)

| Target CPU | Windows NT | Words |
|---|---|---|
| x86 | 3.1, 3.5, 3.51, 4.0 | `nt31 x86`, `nt35 x86`, `nt40 x86` |
| MIPS | 3.1, 3.5, 3.51, 4.0 | `nt31 mips`, `nt35 mips`, `nt40 mips` |
| Alpha | 3.1, 3.5, 3.51, 4.0 | `nt31 alpha`, `nt35 alpha`, `nt40 alpha` |
| PowerPC | 3.51, 4.0 | `nt40 ppc` |
| AXP64 (64-bit Alpha) | Windows 2000 (not released) | `axp64` |
| Itanium (IA-64) | Windows Server 2003 | `ia64` |

```
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 alpha nmake
```

- The compilers are the original Microsoft tools of each Windows NT version.
- [ntrun](https://github.com/tenox7/ntrun) runs them. There is no Wine and no VM.
- The image is native on `linux/amd64` and `linux/arm64`.
- The output is the same file as from a build on real Windows NT, but for the time stamps (see Tests).

## Use

1. Go to your project folder. The container sees it as `/src`.
2. Give the two words of the target, then the command.

```
docker run --rm -v "$PWD":/src tenox7/ntsdk nmake                      # no words: nt40 x86
docker run --rm -v "$PWD":/src tenox7/ntsdk nt35 mips nmake
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 ppc cl hello.c
docker run --rm -v "$PWD":/src tenox7/ntsdk axp64 cl hello.c
docker run --rm -v "$PWD":/src tenox7/ntsdk ia64 cl hello.c bufferoverflowu.lib
docker run --rm -v "$PWD":/src tenox7/ntsdk nt40 alpha ntrun hello.exe # run the program
docker run --rm -it -v "$PWD":/src tenox7/ntsdk nt31 mips              # a shell
docker run --rm tenox7/ntsdk                                           # this text
```

One container can build for all CPUs. `ntsdk` is a command in the image:

```
docker run --rm -v "$PWD":/src tenox7/ntsdk sh -c '
  for cpu in x86 mips alpha ppc; do
    ntsdk nt40 $cpu cl -Fehello-$cpu.exe hello.c || exit 1
  done'
```

| Command | What it does |
|---|---|
| `cl cl386 mcl claxp acc cc link link32 lib lib32 nmake rc cvtres mc midl masm386 asaxp pas ias mip2coff a2coff dumpbin editbin bscmake cvpack cvdump undname uuidgen rebase` | The tools. Each SDK has some of them. |
| `ntrun TOOL ARGS` | Any other tool of the SDK. Example: `ntrun where cl.exe` |
| `ntrun hello.exe` | Runs a 32-bit console program for x86, MIPS, Alpha or PowerPC. |
| `ntsdk SDK CPU COMMAND` | Runs a command for another target. |
| `make` | GNU make. |

## Tools

| Words | SDK and compiler | Versions |
|---|---|---|
| `nt31 x86` | Win32 SDK for Windows NT 3.1 (July 1993) | `cl386` 8.00, `link32` 2.42, `nmake` 1.12, `rc` 3.10, `lib32`, `masm386`, `midl` 1.00 |
| `nt31 mips` | The same SDK | `cl` or `mcl` 8.00, `cc` with `mip2coff`, `link32` 2.42 |
| `nt31 alpha` | The same SDK with the Alpha tools | `cl` or `claxp` 8.00, `acc` with `a2coff`, `asaxp`, `link32` 2.43 |
| `nt35 x86` | Visual C++ 2.0, then the Win32 SDK for Windows NT 3.5 | `cl` 9.00, `link` 2.50, `nmake` 1.50, MFC 3.0, `masm386`, `midl` 2.00 |
| `nt35 mips` | Visual C++ 2.0 for MIPS | `cl` 9.00, `link` 2.50, `nmake` 1.50, MFC 3.0 |
| `nt35 alpha` | Win32 SDK for Windows NT 3.5 for Alpha (it has its own compiler) | `cl` or `claxp` 8.03, `link` 2.50, `nmake` 1.50, `asaxp`, `midl` 2.00 |
| `nt40 x86` | Win32 SDK for Windows NT 4.0, then Visual C++ 4.2 | `cl` 10.20, `link` 4.20, `nmake` 1.61, `rc` 4.00, `midl` 3.00, MFC 4.2 |
| `nt40 mips`, `nt40 alpha`, `nt40 ppc` | Win32 SDK for Windows NT 4.0, then Visual C++ 4.1 | `cl` 10.10, `link` 3.10, `nmake` 1.61, MFC 4.1, `asaxp` (Alpha), `pas` (PowerPC) |
| `axp64` | Platform SDK for Windows 2000 RC2 (September 1999) | `cl` 13.00, `link` 6.20, `nmake` 6.00, `rc` 5.00, `mc` 1.11, `midl` 5.03, `asaxp`, MFC 4.2 |
| `ia64` | Platform SDK for Windows Server 2003 SP1 (April 2005) | `cl` 14.00, `link` 8.00, `nmake` 7.00, `rc` 5.2, `mc` 1.12, `midl` 6.00, `ias` 8.00, MFC 4.2 |

- The SDK word of `axp64` is `nt50`. The SDK word of `ia64` is `nt52`. You can leave them out.
- The folders [nt31sdk](nt31sdk), [nt35sdk](nt35sdk) and [nt40sdk](nt40sdk) tell you how to write a makefile for each SDK. This is the same for each CPU.

## Paths

| In the container | For the tools |
|---|---|
| `/src` (your folder) | `Z:\src` |
| `/opt/SDK/CPU`, for example `/opt/nt40/alpha` | `C:\` |

- Relative paths work.
- An absolute Unix path on the command line becomes a `Z:` path. Examples: `/src/x.c`, `-Fo/src/out/x.obj`, `-out:/src/x.exe`.
- The redistributable DLLs (`MSVCRT20.DLL`, `MFC40.DLL` ...) are in `redist` of Visual C++: `/opt/nt40/alpha/msdev/redist`.

## Environment

`ntsdk` sets these variables:

| Variable | Value |
|---|---|
| `CPU` | `i386`, `MIPS`, `ALPHA`, `PPC`, `ALPHA64` or `IA64`. The makefiles of the SDKs use it (`ntwin32.mak`, `win32.mak`). |
| `INCLUDE`, `LIB` | The folders of the SDK and the compiler. See the next table. |
| `NTRUN_PATH` | The `PATH` of the tools. |
| `NTRUN_DLLPATH` | The folders with the DLLs of the tools. |
| `NTSDK`, `NTCPU` | The two words of the target, for example `nt40` and `alpha`. |
| `PROCESSOR_ARCHITECTURE`, `OS` | As on Windows NT: the CPU of the tools, and `Windows_NT`. |
| `CL` | `axp64` only: `-Ap64`, in front of your own `CL`. |
| `APPVER`, `TARGETOS` | `ia64` only: `5.02` and `WINNT`, for `win32.mak`. |

| Words | `INCLUDE` | `LIB` |
|---|---|---|
| `nt31` | `C:\mstools\h` | `C:\mstools\lib` |
| `nt35 x86` | `C:\msvc20\include;C:\msvc20\mfc\include;C:\mstools\h` | `C:\msvc20\lib;C:\msvc20\mfc\lib;C:\mstools\lib` |
| `nt35 mips` | `C:\msvc20\include;C:\msvc20\mfc\include` | `C:\msvc20\lib;C:\msvc20\mfc\lib` |
| `nt35 alpha` | `C:\mstools\h;C:\mstools\h\crt;C:\mstools\idl` | `C:\mstools\lib;C:\mstools\lib\crt` |
| `nt40` | `C:\mstools\include;C:\msdev\include;C:\msdev\mfc\include` | `C:\mstools\lib;C:\msdev\lib;C:\msdev\mfc\lib` |
| `axp64` | `C:\mssdk\include;C:\mssdk\include\win64\crt;C:\mssdk\include\win64\mfc;C:\mssdk\include\win64\atl;C:\vc98\include` | `C:\mssdk\lib\win64;C:\mssdk\lib\win64\crt;C:\mssdk\lib\win64\mfc;C:\mssdk\lib\win64\atl` |
| `ia64` | `C:\mssdk\include\crt;C:\mssdk\include\crt\sys;C:\mssdk\include\mfc;C:\mssdk\include\atl;C:\mssdk\include` | `C:\mssdk\lib\ia64;C:\mssdk\lib\ia64\mfc` |

To change `INCLUDE`, `LIB`, `NTRUN_PATH` or `NTRUN_DLLPATH`, use `-e`. Example: `-e 'INCLUDE=Z:\src\inc;C:\mstools\include;C:\msdev\include'`.

## Notes

### All targets

- Programs with windows build, but they do not run in the image.
- `mktyplib`, `makehm`, `hc30` and `hc31` do not run.
- Exit codes come through. A compile that fails makes `nmake` fail, and `docker run` fails too.
- The container runs as root. On Linux, root owns the files that it writes.
- The image has no samples, no C library or MFC source, and no help files.

### nt31

- `link32` cannot read a `.res` file. Make an object file first: `cvtres -$(CPU) app.res -o app.rbj`.

### nt35

- **Windows NT 3.51:** use `nt35`. Its programs are marked for Windows NT 3.10. They run on 3.5, 3.51 and 4.0.
- **Add `-DWIN32`.** Without it the headers do not compile. `$(cvars)` of `ntwin32.mak` has it.
- **Alpha:** there is no `OLDNAMES.LIB`, and `cl` does not add `kernel32.lib`. Use `cl -DWIN32 hello.c kernel32.lib -link -nodefaultlib:oldnames.lib`. Makefiles with `ntwin32.mak` do not need this.

### nt40

- **PowerPC on Windows NT 3.51:** link with `-subsystem:console,3.51`, or with `-subsystem:windows,3.51`.
- **MIPS, Alpha and PowerPC** use the NT 4.0 SDK first, then Visual C++ 4.1. This is the same order as for x86. For Visual C++ 4.1 only, add
  `-e 'NTRUN_PATH=C:\msdev\bin' -e 'INCLUDE=C:\msdev\include;C:\msdev\mfc\include' -e 'LIB=C:\msdev\lib;C:\msdev\mfc\lib'`.

### axp64

Windows 2000 for 64-bit Alpha was not released. The Platform SDK for Windows 2000 RC2 has an early compiler for it. `ReadMe64.Txt` of that SDK is in `/opt/nt50/axp64/mssdk`.

- The tools are 32-bit Alpha programs. They make 64-bit programs (machine type `0284`, format PE32+).
- The programs do not run in the image.
- **`-Ap64`** is the 64-bit mode of `cl`. `ntsdk` puts it in `CL`, so each `cl` command has it. The compiler then defines `_WIN64`, `_AXP64_` and `_M_AXP64`.
- **`win32.mak`** works. `CPU` is `ALPHA64`. Its options are `-D_AXP64_=1 -D_ALPHA64_=1 -DALPHA=1 -DWIN64 -D_WIN64 -DWIN32 -D_WIN32 -Wp64 -W4 -Ap64`.
- **C++ and MFC** work. The MFC 4.2 libraries are the release libraries, static and for the DLL. There is no `MFC42.DLL` or `MSVCRT.DLL` for AXP64.
- **midl:** use `midl -win64`.
- **Debug data:** use a `.pdb` file. This is the default of `link -debug`. `-pdb:none` does not work, because `cvpack` cannot read a 64-bit program.
- **`__FILE__` in a header** is the full path, for example `z:\src\stb_image.h`. A program that uses it has the name of your folder in it.

### ia64

The Platform SDK for Windows Server 2003 SP1 has a cross compiler for Itanium. Its tools are x86 programs.

- **Add `bufferoverflowu.lib` to each link.** Without it the linker says `unresolved external symbol __security_cookie`. `win32.mak` adds it.
- The programs do not run in the image.
- **No `.pdb` files.** `cl -Zi` and `link -debug` stop with `MSPDB80.DLL: unable to connect`. `cl -Z7` works: the debug data is in the object file.
- **`win32.mak`** works with `nmake NODEBUG=1`. Without `NODEBUG=1` it uses `-Zi`. `CPU` is `IA64` and `APPVER` is `5.02`.
- **C++ and MFC** work. The MFC 4.2 libraries are the release libraries, static and for the DLL.
- **`dumpbin` and `editbin`** are `link -dump` and `link -edit`. This SDK has no such programs.
- **midl:** use `midl -win64`. **The assembler** is `ias`.
- **C++ programs:** the linker writes unused memory into some bytes of the file. Two links of one C++ program on two systems do not give the same file. The object files are the same.

## Tests

```
tests/run.sh tenox7/ntsdk
```

- The script builds a small program with `nmake` for each of the 12 targets.
- It runs the program with `ntrun`. The AXP64 and Itanium programs cannot run: the script reads their headers with `dumpbin`.
- For x86 it builds the same program in the Wine image of that SDK. The object and resource files must be the same.
- `ntrun` has its own tests in its [repository](https://github.com/tenox7/ntrun). They run in this image.

These files are the same, but for the time stamps:

| Target | Program | The same file as from |
|---|---|---|
| `nt31` x86, MIPS, Alpha | An rsh daemon with resources, built with `nmake` | A build on Windows NT |
| `nt35` x86, `nt40` x86 | The same program | A link on Windows NT 3.51 |
| `nt40` MIPS, Alpha, PowerPC, with Visual C++ 4.1 only | The same program | A build on Windows NT |
| x86 | Object files | The Wine images |
| `axp64` | A console program, and a 628 KB program with windows (`/Ox`) | A build with the same tools on Windows for Alpha |
| `ia64` | 12 object files (C, C++, MFC, the assembler) and a linked C program | The same tools under Wine 8 |

- The link in the Wine images puts the imports in another order (about 370 bytes of the file).
- For Itanium there is no build from a real Windows system to compare with.
- Under Wine 8 the Itanium linker stops with an internal error for most programs. In this image it does not.

## Build the image

```
docker build -t ntsdk .
docker build --build-context ntrun=../ntrun -t ntsdk .         # ntrun from a local folder
docker buildx build --platform linux/amd64,linux/arm64 -t ntsdk .
```

The Dockerfile gets ntrun from its repository and compiles it. The tools come from these folders:

| Folder | From |
|---|---|
| `nt31sdk/mstools`, `nt35sdk/msvc20`, `nt35sdk/mstools`, `nt40sdk/msdev`, `nt40sdk/mstools` | The x86 tools. These are the folders of the Wine images. Their READMEs tell where they come from. |
| `tools/nt31/mips/mstools` | Win32 SDK for Windows NT 3.1 (July 1993): `MSTOOLS\BIN\MIPS` as `bin`, `MSTOOLS\LIB\MIPS` as `lib`. The headers are those of x86. |
| `tools/nt31/alpha/mstools` | The SDK with the Alpha tools: `MSTOOLS\BIN\ALPHA`, `MSTOOLS\H` and `MSTOOLS\LIB\ALPHA` |
| `tools/nt35/mips/msvc20` | Visual C++ 2.0 for MIPS: `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` of `MSVC20` |
| `tools/nt35/alpha/mstools` | Win32 SDK for Windows NT 3.5 for Alpha: `MSTOOLS\BIN\ALPHA`, `MSTOOLS\H`, `MSTOOLS\IDL`, `MSTOOLS\LIB\ALPHA`, and `MSTOOLS\LIB\CRT\ALPHA` as `lib/crt` |
| `tools/nt40/CPU/msdev` | Visual C++ 4.1 for MIPS, Alpha and PowerPC: `bin`, `include`, `lib`, `mfc/include`, `mfc/lib` and `redist` of `MSDEV` |
| `tools/nt40/CPU/mstools` | Win32 SDK for Windows NT 4.0: `MSTOOLS\BIN\CPU` with `MSTOOLS\BIN\WINNT\CPU` as `bin`, `MSTOOLS\LIB\CPU` with `MSTOOLS\LIB\WINNT\CPU` as `lib` (expanded). The headers are those of x86. |
| `tools/nt50/axp64/mssdk` | Platform SDK for Windows 2000 RC2, the setup for Alpha (`psdk-alpha.msi`): `Bin\Win64` as `bin/win64`, the console build tools of `Bin` as `bin`, `Include` as `include`, `Lib\Win64` as `lib/win64` (MFC: the release libraries only) |
| `tools/nt50/axp64/vc98` | Visual C++ 6.0 for Alpha: `nmake`, `dumpbin` and `editbin` (`bin`), `MSVCRT.DLL` and `MSVCP60.DLL` for the tools (`redist`), and 16 headers that the SDK headers include and the SDK does not have, such as `zmouse.h` for MFC (`include`) |
| `tools/nt52/ia64/mssdk` | Platform SDK for Windows Server 2003 SP1, the setup for x86 (`PSDK-x86.msi`): `Bin\win64` (the cross compiler for IA-64) as `bin/win64`, `nmake`, `rc`, `mc`, `midl` and `uuidgen` of `Bin` as `bin`, `Include` as `include`, `Lib\IA64` as `lib/ia64` (MFC: the release libraries only) |
| `tools/sys/CPU` | The C runtime DLLs of Windows NT 4.0 for that CPU (`CRTDLL.DLL`, `MSVCRT.DLL` ...). Some tools need them. |

## The Wine images

The three older images are in this repository too. Each has one SDK for x86, and Wine runs the tools.

| Folder | SDK | Docker Hub |
|---|---|---|
| [nt31sdk](nt31sdk) | Windows NT 3.1 SDK (1993) | [tenox7/nt31sdk](https://hub.docker.com/r/tenox7/nt31sdk) |
| [nt35sdk](nt35sdk) | Visual C++ 2.0 and NT 3.5 SDK (1994) | [tenox7/nt35sdk](https://hub.docker.com/r/tenox7/nt35sdk) |
| [nt40sdk](nt40sdk) | Visual C++ 4.2 and NT 4.0 SDK (1996) | [tenox7/nt40sdk](https://hub.docker.com/r/tenox7/nt40sdk) |

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk nmake
```

- They are `linux/386` images. On arm64 hosts, such as Apple Silicon Macs, they run under emulation.
- Use them when a tool needs Wine: `mktyplib`, `makehm`, or a program with windows.
