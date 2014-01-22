fs = require 'fs'
async = require 'async'
loadGame = require './game'

fileName = process.argv[2]
questionsPerTour = parseInt process.argv[3], 10

async.waterfall [
  (cb) ->
    fs.readFile fileName, cb
  loadGame
], (err, game) ->
  if err
    console.log "ERROR", err
  else
    console.log game.exportForRating questionsPerTour
