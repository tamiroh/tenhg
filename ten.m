:- module ten.
:- interface.

:- import_module io.

:- pred main(io::di, io::uo) is det.

:- implementation.

:- import_module expression.
:- import_module int.
:- import_module list.
:- import_module rational.
:- import_module solutions.
:- import_module string.

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
    evaluate(Expression, Value),
    Value = rational(10).
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
