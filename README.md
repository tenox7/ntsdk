# ntsdk

Docker images with the original Microsoft tools for Windows NT, running under Wine.

- [nt31sdk](nt31sdk) — Windows NT 3.1 SDK (1993) under Wine: build NT 3.1 programs with cl386, link32 and nmake
- [nt35sdk](nt35sdk) — Visual C++ 2.0 and NT 3.5 SDK (1994) under Wine: build NT 3.5 programs with cl, link and nmake
- [nt40sdk](nt40sdk) — Visual C++ 4.2 and NT 4.0 SDK (1996) under Wine: build NT 4.0 programs with cl, link and nmake

## Use the ready-made images

No need to build anything: the images are on Docker Hub as [tenox7/nt31sdk](https://hub.docker.com/r/tenox7/nt31sdk), [tenox7/nt35sdk](https://hub.docker.com/r/tenox7/nt35sdk) and [tenox7/nt40sdk](https://hub.docker.com/r/tenox7/nt40sdk), and `docker run` downloads them the first time.

Go to your project folder and run `nmake` there:

```
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt31sdk nmake   # NT 3.1
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt35sdk nmake   # NT 3.5
docker run --rm --platform linux/386 -v "$PWD":/src tenox7/nt40sdk nmake   # NT 4.0
```

- `--platform linux/386` stops a warning about the platform.
- On arm64 hosts, such as Apple Silicon Macs, the image runs under emulation, so it is slower.
- With no command, the container prints its full instructions.
