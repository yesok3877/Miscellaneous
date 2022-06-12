local Players = game.Players
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

local ScreenPoint = Camera.WorldToScreenPoint
local Children = Players.GetPlayers
local Vector2 = Vector2.new
local Get = rawget

return function()
    local Range, Target = math.huge
    local Players = Children(Players)
    
    for Index = 1, #Players do
        local Player = Get(Players, Index)
        
        if Player ~= LocalPlayer and Player.Character and Player.Character.PrimaryPart then
            local Position, Visible = ScreenPoint(Camera, Player.Character.PrimaryPart.Position)
            
            if Visible then
                local Distance = Vector2((Position.X - Mouse.X), (Position.Y - Mouse.Y)).Magnitude
                
                if Distance <= Range then
                    Range = Distance 
                    Target = Player
                end
            end
        end
    end
    
    return Target
end
