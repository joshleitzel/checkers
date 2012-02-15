# board_spec.rb
require './board.rb'

describe Board do
  before(:each) do
    @board = Board.new
  end
  
  describe "Squares" do
    it "should successfully set and get a square" do
      @board.set(5, 2, CODE_RED)
      @board.get(5, 2).value.should == CODE_RED
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
      @board.neighbors(1, 2).values.should == [0, 0, [2, 3], [2, 1]]
      @board.neighbors(5, 2).values.should == [[4, 1], [4, 3], [6, 3], [6, 1]]
      @board.neighbors(8, 7).values.should == [[7, 6], [7, 8], 0, 0]
    end
       # 
        # 
        # it "should find the moves for a square" do
        #   @board.find_moves_for_square(3, 8).should == [[4, 7]]
        # end
  end
  
  describe "Moves" do
    describe "Jumps" do
      it "should find the destination square" do
        @board.jump_destination(1, 2, 2, 3).should == [3, 4]
        @board.jump_destination(1, 2, 2, 1,).should == 0
        @board.jump_destination(3, 4, 4, 5).should == [5, 6]
        @board.jump_destination(3, 4, 4, 3).should == [5, 2]
        @board.jump_destination(3, 4, 2, 3).should == [1, 2]
        @board.jump_destination(3, 4, 2, 5).should == [1, 6]
      end
      
      it "should check the jumps" do
        @board.check_jumps_on(3, 2, 4, 3).should == false
        @board.set(4, 3, CODE_RED)
        @board.check_jumps_on(3, 2, 4, 3).should == false
        @board.set(4, 3, CODE_RED_KING)
        @board.check_jumps_on(3, 2, 4, 3).should == false
        @board.set(4, 3, CODE_WHITE_KING)
        @board.check_jumps_on(3, 2, 4, 3).should == [5, 4]
        @board.set(4, 3, CODE_WHITE)
        @board.check_jumps_on(3, 2, 4, 3).should == [5, 4]
        @board.check_jumps_on(3, 2, 4, 1).should == false
        @board.check_jumps_on(3, 2, 1, 1).should == false
        @board.check_jumps_on(3, 2, 1, 3).should == false
        @board.check_jumps_on(3, 4, 4, 3).should == [5, 2]
        @board.check_jumps_on(3, 4, 4, 3).should == [5, 2]
        @board.check_jumps_on(3, 4, 4, 3).should == [5, 2]
        
        @board.set(4, 3, CODE_EMPTY)
        @board.set(5, 2, CODE_RED)
        
        @board.check_jumps_on(6, 3, 5, 2).should == [4, 1]
        @board.check_jumps_on(6, 1, 5, 2).should == [4, 3]
      end
      
      describe "finding moves" do
        before(:each) do
          @board.set(1, 2, CODE_EMPTY)
          @board.set(1, 4, CODE_EMPTY)
          @board.set(1, 6, CODE_EMPTY)
          @board.set(1, 8, CODE_EMPTY)
          @board.set(2, 1, CODE_EMPTY)
          @board.set(2, 3, CODE_EMPTY)
          @board.set(2, 5, CODE_EMPTY)
          @board.set(2, 7, CODE_RED_KING)
          @board.set(3, 2, CODE_EMPTY)
          @board.set(3, 4, CODE_RED_KING)
          @board.set(3, 6, CODE_EMPTY)
          @board.set(3, 8, CODE_EMPTY)
          @board.set(4, 3, CODE_RED_KING)
          @board.set(4, 5, CODE_WHITE)
          @board.set(4, 7, CODE_RED)
          @board.set(5, 2, CODE_WHITE_KING)
          @board.set(5, 6, CODE_WHITE)
          @board.set(5, 8, CODE_WHITE_KING)
          @board.set(6, 1, CODE_EMPTY)
          @board.set(6, 3, CODE_EMPTY)
          @board.set(6, 5, CODE_EMPTY)
          @board.set(7, 2, CODE_WHITE_KING)
          @board.set(7, 6, CODE_EMPTY)
          @board.set(7, 8, CODE_EMPTY)
          @board.set(8, 1, CODE_EMPTY)
          @board.set(8, 3, CODE_EMPTY)
          @board.set(8, 7, CODE_EMPTY)
        end
        
        it "should find the moves" do
          @board.display
          @board.moves_for_square(2, 7).should =~ [[2, 7, 1, 6], [2, 7, 1, 8], [2, 7, 3, 8], [2, 7, 3, 6]]
          @board.moves_for_square(3, 4).should =~ [[3, 4, 2, 3], [3, 4, 2, 5]]
          @board.moves_for_square(4, 3).should =~ [[4, 3, 3, 2], [4, 3, 6, 1], [4, 3, 5, 4]]
          @board.moves_for_square(4, 5).should =~ [[4, 5, 2, 3], [4, 5, 3, 6]]
          @board.moves_for_square(4, 7).should =~ [[4, 7, 6, 5]]
          @board.moves_for_square(5, 2).should =~ [[5, 2, 4, 1], [5, 2, 6, 1], [5, 2, 6, 3]]
          @board.moves_for_square(5, 6).should =~ [[5, 6, 3, 8]]
          @board.moves_for_square(5, 8).should =~ [[5, 8, 3, 6]]
          @board.moves_for_square(6, 7).should =~ []
          @board.moves_for_square(7, 2).should =~ [[7, 2, 6, 1], [7, 2, 6, 3], [7, 2, 8, 1], [7, 2, 8, 3]]
          @board.moves_for_square(7, 4).should =~ [[7, 4, 6, 3], [7, 4, 6, 5]]
          @board.moves_for_square(8, 5).should =~ [[8, 5, 7, 6]]
        end
      end
    end
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
