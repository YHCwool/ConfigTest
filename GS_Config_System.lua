--[[
Config System
一个简单的CFG系统您可以粘贴到您的lua上
]]
--------------------------------------------library
local base64 = require("gamesense/base64")
local http = require("gamesense/http")
local clipboard = require("gamesense/clipboard")
--------------------------------------------
local Switch  = ui.new_checkbox(  "Lua", "B","Switch")

local b64title = "_Config_System"

cloud = {
    table = {
        config_data = {},
    },
}
 cloud.table.config_data.cfg_data = {
    Test = {
        Switch,

}
 }

export_config = ui.new_button(
    "Lua",
    "A",
    "Export Config", --ui位置
    function()
        local Code = { {} }

        for _, main in pairs(cloud.table.config_data.cfg_data.Test) do
            if ui.get(main) ~= nil then
                table.insert(Code[1], tostring(ui.get(main)))
            end
        end

        local encodedData = base64.encode(json.stringify(Code))

        clipboard.set(encodedData .. b64title)
        print("Export to Clipboard")
    end
)

import_config = ui.new_button(
    "Lua",
    "A",
    "Import Config",
    function()
        local protected = function()
            local importdData = clipboard.get()
            local import = string.sub(importdData, 1, #importdData - #b64title)
            local decodedData = base64.decode(import)
            local importedData = json.parse(decodedData)

            for k, v in pairs(importedData) do
                local key = ({ [1] = "Test" })[k]

                for k2, v2 in pairs(v) do
                    if key == "Test" then
                        if v2 == "true" then
                            ui.set(cloud.table.config_data.cfg_data[key][k2], true)
                        elseif v2 == "false" then
                            ui.set(cloud.table.config_data.cfg_data[key][k2], false)
                        else
                            ui.set(cloud.table.config_data.cfg_data[key][k2], v2)
                        end
                    end
                end
            end
        end

        local status, message = pcall(protected)
        if not status then
            error("The data you imported may be incorrect or using a different version.") --当数据错误的时候提示
            return
        else
            print("Import form to Clipboard")
        end
    end
)

config_download = ui.new_button(
    "Lua",
    "A",
    "Cloud Config",
    function()
        http.get("https://raw.githubusercontent.com/YHCwool/ConfigTest/main/configtest.txt", --这里是你的库或服务器地址
            function(success, response)
                if not success or response.status ~= 200 then
                    error("Check Internet connection") --此lua用的是github的仓库所以可能上不去请使用VPN
                end

                local encodedData = response.body
                local encodedDataWithoutCustomString = string.sub(encodedData, 1, #encodedData - #b64title)

                local protected = function()
                    for k, v in pairs(json.parse(base64.decode(encodedDataWithoutCustomString))) do
                        local key = ({ [1] = "Test" })[k]

                        for k2, v2 in pairs(v) do
                            if key == "Test" then
                                if v2 == "true" then
                                    ui.set(cloud.table.config_data.cfg_data[key][k2], true)
                                elseif v2 == "false" then
                                    ui.set(cloud.table.config_data.cfg_data[key][k2], false)
                                else
                                    ui.set(cloud.table.config_data.cfg_data[key][k2], v2)
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
                    print("Set form to Cloud")
                end
            end)
    end
)
