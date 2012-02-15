require './util.rb'

class Square
  attr_accessor :value
  
  def initialize(value)
    self.value = value
  end
  
  def empty?
    value == CODE_EMPTY
  end
  
  def red?
    value == CODE_RED
  end
  
  def white?
    value == CODE_WHITE
  end
  
  def red_king?
    value == CODE_RED_KING
  end
  
  def white_king?
    value == CODE_WHITE_KING
  end
  
  def prince?
    red? or white?
  end
  
  def king?
    red_king? or white_king?
  end
end