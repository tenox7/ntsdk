# ntsdk: the original Microsoft tools for Windows NT 3.1, 3.5 and 4.0, for x86, MIPS, Alpha and
# PowerPC, and for 64-bit Alpha (AXP64), in one image. ntrun (https://github.com/tenox7/ntrun)
# runs the tools: no Wine, and the image is a native linux/amd64 or linux/arm64 image.
#
#   docker build -t ntsdk .
#   docker build --build-context ntrun=../ntrun -t ntsdk .      with ntrun from a local folder
#
# The x86 tool folders are those of the three Wine images (nt31sdk, nt35sdk, nt40sdk).
# tools/ has the tools for the RISC CPUs and the C runtime DLLs of Windows NT.
# tools/nt50/axp64 has the tools for 64-bit Alpha: 32-bit Alpha programs that make 64-bit code.

# the source of ntrun
FROM scratch AS ntrun
ADD https://github.com/tenox7/ntrun.git /

FROM debian:bookworm-slim AS build
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      gcc libc6-dev make && rm -rf /var/lib/apt/lists/*
COPY --from=ntrun / /ntrun
RUN make -B -C /ntrun CC=gcc LDFLAGS=-static

FROM debian:bookworm-slim
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      make && rm -rf /var/lib/apt/lists/*
# The tools first: these layers do not change when ntrun changes. One layer for each SDK,
# so a new SDK does not change the layers of the others.
# /opt/SDK/CPU is drive C: of that SDK for that CPU.
COPY nt31sdk/mstools /opt/nt31/x86/mstools
COPY nt35sdk/msvc20 /opt/nt35/x86/msvc20
COPY nt35sdk/mstools /opt/nt35/x86/mstools
COPY nt40sdk/msdev /opt/nt40/x86/msdev
COPY nt40sdk/mstools /opt/nt40/x86/mstools
COPY tools/sys /opt/sys
COPY tools/nt31 /opt/nt31
COPY tools/nt35 /opt/nt35
COPY tools/nt40 /opt/nt40
COPY tools/nt50 /opt/nt50
# The headers of the NT 3.1 SDK (1993) and of the NT 4.0 SDK are the same for each CPU: one copy.
# Each tool is a command.
RUN ln -s /opt/ntrun/ntrun /usr/local/bin/ntrun && \
    ln -s ../../x86/mstools/h /opt/nt31/mips/mstools/h && \
    for c in mips alpha ppc; do ln -s ../../x86/mstools/include /opt/nt40/$c/mstools/include; done && \
    for t in cl cl386 mcl claxp acc cc link link32 lib lib32 nmake rc cvtres mc midl masm386 asaxp pas \
      mip2coff a2coff dumpbin editbin bscmake cvpack cvdump undname uuidgen rebase; do \
      ln -s nt-tool /usr/local/bin/$t; done
# ntrun, and the empty cmd.exe that stands for its command processor
COPY --from=build /ntrun/ntrun /ntrun/cmd.exe /opt/ntrun/
COPY ntsdk nt-tool /usr/local/bin/
COPY README.md /usr/local/share/ntsdk/
WORKDIR /src
ENTRYPOINT ["ntsdk"]
