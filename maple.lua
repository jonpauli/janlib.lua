-- Maple - single-file cheat menu on Jans Library
--
-- run:
--   loadstring(game:HttpGet("https://raw.githubusercontent.com/jonpauli/janlib.lua/main/maple.lua"))()
-- or paste this whole file into the executor.
--
-- input: E = aim assist, Q = trigger bot, R = rage aim, End = menu
-- every feature reads library.flags, so configs restore state correctly.

-- [library] ---------------------------------------------------------------------------------------------------
if getgenv().library then pcall(function() getgenv().library:Unload() end) end

local LIB_URLS = {
    "https://raw.githubusercontent.com/jonpauli/janlib.lua/main/janlib.lua",
    "https://files.catbox.moe/tlzk1o.lua",
}

local librarySource
for _, url in ipairs(LIB_URLS) do
    local ok, body = pcall(function() return game:HttpGet(url) end)
    -- under 50 KB means the old truncated object or a stale CDN cache hit
    if ok and type(body) == "string" and #body > 50000 then
        librarySource = body
        break
    end
end
assert(librarySource, "[maple] could not fetch Jans Library from github or the mirror")

local libraryChunk, libraryError = loadstring(librarySource)
assert(libraryChunk, "[maple] library syntax error: " .. tostring(libraryError))
libraryChunk()

local library = getgenv().library
assert(library, "[maple] library loaded but getgenv().library is nil")

-- [services] --------------------------------------------------------------------------------------------------
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

library.title = "Maple"
library.foldername = "maple_cnfgs"

-- [Combat] ---------------------------------------------------------------------------------------------------
local CombatTab = library:AddTab("Combat")
local CombatCol1 = CombatTab:AddColumn()
local CombatCol2 = CombatTab:AddColumn()

local Aim = CombatCol1:AddSection("Aim Assist")
Aim:AddDivider("Main");
Aim:AddToggle{text = "Enabled", flag = "Aimbot Enabled"}:AddBind({flag = "Aimbot Bind", key = "E", mode = "hold"});
Aim:AddSlider{text = "FOV", flag = "Aimbot FOV", min = 0, max = 500, value = 120, suffix = " px"}
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
Trigger:AddSlider{text = "FOV", flag = "Trigger FOV", min = 0, max = 200, value = 24, suffix = " px"}
Trigger:AddDivider("Checks");
Trigger:AddToggle{text = "Team Check", flag = "Trigger Team Check"}

local AimChecks = CombatCol2:AddSection("Target")
AimChecks:AddDivider("Misc");
AimChecks:AddSlider{text = "Max Distance", flag = "Aim Max Distance", min = 50, max = 2000, value = 1000, suffix = " st"}
AimChecks:AddToggle{text = "Visible Only", flag = "Aim Visible Only", state = true}

-- [Visuals] --------------------------------------------------------------------------------------------------
local VisualsTab = library:AddTab("Visuals")
local VisualsCol1 = VisualsTab:AddColumn()
local VisualsCol2 = VisualsTab:AddColumn()

local Esp = VisualsCol1:AddSection("Player ESP")
Esp:AddDivider("Main");
Esp:AddToggle{text = "Enabled", flag = "ESP Enabled"}:AddColor({flag = "ESP Color", color = Color3.fromRGB(255, 255, 255)});
Esp:AddToggle{text = "Boxes", flag = "ESP Boxes", state = true}
Esp:AddToggle{text = "Names", flag = "ESP Names", state = true}
Esp:AddToggle{text = "Distance", flag = "ESP Distance", state = true}
Esp:AddToggle{text = "Health", flag = "ESP Health", state = true}
Esp:AddToggle{text = "Tracers", flag = "ESP Tracers"}:AddColor({flag = "Tracer Color", color = Color3.fromRGB(255, 255, 255)});

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

-- [Rage] -----------------------------------------------------------------------------------------------------
local RageTab = library:AddTab("Rage")
local RageCol = RageTab:AddColumn()

local RageAim = RageCol:AddSection("Aim")
RageAim:AddDivider("Main");
RageAim:AddToggle{text = "Enabled", flag = "Rage Aim Enabled"}:AddBind({flag = "Rage Aim Bind", key = "R", mode = "hold"});
RageAim:AddSlider{text = "FOV", flag = "Rage Aim FOV", min = 0, max = 500, value = 180, suffix = " px"}
RageAim:AddList{text = "Priority", flag = "Rage Aim Priority", value = "FOV", values = {"FOV", "Distance", "Health"}};
RageAim:AddToggle{text = "Auto Fire", flag = "Rage Auto Fire"}
RageAim:AddToggle{text = "Ignore Walls", flag = "Rage Ignore Walls"}

local RageFov = RageCol:AddSection("FOV Circle")
RageFov:AddDivider("Draw");
RageFov:AddToggle{text = "Draw", flag = "Rage FOV Draw", state = true}:AddColor({flag = "Rage FOV Color", color = Color3.fromRGB(255, 60, 60)});
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

MenuSection:AddDivider("Appearance");
local background = MenuSection:AddList{text = "Background", flag = "UI Background", max = 4, value = "Floral", values = {"Floral", "Flowers", "Circles", "Hearts"}, callback = function(value)
    if library.main then library.main.Image = backgrounds[value] end
end}
background:AddColor({flag = "UI Background Color", color = Color3.new(), trans = 1, calltrans = function(trans)
    if library.main then library.main.ImageTransparency = 1 - trans end
end})
MenuSection:AddSlider{text = "Tile Size", flag = "UI Tile Size", min = 50, max = 500, value = 50, callback = function(value)
    if library.main then library.main.TileSize = UDim2.new(0, value, 0, value) end
end}
MenuSection:AddSlider{text = "UI Transparency", flag = "UI Transparency", min = 0, max = 1, float = 0.05, value = 0, callback = function(value)
    if library.main then library.main.BackgroundTransparency = value end
end}

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

-- [init ui] --------------------------------------------------------------------------------------------------
library:Init()
library:selectTab(library.tabs[1])

-- [runtime helpers] ------------------------------------------------------------------------------------------
local function alive(character)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return humanoid ~= nil and humanoid.Health > 0, humanoid
end

local function bone(character, name)
    if not character then return nil end
    if name == "Head" then
        return character:FindFirstChild("Head")
    elseif name == "Torso" then
        return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
    end
    return character:FindFirstChild("HumanoidRootPart")
end

local function teamAllowed(plr, check)
    if not check then return true end
    if not plr.Team or not player.Team then return true end
    return plr.Team ~= player.Team
end

local function screenPoint(position)
    if not camera then return Vector2.zero, false, 0 end
    local point, onScreen = camera:WorldToViewportPoint(position)
    return Vector2.new(point.X, point.Y), onScreen and point.Z > 0, point.Z
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function visible(part, character)
    if not camera then return false end
    rayParams.FilterDescendantsInstances = {player.Character, character, camera}
    local origin = camera.CFrame.Position
    local result = Workspace:Raycast(origin, part.Position - origin, rayParams)
    return result == nil or result.Instance:IsDescendantOf(character)
end

local function predicted(part, amount)
    if not amount or amount <= 0 then return part.Position end
    local velocity = part.AssemblyLinearVelocity
    return part.Position + velocity * (amount * 0.05)
end

local function click()
    if mouse1click then
        pcall(mouse1click)
    else
        pcall(mouse1press)
        task.delay(0.04, function() pcall(mouse1release) end)
    end
end

local function pick(pixels, hitbox, teamCheck, wallCheck, priority)
    local best, bestScore
    local mousePos = UserInputService:GetMouseLocation()
    local cameraPos = camera.CFrame.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and teamAllowed(plr, teamCheck) then
            local character = plr.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.Health > 0 and root then
                local part = bone(character, hitbox)
                if part then
                    local point, onScreen = screenPoint(part.Position)
                    local distance = (root.Position - cameraPos).Magnitude
                    if onScreen and distance <= (library.flags["Aim Max Distance"] or 1000) then
                        local score = (mousePos - point).Magnitude
                        if score <= pixels and (not wallCheck or visible(part, character)) then
                            if priority == "Distance" then
                                score = distance
                            elseif priority == "Health" then
                                score = humanoid.Health
                            end
                            if not bestScore or score < bestScore then
                                best, bestScore = part, score
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

-- [aim assist] ------------------------------------------------------------------------------------------------
local function aim(target, smoothness)
    if not camera or not target then return end
    local goal = CFrame.new(camera.CFrame.Position, predicted(target, library.flags["Aimbot Prediction"]))
    local alpha = math.clamp(1 - ((smoothness or 8) - 1) / 29, 0.02, 0.95)
    camera.CFrame = camera.CFrame:Lerp(goal, alpha)
end

-- [esp] -------------------------------------------------------------------------------------------------------
local DrawingApi = Drawing
local draws = {}
local warnedNoDrawing = false

local function draw(class)
    if not DrawingApi then return nil end
    local ok, object = pcall(DrawingApi.new, class)
    return ok and object or nil
end

local function espFor(plr)
    local entry = draws[plr]
    if not entry then
        entry = {box = draw("Square"), name = draw("Text"), distance = draw("Text"), health = draw("Text"), tracer = draw("Line")}
        if entry.name then entry.name.Size = 14; entry.name.Font = 2; entry.name.Center = true; entry.name.Outline = true end
        if entry.distance then entry.distance.Size = 14; entry.distance.Font = 2; entry.distance.Center = true; entry.distance.Outline = true end
        if entry.health then entry.health.Size = 14; entry.health.Font = 2; entry.health.Center = true; entry.health.Outline = true end
        if entry.tracer then entry.tracer.Thickness = 1 end
        if entry.box then entry.box.Thickness = 1; entry.box.Filled = false end
        for _, object in pairs(entry) do if object then object.Visible = false end end
        draws[plr] = entry
    end
    return entry
end

local function hideAll()
    for _, entry in pairs(draws) do
        for _, object in pairs(entry) do
            if object then object.Visible = false end
        end
    end
end

local function updateEsp()
    if not library.flags["ESP Enabled"] then hideAll() return end
    if not DrawingApi then
        if not warnedNoDrawing then
            warnedNoDrawing = true
            warn("[maple] this executor has no Drawing API, ESP is off")
        end
        return
    end

    local cameraPos = camera.CFrame.Position
    local maxDistance = library.flags["ESP Max Distance"] or 2000
    local accent = library.flags["ESP Color"] or Color3.new(1, 1, 1)
    local tracerColor = library.flags["Tracer Color"] or Color3.new(1, 1, 1)
    local viewport = camera.ViewportSize

    for _, plr in ipairs(Players:GetPlayers()) do
        local entry = espFor(plr)
        local shown = false
        local character = plr.Character

        if plr ~= player and character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local head = character:FindFirstChild("Head")
            local root = character:FindFirstChild("HumanoidRootPart")

            if humanoid and humanoid.Health > 0 and head and root then
                local distance = (root.Position - cameraPos).Magnitude
                if distance <= maxDistance and teamAllowed(plr, library.flags["ESP Team Check"]) then
                    local headPoint, headVisible = screenPoint(head.Position + Vector3.new(0, 0.4, 0))
                    local rootPoint, rootVisible = screenPoint(root.Position - Vector3.new(0, 2.9, 0))

                    if headVisible and rootVisible then
                        local height = math.abs(rootPoint.Y - headPoint.Y)
                        local width = math.max(height * 0.55, 8)
                        local centerX = (headPoint.X + rootPoint.X) / 2
                        local top = math.min(headPoint.Y, rootPoint.Y)
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
                            entry.distance.Text = ("%d st"):format(distance)
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
                        shown = true
                    end
                end
            end
        end

        if not shown then
            for _, object in pairs(entry) do
                if object then object.Visible = false end
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    local entry = draws[plr]
    if entry then
        for _, object in pairs(entry) do
            if object then pcall(function() object:Remove() end) end
        end
        draws[plr] = nil
    end
end)

-- [fov circle] ------------------------------------------------------------------------------------------------
local circle = draw("Circle")
local silentTarget
local lastTrigger = 0
local lastAutoFire = 0
local mouseWasDown = false
local chanceRoll = 100

-- [main loop] -------------------------------------------------------------------------------------------------
library:AddConnection(RunService.RenderStepped, function(delta)
    camera = Workspace.CurrentCamera or camera
    if not camera then return end

    -- lighting / fov override
    if library.flags["FOV Enabled"] then
        camera.FieldOfView = library.flags["FOV"]
    end

    -- aim assist
    if library.flags["Aimbot Enabled"] or library.flags["Aimbot Bind"] then
        local target = pick(
            library.flags["Aimbot FOV"] or 120,
            library.flags["Aimbot Hitbox"] or "Head",
            library.flags["Aimbot Team Check"],
            library.flags["Aimbot Wall Check"] or library.flags["Aim Visible Only"],
            "FOV"
        )
        if target then
            aim(target, library.flags["Aimbot Smoothing"])
        end
    end

    -- silent aim: decide the target + roll the hit chance on mouse down
    local mouseDown = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    if mouseDown and not mouseWasDown then
        chanceRoll = math.random() * 100
    end
    mouseWasDown = mouseDown

    silentTarget = nil
    if library.flags["Silent Aim Enabled"] then
        local mode = library.flags["Silent Aim Mode"] or "On Shoot"
        if mode == "Always" or mouseDown then
            if chanceRoll <= (library.flags["Silent Aim Chance"] or 100) then
                silentTarget = pick(
                    220,
                    library.flags["Aimbot Hitbox"] or "Head",
                    library.flags["Aimbot Team Check"],
                    library.flags["Silent Aim Wall Check"],
                    "FOV"
                )
            end
        end
    end

    -- trigger bot
    if (library.flags["Trigger Enabled"] or library.flags["Trigger Bind"]) and os.clock() - lastTrigger >= (library.flags["Trigger Delay"] or 0) / 1000 then
        local target = pick(
            library.flags["Trigger FOV"] or 24,
            library.flags["Aimbot Hitbox"] or "Head",
            library.flags["Trigger Team Check"],
            true,
            "FOV"
        )
        if target and visible(target, target.Parent) then
            lastTrigger = os.clock()
            task.spawn(click)
        end
    end

    -- rage: snap + autofire
    if library.flags["Rage Aim Enabled"] or library.flags["Rage Aim Bind"] then
        local target = pick(
            library.flags["Rage Aim FOV"] or 180,
            library.flags["Aimbot Hitbox"] or "Head",
            library.flags["Aimbot Team Check"],
            not library.flags["Rage Ignore Walls"],
            library.flags["Rage Aim Priority"] or "FOV"
        )
        if target then
            local goal = CFrame.new(camera.CFrame.Position, predicted(target, library.flags["Aimbot Prediction"]))
            camera.CFrame = camera.CFrame:Lerp(goal, 0.85)
            if library.flags["Rage Auto Fire"] and os.clock() - lastAutoFire > 0.08 then
                lastAutoFire = os.clock()
                task.spawn(click)
            end
        end
    end

    -- fov circle at the mouse
    if circle then
        local mousePos = UserInputService:GetMouseLocation()
        circle.Visible = library.flags["Rage FOV Draw"] == true
        circle.Position = mousePos
        circle.Radius = library.flags["Rage Aim FOV"] or 180
        circle.Thickness = library.flags["Rage FOV Thickness"] or 1
        circle.NumSides = library.flags["Rage FOV Sides"] or 64
        circle.Color = library.flags["Rage FOV Color"] or Color3.fromRGB(255, 60, 60)
    end

    updateEsp()
end)

-- [silent aim hook] -------------------------------------------------------------------------------------------
local hop, hookError = pcall(function()
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
if not hop then
    warn("[maple] silent aim hook failed: " .. tostring(hookError))
end

-- [cleanup] ---------------------------------------------------------------------------------------------------
local baseUnload = library.Unload
function library:Unload()
    silentTarget = nil
    for _, entry in pairs(draws) do
        for _, object in pairs(entry) do
            if object then pcall(function() object:Remove() end) end
        end
    end
    if circle then pcall(function() circle:Remove() end) end
    return baseUnload(self)
end
