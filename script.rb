module TicTacToe

  #Winning combinations of 3 in a row.
  #Another way to do this would be to test dynamically instead of hard-coding the lines.
  LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9], [1, 4, 7], [2, 5, 8], [3, 6, 9], [1, 5, 9], [3, 5, 7]]

  class Game

    #The board and the current player ID must be accessible to play the game
    attr_reader :board, :current_player_id

    #Initialize the game with a new board, an array of two players, and the ID of the current player.
    def initialize()
      @board = Array.new(10)
      @current_player_id = 0
      #Self refers to the current game. Player takes a game argument so that things in Game
      #can be reached from the player class using the @game instance variable in the player class
      @players = [Player.new(self, "X"), Player.new(self, "O")]
    end

    #This is the main function that plays the game.
    #To play, this function runs a loop that asks the current player to place a marker.
    #This loop continues till one of the players gets three in a row or the board is full.
    def play
      loop do
        place_player_marker(current_player)

        if player_has_won?(current_player)
          puts "#{current_player} wins!"
          print_board
          return
        elsif board_full?
          puts "It's a draw."
          print_board
          return
        end

        switch_players!
      end
    end

    #This function evaluates which positions on the board have not been played on yet
    #The select method filters the board array for positions with a value of nil
    def free_positions
      (1..9).select { |position| @board[position].nil? }
    end

    #This function places an X or O on the board depending on whose turn it is to play
    def place_player_marker(player)
      position = player.select_position!
      puts "#{player} selects #{player.marker} position #{position}"
      @board[position] = player.marker
    end

    #Checks against the LINES array to see if either player has won
    #If any of the lines in the winning array match the criteria that each position in that line
    #equals the player's marker (x or o), returns true
    def player_has_won?(player)
      LINES.any? do |line|
        line.all? { |position| @board[position] == player.marker}
      end
    end

    #Returns true if the array of free positions is empty
    def board_full?
      free_positions.empty?
    end

    #current_player_id toggles between 0 and 1 (i.e. their indices in the @players array)
    #This function gets the id of the other player.
    #Note that we don't even have to pass in the current player
    def other_player_id
      1 - current_player_id
    end

    #Switches whose turn it is to move by toggling @current_player_id
    def switch_players!
      @current_player_id = other_player_id
    end

    def current_player
      @players[current_player_id]
    end

    def opponent
      @players[other_player_id]
    end

    #Calculates what turn it is based on how many empty spots are left on the board
    def turn_num
      10 - free_positions.size
    end

    #This method prints out the updated board to the screen after every turn.
    def print_board
      col_separator = " | "
      row_separator = "--+---+--"

      #This lambda (anonymous) function iterates over each |position| that gets passed in.
      #Looking at how the functions work together below, row_for_display uses a nested array
      #from row_positions for its |row|, and label_for_position uses each element of that 
      #nested array for its |position|. 
      #So for position 1, if @board[1] = true (that is, there's something there, not nil),
      #then it returns board[position], that is, whatever is there (x or o).
      #If there's nothing in that position, then it returns position, that is, it prints the 
      #position number (1-9) in the square.
      label_for_position = lambda{ |position| @board[position] ? @board[position] : position }

      #For each row (i.e. nested array like [1, 2, 3] below), map the row (transform it)
      #according to the &label_for_position function, which prints x, o, or the position number
      #to each square. Then join the row using the | col_separator.
      row_for_display = lambda{ |row| row.map(&label_for_position).join(col_separator)}

      #Array of the positions of the three rows on the board.
      #This array gets passed into the row_for_display lambda function above.
      row_positions = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]

      #Rows_for_display uses the row_positions array and the row_for_display lambda (anonymous) function.
      #It takes the row_positions array and maps (transforms) each element (that is, each nested array)
      #using the row_for_display lambda function.
      rows_for_display = row_positions.map(&row_for_display)

      #The puts statement actually prints the board using rows_for_display.
      puts rows_for_display.join("\n" + row_separator + "\n")
    end

  end

  class Player

    attr_reader :marker

    #Initialize with a @game instance variable and a @marker instance variable. 
    #@game seems to be how the player connects to the game being played but I'm
    #a bit confused on how/why that works.
    def initialize(game, marker)
      @game = game
      @marker = marker
    end

    def select_position!
      @game.print_board
      loop do
        print "Select your #{marker} position: "
        selection = gets.to_i
        if @game.free_positions.include?(selection)
          return selection
        else
          puts "Position #{selection} is not available. Please try again."
        end
      end
    end
  end
end

include TicTacToe

Game.new().play