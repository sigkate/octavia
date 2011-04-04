/**
 * Octavia directory descriptor and related types.
 */


#include "descriptor.h"


dynamic Segment * new_segment(uint16_t size, uint8_t hash [HashSize], Segment * next) {
      if (! size || ! hash)
            return Null;

      Segment * s = allocate(1, sizeof *s);

      s->size = size;
      memcpy(s->hash, hash, HashSize);
      s->next = Null;

      return s;
}


dynamic Description * new_description(FileType type, uint64_t size, int64_t mtime,
                                      Segment * segments, Description * next)
{
      Description * d = allocate(1, sizeof *d);

      d->type = type;
      d->size = size;
      d->mtime = mtime;
      d->segments = segments;
      d->next = next;

      return d;
}


dynamic Endpoint * new_endpoint(uint16_t port, uint16_t netmask,
                                const char name [HostnameSize], Endpoint * next)
{
      size_t lngth = strlen(name);
      if (! port || ! netmask || ! name || lngth > HostnameSize)
            return Null;

      Endpoint * e = allocate(1, sizeof *e);

      e->port = port;
      e->netmask = netmask;
      memcpy(e->name, name, lngth);
      e->next = next;

      return e;
}


dynamic Descriptor * new_descriptor(uint8_t protocol_version,
                                    uint8_t encryption_key [KeySize],
                                    Endpoint * endpoints, Description * descriptions,
                                    Version version, Descriptor * next)
{
      Descriptor * d = allocate(1, sizeof *d);

      d->protocol_version = protocol_version;
      if (encryption_key)
            memcpy(d->encryption_key, encryption_key, KeySize);
      d->endpoints = endpoints;
      d->descriptions = descriptions;
      d->next = next;

      return d;
}


int serialize_descriptor(const Descriptor * descriptor, FILE * file) {
      if (! descriptor || ! file)
            return -1;

      fprintf(file, "protocol-version %hhu\n", descriptor->protocol_version);

      fprintf(file, "encryption-key ");
      for (size_t i = 0; i < KeySize; i++)
            fprintf(file, "%02hhx", descriptor->encryption_key[i]);
      wprintf(file, "\n");

      fprintf(file, "endpoints ");
      Endpoint * e = descriptor->endpoints;
      while (e) {
            fprintf(file, "%s:%hu ", e->name, e->port);
            e = e->next;
      }
      fprintf(file, "\n");

      Description * d = descriptor->descriptions;
      while (d) {
            fprintf(file, "%c %llx %llx\n",
                    File == d->type ? 'f' : 'd', d->size, d->mtime);

            Segment * s = d->segments;
            while (s) {
                  fprintf(file, " %hu ", s->size);
                  for (size_t i = 0; i < HashSize; i++)
                        fprintf(file, "%02hhx", s->hash[i]);

                  fprintf(file, "\n");
                  s = s->next;
            }

            d = d->next;
      }

      fprintf(file, "version %s %llx\n",
              descriptor->version.name, descriptor->version.mtime);
}

