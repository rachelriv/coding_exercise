chai = require 'chai'
sinon = require 'sinon'
expect = chai.expect
chai.use(require 'sinon-chai')
DirectoryValidator = require '../../lib/directory_validator'


describe 'DirectoryValidator', ->
  describe '#validate', ->
    beforeEach ->
      @directoryValidator = new DirectoryValidator
      @directoryValidator.checkForExistence = sinon.stub().callsArg 1
      @directoryValidator.checkIsDirectory = sinon.stub().callsArg 1

    context 'when there are no errors validating the path', ->
      beforeEach (done) ->
        @directoryValidator.checkForExistence
          .callsArgWith 1, null, {status: 'success'}
        @directoryValidator.checkIsDirectory
          .callsArgWith 1, null, {status: 'success'}
        @directoryValidator.validate '/some/directory/path'
                                     , (@error, @results) => done()

      it 'checks that the path exists', ->
        expect(@directoryValidator.checkForExistence).to.have.been.calledWith '/some/directory/path'

      it 'checks that the path is a directory', ->
        expect(@directoryValidator.checkIsDirectory).to.have.been.calledWith '/some/directory/path'

      it 'does not return an error in the callback', ->
        expect(@error).to.be.undefined

    context 'when an error occurs validating the path', ->
      context 'when the error occurs in #checkForExistence', ->
        beforeEach (done) ->
          @directoryValidator.checkForExistence
            .callsArgWith 1, 'path does not exist'
          @directoryValidator.validate '/some/directory/path'
                                     , (@error, @results) => done()

        it 'returns an error that the path does not exist in the callback', ->
          expect(@error).to.equal 'path does not exist'

        it 'does not call #checkIsDirectory', ->
          expect(@directoryValidator.checkIsDirectory).to.not.have.been.called

      context 'when the error occurs in #checkIsDirectory', ->
        beforeEach (done) ->
          @directoryValidator.checkIsDirectory
            .callsArgWith 1, 'path is not a directory'
          @directoryValidator.validate '/some/directory/path'
                                     , (@error, @results) => done()

        it "returns an error that the path isn't a directory in the callback", ->
          expect(@error).to.equal 'path is not a directory'


  describe '#checkForExistence', ->
    context 'when the path does not exist', ->
      beforeEach (done) ->
        filesystem = exists: sinon.stub().callsArgWith 1, false
        @directoryValidator= new DirectoryValidator filesystem
        @directoryValidator.checkForExistence 'some/path', (@error, @result) => done()

      it 'returns an error in the callback', ->
        expect(@error).to.equal 'Specified path does not exist'

    context 'when the path exists', ->
      beforeEach (done) ->
        filesystem = exists: sinon.stub().callsArgWith 1, true
        @directoryValidator= new DirectoryValidator filesystem
        @directoryValidator.checkForExistence 'some/path', (@error, @result) => done()

      it 'does not return an error in the callback', ->
        expect(@error).to.be.null

      it 'returns an object indicating that the path was successfully found', ->
        expect(@result.status).to.equal 'success'


  describe '#checkIsDirectory', ->
    context 'when the path is not a directory', ->
      beforeEach (done) ->
        stats = isDirectory: sinon.stub().returns false
        filesystem = stat: sinon.stub().callsArgWith 1, null, stats
        @directoryValidator= new DirectoryValidator filesystem
        @directoryValidator.checkIsDirectory 'some/path', (@error, @result) => done()

      it 'returns an error in the callback', ->
        expect(@error).to.equal 'Specified path is not a directory'

    context 'when the path is a directory', ->
      beforeEach (done) ->
        stats = isDirectory: sinon.stub().returns true
        filesystem = stat: sinon.stub().callsArgWith 1, null, stats
        @directoryValidator= new DirectoryValidator filesystem
        @directoryValidator.checkIsDirectory 'some/path', (@error, @result) => done()

      it 'does not return an error in the callback', ->
        expect(@error).to.be.null

      it 'returns an object indicating that the directory check was successful', ->
        expect(@result.status).to.equal 'success'
