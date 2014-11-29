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
		server_input(ClientRequest, ServerReply),
		format(Stream, '~q.~n', [ServerReply]),
		write('Send: '), write(ServerReply), nl, 
		flush_output(Stream),
	(ClientRequest == bye; ClientRequest == end_of_file), !.

server_input(initialize(BoardSizeX, BoardSizeY), ok(Board)) :- 
	createBoard(BoardSizeX, BoardSizeY, Board), 
	!.

server_input(initialize(BoardSizeX, BoardSizeY), fail) :-
	!.

server_input(playFT(Board, PieceType, PieceOrientation, PieceX, PieceY, ScoringPlayer, BoardSizeX, BoardSizeY), ok(ScoredBoard)) :-
	validateFirstTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	!.

server_input(playFT(Board, PieceType, PieceOrientation, PieceX, PieceY, ScoringPlayer, BoardSizeX, BoardSizeY), fail) :-
	!.

server_input(play(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard), ok(ScoredBoard)) :-
	validateTurn(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard),
	fillBoardWithScoring(NewBoard, BoardSizeX, BoardSizeY, 0, 0, ScoringPlayer, ScoredBoard),
	!.

server_input(play(Board, PieceType, PieceOrientation, PieceX, PieceY, NewBoard), fail) :-
	!.

server_input(checkWinner(Board, BoardSizeX, BoardSizeY), Winner) :-		%	Missing Winner
	checkForAvailableTurns(Board, BoardSizeX, BoardSizeY),
	checkForWinner(Board, BoardSizeX, BoardSizeY, 0, 0, 0, 0, Winner),
	!.

server_input(checkWinner(Board, BoardSizeX, BoardSizeY), 0) :-
	!.

server_input(bye, ok) :-
	!.

server_input(end_of_file, ok) :-
	!.

server_input(_, invalid) :-
	!.