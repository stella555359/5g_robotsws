#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

void* open_shared_memory(char* name, int size) {
    int fd = shm_open (name, O_RDWR , S_IRUSR | S_IWUSR);
    if (fd == -1)
    {
        fprintf(stderr, "Cannot open shmem\n");
        exit(1);
    }
    ftruncate(fd, size);
    int protection = PROT_READ | PROT_WRITE;
    int visibility = MAP_SHARED;
    return mmap(NULL, size, protection, visibility, fd, 0);
}

int main( int argc, char *argv[] ) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s SHMNAME SIZE MESSAGE\n", argv[0]);
        exit(1);
    }
    int size = strtol(argv[2], NULL, 10);
    void* shmem = open_shared_memory(argv[1], size);
    int nbBytesNeeded = strlen(argv[3]) / 4 + 1;
    char *buf = malloc(nbBytesNeeded);
    size_t i = 0;
    int n = 0;

    for (char *tok = strtok(argv[3], "\\x"); tok; tok = strtok(NULL, "\\x"))
    {
        n = sscanf(tok, "%02hhx", buf + i);
        i++;
    }

    buf[i] = '\0';
    memcpy(shmem, buf, nbBytesNeeded);
    free(buf);
}

