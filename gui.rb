#! /usr/bin/env ruby

require "gosu"
require_relative "chess"

# http://ixian.com/chess/jin-piece-sets/

class GUIChess < Gosu::Window
  
  def initialize
    super(640, 640, true)
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

  def coords_to_pixels(pos)
    x, y = pos
    [x * 80, 640-((y+1) * 80)]
  end
  
  def pixels_to_coords(pixel)
    x, y = pixel
    [(x/80).to_i, ((640-y)/80).to_i]
  end
    
  def draw
    @background.draw(0, 0, 0)
    @game.board.pieces.each do |piece|
      sym = ('@'+piece.color.to_s+'_'+piece.class.to_s.downcase).to_sym
      image = self.instance_variable_get(sym)
      x, y = coords_to_pixels(piece.pos)
      image.draw(x, y, 1)
    end
  end
  
  def needs_cursor?
    true
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
    pixels_to_coords([mouse_x, mouse_y])
  end
  
end

class Chess
  def GUIplay(start_pos, end_pos)
    piece = @board[start_pos]
 
    validate_moving_piece(piece)
    validate_destination(piece, end_pos)
    
    @board.move(piece, end_pos)
    change_players
  end
end

if __FILE__ == $PROGRAM_NAME
  GUIChess.new.show
end