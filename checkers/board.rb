class Board
  attr_accessor :content
  
  def initialize
    s = empty_board
    for b in 1..8
      for a in 1..3
        if (a + b) % 2 == 1
          s[[a,b]] = 1
        end
      end
      for a in 6..8
        if (a + b) % 2 == 1
          s[[a,b]] = 2
        end
      end
    end
    
    self.content = s
  end
  
  def empty_board
    s = Hash.new
    for x in 1..8
      for y in 1..8
        s[[x,y]] = 0
      end
    end
    s
  end
  
  def is_legal_square?(x, y)
    (x + y) % 2 == 1
  end
end