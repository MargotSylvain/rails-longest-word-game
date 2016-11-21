Rails.application.routes.draw do
  get '/game' , to: 'pages#game'
  get '/score' , to: 'pages#score'
end
