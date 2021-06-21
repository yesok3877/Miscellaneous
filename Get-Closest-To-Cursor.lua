local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

return function()
	local closestTarg = math.huge
	local Target = nil
	for _, Player in next, Players:GetPlayers() do
        if Player ~= LocalPlayer then
            local playerCharacter = Player.Character
            if playerCharacter then
                local playerHumanoid = playerCharacter:FindFirstChild("HumanoidRootPart")
                if playerHumanoid then
                    local hitVector, onScreen = Camera:WorldToScreenPoint(playerHumanoid.Position)
                    if onScreen then
                        local CCF = Camera.CFrame.p
                        if workspace:FindPartOnRayWithIgnoreList(Ray.new(CCF, (playerHumanoid.Position-CCF).unit * 5000),{Player}) then
                            local hitTargMagnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(hitVector.X, hitVector.Y)).magnitude
                            if hitTargMagnitude < closestTarg then
                                Target = Player
                                closestTarg = hitTargMagnitude
                            end
                        end
                    end
                end
            end
		end
	end
	return Target
end
