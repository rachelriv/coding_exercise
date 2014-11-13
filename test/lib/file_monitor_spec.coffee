chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
chai.use(require 'sinon-chai')
FileMonitor = require '../../lib/file_monitor'
FileProcessor = require '../../lib/file_processor'


describe 'FileMonitor', ->

  describe '#startMonitoring', ->
    beforeEach ->
      @watcher = on: sinon.stub().callsArg 1
      @fsWatch = watch: sinon.stub().returns @watcher
      @processor = process: sinon.stub()
      @directory = '/some/valid/directory/path'
      @fileMonitor = new FileMonitor {@directory, @fsWatch, @processor}
      @fileMonitor.getInitialOutput = sinon.stub().returns sample: 'output'

    context 'when first beginning to monitor', ->
      beforeEach ->
        @fileMonitor.startMonitoring()

      it 'initializes the output status', ->
        expect(@fileMonitor.getInitialOutput).to.have.been.called

      it 'adds a listener for when files are added', ->
        expect(@watcher.on).to.have.been.calledWith 'add'

    context 'when a file is added', ->
      beforeEach ->
        @watcher.on.callsArgWith 1, 'added/file.json'
        sinon.stub(Date, 'now', -> 12345)
        @fileMonitor.startMonitoring()

      afterEach ->
        Date.now.restore()

      it 'sets the start time for when the file was added', ->
        expect(Date.now).to.have.been.called

      it 'processes the added file', ->
        expect(@processor.process).to.have.been
          .calledWith
            startTime: 12345
            filePath: 'added/file.json'
            output: sample: 'output'

    context 'when less than one second has passed', ->
      beforeEach ->
        @clock = sinon.useFakeTimers(0, 'setInterval')
        sinon.spy(process.stdout, 'write')
        @fileMonitor.getInitialOutput = sinon.spy()
        @fileMonitor.startMonitoring()

      afterEach ->
        @clock.restore()
        process.stdout.write.restore()

      it 'does not log anything to standard output', ->
        # tick 999 ms (less than 1 second)
        @clock.tick 999
        expect(process.stdout.write).to.not.have.been.called

    context 'when one second has passed', ->
      beforeEach ->
        @clock = sinon.useFakeTimers(0, 'setInterval')
        sinon.spy(process.stdout, 'write')
        @fileMonitor.startMonitoring()

      afterEach ->
        @clock.restore()
        process.stdout.write.restore()

      it 'logs the current output to stdout exactly once', ->
        @clock.tick 1000
        expect(process.stdout.write).to.have.been.calledOnce
        expect(process.stdout.write).to.have.been
          .calledWith JSON.stringify sample: 'output'

    context 'when 100 seconds have passed', ->
      beforeEach ->
        @clock = sinon.useFakeTimers(0, 'setInterval')
        sinon.stub(process.stdout, 'write')
        @fileMonitor.startMonitoring()

      afterEach ->
        @clock.restore()
        process.stdout.write.restore()

      it 'logs the current output to stdout 100 times', ->
        @clock.tick 100000
        expect(process.stdout.write.callCount).to.equal 100

