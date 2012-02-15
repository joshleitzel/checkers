# board_spec.rb
require './board.rb'

describe Board do
  before(:each) do
    @board = Board.new
  end
  
  describe "Squares" do
    it "should successfully set and get a square" do
      @board.set(5, 2, CODE_RED)
      @board.get(5, 2).should == CODE_RED
    end
    
    it "should find red squares" do
      init_red_prince = [[1, 2], [1, 4], [1, 6], [1, 8], [2, 1], [2, 3], [2, 5], [2, 7], [3, 2], [3, 4], [3, 6], [3, 8]]
      @board.red_prince_squares.should == init_red_prince
      @board.red_king_squares.should == []
      @board.red_squares.should == init_red_prince
      
      @board.set(5, 2, CODE_RED_KING)
      @board.set(5, 4, CODE_RED)
      @board.set(5, 6, CODE_RED_KING)
      
      @board.red_prince_squares.should == init_red_prince + [[5, 4]]
      @board.red_king_squares.should == [[5, 2], [5, 6]]
      @board.red_squares.should == init_red_prince + [[5, 2], [5, 4], [5, 6]]
    end
    
    it "should find white squares" do
      init_white_prince = [[6, 1], [6, 3], [6, 5], [6, 7], [7, 2], [7, 4], [7, 6], [7, 8], [8, 1], [8, 3], [8, 5], [8, 7]]
      @board.white_prince_squares.should == init_white_prince
      @board.white_king_squares.should == []
      @board.white_squares.should == init_white_prince
    end 
    
    it "should find the neighbors of a square" do
      @board.neighbors(1, 2).should == [0, 0, [2, 3], [2, 1]]
      @board.neighbors(5, 2).should == [[4, 1], [4, 3], [6, 3], [6, 1]]
      @board.neighbors(8, 7).should == [[7, 6], [7, 8], 0, 0]
    end
       # 
        # 
        # it "should find the moves for a square" do
        #   @board.find_moves_for_square(3, 8).should == [[4, 7]]
        # end
  end
  
  describe "Intelligence" do
    it "should find the value of the initialized board" do
      @board.red_value.should == 0
      @board.white_value.should == 0
    end
    
    it "should find the value of a more advanced board" do
      @board.set(4, 1, CODE_RED)
      @board.set(4, 3, CODE_RED_KING)
      @board.set(4, 5, CODE_RED_KING)
      @board.set(5, 2, CODE_WHITE)
      @board.set(5, 4, CODE_WHITE_KING)
      @board.set(5, 6, CODE_RED_KING)
      
      @board.red_value.should == 4
      @board.white_value.should == -4
    end
  end
end
