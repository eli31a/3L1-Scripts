
-- @noindex

VersionScript = "1.1"
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