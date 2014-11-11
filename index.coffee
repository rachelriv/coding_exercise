DirectoryValidator = require './lib/directory_validator'
FileMonitor = require './lib/file_monitor'
path = require 'path'

if process.argv.length isnt 3
  console.error "Requires one commandline argument:
                 the directory that you would like to monitor"
  process.exit(1)

providedDirectory = path.resolve(__dirname, process.argv[2])
directoryValidator = new DirectoryValidator

directoryValidator.validate providedDirectory, (err, results) ->
  unless wasSuccessfulValidation results
    console.error err
    process.exit(1)
  else
    fileMonitor = new FileMonitor providedDirectory
    fileMonitor.startMonitoring()

wasSuccessfulValidation = (results) ->
  for result in results
    console.log "result " + JSON.stringify(result)
    if result.status isnt 'success'
      console.error result.message
      process.exit(1)