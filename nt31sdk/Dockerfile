# Win32 SDK for Windows NT 3.1 (July 1993, i386) under Wine: cl386 8.00, link32 2.42,
# nmake 1.12, rc, lib32, masm386 and the rest of MSTOOLS, with its headers and libraries.
# 32-bit Debian, so Wine runs the 1993 tools natively on x86 hosts and under emulation on
# arm64 ones. mstools/ holds the SDK's bin, h and lib folders as SETENV expects them; the
# image has no SDK samples or other source code. Build and run as linux/386:
#   docker build --platform linux/386 -t nt31sdk .
FROM i386/debian:bookworm
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wine wine32 make && rm -rf /var/lib/apt/lists/*
ENV WINEDEBUG=-all WINEPREFIX=/opt/wine WINEARCH=win32
RUN wineboot --init; wineserver -w; true
COPY mstools /opt/mstools
# what SETENV C:\MSTOOLS sets on NT, as Z: paths for Wine
ENV CPU=i386 INCLUDE=Z:\\opt\\mstools\\h LIB=Z:\\opt\\mstools\\lib WINEPATH=Z:\\opt\\mstools\\bin
COPY wine-mstools entrypoint /usr/local/bin/
COPY README.md /usr/local/share/nt31sdk/
RUN for t in cl386 cl link32 lib32 nmake rc cvtres mc masm386 cvdump cvpack undname; do \
      printf '#!/bin/sh\nexec wine-mstools %s "$@"\n' $t > /usr/local/bin/$t && chmod +x /usr/local/bin/$t; done
WORKDIR /src
ENTRYPOINT ["entrypoint"]
