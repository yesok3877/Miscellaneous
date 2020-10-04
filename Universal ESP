local Players = game:GetService("Players")
local UserInput = game:GetService("UserInputService")
local HTTP = game:GetService("HttpService")
local RunServ = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

--// VARIABLES \\--

local PlaceId = game.PlaceId
local LocalPlayer = Players.LocalPlayer
local CharacterAdded
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
PlayerGui:SetTopbarTransparency(1)
local Mouse = LocalPlayer:GetMouse()
getgenv().Distance = 2000

if LocalPlayer.Character then
    CharacterAdded = LocalPlayer.Character
else
    CharacterAdded = LocalPlayer.CharacterAdded:Wait()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
local espFolder = Instance.new("Folder", ScreenGui)
local rigType = string.split(tostring(LocalPlayer.Character:WaitForChild("Humanoid").RigType), ".")[3]
local selected_teamType = "Regular"
local selected_rigType

local rigTypeR6 = {
	["Head"] = true,
	["Torso"] = true,
	["LowerTorso"] = true,
	["Left Arm"] = true,
	["Right Arm"] = true,
	["Left Leg"] = true,
	["Right Leg"] = true
}

local rigTypeR15 = {
    ["Head"] = true,
    ["UpperTorso"] = true,
    ["LowerTorso"] = true,
    ["LeftUpperArm"] = true,
    ["RightUpperArm"] = true,
    ["RightLowerArm"] = true,
    ["LeftLowerArm"] = true,
    ["LeftHand"] = true,
    ["RightHand"] = true,
    ["LeftUpperLeg"] = true,
    ["RightUpperLeg"] = true,
    ["LeftLowerLeg"] = true,
    ["RightLowerLeg"] = true,
    ["LeftFoot"] = true,
    ["RightFoot"] = true
}

local rigTypeStrucid = {
    ["LeftLowerArm"] = true,
    ["RightLowerArm"] = true,
    ["Head"] = true,
    ["LeftUpperLeg"] = true,
    ["LeftUpperLeg"] = true,
    ["RightLowerLeg"] = true,
    ["Neck"] = true,
    ["RightFoot"] = true,
    ["UpperTorso"] = true,
    ["LeftLowerLeg"] = true,
    ["LowerTorso"] = true,
    ["RightUpperLeg"] = true,
    ["LeftUpperArm"] = true,
    ["RightUpperArm"] = true
}

local rigTypeAceOfSpadez = {
	["Head"] = true,
	["LeftFoot"] = true,
	["LowerLeftArm"] = true,
	["LowerLeftLeg"] = true,
	["LowerRightArm"] = true,
	["LowerRightLeg"] = true,
	["LowerTorso"] = true,
	["RightFoot"] = true,
	["MidTorso"] = true,
	["UpperLeftArm"] = true,
	["UpperLeftLeg"] = true,
	["UpperRightArm"] = true,
	["UpperRightLeg"] = true,
	["UpperTorso"] = true,
	["LeftHandle"] = true,
	["RightHandle"] = true,
	["Shoulders"] = true,
	["Torso"] = true
}

local rigTypeStandardIssue = {
	["lowerrightleg"] = true,
	["leftforearm"] = true,
	["lowerleftleg"] = true,
	["waist"] = true,
	["Torso"] = true,
	["rightforearm"] = true,
	["Head"] = true,
}

local rigTypeRecoil = {
    ["Head"] = true,
	["LeftFoot"] = true,
	["RightFoot"] = true,
	["LeftLowerLeg"] = true,
	["LeftUpperLeg"] = true,
	["RightLowerLeg"] = true,
	["RightUpperLeg"] = true,
	["UpperTorso"] = true,
	["LowerTorso"] = true,
	["LeftUpperArm"] = true,
	["RightUpperArm"] = true,
	["LeftLowerArm"] = true,
	["RightLowerArm"] = true,
	["RightHand"] = true,
	["LeftHand"] = true
}

local rigTypePloyguns = {
    ["Head"] = true,
	["Right Forearm"] = true,
	["Right Leg"] = true,
	["Right Foreleg"] = true,
	["Left Arm"] = true,
	["Right Hand"] = true,
	["Right Foot"] = true,
	["Right Arm"] = true,
	["Left Hand"] = true,
	["Left Foreleg"] = true,
	["Left Leg"] = true,
	["Hips"] = true,
	["Torso"] = true,
	["Left Foot"] = true,
	["Mid"] = true
}

local rigTypeKineticCode = {
    ["UpperTorso"] = true,
	["Head"] = true,
	["Hips"] = true,
	["LeftArm"] = true,
	["LeftFoot"] = true,
    ["LeftHip"] = true,
    ["LeftKnuckles"] = true,
    ["LeftLeg"] = true,
    ["LeftPalm"] = true,
    ["LeftShoulder"] = true,
    ["LowerTorso"] = true,
    ["Neck"] = true,
    ["RightArm"] = true,
    ["RightFoot"] = true,
    ["RightHip"] = true,
    ["RightKnuckles"] = true,
    ["RightLeg"] = true,
    ["RightPalm"] = true,
    ["RightShoulder"] = true
}

if PlaceId == 2377868063 then
    selected_rigType = rigTypeStrucid
elseif PlaceId == 2555870920 then
    selected_rigType = rigTypeAceOfSpadez
elseif PlaceId == 388599755 then
    selected_rigType = rigTypePloyguns
elseif PlaceId == 1837257681 then
    selected_rigType = rigTypeStandardIssue
elseif PlaceId == 4651779470 then
    selected_rigType = rigTypeRecoil
    selected_teamType = "Recoil"
elseif PlaceId == 4738545896 then
    selected_rigType = rigTypeR15
    selected_teamType = "ShootOut"
elseif PlaceId == 3210442546 then
    selected_rigType = rigTypeR15
    selected_teamType = "IslandRoyale"
elseif PlaceId == 401356052 then
    selected_rigType = rigTypeKineticCode
elseif rigType == "R6" then
    selected_rigType = rigTypeR6
elseif rigType == "R15" then
    selected_rigType = rigTypeR15
end

local function teamType(player)
    if selected_teamType == "Recoil" then
        return player:FindFirstChild("GameStats").Team.Value
    elseif selected_teamType == "ShootOut" then
        if player == LocalPlayer then
            return tostring(BrickColor.new(0.172549, 0.329412, 1))
        else
            for _, Player in next, Players:GetPlayers() do
                if Player.Character then
                    if Player.Character:FindFirstChild("Head") then
                        if Player.Character == player.Character then
                            if Player.Character.Head:FindFirstChild("NameTag") then
                                NameTag = Player.Character.Head.NameTag.TextLabel
                                if string.find(tostring(BrickColor.new(NameTag.TextColor3)), "red") then
                                    return tostring(BrickColor.new(NameTag.TextColor3))
                                elseif string.find(tostring(BrickColor.new(NameTag.TextStrokeColor3)), "blue") then
                                    return tostring(BrickColor.new(NameTag.TextStrokeColor3))
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif selected_teamType == "IslandRoyale" then
        return player:FindFirstChild("TeamName").Value
    else
        if player.Team or player.TeamColor then
            local teamplayer = player.Team or player.TeamColor
            return teamplayer
        end
    end
end

local function characterType(player)
    playerName = player.Name
    if PlaceId == 401356052 then
        if workspace["Players"][playerName] or workspace["Players"]:WaitForChild(player) then
            local playerCharacter = workspace["Players"][playerName] or workspace["Players"]:WaitForChild(player)
            return playerCharacter
        end
    elseif player.Character or workspace:FindFirstChild(playerName) then
        local playerCharacter = player.Character or workspace:FindFirstChild(playerName)
        return playerCharacter
    end
end

local function FFA()
    sameTeam = 0
    for _, player in next, Players:GetPlayers() do
        if teamType(player) == teamType(LocalPlayer) then
            sameTeam = sameTeam + 1
        end
    end
    if sameTeam == #Players:GetChildren() then
        return true
    else
        return false
    end
end

local function createBox(player)
	local lines = Instance.new("Frame")
	lines.Name = player.Name
	lines.BackgroundTransparency = 1
	lines.AnchorPoint = Vector2.new(0.5,0.5)
	
	local outlines = Instance.new("Folder", lines)
	outlines.Name = "outlines"
	local inlines = Instance.new("Folder", lines)
	inlines.Name = "inlines"
	
	local outline1 = Instance.new("Frame", outlines)
	outline1.Name = "left"
	outline1.BorderSizePixel = 0
	outline1.BackgroundColor3 = Color3.new(0,0,0)
	outline1.Size = UDim2.new(0,-1,1,0)
	
	local outline2 = Instance.new("Frame", outlines)
	outline2.Name = "right"
	outline2.BorderSizePixel = 0
	outline2.BackgroundColor3 = Color3.new(0,0,0)
	outline2.Position = UDim2.new(1,0,0,0)
	outline2.Size = UDim2.new(0,1,1,0)
	
	local outline3 = Instance.new("Frame", outlines)
	outline3.Name = "up"
	outline3.BorderSizePixel = 0
	outline3.BackgroundColor3 = Color3.new(0,0,0)
	outline3.Size = UDim2.new(1,0,0,-1)
	
	local outline4 = Instance.new("Frame", outlines)
	outline4.Name = "down"
	outline4.BorderSizePixel = 0
	outline4.BackgroundColor3 = Color3.new(0,0,0)
	outline4.Position = UDim2.new(0,0,1,0)
	outline4.Size = UDim2.new(1,0,0,1)
	
	local inline1 = Instance.new("Frame", inlines)
	inline1.Name = "left"
	inline1.BorderSizePixel = 0
	inline1.Size = UDim2.new(0,1,1,0)
	
	local inline2 = Instance.new("Frame", inlines)
	inline2.Name = "right"
	inline2.BorderSizePixel = 0
	inline2.Position = UDim2.new(1,0,0,0)
	inline2.Size = UDim2.new(0,-1,1,0)
	
	local inline3 = Instance.new("Frame", inlines)
	inline3.Name = "up"
	inline3.BorderSizePixel = 0
	inline3.Size = UDim2.new(1,0,0,1)
	
	local inline4 = Instance.new("Frame", inlines)
	inline4.Name = "down"
	inline4.BorderSizePixel = 0
	inline4.Position = UDim2.new(0,0,1,0)
	inline4.Size = UDim2.new(1,0,0,-1)
	
	local text = Instance.new("TextLabel")
	text.Name = "nametag"
	text.Position =  UDim2.new(0.5,0,0,-9)
	text.Size = UDim2.new(0,100,0,-20)
	text.AnchorPoint = Vector2.new(0.5,0.5)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.Font = Enum.Font.Code
	text.TextSize = 16
	text.TextStrokeTransparency = 0
	
	for _,v in pairs(inlines:GetChildren()) do
		v.BackgroundColor3 = Color3.fromRGB(255, 74, 74)
	end
	
	return lines
end

local function updateEsp(player, folder)
    RunServ:BindToRenderStep("Get_" .. player.Name .. "_ESP", 1, function()
        local playerCharacter = characterType(player)
        local xMin = Camera.ViewportSize.X
        local yMin = Camera.ViewportSize.Y
        local xMax = 0
        local yMax = 0
        if teamType(player) ~= teamType(LocalPlayer) or FFA() then
            if player ~= LocalPlayer and playerCharacter and playerCharacter:FindFirstChild("Humanoid") and playerCharacter.Humanoid.Health > 0 then
                local box = folder
                local _, onScreen = Camera:WorldToScreenPoint(playerCharacter.HumanoidRootPart .Position)
                if onScreen and box then
                    box.Visible = true
                    local function getCorners(obj, size)
                        local corners = {
                            Vector3.new(obj.X+size.X/2, obj.Y+size.Y/2, obj.Z+size.Z/2);
                            Vector3.new(obj.X-size.X/2, obj.Y+size.Y/2, obj.Z+size.Z/2);
                            
                            Vector3.new(obj.X-size.X/2, obj.Y-size.Y/2, obj.Z-size.Z/2);
                            Vector3.new(obj.X+size.X/2, obj.Y-size.Y/2, obj.Z-size.Z/2);
                            
                            Vector3.new(obj.X-size.X/2, obj.Y+size.Y/2, obj.Z-size.Z/2);
                            Vector3.new(obj.X+size.X/2, obj.Y+size.Y/2, obj.Z-size.Z/2);
                            
                            Vector3.new(obj.X-size.X/2, obj.Y-size.Y/2, obj.Z+size.Z/2);
                            Vector3.new(obj.X+size.X/2, obj.Y-size.Y/2, obj.Z+size.Z/2);
                        }
                        return corners
                    end
                    local cornerCount = 1
                    local allCorners = {}
                    for _, bodyPart in next, playerCharacter:GetChildren() do
                        if selected_rigType[bodyPart.Name] then
                            local fetchCorners = getCorners(bodyPart.CFrame, bodyPart.Size)
                            for _, corner in next, fetchCorners do
                                table.insert(allCorners, cornerCount, corner)
                                cornerCount = cornerCount + 1
                            end
                        end
                    end
                    for _, corner in next, allCorners do
                        local pos = Camera:WorldToScreenPoint(corner)
                        if pos.X > xMax then
                            xMax = pos.X
                        end
                        if pos.X < xMin then
                            xMin = pos.X
                        end
                        if pos.Y > yMax then
                            yMax = pos.Y
                        end
                        if pos.Y < yMin then
                            yMin = pos.Y
                        end
                    end
                    local xSize = xMax - xMin
                    local ySize = yMax - yMin
                    box.Position = UDim2.new(0,xMin+(Vector2.new(xMax,0)-Vector2.new(xMin,0)).magnitude/2,0,yMin+(Vector2.new(0,yMax)-Vector2.new(0,yMin)).magnitude/2)
                    box.Size = UDim2.new(0,xSize,0,ySize)
                else
                    box.Visible = false
                end
            else
                box.Visible = false
            end
        end
    end)
end

local function esp(player)
    if player ~= LocalPlayer and characterType(player).Humanoid.Health > 0 then
        espBox = createBox(player)
        updateEsp(player, espBox)
        espBox.Parent = espFolder
    end
end

Players.PlayerAdded:Connect(function(Player)
    esp(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    esp(Player)
end)

for _, Player in next, Players:GetPlayers() do
    esp(Player)
end
