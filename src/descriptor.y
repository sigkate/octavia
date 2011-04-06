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

%}

%union {
      int64_t i;
      char * s;
}

%token ProtocolVersionT EncryptionKeyT EndpointsT FileT DirectoryT VersionT
%token <i> IntegerValueT
%token <s> QuotedStringT BareWordT HostnameT

/*%type <i> integer_value */

%%

descriptor: protocol_version encryption_key endpoints descriptions version
      ;

protocol_version: ProtocolVersionT IntegerValueT
      ;

encryption_key: EncryptionKeyT BareWordT
      ;

endpoints: endpoint
      | endpoint endpoints  
      ;

endpoint: HostnameT ':' IntegerValueT
      ;

descriptions: description
      | description descriptions
      ;

description: description_type QuotedStringT IntegerValueT IntegerValueT segments
      ;

segments: segment
      | segment segments
      ;

segment: IntegerValueT BareWordT
      ;

description_type: FileT | DirectoryT
      ;

version: VersionT HostnameT IntegerValueT
      ;

%%

