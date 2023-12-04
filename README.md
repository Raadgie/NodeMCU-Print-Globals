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



```lua
   local function printExpanded()
        print("\n" .. string.rep("=", width))
        print(buildLabel("Do you wish to print an expanded list?", width, " "))
        print(buildLabel("_G(g) package.loaded(l)", width, " "))
        print(buildLabel("_U(u) Exit(x)", width, " "))
        print(string.rep("=", width))
        --[[    
            Subsequently, it is possible to print the content of tables in an expanded tree-like list.
            The console waits for 10 seconds for user input, then terminates the procedure.
        ]]--
    
        -- Setting a timer for automatic termination due to inactivity
        local autoExit = tmr.create()
        autoExit:alarm(10000, tmr.ALARM_SINGLE, function () Terminate("Entry timed out") end)
        -- Setting up the console for user input terminated by the Enter key (Line Feed)
        -- The output does not go to the Lua interpreter
        uart.on("data", "\n",
            -- Anonymous function that is called when the user makes input from the console
            function (input)
                -- The function first interrupts the countdown for the inactivity procedure
                autoExit:unregister()
                -- Setting the software watchdog timer to 5 seconds
                -- Because when printing extensive tables (e.g., _G) in a loop, the system watchdog may overflow, so it is reset inside the loop
    
                tmr.softwd(5)
                -- The user's input evaluation follows
                -- CAUTION: The returned string includes the '\n' character!
                if input == "x\n" then
                    Terminate("Procedure abandoned by the user")
                elseif input == "g\n" then
                    print("\n" .. buildLabel("_G", width) .. " " .. buildLabel("Value", valueWidth))
                    printTableCycle(_G)
                    Terminate()
                elseif input == "l\n" then
                    if next(package["loaded"]) ~= nil then
                        print("\n" .. buildLabel("package.loaded", width) .. " " .. buildLabel("Value", valueWidth))
                        printTableCycle(package.loaded)
                        Terminate()
                    else
                        Terminate("Table is empty.")
                    end
                elseif input == "u\n" then
                    if _U then
                        if next(_U) ~= nil then
                            print("\n" .. buildLabel("_U", width) .. " " .. buildLabel("Value", valueWidth))
                            printTableCycle(_U)
                            Terminate()
                        else
                            Terminate("Table is empty")
                        end
                    else
                        Terminate("Table not found")
                    end
                else
                    Terminate("Unknown input!")
                end
                -- Stopping the software watchdog timer
                tmr.softwd(-1)
            end,
        0)
    end
    printExpanded()
    end
```


