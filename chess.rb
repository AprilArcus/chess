#! /usr/bin/env ruby

require_relative 'board'

class GameError < RuntimeError
end

class Chess
  def initialize 
    @board = Board.setup
    @count = 0
    @current_player = :white
  end
  
  attr_reader :board
  
  def play
    until @board.checkmate?(@current_player) || @board.stalemate?(@current_player)
      p @board
      play_turn
      change_players
    end
    if @board.checkmate?(current_player)
      puts "Checkmate! #{current_player} loses the game."
    else
      puts "Stalemate. The game is a draw."
    end
  end
  
  def change_players
    @count += 1
    @current_player = ((@current_player == :white) ? :black : :white)
  end
  
  def algebraic_to_cartesian(string)
    x = string[0].downcase.ord - 'a'.ord
    y = string[1].ord - '1'.ord
    [x,y]
  end
  
  def get_piece
    puts "Origin?"
    coords = algebraic_to_cartesian(gets.chomp)
    piece = @board[coords]
    validate_moving_piece(piece)
    piece
  end
  
  def validate_moving_piece(piece)
    raise GameError.new("No piece there!") if piece.nil? 
    raise GameError.new("That piece can't move :/") if piece.valid_moves.empty?
    raise GameError.new("Move your own piece!") unless piece.color == @current_player
  end
  
  def get_destination(piece)
    puts "Destination?"
    p @board
    dest = algebraic_to_cartesian(gets.chomp)
    validate_destination(piece, dest)
    dest
  end
  
  def validate_destination(piece, dest)
    raise GameError.new ("That piece doesn't move that way") unless piece.moves.include?(dest)
    raise GameError.new ("Can't move into check") unless piece.valid_moves.include?(dest)
  end
  
  def play_turn
    puts "Turn #{@count}, #{@current_player} to move"
    begin
      piece = get_piece
    rescue GameError => error
      puts error
      retry
    end
    begin
      dest = get_destination(piece)
    rescue GameError => error
      puts error
      retry
    end
    @board.move(piece, dest)
  end
  
end

if __FILE__ == $PROGRAM_NAME
  Chess.new.play
end