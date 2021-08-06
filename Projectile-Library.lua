local Projectile = {}

local function computeLaunchAngle(horizontalDistance, distanceY, intialSpeed, g)
	local distanceTimesG = g*horizontalDistance
	local initialSpeedSquared = intialSpeed^2
	
	local inRoot = initialSpeedSquared^2 - (g*((distanceTimesG*horizontalDistance)+(2*distanceY*initialSpeedSquared)))
	if inRoot <= 0 then
		return false, 0.25 * math.pi
	end
	local root = math.sqrt(inRoot)
	local inATan1 = (initialSpeedSquared - root) / distanceTimesG
	local inATan2 = (initialSpeedSquared + root) / distanceTimesG
	local answerAngle1 = math.atan(inATan1)
	local answerAngle2 = math.atan(inATan2)
	if answerAngle1 < answerAngle2 then
		return true, answerAngle1
	else
		return true, answerAngle2
	end
end

function Projectile.ComputeLaunchVelocity(distanceVector, initialSpeed, g, allowOutOfRange)
	local horizontalDistanceVector = Vector3.new(distanceVector.X, 0, distanceVector.Z)
	local horizontalDistance = horizontalDistanceVector.Magnitude
	
	local isInRange, launchAngle = computeLaunchAngle(horizontalDistance, distanceVector.Y, initialSpeed, g)
	if not isInRange and not allowOutOfRange then return end
	
	local horizontaldirectionUnit = horizontalDistanceVector.Unit
	local vy = math.sin(launchAngle)
	local xz = math.cos(launchAngle)
	local vx = horizontaldirectionUnit.X * xz
	local vz = horizontaldirectionUnit.Z * xz

	return Vector3.new(vx*initialSpeed, vy*initialSpeed, vz*initialSpeed)
end

function Projectile.ComputeLaunchVelocityBeam(distanceVector, initialSpeed, g, allowOutOfRange)
	local distanceY = distanceVector.Y
	local horizontalDistanceVector = Vector3.new(distanceVector.X, 0, distanceVector.Z)
	local horizontalDistance = horizontalDistanceVector.Magnitude
	
	local isInRange, launchAngle = computeLaunchAngle(horizontalDistance, distanceY, initialSpeed, g)
	if not isInRange and not allowOutOfRange then return end
	
	local horizontaldirectionUnit = horizontalDistanceVector.Unit
	local vy = math.sin(launchAngle)
	local xz = math.cos(launchAngle)
	local vx = horizontaldirectionUnit.X * xz
	local vz = horizontaldirectionUnit.Z * xz
	
	local v0sin = vy * initialSpeed
	local horizontalRangeHalf = ((initialSpeed^2)/g * (math.sin(2*launchAngle)))/2
	
	local flightTime
	if horizontalRangeHalf <= horizontalDistance then
		flightTime = ((v0sin+(math.sqrt(v0sin^2+(2*-g*((distanceY))))))/g)
	else          
		flightTime = ((v0sin-(math.sqrt(v0sin^2+(2*-g*((distanceY))))))/g)
	end
	
	return Vector3.new(vx*initialSpeed, vy*initialSpeed, vz*initialSpeed), flightTime
end

function Projectile.BeamProjectile(v0, x0, t1, g)
	local g = Vector3.new(0, -g, 0)
    local c = 0.5*0.5*0.5
    local p3 = 0.5*g*t1*t1 + v0*t1 + x0
    local p2 = p3 - (g*t1*t1 + v0*t1)/3
    local p1 = (c*g*t1*t1 + 0.5*v0*t1 + x0 - c*(x0+p3))/(3*c) - p2
 
    local curve0 = (p1 - x0).magnitude
    local curve1 = (p2 - p3).magnitude
 
    local b = (x0 - p3).unit
    local r1 = (p1 - x0).unit
    local u1 = r1:Cross(b).unit
    local r2 = (p2 - p3).unit
    local u2 = r2:Cross(b).unit
    b = u1:Cross(r1).unit
 
    local cf0 = CFrame.new(
        (x0.x), (x0.y), (x0.z),
        r1.x, u1.x, b.x,
        r1.y, u1.y, b.y,
        r1.z, u1.z, b.z)
 
    local cf1 = CFrame.new(
        (p3.x), (p3.y), (p3.z),
        r2.x, u2.x, b.x,
        r2.y, u2.y, b.y,
        r2.z, u2.z, b.z)
 
	return curve0, -curve1, cf0, cf1
end

return Projectile
