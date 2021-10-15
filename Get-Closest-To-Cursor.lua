local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

return function()
    local Range, Target = math.huge
    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= Players.LocalPlayer and Player.Character and Player.Character.PrimaryPart then
            local Position, Visible = Camera:WorldToScreenPoint(Player.Character.PrimaryPart.Position)
            if Visible then
                local Distance = Vector2.new((Position.X - Mouse.X), (Position.Y - Mouse.Y)).magnitude
                if Distance <= Range then
                    Range = Distance 
                    Target = Player
                end
            end
        end
    end
    return Target
end
