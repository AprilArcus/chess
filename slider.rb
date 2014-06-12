# encoding: utf-8
require_relative 'piece'

class Slider < Piece

  def moves
    moves = []
    @vectors.each do |vector|
      moves += slide(vector)
    end
    moves
  end
  
  
  def slide(vector)
    moves = []
    pos = vector_add(@pos, vector)
    while @board.valid_move?(pos, @color)
      moves << pos
      break unless @board[pos].nil?
      pos = vector_add(pos, vector)
    end
    moves
  end

end

class Bishop < Slider

  def initialize(pos, color, board, has_moved = false)
    super
    @vectors = VECTOR_DIAGO
  end
  
  def to_s
    return '♗' if @color == :white
    return '♝' if @color == :black
  end

end

class Rook < Slider

  def initialize(pos, color, board, has_moved = false)
    super(pos, color, board)
    @vectors = VECTOR_ORTHO
  end
  
  def to_s
    return '♖' if @color == :white
    return '♜' if @color == :black
  end
  
end

class Queen < Slider
  
  def initialize(pos, color, board, has_moved = false)
    super(pos, color, board)
    @vectors = VECTOR_DIAGO + VECTOR_ORTHO
  end
  
  def to_s
    return '♕' if @color == :white
    return '♛' if @color == :black
  end
  
end