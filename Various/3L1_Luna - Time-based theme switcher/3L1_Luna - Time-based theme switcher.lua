--[[    To-do:
- Ejecutar plugin al inicio
]]



-- @author 3L1
-- @description Luna - Time based theme switcher
-- @version 1.1
-- @about
--   ## Luna - Time-based theme switcher
--   
--   This script lets you switch Reaper color themes at given hours.
--   It lets you choose two themes from your SWS resource slots and select
--   the time of the day Reaper switches between them. It's supposed to
--   work in day/night cycles, so the themes are labeled "light" and
--   "dark". Personally, I use Reapertips theme pack, which has both
--   options.
--   
--   The script has also the possibility to set different day/night hours
--   per month, allowing you to follow the Sun through the year.
--   
--   The default hours are 07:00 for light theme and 22:00 for night
--   theme, so they are in sync with Amely Suncroll's Roboface auto
--   background color function.
--   
--   The script also declares and updates an ExtState with tells if time
--   is "Day" or "Night", so other scripts may use the info to apply
--   light or dark color schemes depending on it.
--   
--   Much thanks to Daniel Lumertz for his Reascript tutorial
--   series, this script can only exist because of him.
-- @provides
--   3L1_Luna - Time-based theme switcher.lua
--   Functions/General Functions.lua
--   Functions/User Interface.lua

VersionScript = "1.1"
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