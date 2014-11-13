FileValidator = require './validators/file_validator'
jsonfile = require 'jsonfile'
util = require 'util'

class FileProcessor

  constructor: ->
    @fileValidator = new FileValidator

  process: ({startTime, filePath, output}) ->
    # @fileValidator.validate file, (error, results) =>
    # unless error
    jsonfile.readFile filePath, (err, obj) =>
      input = util.inspect obj
      @updateOutput input, output
      @updateAvgProcessingTime output

  updateOutput: (input, output) ->
    countToUpdate = "#{input.Type}Cnt"
    output[countToUpdate]++

  updateAvgProcessingTime: (output) ->
    newTotalCounts = output.DoorCnt + output.ImgCnt + output.AlarmCnt
    oldTotalCounts = newTotalCounts - 1
    newestProcessingTime = Date.now() - output.startTime
    output.avgProcessingTime = (output.avgProcessingTime * (oldTotalCounts / newTotalCounts)) + (newestProcessingTime * (1/newTotalCounts))



module.exports = FileProcessor