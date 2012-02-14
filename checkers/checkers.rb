require './util.rb'

require 'tree'
require 'term/ansicolor'
include Term::ANSIColor

LOGGING = false
SHOW_EVERY_MOVE = true
MOVE_LIMIT = 1 # a hard limit on the total number of moves EACH player can make
MINIMAX_DEPTH = 3


def tree_from_state(s, rw, depth, k)
  node = Tree::TreeNode.new("Node #{depth}-#{k}", s)
  
  count = 0
  while s != 0
    if depth == 0
      break
    end
    s = expand(s, rw == 0 ? 1 : 0, 0, count)
    log("\t> s is #{s}")
    if s != 0
      log("\t> adding s of #{s}")
      node << tree_from_state(s, rw, depth - 1, count)
    end
    count = count + 1
  end
  log("\t> exit")
  
  return node
end

def traverse(tree, rw)
  max = 0
  s_node = tree
  tree.children.each do |node|
    traverse(node, rw == 0 ? 1 : 0)
    s = node.content
    v = rw == 1 ? board_value(s, rw) : board_value(s, rw)
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

def expand(s, rw, move_num, pick_move_num)
  log("\t> expanding")
  
  last_move = 0
  list_of_moves = 0
  jump = 0
  
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
    end
  else
    move = evaluate_moves(list_of_moves, pick_move_num)
  end
  
  log("  > move: #{list_of_moves}")
  
  if move == nil or move == 0
    s = 0
  end
  
  new_s = s != 0 ? simulate_move(s, move[0], move[1], move[2], move[3], rw) : 0
  
  log("\t> expanded, move: #{move}")
  
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
  if num > list_of_moves.length - 1
    return 0
  end
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
      elsif s[[i, j]] == rw + 2
        value = value - 1
      elsif s[[i, j]] == rw + 3
        # kings worth 2 points
        value = value + 2
      elsif s[[i, j]] == rw + 4
        value = value - 2
      end
    end
  end
  value        
end

def main
  s = initialize_game
  
  print "\nInitialized game:\n"
  print_board(s)
  
  counter = 1
  for i in 1..MOVE_LIMIT
    if s != 0
      s = traverse(tree_from_state(s, 0, MINIMAX_DEPTH, counter), 0)
      Process.exit
      last_s = s.clone unless s == 0
      
      if SHOW_EVERY_MOVE
        print_board(s, counter)
      end
      counter += 1

      if s == 0
        print bold("\nWhite wins!\n\n")
      end
      
      s = traverse(tree_from_state(s, 1, MINIMAX_DEPTH, counter), 1)
      last_s = s.clone unless s == 0
      
      if SHOW_EVERY_MOVE
        print_board(s, counter)
      end
      counter += 1
      
      if s == 0
        print bold("\nRed wins!\n\n")
      end
      
      j = i
    end
  end
  
  if j == MOVE_LIMIT && s != 0
    print bold("\nMove limit reached before either player won.\n\n")
  end
    
  print "Total Moves: #{j * 2}\n\nFinal state:\n"
  print_board(last_s)
  
  s
end

# Main
main
