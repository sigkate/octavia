/**
 * Octavia directory descriptor and related types.
 */


#ifndef DESCRIPTOR_H
#define DESCRIPTOR_H

#include "octavia.h"
#include "util.h"


/**
 * A size (in bytes) and a hash describe a file segment.
 *
 * Can be the head of a list (next).
 */
typedef struct Segment {
      uint16_t size;
      uint8_t hash [HashSize];
      struct Segment * next;
} Segment;

/**
 * Create a new Segment.
 */
dynamic Segment * new_segment(uint16_t size, uint8_t hash [HashSize], Segment * next);


/**
 * Files can be one of two types: regular file (byte stream) or directory
 * descriptor. Perhaps someday we will support more types (e.g. symbolic
 * links, dynamic descriptor services, et c.).
 */
typedef enum {
      File = 0,
      Directory = 1
} FileType;


/**
 * A description of a file.
 *
 * Can be the head of a list (next).
 */
typedef struct Description {
      FileType type;
      char * name;
      uint64_t size;
      int64_t mtime;
      Segment * segments;
      struct Description * next;
} Description;

/**
 * Create a new Description.
 */
dynamic Description * new_description(FileType type, const char * name, uint64_t size,
                                      int64_t mtime, Segment * segments, Description * next);


/**
 * Generic enough to describe any kind of service endpoint: server, proxy,
 * cluster, broadcast domain, multicast domain, et c.
 *
 * For now, we support (hostname, port) and (IPv4, port) tuples with netmask
 * = /32. Expect to at least support IPv6 and broadcast domains (e.g.
 * 10.1.2.0/24), and probably more.
 *
 * Can be the head of a list (next).
 */
typedef struct Endpoint {
      uint16_t port;
      // TODO: We don't actually support netmask in the parser or serializer
      // yet. But we will... oh, we *will*. Until then, it's /32 or /128.
      uint16_t netmask;
      char name [HostnameSize + 1];
      struct Endpoint * next;
} Endpoint;

/**
 * Create a new Endpoint.
 */
dynamic Endpoint * new_endpoint(uint16_t port, uint16_t netmask,
                                const char name [HostnameSize], Endpoint * next);


/**
 * Describes this version of the descriptor: mtime and a descriptive
 * bareword (usually hostname of the host that created this descriptor).
 */
typedef struct {
      char * name;
      int64_t mtime;
} Version;


/**
 * A complete directory descriptor.
 *
 * Can be the head of a list (next).
 */
typedef struct Descriptor {
      uint8_t protocol_version;
      uint8_t encryption_key [KeySize];
      Endpoint * endpoints;
      Description * descriptions;
      Version version;
      struct Descriptor * next;
} Descriptor;

/**
 * Create a new Descriptor.
 */
// XXX And we need descriptor version here too!
dynamic Descriptor * new_descriptor(uint8_t protocol_version,
                                    uint8_t encryption_key [KeySize],
                                    Endpoint * endpoints, Description * descriptions,
                                    Version version, Descriptor * next);


/**
 * Given the text of a descriptor, parses it and returns a live Descriptor
 * object. Parse failures are fatal errors, in which case this function will
 * not return.
 */
Descriptor * parse_descriptor(const char * expression);


/**
 * Writes the descriptor to a file (in the format that parse_descriptor
 * expects). Returns 0 on success, -1 on failure.
 */
int serialize_descriptor(const Descriptor * descriptor, FILE * file);


#endif

