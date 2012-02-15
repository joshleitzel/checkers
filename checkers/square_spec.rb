# square_spec.rb
require './square.rb'

describe Square do
  before(:each) do
    @squares = [
      Square.new(0),
      Square.new(1),
      Square.new(2),
      Square.new(3),
      Square.new(4)
    ]
  end
  
  describe "square inquiries" do
    it "should return the inquiries successfully" do
      @squares.map(&:empty?).should == [true, false, false, false, false]
      @squares.map(&:red_prince?).should == [false, true, false, false, false]
      @squares.map(&:white_prince?).should == [false, false, true, false, false]
      @squares.map(&:prince?).should == [false, true, true, false, false]
      @squares.map(&:red_king?).should == [false, false, false, true, false]
      @squares.map(&:white_king?).should == [false, false, false, false, true]
      @squares.map(&:red?).should == [false, true, false, true, false]
      @squares.map(&:white?).should == [false, false, true, false, true]
      @squares.map(&:king?).should == [false, false, false, true, true]
    end
  end
end