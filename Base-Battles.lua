local GetTarget = loadstring(game:HttpGet(('https://raw.githubusercontent.com/yesok3877/Miscellaneous/master/Get-Closest-To-Cursor.lua')))()
local LocalPlayer = game:GetService("Players").LocalPlayer
local Libraries = game:GetService("ReplicatedStorage").Libraries
local Gameplay = require(Libraries.Gameplay)
local Weapon = require(Libraries.Weapon)
local Direction = Gameplay.GetDir
local Fire = Weapon.Fire
local Teams = require(Libraries.Global).Teams

do
    for _, Object in pairs(getgc()) do
        if typeof(Object) == "function" and getinfo(Object).name == "startShooting" then
            setupvalue(Object, 4, -math.huge)
        end
    end
end

do
    Gameplay.GetDir = function(...)
        local Target = GetTarget()
        if Target and Teams[Target] ~= Teams[LocalPlayer] then
            local Origin = Direction(...)
            return Origin, (Target.Character.Head.Position - Origin).Unit
        end
        return Direction(...)
    end
end

do
    Weapon.Fire = function(self, ...)
        local Arguments = {...}
        local Player = self.player
        local config = self.config
        if Player == LocalPlayer then
            local Target = GetTarget()
            local char = (Target ~= nil and Target.Character)
            if Target and Teams[Target] ~= Teams[LocalPlayer] and char.Humanoid.Health ~= 0 then
                local Head = char.Head
                local Hit = Head.Position
                local Bullet = require(Libraries.Projectile).new(Player, Hit, Hit, config.gravityK)
                local ID = Arguments[4]
                local damage = config.damage
                Bullet.position = Hit
                Bullet.hasImpacted = Head
                require(Libraries.Gameplay).DoHit(ID, Head, Hit, damage, Bullet.velocity, ID, 1, Bullet.t)
            end
            self.maxAmmo = math.huge
            self.ammo = math.huge
        end
        return Fire(self, ...)
    end
end
