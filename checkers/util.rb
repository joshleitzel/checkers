
# 0 - empty
# 1 - red
# 2 - white
# 3 - kingred
# 4 - kingwhite
def s(a, b)
  print s
end

def log(message)
  if LOGGING
    print "\n#{message}"
  end
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

def initialize_game
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
  # 
  # s[[1, 2]] = 0
  # s[[1, 4]] = 0
  # s[[1, 6]] = 0
  # s[[2, 1]] = 0
  # s[[2, 3]] = 0
  # s[[2, 5]] = 0
  # s[[3, 2]] = 0
  # s[[3, 6]] = 0
  # s[[3, 8]] = 0
  # s[[3, 4]] = 3
  # s[[4, 3]] = 3
  # s[[2, 7]] = 3
  # s[[4, 7]] = 1
  # s[[5, 2]] = 4
  # s[[5, 8]] = 4
  # s[[7, 2]] = 4
  # s[[7, 4]] = 4
  # s[[8, 7]] = 4
  # s[[6, 1]] = 0
  # s[[6, 3]] = 0
  # s[[6, 5]] = 0
  # s[[6, 7]] = 0
  # s[[7, 6]] = 0
  # s[[7, 8]] = 0
  # s[[8, 1]] = 0
  # s[[8, 3]] = 0
  # s[[8, 5]] = 0
  # s[[1, 8]] = 0
  s
end

def is_legal_square?(a, b)
  (a + b) % 2 == 1
end

def print_board(s, move = nil)
  print "\n"
  
  if move
    print "Move #"
    print bold(white("#{move}:\n\n"))
  end
  
  print "    1 2 3 4 5 6 7 8\n   ----------------\n"
  for i in 1..8
    print "#{i} | "
    for j in 1..8
      k = s[[i, j]]
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