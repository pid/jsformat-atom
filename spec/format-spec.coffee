{WorkspaceView} = require 'atom'
require 'fs'

format = require '../lib/format'

describe "JSFormat package tests", ->
  beforeEach ->
    atom.workspaceView = new WorkspaceView()
    atom.workspace = atom.workspaceView.model

  # JSFormat tests here

  describe "when the textbuffer is being formatted", ->
    beforeEach ->
      atom.workspaceView.attachToDom()

    it "can format the whole buffer with the use of the command", ->
      # general format test

      waitsForPromise ->
        atom.workspace.open('specfiles/index.js')

      runs ->
        @fileText = atom.workspace.getActiveTextEditor().getText()
        atom.workspaceView.getActiveView().trigger 'jsformat:format'

      runs ->
        # just check that some whitespace and other goodies got added
        expect(atom.workspace.getActiveTextEditor().getText()).not.toMatch(@fileText)

    it "can format a selection of the whole buffer with the use of the command", ->
      # general selected text format test

      waitsForPromise ->
        atom.workspace.open('specfiles/index.js')

      runs ->
        # select text until end of first require
        atom.workspace.getActiveTextEditor().setSelectedBufferRange([[0, 0], [14, 7]])
        @fileText = atom.workspace.getActiveTextEditor().getSelectedText()
        @restOfFileText = atom.workspace.getActiveTextEditor().getTextInBufferRange([[15, 0], [31, 0]])
        atom.workspaceView.getActiveView().trigger 'jsformat:format'

      runs ->
        # check that some whitespace and other goodies got added
        expect(atom.workspace.getActiveTextEditor().getSelectedText()).not.toMatch(@fileText)
        # check that the rest of the file wasn't touched
        expect(atom.workspace.getActiveTextEditor().getTextInBufferRange([[15, 0], [31, 0]])).not.toMatch(@restOfFileText)


    it "can format the whole buffer if Format on save is turned on", ->
      # format_on_save test

      waitsForPromise ->
        atom.workspace.open('specfiles/index.js')

      runs ->
        fileText = atom.workspace.getActiveTextEditor().getText()
        atom.config.set('jsformat.format_on_save', true)
        atom.workspace.getActiveTextEditor().save()

        # just check that some whitespace and other goodies got added
        expect(atom.workspace.getActiveTextEditor().getText()).not.toMatch(fileText)
        atom.config.set('jsformat.format_on_save', false)

    it "can subscribe and unsubscribe to events when format_on_save is enabled", ->
      # format_on_save test

      waitsForPromise ->
        atom.packages.activatePackage('jsformat')

      waitsForPromise ->
        spyOn(format, 'subscribeToEvents').andCallThrough()
        atom.workspace.open('specfiles/index.js')

      runs ->
        fileText = atom.workspace.getActiveTextEditor().getText()
        atom.config.set('jsformat.format_on_save', true)
        atom.workspace.getActiveTextEditor().save()

        # atom.close()
        # TODO add a check here to see that the subscriptions were disposed and deleted from the objects

    it "can subscribe and unsubscribe to events when format_on_save is changed", ->
      # format_on_save test

      waitsForPromise ->
        atom.packages.activatePackage('jsformat')

      waitsForPromise ->
        spyOn(format, 'subscribeToEvents').andCallThrough()
        atom.workspace.open('specfiles/index.js')

      runs ->
        # check that subscribeToEvents has run
        expect(format.subscribeToEvents.callCount).toEqual(0)
        atom.config.set('jsformat.format_on_save', true)
        expect(format.subscribeToEvents.callCount).toEqual(1)
        atom.config.set('jsformat.format_on_save', false)
        expect(format.subscribeToEvents.callCount).toEqual(2)

    it "displays a notification for unsupported languages", ->
      # NotSupportedNotificationView test

      waitsForPromise ->
        atom.packages.activatePackage('jsformat')

      waitsForPromise ->
        spyOn(format, 'displayUnsupportedLanguageNotification').andCallThrough()
        atom.workspace.open('xyz.coffee')

      runs ->
        atom.workspaceView.getActiveView().trigger('jsformat:format')

        expect(format.displayUnsupportedLanguageNotification).toHaveBeenCalled()
        expect(format.displayUnsupportedLanguageNotification.callCount).toEqual(1)
