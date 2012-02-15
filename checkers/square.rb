require './util.rb'

class Square
  attr_accessor :value
  
  def initialize(value)
    self.value = value
  end
  
  def empty?
    value == CODE_EMPTY
  end
  
  def red_prince?
    value == CODE_RED
  end
  
  def red_king?
    value == CODE_RED_KING
  end
  
  def red?
    red_prince? or red_king?
  end
  
  def white_prince?
    value == CODE_WHITE
  end
  
  def white_king?
    value == CODE_WHITE_KING
  end
  
  def white?
    white_prince? or white_king?
  end
  
  def prince?
    red_prince? or white_prince?
  end
  
  def king?
    red_king? or white_king?
  end
end