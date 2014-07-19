#!/usr/bin/env ruby -I.

require 'constants'
require 'resources'
require 'grid'

module Minesweeper
  # Minesweeper game
  class Game < Gosu::Window
    include Constants

    attr_reader :images

    def initialize
      super( WIDTH, HEIGHT, false, 50 )
      self.caption = 'Gosu Minesweeper'

      load_resources

      @grid = Grid.new
    end

    def needs_cursor?
      true
    end

    def update
      update_position if @position
    end

    def draw
      draw_background
      draw_grid
    end

    def button_down( code )
      close if code == Gosu::KbEscape   # DEBUG

      if button_down?( Gosu::MsLeft ) && button_down?( Gosu::MsRight )
        return puts 'Both Both'
      end

      @position = Position.new( mouse_x, mouse_y, :mark ) if code == Gosu::MsRight
    end

    # Left Mouse Button is detected on release to avoid it being triggered
    # accidentally on a bombed square.
    def button_up( code )
      return unless code == Gosu::MsLeft && !button_down?( Gosu::MsRight )

      @position = Position.new( mouse_x, mouse_y, :open )
    end

    private

    def load_resources
      loader = ResourceLoader.new( self )

      @images = loader.images
      @fonts  = loader.fonts

      Block.setup_graphics( self, @images, @fonts )
    end

    def update_position
      @grid.send( @position.op, @position.point )

      @position = nil
    end

    def draw_background
      point = Point.new( 0, 0 )
      size  = Size.new( WIDTH, HEIGHT )
      draw_rectangle( point, size, 0, SILVER )

      point.move_to!( GRID_ORIGIN.x - 1, GRID_ORIGIN.y - 1 )
      draw_rectangle( point, GRID_SIZE.inflate( 2, 2 ), 0, Gosu::Color::BLACK )
    end

    def draw_grid
      @grid.draw
    end
  end

  # Hold the mouse position and the operation to perform
  class Position
    include GosuEnhanced

    attr_reader :point, :op

    def initialize( x, y, op )
      @point = Point.new( x, y )
      @op = op
    end
  end
end

Minesweeper::Game.new.show
