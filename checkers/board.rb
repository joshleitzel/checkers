require 'term/ansicolor'
include Term::ANSIColor

class Board
  attr_accessor :squares
  
  def initialize
    s = empty_board
    for b in 1..8
      for a in 1..3
        if (a + b) % 2 == 1
          s[[a,b]] = Square.new(CODE_RED)
        end
      end
      for a in 6..8
        if (a + b) % 2 == 1
          s[[a,b]] = Square.new(CODE_WHITE)
        end
      end
    end
    
    self.squares = s
  end
  
  def empty_board
    s = Hash.new
    for x in 1..8
      for y in 1..8
        s[[x,y]] = Square.new(CODE_EMPTY)
      end
    end
    s
  end
  
  def serial
    serial = {}
    for y in 1..8
      for x in 1..8
        serial[[x, y]] = get(x, y).value
      end
    end
    serial
  end
  
  def set(x, y, value)
    squares[[x, y]].value = value
  end
  
  def get(x, y)
    squares[[x, y]]
  end
  
  def legal_square?(x, y)
    (x + y) % 2 == 1
  end
  
  def red_prince_squares
    squares.select { |k, v| v.red_prince? }.keys
  end
  
  def red_king_squares
    squares.select { |k, v| v.red_king? }.keys
  end
  
  def red_squares
    squares.select { |k, v| v.red? }.keys
  end
  
  def white_prince_squares
    squares.select { |k, v| v.white_prince? }.keys
  end
  
  def white_king_squares
    squares.select { |k, v| v.white_king? }.keys
  end
  
  def white_squares
    squares.select { |k, v| v.white? }.keys
  end
  
  def red_value
    red_prince_squares.length + red_king_squares.length * 2 - white_prince_squares.length - white_king_squares.length * 2
  end
  
  def white_value
    white_prince_squares.length + white_king_squares.length * 2 - red_prince_squares.length - red_king_squares.length * 2
  end
  
  def neighbors(x, y)
    {
      :northwest  => (((x - 1) >= 1) and ((y - 1) >= 1)) ? [x - 1, y - 1] : 0,
      :northeast  => (((x - 1) >= 1) and ((y + 1) <= 8)) ? [x - 1, y + 1] : 0,
      :southeast  => (((x + 1) <= 8) and ((y + 1) <= 8)) ? [x + 1, y + 1] : 0,
      :southwest  => (((x + 1) <= 8) and ((y - 1) >= 1)) ? [x + 1, y - 1] : 0
    }
  end
  
  def jump_destination(from_x, from_y, over_x, over_y)
    over_neighbors = neighbors(over_x, over_y)
    
    if from_x < over_x
      if from_y < over_y # northwest -> southeast
        destination = over_neighbors[:southeast]
      else # northeast -> southwest
        destination = over_neighbors[:southwest]
      end
    else
      if from_y < over_y # southwest -> northeast
        destination = over_neighbors[:northeast]
      else # southeast -> northwest
        destination = over_neighbors[:northwest]
      end
    end
    
    destination
  end
  
  def check_jumps_on(from_x, from_y, over_x, over_y)
    from = get(from_x, from_y)
    over = get(over_x, over_y)
    destination = jump_destination(from_x, from_y, over_x, over_y)
    
    if destination == 0 or !get(destination[0], destination[1]).empty?
      return false
    end
    
    if (from.red? and over.white?) or (from.white? and over.red?)
      return destination
    end
    
    false
  end
  
  def moves_for_square(x, y)
    square = get(x, y)
    neighbors = neighbors(x, y)
    moves = []
    
    if square.red?
      if !square.king?
        neighbors.delete(:northwest)
        neighbors.delete(:northeast)
      end
    elsif square.white?
      if !square.king?
        neighbors.delete(:southwest)
        neighbors.delete(:southeast)
      end
    else
      # throw error
    end
    
    neighbors.values.each do |neighbor|
      if neighbor != 0
        neighbor_square = get(neighbor[0], neighbor[1])
        if neighbor_square.empty?
          moves << [x, y, neighbor[0], neighbor[1]]
        elsif check_jumps_on(x, y, neighbor[0], neighbor[1])
          move = check_jumps_on(x, y, neighbor[0], neighbor[1])
          moves << [x, y, move[0], move[1]]
        end
      end
    end
    
    moves
  end
  
  def leapfrog(from_x, from_y, to_x, to_y)
    from_neighbors = neighbors(from_x, from_y)
    
    if from_x < to_x
      if from_y < to_y # northwest -> southeast
        square = from_neighbors[:southeast]
      else # northeast -> southwest
        square = from_neighbors[:southwest]
      end
    else
      if from_y < to_y # southwest -> northeast
        square = from_neighbors[:northeast]
      else # southeast -> northwest
        square = from_neighbors[:northwest]
      end
    end
    
    square
  end
  
  def move(from_x, from_y, to_x, to_y)
    from = get(from_x, from_y)
    
    # king promotion
    val = (from.white_prince? and to_x == 1) ? CODE_WHITE_KING : from.value
    val = (from.red_prince? and to_x == 8) ? CODE_RED_KING : val
    
    set(to_x, to_y, val)
    set(from_x, from_y, CODE_EMPTY)
    if (from_y - to_y).abs > 1 # jump was made
      jump_square = leapfrog(from_x, from_y, to_x, to_y)
      set(jump_square[0], jump_square[1], CODE_EMPTY)
    end
    self
  end
  
  def display
    print "\n"
    
    print "    1 2 3 4 5 6 7 8\n   ----------------\n"
    for i in 1..8
      print "#{i} | "
      for j in 1..8
        k = squares[[i, j]].value
        if k == 0
          print blue("o")
        elsif k == 1
          print red("o")
        elsif k == 2
          print "o"
        elsif k == 3
          print red("O")
        else
          print "O"
        end
        print " "
      end
      print "\n"
    end
    print "\n"
  end
end
