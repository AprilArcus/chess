# encoding: utf-8
class Pawn < Piece
  
  def initialize(pos, color, board, has_moved = false)
    super
    if @color == :white
      @step_vector = [0, 1]
      @slide_vector = [0, 2]
      @attack_vectors = [[-1, 1], [1, 1]]
    else
      @step_vector = [0, -1]
      @slide_vector = [0, -2]
      @attack_vectors = [[-1, -1], [1, -1]]
    end 
  end
  
  def moves
    moves = []
    step_pos = vector_add(@pos, @step_vector)
    if @board.on_board?(step_pos) && @board[step_pos].nil?
      moves << step_pos
      slide_pos = vector_add(@pos, @slide_vector)
      if @has_moved == false && @board.on_board?(slide_pos) && @board[slide_pos].nil?
        moves << slide_pos
      end
    end
    @attack_vectors.each do |attack_vector|
      attack_pos = vector_add(@pos, attack_vector)
      if (@board.on_board?(attack_pos) &&
          @board[attack_pos].nil? == false &&
          @board[attack_pos].color != @color)
        moves << attack_pos
      end
    end
    moves
  end
  
  def to_s
    return '♙' if @color == :white
    return '♟' if @color == :black
  end
  
end
