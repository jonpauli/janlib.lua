-- Maple - paste this whole file into the executor and hit Execute.
-- built for Arsenal: camera aim, silent aim on the Mouse object, trigger bot, ESP, recoil control.
-- binds: X = aim assist (hold), V = silent aim (hold), C = trigger bot (hold), Z = rage (hold), End = menu

-- [library] ---------------------------------------------------------------------------------------------------
if getgenv().library then pcall(function() getgenv().library:Unload() end) end

local src = game:HttpGet("https://raw.githubusercontent.com/jonpauli/janlib.lua/main/janlib.lua")
print("[maple] fetched " .. #src .. " bytes")

-- raw github can serve a stale body. the library is 100 KB, anything under 50 KB is not it.
if #src < 50000 then
    src = game:HttpGet("https://files.catbox.moe/tlzk1o.lua")
    print("[maple] github stale, mirror " .. #src .. " bytes")
end

assert(loadstring(src))()

local library = getgenv().library
assert(library, "[maple] library loaded but getgenv().library is nil")

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer

library.title = "Maple"
library.foldername = "maple_cnfgs"

-- [Combat] ---------------------------------------------------------------------------------------------------
local CombatTab = library:AddTab("Combat")
local CombatCol1 = CombatTab:AddColumn()
local CombatCol2 = CombatTab:AddColumn()

local Aim = CombatCol1:AddSection("Aim Assist")
Aim:AddDivider("Main");
local aimToggle = Aim:AddToggle{text = "Enabled", flag = "Aimbot Enabled"}
local aimBind = aimToggle:AddBind({flag = "Aimbot Bind", key = "X", mode = "hold"})
Aim:AddSlider{text = "FOV", flag = "Aimbot FOV", min = 0, max = 360, value = 120, suffix = " px"}
Aim:AddSlider{text = "Smoothing", flag = "Aimbot Smoothing", min = 1, max = 30, value = 8}
Aim:AddSlider{text = "Prediction", flag = "Aimbot Prediction", min = 0, max = 2, float = 0.01, value = 0}
Aim:AddList{text = "Hitbox", flag = "Aimbot Hitbox", value = "Head", values = {"Head", "Torso", "HumanoidRootPart"}};
Aim:AddDivider("Checks");
Aim:AddToggle{text = "Team Check", flag = "Aimbot Team Check"}
Aim:AddToggle{text = "Wall Check", flag = "Aimbot Wall Check"}

local Silent = CombatCol1:AddSection("Silent Aim")
Silent:AddDivider("Main");
local silentToggle = Silent:AddToggle{text = "Enabled", flag = "Silent Aim Enabled"}
local silentBind = silentToggle:AddBind({flag = "Silent Aim Bind", key = "V", mode = "hold"})
Silent:AddSlider{text = "FOV", flag = "Silent Aim FOV", min = 0, max = 360, value = 120, suffix = " px"}
Silent:AddSlider{text = "Hit Chance", flag = "Silent Aim Chance", min = 0, max = 100, value = 100, suffix = "%"}
Silent:AddList{text = "Mode", flag = "Silent Aim Mode", value = "On Shoot", values = {"Always", "On Shoot"}};
Silent:AddDivider("Checks");
Silent:AddToggle{text = "Wall Check", flag = "Silent Aim Wall Check"}

local Trigger = CombatCol2:AddSection("Trigger Bot")
Trigger:AddDivider("Main");
local triggerToggle = Trigger:AddToggle{text = "Enabled", flag = "Trigger Enabled"}
local triggerBind = triggerToggle:AddBind({flag = "Trigger Bind", key = "C", mode = "hold"})
Trigger:AddSlider{text = "Delay", flag = "Trigger Delay", min = 0, max = 500, value = 0, suffix = " ms"}
Trigger:AddSlider{text = "FOV", flag = "Trigger FOV", min = 0, max = 100, value = 20, suffix = " px"}
Trigger:AddDivider("Checks");
Trigger:AddToggle{text = "Team Check", flag = "Trigger Team Check"}

local Recoil = CombatCol2:AddSection("Recoil")
Recoil:AddDivider("Main");
Recoil:AddSlider{text = "Recoil Scale", flag = "Recoil Scale", min = 0, max = 100, value = 100, suffix = "%"}

local Target = CombatCol2:AddSection("Target")
Target:AddDivider("Misc");
Target:AddSlider{text = "Max Distance", flag = "Aim Max Distance", min = 50, max = 2000, value = 1000, suffix = " st"}
Target:AddToggle{text = "Visible Only", flag = "Aim Visible Only", state = true}

-- [Visuals] --------------------------------------------------------------------------------------------------
local VisualsTab = library:AddTab("Visuals")
local VisualsCol1 = VisualsTab:AddColumn()
local VisualsCol2 = VisualsTab:AddColumn()

local Esp = VisualsCol1:AddSection("Player ESP")
Esp:AddDivider("Main");
Esp:AddToggle{text = "Enabled", flag = "ESP Enabled"};
-- off = every element uses its own colour below. on = one colour for box, name, distance and
-- tracer, which is what you want when you just cba setting four pickers.
local espSingle = Esp:AddToggle{text = "Single Colour", flag = "ESP Single Color"}
espSingle:AddColor({flag = "ESP Color", color = Color3.fromRGB(255, 255, 255)})
Esp:AddDivider("Elements");
-- one colour per element, plus a style list where the element has a shape choice. the colour picker
-- carries a transparency bar (the "trans" field) so the fill and the outline are both dialled here.
local espBoxes = Esp:AddToggle{text = "Boxes", flag = "ESP Boxes"}
espBoxes:AddColor({flag = "ESP Box Color", color = Color3.fromRGB(255, 255, 255), trans = 0.4})
espBoxes:AddList{text = "Box Style", flag = "ESP Box Style", value = "Outline", values = {"Outline", "Filled", "Both"}}

local espNames = Esp:AddToggle{text = "Names", flag = "ESP Names"}
espNames:AddColor({flag = "ESP Name Color", color = Color3.fromRGB(255, 255, 255)})
espNames:AddList{text = "Name Mode", flag = "ESP Name Mode", value = "Display", values = {"Display", "Username"}}

local espDistance = Esp:AddToggle{text = "Distance", flag = "ESP Distance"}
espDistance:AddColor({flag = "ESP Distance Color", color = Color3.fromRGB(200, 200, 200)})
espDistance:AddList{text = "Distance Unit", flag = "ESP Distance Unit", value = "Studs", values = {"Studs", "Meters"}}

local espHealth = Esp:AddToggle{text = "Health", flag = "ESP Health"}
espHealth:AddColor({flag = "ESP Health Color", color = Color3.fromRGB(0, 255, 120)})
espHealth:AddList{text = "Health Style", flag = "ESP Health Style", value = "Bar", values = {"Bar", "Text"}}

local espTracers = Esp:AddToggle{text = "Tracers", flag = "ESP Tracers"}
espTracers:AddColor({flag = "ESP Tracer Color", color = Color3.fromRGB(255, 255, 255)})
espTracers:AddList{text = "Tracer Origin", flag = "ESP Tracer Origin", value = "Bottom", values = {"Bottom", "Center", "Top"}}

local EspStyle = VisualsCol1:AddSection("ESP Style")
EspStyle:AddDivider("Text");
EspStyle:AddSlider{text = "Text Size", flag = "ESP Text Size", min = 8, max = 24, value = 14}
EspStyle:AddList{text = "Font", flag = "ESP Font", value = "Plex", values = {"UI", "System", "Plex", "Code"}}
EspStyle:AddToggle{text = "Text Outline", flag = "ESP Text Outline", state = true}
EspStyle:AddDivider("Shapes");
EspStyle:AddSlider{text = "Box Thickness", flag = "ESP Box Thickness", min = 1, max = 4, value = 1}
EspStyle:AddSlider{text = "Tracer Thickness", flag = "ESP Tracer Thickness", min = 1, max = 4, value = 1}
EspStyle:AddSlider{text = "Health Bar Width", flag = "ESP Health Width", min = 1, max = 8, value = 3}

local EspChecks = VisualsCol1:AddSection("ESP Checks")
EspChecks:AddDivider("Main");
EspChecks:AddToggle{text = "Team Check", flag = "ESP Team Check"}
EspChecks:AddToggle{text = "Use Team Color", flag = "ESP Team Color"}
EspChecks:AddSlider{text = "Max Distance", flag = "ESP Max Distance", min = 100, max = 5000, value = 2000, suffix = " st"}

-- [FOV circles] ------------------------------------------------------------------------------------------------
-- the aim FOV sliders are pixel radii, not degrees: findTarget compares screen distance from the
-- crosshair against them. the circles draw at exactly that radius, so what you see is what the
-- aimbot actually sees.
local Fov = VisualsCol2:AddSection("FOV Circles")
Fov:AddDivider("Draw");
Fov:AddToggle{text = "Aimbot", flag = "FOV Aimbot Draw"}:AddColor({flag = "FOV Aimbot Color", color = Color3.fromRGB(0, 200, 255)});
Fov:AddToggle{text = "Silent", flag = "FOV Silent Draw"}:AddColor({flag = "FOV Silent Color", color = Color3.fromRGB(255, 170, 0)});
Fov:AddToggle{text = "Trigger", flag = "FOV Trigger Draw"}:AddColor({flag = "FOV Trigger Color", color = Color3.fromRGB(0, 255, 120)});
Fov:AddToggle{text = "Rage", flag = "FOV Rage Draw"}:AddColor({flag = "FOV Rage Color", color = Color3.fromRGB(255, 60, 60)});
Fov:AddDivider("Shape");
Fov:AddSlider{text = "Thickness", flag = "FOV Thickness", min = 1, max = 5, value = 1}
Fov:AddSlider{text = "Sides", flag = "FOV Sides", min = 3, max = 64, value = 64}

local Env = VisualsCol2:AddSection("Environment")
Env:AddDivider("Lighting");
Env:AddToggle{text = "Fullbright", flag = "Fullbright", callback = function(state)
    Lighting.Brightness = state and 3 or 1
end}
Env:AddToggle{text = "No Fog", flag = "No Fog", callback = function(state)
    Lighting.FogEnd = state and 1e6 or 100000
end}
Env:AddDivider("Camera");
Env:AddToggle{text = "Override FOV", flag = "FOV Enabled"}
Env:AddSlider{text = "Field of View", flag = "FOV", min = 70, max = 120, value = 70}
local defaultCameraMode = player.CameraMode
local defaultZoom = player.CameraMaxZoomDistance
Env:AddToggle{text = "Third Person", flag = "Third Person", callback = function(state)
    if not state then
        player.CameraMode = defaultCameraMode
        player.CameraMaxZoomDistance = defaultZoom
    end
end}

-- [Rage] -----------------------------------------------------------------------------------------------------
local RageTab = library:AddTab("Rage")
local RageCol = RageTab:AddColumn()

local RageAim = RageCol:AddSection("Aim")
RageAim:AddDivider("Main");
local rageToggle = RageAim:AddToggle{text = "Enabled", flag = "Rage Aim Enabled"}
local rageBind = rageToggle:AddBind({flag = "Rage Aim Bind", key = "Z", mode = "hold"})
RageAim:AddSlider{text = "FOV", flag = "Rage Aim FOV", min = 0, max = 360, value = 180, suffix = " px"}
RageAim:AddSlider{text = "Smoothing", flag = "Rage Aim Smoothing", min = 0, max = 10, float = 0.1, value = 0}
RageAim:AddList{text = "Priority", flag = "Rage Aim Priority", value = "Distance", values = {"Distance", "Health", "FOV"}};
RageAim:AddDivider("Behaviour");
RageAim:AddToggle{text = "Auto Fire", flag = "Rage Auto Fire"}
RageAim:AddToggle{text = "Ignore Walls", flag = "Rage Ignore Walls"}

local RageTarget = RageCol:AddSection("Target")
RageTarget:AddDivider("Misc");
RageTarget:AddList{text = "Hitbox", flag = "Rage Aim Hitbox", value = "Head", values = {"Head", "Torso", "HumanoidRootPart"}};
RageTarget:AddToggle{text = "Team Check", flag = "Rage Aim Team Check"}

-- [Misc] -----------------------------------------------------------------------------------------------------
local MiscTab = library:AddTab("Misc")
local MiscCol = MiscTab:AddColumn()

local Character = MiscCol:AddSection("Character")
Character:AddDivider("Movement");
Character:AddSlider{text = "Walk Speed", flag = "Walk Speed", min = 0, max = 200, value = 16, callback = function(value)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then humanoid.WalkSpeed = value end
end}
Character:AddSlider{text = "Jump Power", flag = "Jump Power", min = 0, max = 200, value = 50, callback = function(value)
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = value
    end
end}

player.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if library.flags["Walk Speed"] ~= 16 then humanoid.WalkSpeed = library.flags["Walk Speed"] end
        if library.flags["Jump Power"] ~= 50 then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = library.flags["Jump Power"]
        end
    end
end)

local Utility = MiscCol:AddSection("Utility")
Utility:AddDivider("Client");
Utility:AddToggle{text = "Anti AFK", flag = "Anti AFK"}
Utility:AddButton{text = "Copy Job ID", callback = function()
    local ok = pcall(function() setclipboard(game.JobId) end)
    print("[maple] job id " .. tostring(ok and "copied" or "copy failed") .. ": " .. tostring(game.JobId))
end}
Utility:AddButton{text = "Rejoin", callback = function()
    if game.JobId == "" then return end
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end}

player.Idled:Connect(function()
    if not library.flags["Anti AFK"] then return end
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- [Settings] -------------------------------------------------------------------------------------------------
local SettingsTab = library:AddTab("Settings")
local SettingsCol1 = SettingsTab:AddColumn()
local SettingsCol2 = SettingsTab:AddColumn()
local MenuSection = SettingsCol1:AddSection("Menu")
local ConfigSection = SettingsCol2:AddSection("Configs")
local Warning = library:AddWarning({type = "confirm"})

MenuSection:AddBind{text = "UI Toggle", flag = "UI Toggle", nomouse = true, key = "End", callback = function()
    library:Close()
end}

-- every accent-colored element reads this flag. has to exist before library:Init()
MenuSection:AddColor{text = "Accent Color", flag = "Menu Accent Color", color = Color3.fromRGB(153, 114, 248), callback = function(color)
    if library.currentTab then library.currentTab.button.TextColor3 = color end
    for _, v in next, library.theme do
        v[(v.ClassName == "TextLabel" and "TextColor3") or (v.ClassName == "ImageLabel" and "ImageColor3") or "BackgroundColor3"] = color
    end
end}

local backgrounds = {
    Floral = "rbxassetid://5553946656",
    Flowers = "rbxassetid://6071575925",
    Circles = "rbxassetid://6071579801",
    Hearts = "rbxassetid://6073763717",
}

-- library.main only exists after library:Init(), so every callback below writes through
-- this one function and it gets called again once the menu actually exists.
-- tint comes from the color option's flag, opacity from its transparency bar, and the
-- UI Transparency slider fades the image and the solid colour under it together.
local function applyBackground()
    if not library.main then return end
    local main = library.main
    local opacity = 1 - (library.flags["UI Background Color Transparency"] or 0)
    local fade = library.flags["UI Transparency"] or 0
    local tile = library.flags["UI Tile Size"] or 50
    main.Image = backgrounds[library.flags["UI Background"] or "Floral"]
    main.ImageColor3 = library.flags["UI Background Color"] or Color3.fromRGB(40, 40, 40)
    main.ImageTransparency = math.clamp(1 - opacity + fade, 0, 1)
    main.TileSize = UDim2.new(0, tile, 0, tile)
    main.BackgroundTransparency = fade
end

MenuSection:AddDivider("Appearance");
MenuSection:AddList{text = "Background", flag = "UI Background", max = 4, value = "Floral", values = {"Floral", "Flowers", "Circles", "Hearts"}, callback = applyBackground}

-- the pattern is a tiled image, so it tints through ImageColor3. nothing in the library
-- writes that for you, the color option only paints its own swatch.
MenuSection:AddColor{text = "Background Color", flag = "UI Background Color", color = Color3.fromRGB(40, 40, 40), trans = 1,
    callback = applyBackground,
    calltrans = applyBackground
}

MenuSection:AddSlider{text = "Tile Size", flag = "UI Tile Size", min = 1, max = 500, value = 50, callback = applyBackground}
MenuSection:AddSlider{text = "UI Transparency", flag = "UI Transparency", min = 0, max = 1, float = 0.05, value = 0, callback = applyBackground}

ConfigSection:AddDivider("Files");
ConfigSection:AddBox{text = "Config Name", flag = "Config Name"};
-- flag has to stay "Config List", the library syncs this option against the folder
ConfigSection:AddList{text = "Configs", flag = "Config List", skipflag = true, value = "", values = library:GetConfigs()};

-- empty list resolves to the string "nil" inside the lib, so filter it out before touching files
local function selectedConfig()
    local name = library.flags["Config List"]
    if type(name) ~= "string" or name == "" or name == "nil" then return nil end
    return name
end

ConfigSection:AddButton{text = "Create", callback = function()
    local name = library.flags["Config Name"]
    if type(name) ~= "string" or name == "" then return end
    library:GetConfigs()
    writefile(library.foldername .. "/" .. name .. library.fileext, "{}")
    library.options["Config List"]:AddValue(name)
end}

ConfigSection:AddButton{text = "Save", callback = function()
    local name = selectedConfig()
    if not name then return end
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Save current settings to <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. name .. "</font>?"
    if Warning:Show() then library:SaveConfig(name) end
end}

ConfigSection:AddButton{text = "Load", callback = function()
    local name = selectedConfig()
    if not name then return end
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Load config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. name .. "</font>?"
    if Warning:Show() then library:LoadConfig(name) end
end}

ConfigSection:AddButton{text = "Delete", callback = function()
    local name = selectedConfig()
    if not name then return end
    local r, g, b = library.round(library.flags["Menu Accent Color"])
    Warning.text = "Delete config <font color='rgb(" .. r .. "," .. g .. "," .. b .. ")'>" .. name .. "</font>?"
    if Warning:Show() then
        if table.find(library:GetConfigs(), name) then
            library.options["Config List"]:RemoveValue(name)
            pcall(delfile, library.foldername .. "/" .. name .. library.fileext)
        end
    end
end}

-- [Init] -----------------------------------------------------------------------------------------------------
library:Init()
applyBackground() -- main exists now, push the saved background onto it
library:selectTab(library.tabs[1])

-- [runtime] ----------------------------------------------------------------------------------------------------
-- Arsenal is RCL's first person shooter: hitscan weapons that read the Mouse object, R6/R15 characters,
-- a ForceField during spawn protection, and a camera the game rewrites every frame. everything below
-- reads library.flags only, so loading a config restores the same behaviour.

local UserInputService = game:GetService("UserInputService")

local camera = workspace.CurrentCamera
local mouse = player:GetMouse()
local drawingApi = Drawing
local drawings = {}

local silentTarget
local mouseWasDown = false
local chanceRoll = 100
local lastTrigger = 0
local lastRageFire = 0
local lastShot = 0
local envElapsed = 0
local warnedDrawing = false
local fovApplied = false
local recoilBase = camera and camera.CFrame or CFrame.new()

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    camera = workspace.CurrentCamera
end)

local function crosshair()
    local viewport = camera.ViewportSize
    return Vector2.new(viewport.X / 2, viewport.Y / 2) -- Arsenal aim point, mouse is locked to centre
end

local function aliveCharacter(plr)
    local character = plr.Character
    if not character then return nil end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return nil end
    return character, humanoid
end

local function hitPart(character, hitbox)
    if hitbox == "Head" then return character:FindFirstChild("Head") end
    if hitbox == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    return character:FindFirstChild("HumanoidRootPart")
end

local function teamAllowed(plr, check)
    if not check then return true end
    if not plr.Team or not player.Team then return true end
    return plr.Team ~= player.Team
end

local function canSee(part, character)
    rayParams.FilterDescendantsInstances = {player.Character, character}
    local origin = camera.CFrame.Position
    local result = workspace:Raycast(origin, part.Position - origin, rayParams)
    return result == nil or result.Instance:IsDescendantOf(character)
end

local function predicted(part, amount)
    if not amount or amount <= 0 then return part.Position end
    return part.Position + part.AssemblyLinearVelocity * (amount * 0.05)
end

local function findTarget(fov, hitbox, priority, maxDistance, teamCheck, wallCheck)
    if not camera then return nil end
    local center = crosshair()
    local best, bestScore
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local character, humanoid = aliveCharacter(plr)
            if character and not character:FindFirstChildOfClass("ForceField") and teamAllowed(plr, teamCheck) then
                local part = hitPart(character, hitbox)
                local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
                if part and root then
                    local distance = (root.Position - camera.CFrame.Position).Magnitude
                    if distance <= maxDistance then
                        local screen, onScreen = camera:WorldToViewportPoint(part.Position)
                        if onScreen and screen.Z > 0 then
                            local offset = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                            if offset <= fov and (not wallCheck or canSee(part, character)) then
                                local score = offset
                                if priority == "Distance" then score = distance end
                                if priority == "Health" then score = humanoid.Health end
                                if not bestScore or score < bestScore then
                                    best, bestScore = {part = part, character = character, player = plr}, score
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local function aimAt(position, smoothness)
    if not camera then return end
    local goal = CFrame.new(camera.CFrame.Position, position)
    local alpha = 1
    if smoothness and smoothness > 1 then
        alpha = math.clamp(1 / smoothness, 0.02, 1)
    end
    camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

local function click()
    lastShot = os.clock()
    if mouse1click then
        pcall(mouse1click)
    elseif mouse1press then
        pcall(mouse1press)
        task.delay(0.05, function() pcall(mouse1release) end)
    end
end

-- Arsenal kicks the camera up on every shot. mouse movement is the only thing that should rotate the
-- view, so rotation that happens with the mouse still is recoil and gets lerped back out.
local function stabilise(scale)
    if not camera or scale <= 0 then return end
    local delta = UserInputService:GetMouseDelta()
    if delta.Magnitude > 0.1 then
        recoilBase = camera.CFrame
        return
    end
    local goal = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + recoilBase.LookVector)
    camera.CFrame = camera.CFrame:Lerp(goal, scale)
end

-- [esp] --------------------------------------------------------------------------------------------------------
-- every object is created once per player and then only written to when a value actually changes. a
-- standing player costs zero Drawing writes per frame, a moving one costs position/size only.
local ESP_OBJECTS = { "box", "boxFill", "name", "distance", "health", "healthBg", "healthBar", "tracer" }

-- Drawing.Text.Font: 0 UI, 1 System, 2 Plex, 3 Monospace
local ESP_FONT = { UI = 0, System = 1, Plex = 2, Code = 3 }

local function newDrawing(class)
    if not drawingApi then return nil end
    local ok, object = pcall(drawingApi.new, class)
    return ok and object or nil
end

local function hideEntry(entry)
    local s = entry.state
    if s.hidden then return end
    for key in pairs(s) do s[key] = nil end
    s.hidden = true
    for _, key in ipairs(ESP_OBJECTS) do
        local object = entry[key]
        if object then object.Visible = false end
    end
end

local function espEntry(plr)
    local entry = drawings[plr]
    if entry then return entry end

    entry = {
        box = newDrawing("Square"),
        boxFill = newDrawing("Square"),
        name = newDrawing("Text"),
        distance = newDrawing("Text"),
        health = newDrawing("Text"),
        healthBg = newDrawing("Square"),
        healthBar = newDrawing("Square"),
        tracer = newDrawing("Line"),
        state = {},
    }
    if entry.box then entry.box.Filled = false end
    if entry.boxFill then entry.boxFill.Filled = true end
    for _, key in ipairs({ "name", "distance", "health" }) do
        local text = entry[key]
        if text then
            text.Center = true
            text.OutlineColor = Color3.new(0, 0, 0)
        end
    end
    if entry.healthBg then
        entry.healthBg.Color = Color3.new(0, 0, 0)
        entry.healthBg.Transparency = 0.35
    end
    hideEntry(entry)
    drawings[plr] = entry
    return entry
end

local espActive = false

-- per object cache: only write a property when the value it should hold changed
local function slot(entry, key)
    local s = entry.state[key]
    if not s then
        s = {}
        entry.state[key] = s
    end
    return s, entry[key]
end

local function put(s, object, prop, value)
    if s[prop] ~= value then
        s[prop] = value
        object[prop] = value
    end
end

local function project(camera, position)
    local point, onScreen = camera:WorldToViewportPoint(position)
    if point.Z <= 0 then return nil end
    return point, onScreen
end

local function updateEsp()
    if not library.flags["ESP Enabled"] then
        if espActive then
            espActive = false
            for _, entry in pairs(drawings) do hideEntry(entry) end
        end
        return
    end
    if not drawingApi then
        if not warnedDrawing then
            warnedDrawing = true
            warn("[maple] this executor has no Drawing API, ESP is off")
        end
        return
    end
    if not camera then return end

    espActive = true
    local accent = library.flags["ESP Color"] or Color3.new(1, 1, 1)
    local boxColor = library.flags["ESP Box Color"] or accent
    local boxTrans = library.flags["ESP Box Color Transparency"] or 0
    local nameColor = library.flags["ESP Name Color"] or accent
    local distColor = library.flags["ESP Distance Color"] or accent
    local hpColor = library.flags["ESP Health Color"] or accent
    local tracerColor = library.flags["ESP Tracer Color"] or accent

    local maxDistance = library.flags["ESP Max Distance"] or 2000
    local boxesOn = library.flags["ESP Boxes"] == true
    local namesOn = library.flags["ESP Names"] == true
    local distanceOn = library.flags["ESP Distance"] == true
    local healthOn = library.flags["ESP Health"] == true
    local tracersOn = library.flags["ESP Tracers"] == true
    local teamCheck = library.flags["ESP Team Check"] == true
    local teamColorOn = library.flags["ESP Team Color"] == true
    local singleColor = library.flags["ESP Single Color"] == true

    local boxStyle = library.flags["ESP Box Style"] or "Outline"
    local healthStyle = library.flags["ESP Health Style"] or "Bar"
    local unit = library.flags["ESP Distance Unit"] or "Studs"
    local nameMode = library.flags["ESP Name Mode"] or "Display"
    local tracerOrigin = library.flags["ESP Tracer Origin"] or "Bottom"

    local textSize = library.flags["ESP Text Size"] or 14
    local font = ESP_FONT[library.flags["ESP Font"] or "Plex"] or 2
    local outline = library.flags["ESP Text Outline"] ~= false
    local boxThickness = library.flags["ESP Box Thickness"] or 1
    local tracerThickness = library.flags["ESP Tracer Thickness"] or 1
    local hpWidth = library.flags["ESP Health Width"] or 3

    local drawOutline = boxStyle ~= "Filled"
    local drawFill = boxStyle ~= "Outline"

    local origin = camera.CFrame.Position
    local viewport = camera.ViewportSize
    local fromX = viewport.X / 2
    local fromY = viewport.Y
    if tracerOrigin == "Center" then
        fromY = viewport.Y / 2
    elseif tracerOrigin == "Top" then
        fromY = 0
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local shown = false

        if plr ~= player then
            local character, humanoid = aliveCharacter(plr)
            local head = character and character:FindFirstChild("Head")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if head and root and teamAllowed(plr, teamCheck) then
                local distance = (root.Position - origin).Magnitude
                if distance <= maxDistance then
                    -- Drawing paints in viewport space. WorldToScreenPoint adds the topbar inset on
                    -- top of that and pushes the whole box off the character.
                    local headPoint, headOnScreen = project(camera, head.Position + Vector3.new(0, head.Size.Y * 0.5, 0))
                    local legDrop = humanoid.RigType == Enum.HumanoidRigType.R6 and 3 or (humanoid.HipHeight + 0.4)
                    local footPoint = project(camera, root.Position - Vector3.new(0, legDrop, 0))

                    if headPoint and footPoint and headOnScreen then
                        shown = true
                        local entry = espEntry(plr)
                        entry.state.hidden = false

                        local top = math.min(headPoint.Y, footPoint.Y)
                        local height = math.max(math.abs(footPoint.Y - headPoint.Y), 6)
                        local width = math.max(height * 0.55, 8)
                        local centerX = (headPoint.X + footPoint.X) / 2
                        local left = centerX - width / 2
                        local bottom = top + height

                        -- team colour wins, then single colour, then the per element pickers
                        local boxC, nameC, distC, tracerC = boxColor, nameColor, distColor, tracerColor
                        if singleColor then
                            boxC, nameC, distC, tracerC = accent, accent, accent, accent
                        end
                        if teamColorOn and plr.Team then
                            boxC = plr.Team.TeamColor.Color
                            nameC, distC, tracerC = boxC, boxC, boxC
                        end

                        -- box: outline square, filled square, or both
                        local sb, box = slot(entry, "box")
                        if box then
                            put(sb, box, "Visible", boxesOn and drawOutline)
                            put(sb, box, "Color", boxC)
                            put(sb, box, "Thickness", boxThickness)
                            if sb.x ~= left or sb.y ~= top or sb.w ~= width or sb.h ~= height then
                                box.Position = Vector2.new(left, top)
                                box.Size = Vector2.new(width, height)
                                sb.x, sb.y, sb.w, sb.h = left, top, width, height
                            end
                        end

                        local sf, fill = slot(entry, "boxFill")
                        if fill then
                            put(sf, fill, "Visible", boxesOn and drawFill)
                            put(sf, fill, "Color", boxC)
                            put(sf, fill, "Transparency", boxTrans)
                            if sf.x ~= left or sf.y ~= top or sf.w ~= width or sf.h ~= height then
                                fill.Position = Vector2.new(left, top)
                                fill.Size = Vector2.new(width, height)
                                sf.x, sf.y, sf.w, sf.h = left, top, width, height
                            end
                        end

                        -- name
                        local sn, nameText = slot(entry, "name")
                        if nameText then
                            put(sn, nameText, "Visible", namesOn)
                            put(sn, nameText, "Color", nameC)
                            put(sn, nameText, "Size", textSize)
                            put(sn, nameText, "Font", font)
                            put(sn, nameText, "Outline", outline)
                            put(sn, nameText, "Text", nameMode == "Username" and plr.Name or plr.DisplayName)
                            if sn.x ~= centerX or sn.y ~= top - textSize - 2 then
                                nameText.Position = Vector2.new(centerX, top - textSize - 2)
                                sn.x, sn.y = centerX, top - textSize - 2
                            end
                        end

                        -- distance. the label is only formatted when the rounded value moves, so a
                        -- standing player allocates nothing and writes nothing.
                        local sd, distanceText = slot(entry, "distance")
                        if distanceText then
                            local rounded = math.floor((unit == "Meters" and distance * 0.28 or distance) + 0.5)
                            if sd.k ~= rounded or sd.u ~= unit then
                                sd.k, sd.u = rounded, unit
                                distanceText.Text = (unit == "Meters") and (rounded .. "m") or (rounded .. "st")
                            end
                            put(sd, distanceText, "Visible", distanceOn)
                            put(sd, distanceText, "Color", distC)
                            put(sd, distanceText, "Size", textSize)
                            put(sd, distanceText, "Font", font)
                            put(sd, distanceText, "Outline", outline)
                            if sd.x ~= centerX or sd.y ~= bottom + 1 then
                                distanceText.Position = Vector2.new(centerX, bottom + 1)
                                sd.x, sd.y = centerX, bottom + 1
                            end
                        end

                        -- health: a bar to the left of the box, or a text row under it
                        local ratio = math.clamp(humanoid.Health / math.max(humanoid.MaxHealth, 1), 0, 1)
                        local hpTextOn = healthOn and healthStyle == "Text"
                        local hpBarOn = healthOn and healthStyle == "Bar"

                        local sh, healthText = slot(entry, "health")
                        if healthText then
                            local shownHp = math.ceil(humanoid.Health)
                            if sh.k ~= shownHp then
                                sh.k = shownHp
                                healthText.Text = shownHp .. " hp"
                            end
                            put(sh, healthText, "Visible", hpTextOn)
                            put(sh, healthText, "Color", hpColor)
                            put(sh, healthText, "Size", textSize)
                            put(sh, healthText, "Font", font)
                            put(sh, healthText, "Outline", outline)
                            if sh.x ~= centerX or sh.y ~= bottom + textSize + 2 then
                                healthText.Position = Vector2.new(centerX, bottom + textSize + 2)
                                sh.x, sh.y = centerX, bottom + textSize + 2
                            end
                        end

                        local barX = left - boxThickness - 4 - hpWidth
                        local barHeight = math.max(height * ratio, 0)
                        local shb, hpBg = slot(entry, "healthBg")
                        if hpBg then
                            put(shb, hpBg, "Visible", hpBarOn)
                            if shb.x ~= barX or shb.y ~= top or shb.h ~= height then
                                hpBg.Position = Vector2.new(barX, top)
                                hpBg.Size = Vector2.new(hpWidth, height)
                                shb.x, shb.y, shb.h = barX, top, height
                            end
                        end

                        local shr, hpBar = slot(entry, "healthBar")
                        if hpBar then
                            put(shr, hpBar, "Visible", hpBarOn and barHeight > 0)
                            put(shr, hpBar, "Color", hpColor)
                            if shr.x ~= barX or shr.w ~= hpWidth
                                or shr.y ~= top + height - barHeight or shr.h ~= barHeight then
                                hpBar.Position = Vector2.new(barX, top + height - barHeight)
                                hpBar.Size = Vector2.new(hpWidth, barHeight)
                                shr.x, shr.w, shr.y, shr.h = barX, hpWidth, top + height - barHeight, barHeight
                            end
                        end

                        -- tracer
                        local st, tracer = slot(entry, "tracer")
                        if tracer then
                            local toX, toY = centerX, top + height * 0.5
                            put(st, tracer, "Visible", tracersOn)
                            put(st, tracer, "Color", tracerC)
                            put(st, tracer, "Thickness", tracerThickness)
                            if st.fx ~= fromX or st.fy ~= fromY or st.tx ~= toX or st.ty ~= toY then
                                tracer.From = Vector2.new(fromX, fromY)
                                tracer.To = Vector2.new(toX, toY)
                                st.fx, st.fy, st.tx, st.ty = fromX, fromY, toX, toY
                            end
                        end
                    end
                end
            end
        end

        if not shown then
            local entry = drawings[plr]
            if entry then hideEntry(entry) end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    local entry = drawings[plr]
    if entry then
        for _, key in ipairs(ESP_OBJECTS) do
            local object = entry[key]
            if object then pcall(function() object:Remove() end) end
        end
        drawings[plr] = nil
    end
end)

-- [fov circles] ------------------------------------------------------------------------------------------------
-- radius is the same pixel value findTarget compares against, so the circle is literally the aim area
local function newCircle()
    local c = newDrawing("Circle")
    if c then
        c.Filled = false
        c.Visible = false
    end
    return c
end

local fovCircles = {
    { circle = newCircle(), flag = "FOV Aimbot Draw", colorFlag = "FOV Aimbot Color", radiusFlag = "Aimbot FOV", fallbackRadius = 120, fallbackColor = Color3.fromRGB(0, 200, 255) },
    { circle = newCircle(), flag = "FOV Silent Draw", colorFlag = "FOV Silent Color", radiusFlag = "Silent Aim FOV", fallbackRadius = 120, fallbackColor = Color3.fromRGB(255, 170, 0) },
    { circle = newCircle(), flag = "FOV Trigger Draw", colorFlag = "FOV Trigger Color", radiusFlag = "Trigger FOV", fallbackRadius = 20, fallbackColor = Color3.fromRGB(0, 255, 120) },
    { circle = newCircle(), flag = "FOV Rage Draw", colorFlag = "FOV Rage Color", radiusFlag = "Rage Aim FOV", fallbackRadius = 180, fallbackColor = Color3.fromRGB(255, 60, 60) },
}

local fovState = {}

local function updateFov()
    local center = crosshair()
    local thickness = library.flags["FOV Thickness"] or 1
    local sides = library.flags["FOV Sides"] or 64

    for _, cfg in ipairs(fovCircles) do
        local circle = cfg.circle
        if circle then
            local s = fovState[cfg]
            if not s then
                s = {}
                fovState[cfg] = s
            end

            local radius = library.flags[cfg.radiusFlag] or cfg.fallbackRadius
            local on = library.flags[cfg.flag] == true and radius > 0
            if s.visible ~= on then
                circle.Visible = on
                s.visible = on
            end

            if on then
                local color = library.flags[cfg.colorFlag] or cfg.fallbackColor
                if s.pos ~= center then circle.Position = center; s.pos = center end
                if s.radius ~= radius then circle.Radius = radius; s.radius = radius end
                if s.color ~= color then circle.Color = color; s.color = color end
                if s.thickness ~= thickness then circle.Thickness = thickness; s.thickness = thickness end
                if s.sides ~= sides then circle.NumSides = sides; s.sides = sides end
            end
        end
    end
end

-- [binds] ------------------------------------------------------------------------------------------------------
-- the library sets the bind flag on key down and clears it on key up. if the window loses focus while
-- the key is held the key-up never arrives and the flag sticks on forever, which looks exactly like
-- "the bind is broken". check the real input state and heal the flag.
local function bindHeld(bind)
    if not bind then return false end
    if library.flags[bind.flag] ~= true then return false end

    local key = bind.key
    if not key or key == "none" then return true end

    if key:match("^Mouse") then
        local input = Enum.UserInputType[key]
        if input and not UserInputService:IsMouseButtonPressed(input) then
            library.flags[bind.flag] = false
            return false
        end
    else
        local code = Enum.KeyCode[key]
        if code and not UserInputService:IsKeyDown(code) then
            library.flags[bind.flag] = false
            return false
        end
    end

    return true
end

-- [main loop] --------------------------------------------------------------------------------------------------
local function onRender(delta)
    camera = workspace.CurrentCamera or camera
    if not camera then return end

    -- Arsenal re-applies its own lighting per map, so this is a slow re-assert, not a one shot
    envElapsed = envElapsed + delta
    if envElapsed >= 1 then
        envElapsed = 0
        if library.flags["Fullbright"] then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
            local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmosphere then atmosphere.Density = 0 end
        end
        if library.flags["No Fog"] then
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 1e6
        end
    end

    if library.flags["FOV Enabled"] then
        camera.FieldOfView = library.flags["FOV"]
        fovApplied = true
    elseif fovApplied then
        fovApplied = false
        camera.FieldOfView = 70 -- Arsenal's default, nothing else to restore to
    end

    if library.flags["Third Person"] then
        if player.CameraMode ~= Enum.CameraMode.Classic then
            player.CameraMode = Enum.CameraMode.Classic
        end
        if player.CameraMaxZoomDistance < 20 then
            player.CameraMaxZoomDistance = 20
        end
    end

    -- movement is re-asserted because Arsenal resets the humanoid on respawn
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        local speed = library.flags["Walk Speed"]
        if type(speed) == "number" and speed ~= 16 and math.abs(humanoid.WalkSpeed - speed) > 0.05 then
            humanoid.WalkSpeed = speed
        end
        local jump = library.flags["Jump Power"]
        if type(jump) == "number" and jump ~= 50 then
            if not humanoid.UseJumpPower then humanoid.UseJumpPower = true end
            if math.abs(humanoid.JumpPower - jump) > 0.05 then humanoid.JumpPower = jump end
        end
    end

    local mouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    if mouseDown and not mouseWasDown then
        chanceRoll = math.random() * 100
        lastShot = os.clock()
    end
    mouseWasDown = mouseDown

    local aimActive = library.flags["Aimbot Enabled"] == true or bindHeld(aimBind)
    local rageActive = library.flags["Rage Aim Enabled"] == true or bindHeld(rageBind)

    -- recoil recovery only runs for a short window after a shot, otherwise the camera would fight
    -- the mouse on every frame where the mouse happened to move less than a pixel
    if not aimActive and not rageActive then
        if os.clock() - lastShot < 0.35 then
            stabilise((library.flags["Recoil Scale"] or 0) / 100)
        else
            recoilBase = camera.CFrame
        end
    end

    if rageActive then
        local target = findTarget(
            library.flags["Rage Aim FOV"] or 180,
            library.flags["Rage Aim Hitbox"] or "Head",
            library.flags["Rage Aim Priority"] or "Distance",
            library.flags["Aim Max Distance"] or 1000,
            library.flags["Rage Aim Team Check"],
            not library.flags["Rage Ignore Walls"]
        )
        if target then
            aimAt(predicted(target.part, library.flags["Aimbot Prediction"]), (library.flags["Rage Aim Smoothing"] or 0) + 1)
            recoilBase = camera.CFrame
            if library.flags["Rage Auto Fire"] and os.clock() - lastRageFire > 0.08 then
                lastRageFire = os.clock()
                task.spawn(click)
            end
        end
    elseif aimActive then
        local target = findTarget(
            library.flags["Aimbot FOV"] or 120,
            library.flags["Aimbot Hitbox"] or "Head",
            "FOV",
            library.flags["Aim Max Distance"] or 1000,
            library.flags["Aimbot Team Check"],
            library.flags["Aimbot Wall Check"] or library.flags["Aim Visible Only"]
        )
        if target then
            aimAt(predicted(target.part, library.flags["Aimbot Prediction"]), library.flags["Aimbot Smoothing"] or 1)
            recoilBase = camera.CFrame
        end
    end

    local triggerActive = library.flags["Trigger Enabled"] == true or bindHeld(triggerBind)
    if triggerActive and os.clock() - lastTrigger >= math.max((library.flags["Trigger Delay"] or 0) / 1000, 0.03) then
        local target = findTarget(
            library.flags["Trigger FOV"] or 20,
            library.flags["Aimbot Hitbox"] or "Head",
            "FOV",
            library.flags["Aim Max Distance"] or 1000,
            library.flags["Trigger Team Check"],
            true
        )
        if target then
            lastTrigger = os.clock()
            task.spawn(click)
        end
    end

    silentTarget = nil
    local silentActive = library.flags["Silent Aim Enabled"] == true or bindHeld(silentBind)
    if silentActive then
        local mode = library.flags["Silent Aim Mode"] or "On Shoot"
        if mode == "Always" or mouseDown then
            if chanceRoll <= (library.flags["Silent Aim Chance"] or 100) then
                local target = findTarget(
                    library.flags["Silent Aim FOV"] or 120,
                    library.flags["Aimbot Hitbox"] or "Head",
                    "FOV",
                    library.flags["Aim Max Distance"] or 1000,
                    library.flags["Aimbot Team Check"],
                    library.flags["Silent Aim Wall Check"]
                )
                silentTarget = target and target.part or nil
            end
        end
    end

    updateFov()
    updateEsp() -- every frame, so boxes stay welded to the character instead of trailing
end

-- Camera priority + 1 means this runs after Roblox has moved the camera for the frame, so an aim
-- correction is not overwritten by the game's own camera update.
RunService:BindToRenderStep("maple", Enum.RenderPriority.Camera.Value + 1, onRender)

-- [silent aim hook] --------------------------------------------------------------------------------------------
local hookOk, hookError = pcall(function()
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if not checkcaller() and silentTarget and self == mouse then
            if key == "Hit" then
                return CFrame.new(silentTarget.Position)
            elseif key == "Target" then
                return silentTarget
            elseif key == "UnitRay" then
                local origin = camera.CFrame.Position
                return Ray.new(origin, (silentTarget.Position - origin).Unit * 1000)
            end
        end
        return oldIndex(self, key)
    end)
end)
if not hookOk then
    warn("[maple] silent aim hook failed: " .. tostring(hookError))
end

-- [cleanup] ----------------------------------------------------------------------------------------------------
local baseUnload = library.Unload
function library:Unload()
    pcall(function() RunService:UnbindFromRenderStep("maple") end)
    silentTarget = nil
    for _, entry in pairs(drawings) do
        for _, key in ipairs(ESP_OBJECTS) do
            local object = entry[key]
            if object then pcall(function() object:Remove() end) end
        end
    end
    for _, cfg in ipairs(fovCircles) do
        if cfg.circle then pcall(function() cfg.circle:Remove() end) end
    end
    return baseUnload(self)
end
