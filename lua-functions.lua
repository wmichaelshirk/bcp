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