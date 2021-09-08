require 'gosu'
require "mini_magick"
require "rubygems"
include Gosu

$dimension = 600
#consider opening the window this way
#next plan is to make a pixel clicked by the user turn white
#when the mouse clicks over it and the computer checks what the color value is
#if black change to white for now

#make seperate function for fill, and take in current color value as a parameter
#do nothing if that color is not the one to change color of
#otherwise change it's color to white

#for non-recursive fill make smaller Image
#then iterate through all the pixels and put into a list
#have fill function with hardcoded coordinates for the fill
#test

$image = MiniMagick::Image.open("smear.png")
$image.path #=> "/var/folders/k7/6zx6dx6x7ys3rv3srh0nyfj00000gn/T/magick20140921-75881-1yho3zc.jpg"
pixels = $image.get_pixels

count = 0
#0 for third array is red, 1 is green, 2 is blue
height = $image.height
width = $image.width
$i = 0
$j = 0
MiniMagick::Tool::Identify.new(whiny: false) do |b|
  b.help
end

module MiniMagick
  class Image
    def pixel_at(x, y)
      run_command("convert", "#{path}[1x1+#{x.to_i}+#{y.to_i}]", 'txt:').split("\n").each do |line|
        return $1 if /^0,0:.*(#[0-9a-fA-F]+)/.match(line)
      end
      nil
    end
  end
end

class GameWindow < Window

  def initialize
    super $dimension, $dimension, false
    self.caption = "Drawing board"
  	@background = Image.new("smear.png")
    @array = []
    #@click = true
  end
  def flood(x,y,color, parent_x, parent_y)
    p = $image.pixel_at(x,y)
    if p == "#000000FF"
      p = "#000000"
    end
    #puts "parent in recursion #{p}"
    if p == color
      #puts "color match #{p} and #{color}"
      $image.draw "fill #FFFFFF point #{x},#{y}"
      if !(x+1 == parent_x && y == parent_y)
        flood(x+1, y, color, x,y)
      end
      if !(x == parent_x && y+1 == parent_y)
        flood(x, y+1, color, x,y)
      end
      if !(x == parent_x && y-1 == parent_y)
        flood(x, y-1, color, x,y)
      end
      if !(x-1 == parent_x && y == parent_y)
        flood(x-1, y, color, x,y)
      end
    elsif p == "#FFFFFF"
      #puts"stopped early"
      return x,y
    end
  end

  def button_down(id)
    if (id == Gosu::MsLeft)
      puts "X: #{mouse_x}, Y: #{mouse_y}"
      p = $image.pixel_at(mouse_x, mouse_y)
      puts p
      if p == "#000000FF" || p == "000000"
        p = "#000000"
        puts "First parent color #{p}"
        flood(mouse_x, mouse_y, p, mouse_x, mouse_y)
        puts "finshed filling area"
        $image.write("work.png")
        @background = Image.new("work.png")
      end

    elsif (id == Gosu::MsRight)
      $image.write("clear.png")
      close
    end
  end
  def update
  end
  def draw
    @background.draw(0,0,0)
    #if @click == true then
      #$image.draw "fill white point #{mouse_x}, #{mouse_y}"
      #@click = false
    #end
  end
end

GameWindow.new.show
