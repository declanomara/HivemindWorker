local io = require("io")
local filesystem = require("filesystem")
local internet = require("internet")


local github_url = "https://raw.githubusercontent.com/declanomara/HivemindWorker/master"
local install_url = github_url.."/install.lua"
local main_url = github_url.."/main.lua"
local autorun_url = github_url.."/autorun.lua"
local json_url = github_url.."/json.lua"
local inspect_url = github_url.."/inspect.lua"


function download_script (url, save_name)
    print('Downloading file "'..save_name..'"...')
    local handle = internet.request(url)
    local result = ""
    for chunk in handle do result = result..chunk end

    print('Saving file "'..save_name..'"...')
    local file = io.open(save_name, "w")
    file:write(result)
    file:close()

    return True
end

function main ()
    download_script(json_url, "/home/json.lua")
    download_script(inspect_url, "/home/inspect.lua")
    download_script(install_url, "/home/install.lua")
    download_script(main_url, "/home/main.lua")
    download_script(autorun_url, "/autorun.lua")
end

main()