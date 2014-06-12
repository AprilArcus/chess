#! /usr/bin/env ruby

require "gosu"
require_relative "chess"

# http://ixian.com/chess/jin-piece-sets/

class GUIChess < Gosu::Window
  
  def initialize(width, height, fullscreen)
    super
    @game = Chess.new
    @background =   Gosu::Image.new(self, './assets/background.png',   false)
    @white_king =   Gosu::Image.new(self, './assets/white_king.png',   false)
    @white_queen =  Gosu::Image.new(self, './assets/white_queen.png',  false)
    @white_bishop = Gosu::Image.new(self, './assets/white_bishop.png', false)
    @white_knight = Gosu::Image.new(self, './assets/white_knight.png', false)
    @white_rook =   Gosu::Image.new(self, './assets/white_rook.png',   false)
    @white_pawn =   Gosu::Image.new(self, './assets/white_pawn.png',   false)
    @black_king =   Gosu::Image.new(self, './assets/black_king.png',   false)
    @black_queen =  Gosu::Image.new(self, './assets/black_queen.png',  false)
    @black_bishop = Gosu::Image.new(self, './assets/black_bishop.png', false)
    @black_knight = Gosu::Image.new(self, './assets/black_knight.png', false)
    @black_rook =   Gosu::Image.new(self, './assets/black_rook.png',   false)
    @black_pawn =   Gosu::Image.new(self, './assets/black_pawn.png',   false)
  end
    
  def draw
    @background.draw(0, 0, 0)
    @white_king.draw(*coords_to_pixels(@game.board.white_king.pos), 1)
    @game.board.white_queens.each { |queen| @white_queen.draw(*coords_to_pixels(queen.pos), 1) }
    @game.board.white_bishops.each { |bishop| @white_bishop.draw(*coords_to_pixels(bishop.pos), 1) }
    @game.board.white_knights.each { |knight| @white_knight.draw(*coords_to_pixels(knight.pos), 1) }
    @game.board.white_rooks.each { |rook| @white_rook.draw(*coords_to_pixels(rook.pos), 1) }
    @game.board.white_pawns.each { |pawn| @white_pawn.draw(*coords_to_pixels(pawn.pos), 1) }
    @black_king.draw(*coords_to_pixels(@game.board.black_king.pos), 1)
    @game.board.black_queens.each { |queen| @black_queen.draw(*coords_to_pixels(queen.pos), 1) }
    @game.board.black_bishops.each { |bishop| @black_bishop.draw(*coords_to_pixels(bishop.pos), 1) }
    @game.board.black_knights.each { |knight| @black_knight.draw(*coords_to_pixels(knight.pos), 1) }
    @game.board.black_rooks.each { |rook| @black_rook.draw(*coords_to_pixels(rook.pos), 1) }
    @game.board.black_pawns.each { |pawn| @black_pawn.draw(*coords_to_pixels(pawn.pos), 1) }
  end
  
  def needs_cursor?
    true
  end
  
  def coords_to_pixels(pos)
    x, y = pos
    [x * 80, 560+(-y * 80)]
  end
  
  def pixels_to_coords(pixel)
    x, y = pixel
    [(x/80).to_i, ((640-y)/80).to_i]
  end
  
  def update
      # exit if over?
  end
  
  def button_down(id)
    @start_pos = get_mouse_grid
  end
  
  def button_up(id)
    end_pos = get_mouse_grid
    begin
      @game.GUIplay(@start_pos, end_pos)
    rescue GameError 
    end
  end
  
  def get_mouse_grid
    mouse = [mouse_x, mouse_y]
    pos = pixels_to_coords(mouse)
  end
  
end


class Chess
  def GUIplay(start_pos, end_pos)
    piece = @board[start_pos]
 
    raise GameError.new("No piece there") if piece.nil?
    validate_moving_piece(piece) # raise an exception if we pick the wrong piece
    validate_destination(piece, end_pos)
    
    @board.move(piece, end_pos)
    change_players
  end
end



if __FILE__ == $PROGRAM_NAME
  GUIChessInstance = GUIChess.new(640, 640, false)
  GUIChessInstance.show
end