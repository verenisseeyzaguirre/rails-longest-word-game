require 'open-uri'
require 'json'

class GamesController < ApplicationController
  def new
    @letters = generate_grid(10)
  end

  def score
    @sum = session[:score] || 0
    @word = params[:word]
    p "words is"
    p @word
     p "letters is"
    @letters = params[:letters].split(' ')
    p @letters
    @result = run_game(@word, @letters)
    session[:score] = @sum + @result[:score]
  end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    (0...grid_size).map { ('A'..'Z').to_a[rand(26)] }
  end

  def run_game(attempt, grid)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    result_serialized = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}").read
    result_parsed = JSON.parse(result_serialized)
    p "grid"
    p grid
    p "attempt"
    p attempt
    num_chars_validated = validate_word(grid, attempt)
    is_validated = result_parsed['length'] == num_chars_validated
    if result_parsed['found']
      if is_validated
        total_score = (result_parsed['length'] * 1000)
        message = 'Well Done!'
      else
        total_score = 0
        message = 'Sorry but @word can not be built out'
      end
    else
      total_score = 0
      message = 'Sorry but @word does not seem to be a valid English word'
    end
    { score: total_score, message: message}
  end

  def validate_word(grid, attempt)
    correctas = 0
    p "q es grid"
    p grid
    grid_string = grid * ''
    grid_string.upcase!
    grid_string = grid.upcase
    attempt.upcase!
    until grid_string.empty?
      grid_string.each_char do |char|
        if attempt.include?(char)
          correctas += 1
          attempt = attempt.sub(char, '')
        end
        grid_string = grid_string.sub(char, '')
      end
    end
    return correctas
  end
end
