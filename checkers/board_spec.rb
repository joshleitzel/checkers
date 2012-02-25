# board_spec.rb
require './board.rb'

describe Board do
  before(:each) do
    @board = Board.new(nil)
  end
  
  describe "Basic" do
    it "should serialize the square values" do
      @board.serial.should == {
        [1, 1]=>0, [2, 1]=>1, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>2, [7, 1]=>0, [8, 1]=>2,
        [1, 2]=>1, [2, 2]=>0, [3, 2]=>1, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>2, [8, 2]=>0,
        [1, 3]=>0, [2, 3]=>1, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>2, [7, 3]=>0, [8, 3]=>2,
        [1, 4]=>1, [2, 4]=>0, [3, 4]=>1, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
        [1, 5]=>0, [2, 5]=>1, [3, 5]=>0, [4, 5]=>0, [5, 5]=>0, [6, 5]=>2, [7, 5]=>0, [8, 5]=>2,
        [1, 6]=>1, [2, 6]=>0, [3, 6]=>1, [4, 6]=>0, [5, 6]=>0, [6, 6]=>0, [7, 6]=>2, [8, 6]=>0,
        [1, 7]=>0, [2, 7]=>1, [3, 7]=>0, [4, 7]=>0, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>2,
        [1, 8]=>1, [2, 8]=>0, [3, 8]=>1, [4, 8]=>0, [5, 8]=>0, [6, 8]=>0, [7, 8]=>2, [8, 8]=>0
      }
    end
    
    it "should find the opposite player" do
      @board.opposite_player('red').should == 'white'
      @board.opposite_player('white').should == 'red'
    end
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
      
      it "should find the leapfrogs (square to be jumped over)" do
        @board.leapfrog(1, 2, 3, 4).should == [2, 3]
        @board.leapfrog(3, 4, 1, 2).should == [2, 3]
        @board.leapfrog(3, 2, 1, 4).should == [2, 3]
        @board.leapfrog(1, 4, 3, 2).should == [2, 3]
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
        @board.set(8, 7, CODE_EMPTY)
      end
      
      it "should find the moves for the squares" do
        @board.moves_for_square(2, 7).should =~ [[2, 7, 1, 6], [2, 7, 1, 8], [2, 7, 3, 8], [2, 7, 3, 6]]
        @board.moves_for_square(3, 4).should =~ [[3, 4, 2, 3], [3, 4, 2, 5]]
        @board.moves_for_square(4, 3).should =~ [[4, 3, 3, 2], [4, 3, 6, 1], [4, 3, 5, 4]]
        @board.moves_for_square(4, 5).should =~ [[4, 5, 2, 3], [4, 5, 3, 6]]
        @board.moves_for_square(4, 7).should =~ [[4, 7, 6, 5]]
        @board.moves_for_square(5, 2).should =~ [[5, 2, 4, 1], [5, 2, 6, 1], [5, 2, 6, 3]]
        @board.moves_for_square(5, 6).should =~ [[5, 6, 3, 8]]
        @board.moves_for_square(5, 8).should =~ [[5, 8, 3, 6]]
        @board.moves_for_square(6, 7).should == []
        @board.moves_for_square(7, 2).should =~ [[7, 2, 6, 1], [7, 2, 6, 3], [7, 2, 8, 1]]
        @board.moves_for_square(7, 4).should =~ [[7, 4, 6, 3], [7, 4, 6, 5]]
        @board.moves_for_square(8, 3).should == []
        @board.moves_for_square(8, 5).should =~ [[8, 5, 7, 6]]
      end
      
      it "should find the moves for red" do
        @board.moves_for_player('red').should =~ [[2, 7, 1, 6], [2, 7, 1, 8], [2, 7, 3, 6], [2, 7, 3, 8], [3, 4, 2, 3], [3, 4, 2, 5], [4, 3, 3, 2], [4, 3, 5, 4], [4, 3, 6, 1], [4, 7, 6, 5]]
      end
      
      it "should find the moves for white" do
        @board.moves_for_player('white').should =~ [[4, 5, 2, 3], [4, 5, 3, 6], [5, 2, 4, 1], [5, 2, 6, 1], [5, 2, 6, 3], [5, 6, 3, 8], [5, 8, 3, 6], [7, 2, 6, 1], [7, 2, 6, 3], [7, 2, 8, 1], [7, 4, 6, 3], [7, 4, 6, 5], [8, 5, 7, 6]]
      end
      
      it "should make the moves" do
        @board.move(2, 7, 1, 6).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>0, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>0, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>4, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>0, [3, 3]=>0, [4, 3]=>3, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>3, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>2, [5, 5]=>0, [6, 5]=>0, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>2, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>1, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>0,
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
        @board.move(4, 3, 6, 1).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>3, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>0, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>0, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>3, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>2, [5, 5]=>0, [6, 5]=>0, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>2, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>1, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>0, 
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
        @board.move(4, 5, 2, 3).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>3, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>0, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>2, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>0, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>0, [5, 5]=>0, [6, 5]=>0, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>2, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>1, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>0,
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
        @board.move(4, 7, 6, 5).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>3, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>0, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>2, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>0, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>0, [5, 5]=>0, [6, 5]=>1, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>0, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>0, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>0,
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
        @board.move(2, 3, 1, 2).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>3, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>4, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>0, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>0, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>0, [5, 5]=>0, [6, 5]=>1, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>0, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>0, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>0,
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
        @board.move(6, 5, 7, 6).move(7, 6, 8, 7).serial.should == {
          [1, 1]=>0, [2, 1]=>0, [3, 1]=>0, [4, 1]=>0, [5, 1]=>0, [6, 1]=>3, [7, 1]=>0, [8, 1]=>0,
          [1, 2]=>4, [2, 2]=>0, [3, 2]=>0, [4, 2]=>0, [5, 2]=>0, [6, 2]=>0, [7, 2]=>4, [8, 2]=>0,
          [1, 3]=>0, [2, 3]=>0, [3, 3]=>0, [4, 3]=>0, [5, 3]=>0, [6, 3]=>0, [7, 3]=>0, [8, 3]=>2,
          [1, 4]=>0, [2, 4]=>0, [3, 4]=>0, [4, 4]=>0, [5, 4]=>0, [6, 4]=>0, [7, 4]=>2, [8, 4]=>0,
          [1, 5]=>0, [2, 5]=>0, [3, 5]=>0, [4, 5]=>0, [5, 5]=>0, [6, 5]=>0, [7, 5]=>0, [8, 5]=>2,
          [1, 6]=>3, [2, 6]=>0, [3, 6]=>0, [4, 6]=>0, [5, 6]=>0, [6, 6]=>0, [7, 6]=>0, [8, 6]=>0,
          [1, 7]=>0, [2, 7]=>0, [3, 7]=>0, [4, 7]=>0, [5, 7]=>0, [6, 7]=>2, [7, 7]=>0, [8, 7]=>3,
          [1, 8]=>0, [2, 8]=>0, [3, 8]=>0, [4, 8]=>0, [5, 8]=>4, [6, 8]=>0, [7, 8]=>0, [8, 8]=>0
        }
      end
    end
    
    describe "finding moves for a player" do
      it "should find the moves for red" do
        @board.moves_for_player('red').should =~ [[3, 2, 4, 1], [3, 2, 4, 3], [3, 4, 4, 3], [3, 4, 4, 5], [3, 6, 4, 5], [3, 6, 4, 7], [3, 8, 4, 7]]
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
  
  describe "Advancing (taking a turn)" do
    it "should advance the board with red" do
      @board.advance('red').valid?.should == true
    end
    
    it "should advance the board with white" do
      @board.advance('white').valid?.should == true
    end
    
    it "should build the minimax tree" do
      print "\n\n"
      @board.minimax_tree('red', 6, nil, 0).print_tree
      print "\n\n"
    end
  end
end
