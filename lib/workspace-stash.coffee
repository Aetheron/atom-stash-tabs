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

    i = Object.keys(@stashes).length
    @stashes["stash#{ i }"] = stashedFiles
    console.log @stashes
    
    # menu = Menu.getApplicationMenu();
    # submenu = [] 
    # for item in menu.items
    #   if item.label == "Packages"
    #     submenu = item
    
    stashTitle = stashTitles.join( ", " )
    if stashTitle.length > 20
      stashTitle.substr( 0, 20 )
      stashTitle += "..."
    stashMenu = new MenuItem({
        label: "Unstash #{ stashTitle }",
        click: () => @unstash("stash#{ i }"),
        id: "stash#{ i }"
    })
    
    # for submenuItem in submenu.submenu.items
    #   if submenuItem.label = "Workspace Stash"
    #     submenuItem.submenu.append(stashMenu)
    # 
    # Menu.setApplicationMenu(menu);
    
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
