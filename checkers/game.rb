require './board.rb'

class Game
  attr_accessor :board
  
  def initialize
    self.board = Board.new
  end
end