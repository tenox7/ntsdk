# Visual C++ 4.2 (July 1996, i386) and the Win32 SDK for Windows NT 4.0 (1996) under Wine:
# cl 10.20, link 4.20, nmake 1.61, lib, rc, midl, dumpbin, editbin and the rest of the
# command-line tools, with the NT 4.0 headers and libraries and MFC 4.2. 32-bit Debian, so
# Wine runs the 1996 tools natively on x86 hosts and under emulation on arm64 ones.
# msdev/ holds the bin, include, lib, mfc/include, mfc/lib and redist folders of the
# Visual C++ CD's MSDEV; mstools/ holds the SDK's i386 bin, include and lib folders as its
# setup lays them out. The image has no samples, CRT or MFC source or other source code.
# Build and run as linux/386:
#   docker build --platform linux/386 -t nt40sdk .
FROM i386/debian:bookworm
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wine wine32 make && rm -rf /var/lib/apt/lists/*
ENV WINEDEBUG=-all WINEPREFIX=/opt/wine WINEARCH=win32
RUN wineboot --init; wineserver -w; true
COPY msdev /opt/msdev
COPY mstools /opt/mstools
# the SDK's INCLUDE, LIB and PATH in front of Visual C++ 4.2's, as SETENV puts them, as Z: paths
ENV CPU=i386 \
    INCLUDE=Z:\\opt\\mstools\\include;Z:\\opt\\msdev\\include;Z:\\opt\\msdev\\mfc\\include \
    LIB=Z:\\opt\\mstools\\lib;Z:\\opt\\msdev\\lib;Z:\\opt\\msdev\\mfc\\lib \
    WINEPATH=Z:\\opt\\mstools\\bin;Z:\\opt\\msdev\\bin
COPY wine-tool entrypoint /usr/local/bin/
COPY README.md /usr/local/share/nt40sdk/
RUN for t in cl link lib nmake rc cvtres dumpbin editbin bscmake mc mktyplib midl cvpack \
      makehm uuidgen; do \
      printf '#!/bin/sh\nexec wine-tool %s "$@"\n' $t > /usr/local/bin/$t && chmod +x /usr/local/bin/$t; done
WORKDIR /src
ENTRYPOINT ["entrypoint"]
