-- Modified support for Krnl and others

--LIBRARY START
--Services
getgenv().runService = game:GetService"RunService"
getgenv().textService = game:GetService"TextService"
getgenv().inputService = game:GetService"UserInputService"
getgenv().tweenService = game:GetService"TweenService"

if getgenv().library then
    getgenv().library:Unload()
end

local library = {design = getgenv().design == "kali" and "kali" or "uwuware", tabs = {}, draggable = true, flags = {}, title = "CheatX", open = false, popup = nil, instances = {}, connections = {}, options = {}, notifications = {}, tabSize = 0, theme = {}, foldername = "cheatx_cnfgs", fileext = ".txt"}
getgenv().library = library

--Locals
local dragging, dragInput, dragStart, startPos, dragObject

local blacklistedKeys = { --add or remove keys if you find the need to
    Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Escape
}
local whitelistedMouseinputs = { --add or remove mouse inputs if you find the need to
    Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
}

--Functions
library.round = function(num, bracket)
    if typeof(num) == "Vector2" then
        return Vector2.new(library.round(num.X), library.round(num.Y))
    elseif typeof(num) == "Vector3" then
        return Vector3.new(library.round(num.X), library.round(num.Y), library.round(num.Z))
    elseif typeof(num) == "Color3" then
        return library.round(num.R * 255), library.round(num.G * 255), library.round(num.B * 255)
    else
        return num - num % (bracket or 1);
    end
end

--From: https://devforum.roblox.com/t/how-to-create-a-simple-rainbow-effect-using-tweenService/221849/2
local chromaColor
spawn(function()
    while library and wait() do
        chromaColor = Color3.fromHSV(tick() % 6 / 6, 1, 1)
    end
end)

function library:Create(class, properties)
    properties = properties or {}
    if not class then return end
    local a = class == "Square" or class == "Line" or class == "Text" or class == "Quad" or class == "Circle" or class == "Triangle"
    local t = a and Drawing or Instance
    local inst = t.new(class)
    for property, value in next, properties do
        inst[property] = value
    end
    table.insert(self.instances, {object = inst, method = a})
    return inst
end

function library:AddConnection(connection, name, callback)
    callback = type(name) == "function" and name or callback
    connection = connection:connect(callback)
    if name ~= callback then
        self.connections[name] = connection
    else
        table.insert(self.connections, connection)
    end
    return connection
end

function library:Unload()
    for _, c in next, self.connections do
        c:Disconnect()
    end
    for _, i in next, self.instances do
        if i.method then
            pcall(function() i.object:Remove() end)
        else
            i.object:Destroy()
        end
    end
    for _, o in next, self.options do
        if o.type == "toggle" then
            coroutine.resume(coroutine.create(o.SetState, o))
        end
    end
    library = nil
    getgenv().library = nil
end

function library:LoadConfig(config)
    if table.find(self:GetConfigs(), config) then
        local Read, Config = pcall(function() return game:GetService"HttpService":JSONDecode(readfile(self.foldername .. "/" .. config .. self.fileext)) end)
        Config = Read and Config or {}
        for _, option in next, self.options do
            if option.hasInit then
                if option.type ~= "button" and option.flag and not option.skipflag then
                    if option.type == "toggle" then
                        spawn(function() option:SetState(Config[option.flag] == 1) end)
