require './board.rb'

class Game
  attr_accessor :board
  attr_accessor :player
  
  def initialize
    self.board = Board.new(nil)
  end
  
  def play
    self.player = 'red' # red moves first
    board.advance(player)
  end
end
