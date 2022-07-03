local computer = require("computer")
local internet = require("internet")
local inspect = require("inspect")
local json = require("json")
local robot_api = require("robot")


function save_position ()
    local file = io.open("/home/pos.txt", "w")
    file:write(json.encode(pos))
    file:close()
    return true
end

function _load_position ()
    local file = io.open("/home/pos.txt", "r")
    local pos_string = file:read()
    pos = json.decode(pos_string)
    return pos
end

function load_position ()
    local ran, result = pcall(_load_position)
    if not ran then
        return {x=0, y=0, z=0, facing=0}
    else
        return result
    end
end

function args_to_uri (args)
    uri = "?"

    for k, v in pairs(args) do
        uri = uri..k.."="..v.."&"
    end

    return uri
end

function make_request (url, args)
    local args_string = args_to_uri(args)
    local abs_url = url..args_string
    local handle = internet.request(abs_url)
    local result = ""
    for chunk in handle do result = result..chunk end

    result = json.decode(result)

    return result
end

function get_actions ()
    return make_request(url.."/orders", {uuid = id})
end

function register ()
    return make_request(url.."/register", {uuid = id})
end

function update_status ()
    return make_request(url.."/status_update", {x=pos.x, y=pos.y, z=pos.z, facing=pos.facing, uuid=id})
end

function update_position (amt, dir)
    save_position ()

    if dir == 0 then
        pos.x = pos.x + amt
        return true
    end

    if dir == 1 then
        pos.z = pos.z + amt
        return true
    end

    if dir == 2 then
        pos.x = pos.x - amt
        return true
    end

    if dir == 3 then
        pos.z = pos.z - amt
        return true
    end

    return false
end

function move_forward ()
    local success = robot_api.forward()
    if success then
        update_position(1, pos.facing)
    end

    return success
end

function move_back ()
    local success = robot_api.back()
    if success then
        update_position(-1, pos.facing)
    end

    return success
end

function turn_right ()
    robot_api.turnRight()
    pos.facing = (pos.facing - 1) % 4
end

function turn_left ()
    robot_api.turnLeft()
    pos.facing = (pos.facing + 1) % 4
end

function handle_movement (action)
    if action["direction"] == "forward" then
        move_forward()
    end

    if action["direction"] == "turnRight" then
        turn_right()
    end

    if action["direction"] == "turnLeft" then
        turn_left()
    end

    if action["direction"] == "back" then
        move_back()
    end

    update_status()
end


function handle_action (action)
    if action["type"] == "register" then
        register()
    end

    if action["type"] == "ping" then
        update_status()
    end

    if action["type"] == "move" then
        handle_movement(action)
    end

    if action["type"] == "null" then
        local current_time = os.time()
        if (current_time - wait_msg_interval) > prev_waiting_time then
            print("current:"..current_time)
            print("prev:"..prev_waiting_time)
            print("Awaiting further instructions...")
            prev_waiting_time = current_time
        end
    end

end


function main ()
    local registration = register()
    if registration["success"] == "false" then
        if registration["error"] ~= "uuid already registered" then
            return
        end
    end

    while true do
        local actions = get_actions()

        for _, action in ipairs(actions) do
            handle_action(action)
        end

        os.sleep(0.05)

    end
end

id = computer.address()
url = "http://localhost:8000"
pos = load_position()

prev_waiting_time = 0
wait_msg_interval = 5

main()