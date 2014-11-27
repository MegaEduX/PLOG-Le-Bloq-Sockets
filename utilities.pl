%
%	[Utilities] -> writeln
%

writeln(X) :-
	write(X),
	nl.

%
%	[Utilities] -> Read Integer
%

readInteger(ReturnValue) :-
	read(ReturnValue),
	integer(ReturnValue),
	
	!.

readInteger(ReturnValue) :-
	write('An integer was expected, not something else! Please retry'),
	readInteger(ReturnValue).

%
%	[Utilities] -> Read Yes / No
%

readYN(y).
readYN(n).

readYN(X) :- 
	read(X), 
	readYN(X), 
	
	!.

readYN(X) :- 
	write('You need to choose between "y" and "n". Please retry'),
	readYN(X).

%
%	[Utilities] -> Negation
%
%	Shamelessly stolen from "http://en.wikibooks.org/wiki/Prolog/Cuts_and_Negation" (Nov. 5th, 2014)
%

not(Goal) :- call(Goal), !, fail.
not(_).