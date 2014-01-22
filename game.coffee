xml2js = require 'xml2js'
_ = require 'lodash'

class Game
  constructor: (gameObj) ->
    data = gameObj.gameset
    @name = data.$.title
    @date = data.$.date
    @questionsNumber = parseInt data.$.questionsNumber, 10
    teamsData = data.teams[0].team
    @teams = {}
    for team in teamsData
      @teams[team.$.number] = newTeam = _.pick team.$, 'name', 'city'
      newTeam.results = (false for i in [0...@questionsNumber])
      for i in team.questionNumbers[0].split /\s*,\s*/
        newTeam.results[parseInt(i, 10) - 1] = true

  exportForRating: (questionsPerTour) ->
    if questionsPerTour
      @questionsPerTour = questionsPerTour
      if @questionsNumber % @questionsPerTour
        throw new Error 'Число вопросов не кратно размеру тура'
      @toursNumber = @questionsNumber / @questionsPerTour
    res = []
    output = (row) ->
      res.push row.join(';')
    output ['IDteam', 'Название', 'Город', 'Тур'].concat [1..@questionsPerTour]
    for teamNumber, team of @teams      
      for tourNumber in [1..@toursNumber]
        results = ((if team.results[i] then 1 else '') for i in [(tourNumber - 1) * @questionsPerTour ... tourNumber * @questionsPerTour])
        output ['', team.name, team.city, tourNumber].concat results
    res.join '\n'


module.exports = (data, cb) ->
  xml2js.parseString data, (err, obj) ->
    cb err, not err and new Game(obj)