class WordGuesserGame
  # Attributes for the game's state.
  attr_accessor :word, :guesses, :wrong_guesses

  # Get a word from remote "random word" service
  def self.get_random_word
    require 'uri'
    require 'net/http'
    uri = URI('http://randomword.saasbook.info/RandomWord')
    Net::HTTP.new('randomword.saasbook.info').start do |http|
      return http.post(uri, "").body
    end
  end

  # Initializes a new game.
  # @param word [String] The secret word for the game.
  def initialize(word)
    @word = word
    @guesses = ''
    @wrong_guesses = ''
  end

  # Processes a player's guess.
  # @param letter [String, nil] The letter being guessed.
  # @return [Boolean] false if the guess is a repeat, true otherwise.
  # @raise [ArgumentError] if the guess is invalid (not a single letter).
  def guess(letter)
    # 1. Validate the input
    if letter.nil? || letter.empty? || !letter.match?(/^[a-zA-Z]$/)
      raise ArgumentError, 'Invalid guess.'
    end
    
    letter = letter.downcase

    # 2. Check for repeated guesses
    if @guesses.include?(letter) || @wrong_guesses.include?(letter)
      return false
    end

    # 3. Process the new, valid guess
    if @word.include?(letter)
      @guesses += letter
    else
      @wrong_guesses += letter
    end
    
    true
  end

  # Returns a string showing the word with correctly guessed letters revealed.
  # Unguessed letters are represented by hyphens.
  # Example: word="banana", guesses="bn" => "b-n-n-"
  # @return [String] The word with guesses displayed.
  def word_with_guesses
    # Iterate over each character of the word. If the character is in our
    # correct guesses string, keep it. Otherwise, replace it with a hyphen.
    # Finally, join the characters back into a single string.
    @word.chars.map { |char| @guesses.include?(char) ? char : '-' }.join
  end

  # Checks the current status of the game.
  # @return [Symbol] :win, :lose, or :play.
  def check_win_or_lose
    # A player wins if all unique letters in the word have been guessed.
    # We can check this by seeing if the displayed word has no more hyphens.
    return :win if !word_with_guesses.include?('-')

    # A player loses if they have made 7 or more wrong guesses.
    return :lose if @wrong_guesses.length >= 7

    # Otherwise, the game is still in progress.
    :play
  end
end
