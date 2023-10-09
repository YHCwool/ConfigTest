--[[
Simple Config System
]]
--------------------------------------------library
local base64 = require("neverlose/base64")
local http = require("neverlose/http")
local clipboard = require("neverlose/clipboard")
local gradient = require("neverlose/gradient")
--------------------------------------------icons
local iconexport = ui.get_icon("file-export")
local iconimport = ui.get_icon("file-import")
local iconcfg = ui.get_icon("cog")
local cloud = ui.get_icon("cloud")
--------------------------------------------sidebar
local gradient_animation =
    gradient.text_animate(
        "Config Syetem",
        8,
        {
            ui.get_style()["Link Active"],
            color(173, 182, 234, 177)
        }
    )
ui.sidebar(gradient_animation:get_animated_text(), iconcfg)
--------------------------------------------ui
local G = ui.create("Simple Config System")
local Switch = G:switch("Switch")
local b64title = "_Config_System"
--------------------------------------------
System = {
    config_data = {
        Test = {
            Switch
        }
    }
}

--------------------------------------------Export
G:button(
    iconexport .." Export Config", --ui位置
    function()
        local Code = {{}}

        for _, main in pairs(System.config_data.Test) do
            if main:get() ~= nil then
                table.insert(Code[1], tostring(main:get()))
            end
        end

        local encodedData = base64.encode(json.stringify(Code))

        clipboard.set(encodedData .. b64title)
        print("Exported from clipborad!")
    end
)
--------------------------------------------Import
G:button(
    iconimport .." Import Config",
    function()
        local protected = function()
            local importdData = clipboard.get()
            local import = string.sub(importdData, 1, #importdData - #b64title)

            for k, v in pairs(json.parse(base64.decode(import))) do
                local key = ({[1] = "Test"})[k]

                for k2, v2 in pairs(v) do
                    if key == "Test" then
                        if v2 == "true" then
                            System.config_data[key][k2]:set(true)
                        elseif v2 == "false" then
                            System.config_data[key][k2]:set(false)
                        else
                            System.config_data[key][k2]:set()
                        end
                    end
                end
            end
        end

        local status = pcall(protected)
        if not status then
            error("The data you imported may be incorrect or using a different version.") --Prompt when the data is wrong.
            return
        else
            print("Imported from clipborad!")
        end
    end
)
--------------------------------------------Cloud
G:button(
    cloud .." Cloud Config",
    function()
        http.get(
            "https://raw.githubusercontent.com/YHCwool/ConfigTest/main/configtest.txt", --这里是你的库或服务器地址
            function(success, response)
                if not success or response.status ~= 200 then
                    error("Check Internet connection") --此lua用的是github的仓库所以可能上不去请使用VPN
                end

                local encodedData = response.body
                local cloudData= string.sub(encodedData, 1, #encodedData - #b64title)

                local protected = function()
                    for k, v in pairs(json.parse(base64.decode(cloudData))) do
                        local key = ({[1] = "Test"})[k]

                        for k2, v2 in pairs(v) do
                            if key == "Test" then
                                if v2 == "true" then
                                    System.config_data[key][k2]:set(true)
                                elseif v2 == "false" then
                                    System.config_data[key][k2]:set(false)
                                else
                                    System.config_data[key][k2]:set()
                                end
                            end
                        end
                    end
                end

                local status = pcall(protected)
                if not status then
                    error("Cloud Find Error")
                    return
                else
                    print("Config from Cloud!")
                end
            end
        )
    end
)
