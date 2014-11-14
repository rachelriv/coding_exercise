util = require 'util'
path = require 'path'

class FileProcessor

  # JSON file reader injected as a dependency for testing
  constructor: (@jsonfile) ->
    @jsonfile ?= require 'jsonfile'

  process: ({startTimes, filePath, output}) ->
    if path.extname(filePath) is '.json'
      @jsonfile.readFile filePath, (error, inputObj) =>
        unless error
          @updateCount inputObj, output
          @updateAvgProcessingTime {startTimes, filePath, output}

  updateCount: (input, output) ->
    if input?.Type
      countToUpdate = "#{input.Type}Cnt"
      output[countToUpdate] ?= 0
      output[countToUpdate]++

  updateAvgProcessingTime: ({startTimes, filePath, output}) ->
    totalCount = @getTotalCount output
    weightedOldAvg = (output.avgProcessingTime or 0) * ((totalCount-1)/totalCount)
    weightedNewTime = (Date.now() - startTimes[filePath]) * (1/totalCount)
    output.avgProcessingTime = weightedOldAvg + weightedNewTime
    output

  getTotalCount: (output) ->
    totalCount = 0
    for key, value of output
      totalCount += value if key.match(/Cnt/)
    totalCount


module.exports = FileProcessor