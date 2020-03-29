E2Lib.RegisterExtension("jumper",true,"CAP Extra: Adds extra functions for Puddle Jumpers.")

-- Is it a valid Puddle Jumper?
local function isJumperValid(ent)
	return IsValid(ent)==true&&ent:GetClass()=="puddle_jumper"
end

-- Convert bool to number, opposite of bool(any)
local function num(bool)
	return bool==true&&1||0
end

--[[----------------------------------------------------------
Initialise
----------------------------------------------------------]]--
local function isJumperInitialised(ent)
	return num(ent.Inflight==true)
end

__e2setcost(5)
e2function number entity:stargateJumperSetInitialise(number bool)
	if(isJumperValid(this)==false)then return 0 end
	if(bool==1&&isJumperInitialised(this)==0)then
		-- https://github.com/RafaelDeJongh/cap/blob/master/lua/entities/puddle_jumper/server/sv_control.lua#L124
		if(this.AllowActivation)then
			local physObj=this:GetPhysicsObject()
			if(IsValid(physObj)==true)then
				physObj:Wake()
				physObj:EnableMotion(true)
			end
			this.Inflight=true
			this.Pilot=nil
			this:SetWire("Driver",this.Pilot)
			this.Roll=0
			if(this.BulkHead)then
				this:ToggleBulkHead()
			end
			if(!this.Cloaked)then
				this:ToggleRotorwash(true)
			end
			this.health=100
			this.AllowActivation=false
			this.LiftOff=true
			this:EmitSound(this.Sounds.Startup,100,100)
			this.StartPos=this:GetPos()
			this:RemoveAll()
			this:SetNetworkedBool("JumperInflight",true)
			this.PlayerColor=Color(255,255,255,255)
			if(!this.Cloaked)then
				this:SpawnPilot(this:GetPos()+this:GetForward()*47.5+this:GetUp()*-17.5+this:GetRight()*32.5)
			end
		end
		this.Entered=true
		timer.Simple(0.75,function()
			this.AllowActivation=true
			this.LiftOff=false
		end)
		return num(isJumperInitialised(this)==1)
	elseif(bool==0&&isJumperInitialised(this)==1)then
		-- https://github.com/RafaelDeJongh/cap/blob/master/lua/entities/puddle_jumper/server/sv_control.lua#L3
		if(IsValid(this.PilotAvatar)==true)then
			this.PilotAvatar:Remove()
		end
		this:EmitSound(this.Sounds.Shutdown,100,100)
		this:SetNetworkedEntity("jumper",NULL)
		this.HoverPos=this:GetPos()
		this:SetWire("Driver",NULL)
		this:RemoveDrones()
		this.Roll=0
		this.LiftOff=false
		this.Inflight=false
		this.Accel.FWD=0
		this.Accel.RIGHT=0
		this.Accel.UP=0
		this:SetNetworkedBool("JumperInflight",false)
		this:SpawnToggleButton(self.player)
		this:SpawnBulkHeadDoor(nil,self.player)
		this:SpawnBackDoor(nil,self.player)
		if(this.door)then
			this.Door:SetSolid(SOLID_NONE)
		end
		this:SpawnOpenedDoor(self.player)
		this:ToggleRotorwash(false)
		if(this.epodo)then
			this:TogglePods()
		end
		timer.Simple(0.75,function()
			this.AllowActivation=true
		end)
		return num(isJumperInitialised(this)==0)
	end
	return 0
end

__e2setcost(1)
e2function number entity:stargateJumperGetInitialise()
	if(isJumperValid(this)==false)then return 0 end
	return isJumperInitialised(this)
end

--[[----------------------------------------------------------
Shield
----------------------------------------------------------]]--
local function canJumperShield(ent)
	return num(ent.CanShield==true&&ent.NextUse.Shields<CurTime()&&IsValid(ent.Shields)==true)
end

local function isJumperShielded(ent)
	return num(ent.Shields:Enabled()==true)
end

__e2setcost(1)
e2function number entity:stargateJumperSetShield(number bool)
	if(isJumperValid(this)==false)then return 0 end
	if(canJumperShield(this)==0)then return 0 end
	-- https://github.com/RafaelDeJongh/cap/blob/master/lua/entities/puddle_jumper/server/sv_toggles.lua#L13
	if(bool==1&&isJumperShielded(this)==0)then
		this:ToggleShield()
		return num(isJumperShielded(this)==1)
	elseif(bool==0&&isJumperShielded(this)==1)then
		this:ToggleShield()
		return num(isJumperShielded(this)==0)
	end
	return 0
end

__e2setcost(1)
e2function number entity:stargateJumperGetShield()
	if(isJumperValid(this)==false)then return 0 end
	return isJumperShielded(this)
end

__e2setcost(1)
e2function number entity:stargateJumperCanShield()
	if(isJumperValid(this)==false)then return 0 end
	return canJumperShield(this)
end

__e2setcost(1)
e2function number entity:stargateJumperGetShieldStrength()
	if(isJumperValid(this)==false)then return 0 end
	return self.Shields.Strength
end

--[[----------------------------------------------------------
Cloak
----------------------------------------------------------]]--
local function canJumperCloak(ent)
	return num(ent.CanCloak==true&&ent.CanDoCloak==true)
end


local function isJumperCloaked(ent)
	return num(ent.Cloaked==true)
end

__e2setcost(1)
e2function number entity:stargateJumperSetCloak(number bool)
	if(isJumperValid(this)==false)then return 0 end
	if(canJumperCloak(this)==0)then return 0 end
	if(bool==1&&isJumperCloaked(this)==0)then
		this:ToggleCloak()
		return num(isJumperCloaked(this)==1)
	elseif(bool==0&&isJumperCloaked(this)==1)then
		this:ToggleCloak()
		return num(this.AnimCloaked==false) -- We can't use this.Cloaked because it isn't set to false until the animation finishes playing (after 1.75s)
	end
	return 0
end

__e2setcost(1)
e2function number entity:stargateJumperGetCloak()
	if(isJumperValid(this)==false)then return 0 end
	return isJumperCloaked(this)
end

__e2setcost(1)
e2function number entity:stargateJumperCanCloak()
	if(isJumperValid(this)==false)then return 0 end
	return canJumperCloak(this)
end