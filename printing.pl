printBoard([]).

printBoard([FirstRow|OtherRows]) :-
	printList(FirstRow),
	printBoard(OtherRows).

printList([]) :-
	nl.

printList([First|Others]) :-
	write('[ '),
	
	(
		(
			First is 0,
			write(' ')
		);
		
		(
			First is 4,
			write('X')
		);
		
		(
			First is 5,
			write('Y')
		);
		
		(
			not(First is 0),
			not(First is 4),
			not(First is 5),
			
			write(First)
		)
	),
	
	write(' ]'),
	printList(Others).
	