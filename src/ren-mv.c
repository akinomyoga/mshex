#include <stdlib.h>
#include <stdio.h>

// stat
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>


int main(int argc, char** argv) {
  if (!(argc >= 2 && argv[1][0] == '-' && argc % 2 == 0)) {
    fprintf(stderr, "usage: ren-mv [-n|-f] [src dst]...\n");
    return 2;
  }

  int flag_force = 0;
  char* p = argv[1];
  while (*++p) {
    switch (*p) {
    case 'n': flag_force = 0; break;
    case 'f': flag_force = 1; break;
    default:
      fprintf(stderr, "ren-mv: unrecognized option -%c\n", *p);
      return 2;
    }
  }

  int error_flag = 0;
  for (int i = 2; i < argc; i += 2) {
    char* src = argv[i];
    char* dst = argv[i + 1];

    struct stat st;
    if (stat(src, &st) != 0) {
      fprintf(stderr, "ren-mv (%s -> %s): the source file does not exist.\n", src, dst);
      continue;
    }

    if (stat(dst, &st) == 0) {
      if (flag_force) {
        fprintf(stderr, "ren-mv (%s -> %s): the destination path is overwritten.\n", src, dst);
      } else {
        fprintf(stderr, "ren-mv (%s -> %s): the destination path already exists.\n", src, dst);
        continue;
      }
    }

    int result = rename(src, dst);
    if (result != 0) {
      fprintf(stderr, "ren-mv: failed '%s' -> '%s'\n", src, dst);
      error_flag++;
      continue;
    }
  }

  if (error_flag) return 1;
  return EXIT_SUCCESS;
}
