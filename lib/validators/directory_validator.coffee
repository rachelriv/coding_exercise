async = require 'async'
path = require 'path'
fs = require 'fs'

class DirectoryValidator

  # filesystem injected as a dependency for testing purposes
  constructor: (@filesystem = fs) ->

  validate: (directoryPath, callback) ->
    async.series [
      (eachCallback) => @checkForExistence directoryPath, eachCallback,
      (eachCallback) => @checkIsDirectory directoryPath, eachCallback
    ]
    , callback

  checkForExistence: (path, callback) ->
    @filesystem.exists path, (exists) ->
      unless exists
        callback 'Specified path does not exist'
      else
        callback null, {status: 'success'}

  checkIsDirectory: (path, callback) ->
    @filesystem.stat path, (err, stats) ->
      return callback err if err
      unless stats?.isDirectory()
        callback 'Specified path is not a directory'
      else
        callback null, {status: 'success'}

module.exports = DirectoryValidator
