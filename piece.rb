class Piece
  VECTOR_DIAGO = [1,-1].product([-1,1])
  VECTOR_ORTHO = [[1, 0], [0, 1], [-1, 0], [0, -1]]
  
  def initialize(pos, color, board, has_moved = false)
    @pos = pos
    @color = color
    @board = board
    @has_moved = has_moved
  end
  
  attr_accessor :board, :has_moved, :pos
  attr_reader :color
  alias_method :has_moved?, :has_moved

  def vector_add(pos, vector)
    [ pos[0] + vector[0], pos[1] + vector[1] ]
  end
  
  def valid_moves
    moves.reject { |move| @board.move_into_check?(self.pos, move) }
  end
  
  def dup(board)
    self.class.new(@pos.dup, @color, board, @has_moved)
  end
  
end