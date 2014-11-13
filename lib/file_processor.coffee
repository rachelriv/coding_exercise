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
    currentProcessingTime = Date.now() - startTimes[filePath]
    endtime = Date.now()
    console.log "endTime for #{filePath}: #{endtime}"
    output


module.exports = FileProcessor