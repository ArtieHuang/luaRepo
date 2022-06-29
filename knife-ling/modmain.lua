PrefabFiles = {

	"mymod",
}

Assets = {
	Asset( "ATLAS", "images/mymod.xml" ),
	Asset("IMAGE", "images/mymod.tex"), 
	Asset("ANIM", "anim/mymod.zip"),
	Asset("ANIM", "anim/swap_mymod.zip"),
}

local RECIPETABS = GLOBAL.RECIPETABS
local Recipe = GLOBAL.Recipe
local Ingredient = GLOBAL.Ingredient
local TECH = GLOBAL.TECH
local TheWorld = GLOBAL.TheWorld
local ACTIONS=GLOBAL.ACTIONS
local FUELTYPE=GLOBAL.FUELTYPE
local SpawnPrefab=GLOBAL.SpawnPrefab
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS



 AddPrefabPostInit("mymod",function(inst)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(40)
    inst.components.weapon:SetRange(1.1,1.1)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)  
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.CHOP, 1)
    inst.components.tool:SetAction(ACTIONS.MINE, 1)
    if inst.components.equippable then inst.components.equippable.walkspeedmult =1.25 end
	local function onattack(inst, attacker, target)
		if attacker then
			--if  target.components.freezable then
			--	if  target ~= nil and target.components.freezable ~= nil then
			--		target.components.freezable:AddColdness(1)
			--	end
			--end
		end
	if attacker then
	    if attacker.components.health then
		    attacker.components.health:DoDelta(1)
		end
	end
	if attacker then
	    if attacker.components.sanity then
		    attacker.components.sanity:DoDelta(0)
		end
	end
		inst.mater=inst.mater+0.01
    end
    inst.components.weapon:SetOnAttack(onattack)
end)



AddRecipe("mymod", {Ingredient("goldnugget", 10),Ingredient("purplegem", 1),Ingredient("livinglog", 5)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, nil, nil, nil, nil, nil, "images/mymod.xml", "mymod.tex" )
STRINGS.NAMES.MYMOD="灵刃"
STRINGS.CHARACTERS.GENERIC.MYMOD ="灵刃"
STRINGS.RECIPE_MYMOD= "灵刃"
STRINGS.RECIPE_DESC.MYMOD= "斩断一切！"

local function OnGetItemFromPlayer(inst, giver, item, player)
    inst.components.weapon:SetDamage(50+inst.mater*1)
	local currentperc = inst.components.finiteuses:GetPercent()
	if item  then
		if  item.prefab == "reviver" then
			if inst.mater<50000 then
				inst.mater = inst.mater+1
				inst.components.weapon:SetDamage(40+inst.mater*1)
				giver.components.talker:Say("等级:"..inst.mater)
			else
				giver.components.talker:Say("已满级!")
			end
		end
		if item.prefab == "flint" then
			currentperc=currentperc +0.1
		end
		
	end
	if inst.mater >= 2000 then
	     inst.components.finiteuses:SetMaxUses(10000000000000000000000000000000)
	end
	if inst.mater >= 100  then
		inst.components.weapon:SetRange(inst.mater/100+1,inst.mater/100+1)
		inst.components.tool:SetAction(ACTIONS.CHOP, inst.mater/100+1)
		inst.components.tool:SetAction(ACTIONS.MINE, inst.mater/100)
	end

	if currentperc>=1 then
		currentperc=1
	end
	inst.components.finiteuses:SetPercent(currentperc)
end

local function onpreload(inst, data)
	if data then
		if data.mater then
			inst.mater = data.mater
		end
		OnGetItemFromPlayer(inst)
	end
end

local function onsave(inst, data)
	data.mater = inst.mater
end	

local function OnRefuseItem(inst, giver, item)
	if item then
		giver.components.talker:Say("等级:"..inst.mater)
	end
end

local function AcceptTest(inst, item)
    return item.prefab == "greengem" or item.prefab == "yellowgem" or item.prefab == "orangegem" or 
	item.prefab == "thulecite" or item.prefab == "thulecite_pieces" or item.prefab == "bluegem"
	or item.prefab == "purplegem" or item.prefab == "redgem" or item.prefab == "reviver"or item.prefab == "flint"
end

AddPrefabPostInit("mymod",function(inst)
	inst.mater=0
	inst.components.weapon:SetDamage(40)
    inst:ListenForEvent("equipped",OnGetItemFromPlayer)
	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(AcceptTest)
	inst.components.trader.onaccept = OnGetItemFromPlayer
	inst.components.trader.onrefuse = OnRefuseItem
	inst.OnSave = onsave
	inst.OnPreLoad = onpreload
end)
AddPrefabPostInit("reviver",function(inst)
	if not inst.components.tradable then
		inst:AddComponent("tradable")
    end
end)
AddPrefabPostInit("flint",function(inst)
	if not inst.components.tradable then
		inst:AddComponent("tradable")
    end
end)	
