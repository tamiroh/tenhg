:- module expression.
:- interface.

:- import_module rational.

:- type expression
    --->    digit(int)
    ;       add(expression, expression)
    ;       sub(expression, expression)
    ;       mul(expression, expression)
    ;       divide(expression, expression).

% Division by zero causes evaluation to fail.
:- pred evaluate(expression::in, rational::out) is semidet.
:- func format_expression(expression) = string.

:- implementation.

:- import_module string.

% Evaluate an expression to an exact rational value; division by zero fails.
evaluate(digit(Value), rational(Value)).
evaluate(add(Left, Right), L + R) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(sub(Left, Right), L - R) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(mul(Left, Right), L * R) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(divide(Left, Right), Result) :-
    evaluate(Left, L),
    evaluate(Right, R),
    R \= rational.zero,
    Result = L / R.

format_expression(digit(Value)) = string.int_to_string(Value).
format_expression(add(Left, Right)) = format_binary(Left, "+", Right).
format_expression(sub(Left, Right)) = format_binary(Left, "-", Right).
format_expression(mul(Left, Right)) = format_binary(Left, "*", Right).
format_expression(divide(Left, Right)) = format_binary(Left, "/", Right).

:- func format_binary(expression, string, expression) = string.

format_binary(Left, Operator, Right) =
    "(" ++ format_expression(Left) ++ " " ++ Operator ++ " " ++
    format_expression(Right) ++ ")".
