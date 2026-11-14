-- Maple - paste this whole file into the executor and hit Execute.
-- built for Arsenal: camera aim, silent aim on the Mouse object, trigger bot, ESP, recoil control.
-- binds: E = aim assist (hold), Q = trigger bot (hold), R = rage (hold), End = menu

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
Aim:AddToggle{text = "Enabled", flag = "Aimbot Enabled"}:AddBind({flag = "Aimbot Bind", key = "E", mode = "hold"});
Aim:AddSlider{text = "FOV", flag = "Aimbot FOV", min = 0, max = 360, value = 120, suffix = " deg"}
Aim:AddSlider{text = "Smoothing", flag = "Aimbot Smoothing", min = 1, max = 30, value = 8}
Aim:AddSlider{text = "Prediction", flag = "Aimbot Prediction", min = 0, max = 2, float = 0.01, value = 0}
Aim:AddList{text = "Hitbox", flag = "Aimbot Hitbox", value = "Head", values = {"Head", "Torso", "HumanoidRootPart"}};
Aim:AddDivider("Checks");
Aim:AddToggle{text = "Team Check", flag = "Aimbot Team Check"}
Aim:AddToggle{text = "Wall Check", flag = "Aimbot Wall Check"}

local Silent = CombatCol1:AddSection("Silent Aim")
Silent:AddDivider("Main");
Silent:AddToggle{text = "Enabled", flag = "Silent Aim Enabled"}
Silent:AddSlider{text = "Hit Chance", flag = "Silent Aim Chance", min = 0, max = 100, value = 100, suffix = "%"}
Silent:AddList{text = "Mode", flag = "Silent Aim Mode", value = "On Shoot", values = {"Always", "On Shoot"}};
Silent:AddDivider("Checks");
Silent:AddToggle{text = "Wall Check", flag = "Silent Aim Wall Check"}

local Trigger = CombatCol2:AddSection("Trigger Bot")
Trigger:AddDivider("Main");
Trigger:AddToggle{text = "Enabled", flag = "Trigger Enabled"}:AddBind({flag = "Trigger Bind", key = "Q", mode = "hold"});
Trigger:AddSlider{text = "Delay", flag = "Trigger Delay", min = 0, max = 500, value = 0, suffix = " ms"}
Trigger:AddSlider{text = "FOV", flag = "Trigger FOV", min = 0, max = 100, value = 20}
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
Esp:AddToggle{text = "Enabled", flag = "ESP Enabled"}:AddColor({flag = "ESP Color", color = Color3.fromRGB(255, 255, 255)});
Esp:AddToggle{text = "Boxes", flag = "ESP Boxes"}
Esp:AddToggle{text = "Names", flag = "ESP Names"}
Esp:AddToggle{text = "Distance", flag = "ESP Distance"}
Esp:AddToggle{text = "Health", flag = "ESP Health"}
Esp:AddToggle{text = "Tracers", flag = "ESP Tracers"}:AddColor({flag = "Tracer Color", color = Color3.fromRGB(255, 255, 255)});
Esp:AddSlider{text = "Refresh", flag = "ESP Refresh", min = 0.05, max = 1, float = 0.05, value = 0.1, suffix = "s"}

local EspChecks = VisualsCol1:AddSection("ESP Checks")
EspChecks:AddDivider("Main");
EspChecks:AddToggle{text = "Team Check", flag = "ESP Team Check"}
EspChecks:AddToggle{text = "Use Team Color", flag = "ESP Team Color"}:AddColor({flag = "ESP Team Accent", color = Color3.fromRGB(0, 170, 255)});
EspChecks:AddSlider{text = "Max Distance", flag = "ESP Max Distance", min = 100, max = 5000, value = 2000, suffix = " st"}

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

library:AddConnection(RunService.RenderStepped, function()
    local camera = workspace.CurrentCamera
    if camera and library.flags["FOV Enabled"] then
        camera.FieldOfView = library.flags["FOV"]
    end
end)

-- [Rage] -----------------------------------------------------------------------------------------------------
local RageTab = library:AddTab("Rage")
local RageCol = RageTab:AddColumn()

local RageAim = RageCol:AddSection("Aim")
RageAim:AddDivider("Main");
RageAim:AddToggle{text = "Enabled", flag = "Rage Aim Enabled"}:AddBind({flag = "Rage Aim Bind", key = "R", mode = "hold"});
RageAim:AddSlider{text = "FOV", flag = "Rage Aim FOV", min = 0, max = 360, value = 180, suffix = " deg"}
RageAim:AddSlider{text = "Smoothing", flag = "Rage Aim Smoothing", min = 0, max = 10, float = 0.1, value = 0}
RageAim:AddList{text = "Priority", flag = "Rage Aim Priority", value = "Distance", values = {"Distance", "Health", "FOV"}};
RageAim:AddDivider("Behaviour");
RageAim:AddToggle{text = "Auto Fire", flag = "Rage Auto Fire"}
RageAim:AddToggle{text = "Ignore Walls", flag = "Rage Ignore Walls"}

local RageFov = RageCol:AddSection("FOV Circle")
RageFov:AddDivider("Draw");
-- drawing the circle itself is a render step in your cheat loop, this only publishes the settings
RageFov:AddToggle{text = "Draw", flag = "Rage FOV Draw"}:AddColor({flag = "Rage FOV Color", color = Color3.fromRGB(255, 60, 60)});
RageFov:AddSlider{text = "Thickness", flag = "Rage FOV Thickness", min = 1, max = 5, value = 1}
RageFov:AddSlider{text = "Sides", flag = "Rage FOV Sides", min = 3, max = 64, value = 64}

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
    main.ImageColor3 = library.flags["UI Background Color"] or Color3.new(1, 1, 1)
    main.ImageTransparency = math.clamp(1 - opacity + fade, 0, 1)
    main.TileSize = UDim2.new(0, tile, 0, tile)
    main.BackgroundTransparency = fade
end

MenuSection:AddDivider("Appearance");
MenuSection:AddList{text = "Background", flag = "UI Background", max = 4, value = "Floral", values = {"Floral", "Flowers", "Circles", "Hearts"}, callback = applyBackground}

-- the pattern is a tiled image, so it tints through ImageColor3. nothing in the library
-- writes that for you, the color option only paints its own swatch.
MenuSection:AddColor{text = "Background Color", flag = "UI Background Color", color = Color3.fromRGB(255, 255, 255), trans = 1,
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
local espElapsed = 0
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
local function newDrawing(class)
    if not drawingApi then return nil end
    local ok, object = pcall(drawingApi.new, class)
    return ok and object or nil
end

local function hideEntry(entry)
    for _, object in pairs(entry) do
        if object then object.Visible = false end
    end
end

local function espEntry(plr)
    local entry = drawings[plr]
    if entry then return entry end

    entry = {
        box = newDrawing("Square"),
        name = newDrawing("Text"),
        distance = newDrawing("Text"),
        health = newDrawing("Text"),
        tracer = newDrawing("Line"),
    }
    for _, text in ipairs({entry.name, entry.distance, entry.health}) do
        if text then
            text.Size = 14
            text.Font = 2
            text.Center = true
            text.Outline = true
        end
    end
    if entry.box then
        entry.box.Thickness = 1
        entry.box.Filled = false
    end
    if entry.tracer then
        entry.tracer.Thickness = 1
    end
    hideEntry(entry)
    drawings[plr] = entry
    return entry
end

local function updateEsp()
    if not library.flags["ESP Enabled"] then
        for _, entry in pairs(drawings) do hideEntry(entry) end
        return
    end
    if not drawingApi then
        if not warnedDrawing then
            warnedDrawing = true
            warn("[maple] this executor has no Drawing API, ESP is off")
        end
        return
    end

    local accent = library.flags["ESP Color"] or Color3.new(1, 1, 1)
    local tracerColor = library.flags["Tracer Color"] or Color3.new(1, 1, 1)
    local maxDistance = library.flags["ESP Max Distance"] or 2000
    local origin = camera.CFrame.Position
    local viewport = camera.ViewportSize

    for _, plr in ipairs(Players:GetPlayers()) do
        local entry = espEntry(plr)
        local shown = false

        if plr ~= player then
            local character, humanoid = aliveCharacter(plr)
            local head = character and character:FindFirstChild("Head")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if head and root and teamAllowed(plr, library.flags["ESP Team Check"]) then
                local distance = (root.Position - origin).Magnitude
                if distance <= maxDistance then
                    local headPoint, headVisible = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local footPoint, footVisible = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 2.8, 0))

                    if headVisible and footVisible and headPoint.Z > 0 then
                        shown = true
                        local top = math.min(headPoint.Y, footPoint.Y)
                        local height = math.abs(footPoint.Y - headPoint.Y)
                        local width = math.max(height * 0.55, 8)
                        local centerX = (headPoint.X + footPoint.X) / 2
                        local bottom = top + height
                        local color = accent

                        if library.flags["ESP Team Color"] and plr.Team then
                            color = plr.Team.TeamColor.Color
                        end

                        if entry.box then
                            entry.box.Visible = library.flags["ESP Boxes"] == true
                            entry.box.Color = color
                            entry.box.Position = Vector2.new(centerX - width / 2, top)
                            entry.box.Size = Vector2.new(width, height)
                        end
                        if entry.name then
                            entry.name.Visible = library.flags["ESP Names"] == true
                            entry.name.Color = color
                            entry.name.Position = Vector2.new(centerX, top - 16)
                            entry.name.Text = plr.Name
                        end
                        if entry.distance then
                            entry.distance.Visible = library.flags["ESP Distance"] == true
                            entry.distance.Color = color
                            entry.distance.Position = Vector2.new(centerX, bottom + 1)
                            entry.distance.Text = ("%dm"):format(distance)
                        end
                        if entry.health then
                            entry.health.Visible = library.flags["ESP Health"] == true
                            entry.health.Color = color
                            entry.health.Position = Vector2.new(centerX, bottom + 16)
                            entry.health.Text = ("%d hp"):format(humanoid.Health)
                        end
                        if entry.tracer then
                            entry.tracer.Visible = library.flags["ESP Tracers"] == true
                            entry.tracer.Color = tracerColor
                            entry.tracer.From = Vector2.new(viewport.X / 2, viewport.Y)
                            entry.tracer.To = Vector2.new(centerX, bottom)
                        end
                    end
                end
            end
        end

        if not shown then hideEntry(entry) end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    local entry = drawings[plr]
    if entry then
        for _, object in pairs(entry) do
            if object then pcall(function() object:Remove() end) end
        end
        drawings[plr] = nil
    end
end)

-- [fov circle] -------------------------------------------------------------------------------------------------
local circle = newDrawing("Circle")
if circle then
    circle.Filled = false
    circle.Visible = false
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
    end
    mouseWasDown = mouseDown

    local aimActive = library.flags["Aimbot Enabled"] or library.flags["Aimbot Bind"]
    local rageActive = library.flags["Rage Aim Enabled"] or library.flags["Rage Aim Bind"]

    if not aimActive and not rageActive then
        stabilise((library.flags["Recoil Scale"] or 0) / 100)
        recoilBase = camera.CFrame
    end

    if rageActive then
        local target = findTarget(
            library.flags["Rage Aim FOV"] or 180,
            library.flags["Aimbot Hitbox"] or "Head",
            library.flags["Rage Aim Priority"] or "Distance",
            library.flags["Aim Max Distance"] or 1000,
            library.flags["Aimbot Team Check"],
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

    local triggerActive = library.flags["Trigger Enabled"] or library.flags["Trigger Bind"]
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
    if library.flags["Silent Aim Enabled"] then
        local mode = library.flags["Silent Aim Mode"] or "On Shoot"
        if mode == "Always" or mouseDown then
            if chanceRoll <= (library.flags["Silent Aim Chance"] or 100) then
                local target = findTarget(
                    math.max(library.flags["Aimbot FOV"] or 120, 40),
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

    if circle then
        circle.Position = crosshair()
        circle.Radius = library.flags["Rage Aim FOV"] or 180
        circle.Thickness = library.flags["Rage FOV Thickness"] or 1
        circle.NumSides = library.flags["Rage FOV Sides"] or 64
        circle.Color = library.flags["Rage FOV Color"] or Color3.fromRGB(255, 60, 60)
        circle.Visible = library.flags["Rage FOV Draw"] == true
    end

    espElapsed = espElapsed + delta
    if espElapsed >= (library.flags["ESP Refresh"] or 0.1) then
        espElapsed = 0
        updateEsp()
    end
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
        for _, object in pairs(entry) do
            if object then pcall(function() object:Remove() end) end
        end
    end
    if circle then pcall(function() circle:Remove() end) end
    return baseUnload(self)
end
