-- Library for localizing strings in lua scripts

local lang = HedgewarsScriptLoad("Locale/" .. tostring(L) .. ".lua")

function loc(text)
    if locale ~= nil and locale[text] ~= nil then return locale[text]
    else return text
    end
end
