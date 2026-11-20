/* hello.c: the test program of the ntsdk image. It prints the CPU type of its own file,
   the version of the compiler, a number that the compiler calculated, a number that the
   program calculated, and a text from its resources. */
#include <windows.h>
#include <stdio.h>

static double sum(int n)
{
    double s = 0;
    int i;

    for (i = 1; i <= n; i++)
        s += 1.0 / i;
    return s;
}

int main(int argc, char **argv)
{
    unsigned char *base = (unsigned char *)GetModuleHandle(NULL);
    unsigned short machine = *(unsigned short *)(base + *(long *)(base + 0x3c) + 4);
    char *text = "no resource";
    HRSRC r = FindResource(NULL, MAKEINTRESOURCE(1), RT_RCDATA);
    int compiler = 0;

#ifdef _MSC_VER
    compiler = _MSC_VER;
#endif
    if (r)
        text = (char *)LockResource(LoadResource(NULL, r));
    printf("hello: machine %04x, compiler %d\n", machine, compiler);
    printf("%d %.6f %s\n", 6 * 7, sum(1000), text);
    return 0;
}
