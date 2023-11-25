# NodeMCU-Print-Globals

### Tool for printing the tree structure of Globals using the excellent [NodeMCU-Tools](https://github.com/BoresXP/nodemcu-tools) (@BoresXP) extension for VS Code. 

![Snímek obrazovky 2023-11-25 v 18 04 00](https://github.com/Raadgie/NodeMCU-Print-Globals/assets/152021860/4496c26b-84a9-4ea8-8ab2-426a26fd4ad8)

<hr>

### Integration with VS Code





Open the NodeMCU-Tools extension settings and modify the code for Snippets in the 'settings.json' file.

```json
   "nodemcu-tools.snippets": {

        "Globals": "if file.exists ('~Button Print Globals.lc') then dofile('~Button Print Globals.lc') elseif file.exists('~Button Print Globals.lua') then dofile('~Button Print Globals.lua') end"

    },
```
<br>

Upload the file '~Button Print Globals.lc' to ESP.

<hr>




```lua
do
    -- Function for aligning column spaces: arg is the key, tab is the total space size (number of characters)
    local function expandTabs(arg, tab)
        local keyString = tostring(arg)
        -- Length of the original string (key)
        local sLength = string.len(keyString)
        -- Return a substring from the original string from the first character to the n-th (tab) character
        -- (if the string is longer than 'tab' characters)
        keyString = string.sub(keyString, 1, tab)
        -- If the original string is longer than 'tab' characters
        if sLength >= tab then
            -- Shorten the string by one character and append "three dots" (ASCII 0x85) with a space
            keyString = keyString:sub(1, -2) .. "… "
        else
            -- Fill the difference between 'tab' and the length of the string with spaces + 1
            keyString = keyString .. string.rep(" ", (tab - sLength + 1))
        end
        return keyString
    end

    --[[
            The function iterates through the table, including cycling inner references,
            and prints its content in a tree structure format:

            <symbol_representing_item_type> <key> [<value>]

            t                   table
            tab                 tab (number of characters for column value indentation)
            indent_tree         indentation of the tree structure (relative)
            indent              indentation of the tree structure from the initial symbol
            sep                 separator, guiding character of the tree structure
            processed_Tables   table of already iterated items (tables) to avoid cycling
    ]]--
    local function printTableCycle(t, tab, indent_tree, indent, sep, processedTables)
        -- If the 'tab' parameter (tabulator) is not provided, set it to 40 characters
        local tab = tab or 40
        -- If the 'sep' parameter is not provided, set it
        local sep = sep or "| "
        local outputString
        local symbol
        -- If the indentation parameter is not provided, set it
        local indent = indent or " "
         -- If the indentation parameter in the tree structure is not provided, set it
        local indent_tree = indent_tree or 2
        -- Table of already iterated items
        local processedTables = processedTables or {}
        for key, value in pairs(t) do
            -- If the item type is another table, iterate through it
            if type(value) == "table" then
                    -- Create a new string (list item) consisting of the symbol, indentation from the symbol, separator, and the original key
                    symbol = "{ }"
                    outputString = symbol .. indent .. sep .. key
                    -- Print the item line, supplemented with the number of spaces to reach the indentation of the second column (value 'tab')
                    -- NOTE: the string.len() function returns the number of bytes, and some special characters may have more bytes,
                    -- so it is necessary to compensate for these characters in the 'symbol' variable
                    -- For special symbols, 3 characters are fixed
                    print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
                    -- If the table has not been iterated yet, save it as iterated
                    -- (the value contains the unique address of the table, e.g., table: 0x4026bb48)
                    if not processedTables[value] then
                        processedTables[value] = true
                        -- Increase the indentation in the tree structure
                        indent = indent .. string.rep(" ", indent_tree)
                        -- Recursive call of the 'printTableCycle' function
                        -- Pass the new table for iteration and the list of already iterated tables
                        printTableCycle(value, tab, indent_tree, indent, sep, processedTables)
                        -- If the previous table no longer has any items to iterate, decrease the indentation (return from recursion)
                        -- The new indentation is reduced by the negative value of the tree structure indentation (-1 => last character of the string)
                        indent = string.sub(indent, 1, -indent_tree - 1)
                    end
            -- Print other values
            elseif type(value) == "function" then
                symbol = " ƒ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "string" then
                symbol = "„ ”"
                outputString = symbol .. indent .. sep .. key
                -- Place the string value in quotes and replace control characters (%c) with spaces
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. "\"" .. string.gsub(value, "%c", " ") .. "\"")
            elseif type(value) == "number" then
                symbol = "¹²³"
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "boolean" then
                symbol = " ! "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "thread" then
                symbol = " ¢ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "userdata" then
                symbol = " @ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            else
                symbol = " ? "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            end
        end
    end

    -- Analogous function without iterating through subtables
    local function printTableNoCycle(t, tab)
        local tab = tab or 40
        local indent = indent or " "
        local outputString
        local symbol
        for key, value in pairs(t) do
            if type(value) == "table" then
                symbol = "{ }"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "function" then
                symbol = " ƒ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "string" then
                symbol = "„ ”"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. "\"" .. string.gsub(value, "%c", " ") .. "\"")
            elseif type(value) == "number" then
                symbol = "¹²³"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "boolean" then
                symbol = " ! "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "thread" then
                symbol = " ¢ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            elseif type(value) == "userdata" then
                symbol = " @ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            else
                symbol = " ? "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))
            end
        end
    end

    print "================ _G ==================="
    printTableNoCycle(_G)
    print ("\n")
    -- If the 'package.loaded' table is not empty, print it
    if next(package["loaded"]) ~= nil then
        print "============ package.loaded ==========="
        printTableNoCycle(package.loaded)
    end

    print ("\n")
    -- If the user table '_U' is not empty, print it
    if _U then
        if next(_U) ~= nil then
            print "================ _U ==================="
            printTableNoCycle(_U)
        end
    end
    
    print ("\n")
    
    print "======================================="
    print [[Do you wish to print an expanded list?
Exit(x) _G(g) package.loaded(l) _U(u)]]
    print "======================================="

    --[[
        
        Subsequently, the content of tables can be printed in an expanded tree list
        The console waits for 10 seconds for user input, then terminates the procedure


    ]]

    -- Function to terminate input
    local function Terminate(reason)
        print ("\r\n")
        if reason ~=nil then print ("*** " .. reason) end
        print ("*** Iteration terminated.")
        -- Resetting the console input for the Lua interpreter
        uart.on("data","\n",1)
    end
    -- Setting a timer for automatic termination for inactivity
    local autoExit = tmr.create()
    autoExit:alarm(10000, tmr.ALARM_SINGLE, function () Terminate("Request time limit exceeded.") end)
    -- Setting the console for user input terminated by the Enter key (Line Feed)
    -- The output does not go to the Lua interpreter
    uart.on("data","\n",
        -- Anonymous function that is called when the user inputs from the console
        function (input)
            -- The function first interrupts the countdown to interrupt the procedure for inactivity
            autoExit:unregister()
            -- The user input is then evaluated
            -- NOTE: The returned string includes the '\n' character!
            if input == "x\n" then
                Terminate("Procedure abandoned by the user.")
            elseif input == "g\n" then
                print ("\r\n")
                print "================ _G ==================="
                printTableCycle(_G)
                print ("\n")
                Terminate()
            elseif input == "l\n" then
                if next(package["loaded"]) ~= nil then
                    print ("\r\n")
                    print "============ package.loaded ==========="
                    printTableCycle(package.loaded)
                    print ("\n")
                    Terminate()
                else
                    Terminate("Table is empty.")
                end
            elseif input == "u\n" then
                if _U then
                    if next(_U) ~= nil then
                        print ("\r\n")
                        print "================ _U ==================="
                        printTableCycle(_U)
                        print ("\n")
                        Terminate()
                    else
                        Terminate("Table is empty.")
                    end
                else
                    Terminate("Table not found.")
                end
            else
                Terminate("Unknown input!")
            end
        end,
    0)
end
collectgarbage("collect")

```
