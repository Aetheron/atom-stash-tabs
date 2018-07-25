{remote} = require('electron')
{Menu, MenuItem} = remote

module.exports =
  stashes: []
  stashedFiles: []
  activeFile: null

  activate: (state) -> # ...
    atom.commands.add 'atom-workspace', 'workspace:stash', => @stash()
    # atom.commands.add 'atom-workspace', 'workspace:apply', => @apply()

  stash: ->
    stashedFiles = []
    @activeFile = atom.workspace.paneContainer.activePane.getActiveItem().getPath()
    atom.workspace.getTextEditors().forEach (editor) ->
      stashedFiles.push editor.getPath()
      atom.workspace.paneContainer.activePane.destroyItem(editor)

    @stashedFiles = stashedFiles

    i = @stashes.length
    @stashes["stash#{i}"] = stashedFiles
    console.log @stashes
    
    menu = Menu.getApplicationMenu();
    submenu = [] 
    for item in menu.items
      if item.label == "Packages"
        submenu = item
    
    stashMenu = new MenuItem({
        label: 'unstash #{i}',
    })
    
    for submenuItem in submenu.submenu.items
      if submenuItem.label = "Stash Tabs Dev"
        submenuItem.submenu.append(stashMenu)
    
    Menu.setApplicationMenu(menu);

    # atom.contextMenu.add {
    #     'Packages': [{
    #         label: 'stash-tabs-dev',
    #         submenu: [{
    #             label: 'unstash',
    #             submenu: [{label: "stash#{i}", command: => @unstash()}]
    #         }]
    #     }]
    #atom-pane selector for adding items to the overlay
    # }
    # atom.commands.add 'atom-workspace', 'stash-tabs-dev:unstash:stash#{i}', => @unstash()

  apply: ->
    if @stashedFiles.length > 0
      atom.workspace.paneContainer.activePane.destroyItems()
      activeFile = @activeFile
      activeEditor = null
      @stashedFiles.forEach (file) ->
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
