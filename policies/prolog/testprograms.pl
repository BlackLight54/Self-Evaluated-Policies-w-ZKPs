% Sample knowledge base
parent(anne, bob).
parent(bob, carol).
ancestor(X, Y) :- parent(X, Y).
ancestor(X, Y) :- parent(X, Z), ancestor(Z, Y).


% Sum of a list
sum([], 0).
sum([H|T], S) :-
    sum(T, S1),
    S is H + S1.

% Sample for findall usinng dogs 
dog(fido).
dog(rover).

findall_dogs(List) :- findall(X, dog(X), List).
