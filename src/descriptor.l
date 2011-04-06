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
      return ProtocolVersionT;
}

encryption-key {
      return EncryptionKeyT;
}

endpoints {
      return EndpointsT;
}

f {
      return FileT;
}

d {
      return DirectoryT;
}

version {
      return VersionT;
}

{quoted_string} {
      yylval.s = strdup(yytext + 1);

      if ('"' != yylval.s[yyleng - 2])
            logger(Error, "Unterminated quoted string '%s'", yytext);
      else
            yylval.s[yyleng - 2] = '\0';

      return QuotedStringT;
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
            logger(Error, "Invalid integer literal '%s'", yytext);
            yylval.i = 0;
            return 0;
      }

      yylval.i = (int64_t) i;

      return IntegerValueT;
}

[A-Za-z_0-9\.]+ {
      yylval.s = strdup(yytext);
      return BareWordT;
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

      Version v = { "XXX TODO", 0 };
      result = new_descriptor(0, Null, Null, Null, v, Null);

      YY_BUFFER_STATE st = yy_scan_string(expression);

      yyparse();
      yy_delete_buffer(st);

      errno = 0;
      return result;
}

