class Computer
  COLORS = ["red","green","blue","yellow","purple","orange"]

  def current_guess(s)
    some = s.length
    if s.length == 1296
      ["red","red","green","green"]
    elsif s.length == 0
      raise "There seems to have been some inconsistencies with the guesses."
    else
      s.first
    end
  end

  def eliminate_patterns(seed, current_guess, feedback)
    result = []

    0.upto(seed.length - 1).each do |n|
      current_in_index = seed[n]
      if guess(current_guess, current_in_index) == feedback
        result << current_in_index
      end
    end
    result
  end

  def generate_patterns
    COLORS.repeated_permutation(4).to_a.sort!
  end

  def guess(code, guess)
    control = Array.new(4) { |x| x = 0 }
    control_guess = code.dup

    guess.each_index do |i|
      if guess[i] == code[i]
        control[i] = 1
        control_guess[i] = nil
        next
      end
    end

    code.each_index do |i|
      if control_guess.include?(guess[i]) && control[i] == 0
        control[i] = 2
        next
      end
    end
    [control.count(1), control.count(2)]
  end

  def exact_match(index)

  end
end
