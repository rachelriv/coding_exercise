chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
chai.use(require 'sinon-chai')
FileProcessor = require '../../lib/file_processor'

describe 'FileProcessor', ->
  describe '#process', ->
    beforeEach ->
      @jsonFile = readFile: sinon.stub().callsArg 1
      @fileProcessor = new FileProcessor @jsonFile

    context 'when the file is not JSON', ->
      beforeEach ->
        input =
          startTimes: {}
          filePath: '/path/to/nonJSONFile.txt'
          output: {}
        @fileProcessor.process input

      it 'does not read the file', ->
        expect(@jsonFile.readFile).to.not.have.been.called

    context 'when the file is JSON', ->
      beforeEach ->
        @input =
          startTimes: {}
          filePath: '/path/to/JSONFile.json'
          output: some: 'stuff'

      it 'reads the file', ->
        @fileProcessor.process @input
        expect(@jsonFile.readFile).to.have.been.called

      context 'when no error occurs parsing the JSON', ->
        beforeEach ->
          @parsedObj = Type: 'Example'
          @jsonFile.readFile.callsArgWith 1, null, @parsedObj
          @fileProcessor.updateCount = sinon.spy()
          @fileProcessor.updateAvgProcessingTime = sinon.spy()
          @fileProcessor.process @input

        it 'updates the count of that type in the output', ->
          expect(@fileProcessor.updateCount).to.have.been
            .calledWith @parsedObj

        it 'updates the average processing time
            after the count has been updated', ->
          expect(@fileProcessor.updateAvgProcessingTime).to.have.been
            .calledAfter @fileProcessor.updateCount

      context 'when an error occurs parsing the JSON', ->
        beforeEach ->
          @jsonFile.readFile.callsArgWith 1, 'error parsing JSON'
          @fileProcessor.updateCount = sinon.spy()
          @fileProcessor.updateAvgProcessingTime = sinon.spy()
          @fileProcessor.process @input

        it 'does not call #updateCount', ->
          expect(@fileProcessor.updateCount).to.not.have.been.called

        it 'does not call #updateAvgProcessingTime', ->
          expect(@fileProcessor.updateAvgProcessingTime).to.not
            .have.been.called


  describe '#updateCount', ->
    beforeEach ->
      @fileProcessor = new FileProcessor

    context 'when the JSON input specifies a "Type"', ->
      beforeEach ->
        input = Type: 'Example'
        @output = {}
        @fileProcessor.updateCount input, @output

      it 'adds/increments the count of the given type in the output', ->
        expect(@output.ExampleCnt).to.equal 1

    context 'when the JSON input does not specify a "Type"', ->
      beforeEach ->
        input = missing: 'Type'
        @output = {}
        @fileProcessor.updateCount input, @output

      it 'does not add or increment any counts in the output', ->
        expect(@output).to.eql {}


  describe '#updateAvgProcessingTime', ->
    context 'when the previous processing time exists', ->
      beforeEach ->
        @startTimes =
          'file1': 0
        @output = avgProcessingTime: 10
        @filePath = 'file1'
        @fileProcessor = new FileProcessor
        sinon.stub(Date, 'now', -> 5)
        @fileProcessor.getTotalCount = sinon.stub().returns 7
        @fileProcessor.updateAvgProcessingTime {startTimes: @startTimes, output: @output, filePath: @filePath}

      afterEach ->
        Date.now.restore()

      it 'gets the total count', ->
        expect(@fileProcessor.getTotalCount).to.have.been.called

      it 'computes the average by adding the weighted old average with the weighted new time', ->
        count = 7
        oldAvg = 10
        newTime = 5
        weightedOldAvg = oldAvg * ((count - 1)/ count)
        weightedNewTime = newTime * (1/count)
        expect(@output.avgProcessingTime).to.equal (weightedOldAvg + weightedNewTime)

    context 'when the previous processing time does not exist', ->
      beforeEach ->
        @startTimes =
          'file1': 0
        @output = {}
        @filePath = 'file1'
        @fileProcessor = new FileProcessor
        sinon.stub(Date, 'now', -> 5)
        @fileProcessor.getTotalCount = sinon.stub().returns 1
        @fileProcessor.updateAvgProcessingTime {startTimes: @startTimes, output: @output, filePath: @filePath}

      afterEach ->
        Date.now.restore()

      it 'sets the most recent time to the new average', ->
        expect(@output.avgProcessingTime).to.equal 5
