# game_spec.rb
require './game.rb'

describe Game do
  before(:each) do
    @game = Game.new
  end
  
  it "should create a new game" do
    @game.board.should_not == nil
  end
end