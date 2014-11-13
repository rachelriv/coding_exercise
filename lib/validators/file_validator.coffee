class FileValidator

  validate: (file, callback) ->
    callback null, {status: 'success'}

module.exports = FileValidator