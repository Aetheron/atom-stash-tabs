{remote} = require('electron')
{Menu, MenuItem} = remote

module.exports =
  stashes: {}
  stashedFiles: []
  activeFile: null
  disposableMenuItems: {}

  activate: (state) -> # ...
    atom.commands.add 'atom-workspace', 'workspace:stash', => @stash()

  stash: ->
    stashedFiles = []
    @activeFile = atom.workspace.paneContainer.activePane.getActiveItem().getPath()
    stashTitles = []
    atom.workspace.getTextEditors().forEach (editor) ->
      stashTitles.push(editor.getTitle())
      stashedFiles.push(editor.getPath())
      atom.workspace.paneContainer.activePane.destroyItem(editor)

    @stashedFiles = stashedFiles

    i = Math.random().toString(36).substr(2, 7)
    while @stashes["stash#{ i }"]?
        i = Math.random().toString(36).substr(2, 7)
    @stashes["stash#{ i }"] = stashedFiles
    console.log @stashes
    
    stashTitle = stashTitles.join( ", " )
    if stashTitle.length > 20
      stashTitle = stashTitle.substr(0, 50)
      if stashTitle[stashTitle.length - 1] == '.'
        stashTitle = stashTitle.slice(0, -1)
      stashTitle += "..."
    stashMenu = new MenuItem({
        label: "Unstash #{ stashTitle }",
        click: () => @unstash("stash#{ i }"),
        id: "stash#{ i }"
    })
    
    disposable = atom.menu.add [
        {
            'label': 'Packages'
            'submenu': [
                {
                    'label': 'Workspace Stash'
                    'submenu': [
                        {
                            'label': "Unstash #{ stashTitle }",
                            'command': "workspace:unstash#{ i }"
                        }
                    ]
                }
            ]
        }
    ]
    atom.commands.add 'atom-workspace', "workspace:unstash#{ i }", => @unstash("stash#{ i }")
    @disposableMenuItems["stash#{ i }"] = disposable

  unstash: (item) ->
    currentStash = @stashes[item]
    
    delete @stashes[item]
    @disposableMenuItems[item].dispose()
    
    if currentStash? && currentStash.length > 0
      atom.workspace.paneContainer.activePane.destroyItems()
      activeFile = @activeFile
      activeEditor = null
      currentStash.forEach (file) ->
        editor = atom.workspace.open file, {activatePane: false}

        if file == activeFile
          activeEditor = editor

      if activeEditor
        console.log 'found an editor to activate', activeEditor
        activeEditor.then (editor) ->
          console.log 'active editor', editor
          atom.workspace.paneContainer.activePane.activateItem(editor)
      else
        atom.workspace.paneContainer.activePane.destroyItems()
        activeFile = @activeFile
        activeEditor = null
        currentStash.forEach (file) ->
          editor = atom.workspace.open file, {activatePane: false}

          if file == activeFile
            activeEditor = editor

        if activeEditor
          console.log 'found an editor to activate', activeEditor
          activeEditor.then (editor) ->
            console.log 'active editor', editor
            atom.workspace.paneContainer.activePane.activateItem(editor)

      @stashedFiles = []
      @activeFile = null
