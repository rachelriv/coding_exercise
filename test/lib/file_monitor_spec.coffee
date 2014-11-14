chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
chai.use(require 'sinon-chai')
FileMonitor = require '../../lib/file_monitor'


describe 'FileMonitor', ->

  describe '#startMonitoring', ->
    beforeEach ->
      @watcher = on: sinon.stub().callsArg 1
      @fsWatch = watch: sinon.stub().returns @watcher
      @processor = process: sinon.stub()
      @directory = '/some/valid/directory/path'
      @fileMonitor = new FileMonitor {@directory, @fsWatch, @processor}

    context 'when first beginning to monitor', ->
      beforeEach ->
        @fileMonitor.startMonitoring()

      it 'adds a listener that listens for when files are added', ->
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
            startTimes: 'added/file.json': 12345
            filePath: 'added/file.json'
            output: {}

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
        sinon.stub(process.stdout, 'write')
        @fileMonitor.startMonitoring()
        @clock.tick 1000

      afterEach ->
        @clock.restore()

      it 'logs the current output to stdout exactly once', ->
        callCount = process.stdout.write.callCount

        # unstub writing to standard output so
        # the results of this test are logged
        process.stdout.write.restore()

        expect(callCount).to.equal 1

    context 'when 100 seconds have passed', ->
      beforeEach ->
        @clock = sinon.useFakeTimers(0, 'setInterval')
        sinon.stub(process.stdout, 'write')
        @fileMonitor.startMonitoring()
        @clock.tick 100000

      afterEach ->
        @clock.restore()

      it 'logs the current output to stdout 100 times', ->
        callCount = process.stdout.write.callCount

        # unstub writing to standard output so
        # the results of this test are logged
        process.stdout.write.restore()

        expect(callCount).to.equal 100


  describe '#resetOutput', ->
    beforeEach ->
      @fileMonitor = new FileMonitor directory: '/some/directory'
      @output =
        a: 1
        b: 20
      @resetOutput =
        a: 0
        b: 0
      @fileMonitor.resetOutput @output

    it 'reset the output values to all be zero', ->
      expect(@output).to.eql @resetOutput


