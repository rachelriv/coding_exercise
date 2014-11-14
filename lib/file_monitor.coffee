chokidar = require 'chokidar'
clone = require 'clone'
FileProcessor = require './file_processor'

class FileMonitor

  # file system watcher/processor injected as dependencies for testing purposes
  # chokidar module chosen for watching since it solves some
  # of the crossplatform issues with watching files using just fs
  constructor: ({directory, @fsWatch, @processor}) ->
    @fsWatch ?= chokidar
    @processor ?= new FileProcessor
    @watcher = @fsWatch.watch directory
                              , {ignored: /[\/\\]\./, persistent: true}

  startMonitoring: ->
    output = {}
    startTimes = {}
    @watcher.on 'add', (filePath) =>
      startTimes[filePath] = Date.now()
      @processor.process { startTimes, filePath, output }

    # print output and reset each second
    setInterval =>
        # default avgProcessingTime if no files were processed
        output.avgProcessingTime ?= 0
        console.log JSON.stringify output
        output = @resetOutput output
      , 1000

  resetOutput: (output) ->
    (output[k] = 0 for k in Object.keys(output))
    output

module.exports = FileMonitor