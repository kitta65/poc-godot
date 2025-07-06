# PoC of Godot

## Setup

### VSCode

In Godot, set `Editor > Editor Settings > Text Editor > External`.

- `Exec Path > C:\Users\username\AppData\Local\Programs\Microsoft VS Code\Code.exe`
- `Exec Flags > {project} --goto {file}:{line}:{col}`
- `Use External Editor > On`

Install VSCode extension ([godot-vscode-plugin](https://github.com/godotengine/godot-vscode-plugin)) and configure.

### Export

- Download [export template](https://docs.godotengine.org/en/stable/tutorials/export/exporting_projects.html#export-templates)
- Enable rcedit
  - Download from [GitHub releases](https://github.com/electron/rcedit/releases)
  - Set `Editor > Editor Settings > Export > Windows > rcedit`

### Gut

Install Gut from in-editor Godot Asset Lib and then activate ([see](https://gut.readthedocs.io/en/latest/Install.html)).
