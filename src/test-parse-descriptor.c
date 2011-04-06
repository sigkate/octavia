#include <sys/stat.h>

#include <err.h>
#include <stdio.h>

#include "descriptor.h"
#include "util.h"


dynamic char * get_data(const char * pathname) {
      struct stat stt;

      if (stat(pathname, &stt))
            err(1, "%s", pathname);

      char * data = allocate(stt.st_size, 1);

      FILE * fl = fopen(pathname, "r");
      (void) fread(data, 1, stt.st_size, fl);
      fclose(fl);
      return data;
}


int main(int count, char * arguments []) {
      for (int i = 1; i < count; i++) {
            char * data = get_data(arguments[i]);

            Descriptor * d = parse_descriptor(data);
            printf("%p\n", d);
            serialize_descriptor(d, stdout);

            free(data);
            free(d);
      }

      return 0;
}

