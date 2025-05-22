-- @author 3L1
-- @description Luna - Time based theme switcher
-- @version 1.0
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

VersionScript = "1.0"
NombreScript = "Luna - Time-based Theme Switcher"
SeccionExt = "3L1_Luna"

package.path = package.path .. ";" .. debug.getinfo(1, 'S').source:match[[^@?(.*[\/])[^\/]-$]] .. "?.lua"
require("Functions/General Functions")

reaper.set_action_options(1)

local temaDiurno = GetExt("DayTheme", 1)
local temaNocturno = GetExt("NightTheme", 2)
local calendario = GetExt("Calendar", 0)

local dataHoraria = {}
for i = 1, 13 do
    dataHoraria[i] = {}
    dataHoraria[i]["hourDay"] = GetExt("M"..i.."HourDay", 7)
    dataHoraria[i]["minDay"] = GetExt("M"..i.."MinDay", 0)
    dataHoraria[i]["hourNight"] = GetExt("M"..i.."HourNight", 22)
    dataHoraria[i]["minNight"] = GetExt("M"..i.."MinNight", 0)
end

local comTemaDiurno = reaper.NamedCommandLookup("_S&M_LOAD_THEME"..tostring(temaDiurno))
local comTemaNocturno = reaper.NamedCommandLookup("_S&M_LOAD_THEME"..tostring(temaNocturno))
local momentoPrevio

local _, __, sec, id = reaper.get_action_context()
reaper.SetToggleCommandState(sec, id, 1)

function Loop()
    local estadoReprod = reaper.GetPlayState()
    if estadoReprod ~= 5 and estadoReprod ~= 6 then
        local tiempo = os.date("*t")
        local hora = math.tointeger(tiempo.hour)
        local minuto = math.tointeger(tiempo.min)
        local mes = calendario == 0 and 13 or math.tointeger(tiempo.month)
        local horaAmanecer = dataHoraria[mes]["hourDay"]
        local minAmanecer = dataHoraria[mes]["minDay"]
        local horaAtardecer = dataHoraria[mes]["hourNight"]
        local minAtardecer = dataHoraria[mes]["minNight"]
        local momento = (hora > horaAmanecer and hora < horaAtardecer) or (hora == horaAmanecer and minuto >= minAmanecer) or (hora == horaAtardecer and minuto < minAtardecer)
        if momento ~= momentoPrevio then
            local tema = momento and comTemaDiurno or comTemaNocturno
            reaper.Main_OnCommand(tema, 0)
            momentoPrevio = momento
            reaper.SetExtState(SeccionExt, "Daytime", momento and "Day" or "Night", true)
        end
    end
    reaper.defer(Loop)
end

function Exit()
    reaper.SetToggleCommandState(sec, id, 0)
end

reaper.defer(Loop)
reaper.atexit(Exit)