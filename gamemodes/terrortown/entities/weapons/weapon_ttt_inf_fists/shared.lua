AddCSLuaFile()

if CLIENT then
	SWEP.PrintName = "infected_fists_name"

	SWEP.ViewModelFlip = false
	SWEP.ViewModelFOV = 54
	SWEP.DrawCrosshair = false

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "knife_desc"
	}

	SWEP.Icon = "vgui/ttt/icon_knife"
	SWEP.IconLetter = "j"
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "fist"
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""
SWEP.UseHands = true

SWEP.Primary.Damage = 50
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 12

SWEP.Kind = WEAPON_SPECIAL

SWEP.HitDistance = 64

SWEP.AllowDrop = false
SWEP.IsSilent = true

-- Pull out faster than standard guns
SWEP.DeploySpeed = 2

local swingSound = Sound("WeaponFrag.Throw")
local hitSound = Sound("Flesh.ImpactHard")
local animations = {
	"fists_left",
	"fists_right",
	"fists_uppercut"
}

function SWEP:Initialize()
	self:SetHoldType("fist")
end

function SWEP:Deploy()
	local vm = self.Owner:GetViewModel()

	vm:SendViewModelMatchingSequence(vm:LookupSequence("fists_draw"))
	vm:SetPlaybackRate(self.DeploySpeed)
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	local owner = self.Owner

	if not IsValid(owner) then return end

	-- animation
	owner:SetAnimation(PLAYER_ATTACK1)

	local anim = animations[math.random(1, 3)]

	local vm = owner:GetViewModel()
	vm:SendViewModelMatchingSequence(vm:LookupSequence(anim))

	self:EmitSound(anim)

	self:EmitSound(swingSound)

	owner:LagCompensation(true)

	local spos = owner:GetShootPos()
	local sdest = spos + owner:GetAimVector() * 70

	local kmins = Vector(1, 1, 1) * -10
	local kmaxs = Vector(1, 1, 1) * 10

	local tr = util.TraceHull({
		start = spos,
		endpos = sdest,
		filter = owner,
		mask = MASK_SHOT_HULL,
		mins = kmins,
		maxs = kmaxs
	})

	-- Hull might hit environment stuff that line does not hit
	if not IsValid(tr.Entity) then
		tr = util.TraceLine({
			start = spos,
			endpos = sdest,
			filter = owner,
			mask = MASK_SHOT_HULL
		})
	end

	local hitEnt = tr.Entity

	-- effects
	if IsValid(hitEnt) then
		self:EmitSound(hitSound)

		self:SendWeaponAnim(ACT_VM_HITCENTER)

		local edata = EffectData()
		edata:SetStart(spos)
		edata:SetOrigin(tr.HitPos)
		edata:SetNormal(tr.Normal)
		edata:SetEntity(hitEnt)

		if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
			owner:SetAnimation(PLAYER_ATTACK1)

			self:SendWeaponAnim(ACT_VM_MISSCENTER)

			util.Effect("BloodImpact", edata)
		end
	else
		self:SendWeaponAnim(ACT_VM_MISSCENTER)
	end

	if SERVER then
		owner:SetAnimation(PLAYER_ATTACK1)
	end

	if SERVER and tr.Hit and tr.HitNonWorld and IsValid(hitEnt) and hitEnt:IsPlayer() then
		-- knife damage is never karma'd, so don't need to take that into
		-- account we do want to avoid rounding error strangeness caused by
		-- other damage scaling, causing a death when we don't expect one, so
		-- when the target's health is close to kill-point we just kill
		if hitEnt:Health() < self.Primary.Damage + 10 then
			self:StabKill(tr, spos, sdest)
		else
			local dmg = DamageInfo()
			dmg:SetDamage(self.Primary.Damage)
			dmg:SetAttacker(owner)
			dmg:SetInflictor(self)
			dmg:SetDamageForce(owner:GetAimVector() * 5)
			dmg:SetDamagePosition(owner:GetPos())
			dmg:SetDamageType(DMG_SLASH)

			hitEnt:DispatchTraceAttack(dmg, spos + (owner:GetAimVector() * 3), sdest)
		end
	end

	owner:LagCompensation(false)
end

function SWEP:StabKill(tr, spos, sdest)
	local target = tr.Entity

	local dmg = DamageInfo()
	dmg:SetDamage(2000)
	dmg:SetAttacker(self.Owner)
	dmg:SetInflictor(self)
	dmg:SetDamageForce(self.Owner:GetAimVector())
	dmg:SetDamagePosition(self.Owner:GetPos())
	dmg:SetDamageType(DMG_SLASH)

	-- now that we use a hull trace, our hitpos is guaranteed to be
	-- terrible, so try to make something of it with a separate trace and
	-- hope our effect_fn trace has more luck

	-- first a straight up line trace to see if we aimed nicely
	local retr = util.TraceLine({start = spos, endpos = sdest, filter = self.Owner, mask = MASK_SHOT_HULL})

	-- if that fails, just trace to worldcenter so we have SOMETHING
	if retr.Entity ~= target then
		local center = target:LocalToWorld(target:OBBCenter())

		retr = util.TraceLine({start = spos, endpos = center, filter = self.Owner, mask = MASK_SHOT_HULL})
	end

	-- create knife effect creation fn
	local bone = retr.PhysicsBone
	local pos = retr.HitPos
	local norm = tr.Normal

	local ang = Angle(-28, 0, 0) + norm:Angle()
	ang:RotateAroundAxis(ang:Right(), -90)

	pos = pos - (ang:Forward() * 7)

	local ignore = self.Owner

	target.effect_fn = function(rag)
		if not rag then return end

		-- we might find a better location
		local rtr = util.TraceLine({
			start = pos,
			endpos = pos + norm * 40,
			filter = ignore,
			mask = MASK_SHOT_HULL
		})

		if IsValid(rtr.Entity) and rtr.Entity == rag then
			bone = rtr.PhysicsBone
			pos = rtr.HitPos

			ang = Angle(-28, 0, 0) + rtr.Normal:Angle()
			ang:RotateAroundAxis(ang:Right(), -90)

			pos = pos - ang:Forward() * 10
		end

		local knife = ents.Create("prop_physics")
		--knife:SetModel("models/weapons/w_knife_t.mdl")
		knife:SetPos(pos)
		knife:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		knife:SetAngles(ang)

		knife.CanPickup = false

		knife:Spawn()

		local phys = knife:GetPhysicsObject()

		if IsValid(phys) then
			phys:EnableCollisions(false)
		end

		constraint.Weld(rag, knife, bone, 0, 0, true)

		-- need to close over knife in order to keep a valid ref to it
		rag:CallOnRemove("ttt_knife_cleanup", function()
			if IsValid(knife) then
				SafeRemoveEntity(knife)
			end
		end)
	end

	-- seems the spos and sdest are purely for effects/forces?
	target:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)

	-- target appears to die right there, so we could theoretically get to
	-- the ragdoll in here...
end

function SWEP:OnDrop()
	self:Remove()
end
