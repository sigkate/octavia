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

%token ProtocolVersion EncryptionKey Endpoints File Directory Version
%token <i> IntegerValue
%token <s> QuotedString BareWord Hostname

/*%type <i> integer_value */

%%

descriptor: protocol_version encryption_key endpoints descriptions version
      ;

protocol_version: ProtocolVersion IntegerValue
      ;

encryption_key: EncryptionKey BareWord
      ;

endpoints: endpoint
      | endpoint endpoints  
      ;

endpoint: Hostname ':' IntegerValue
      ;

descriptions: description
      | description descriptions
      ;

description: description_type QuotedString IntegerValue IntegerValue segments
      ;

segments: segment
      | segment segments
      ;

segment: IntegerValue BareWord
      ;

description_type: File | Directory
      ;

version: Version Hostname IntegerValue
      ;

%%

