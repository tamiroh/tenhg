:- module ten.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module int.
:- import_module list.
:- import_module solutions.
:- import_module string.

% A rational value and the expression that produced it.
:- type expression ---> expression(int, int, string).

main(!IO) :-
    io.command_line_arguments(Args, !IO),
    ( if
        Args = [_, _, _, _],
        list.map(parse_digit, Args, Expressions)
    then
        solutions(solve(Expressions), Answers),
        (
            Answers = [Answer | _],
            io.format("%s = 10\n", [s(Answer)], !IO)
        ;
            Answers = [],
            io.write_string("No solution.\n", !IO)
        )
    else
        io.write_string("Usage: ten DIGIT DIGIT DIGIT DIGIT (each 0-9)\n", !IO),
        io.set_exit_status(1, !IO)
    ).

:- pred parse_digit(string::in, expression::out) is semidet.

parse_digit(Text, expression(Value, 1, string.int_to_string(Value))) :-
    string.to_int(Text, Value),
    Value >= 0,
    Value =< 9.

% Pick any two values, combine them, and repeat until only 10 remains.
:- pred solve(list(expression)::in, string::out) is nondet.

solve([expression(N, D, Text)], Text) :-
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

combine(expression(A, B, Left), expression(C, D, Right),
        expression(N, Denominator, Text)) :-
    (
        N = A * D + C * B,
        Denominator = B * D,
        Operator = "+"
    ;
        N = A * D - C * B,
        Denominator = B * D,
        Operator = "-"
    ;
        N = A * C,
        Denominator = B * D,
        Operator = "*"
    ;
        C \= 0,
        N = A * D,
        Denominator = B * C,
        Operator = "/"
    ),
    Text = "(" ++ Left ++ " " ++ Operator ++ " " ++ Right ++ ")".
