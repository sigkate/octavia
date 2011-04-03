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
                                    Descriptor * next)
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

