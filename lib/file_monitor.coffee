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
    output = @getInitialOutput()
    @watcher.on 'add', (filePath) =>
      startTime = Date.now()
      @processor.process { startTime, filePath, output }

    # print output and reset for next second interval
    setInterval =>
        console.log JSON.stringify output
        currentOutput = @getInitialOutput()
      , 1000


  getInitialOutput: ->
    DoorCnt: 0
    ImgCnt: 0
    AlarmCnt: 0
    avgProcessingTime: 0

module.exports = FileMonitor