-- Functions that should be standard library I copied from somewhere.
function trim(s)
    -- from PiL2 20.4
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function gsplit(s,sep)
    return coroutine.wrap(function()
        if s == '' or sep == '' then
            coroutine.yield(s)
            return
        end
        local lasti = 1
        for v,i in s:gmatch('(.-)'..sep..'()') do
            coroutine.yield(v)
            lasti = i
        end
        coroutine.yield(s:sub(lasti))
    end)
end

function accumulate(t,i,s,v)
    for v in i,s,v do
       t[#t+1] = v
    end
    return t
end

function tsplit(s,sep)
    return accumulate({}, gsplit(s,sep))
end



-- This function takes a block of text and applys the "lettrine" function to the first word.
-- It's simply a convenience function to break up the first two syllables correctly.
function drop(text)
    local first = text:sub(1, 1)
    local rest = text:sub(2)
    local closingIndex = rest:find(" ", 2)
    if (closingIndex == nil) then
        tex.print(text)
    end
    tex.print("\\lettrine{" .. first .. "}{" .. 
        rest:sub(1, closingIndex - 1) .. "}" ..
        rest:sub(closingIndex ))
end

-- This function renders the text Kalendar
-- in an appropriate latex table.
function printKalendar(reduced)
    reduced = reduced or false
    local mainFontSize = "tiny"
    local doubleFeastSize = "small"
    -- Columns:
    -- 1 day, 2 Sunday Letter, 3-4 Roman day, 5 Feast (6 "rubric")

    local inTable = false

    for line in io.lines("kalendar.txt") do
        (function()
        local splitline = tsplit(line, "|")
        if not splitline or (#splitline == 1 and trim(splitline[1]) == "") then
            if inTable == true then
                tex.print("\\end{longtabu}}\n")
                inTable = false
            end
        elseif #splitline == 1 then
            tex.print("\\section{" .. splitline[1] .. "}\n")
            tex.print("{\\" .. mainFontSize .. "\n")
            if reduced then
                tex.print("\\begin{longtabu} to \\linewidth {@{} c @{\\hspace{.5em}} X @{} }\n")
            else
                tex.print("\\begin{longtabu} to \\linewidth {@{} c @{\\hspace{.5em}} c @{\\hspace{.5em}} r @{\\hspace{.3em}} l @{\\hspace{1em}} X @{} }\n")
            end
            inTable = true
        else 
            local hang
            while (#splitline < 5) do
                table.insert(splitline, "")
            end
            if (reduced) then
                table.remove(splitline, 6)
                table.remove(splitline, 4)
                table.remove(splitline, 3)
                table.remove(splitline, 2)
                if #splitline == 1 or trim(splitline[2]) == "" then
                    return
                end
                
            else 
                if #splitline == 6 then
                    hang = table.remove(splitline)
                    splitline[#splitline] = splitline[#splitline] .. "\\hspace*{\\fill}\\emph{" .. hang .. "}"
                end
                if splitline[4] ~= "" then
                    splitline[4] = "\\emph{" .. splitline[4] .. "}"
                end
                if trim(splitline[2]) == "A" then
                    splitline[2] = "{\\red ".. trim(splitline[2]) .. "}"
                end
                if trim(splitline[3]) == "KL" then
                    splitline[3] = "\\multicolumn{2}{c}{\\dub{\\red" .. splitline[3] .. "}}"
                    table.remove(splitline,4)
                end
                if trim(splitline[3]) == "Ides" or trim(splitline[3]) == "Nones" then
                    splitline[3] = "\\multicolumn{2}{c}{\\scshape " .. trim(splitline[3]) .. "}"
                    table.remove(splitline,4)
                end
            end
            tex.print(table.concat(splitline,"&") .. "\\\\\n")
        end
    end)()     
    end
end