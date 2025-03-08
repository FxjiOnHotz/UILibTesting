local CustomTheme = {
    SchemeColor = Color3.fromRGB(math.random(1,255), math.random(1,255), math.random(1,255)),
    Background = Color3.fromRGB(25, 25, 25),
    Header = Color3.fromRGB(20, 20, 20),
    TextColor = Color3.fromRGB(255, 255, 255),
    ElementColor = Color3.fromRGB(20, 20, 20)
}

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/FxjiOnHotz/FujiHub/refs/heads/main/Resources/KavoUILibraryBackup.lua"))()
local Window = Library.CreateLib("FujiHub v1 | Pillar Chase 2", CustomTheme)

-- Toggles

local ObjectiveESP = false

-- Tabs

local MainTab = Window:NewTab("Main")
local TasksTab = Window:NewTab("Tasks")
local VisualsTab = Window:NewTab("Visuals")
local PlayerTab = Window:NewTab("Player")

-- Sections

local MainSection = MainTab:NewSection("Game Info")
local MainSectionUI = MainTab:NewSection("UI")
local PlayerSection = PlayerTab:NewSection("Player")
local VisualsSection = VisualsTab:NewSection("Visuals")
local TasksSection = TasksTab:NewSection("Tasks")

-- Tasks Tab

TasksSection:NewButton("Insta Activate Task", "Sets HoldDuration of all tasks to 0.", function()
    for _, containerName in pairs({"ObjectiveInteract", "ObjectiveInteract2", "Objectives1", "Objectives2"}) do
        local container = workspace.Map:FindFirstChild(containerName)
        if container then
            for _, objective in pairs(container:GetChildren()) do
                for _, descendant in pairs(objective:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") then
                        descendant.HoldDuration = 0
                    end
                end
            end
        end
    end
end)



TasksSection:NewButton("Teleport to Random Task (Objective ESP to use)", "Teleports you to a random task.", function()
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local HRP = character:FindFirstChild("HumanoidRootPart")
    if not HRP then return end

    -- Find all tasks with a Highlight
    local tasksWithHighlight = {}
    for _, containerName in pairs({"ObjectiveInteract", "ObjectiveInteract2", "Objectives1", "Objectives2"}) do
        local container = workspace.Map:FindFirstChild(containerName)
        if container then
            for _, objective in pairs(container:GetChildren()) do
                if objective:FindFirstChild("Highlight") then
                    table.insert(tasksWithHighlight, objective)
                end
            end
        end
    end

    -- Choose a random task
    if #tasksWithHighlight > 0 then
        local randomTask = tasksWithHighlight[math.random(1, #tasksWithHighlight)]
        local teleportPosition = randomTask:GetPivot().Position -- Get the position of the task

        -- Teleport the player and anchor them
        HRP.CFrame = CFrame.new(teleportPosition + Vector3.new(0, 3, 0)) -- Teleport slightly above the task
        HRP.Anchored = true

        -- Unanchor after 1 second
        task.delay(1, function()
            HRP.Anchored = false
        end)
    else
        warn("No tasks with highlights found.")
    end
end)


-- Player Tab

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")

local speedEnabled = false
local kaijuSpeed = 16
local speedConnection
local charConnection

local function setWalkSpeed()
    if humanoid then
        humanoid.WalkSpeed = kaijuSpeed
    end
end

local function enableSpeedLoop(enable)
    if enable then
        if humanoid then
            setWalkSpeed()
            speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(setWalkSpeed)
        end

        charConnection = player.CharacterAdded:Connect(function(newCharacter)
            character = newCharacter
            humanoid = newCharacter:WaitForChild("Humanoid")

            setWalkSpeed()
            speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(setWalkSpeed)
        end)
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        if charConnection then
            charConnection:Disconnect()
            charConnection = nil
        end
        if humanoid then
            humanoid.WalkSpeed = 16 -- Reset to default speed
        end
    end
end

PlayerSection:NewSlider("Speed", "", 500, 0, function(value)
    kaijuSpeed = value
    if speedEnabled then
        setWalkSpeed()
    end
end)

PlayerSection:NewToggle("Enable Speed", "Starts/stops your speed that you set.", function(state)
    speedEnabled = state
    enableSpeedLoop(state)
end)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:FindFirstChildOfClass("Humanoid")

local jumpPower = 50 -- Default JumpPower
local infiniteJumpEnabled = false

-- Function to apply the jump power
local function setJumpPower()
    if humanoid then
        humanoid.UseJumpPower = true
        humanoid.JumpPower = jumpPower
    end
end

-- Infinite Jump Function
local function onJumpRequest()
    if infiniteJumpEnabled and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

-- Slider for setting JumpPower

PlayerSection:NewSlider("JumpPower", "", 500, 0, function(value)
    jumpPower = value
    setJumpPower()
end)

PlayerSection:NewToggle("Enable JumpPower", "Starts/stops your jumppower that you set.", function(state)
    infiniteJumpEnabled = state
    if state then
        setJumpPower()
        UserInputService.JumpRequest:Connect(onJumpRequest)
    else
        if humanoid then
            humanoid.JumpPower = 50 -- Reset to default
        end
    end
end)

-- Visuals Tab

VisualsSection:NewToggle("Objective ESP", "Highlights all objectives.", function(state)
    ObjectiveESP = state
    local triggeredObjectives = {} -- Store triggered objectives

    while ObjectiveESP do
        for _, containerName in pairs({"ObjectiveInteract", "ObjectiveInteract2", "Objectives1", "Objectives2"}) do
            local container = workspace.Map:FindFirstChild(containerName)
            if container then
                for _, Objective in pairs(container:GetChildren()) do
                    if (Objective:IsA("Model") or Objective:IsA("Part") or Objective:IsA("MeshPart")) and not triggeredObjectives[Objective] then
                        -- Remove existing ESP elements
                        if Objective:FindFirstChild("Highlight") then
                            Objective.Highlight:Destroy()
                        end
                        if Objective:FindFirstChild("BillboardGui") then
                            Objective.BillboardGui:Destroy()
                        end

                        -- Create new Highlight
                        local Highlight = Instance.new("Highlight")
                        Highlight.Parent = Objective
                        Highlight.FillColor = Color3.fromRGB(0, 155, 0)
                        Highlight.FillTransparency = 0.5
                        Highlight.Adornee = Objective

                        -- Create BillboardGui
                        local Billboard = Instance.new("BillboardGui")
                        Billboard.Name = "BillboardGui"
                        Billboard.Size = UDim2.new(0, 100, 0, 50)
                        Billboard.StudsOffset = Vector3.new(0, 2, 0)
                        Billboard.AlwaysOnTop = true
                        Billboard.Parent = Objective

                        local TextLabel = Instance.new("TextLabel")
                        TextLabel.Size = UDim2.new(1, 0, 1, 0)
                        TextLabel.BackgroundTransparency = 1
                        TextLabel.Text = Objective.Name
                        TextLabel.TextColor3 = Color3.new(1, 1, 1)
                        TextLabel.TextScaled = true
                        TextLabel.Font = Enum.Font.SourceSansBold
                        TextLabel.Parent = Billboard

                        -- Connect ProximityPrompt trigger event
                        for _, prompt in pairs(Objective:GetDescendants()) do
                            if prompt:IsA("ProximityPrompt") then
                                prompt.Triggered:Connect(function(player)
                                    if player == game.Players.LocalPlayer then
                                        -- Mark objective as triggered
                                        triggeredObjectives[Objective] = true

                                        -- Remove ESP elements permanently
                                        if Objective:FindFirstChild("Highlight") then
                                            Objective.Highlight:Destroy()
                                        end
                                        if Objective:FindFirstChild("BillboardGui") then
                                            Objective.BillboardGui:Destroy()
                                        end
                                    end
                                end)
                            end
                        end
                    end
                end
            end
        end
        task.wait(1)
    end

    -- Cleanup when ObjectiveESP is turned off
    for _, containerName in pairs({"ObjectiveInteract", "ObjectiveInteract2", "Objectives1", "Objectives2"}) do
        local container = workspace.Map:FindFirstChild(containerName)
        if container then
            for _, Objective in pairs(container:GetChildren()) do
                if Objective:FindFirstChild("Highlight") then
                    Objective.Highlight:Destroy()
                end
                if Objective:FindFirstChild("BillboardGui") then
                    Objective.BillboardGui:Destroy()
                end
            end
        end
    end
end)


-- Main Tab

local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

MainSection:NewButton("Game Name: " .. GameName, "The game's name", function()
    toClipboard(game.Name)
end)

MainSection:NewButton("PlaceId: " .. game.PlaceId, "The game's place id", function()
    toClipboard(game.PlaceId)
end)

MainSection:NewButton("JobId: " .. game.JobId, "The game's job id", function()
    toClipboard(game.JobId)
end)

MainSectionUI:NewKeybind("Toggle UI", "Key to toggle the gui.", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)
