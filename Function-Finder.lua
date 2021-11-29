local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
local Mouse = LocalPlayer:GetMouse()

local Ancestor = game.FindFirstAncestor
local Descendant = game.IsDescendantOf
local Ray = Ray.new
local Floor = math.floor
local Count = table.getn
local Find = table.find
local Insert = table.insert
local Match = string.find
local Lower = string.lower
local Split = string.split
local Format = string.format
local Delay = task.wait

local Library do
    Library = {
        Instance = {Camera, Mouse, Character, Ray},

        Key = {
            Function = {"shoot", "fire", "bullet", "projectile", "hit", "unit", "trajectory"},
            Instance = {"barrel", "flash", "muzzle", "sight", "aim", "shoot", "fire", "bullet", "unit"},
            Class = {"Part", "Attachment", "MeshPart"},
            Ignore = {"CameraModule", "PlayerModule", "Chat", "ClientChatModules", "CameraScript", "ControlScript", "CorePackages", "CoreGui", "RobloxGui", "Animate", "ChatScript", "BubbleChat", "PlayerScriptsLoader"}
        },

        Function = {
            Found = {},
            Suggest = {}
        },

        Search = {
            Instance = function(self, Value)
                if typeof(Value) == "Instance" then
                    local Array = Library.Instance

                    for Index = 1, Count(Array) do
                        local Instance = rawget(Array, Index)
                        
                        if (Value == Instance or select(2, pcall(function()
                            return Descendant(Value, Instance)
                        end))) then
                            return Value
                        end
                    end
                end
            end,
            Key = function(self, Value)
                if typeof(Value) == "string" then
                    local Array = Library.Key.Instance

                    for Index = 1, Count(Array) do
                        local Instance = rawget(Array, Index)

                        if Match(Lower(tostring(Value)), Instance) then
                            return Value
                        end
                    end
                end
            end,
            Class = function(self, Value)
                if typeof(Value) == "Instance" then
                    local Array = Library.Key.Class

                    for Index = 1, Count(Array) do
                        local Class = rawget(Array, Index)

                        if Value.ClassName == Class then
                            return self:Key(Value)
                        end
                    end
                end
            end,
        },

        Scan = function(self, Function)
            local Info = getinfo(Function)
            local Source = (getfenv(Function).script or nil)

            local Constant = getconstants(Function)
            local Upvalue = getupvalues(Function)
            local Proto = getprotos(Function)

            if Find(self.Function.Found, Info.name) then
                return
            end

            if Source then
                local Array = self.Key.Ignore

                for Index = 1, Count(Array) do
                    local Script = rawget(Array, Index)

                    if (Source.name == Script or select(2, pcall(function()
                        return Ancestor(Source, Script)
                    end))) then
                        return
                    else
                        local Ancestor = Split(Info.short_src, ".")

                        for Index = 1, Count(Ancestor) do
                            if Find(Array, rawget(Ancestor, Index)) then
                                return
                            end
                        end
                    end
                end
            end

            do
                local Function = Info.name

                for Index = 1, Count(Constant) do
                    if self.Search:Key(rawget(Constant, Index)) and not Find(self.Function.Found, Function) then
                        --Delay()
                        print("     ", Function)
                        Insert(self.Function.Found, Function)
                    end
                end
            end

            do
                local Function = Info.name

                for Index = 1, Count(Upvalue) do
                    local Value = rawget(Constant, Index)
                    local Search = self.Search

                    if (Search:Instance(Value) or Search:Class(Value)) and not Find(self.Function.Found, Function) then
                        --Delay()
                        print("     ", Function)
                        Insert(self.Function.Found, Function)
                    end
                end
            end

            do
                local Function = Info.name
                local Array = self.Key.Function

                for Index = 1, Count(Array) do
                    local Name = rawget(Array, Index)
                    local Format = Format((Function .. " (%i, %i)"), Info.numparams, Count(Proto))

                    if Match(Lower(Function), Name) and not Find(self.Function.Suggest, Format) then
                        Insert(self.Function.Suggest, Format)
                    end
                end
            end

            do
                for Index = 1, Count(Proto) do
                    self:Scan(rawget(Proto, Index))
                end
            end
        end
    }
end

local Time = tick()

local Separate = string.rep("---", 100)
print(Separate)
print("Functions Found:")

local Garbage = getgc(true) do

    for Index = 1, Count(Garbage) do
        local Object = rawget(Garbage, Index)

        if typeof(Object) == "function" and islclosure(Object) and getinfo(Object).name ~= "" then
            --Delay()
            Library:Scan(Object)
        end
    end
end

print("Functions Suggested:")

do
    local Array = Library.Function.Suggest

    for Index = 1, Count(Array) do
        --Delay()
        print("     ", rawget(Array, Index))
    end
end

print("Took", Floor(tick() - Time), "Seconds To Complete.")
print(Count(Library.Function.Found), "Functions Were Scanned.")
print("Accuracy:", (Floor((Count(Library.Function.Suggest) / Count(Library.Function.Found)) * 100) .. "%"))

print(Separate)
