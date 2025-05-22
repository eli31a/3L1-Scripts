function print(valor)
    reaper.ShowConsoleMsg(tostring(valor)..'\n')
end

function SetExts()
    for i = 1, 13 do
        reaper.SetExtState(SeccionExt, "M"..i.."HourDay", tostring(DataHoraria[i]["hourDay"]), true)
        reaper.SetExtState(SeccionExt, "M"..i.."MinDay", tostring(DataHoraria[i]["minDay"]), true)
        reaper.SetExtState(SeccionExt, "M"..i.."HourNight", tostring(DataHoraria[i]["hourNight"]), true)
        reaper.SetExtState(SeccionExt, "M"..i.."MinNight", tostring(DataHoraria[i]["minNight"]), true)
    end
    reaper.SetExtState(SeccionExt, "DayTheme", tostring(TemaDiurno), true)
    reaper.SetExtState(SeccionExt, "NightTheme", tostring(TemaNocturno), true)
    reaper.SetExtState(SeccionExt, "Calendar", tostring(Calendario), true)
end

function GetExt(clave, defecto)
    local valor = reaper.GetExtState(SeccionExt, clave)
    if valor ~= "" then
        return tonumber(valor)
    else
        reaper.SetExtState(SeccionExt, clave, tostring(defecto), true)
        return defecto
    end
end