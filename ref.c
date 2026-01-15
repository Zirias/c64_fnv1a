#include <inttypes.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint64_t fnv1a(const char *s)
{
    uint64_t h = 0xcbf29ce484222325;
    unsigned char c;
    while ((c = (unsigned char) *s++))
    {
	h ^= c;
	h *= 0x100000001b3ul;
    }
    return h;
}

int main(int argc, char **argv)
{
    if (argc != 2) return EXIT_FAILURE;

    uint64_t h = fnv1a(argv[1]);
    printf("%" PRIx64 "\n", h);
    return EXIT_SUCCESS;
}

