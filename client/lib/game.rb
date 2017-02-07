require_relative 'computer'
require_relative 'user'


class Game
  def initialize(output, computer, user)
    @output = output
    @computer = computer
    @user = user
  end
  def start
    @output.puts "Starting new game..."
    feedback = []
    guesses = []
    feedbacks = []
    guess_num = 0
    @user.register
    s = @computer.generate_patterns
    while feedback[0] != 4
      guess = @computer.current_guess(s)
      #@output.puts "\n#{guess}"
      feedback = @user.give_feedback(guess)
      guesses << guess
      feedbacks << feedback
      s = @computer.eliminate_patterns(s, guess, feedback)
      guess_num += 1
      @output.puts "||  #{guess}  || #{feedback}"
      #:build_board(guesses, feedbacks)
    end
    @output.puts "Yay! Game over in #{guess_num} " + pluralize(guess_num)
  end

  def pluralize(number)
    number == 1 ? "try" : "tries"
  end

  def build_board(guess, feedback)
    guess.each_index do |e|
      @output.puts "||  #{guess[e]}  || #{feedback[e]}"
    end
  end
end
