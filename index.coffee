DirectoryValidator = require './lib/directory_validator'
FileMonitor = require './lib/file_monitor'
path = require 'path'

if process.argv.length isnt 3
  console.error "Requires one commandline argument:
                 the directory that you would like to monitor"
  process.exit(1)

providedDirectory = path.resolve(__dirname, process.argv[2])
directoryValidator = new DirectoryValidator

directoryValidator.validate providedDirectory, (error, results) ->
  if error
    console.error error
    process.exit(1)
  else
    fileMonitor = new FileMonitor providedDirectory
    fileMonitor.startMonitoring()