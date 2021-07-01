getgenv().SpoofTABLE = true
local gameMeta = getrawmetatable(game)
setreadonly(gameMeta, false)
local oldNamecall = gameMeta.__namecall
local method = nil
local spoofRemote = {}

local function returnData(requestTable, requestData)
    for _, data in next, requestTable do
        if data == requestData then
            return true
        else
        end
    end
    return false
end

function sendNotification(title, text, icon)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = tostring(title),
		Text = tostring(text),
		Icon = "http://www.roblox.com/asset/?id=1204401092"
	})
end

sendNotification("Remote Spoofer","Loading")

for _, remote in next, game:GetDescendants() do
    if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") and not table.find(spoofRemote, remote.Name) then
        table.insert(spoofRemote, remote.Name)
    end
end

gameMeta.__namecall = newcclosure(function(remote, ...)
    local arguments = {...}
    local method = "FireServer" or "InvokeServer"
    if returnData(spoofRemote, remote.Name) == true then
        if getgenv().SpoofTABLE == true then
            remote[method](remote, unpack(arguments))
        else
            remote[method](oldNamecall(remote, ...))
        end
        return
    end
    return oldNamecall(remote, ...)
end)

sendNotification("Remote Spoofer","Loaded")
