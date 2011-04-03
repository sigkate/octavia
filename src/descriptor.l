/**
 * Grammar for Octavia directory descriptors.
 */

%{
#include <inttypes.h>
#include <errno.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "y.tab.h"
#include "descriptor.h"
#include "util.h"


/*
 * This crap shuts the compiler up.
 */
int yyparse(void);

extern Descriptor * result;

%}

space [ \t]+
quoted_string \"[^\"\n]*[\"\n]
nl \n

%%

{space} ;

protocol-version {
      return ProtocolVersion;
}

encryption-key {
      return EncryptionKey;
}

endpoints {
      return Endpoints;
}

f {
      return File;
}

d {
      return Directory;
}

version {
      return Version;
}

{quoted_string} {
      yylval.s = strdup(yytext + 1);

      if ('"' != yylval.s[yyleng - 2])
            logger(Error, "Unterminated quoted string '%s'", yytext);
      else
            yylval.s[yyleng - 2] = '\0';

      return QuotedString;
}

[A-Fa-f0-9]{1,16} {
      char * end;
      uintmax_t i = strtoumax(yytext, &end, 0);

      /*
       * strtoumax can fail on ERANGE or (on some platforms) EINVAL.
       * Checking for any errno at all is a fail-safe. (Probably
       * unnecessary, but I don't think wrong.)
       *
       * Additionally, assert that the entire yytext was valid.
       */
      if (errno || i > SIZE_MAX || '\0' != *end) {
            logger(Error, "Invalid integer value '%s'", yytext);
            yylval.i = 0;
            return 0;
      }

      yylval.i = (int64_t) i;

      return IntegerValue;
}

[A-Za-z_0-9\.]+ {
      yylval.s = strdup(yytext);
      return BareWord;
}

\n  |
.  {
      return yytext[0];
}

%%

Descriptor * parse_descriptor(const char * expression) {
      if (! expression || ! *expression) {
            errno = EINVAL;
            return 0;
      }

      result = new_descriptor(0, Null, Null, Null, Null);

      YY_BUFFER_STATE st = yy_scan_string(expression);

      yyparse();
      yy_delete_buffer(st);

      errno = 0;
      return result;
}

