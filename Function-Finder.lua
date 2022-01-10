local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local Character = LocalPlayer.Character
local Mouse = LocalPlayer:GetMouse()

local Ancestor = game.FindFirstAncestor
local Descendant = game.IsDescendantOf
local Ray = Ray.new
local String = tostring
local Type = typeof
local Get = rawget
local Select = select
local Call = pcall
local Closure = islclosure
local Floor = math.floor
local Find = table.find
local Insert = table.insert
local Match = string.find
local Lower = string.lower
local Split = string.split
local Format = string.format
local Delay = task.wait
local Info = debug.getinfo
local Constants = debug.getconstants
local Upvalues = debug.getupvalues
local Protos = debug.getprotos

local Library do
    Library = {
        Instance = {Camera, Mouse, Character, Ray},

        Key = {
            Function = {'shoot', 'fire', 'bullet', 'projectile', 'hit', 'unit', 'trajectory'},
            Instance = {'barrel', 'flash', 'muzzle', 'sight', 'aim', 'shoot', 'fire', 'bullet', 'unit', 'unitray'},
            Class = {'Part', 'Attachment', 'MeshPart'},
            Ignore = {'CameraModule', 'PlayerModule', 'Chat', 'ClientChatModules', 'CameraScript', 'ControlScript', 'CorePackages', 'CoreGui', 'RobloxGui', 'Animate', 'ChatScript', 'BubbleChat', 'PlayerScriptsLoader'}
        },

        Function = {
            Found = {},
            Suggest = {}
        },

        Search = {
            Instance = function(self, Value)
                if Type(Value) == 'Instance' then
                    local Array = Library.Instance

                    for Index = 1, #Array do
                        local Instance = Get(Array, Index)
                        
                        if (Value == Instance or Select(2, Call(Descendant, Value, Instance))) then
                            return Value
                        end
                    end
                end
            end,
            Key = function(self, Value)
                if Type(Value) == 'string' then
                    local Array = Library.Key.Instance

                    for Index = 1, #Array do
                        local Instance = Get(Array, Index)

                        if Match(Lower(String(Value)), Instance) then
                            return Value
                        end
                    end
                end
            end,
            Class = function(self, Value)
                if Type(Value) == 'Instance' then
                    local Array = Library.Key.Class

                    for Index = 1, #Array do
                        local Class = Get(Array, Index)

                        if Value.ClassName == Class then
                            return self:Key(Value)
                        end
                    end
                end
            end,
        },

        Scan = function(self, Function)
            local Info = Info(Function)
            local Source = (getfenv(Function).script or nil)

            local Constant = Constants(Function)
            local Upvalue = Upvalues(Function)
            local Proto = Protos(Function)

            if Find(self.Function.Found, Info.name) then
                return
            end

            if Source then
                local Array = self.Key.Ignore

                for Index = 1, #Array do
                    local Script = Get(Array, Index)

                    if (Source.name == Script or Select(2, Call(Ancestor, Source, Script))) then
                        return
                    else
                        local Ancestor = Split(String(Info.source), '.')

                        for Index = 1, #Ancestor do
                            if Find(Array, Get(Ancestor, Index)) then
                                return
                            end
                        end
                    end
                end
            end

            do
                local Function = Info.name

                for Index = 1, #Constant do
                    if self.Search:Key(Get(Constant, Index)) then
                        local Format = Format(('"%s"' .. '  -->  ' .. Function), (String(Source) or 'nil'))

                        if not Find(self.Function.Found, Format) then
                            --Delay()
                            print('     ', Format)
                            Insert(self.Function.Found, Format)
                        end
                    end
                end
            end

            do
                local Function = Info.name

                for Index = 1, #Upvalue do
                    local Value = Get(Constant, Index)
                    local Search = self.Search

                    if (Search:Instance(Value) or Search:Class(Value)) then
                        local Format = Format(('"%s"' .. '  -->  ' .. Function), Source.name)

                        if not Find(self.Function.Found, Format) then
                            --Delay()
                            print('     ', Format)
                            Insert(self.Function.Found, Format)
                        end
                    end
                end
            end

            do
                local Function = Info.name
                local Array = self.Key.Function

                for Index = 1, #Array do
                    local Name = Get(Array, Index)
                    local Format = Format((Function .. ' (%i, %i)'), Info.numparams, #Proto)

                    if Match(Lower(Function), Name) and not Find(self.Function.Suggest, Format) then
                        Insert(self.Function.Suggest, Format)
                    end
                end
            end

            do
                for Index = 1, #Proto do
                    --Delay()
                    self:Scan(Get(Proto, Index))
                end
            end
        end
    }
end

local Time = tick()

local Separate = string.rep('---', 100)
print(Separate)
print('Functions Found:')

local Garbage = getgc(true) do

    for Index = 1, #Garbage do
        local Object = Get(Garbage, Index)

        if Type(Object) == 'function' and Closure(Object) and Info(Object).name ~= '' then
            --Delay()
            Library:Scan(Object)
        end
    end
end

print('Functions Suggested:')

do
    local Array = Library.Function.Suggest

    for Index = 1, #Array do
        --Delay()
        print('     ', Get(Array, Index))
    end
end

print('Took', Floor(tick() - Time), 'Seconds To Complete.')
print(#Library.Function.Found, 'Functions Were Scanned.')
print('Accuracy:', (Floor((#Library.Function.Suggest / #Library.Function.Found) * 100) .. '%'))

print(Separate)
