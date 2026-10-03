:- module ten.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.
:- import_module list.
:- import_module solutions.
:- import_module string.

% Numerator and denominator; values produced below have nonzero denominators.
% Fractions are not necessarily reduced.
:- type rational ---> rational(int, int).

:- type expression
    --->    digit(int)
    ;       add(expression, expression)
    ;       sub(expression, expression)
    ;       mul(expression, expression)
    ;       divide(expression, expression).

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    ( if
        Args = [_, _, _, _],
        list.map(parse_digit, Args, Expressions)
    then
        solutions(solve(Expressions), Answers),
        (
            Answers = [Answer | _],
            io.format("%s = 10\n", [s(format_expression(Answer))], !IO)
        ;
            Answers = [],
            io.write_string("No solution.\n", !IO)
        )
    else
        io.write_string("Usage: ten DIGIT DIGIT DIGIT DIGIT (each 0-9)\n", !IO),
        io.set_exit_status(1, !IO)
    ).

:- pred parse_digit(string::in, expression::out) is semidet.

parse_digit(Text, digit(Value)) :-
    string.to_int(Text, Value),
    Value >= 0,
    Value =< 9.

% Build an expression tree, then check whether its value is 10.
:- pred solve(list(expression)::in, expression::out) is nondet.

solve([Expression], Expression) :-
    evaluate(Expression, rational(N, D)),
    N = 10 * D.
solve(Expressions, Answer) :-
    pick(Expressions, A, Rest),
    pick(Rest, B, Others),
    combine(A, B, Combined),
    solve([Combined | Others], Answer).

:- pred pick(list(T)::in, T::out, list(T)::out) is nondet.

pick([X | Xs], X, Xs).
pick([X | Xs], Y, [X | Rest]) :-
    pick(Xs, Y, Rest).

:- pred combine(expression::in, expression::in, expression::out) is multi.

combine(Left, Right, add(Left, Right)).
combine(Left, Right, sub(Left, Right)).
combine(Left, Right, mul(Left, Right)).
combine(Left, Right, divide(Left, Right)).

% Evaluate an expression to an exact rational value; division by zero fails.
:- pred evaluate(expression::in, rational::out) is semidet.

evaluate(digit(Value), rational(Value, 1)).
evaluate(add(Left, Right), rational_add(L, R)) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(sub(Left, Right), rational_sub(L, R)) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(mul(Left, Right), rational_mul(L, R)) :-
    evaluate(Left, L),
    evaluate(Right, R).
evaluate(divide(Left, Right), Result) :-
    evaluate(Left, L),
    evaluate(Right, R),
    rational_divide(L, R, Result).

:- func rational_add(rational, rational) = rational.

rational_add(rational(A, B), rational(C, D)) =
    rational(A * D + C * B, B * D).

:- func rational_sub(rational, rational) = rational.

rational_sub(rational(A, B), rational(C, D)) =
    rational(A * D - C * B, B * D).

:- func rational_mul(rational, rational) = rational.

rational_mul(rational(A, B), rational(C, D)) = rational(A * C, B * D).

:- pred rational_divide(rational::in, rational::in, rational::out) is semidet.

rational_divide(rational(A, B), rational(C, D), rational(A * D, B * C)) :-
    C \= 0.

:- func format_expression(expression) = string.

format_expression(digit(Value)) = string.int_to_string(Value).
format_expression(add(Left, Right)) = format_binary(Left, "+", Right).
format_expression(sub(Left, Right)) = format_binary(Left, "-", Right).
format_expression(mul(Left, Right)) = format_binary(Left, "*", Right).
format_expression(divide(Left, Right)) = format_binary(Left, "/", Right).

:- func format_binary(expression, string, expression) = string.

format_binary(Left, Operator, Right) =
    "(" ++ format_expression(Left) ++ " " ++ Operator ++ " " ++
    format_expression(Right) ++ ")".
