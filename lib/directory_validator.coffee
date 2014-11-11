async = require 'async'
path = require 'path'
fs = require 'fs'

class DirectoryValidator
  validate: (directoryPath, callback) ->
    async.series [
      (eachCallback) => @checkForExistence directoryPath, eachCallback,
      (eachCallback) => @checkIsDirectory directoryPath, eachCallback
    ]
    , callback


  checkForExistence: (path, callback) ->
    fs.exists path, (exists) ->
      console.log "path #{path}"
      unless exists
        callback null
                 , {message: 'Specified directory does not exist', status:  'failure'}
      else
        callback null, {status: 'success'}

  checkIsDirectory: (path, callback) ->
    fs.stat path, (err, stats) ->
      return callback err if err
      unless stats?.isDirectory()
        callback null
                 , {message: 'Specified path is not a directory', status:  'failure'}
      else
        callback null, {status: 'success'}

module.exports = DirectoryValidator