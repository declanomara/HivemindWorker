local io = require("io")
local filesystem = require("filesystem")
local internet = require("internet")


local install_url = "https://raw.githubusercontent.com/declanomara/HivemindWorker/master/install.lua"
local main_url = "https://github.com/declanomara/HivemindWorker/blob/master/main.lua"


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
    download_script(install_url, "install.lua")
    download_script(main_url, "main.lua")
end

main()