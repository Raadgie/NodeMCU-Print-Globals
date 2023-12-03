do
    -- width of the column for displaying iteration
    local width = 40
    -- width of the column for displaying values
    local valueWidth = 20
    -- function for filling in spaces
    -- arg = string or number
    -- tab = indentation (number of characters in the 1st column)
    -- gap = compensation for added spaces or other characters
    local function expandTabs(arg, tab, gap)
        local keyString = arg
        if type(keyString) ~= "string" then keyString = tostring(arg) end
        local gap = gap or 0
        local tab = tab - gap
        -- length of the original string
        local sLength = string.len(keyString)
        -- return a substring from the original string from the first character to the n-th (tab) character
        -- (if the string is longer than 'tab' characters, it will be shortened)
        keyString = string.sub(keyString, 1, tab)
        -- if the original string is longer than 'tab' characters
        if sLength > tab then
            -- shorten the string by one character and append "three dots" (ASCII 0x85)
            keyString = keyString:sub(1, -2) .. "…"
        else
            -- fill in the difference between 'tab' and the length of the string with spaces 
            keyString = keyString .. string.rep(" ", (tab - sLength))
        end
        return keyString
    end
    --[[
            the function iterates through the table, including cycling through internal references
            and outputs its content in a tree structure format:

            <symbol_indicating_item_type> <key> [<value>]

            t                   table
            tab                 tab (number of characters in the value column indentation)
            indent_tree         indentation of the tree structure (relative)
            indent              indentation of the tree structure from the initial symbol
            sep                 separator, leading character of the tree structure
            processed_Tables    table of already iterated items (tables) to prevent cycling
    ]]--
    local function printTableCycle(t, tab, valueWidth, indent_tree, indent, sep, processedTables)
        -- if the 'tab' parameter (tab) is not specified, set it to 40 characters
        local tab = tab or 40
        -- set the default value to 20 characters
        local valueWidth = valueWidth or 20
        -- if the 'sep' parameter is not specified, set it
        local sep = sep or "| "
        local outputString
        local symbol
        -- if the indentation parameter is not specified, set it
        local indent = indent or " "
         -- if the indentation parameter in the tree output is not specified, set it
        local indent_tree = indent_tree or 2
        -- table of already iterated items
        local processedTables = processedTables or {}
        for key, value in pairs(t) do
            -- if the type of the item is another table, iterate through it
            if type(value) == "table" then
                    -- a new string (list item) consists of a symbol, indentation from the symbol, a separator, and the original key
                    symbol = "{ }"
                    outputString = symbol .. indent .. sep .. key
                    -- print the item line with added spaces to reach the indentation of the second column (value 'tab')
                    -- NOTE: the string.len() function returns the number of bytes, and some special characters may have more bytes,
                    -- so it is necessary to compensate for these characters in the 'symbol' variable
                    -- 3 characters are fixed for special symbols
                    print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
                    -- if the table has not been iterated yet, save it as iterated
                    -- (the value contains the unique address of the table, e.g., table: 0x4026bb48)
                    if not processedTables[value] then
                        processedTables[value] = true
                        -- increase the indentation in the tree structure
                        indent = indent .. string.rep(" ", indent_tree)
                        -- recursive call to the 'printTableCycle' function
                        -- pass a new table for iteration and a list of already iterated tables
                        printTableCycle(value, tab, valueWidth, indent_tree, indent, sep, processedTables)
                        -- if the previous table no longer has any items to iterate, reduce the indentation (return from recursion)
                        -- the new indentation is reduced by a negative value of the tree structure indentation (-1 => the last character of the string)
                        indent = string.sub(indent, 1, - indent_tree - 1)
                    end
            -- output other values
            elseif type(value) == "function" then
                symbol = " ƒ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "string" then
                symbol = "„ ”"
                outputString = symbol .. indent .. sep .. key
                -- for a string value, put it in quotes and replace control characters (%c) with spaces
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs("\"" .. string.gsub(value, "%c", " ") .. "\"", valueWidth))
             elseif type(value) == "number" then
                symbol = "¹²³"
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "boolean" then
                symbol = " ! "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "thread" then
                symbol = " ¢ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "userdata" then
                symbol = " @ "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            else
                symbol = " ? "
                outputString = symbol .. indent .. sep .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            end
            tmr.wdclr()
        end
    end

    -- analogous function without iterating through sub-tables
    local function printTableNoCycle(t, tab, valueWidth)
        local indent = " "
        local outputString
        local symbol
        local valueWidth = valueWidth or 20
        local tab = tab or 40
        for key, value in pairs(t) do
            if type(value) == "table" then
                symbol = "{ }"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "function" then
                symbol = " ƒ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "string" then
                symbol = "„ ”"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs("\"" .. string.gsub(value, "%c", " ") .. "\"", valueWidth))
            elseif type(value) == "number" then
                symbol = "¹²³"
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "boolean" then
                symbol = " ! "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "thread" then
                symbol = " ¢ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            elseif type(value) == "userdata" then
                symbol = " @ "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            else
                symbol = " ? "
                outputString = symbol .. indent .. key
                print(expandTabs(outputString, tab + string.len(symbol), 3) .. " " .. expandTabs(tostring(value), valueWidth))
            end
        end
    end


    local function buildLabel(label, width, sign)
        -- dividing character
        local dividerSign = sign or "="
        -- number of characters in the dividing line, minus the space before and after the label
        local dividerLength = width - #label - 2
        -- string of dividing lines before the label
        local beforeCenterString = string.rep(dividerSign, math.ceil(dividerLength / 2))
        -- length of the dividing line after the label, minus the space before and after the label
        local afterlenght =  width - #beforeCenterString - #label - 2
        -- string of dividing lines after the label
        local afterCenterString = string.rep(dividerSign, afterlenght)
        -- final label
        local mergedString = beforeCenterString ..  " " ..  label .. " " .. afterCenterString
        return mergedString
    end
    
    -- function to terminate input
    local function Terminate(reason)
        print("\n")
        if reason ~=nil then 
            print(buildLabel(reason, width, "*"))
        end
        print(buildLabel("Iteration terminated", width, "*"))
        -- set the console input back to the Lua interpreter
        uart.on("data","\n",1)
    end
    -- set the software watchdog timer to 5 seconds
    -- because when printing extensive tables (e.g., _G) in a loop, the system watchdog may overflow, so it is reset inside the loop 

    print("\n" .. buildLabel("_G", width) .. " " .. buildLabel("Value", valueWidth))
    printTableNoCycle(_G, width, valueWidth)
    -- stop the software watchdog timer
    tmr.softwd(-1)

    -- if the 'package.loaded' table is not empty, print it
    if next(package["loaded"]) ~= nil then
        print("\n" .. buildLabel("package.loaded", width) .. " " .. buildLabel("Value", valueWidth))
        printTableNoCycle(package.loaded, width, valueWidth)
    end
  
    -- if the user table '_U' is not empty, print it
    if _U then
        if  next(_U) ~= nil then
            print("\n" .. buildLabel("_U", width) .. " " .. buildLabel("Value", valueWidth))
            printTableNoCycle(_U, width, valueWidth)
        end
    end
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
    collectgarbage("collect")
    