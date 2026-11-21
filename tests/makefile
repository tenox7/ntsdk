# makefile of the test program: one makefile for each SDK and CPU of the ntsdk image.
# cl starts the linker of its SDK. NTSDK (nt31, nt35, nt40) and CPU come from the image.

# The linker of the NT 3.1 SDK cannot read a .res file: cvtres makes an object file of it.
!IF "$(NTSDK)" == "nt31"
RES = hello.rbj
!ELSE
RES = hello.res
!ENDIF

# The NT 3.5 SDK for Alpha has no OLDNAMES.LIB, and its compiler asks for it.
!IF "$(NTSDK)" == "nt35" && "$(CPU)" == "ALPHA"
LFLAGS = -link -nodefaultlib:oldnames.lib
!ENDIF

# The libraries of the nt52 SDK for Itanium need this library: it has the code of the -GS check.
!IF "$(NTSDK)" == "nt52"
LIBS = bufferoverflowu.lib
!ENDIF

all: hello.exe

hello.res: hello.rc
	rc -r hello.rc

hello.rbj: hello.res
	cvtres -$(CPU) hello.res -o hello.rbj

hello.exe: hello.c $(RES)
	cl -nologo -O2 -DWIN32 hello.c $(RES) kernel32.lib libc.lib $(LIBS) $(LFLAGS)
