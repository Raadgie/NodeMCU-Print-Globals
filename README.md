# NodeMCU-Print-Globals

### Tool for printing the tree structure of Globals using the excellent [NodeMCU-Tools](https://github.com/BoresXP/nodemcu-tools) (@BoresXP) extension for VS Code. 

![Snímek obrazovky 2023-11-25 v 18 04 00](https://github.com/Raadgie/NodeMCU-Print-Globals/assets/152021860/4496c26b-84a9-4ea8-8ab2-426a26fd4ad8)

<hr>

### Integration with VS Code





Open the NodeMCU-Tools extension settings and modify the code for Snippets in the 'settings.json' file.

```json
   "nodemcu-tools.snippets": {

 "Globals": "name = '~Globals' if file.exists (name .. '.lc') then dofile(name .. '.lc') elseif file.exists(name .. '.lua') then dofile(name .. '.lua') end"

    },
```
<br>

Upload the file '~Button Print Globals.lc' to ESP.

<hr>
