class Game
	
  attr_accessor :p1, :p2, :current_player, :second_player, :board

  def initialize
		@board           = Board.new 
		@p1              = Player.new 
		@p2              = Player.new 
		@current_player  = first_turn
		@second_player   = second_player
		@game_over       = false 
		@winner          = nil
		@moves_remaining = 42 
  end
	
	def get_names
		puts "Welcome to Connect Four"
		puts "\nPlayer 1, please enter your name: "
		@p1.name = gets.chomp
		puts "\nPlayer 2, please enter your name: "
		@p2.name = gets.chomp
    puts "\n"
	end
	
  def start_game
		get_names
		assign_symbols
  end

  def assign_symbols
		@p1.symbol = ["X".red, "O".blue].shuffle.first
		@p2.symbol = (@p1.symbol == "X".red) ? "O".blue : "X".red
		puts "#{@current_player.name} will go first. Symbol: #{@current_player.symbol}."
    puts "#{@second_player.name} will go second. Symbol: #{@second_player.symbol}. \n\n"
  end

  def first_turn
		[@p1, @p2].shuffle.first
  end

  def second_player
		@current_player == @p1 ? @p2 : @p1
  end

  def take_turns
		buffer          = @current_player
		@current_player = @second_player
		@second_player  = buffer
  end

  def state(pos)
		@board.cell(pos).state
  end

  def print_board
    @letter = "A"
		@num = 1
		puts "==============================="
   
    until @letter == "G"
      print "||"
			for @num in 1..7
        print " #{state("#{@letter}#{@num}")} |"
      end
    
	  puts "|"
      puts "-------------------------------"
      @letter = @letter.next.ord.chr
      @num = 1
    end
  
    puts "   1   2   3   4   5   6   7   "
  
  end

  def new_line
		puts "\n"
  end

  def legal_move(column)
  
		if (1..7).include?(column)
			(0..5).each do |i|
			
				if (i == 5) && (@board.cell(0, column-1).state != " ")
					print "That column is full! Please select another column: "
					input = gets.chomp.to_i
					legal_move(input)
				end
			
				if @board.cell(5 - i, column - 1).state == " "
					@board.cell(5 - i, column - 1).state = @current_player.symbol 
					@current_player.add_move(@board.cell(5 - i, column - 1)) 
					break	
				end
			
			end
	  
		else
			print "Please enter a valid column number:"
			input = gets.chomp.to_i
			legal_move(input)	
		end
	
  end
	
  def turn
		puts "\nIt is #{@current_player.name}'s turn. You can move by entering a column number(1-7): "
		number = gets.chomp.to_i
		legal_move(number)
		check_win
		take_turns
  end

  def check_win

		@current_player.moves.each do |m|
			m.search_paths.each do |p|
				counter = 1
				for i in 1..3
					counter += 1 if @current_player.moves.any?{ |x| x == @board.offset(m, i*(@board.paths[p][0]), i*(@board.paths[p][1])) }
					if counter == 4
						@game_over = true
						@winner = @current_player
						break
					end
				end
			end
		end

		@game_over = true if (@game_over == false) && (@p1.moves.length + @p2.moves.length == 42)

  end

	def move_sequence
		print_board
		turn
		new_line
	end
	
	def declare_winner
		puts !@winner ? "\nDraw!" : "\nCongratulations #{@winner.name}, you've won!"
	end
  
	def play
		new_line
		start_game
		move_sequence until @game_over
		print_board
		declare_winner

  end
  
end