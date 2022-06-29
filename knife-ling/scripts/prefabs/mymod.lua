 local assets=
{
	Asset("ANIM", "anim/mymod.zip"),
	Asset("ANIM", "anim/swap_mymod.zip"),
	Asset("ATLAS", "images/mymod.xml"),
	Asset("IMAGE", "images/mymod.tex"),
	Asset("ANIM", "anim/ui_backpack_2x4.zip"),
}
local function sword_do_trail(inst)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    if not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor:GetRunSpeed() * .1
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end
    local mounted = owner.components.rider ~= nil and owner.components.rider:IsRiding()
    local map = TheWorld.Map
    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        (mounted and 1 or .5) + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:IsPassableAtPoint(pt:Get())
                and not map:IsPointNearHole(pt)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, { "shadowtrail" }) <= 0
        end
    )

    if offset ~= nil then
        SpawnPrefab("cane_ancient_fx").Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

local function sword_equipped(inst)
    if inst._trailtask == nil then
        inst._trailtask = inst:DoPeriodicTask(6 * FRAMES, sword_do_trail, 2 * FRAMES)
    end
end

local function sword_unequipped(inst)
    if inst._trailtask ~= nil then
        inst._trailtask:Cancel()
        inst._trailtask = nil
    end
end

local function lighton(inst, owner)
    if inst._light == nil or not inst._light:IsValid() then
        inst._light = SpawnPrefab("mymod_light")
    end
    if owner ~= nil then
        inst._light.entity:SetParent(owner.entity)
    end
	
end


local function lightoff(inst)
    if inst._light ~= nil then
            if inst._light:IsValid() then
                inst._light:Remove()
            end
            inst._light = nil
        end
end  

local function OnEquip(inst, owner)
  owner.AnimState:OverrideSymbol("swap_object", "swap_mymod", "symbol0")
  owner.AnimState:Show("ARM_carry")
  owner.AnimState:Hide("ARM_normal")
  lighton(inst, owner)
	if "false"=="true" then
	   inst.components.container:Open(owner)
	end
	if "false"=="true" then
	   	if ""=="cane_ancient_fx" then
			sword_equipped(inst)
		else
			if inst._vfx_fx_inst == nil then
				inst._vfx_fx_inst = SpawnPrefab("cane_victorian_fx")
				inst._vfx_fx_inst.entity:AddFollower()
			end
			inst._vfx_fx_inst.entity:SetParent(owner.entity)
			inst._vfx_fx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 0, inst.vfx_fx_offset or 0, 0)
		end
	end
end
  
local function OnUnequip(inst, owner)
  owner.AnimState:Hide("ARM_carry")
  owner.AnimState:Show("ARM_normal")
  lightoff(inst, owner)
  	if "false"=="true" then
	   inst.components.container:Close(owner)
	end
	if "false"=="true" then
		if ""=="cane_ancient_fx" then
	   	   sword_unequipped(inst)
		else
			if inst._vfx_fx_inst ~= nil then
				inst._vfx_fx_inst:Remove()
				inst._vfx_fx_inst = nil
			end
		end
	end
end
local function mymod_lightfn()
    local inst = CreateEntity()	

    inst.entity:AddTransform()	
    inst.entity:AddLight()		
    inst.entity:AddNetwork()	

    inst:AddTag("FX")	

	inst.Light:SetIntensity(0.5)	
	inst.Light:SetRadius(1)		
	inst.Light:Enable(true)		
	inst.Light:SetFalloff(1)	
	inst.Light:SetColour(200/255, 200/255, 200/255)	

    inst.entity:SetPristine()	

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false	

    return inst
end
local function fn()

  local inst = CreateEntity()
  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddLight()	
  inst.entity:AddNetwork()
  inst.entity:AddMiniMapEntity()
  MakeInventoryPhysics(inst)
  inst.Light:SetIntensity(0.5)	
  inst.Light:SetRadius(1)		
  inst.Light:Enable(true)		
  inst.Light:SetFalloff(1)	
  inst.Light:SetColour(200/255, 200/255, 200/255)		
  inst.AnimState:SetBank("mymod")
  inst.AnimState:SetBuild("mymod")
  inst.AnimState:PlayAnimation("idle")
  inst.MiniMapEntity:SetIcon("mymod.tex")
  inst:AddTag("sharp")
  inst.entity:SetPristine()
  if not TheWorld.ismastersim then
		if "false"=="true" then
			if inst.replica and inst.replica.container then
				inst.replica.container:WidgetSetup("backpack")
			end
		end
		return inst
  end
  
  inst:AddComponent("inspectable")
  inst:AddComponent("inventoryitem")

  inst.components.inventoryitem.imagename = "mymod"
  inst.components.inventoryitem.atlasname = "images/mymod.xml"
  inst:AddComponent("equippable")
  inst.components.equippable:SetOnEquip( OnEquip )
  inst.components.equippable:SetOnUnequip( OnUnequip )
  if "false"=="true" then
	  inst:AddComponent("container")
      inst.components.container:WidgetSetup("backpack")
  end
  return inst
end
  
return  Prefab("common/inventory/mymod", fn, assets),
		Prefab("mymod_light", mymod_lightfn)