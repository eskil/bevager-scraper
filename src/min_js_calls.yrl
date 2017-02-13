Nonterminals
  call
  exprs
  expr
.

Terminals
  int
  name
  boolean
  '('
  ')'
  '$'
  '.'
  ','
  string
.

Rootsymbol call
.

call -> name '(' ')' : [{call, nil, unwrap('$1'), []}].
call -> name '(' exprs ')' : [{call, nil, unwrap('$1'), '$3'}].
call -> name '.' name '(' ')' : [{call, unwrap('$1'), unwrap('$3'), []}].
call -> name '.' name '(' exprs ')' : [{call, unwrap('$1'), unwrap('$3'), '$5'}].

expr -> int : unwrap('$1').
expr -> '$' name : {var, get_value('$2')}.
expr -> string : unwrap('$1').
expr -> boolean : unwrap('$1').
exprs -> expr : ['$1'].
exprs -> expr ',' exprs : ['$1'] ++ '$3'.

Erlang code.

get_value({_, _, Value}) -> Value.

%% When unwrapping, we drop the line number and convert "int" to
%% integers and for strings we remove the surrounding quotes.

unwrap({int, _line, Value}) -> {int, list_to_integer(Value)};
unwrap({string, _line, Value}) -> {string, lists:sublist(Value, 2, length(Value)-2)};
unwrap({Token, _line, Value}) -> {Token, Value}.

%% And if we don't care about typing, we could just do
% unwrap({Token, _line, Value}) -> Value.

% And of course if you're writing a better parser and want to inform
% about line numbers, remove decode entirely.
