require_relative 'slider'
require_relative 'stepper'
require_relative 'pawn'

class Board
  
  def self.setup
    board = Board.new
    board.pieces = [Rook.new(  [0,0], :white, board),
                    Knight.new([1,0], :white, board),
                    Bishop.new([2,0], :white, board),
                    Queen.new( [3,0], :white, board),
                    King.new(  [4,0], :white, board),
                    Bishop.new([5,0], :white, board),
                    Knight.new([6,0], :white, board),
                    Rook.new(  [7,0], :white, board),
                    Rook.new(  [0,7], :black, board),
                    Knight.new([1,7], :black, board),
                    Bishop.new([2,7], :black, board),
                    Bishop.new([5,7], :black, board),
                    Queen.new( [3,7], :black, board),
                    King.new(  [4,7], :black, board),
                    Rook.new(  [7,7], :black, board),
                    Knight.new([6,7], :black, board)].
                    concat((0...8).map { |file| Pawn.new([file, 1], :white, board) }).
                    concat((0...8).map { |file| Pawn.new([file, 6], :black, board) })
    board.generate_caches
    board
  end
  
  attr_accessor :pieces
  
  def [](pos)
    @positions_hash[pos]
  end
  
  def valid_move?(pos, color)
    on_board?(pos) && (self[pos].nil? || self[pos].color != color)
  end
  
  def on_board?(pos)
    pos.all? { |coord| coord.between?(0,7) }
  end
  
  def to_s
    output_array = Array.new(8) { Array.new(8) {' '} }
    (@white_army + @black_army).each do |piece|
      unless piece.pos.nil?
        x = piece.pos[0]
        y = piece.pos[1]
        output_array[y][x] = piece.to_s
      end
    end
    
    output = "\n  a b c d e f g h\n"
    7.downto(0) do |rank|
      output += "#{rank + 1} #{output_array[rank].join' '}\n"
    end
    output
  end
  
  def opponent_pieces(color)
    opponent_pieces = (color == :white ? @black_army : @white_army)
  end

  def can_castle_kingside?(color)
    rank = (color == :white ? 0 : 7)
    (!in_check?(color) && !self[[4,rank]].nil? && !self[[4,rank]].has_moved? &&
     self[[5,rank]].nil? && self[[6,rank]].nil? && !self[[7,rank]].nil? &&
     !self[[7,rank]].has_moved? && !move_into_check?([4,rank],[5,rank]) &&
     !move_into_check?([4,rank],[6,rank]))
  end
  
  def can_castle_queenside?(color)
    rank = (color == :white ? 0 : 7)
    (!in_check?(color) && !self[[4,rank]].nil? && !self[[4,rank]].has_moved? &&
     self[[3,rank]].nil? && self[[2,rank]].nil? && self[[1,rank]].nil? &&
     !self[[0,rank]].nil? && !self[[0,rank]].has_moved? &&
     !move_into_check?([4,rank],[3,rank]) &&
     !move_into_check?([4,rank],[2,rank]))
  end
  
  def in_check?(color)
    king_pos = (color == :white ? @white_king.pos : @black_king.pos)
    opponent_moves = opponent_pieces(color).reduce([]) do |moves, piece|
      moves += piece.moves
      moves
    end
    opponent_moves.include?(king_pos)
  end
  
  def any_moves?(color)
    if color == :white
      pieces = @white_army
    else
      pieces = @black_army
    end
    pieces.map { |piece| piece.valid_moves.count }.reduce(:+) != 0
  end
  
  def checkmate?(color)
    in_check?(color) && !any_moves?(color)    
  end
  
  def stalemate?(color)
    !in_check?(color) && !any_moves?(color)
  end
  
  def move(piece, end_pos)
    #castle kingside
    if piece.class == King && end_pos[0] == 6 && can_castle_kingside?(piece.color)
      move!(piece, end_pos) # move king
      move!(self[[7, end_pos[1]]], [5, end_pos[1]]) # move rook
    #castle kingside
    elsif piece.class == King && end_pos[0] == 2 && can_castle_queenside?(piece.color)
      move!(piece, end_pos) # move king
      move!(self[[0, end_pos[1]]], [3, end_pos[1]]) # move rook
    else
      # regular move
      fail 'invalid move' unless piece.moves.include?(end_pos)
      if piece.class == Pawn && (piece.color == :white && end_pos[1] == 7 ||
                                 piece.color == :black && end_pos[1] == 0)
        #promotion
        if piece.color == :white
          @pieces.delete(piece)
          @pieces << Queen.new(end_pos, :white, self)
          generate_caches
        else
          @pieces.delete(piece)
          @pieces << Queen.new(end_pos, :black, self)
          generate_caches
        end
      else #regular move
        move!(piece, end_pos)
      end
    end
  end
  
  def move!(piece, end_pos)
    captured_piece = self[end_pos] # could be nil
    @pieces.delete(captured_piece)
    piece.pos = end_pos
    piece.has_moved = true
    generate_caches
    self # allow chaining
  end
  
  def move_into_check?(start_pos, end_pos)
    board_dup = self.dup
    piece_dup = board_dup[start_pos]
    board_dup.move!(piece_dup, end_pos).in_check?(piece_dup.color)
  end
  
  def dup
    board_dup = self.class.new
    board_dup.pieces = pieces.map { |piece| piece.dup(board_dup) }
    board_dup.generate_caches
    board_dup
  end
  
  def generate_caches
    generate_handles
    generate_positions_hash
  end
  
  def generate_handles
    @white_army = @pieces.select { |piece| piece.color == :white }
    @black_army = @pieces.select { |piece| piece.color == :black }
    @white_king = @pieces.find { |piece| piece.color == :white && piece.class == King }
    @black_king = @pieces.find { |piece| piece.color == :black && piece.class == King }
  end

  def generate_positions_hash
    @positions_hash = @pieces.reduce({}) do |hash, piece|
      hash[piece.pos] = piece
      hash
    end
  end  
  
end