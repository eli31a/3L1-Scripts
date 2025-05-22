--[[    To-do:
- Ejecutar plugin al inicio
]]

VersionScript = "1.0"
NombreScript = "Luna - Time-based Theme Switcher"
SeccionExt = "3L1_Luna"

local rutaFuente = debug.getinfo(1, 'S').source:match[[^@?(.*[\/])[^\/]-$]]

NombreSdoPlano = reaper.GetExtState(SeccionExt, "BackgroundName")
if NombreSdoPlano == "" then
    local comandoSdoPlano = reaper.AddRemoveReaScript(true, 0, rutaFuente.."3L1_Luna - Time-based theme switcher (background).lua", true)
    NombreSdoPlano = reaper.ReverseNamedCommandLookup(comandoSdoPlano)
    reaper.SetExtState(SeccionExt, "BackgroundName", NombreSdoPlano, true)
end

package.path = package.path..";"..rutaFuente.."?.lua;"..reaper.ImGui_GetBuiltinPath().."/?.lua"
require("Functions/General Functions")

TemaDiurno = GetExt("DayTheme", 1)
TemaNocturno = GetExt("NightTheme", 2)
Calendario = GetExt("Calendar", 0)

require("Functions/User Interface")

DataHoraria = {}
for i = 1, 13 do
    DataHoraria[i] = {}
    DataHoraria[i]["hourDay"] = GetExt("M"..i.."HourDay", 7)
    DataHoraria[i]["minDay"] = GetExt("M"..i.."MinDay", 0)
    DataHoraria[i]["hourNight"] = GetExt("M"..i.."HourNight", 22)
    DataHoraria[i]["minNight"] = GetExt("M"..i.."MinNight", 0)
end

reaper.defer(Loop)