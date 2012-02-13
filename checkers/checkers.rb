require 'tree'
require 'term/ansicolor'
include Term::ANSIColor

# 0 - empty
# 1 - red
# 2 - white
# 3 - kingred
# 4 - kingwhite
def s(a, b)
  print s
end

LOGGING = false
SHOW_EVERY_MOVE = false
MOVE_LIMIT = 2 # a hard limit on the total number of moves EACH player can make
MINIMAX_DEPTH = 3

def log(message)
  if LOGGING
    print "\n#{message}"
  end
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


def tree_from_state(s, rw, depth, k)
  node = Tree::TreeNode.new("Node #{depth}-#{k}", s)
  
  count = 0
  while s != 0
    if depth == 0
      break
    end
    s = expand(s, rw, 0, count)
    if s != 0
      node << tree_from_state(s, rw, depth - 1, count)
    end
    count = count + 1
  end
  
  return node
end

def traverse(tree)
  max = 0
  s_node = tree
  tree.children.each do |node|
    traverse(node)
    s = node.content
    v = board_value(s, 0)
    if v > max
      saved_s = s
      s_node = node
    end
  end
  
  while s_node.parent
    s_node = s_node.parent
  end
  s_node.content
end


def simulate_game
  s = initialize_game
  
  print "\nInitialized game:\n"
  print_board(s)
  
  counter = 1
  for i in 1..MOVE_LIMIT
    if s != 0
      s = traverse(tree_from_state(s, 0, MINIMAX_DEPTH, counter))
      counter += 1
      last_s = s.clone unless s == 0
      
      s = traverse(tree_from_state(s, 1, MINIMAX_DEPTH, counter))
      counter += 1
      last_s = s.clone unless s == 0
      j = i
    end
  end
  
  print "Total Moves: #{j * 2}\n\nFinal state:\n"
  print_board(last_s)
  
  s
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
  
  s[[1, 2]] = 0
  s[[1, 4]] = 0
  s[[1, 6]] = 0
  s[[2, 1]] = 0
  s[[2, 3]] = 0
  s[[2, 5]] = 0
  s[[3, 2]] = 0
  s[[3, 6]] = 0
  s[[3, 8]] = 0
  s[[3, 4]] = 3
  s[[4, 3]] = 3
  s[[2, 7]] = 3
  s[[4, 7]] = 1
  s[[5, 2]] = 4
  s[[5, 8]] = 4
  s[[7, 2]] = 4
  s[[7, 4]] = 4
  s[[8, 7]] = 4
  s[[6, 1]] = 0
  s[[6, 3]] = 0
  s[[6, 5]] = 0
  s[[6, 7]] = 0
  s[[7, 6]] = 0
  s[[7, 8]] = 0
  s[[8, 1]] = 0
  s[[8, 3]] = 0
  s[[8, 5]] = 0
  s[[1, 8]] = 0
  s
end

def is_legal_square?(a, b)
  (a + b) % 2 == 1
end

def move(s, from_x, from_y, to_x, to_y)
  from = s[[from_x, from_y]]
  s[[to_x, to_y]] = from
  s[[from_x, from_y]] = 0
  s
end

def expand(s, rw, move_num, pick_move_num)
  list_of_moves = 0
  jump = 0
  
#  while jump == 0
    for a in 1..8
      for b in 1..8
        if (a + b) % 2 == 1
          if (s[[a, b]] == 1 + rw) or (s[[a, b]] == 3 + rw)
            result = exploit_moves(s, a, b, list_of_moves, jump, rw)
            list_of_moves = result[:list_of_moves]
            jump = result[:jump]
          end
        end
      end
    end
    
    if jump == 0
      if list_of_moves != 0
        move = evaluate_moves(list_of_moves, pick_move_num)
      else
        s = 0
        winner = rw == 0 ? 'White' : 'Red'
        print bold("\n#{winner} wins!\n\n")
      end
    else  
      move = evaluate_moves(list_of_moves, pick_move_num)
    end
 # end
  
  log("  > move: #{list_of_moves}")
  
  if move == nil
    s = 0
  end
  
  new_s = s != 0 ? simulate_move(s, move[0], move[1], move[2], move[3], rw) : 0
  
  if SHOW_EVERY_MOVE
    print_board(new_s, move_num)
  end
  
  new_s
end

def make_jump(s, from_x, from_y, remove_x, remove_y, to_x, to_y, jump, list_of_moves, rw)
  piece = s[[from_x, from_y]]
  s[[from_x, from_y]] = 0
  s[[remove_x, remove_y]] = 0
  promotion = 0
  if (to_y == 1 + 7 * (1 - rw)) and (piece == 1 + rw)
    log("  > promoting")
    promotion = 1
    s[[to_x, to_y]] = 3 + rw
  else
    s[[to_x, to_y]] = piece
  end
  list_of_moves = add_move_to_list(list_of_moves, from_x, from_y, to_x, to_y)
  if promotion != 1
    # check if a new jump is obliged
    exploit_moves(s, remove_x, remove_y, list_of_moves, jump, rw)
  end
  list_of_moves
end

def exploit_moves(s, a, b, list_of_moves, jump, rw)
  result = {
    :jump => jump,
    :list_of_moves => list_of_moves
  }
  
  if s[[a, b]] == 3 + rw
    # king, check backward first
    for d in [0, 1]
      neighbor = neighbor(a, b, d, rw, 0)
      if neighbor != 0
        result = check_move(s, a, b, neighbor[0], neighbor[1], d, jump, list_of_moves, rw, 0)
        list_of_moves = result[:list_of_moves]
        jump = result[:jump]
      end
    end
  end
  
  if (s[[a, b]] == 1 + rw) or (s[[a, b]] == 3 + rw)
    for d in [0, 1]
      neighbor = neighbor(a, b, d, rw, 1)
      if neighbor != 0
        result = check_move(s, a, b, neighbor[0], neighbor[1], d, jump, list_of_moves, rw, 1)
        list_of_moves = result[:list_of_moves]
        jump = result[:jump]
        log("  > result: \n\t#{result.inspect}")
      end
    end
  end
  return {
    :jump => jump,
    :list_of_moves => list_of_moves
  }
end

def check_move(s, a, b, aa, bb, d, jump, list_of_moves, rw, fb)
  log("Checking: from [#{a}, #{b}] to [#{aa}, #{bb}]; current: [#{s[[aa, bb]]}]; player: [#{rw}], jump: #{jump}")
  if s[[aa, bb]] == 0 and jump == 0
    log("  > empty")
    ss = simulate_move(s, a, b, aa, bb, rw)
    list_of_moves = add_move_to_list(list_of_moves, a, b, aa, bb)
  elsif (s[[aa, bb]] == 2 - rw) or (s[[aa, bb]] == 4 - rw)
    # opposite piece
    log("  > opposite piece")
    neighbor = neighbor(aa, bb, d, rw, fb)
    if neighbor != 0 and s[[neighbor[0], neighbor[1]]] == 0
      if jump == 0
        jump = 1
        list_of_moves = 0
      end
      list_of_moves = make_jump(s, a, b, aa, bb, neighbor[0], neighbor[1], jump, list_of_moves, rw)
    end
  else
    log("  > nothing to do here")
  end
  
  result = {
    :jump => jump,
    :list_of_moves => list_of_moves
  }
  log("  > check result: \n\t#{result}")
  result
end

def add_move_to_list(list_of_moves, from_x, from_y, to_x, to_y)
  move = [from_x, from_y, to_x, to_y]
  
  if list_of_moves == 0
    list_of_moves = [move]
  else
    list_of_moves << move
  end
  list_of_moves
end

def neighbor_list(a, b)
  n1 = (((a - 1) >= 1) and ((b - 1) >= 1)) ? [a - 1, b - 1] : 0 
  n2 = (((a - 1) >= 1) and ((b + 1) <= 8)) ? [a - 1, b + 1] : 0
  n3 = (((a + 1) <= 8) and ((b + 1) <= 8)) ? [a + 1, b + 1] : 0
  n4 = (((a + 1) <= 8) and ((b - 1) >= 1)) ? [a + 1, b - 1] : 0
  [n1, n2, n3, n4]
end

# d - diagonal, 0 or 1
def neighbor(a, b, d, rw, fb)
  neighbor = (rw + fb) % 2 # 1 - redforward, whitebackward; 0 - redbackward, whiteforward
  neighbor_list = neighbor_list(a, b)
  if d == 0
    return neighbor != 0 ? neighbor_list[2] : neighbor_list[0]
  elsif d == 1
    return neighbor != 0 ? neighbor_list[3] : neighbor_list[1]
  end
end

def simulate_move(s, from_x, from_y, to_x, to_y, rw)
  s2 = s.clone
  s2[[from_x, from_y]] = 0
  if (to_y == 1 + 7 * (1 - rw)) and (s[[from_x, from_y]] == 1 + rw)
    # king promotion for simple piece
    s2[[to_x, to_y]] = 3 + rw
  else
    s2[[to_x, to_y]] = s[[from_x, from_y]]
  end
  s2
end

def evaluate_moves(list_of_moves, num)
  list_of_moves[num]
end

def minimax(s, rw, depth, v)
  v ||= 0
  other = rw == 0 ? 1 : 0
  
  if depth == 0
    s = expand(s, rw, 0)
    bv = board_value(s, rw)
    return bv
  else
    for i in 0..depth
      s = expand(s, rw, 0)
      bv = board_value(s, rw)
      v = minimax(s, rw, depth - 1, v)
    end
  end 
  
  v
end

# Finds the value for a specific state of the board for a player
def board_value(s, rw)
  value = 0
  for i in 1..8
    for j in 1..8
      if s[[i, j]] == rw + 1
        # regular pieces worh 1 point
        value = value + 1
      elsif s[[i, j]] == rw + 3
        # kings worth 2 points
        value = value + 2
      end
    end
  end
  value        
end

def max_value(state)
  if terminal_test(state)
    return utility(state)
  end
  v = 0
  for a, s in successors(state) do
    v = max(v, min_value(s))
  end
  v
end

def min_value(state)
  if terminal_test(state)
    return utility(state)
  end
  v = 0
  for a, s in successors(state) do
    v = min(v, max_value(s))
  end
  v
end

def num_pieces(s, type)
  sum = 0
  for i in 1..8
    for j in 1..8
      if s[[i, j]] == type
        sum = sum + 1
      end
    end
  end
  sum
end

# Main
simulate_game
