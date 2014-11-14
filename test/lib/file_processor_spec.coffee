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
