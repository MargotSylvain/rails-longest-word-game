require 'open-uri'
require 'json'

class PagesController < ApplicationController
 def game
   @grid = generate_grid(@size)
   @size = params[:number].to_i
 end

 def score
   @grid = params[:grid].downcase
   @trial = params[:shot]
   @start_time = Time.parse(params[:start_time])
   @time_taken = Time.now - @start_time
   included?(@trial, @grid)
   compute_score(@trial, @time_taken)
   get_translation(@trial)
   @score = score_and_message(@trial, @grid, @time_taken)
 end


 def generate_grid(grid_size)
   letters = Array.new(params[:number].to_i) { ('A'..'Z').to_a[rand(26)] }
   letters.join(", ").downcase
 end

 def included?(trial, grid)
   trial.split("").all? { |letter| trial.count(letter) <= grid.count(letter) }
 end

 def compute_score(trial, time_taken)
   (time_taken > 120.0) ? 0 : trial.size * (1.0 - time_taken / 60.0)
 end

 def score_and_message(trial, grid, time_taken)
   if included?(trial, grid)
     if get_translation(trial)
       @score = compute_score(trial, time_taken)
       return "#{@score} - Well done in #{time_taken} !"
     else
       @score = 0
       return "not an english word"
     end
   else
     @score = 0
     return "not in the grid"
   end
 end

 def get_translation(word)
   api_key = "fe904a78-2bf3-402f-a109-eea62b728943"
   begin
     response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
     json = JSON.parse(response.read.to_s)
     if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
       return json['outputs'][0]['output']
     end
   rescue
     if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
       return word
     else
       return nil
     end
   end
 end

end
