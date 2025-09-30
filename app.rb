require 'sinatra/base'
require 'sinatra/flash'
require_relative 'lib/wordguesser_game'

class WordGuesserApp < Sinatra::Base
  enable :sessions
  register Sinatra::Flash

  set :host_authorization, { permitted_hosts: [] }  

  before do
    @game = session[:game] || WordGuesserGame.new('')
  end

  after do
    session[:game] = @game
  end

  # These two routes are good examples of Sinatra syntax
  # to help you with the rest of the assignment
  get '/' do
    redirect '/new'
  end

  get '/new' do
    erb :new
  end

  post '/create' do
    # NOTE: don't change next line - it's needed by autograder!
    word = params[:word] || WordGuesserGame.get_random_word
    # NOTE: don't change previous line - it's needed by autograder!

    @game = WordGuesserGame.new(word)
    redirect '/show'
  end

  # Use existing methods in WordGuesserGame to process a guess.
  # If a guess is repeated, set flash[:message] to "You have already used that letter."
  # If a guess is invalid, set flash[:message] to "Invalid guess."
  post '/guess' do
    # REMOVED the redundant line that did nothing.
    letter = params[:guess].to_s[0]
    begin
      if !@game.guess(letter)
        flash[:message] = "You have already used that letter."
      end
    rescue ArgumentError
      flash[:message] = "Invalid guess."
    end
    redirect '/show'
  end

  # Everytime a guess is made, we should eventually end up at this route.
  # Use existing methods in WordGuesserGame to check if player has
  # won, lost, or neither, and take the appropriate action.
  get '/show' do
    # This logic is now clean. It will either redirect OR render, never both.
    case @game.check_win_or_lose
    when :win
      redirect '/win'
    when :lose
      redirect '/lose'
    else # The return value is :play
      erb :show
    end
    # REMOVED the extra 'erb :show' from the end of the block.
  end

  get '/win' do
    # This logic is now clean.
    if @game.check_win_or_lose == :win
      erb :win
    else
      redirect '/show'
    end
    # REMOVED the extra 'erb :win' from the end of the block.
  end

  get '/lose' do
    # This logic is now clean.
    if @game.check_win_or_lose == :lose
      erb :lose
    else
      redirect '/show'
    end
    # REMOVED the extra 'erb :lose' from the end of the block.
  end
end
