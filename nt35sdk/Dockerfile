# Visual C++ 2.0 (September 1994, i386) and the Win32 SDK for Windows NT 3.5 under Wine:
# cl 9.00, link 2.50, nmake 1.50, lib, rc, dumpbin, editbin, masm386, midl and the rest of
# the command-line tools, with the NT 3.5 headers and libraries and MFC 3.0. 32-bit Debian,
# so Wine runs the 1994 tools natively on x86 hosts and under emulation on arm64 ones.
# msvc20/ holds the bin, include, lib, mfc/include, mfc/lib and redist folders of the
# Visual C++ CD's MSVC20; mstools/ holds the SDK's bin, h and lib folders as SETENV expects
# them. The image has no samples, MFC source or other source code. Build and run as linux/386:
#   docker build --platform linux/386 -t nt35sdk .
FROM i386/debian:bookworm
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wine wine32 make && rm -rf /var/lib/apt/lists/*
ENV WINEDEBUG=-all WINEPREFIX=/opt/wine WINEARCH=win32
RUN wineboot --init; wineserver -w; true
COPY msvc20 /opt/msvc20
COPY mstools /opt/mstools
# the INCLUDE, LIB and PATH of Visual C++ 2.0 followed by the SDK's, as Z: paths for Wine
ENV CPU=i386 \
    INCLUDE=Z:\\opt\\msvc20\\include;Z:\\opt\\msvc20\\mfc\\include;Z:\\opt\\mstools\\h \
    LIB=Z:\\opt\\msvc20\\lib;Z:\\opt\\msvc20\\mfc\\lib;Z:\\opt\\mstools\\lib \
    WINEPATH=Z:\\opt\\msvc20\\bin;Z:\\opt\\mstools\\bin
COPY wine-tool entrypoint /usr/local/bin/
COPY README.md /usr/local/share/nt35sdk/
RUN for t in cl link lib nmake rc cvtres dumpbin editbin bscmake mc mktyplib cvpack makehm \
      uuidgen masm386 midl; do \
      printf '#!/bin/sh\nexec wine-tool %s "$@"\n' $t > /usr/local/bin/$t && chmod +x /usr/local/bin/$t; done
WORKDIR /src
ENTRYPOINT ["entrypoint"]
