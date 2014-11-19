['io/console', 'colorize'].each{|g|require g}


@board = Array.new(4) { [0,0,0,0] }                          # Creates a 4 X 4 game board

# Creates a hash of achievements with the keys representing their names and values representing their descriptions

@achievements = {16 => "Unlock the 16 Tile", 32 => "Unlock the 32 Tile", 64 => "Unlock the 64 Tile", 128 => "Unlock the 128 Tile",
256 => "Unlock the 256 Tile", 512 => "Unlock the 512 Tile", 1024 => "Unlock the 1024 Tile", 2048 => "Unlock the 2048 Tile",
4096 => "Unlock the 4096 Tile", 8192 => "Unlock the 8192 Tile", 16384 => "Unlock the 16384 Tile", "Score 500" => "Earn more than 500 points",
"Score 1000" => "Earn more than 1000 points", "Score 2000" => "Earn more than 2000 points", "Score 5000" => "Earn more than 5000 points",
"Score 10000" => "Earn more than 10000 points", "HIGHEST SCORE" => "Earn more than 20000 points"}

# At first, the player hasn't earned any achievements

@unlocked = []

# This method will update the board before every turn

def draw_board

  # Color codes a new high score
  
  puts " Score: #{@board.flatten.inject(:+) == [@board.flatten.inject(:+), @scores.max].max ? \
  (@board.flatten.inject(:+)).to_s.yellow : @board.flatten.inject(:+)} High Score: #{@board.flatten.inject(:+) == [@board.flatten.inject(:+), @scores.max].max ? \
  (@board.flatten.inject(:+)).to_s.yellow : [@board.flatten.inject(:+), @scores.max].max} Achievements: #{@unlocked.count}"
  puts " ________________________________________"
  
  (0..3).each{|ii|
    print '|'                                                # For every row add a separator
    (0..3).each{|jj|
  	  n = @board[ii][jj]                                     # Coordinates we will place tiles
	  print color_num(n)                                     # Prints a color-coded number, see color_num method
	  print '|'                                              # Add a separator for every cell on every row
	}
    puts ""
  }
  puts ""
end

# Generates a new tile

def new_tile
  tile = rand(1..2) * 2                                      # Will generate either a 2 or a 4
  xx = rand(0..3)
  yy = rand(0..3)
  (0..3).each{|ii|
    (0..3).each{|jj|
      x1 = (xx + ii) % 4
      y1 = (yy + jj) % 4
      if @board[x1][y1] == 0
        @board[x1][y1] = tile                                # If space is empty, a new title is generated
	    return true
      end
    }
  }
  false
end

# Color codes a number based on its values.

def color_num(num)
  number = '%4.4s' % num                                     # Shifts number to the right a few spaces
  color = ""                                                 # Initialize color variable
  
  case num
    when 0 then color = "    "
    when 2 then color = number.white
    when 4 then color = number.white
    when 8 then color = number.light_red
    when 16 then color = number.red
    when 32 then color = number.light_yellow
    when 64 then color = number.yellow
    when 128 then color = number.light_cyan
    when 256 then color = number.cyan
    when 512 then color = number.light_green
    when 1024 then color = number.green
    when 2048 then color = number.light_blue
    when 4096 then color = number.blue
    when 8192 then color = number.light_magenta
    when 16384 then color = number.magenta
    else abort "error"
  end
  
  color.underline
end

# Receive and process user input

def get_input
  input = ''
  controls = ['a', 's', 'd', 'w']
  while !controls.include?(input) do
    input = STDIN.getch                                      # Implemented so player does not have to press Enter"
    abort "escaped" if input == "\e" 
  end 
  input 
end 

# Creates a new line after the user enters a direction

def shift_left(line)
  new_line = []
  line.each { |ii| new_line.push(ii) if ii != 0 }
  new_line.push(0) while new_line.size != 4
  new_line
end

# Moves tiles to the left

def move_left
  new_board = Marshal.load(Marshal.dump(@board))             # Creates a new board object using the data from @board
  (0..3).each{|ii| 
	(0..3).each{|jj| 
      (jj..2).each{|kk| 
		if @board[ii][kk + 1] == 0 
		  next
		elsif @board[ii][jj] == @board[ii][kk + 1]
		  @board[ii][jj] = @board[ii][jj] * 2                # Tile is doubled if 2 adjacent tiles connect
		  @board[ii][kk + 1] = 0                             # Original Tile is eliminated
		end
	  break
		}
	  }
	@board[ii] = shift_left(@board[ii])
	}
  @board == new_board ? false : true
end

# Move tiles to the right

def move_right
  @board.each(&:reverse!)
  action = move_left
  @board.each(&:reverse!)
  action
end

# Move tiles down

def move_down
  @board = @board.transpose.map(&:reverse)
  action = move_left
  3.times { @board = @board.transpose.map(&:reverse) }       # Mapped 3 times to retain positioning
  action
end

# Move tiles up

def move_up
  3.times { @board = @board.transpose.map(&:reverse) }
  action = move_left
  @board = @board.transpose.map(&:reverse)
  action
end

# If a player reaches the final tile, 16384, they win

def win_checker
  @board.flatten.max == 16384
end

# Checks which direction the player can move

def loss_checker
  new_board = Marshal.load(Marshal.dump(@board)) 
  option = move_right
  if option == false
    option = move_left
	if option == false
	  option = move_up
	  if option == false
		option = move_down
		if option == false
		  @board = Marshal.load(Marshal.dump(new_board))
		  return true
		end
	  end
	end
  end
  @board = Marshal.load(Marshal.dump(new_board))
  false
end

@scores = [0]                                                # This will store the scores recorded for every game

# Event Sequence for every game

def play
  puts "Welcome to 2048!"
  puts "Match powers of 2 by connecting ajacent identical numbers. Try to reach 2048"
  puts "Press 'a' to move left"
  puts "Press 'd' to move right"
  puts "Press 'w' to move up"
  puts "Press 's' to move down"
  
  2.times { new_tile } # Start Off a game with two titles
  draw_board
  @win = true
  
  # This while loop is called for every turn.
  
  while !win_checker
    direction = get_input
	
	#When a key is pressed, its respective method is called
	
	case direction
	  when 'a' then action = move_left
	  when 'd' then action = move_right
	  when 'w' then action = move_up
	  when 's' then action = move_down
	end
	
	new_tile if action == true                               # A new tile is generated if a legal move is available
	draw_board
	
	if loss_checker
	  @win = false
	  break                                                  # Loop will end if a player loses
	end
	
  end
end

# When the game ends, you earn achievements if you did well

def earn_achievements
  [16,32,64,128,256,512,1024,2048,4096,8192,16384].each do |a|
    unless @unlocked.include?(@achievements[a])
      @unlocked << @achievements[a] if (@board.flatten.include?(a))
	end
  end
  
  [500,1000,2000,5000,10000].each do |score|
    unless @unlocked.include?(@achievements["Score #{score}"])
      @unlocked << @achievements["Score #{score}"] if @board.flatten.inject(:+) >= score
    end
  end
  
  unless @unlocked.include?(@achievements["HIGHEST SCORE"])
    @unlocked << @achievements["HIGHEST SCORE"] if @board.flatten.inject(:+) >= 20000
  end
  
end

# Score is calculated when the game ends

def end_game
  
  if @win
    puts "Congratulations, you reached the FINAL tile."
    puts "Your final score was #{@board.flatten.inject(:+)}."
    @scores.push(@board.flatten.inject(:+))
  else
    puts "There are no more ajacent tiles with the same number. The game is over."
    puts "Your final score was #{@board.flatten.inject(:+)}."
    @scores.push(@board.flatten.inject(:+))
  end
  
end

# The sequences of events for a game

def play_cycle
  play
  earn_achievements
  end_game
end

play_cycle                                                  # Starts the game

response = ''                                               # Initialize variable

while response == '' || response == 'y'
  puts "HIGH SCORE: #{@scores.max}\n"
  @board = Array.new(4){[0,0,0,0]}
  puts "Would you like to play again?"
  puts "Press y for 'Yes' and n for 'No'"
  response = gets.chomp
  
  # If a player presses A, a list of the achievements they've earned will show up
  
  while response == 'a'
    puts "\n"
    puts @unlocked
	puts "\n"
	response = ''
  end
  
  # Repeats the game if player presses Yes
  play_cycle if response == 'y'

end