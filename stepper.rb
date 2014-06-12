# encoding: utf-8
require_relative 'piece'

class Stepper < Piece
  
  
  def moves 
    @vectors.map do |vector|
      vector_add(@pos, vector)
    end.select { |pos| @board.empty_or_capture?(pos, @color) }
  end
end

class King < Stepper
  
  def initialize(pos, color, board, has_moved = false)
    super(pos, color, board)
    @vectors = VECTOR_DIAGO + VECTOR_ORTHO
  end
  
  def to_s
    return '♔' if @color == :white
    return '♚' if @color == :black
  end
  
  def moves
    if @has_moved
      super
    else
      super.concat([[pos[0]-2,pos[1]],[pos[0]+2,pos[1]]])
    end
  end
  
end

class Knight < Stepper
  VECTORS = [2,-2].product([1,-1]) + [1,-1].product([2,-2])
  
  def initialize(pos, color, board, has_moved = false)
    super(pos, color, board)
    @vectors = VECTORS
  end
  
  def to_s
    return '♘' if @color == :white
    return '♞' if @color == :black
  end
  
end