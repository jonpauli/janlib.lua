-- Maple - paste this whole file into the executor and hit Execute.

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
Recoil:AddSlider{text = "Recoil Scale", flag = "Recoil Scale", min = 0, max = 100, value = 0, suffix = "%"}
Recoil:AddSlider{text = "Spread Scale", flag = "Spread Scale", min = 0, max = 100, value = 0, suffix = "%"}

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
Env:AddToggle{text = "Third Person", flag = "Third Person"}

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

-- [Init] -----------------------------------------------------------------------------------------------------
library:Init()
library:selectTab(library.tabs[1])
