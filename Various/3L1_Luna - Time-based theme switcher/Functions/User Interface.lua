local ImGui = require "imgui" "0.9.3"
local ctx = ImGui.CreateContext("Luna - Time-based theme switcher")
local nombreVentana = NombreScript.." "..VersionScript
local anchoVentana = 300
local altoVentana = 290
local fuente = ImGui.CreateFont("sans-serif", 14)
--local FLTMIN = ImGui.NumericLimits_Float()
--local demo = require "ReaImGui_Demo"

local tiempo = os.date("*t")
local mes = Calendario == 0 and 13 or math.tointeger(tiempo.month)
local encendido = Calendario == 1
local meses = {" (January)", " (February)", " (March)", " (April)", " (May)", " (June)", " (July)", " (August)", " (September)", " (October)", " (November)", " (December)", ""}

ImGui.Attach(ctx, fuente)

function Loop()
    --demo.PushStyle(ctx)
    --demo.ShowDemoWindow(ctx)
    PushTheme()
    if reaper.GetExtState(SeccionExt, "Daytime") == "Night" then
        PushDarkColors()
    else
        PushLightColors()
    end
    local flagsVentana = ImGui.WindowFlags_NoDocking | ImGui.WindowFlags_NoCollapse | ImGui.WindowFlags_NoResize
    ImGui.SetNextWindowSize(ctx, anchoVentana, altoVentana, ImGui.Cond_Once)
    ImGui.PushFont(ctx, fuente)
    local visible, abierto = ImGui.Begin(ctx, nombreVentana, true, flagsVentana)
    if visible then
        local cota = ImGui.SliderFlags_AlwaysClamp
        local anchoCombo = ImGui.ComboFlags_WidthFitPreview
        ImGui.SeparatorText(ctx, "Change hours"..meses[mes]..":")
        ImGui.BeginGroup(ctx)
        do
            ImGui.Text(ctx, "Light theme hour:")
            do
                local cambioHora, cambioMin
                ImGui.SetNextItemWidth(ctx, anchoVentana/2 - 30)
                cambioHora, DataHoraria[mes]["hourDay"] = ImGui.SliderInt(ctx, "H##Day", DataHoraria[mes]["hourDay"], 0, 23, "%d", cota)
                ImGui.SetNextItemWidth(ctx, anchoVentana/2 - 30)
                cambioMin, DataHoraria[mes]["minDay"] = ImGui.SliderInt(ctx, "M##Day", DataHoraria[mes]["minDay"], 0, 59, "%d", cota)
                if (cambioHora or cambioMin) then
                    if DataHoraria[mes]["hourDay"] > DataHoraria[mes]["hourNight"] then
                        DataHoraria[mes]["hourDay"] = DataHoraria[mes]["hourNight"]
                    elseif DataHoraria[mes]["hourDay"] == DataHoraria[mes]["hourNight"] and DataHoraria[mes]["minDay"] >= DataHoraria[mes]["minNight"] then
                        DataHoraria[mes]["minDay"] = DataHoraria[mes]["minNight"] - 1
                    end
                end
            end
            ImGui.Spacing(ctx)
            ImGui.Text(ctx, "Dark theme hour:")
            do
                local cambioHora, cambioMin
                ImGui.SetNextItemWidth(ctx, anchoVentana/2 - 30)
                cambioHora, DataHoraria[mes]["hourNight"] = ImGui.SliderInt(ctx, "H##Night", DataHoraria[mes]["hourNight"], 0, 23, "%d", cota)
                ImGui.SetNextItemWidth(ctx, anchoVentana/2 - 30)
                cambioMin, DataHoraria[mes]["minNight"] = ImGui.SliderInt(ctx, "M##Night", DataHoraria[mes]["minNight"], 0, 59, "%d", cota)
                if (cambioHora or cambioMin) then
                    if DataHoraria[mes]["hourNight"] < DataHoraria[mes]["hourDay"] then
                        DataHoraria[mes]["hourNight"] = DataHoraria[mes]["hourDay"]
                    elseif DataHoraria[mes]["hourNight"] == DataHoraria[mes]["hourDay"] and DataHoraria[mes]["minNight"] <= DataHoraria[mes]["minDay"] then
                        DataHoraria[mes]["minNight"] = DataHoraria[mes]["minDay"] + 1
                    end
                end
            end
        end
        ImGui.EndGroup(ctx)
        ImGui.SameLine(ctx)
        ImGui.BeginGroup(ctx)
        do
            local retval
            retval, encendido = ImGui.Checkbox(ctx, "Monthly setup", encendido)
            if retval then
                local tiempo = os.date("*t")
                mes = encendido and math.tointeger(tiempo.month) or 13
                Calendario = encendido and 1 or 0
            end
            ImGui.Spacing(ctx)
            ImGui.Spacing(ctx)
            ImGui.Spacing(ctx)
            if not encendido then ImGui.BeginDisabled(ctx) end
            if ImGui.BeginTable(ctx, "monTable", 3) then
                for i = 1, 12 do
                    ImGui.TableNextColumn(ctx)
                    _, mes = ImGui.RadioButtonEx(ctx, (meses[i]:sub(3, 3)).."##"..tostring(i), mes, i)
                end
                ImGui.EndTable(ctx)
            end
            if not encendido then ImGui.EndDisabled(ctx) end
        end
        ImGui.EndGroup(ctx)
        ImGui.SeparatorText(ctx, "Theme resource slots:")
        if ImGui.BeginCombo(ctx, "Light theme", tostring(TemaDiurno), anchoCombo) then
            for i = 1, 4 do
                local estado = TemaDiurno == i
                _, estado = ImGui.Selectable(ctx, "Slot "..tostring(i), estado)
                if estado then TemaDiurno = i end
            end
            ImGui.EndCombo(ctx)
        end
        ImGui.SameLine(ctx, anchoVentana/2)
        if ImGui.BeginCombo(ctx, "Dark theme", tostring(TemaNocturno), anchoCombo) then
            for i = 1, 4 do
                local estado = TemaNocturno == i
                _, estado = ImGui.Selectable(ctx, "Slot "..tostring(i), estado)
                if estado then TemaNocturno = i end
            end
            ImGui.EndCombo(ctx)
        end
        ImGui.Spacing(ctx)
        ImGui.Separator(ctx)
        ImGui.Spacing(ctx)
        ImGui.Dummy(ctx, anchoVentana/2 - 35, 30)
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Cancel", anchoVentana/4, 30) then
            abierto = false
        end
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "OK", anchoVentana/4, 30) then
            SetExts()
            local comandoSdoPlano = reaper.NamedCommandLookup("_"..NombreSdoPlano)
            if reaper.GetToggleCommandState(comandoSdoPlano) == 1 then
                reaper.Main_OnCommand(comandoSdoPlano, 0)
            end
            reaper.Main_OnCommand(comandoSdoPlano, 0)
            abierto = false
        end
        ImGui.End(ctx)
    end
    ImGui.PopFont(ctx)
    --demo.PopStyle(ctx)
    PopTheme()
    PopColors()
    if abierto then reaper.defer(Loop) end
end

function PushTheme()
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowRounding,          7)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_WindowTitleAlign,        0.5, 0.5)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_FrameRounding,           2)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_GrabRounding,            2)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_SeparatorTextBorderSize, 1)
    ImGui.PushStyleVar(ctx, ImGui.StyleVar_DisabledAlpha,           0)
end

function PushLightColors()
    ImGui.PushStyleColor(ctx, ImGui.Col_Text,             0x000000FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_WindowBg,         0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_PopupBg,          0xFFFFFFF0)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg,          0xB4B4B4FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgHovered,   0xBEBEBEFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgActive,    0xC8C8C8FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBg,          0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgActive,    0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgCollapsed, 0xD7D7D782)
    ImGui.PushStyleColor(ctx, ImGui.Col_CheckMark,        0x323232FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrab,       0x919191FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrabActive, 0xAAAAAAFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Button,           0xB4B4B4FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered,    0xBEBEBEFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,     0xC8C8C8FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Header,           0xBEBEBEFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_HeaderHovered,    0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_HeaderActive,     0xC8C8C8FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Separator,        0x32323280)
end

function PushDarkColors()
    ImGui.PushStyleColor(ctx, ImGui.Col_Text,             0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_WindowBg,         0x323232FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_PopupBg,          0x000000F0)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBg,          0x505050FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgHovered,   0x5A5A5AFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_FrameBgActive,    0x646464FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBg,          0x323232FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgActive,    0x323232FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_TitleBgCollapsed, 0x32323282)
    ImGui.PushStyleColor(ctx, ImGui.Col_CheckMark,        0xD7D7D7FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrab,       0x919191FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_SliderGrabActive, 0xAAAAAAFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Button,           0x505050FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonHovered,    0x5A5A5AFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_ButtonActive,     0x646464FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Header,           0x5A5A5AFF)
    ImGui.PushStyleColor(ctx, ImGui.Col_HeaderHovered,    0x323232FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_HeaderActive,     0x646464FF)
    ImGui.PushStyleColor(ctx, ImGui.Col_Separator,        0xD7D7D780)
end

function PopTheme()
    ImGui.PopStyleVar(ctx, 6)
end

function PopColors()
    ImGui.PopStyleColor(ctx, 19)
end