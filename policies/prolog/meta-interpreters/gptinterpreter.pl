% Handling the false predicate
solve(fail, _, _) :- !, fail.

% Base cases for the interpreter.
solve(true, _, []):- !.



% Handling built-in functions
% Handling findall
solve(findall(Var, Pred, List), N, Trace) :-
    findall((Var, TraceElement), solve_with_trace(Pred, Var, N, TraceElement), Results),
    extract_elements(Results, List, IndividualTraces),
    flatten(IndividualTraces, FlattenedTraces),
    length(FlattenedTraces, L),
    M is N + L,
    append(FlattenedTraces, [(M, findall(Var, Pred, List), [(Pred, List)], [(Var, List)])], Trace).
% Helper predicate to perform solve with trace for findall
solve_with_trace(Pred, Var, N, [(N, Pred, Unification, [(Var, Value)]) | Trace]) :-
    M is N + 1,
    solve(Pred, M, Trace),
    Unification = [(Pred, Var)],
    Var = Value.
% Helper predicate to extract elements and their respective traces
extract_elements([], [], []).
extract_elements([(Elem, Trace) | RestElems], [Elem | RestList], [Trace | RestTraces]) :-
    extract_elements(RestElems, RestList, RestTraces).

% Handling arithmetic operations

% is 
% Case when RHS is instantiated, compute and unify with LHS
solve(Expr1 is Expr2, N, [(N, Expr1 is Expr2, [], [(Expr1, Result)]) | Trace]) :-
    ground(Expr2),
    Result is Expr2,
    Expr1 = Result,
    M is N + 1,
    !,solve(true, M, Trace).
% Case when both LHS and RHS are variables, unify them
solve(Expr1 is Expr2, N, [(N, Left > Right) | Trace]) :-
    var(Expr1), var(Expr2),
    Expr1 = Expr2,
    M is N + 1,
    !,solve(true, M, Trace).
% Case when only LHS is instantiated (and not RHS). 
% We can't reverse compute RHS in general Prolog, so we'll delay or fail.
% Here, I'm choosing to unify them.
solve(Expr1 is Expr2, N, [(N, Left > Right) | Trace]) :-
    ground(Expr1), var(Expr2),
    Expr1 = Expr2,
    M is N + 1,
    !,solve(true, M, Trace).

% >
% Handle the > predicate when both arguments are ground.
solve(Left > Right, N, [(N, Left > Right) | Trace]) :-
    ground(Left), ground(Right),
    Left > Right,
    M is N + 1,
    !,solve(true, M, Trace).
% Handle the > predicate when both arguments are ground but the comparison is false.
solve(Left > Right, N, [(N, Left > Right, false) | Trace]) :-
    ground(Left), ground(Right),
    \+ (Left > Right),!,  % This ensures that the comparison is false
    M is N + 1,
    write(fail), nl,
    write(Left), write(' is not greater than '), write(Right), nl,
    solve(fail, M, Trace).  % You can decide what to do next; here I'm just causing it to fail.
% Delay the evaluation of > until both arguments are ground.
solve(Left > Right, N, [(N, Left > Right) | Trace]) :-
    when((ground(Left), ground(Right)), Left > Right),
    M is N + 1,
    !,solve(true, M, Trace).

% Handle the = predicate when both arguments are unifiable
solve(Left = Right, N, [(N, Left = Right, true) | Trace]) :-
    unify_with_occurs_check(Left, Right),  % Ensures that the unification is possible
    M is N + 1,
    !,solve(true, M, Trace).

% Handle cuts
solve(!, N, [(N, !)]) :- !.

% Handle disjunctions
solve((Goal1 ; _), N, Trace) :-
    !,solve(Goal1, N, Trace).
solve((_; Goal2), N, Trace) :-
    solve(Goal2, N, Trace).
solve((A, B), N, Trace) :-
    solve(A, N, TraceA),
    length(TraceA, L),
    M is N + L, 
    solve(B, M, TraceB),
    append(TraceA, TraceB, Trace).
% General case to process a clause from the knowledge base.
solve(Goal, N, [(N, Goal, Unification, Substitution) | Trace]) :-
    Goal \= (_ > _),  % Exclude the '>' predicates
    Goal \= (_ is _),  % Exclude the 'is' predicates
    Goal \= (_ = _),  % Exclude the '=' predicates
    Goal \= (_ ; _),  % Exclude the ';' predicates
    Goal \= (!),  % Exclude the '!' predicates
    Goal \= (findall(_, _, _)),  % Exclude the 'findall' predicates
    Goal \= (fail),  % Exclude the 'fail' predicates
    Goal \= (true),  % Exclude the 'true' predicates
    clause(Goal, Body),
    copy_term((Goal, Body), (NewGoal, NewBody)),
    NewGoal = Goal,
    unification_trace(Body, NewBody, Unification),
    M is N + 1,
    solve(NewBody, M, Trace),
    findall((Var, Value), (member(Var, Goal), Var = Value), Substitution).




unification_trace(A, B, []) :- var(A), var(B), !.
unification_trace((A, C), (B, D), [(A, B), (C, D)]) :- !.
unification_trace(A, B, [(A, B)]).

% Print the trace to the console.
trace(Goal) :-
    solve(Goal, 1, Trace),
    write_trace(Trace).

write_trace([]) :-
    write('End of trace.'), nl.

write_trace([(N, Goal, Unification, Substitution) | Rest]) :-
    format("Step ~w:\n", [N]),
    write('Goal: '), write(Goal), nl,
    write('Unification: '), nl,
    write_unifications(Unification),
    write('Substitutions: '), nl,
    write_substitutions(Substitution),
    nl,
    write_trace(Rest).

write_unifications([]).
write_unifications([(Original1, Unified1), (Original2, Unified2) | Rest]) :-
    write('Original: '), write(Original1), write(','), write(Original2), nl,
    write('Becomes: '), write(Unified1), write(','), write(Unified2), nl,
    write_unifications(Rest).
write_unifications([(Original, Unified) | Rest]) :-
    write('Original: '), write(Original), nl,
    write('Becomes: '), write(Unified), nl,
    write_unifications(Rest).

write_substitutions([]).
write_substitutions([(Var, Value) | Rest]) :-
    write(Var), write(' = '), write(Value), nl,
    write_substitutions(Rest).


:- include("./policy.pl").