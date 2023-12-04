# NodeMCU-Print-Globals

### Tool for printing the tree structure of Globals using the excellent [NodeMCU-Tools](https://github.com/BoresXP/nodemcu-tools) (@BoresXP) extension for VS Code. 

![Snímek obrazovky 2023-12-04 v 0 27 00](https://github.com/Raadgie/NodeMCU-Print-Globals/assets/152021860/da5b426f-eec0-4ea3-92d5-941f12e93d2f)


<hr>

### Integration with VS Code





Open the NodeMCU-Tools extension settings and modify the code for Snippets in the 'settings.json' file.

```json
   "nodemcu-tools.snippets": {

 "Globals": "local name = '~Globals' if file.exists (name .. '.lc') then dofile(name .. '.lc') elseif file.exists(name .. '.lua') then dofile(name .. '.lua') end"

    },
```
<br>

Upload the file '~Globals.lc' to ESP.

<hr>

### Expanded Table Output

The console will present a menu for extended table output and wait for input for 10 seconds.

![Snímek obrazovky 2023-12-04 v 0 27 43](https://github.com/Raadgie/NodeMCU-Print-Globals/assets/152021860/15ad8730-3180-4abe-91ff-e10f0af2c0a7)
