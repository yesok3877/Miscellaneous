











local dmgmodule = require(game.ReplicatedStorage.Modules.Damage)

function addvelocitytobb(Hit,veloc)
		local instance=Instance.new("BodyVelocity")
		instance.Parent=Hit
		instance.Velocity=Hit.Velocity+veloc
		--instance.RotVelocity=Vector3.new(math.random(-10,10),math.random(-10,10),math.random(-10,10)).unit*veloc
		instance.P=15000
		instance.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
		delay(.1,function()
		instance:Destroy()
		end)	
end


game.ReplicatedStorage.Events.BURNME.OnServerEvent:connect(function(player,fire,timetaken)
	timetaken=math.min(1,math.floor(timetaken*100)/100)
	if fire and fire:FindFirstChild("creator") and fire.creator.Value and game.Workspace.Status.Preparation.Value==false then
		local killerman=fire.creator.Value
		local victim=player
		if victim and victim.Character and victim.Character:FindFirstChild("Humanoid") and victim.Character.Humanoid.Health>0 and (victim==killerman or victim.Status.Team.Value=="Terrorist" or victim.Status.Team.Value~=killerman.Status.Team.Value)  then
			if victim.Character.Humanoid:FindFirstChild("creator") then
				victim.Character.Humanoid.creator:Destroy()
			end
			local tag=fire.creator:clone()
			tag.Parent=victim.Character.Humanoid
			delay(1,function()
				tag:Destroy()
			end)			
			local DPS=20+((60-20)*(timetaken/1))
			dmgmodule.takeDamage(tag.Value,victim.Character.Humanoid,DPS/5,game.ReplicatedStorage.Weapons[tag.NameTag.Value],false,false)
		end
	end
end)
--Handle shattering parts

function createTriangle(a, b, c, template, depth)
	depth=0.15
	local edges = {
		{longest = (c - b), other = (a - b), position = b},
		{longest = (a - c), other = (b - c), position = c},
		{longest = (b - a), other = (c - a), position = a}
	}
	table.sort(edges, function(a, b) return a.longest.magnitude > b.longest.magnitude end)
	local edge = edges[1]
	-- get angle between two vectors
	local theta = math.acos(edge.longest.unit:Dot(edge.other.unit)) -- angle between two vectors
	-- SOHCAHTOA
	local s1 = Vector2.new(edge.other.magnitude * math.cos(theta), edge.other.magnitude * math.sin(theta))
	local s2 = Vector2.new(edge.longest.magnitude - s1.x, s1.y)
	-- positions
	local p1 = edge.position + edge.other * 0.5 -- wedge1's position
	local p2 = edge.position + edge.longest + (edge.other - edge.longest) * 0.5 -- wedge2's position
	-- rotation matrix facing directions
	local right = edge.longest:Cross(edge.other).unit
	local up = right:Cross(edge.longest).unit
	local back = edge.longest.unit
	-- put together the cframes
	local cf1 = CFrame.new( -- wedge1 cframe
		p1.x, p1.y, p1.z,
		-right.x, up.x, back.x,
		-right.y, up.y, back.y,
		-right.z, up.z, back.z
	)
	local cf2 = CFrame.new( -- wedge2 cframe
		p2.x, p2.y, p2.z,
		right.x, up.x, -back.x,
		right.y, up.y, -back.y,
		right.z, up.z, -back.z
	)
	-- put it all together by creating the wedges
	local w1 = template:Clone()
	local w2 = template:Clone()
	w1.Size = Vector3.new(depth, s1.y, s1.x)
	w2.Size = Vector3.new(depth, s2.y, s2.x)
	w1.CFrame = cf1
	w2.CFrame = cf2
	w1.Anchored = false
	w2.Anchored = false
	return {w1,w2}
end

function getThinAxis(part)
	local vals = {part.Size.X,part.Size.Y,part.Size.Z}
	local lowest = math.min(vals[1],vals[2],vals[3])
	
	local axis
	if lowest == vals[1] then axis = 1 end
	if lowest == vals[2] then axis = 2 end
	if lowest == vals[3] then axis = 3 end
	
	return axis,lowest
end

function getPoints(part)
	
	local thinAxis = getThinAxis(part)
	
	local width,height,depth = part.Size.X/2,part.Size.Y/2,part.Size.Z/2
	
	local up = CFrame.new(0,height,0)
	local down = CFrame.new(0,-height,0)
	local left = CFrame.new(-width,0,0)
	local right = CFrame.new(width,0,0)
	local front = CFrame.new(0,0,-depth)
	local back = CFrame.new(0,0,depth)
	

	if thinAxis == 1 then
		--X is small, get points on Y and Z	
		local tab = {
			part.CFrame * up * front,
			part.CFrame * down * front,
			part.CFrame * down * back,
			part.CFrame * up * back,
		}
		if part:IsA("WedgePart") then
			table.remove(tab,1)
		end

		return tab
	elseif thinAxis == 2 then
		--Y is small, get points on X and Z	
		local tab = {
			part.CFrame * front * right,
			part.CFrame * back * right,
			part.CFrame * back * left,
			part.CFrame * front * left,
		}

		return tab
	elseif thinAxis == 3 then
		--Z is small, get points on X and Y	
		local tab = {
			part.CFrame * up * right,
			part.CFrame * down * right,
			part.CFrame * down * left,
			part.CFrame * up * left,
		}

		return tab
	end
	
end

function getShatterPoint(part,impactPosition)
	local function shouldReverseDirection(dir,depth)
		local rev = dir * -1
		
		local checkNormal = CFrame.new(impactPosition,impactPosition+dir).p
		local checkReversed = CFrame.new(impactPosition,impactPosition+rev).p
		
		local difNormal = checkNormal - part.CFrame.p
		local difReversed = checkReversed - part.CFrame.p
		
		local distNormal = (difNormal.X^2) + (difNormal.Y^2) + (difNormal.Z^2)
		local distReversed = (difReversed.X^2) + (difReversed.Y^2) + (difReversed.Z^2)
		
		if distNormal < distReversed then
			return false
		else
			return true
		end
	end

	local thinAxis,depth = getThinAxis(part)
	
	local direction
	if thinAxis == 1 then direction = part.CFrame.rightVector end
	if thinAxis == 2 then direction = part.CFrame.upVector end
	if thinAxis == 3 then direction = part.CFrame.lookVector end
	
	if shouldReverseDirection(direction,depth) then direction = direction * -1 end
	
	local pointing = CFrame.new(impactPosition,impactPosition + direction)
	local cf = pointing * CFrame.new(0,0,-depth/2)
	

	
	return cf.p,direction
end

function shatter(part,impactPosition,force)
	local origcf=part.CFrame
	local size=math.min(part.Size.X,part.Size.Y,part.Size.Z)
	local ind
	if size==part.Size.X then
		ind="x"
	elseif size==part.Size.Y then
		ind="y"
	elseif size==part.Size.Z then
		ind="z"
	end
	if ind=="x" then
		part.Size=Vector3.new(0.05,part.Size.Y,part.Size.Z)
	elseif ind=="y" then
		part.Size=Vector3.new(part.Size.X,0.05,part.Size.Z)
	elseif ind=="z" then
		part.Size=Vector3.new(part.Size.X,part.Size.Y,0.05)
	end
	part.CFrame=origcf
	local verts = getPoints(part)	
	local shatterPoint,direction = getShatterPoint(part,impactPosition)
	
	local template = Instance.new("WedgePart")
	template.Transparency = part.Transparency
	template.TopSurface = Enum.SurfaceType.Smooth
	template.BottomSurface = Enum.SurfaceType.Smooth
	template.BrickColor = part.BrickColor
	local canShatter = Instance.new("BoolValue")
	canShatter.Name = "canShatter"
	canShatter.Parent = template
	
	local thin,partDepth = getThinAxis(part)
	
	
	local tris = {}
	if #verts == 4 then
		tris = {
			{verts[1],verts[2],shatterPoint},
			{verts[2],verts[3],shatterPoint},
			{verts[3],verts[4],shatterPoint},
			{verts[4],verts[1],shatterPoint}
		}
	else
		tris = {
			{verts[1],verts[2],shatterPoint},
			{verts[2],verts[3],shatterPoint},
			{verts[3],verts[1],shatterPoint},
		}
	end
	
	local triParts = {}
	
	for i = 1,#tris do
		local t = createTriangle(
			tris[i][1].p,
			tris[i][2].p,
			tris[i][3],
			template,
			partDepth
		)
		table.insert(triParts,t)
	end
	
	local par = game.Workspace["Ray_Ignore"]
	for i = 1,#triParts do
		for p = 1,#triParts[i] do
			local prt = triParts[i][p]
			prt.Parent = par
			prt.CollisionGroupId=4
			addvelocitytobb(prt,force+Vector3.new(math.random(-5,5),math.random(-5,5),math.random(-5,5)))
			prt.Transparency=part.Transparency
			prt.Reflectance=part.Reflectance
			prt.Material=Enum.Material.Glass
			prt.CanCollide=true
			delay(1,function()
			prt:Destroy()
			end)
		end
	end
	part:Destroy()	
end



-----so much shit for glass shattering holy moly aaaaaaaaa




getGrenade = function(part, whereto, min, max, networkowner,grenade,primary,secondary,player)	
	if part ~= nil then
		local defaultgun="Glock"
		if player and player:FindFirstChild("Status") and player.Status.Team.Value=="CT" then
			defaultgun="P2000"
		end
		if secondary and secondary~="" then
			defaultgun=secondary
		end
		if primary and primary~="" then
			defaultgun=primary
		end
		part.Explode.Disabled=false
		if part.Explode:FindFirstChild("gun") then
			part.Explode.gun.Value=defaultgun
		end
		part.Explode.creator.Value=networkowner
		local p = Instance.new("Part")
			
			
			p.Shape = "Ball"
			p.Size = Vector3.new(0.6, 0.6, 0.6)
			if part and part:FindFirstChild("ball") then
				p.Size=Vector3.new(0.6,0.6,0.6)
			end
			p.Transparency = 1
			
			--p.Material = Enum.Material.Fabric
			--[[local bg = Instance.new("BodyGyro", p)
			bg.maxTorque = Vector3.new(math.huge, math.huge, math.huge)
			bg.D = 500
			bg.P = 10000]]
			local bf = Instance.new("BodyForce", p)
			bf.force = Vector3.new(0, (game.Workspace.Gravity-196)/2, 0) * p:GetMass()
			local bf2 = Instance.new("BodyForce", part)
			bf2.force = Vector3.new(0, game.Workspace.Gravity/1.35, 0) * part:GetMass()
			local bsc = Instance.new("BallSocketConstraint", p)
			local a0 = Instance.new("Attachment", p)
			local a1 = Instance.new("Attachment", part)
			bsc.Attachment0 = a0
			bsc.Attachment1 = a1
			--[[local w=Instance.new("Weld")
			w.Parent=p
			w.Part0=p
			w.Part1=part]]
			local a = 0
			local b = 100
			local c = 2--0.1
			local d = 1
			local elasticity=0.75
			p.CustomPhysicalProperties = PhysicalProperties.new(1,a,elasticity,b,c)
			--part.CustomPhysicalProperties = PhysicalProperties.new(1,a,1,b,c)
			local bob=part:GetDescendants()
			for i=1,#bob do
				local shats=bob[i]
				if bob[i]:IsA("BasePart") then
					--[[local bf2 = Instance.new("BodyForce", shats)
					bf2.force = Vector3.new(0, shats:GetMass(), 0) * game.Workspace.Gravity]]
					bob[i].CollisionGroupId=6
					bob[i].CanCollide=false
				end
			end	
			p.CollisionGroupId=6
			part.CollisionGroupId=6
			if player.Status.Team.Value=="CT" then
				p.CollisionGroupId=9
				part.CollisionGroupId=9
			end
			part.Explode.creator.Start.Value=whereto.p
			p.CFrame = whereto
			part.CFrame = p.CFrame
			--part.RotVelocity = Vector3.new(math.random(min, max), math.random(min, max),math.random(min, max))
			part.CanCollide=false
			p.CanCollide=false
			p.Parent=part
			part.Parent = game.Workspace.Debris
			part:SetNetworkOwner(nil)
			p:SetNetworkOwner(nil)
			local bob=part:GetDescendants()
			for i=1,#bob do
				if bob[i]:IsA("BasePart") then
					bob[i]:SetNetworkOwner(nil)
				end
			end			
			p.CanCollide=true
			local HitPlayers={}
			if part:FindFirstChild("ground") then
				if player then
					if game.ReplicatedStorage.gametype.Value=="TTT" then
						if player and player.Character and player.Character:FindFirstChild("RDMProtection") then
							player.Character.RDMProtection:Destroy()
							delay(4,function()
								if player:FindFirstChild("RDM")==nil and player.Status.Role.Value~="Traitor" then
									local part = Instance.new("IntValue")
									part.Parent = player.Character
									part.Name = "RDMProtection"						
								end
							end)
						end
					end
				end				
			end
			p.Touched:connect(function(hit)
				
				local Hit=hit
				local Pos=p.Position
					if p.Velocity.magnitude>=10 then
						local SHUCKY=nil
						if hit and hit.Parent and hit.Parent:FindFirstChild("Humanoid") then
							SHUCKY=hit.Parent.Humanoid
						end
						if hit and hit.Parent and hit.Parent.Parent and hit.Parent.Parent:FindFirstChild("Humanoid") then
							SHUCKY=hit.Parent.Parent.Humanoid
						end
						if SHUCKY and SHUCKY.Parent and not HitPlayers[SHUCKY.Parent] and game.Players:GetPlayerFromCharacter(SHUCKY.Parent) and game.Players:GetPlayerFromCharacter(SHUCKY.Parent).Status.Team.Value~=player.Status.Team.Value then
							p.Velocity = Vector3.new(p.Velocity.X / 200, p.Velocity.Y, p.Velocity.Z / 200)
							if hit.Parent.Humanoid:FindFirstChild("creator") then
								hit.Parent.Humanoid.creator:Destroy()
							end
							HitPlayers[SHUCKY.Parent]=true
							local c = Instance.new("ObjectValue")
							c.Name = "creator"
							c.Value = player
							delay(1,function()
								c:Destroy()
							end)
							c.Parent = hit.Parent.Humanoid
							local piece=Instance.new("StringValue")
							piece.Parent=c
							piece.Name="NameTag"
							piece.Value=grenade
							local dmg=2
							if grenade=="HE Grenade" then
								dmg=4
							end
							dmgmodule.takeDamage(player,hit.Parent.Humanoid,dmg,game.ReplicatedStorage.Weapons[grenade],false,false)
						end
					end
				if Hit and game.Workspace.Map.Regen:FindFirstChild("Glasses") and Hit:IsDescendantOf(game.Workspace.Map.Regen.Glasses) then
					local idiot=game.ReplicatedStorage.Sounds.Glass:clone()
					idiot.Parent=Hit
					idiot.PlaybackSpeed=math.random(80,120)/100
					idiot.PlayOnRemove=true
					idiot:Destroy()	
					if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
						shatter(Hit,Pos,CFrame.new(player.Character.HumanoidRootPart.CFrame.p,Pos).lookVector.unit*p.Velocity.magnitude)
					end
				end
				if part.Anchored==false and hit.CanCollide==true and hit.Anchored==true  or hit:IsDescendantOf(game.Workspace["Ray_Ignore"].Fires) then
					if part and part:FindFirstChild("Bounce1") then
						part["Bounce"..math.random(1,4)]:Play()
					else
						part.Bounce:Play()		
					end
					if hit ~= nil and hit.Transparency<=0 and hit.CanCollide==true then
						p.Velocity = Vector3.new(p.Velocity.X / 2.5, p.Velocity.Y, p.Velocity.Z / 2.5)
						if d <= 3 then
							p.CustomPhysicalProperties = PhysicalProperties.new(1, a, elasticity, b, c)
						end
						a = a + 0.05
						b = b - 20
						c = c - (c/2)
						d = d + 1
						--elast=elast-0.25
					end
					if d>2 then
						if part and part:FindFirstChild("ball") then
						else
							--[[if p.Shape~="Cylinder" then
								p.Shape = "Cylinder"
								p.Size = Vector3.new(0.6, 0.4, 0.4)
								if p:FindFirstChild("Weld") then
									p.Weld:Destroy()
								end
								local w=Instance.new("Weld")
								w.Parent=p
								w.Part0=p
								w.Part1=part
								w.C0=CFrame.Angles(0,math.rad(0),math.rad(90))
							end]]
						end
						--print' over 2 '
					end
					if p.Parent:FindFirstChild("Fart") == nil then
						--print ' fart initialized '
						if part:FindFirstChild("ground") then
							local het,pos=game.Workspace:FindPartOnRayWithWhitelist(Ray.new(p.Position,Vector3.new(0,-1,0)),{game.Workspace.Map.Geometry})
							if het then
								local stinky = Instance.new("StringValue")
								stinky.Name = "Fart"
								stinky.Parent = p.Parent								
							end
						elseif part:FindFirstChild("ground")==nil and d>2 or hit:IsDescendantOf(game.Workspace["Ray_Ignore"].Fires) then
							local stinky = Instance.new("StringValue")
							stinky.Name = "Fart"
							if hit:IsDescendantOf(game.Workspace["Ray_Ignore"].Fires) then
								local nib=Instance.new("IntValue")
								nib.Name="Fast"
								nib.Parent=stinky
							end
							stinky.Parent = p.Parent
						end
					end
				end
			end)
			return p
	end
end

local grenadeRate = {}
local GRENADE_RATE_LIMIT = 0.75
game.ReplicatedStorage.Events.ThrowGrenade.OnServerEvent:connect(function(player,object, whereto, min, max, velocity,primary,secondary)
	if whereto then
		player:Kick("bruh rlly")
		return
	end
	
	-- You're being rate l$m$t$d
	local now = tick()
	local lastSent = grenadeRate[player.UserId] or 0
	if now - lastSent < GRENADE_RATE_LIMIT then return end
	grenadeRate[player.UserId] = now

	if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		if player and player.Character:FindFirstChild("Head") then
			whereto=player.Character.Head.CFrame
		end
		if (whereto.p-(player.Character.HumanoidRootPart.Position)).magnitude>10 then
			return
		end
	end
			local part = object:clone()
	--part.GUI.Enabled=true
			if part:FindFirstChild("Slide") then
				part.Slide.Transparency=1
			end
			if part:FindFirstChild("PinS") then
				part.PinS.Transparency=1
			end
			part.Anchored = false
			part.Velocity=velocity
			local bap=game.ReplicatedStorage.creator:clone()
			bap.Parent=part
			bap.Value=player
			getGrenade(part, whereto, min, max,player,object.Parent.Name,primary,secondary,player)
end)
