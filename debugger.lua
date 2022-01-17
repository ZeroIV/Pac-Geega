Debugger = class('Debugger')

local debugLog = {}
local debug_status
local log_seperator = '\n'
function Debugger:init()
    for i = 1, 20 do
        log_seperator = log_seperator .. '*'
    end
    log_seperator = log_seperator .. '\n'
end

function Debugger:append(...)
    local data
    if ... then
         data = table.pack(...)
         for i = 1, data.n do
            local item = tostring(data[i])
            if debug_status then
                print(item)
            else
                table.insert(debugLog, item)
            end
        end
    end
end

function Debugger:toggle()
    debug_status = not debug_status
end

function Debugger:getStatus()
    return debug_status
end

function Debugger:getLog()
    return debugLog
end

function Debugger:purge()
    debugLog = {}
end

function Debugger:dump()
    while #debugLog > 0 do
        local item = table.remove(debugLog, 1)
        if type(item) == 'table' then
            for k, v in pairs(item) do
                print(tostring(v))
            end
        else
            print(item)
        end
    end
    print(log_seperator)
end