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
    board.refresh_caches
    board
  end
  
  attr_accessor :pieces
  
  def [](pos)
    @positions_hash[pos]
  end

  def to_s
    output = "\n  a b c d e f g h\n"
    7.downto(0) do |rank|
      output += "#{rank + 1} "
      0.upto(7) do |file|
        piece = self[[file, rank]]
        output += "#{(piece.nil? ? ' ' : piece.to_s)} "
      end
      output += "\n"
    end
    output
  end

  def on_board?(pos)
    pos.all? { |coord| coord.between?(0,7) }
  end
  
  def valid_move?(pos, color)
    on_board?(pos) && (self[pos].nil? || self[pos].color != color)
  end

  def can_castle_kingside?(color)
    rank = (color == :white ? 0 : 7)
    (!in_check?(color) && !king(color).has_moved? &&
     self[[5,rank]].nil? && self[[6,rank]].nil? && # intervening squares empty
     !self[[7,rank]].nil? && !self[[7,rank]].has_moved? && # rook hasn't moved
     !move_into_check?([4,rank],[5,rank]) && # don't move through check
     !move_into_check?([4,rank],[6,rank]))   # don't move into check
  end
  
  def can_castle_queenside?(color)
    rank = (color == :white ? 0 : 7)
    (!in_check?(color) && !king(color).has_moved? &&
     self[[3,rank]].nil? && self[[2,rank]].nil? && self[[1,rank]].nil? &&
     !self[[0,rank]].nil? && !self[[0,rank]].has_moved? &&
     !move_into_check?([4,rank],[3,rank]) &&
     !move_into_check?([4,rank],[2,rank]))
  end

  def king(color)
    color == :white ? @white_king : @black_king
  end

  def army(color)
    color == :white ? @white_army : @black_army
  end

  def enemy_army(color)
    color == :white ? @black_army : @white_army
  end
  
  def in_check?(color)
    enemy_moves = enemy_army(color).reduce([]) do |moves, piece|
      moves += piece.moves
      moves
    end
    enemy_moves.include?(king(color).pos)
  end
  
  def any_moves?(color)
    army(color).map { |piece| piece.valid_moves.count }.reduce(:+) != 0
  end
  
  def checkmate?(color)
    in_check?(color) && !any_moves?(color)    
  end
  
  def stalemate?(color)
    !in_check?(color) && !any_moves?(color)
  end
  
  def move(piece, end_pos)
    fail 'invalid move' unless piece.moves.include?(end_pos)
    if piece.class == King && end_pos[0] == 6 && can_castle_kingside?(piece.color)
      rank = end_pos[1]
      move!(piece, end_pos)             # move king
      move!(self[[7, rank]], [5, rank]) # move rook
    elsif piece.class == King && end_pos[0] == 2 && can_castle_queenside?(piece.color)
      rank = end_pos[1]
      move!(piece, end_pos)             # move king
      move!(self[[0, rank]], [3, rank]) # move rook
    else
      if piece.class == Pawn && (piece.color == :white && end_pos[1] == 7 ||
                                 piece.color == :black && end_pos[1] == 0)
        promote(piece, end_pos)
      else
        move!(piece, end_pos)
      end
    end
  end

  def promote(piece, end_pos)
    @pieces.delete(piece)
    @pieces << Queen.new(end_pos, piece.color, self)
    refresh_caches
  end
  
  def move!(piece, end_pos)
    captured_piece = self[end_pos] # could be nil
    @pieces.delete(captured_piece)
    piece.pos = end_pos
    piece.has_moved = true
    refresh_caches
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
    board_dup.refresh_caches
    board_dup
  end
  
  def refresh_caches
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