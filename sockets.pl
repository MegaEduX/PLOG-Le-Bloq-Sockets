:-use_module(library(sockets)).

port(60001).

server:-
	port(Port),
	socket_server_open(Port,Socket),
	socket_server_accept(Socket, _Client, Stream, [type(text)]),
	server_loop(Stream),
	socket_server_close(Socket),
	write('Server Exit'),nl.

server_loop(Stream) :-
	repeat,
		read(Stream, ClientRequest),
		write('Received: '), write(ClientRequest), nl, 
		%server_input(ClientRequest, ServerReply),
		format(Stream, '~q.~n', [ServerReply]),
		write('Send: '), write(ServerReply), nl, 
		flush_output(Stream),
	(ClientRequest == bye; ClientRequest == end_of_file), !.

server_input(initialize(BoardSizeX, BoardSizeY), ok(Board)):- 
	createBoard(BoardSizeX, BoardSizeY, Board), 
	!.

server_input(validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY), ok(ScoredBoard)) :-
	validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	!.

server_input(validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard), fail) :-
	!.

server_input(validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard), ok(ScoredBoard)) :-
	validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	!.

server_input(validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard), fail) :-
	!.

server_input(checkGameOver(Board, BoardSizeX, BoardSizeY), winner(Winner)) :-		%	Missing Winner
	checkForAvailableTurns(Board, BoardSizeX, BoardSizeY),
	!.

server_input(checkGameOver(Board, BoardSizeX, BoardSizeY), false) :-
	!.

/*server_input(execute(Mov, Board), ok(NewBoard)):- 
	valid_move(Mov, Board),
	execute_move(Mov, Board, NewBoard), !.
server_input(calculate(Level, J, Board), ok(Mov, NewBoard)):- 
	calculate_move(Level, J, Board, Mov),
	execute_move(Mov, Board, NewBoard), !.
server_input(game_end(Board), ok(Winner)):- 
	end_game(Board, Winner), !.*/

server_input(bye, ok) :-
	!.

server_input(end_of_file, ok) :-
	!.

server_input(_, invalid) :-
	!.