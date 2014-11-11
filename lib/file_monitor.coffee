chokidar = require 'chokidar'

class FileMonitor
  constructor: (folder) ->
    @watcher = chokidar.watch folder
                              , {ignored: /[\/\\]\./, persistent: true}

  startMonitoring: ->
    @watcher.on 'add', (path) ->
      result.push "File #{path} has been added"
    setInterval(@report, 10000)

  report = ->
    console.log result
    result = []

module.exports = FileMonitor