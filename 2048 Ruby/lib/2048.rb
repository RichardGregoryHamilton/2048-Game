['io/console', 'colorize'].each{ |g| require g }

  @achievements = {16    => "Unlock the 16 Tile", 
                   32    => "Unlock the 32 Tile",
                   64    => "Unlock the 64 Tile",
                   128   => "Unlock the 128 Tile",
                   256   => "Unlock the 256 Tile",
                   512   => "Unlock the 512 Tile",
                   1024  => "Unlock the 1024 Tile",
                   2048  => "Unlock the 2048 Tile",
                   4096  => "Unlock the 4096 Tile",
                   8192  => "Unlock the 8192 Tile",
                   16384 => "Unlock the 16384 Tile",
                   "Score 500"     => "Earn more than 500 points",
                   "Score 1000"    => "Earn more than 1000 points",
                   "Score 2000"    => "Earn more than 2000 points",
                   "Score 5000"    => "Earn more than 5000 points",
                   "Score 10000"   => "Earn more than 10000 points",
                   "HIGHEST SCORE" => "Earn more than 20000 points"}

  @unlocked = []
  @board    = Array.new(4) { [0,0,0,0] } 

  def game_score
    @board.flatten.inject(:+)
  end

  def high_score 
    [game_score, @scores.max].max
  end

  def colorize_score
    game_score.to_s.yellow
  end

  def show_score
    puts "\t\t Score: #{game_score == high_score ? colorize_score : game_score} " <<
         "High Score: #{game_score == high_score ? colorize_score : high_score} " <<
         "Achievements: #{@unlocked.count}"
    puts "\t\t ________________________________________"
  end
  
  def draw_board
    show_score
    for x in 0..3
      print "\t\t| "
      for y in 0..3
        number = @board[x][y]                                     # Coordinates we will place tiles
        print color_num(number) << "| "                           # Prints a color-coded number, see color_num method
      end
      puts ""
    end
    puts ""
  end

  def new_tile
    tile = [*1..2].sample * 2                                      # Will generate either a 2 or a 4
    x    = [*0..3].sample
    y    = [*0..3].sample
    for i in 0..3
      for j in 0..3
        x1 = (x + i) % 4
        y1 = (y + j) % 4
        if @board[x1][y1] == 0
          @board[x1][y1] = tile                                # If space is empty, a new title is generated
          return true
        end
      end
    end
    false
  end

  def color_num(num)
    number = '%4.4s' % num                                     # Shifts number to the right a few spaces
    color = ""                                                 # Initialize color variable
    
    numbers = [0]
    (1..14).each { |n| numbers.push (2 ** n) }
    colors = [:white, :white, :light_red, :red, :light_yellow, :yellow, :light_cyan,
    :cyan, :light_green, :green, :light_blue, :blue, :light_magenta, :magenta]
    colors_array = [numbers.zip(colors)].flatten(1)
    
    for i in 0..colors_array.length-1
      color = number.colorize(colors_array[i][1]) if num == colors_array[i][0]
    end
    
    color.underline
  end

  # Receive and process user input

  def get_input
    input = ''
    controls = ['a', 's', 'd', 'w']
    until controls.include?(input) do
      input = STDIN.getch                                      # Implemented so player does not have to press Enter"
      abort "escaped" if input == "\e" 
    end 
    input 
  end 

  def flip_board
    @board.transpose.map(&:reverse)
  end
  
  # Creates a new line after the user enters a direction

  def shift_left(line)
    new_line = []
    line.each { |l| new_line << l unless l.zero? }
    new_line << 0 until new_line.size == 4
    new_line
  end

  # Moves tiles to the left

  def move_left
    new_board = Marshal.load(Marshal.dump(@board))             # Creates a new board object using the data from @board
    for i in 0..3
      for j in 0..3
        for k in j..2
          if @board[i][k + 1] == 0 
            next
          elsif @board[i][j] == @board[i][k + 1]
            @board[i][j] = @board[i][j] * 2                # Tile is doubled if 2 adjacent tiles connect
            @board[i][k + 1] = 0                             # Original Tile is eliminated
          end
        break
        end
      end
    @board[i] = shift_left(@board[i])
    end
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
    @board = flip_board
    action = move_left
    3.times { @board = flip_board }       # Mapped 3 times to retain positioning
    action
  end

  # Move tiles up

  def move_up
    3.times { @board = flip_board }
    action = move_left
    @board = flip_board
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
    unless option
      option = move_left
      unless option
        option = move_up
        unless option
          option = move_down
          unless option
            @board = Marshal.load(Marshal.dump(new_board))
            return true
          end
        end
      end
    end
    @board = Marshal.load(Marshal.dump(new_board))
    false
  end

  def get_tiles
    2.times { new_tile }
    draw_board
    @win = true
  end
  
  def make_move
    direction = get_input

    case direction
      when 'a' then action = move_left
      when 'd' then action = move_right
      when 'w' then action = move_up
      when 's' then action = move_down
    end
    
    new_tile if action
  end
  
  def move_sequence
    until win_checker
   
      make_move
      draw_board
    
      if loss_checker
        @win = false
        break                                                  # Loop will end if a player loses
      end
    
    end
  end
  
  @scores = [0]                                                # This will store the scores recorded for every game

  def greeting
    puts "\n\t\t Welcome to 2048!"
    puts "\n\t\t RULES"
    puts "\n\t\t Match powers of 2 by connecting ajacent identical numbers."
    puts "\n\t\t CONTROLS"
    puts "\n\t\t a - Move left"
    puts "\t\t d - Move right"
    puts "\t\t w - Move up"
    puts "\t\t s - Move down"
    puts "\n"
  end
  
  # Event Sequence for every game

  def play
    greeting
    get_tiles
    move_sequence
  end

  def unlock_tiles
    [16,32,64,128,256,512,1024,2048,4096,8192,16384].each do |a|
      unless @unlocked.include?(@achievements[a])
        @unlocked << @achievements[a] if (@board.flatten.include?(a))
      end
    end
  end
  
  def reach_milestones
    [500,1000,2000,5000,10000].each do |score|
      unless @unlocked.include?(@achievements["Score #{score}"])
        @unlocked << @achievements["Score #{score}"] if game_score >= score
      end
    end
  end
  
  def highest_honor
    unless @unlocked.include?(@achievements["HIGHEST SCORE"])
      @unlocked << @achievements["HIGHEST SCORE"] if game_score >= 20000
    end
  end
  
  def earn_achievements
    unlock_tiles
    reach_milestones
    highest_honor
  end

  def win_message
    puts "\t\t Congratulations! You reached the FINAL tile!".yellow
    puts "\n\t\t Your final score was #{game_score}."
    puts "\n\t\t Press 'a' to view your achievements!\n"
    @scores << game_score
  end
  
  def lose_message
    puts "\t\t There are no more ajacent tiles with the same number.".red
    puts "\t\t The game is over".red
    puts "\n\t\t Your final score was #{game_score}."
    puts "\n\t\t Press 'a' to view your achievements!\n"
    @scores << game_score
  end
  
  def end_game
    @win ? win_message : lose_message
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
    puts "\t\t HIGH SCORE: #{@scores.max}\n"
    @board = Array.new(4){[0,0,0,0]}
    puts "\n\t\t Would you like to play again?"
    puts "\t\t Press y for 'Yes' and n for 'No'"
    response = gets.chomp
    
    # If a player presses A, a list of the achievements they've earned will show up
    
    while response == 'a'
      puts "\n\t\t ACHIEVEMENTS \n\n"
      @unlocked.each {|a| puts "\t\t " << a}
      puts "\n"
      response = ''
    end
    
    play_cycle if response == 'y'                             # Repeats the game if player presses Yes

  end