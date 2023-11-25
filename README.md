# NodeMCU-Print-Globals

Tool for printing the tree structure of Globals using the excellent NodeMCU-Tools extension for VS Code. (https://github.com/BoresXP/nodemcu-tools)

![Snímek obrazovky 2023-11-25 v 18 04 00](https://github.com/Raadgie/NodeMCU-Print-Globals/assets/152021860/4496c26b-84a9-4ea8-8ab2-426a26fd4ad8)













```lua
do
-- Function for aligning column spaces: 'arg' is the key, 'tab' is the total space (number of characters)
local function expandTabs(arg, tab)
    local keyString = tostring(arg)
    local sLength = string.len(keyString)
    keyString = string.sub(keyString, 1, tab)
    
    if sLength >= tab then
        keyString = keyString:sub(1, -2) .. "… "
    else
        keyString = keyString .. string.rep(" ", (tab - sLength + 1))
    end
    
    return keyString
end

--[[
    Function iterates through a table, handling circular references,
    and prints its content in a tree structure format:

    <symbol_representing_item_type> <key> [<value>]

    t                   table
    tab                 tab (number of characters for indentation)
    indent_tree         indentation of the tree structure (relative)
    indent              indentation of the tree structure from the initial symbol
    sep                 separator, guiding character of the tree structure
    processed_Tables   table of already iterated items (tables) to avoid cycling
]]--
local function printTableCycle(t, tab, indent_tree, indent, sep, processedTables)
    local tab = tab or 40
    local sep = sep or "| "
    local outputString
    local symbol
    local indent = indent or " "
    local indent_tree = indent_tree or 2
    local processedTables = processedTables or {}

    for key, value in pairs(t) do
        if type(value) == "table" then
            symbol = "{ }"
            outputString = symbol .. indent .. sep .. key

            print(expandTabs(outputString, tab + string.len(symbol) - 3) .. tostring(value))

            if not processedTables[value] then
                processedTables[value] = true
                indent = indent .. string.rep(" ", indent_tree)
                printTableCycle(value, tab, indent_tree, indent, sep, processedTables)
                indent = string.sub(indent, 1, -indent_tree - 1)
            end
        elseif type(value) == "function" then
            -- (other cases for different types...)
        end
    end
end

-- Analogous function without iteration of subtables
local function printTableNoCycle(t, tab)
    -- (similar implementation...)
end

print "================ _G ==================="
printTableNoCycle(_G)
print ("\n")

if next(package["loaded"]) ~= nil then
    print "============ package.loaded ==========="
    printTableNoCycle(package.loaded)
end

print ("\n")

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

local function Terminate(reason)
    print ("\r\n")
    if reason ~= nil then print ("*** " .. reason) end
    print ("*** Iteration terminated.")
    uart.on("data", "\n", 1)
end

local autoExit = tmr.create()
autoExit:alarm(10000, tmr.ALARM_SINGLE, function () Terminate("Request time limit exceeded.") end)

uart.on("data", "\n",
    function (input)
        autoExit:unregister()

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
