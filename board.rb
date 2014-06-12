require_relative 'slider'
require_relative 'stepper'
require_relative 'pawn'

class Board
  
  def self.setup
    board = Board.new
    board.white_king =    King.new(  [4,0], :white, board)
    board.white_queens =  [Queen.new( [3,0], :white, board)]
    board.white_rooks =   [Rook.new(  [0,0], :white, board),
                           Rook.new(  [7,0], :white, board)]
    board.white_bishops = [Bishop.new([2,0], :white, board),
                           Bishop.new([5,0], :white, board)]
    board.white_knights = [Knight.new([1,0], :white, board),
                           Knight.new([6,0], :white, board)]
    board.white_pawns = (0...8).map { |file| Pawn.new([file, 1], :white, board) }
    board.black_king =    King.new(  [4,7], :black, board)
    board.black_queens =  [Queen.new( [3,7], :black, board)]
    board.black_rooks =   [Rook.new(  [0,7], :black, board),
                           Rook.new(  [7,7], :black, board)]
    board.black_bishops = [Bishop.new([2,7], :black, board),
                           Bishop.new([5,7], :black, board)]
    board.black_knights = [Knight.new([1,7], :black, board),
                           Knight.new([6,7], :black, board)]
    board.black_pawns = (0...8).map { |file| Pawn.new([file, 6], :black, board) }
    board.update_game_state
    board
  end
  
  attr_accessor :white_king,
                :white_queens,
                :white_rooks,
                :white_bishops,
                :white_knights,
                :white_pawns,
                :black_king,
                :black_queens,
                :black_rooks,
                :black_bishops,
                :black_knights,
                :black_pawns
  
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
          @white_pawns.delete(piece)
          @white_queens << Queen.new(end_pos, :white, self)
          update_game_state
        else
          @black_pawns.delete(piece)
          @black_queens << Queen.new(end_pos, :black, self)
          update_game_state
        end
      else #regular move
        move!(piece, end_pos)
      end
    end
  end
  
  def move!(piece, end_pos)
    captured_piece = self[end_pos] # could be nil
    @black_queens.delete(captured_piece)
    @black_bishops.delete(captured_piece)
    @black_knights.delete(captured_piece)
    @black_rooks.delete(captured_piece)
    @black_pawns.delete(captured_piece)
    @white_queens.delete(captured_piece)
    @white_bishops.delete(captured_piece)
    @white_knights.delete(captured_piece)
    @white_rooks.delete(captured_piece)
    @white_pawns.delete(captured_piece)
    piece.pos = end_pos
    piece.has_moved = true # useful for pawns & castling;
    update_game_state      # but implemented by all pieces
    self # allow chaining
  end
  
  def move_into_check?(start_pos, end_pos)
    board_dup = self.dup
    dup_piece = board_dup[start_pos]
    board_dup.move!(dup_piece, end_pos).in_check?(dup_piece.color)
  end
  
  def dup
    duped_board = self.class.new
    duped_board.white_king = @white_king.dup(duped_board)
    duped_board.white_queens = @white_queens.map { |piece| piece.dup(duped_board) }
    duped_board.white_bishops = @white_bishops.map { |piece| piece.dup(duped_board) }
    duped_board.white_knights = @white_knights.map { |piece| piece.dup(duped_board) }
    duped_board.white_rooks = @white_rooks.map { |piece| piece.dup(duped_board) }
    duped_board.white_pawns = @white_pawns.map { |piece| piece.dup(duped_board) }
    duped_board.black_king = @black_king.dup(duped_board)
    duped_board.black_queens = @black_queens.map { |piece| piece.dup(duped_board) }
    duped_board.black_bishops = @black_bishops.map { |piece| piece.dup(duped_board) }
    duped_board.black_knights = @black_knights.map { |piece| piece.dup(duped_board) }
    duped_board.black_rooks = @black_rooks.map { |piece| piece.dup(duped_board) }
    duped_board.black_pawns = @black_pawns.map { |piece| piece.dup(duped_board) }
    duped_board.update_game_state
    duped_board
  end
  
  def update_game_state
    gather_armies
    generate_positions_hash
  end
  
  def gather_armies
    @white_army = [@white_king].concat(@white_queens).concat(@white_rooks).
                                concat(@white_bishops).concat(@white_knights).
                                concat(@white_pawns)
    @black_army = [@black_king].concat(@black_queens).concat(@black_rooks).
                                concat(@black_bishops).concat(@black_knights).
                                concat(@black_pawns)
  end

  def generate_positions_hash
    @positions_hash = {}
    @white_army.each { |piece| @positions_hash[piece.pos] = piece }
    @black_army.each { |piece| @positions_hash[piece.pos] = piece }
  end  
  
end