Definitions.

INT        = [0-9]+
NAME       = [a-zA-Z_]+
WHITESPACE = [\s\t\n\r]

Rules.

\.            : {token, {'.',  TokenLine}}.
\$            : {token, {'$',  TokenLine}}.
\(            : {token, {'(',  TokenLine}}.
\)            : {token, {')',  TokenLine}}.
,             : {token, {',',  TokenLine}}.
true          : {token, {boolean,  TokenLine, true}}.
false         : {token, {boolean,  TokenLine, false}}.
{INT}         : {token, {int,  TokenLine, TokenChars}}.
{NAME}        : {token, {name, TokenLine, TokenChars}}.
"([^"\\]*(\\.[^"\\]*)*)"|\'([^\'\\]*(\\.[^\'\\]*)*)\' : {token, {string, TokenLine, TokenChars}}.
{WHITESPACE}+ : skip_token.

Erlang code.

to_atom([$:|Chars]) ->
    list_to_atom(Chars).