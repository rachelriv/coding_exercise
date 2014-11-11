# chokidar is a neat wrapper around node.js js.watch / fs.watchFile
# that is compatible with OS X
chokidar = require 'chokidar'
watcher = chokidar.watch('.', {ignored: /[\/\\]\./, persistent: true});

watcher.on 'add', (path) ->
  result.push "File #{path} has been added"

report = ->
  console.log result
  result = []

setInterval(report, 10000)
