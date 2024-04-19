male(john).
male(james).
male(bob).
male(tom).

female(anna).
female(lisa).
female(susan).
female(mary).

parent(john, james).
parent(john, lisa).
parent(anna, james).
parent(anna, lisa).
parent(james, bob).
parent(james, susan).
parent(lisa, mary).
parent(tom, mary).

father(X, Y) :-
    male(X),
    parent(X, Y).

mother(X, Y) :-
    female(X),
    parent(X, Y).


child(X, Y) :-
    parent(Y, X).


sibling(X, Y) :-
    parent(Z, X),
    parent(Z, Y),
    X \= Y.

brother(X, Y) :-
    male(X),
    sibling(X, Y).

sister(X, Y) :-
    female(X),
    sibling(X, Y).

grandparent(X, Y) :-
    parent(X, Z),
    parent(Z, Y).

grandfather(X, Y) :-
    male(X),
    grandparent(X, Y).

grandmother(X, Y) :-
    female(X),
    grandparent(X, Y).