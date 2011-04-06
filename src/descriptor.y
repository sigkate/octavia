/**
 * Grammar for Octavia directory descriptors.
 */

%{
#include <stdint.h>
#include <stdio.h>

#include "descriptor.h"
#include "util.h"


void yyerror(char const * message) {
      logger(Error, "%s", message);
}

Descriptor * result;
Segment * current_segments;

%}

%union {
      int64_t i;
      char * s;
}

%token ProtocolVersionT EncryptionKeyT EndpointsT FileT DirectoryT VersionT
%token <i> IntegerValueT
%token <s> QuotedStringT BareWordT HostnameT

/*%type <i> integer_value */
%type <i> description_type

%%

descriptor: protocol_version encryption_key EndpointsT endpoints descriptions version
      {
      }
      ;

protocol_version: ProtocolVersionT IntegerValueT
      {
            if ($2 > 0xff || $2 < 0)
                  logger(Fatal, "Invalid protocol-version '%jx'", $2);

            result->protocol_version = $2;
      }
      ;

encryption_key: EncryptionKeyT BareWordT
      {
            if (strlen($2) != KeySize * 2)
                  logger(Fatal, "Invalid encryption-key '%s' \n", $2);

            for (size_t i = 0; i < KeySize; i++)
                  sscanf($2 + (i * 2), "%2x", result->encryption_key + i);
      }
      ;

endpoints: endpoint endpoints
      | endpoint
      {
      }
      ;

endpoint: BareWordT ':' IntegerValueT
      {

            Endpoint * e = new_endpoint($3, 32/*XXX*/, $1, Null);

            if (! result->endpoints)
                  result->endpoints = e;
            else {
                  Endpoint * tl = result->endpoints;
                  while (tl && tl->next)
                        tl = tl->next;
                  tl->next = e;
            }
      }
      ;

descriptions: description
      | description descriptions
      {
      }
      ;

description: description_type QuotedStringT IntegerValueT IntegerValueT segments
      {
            Description * d = new_description(FileT == $1 ? File : Directory,
                                              $2, $3, $4, current_segments, Null);

            if (! result->descriptions)
                  result->descriptions = d;
            else {
                  Description * tl = result->descriptions;
                  while (tl && tl->next)
                        tl = tl->next;
                  tl->next = d;
            }

            current_segments = Null;
      }
      ;

segments: segment
      | segment segments
      {
      }
      ;

segment: IntegerValueT BareWordT
      ;

description_type: FileT | DirectoryT
      ;

version: VersionT HostnameT IntegerValueT
      {
            result->version.name = format("%s", $2);
            result->version.mtime = $3;
      }
      ;

%%

