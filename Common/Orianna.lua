--[[ TODO:
-Laneclear/JungleClear/Lasthit
-Ult Flash Combo
]]

if GetObjectName(myHero) ~= "Orianna" then return end

require('Deftlib')

local Ball = myHero
	
local OriannaMenu = MenuConfig("Orianna", "Orianna")
OriannaMenu:Menu("Combo", "Combo")
OriannaMenu.Combo:Boolean("Q", "Use Q", true)
OriannaMenu.Combo:Boolean("W", "Use W", true)
OriannaMenu.Combo:Boolean("E", "Use E", true)
OriannaMenu.Combo:Menu("R", "Use R")
OriannaMenu.Combo.R:Boolean("REnabled", "Enabled", true)
OriannaMenu.Combo.R:Boolean("Rkill", "if Can Kill", true)
OriannaMenu.Combo.R:Slider("Rcatch", "if can catch X enemies", 2, 0, 5, 1)
--OriannaMenu.Combo.R:Key("FlashR", "R Flash Combo", string.byte("G"))
--OriannaMenu.Combo.R:Slider("FlashRcatch", "if can catch X enemies", 3, 0, 5, 1)

OriannaMenu:Menu("Harass", "Harass")
OriannaMenu.Harass:Boolean("Q", "Use Q", true)
OriannaMenu.Harass:Boolean("W", "Use W", true)
OriannaMenu.Harass:Boolean("E", "Use E", false)
OriannaMenu.Harass:Slider("Mana", "if Mana % is More than", 30, 0, 80, 1)

OriannaMenu:Menu("Killsteal", "Killsteal")
OriannaMenu.Killsteal:Boolean("Q", "Killsteal with Q", false)
OriannaMenu.Killsteal:Boolean("W", "Killsteal with W", true)
OriannaMenu.Killsteal:Boolean("E", "Killsteal with E", false)

OriannaMenu:Menu("Misc", "Misc")
if Ignite ~= nil then OriannaMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true) end
OriannaMenu.Misc:Boolean("Autolvl", "Auto level", true)
OriannaMenu.Misc:DropDown("Autolvltable", "Priority", 1, {"Q-W-E", "W-Q-E", "Q-E-W"})
OriannaMenu.Misc:Boolean("Interrupt", "Interrupt Dangerous Spells (R)", true)
OriannaMenu.Misc:Menu("AutoUlt", "Auto Ult")
OriannaMenu.Misc.AutoUlt:Boolean("Enabled", "Enabled", true)
OriannaMenu.Misc.AutoUlt:Slider("catchable", "if Can Catch X Enemies", 3, 0, 5, 1)
OriannaMenu.Misc.AutoUlt:Slider("killable", "if Can Kill X Enemies", 2, 0, 5, 1)

OriannaMenu:Menu("JungleClear", "JungleClear")
OriannaMenu.JungleClear:Boolean("Q", "Use Q", true)
OriannaMenu.JungleClear:Boolean("W", "Use W", true)
OriannaMenu.JungleClear:Boolean("E", "Use E", true)

OriannaMenu:Menu("LaneClear", "LaneClear")
OriannaMenu.LaneClear:Boolean("Q", "Use Q", true)
OriannaMenu.LaneClear:Boolean("W", "Use W", true)

OriannaMenu:Menu("Drawings", "Drawings")
OriannaMenu.Drawings:Boolean("Q", "Draw Q Range", true)
OriannaMenu.Drawings:Boolean("W", "Draw W Radius", true)
OriannaMenu.Drawings:Boolean("E", "Draw E Range", true)
OriannaMenu.Drawings:Boolean("R", "Draw R Radius", true)
OriannaMenu.Drawings:Boolean("Ball", "Draw Ball Position", true)

OnDraw(function(myHero)
if OriannaMenu.Drawings.Ball:Value() then DrawCircle(GetOrigin(Ball),150,1,128,0xffffffff) end
if OriannaMenu.Drawings.W:Value() then DrawCircle(GetOrigin(Ball),250,1,128,0xffffffff) end
if OriannaMenu.Drawings.R:Value() then DrawCircle(GetOrigin(Ball),400,1,128,0xffffffff) end
if OriannaMenu.Drawings.Q:Value() then DrawCircle(GoS:myHeroPos(),825,1,128,0xff00ff00) end
if OriannaMenu.Drawings.E:Value() then DrawCircle(GoS:myHeroPos(),1000,1,128,0xff00ff00) end
end)

OnTick(function(myHero)
	
     if IOW:Mode() == "Combo" then
	    
        local target = GetCurrentTarget()

	if IsReady(_R) and OriannaMenu.Combo.R.REnabled:Value() then
	  if GoS:EnemiesAround(GetOrigin(Ball), 400) >= OriannaMenu.Combo.R.Rcatch:Value() then
	  CastSpell(_R)
	  end
	end
	
	if IsReady(_R) then
	  if IsReady(_Q) and OriannaMenu.Combo.Q:Value() and GoS:EnemiesAround(GoS:myHeroPos(), 825) < 2 and GoS:ValidTarget(target, 825) then
          Cast(_Q,target,Ball)   
	  end
	elseif CanUseSpell(myHero, _R) ~= READY then
          if IsReady(_Q) and OriannaMenu.Combo.Q:Value() and GoS:ValidTarget(target, 825) then
          Cast(_Q,target,Ball)
	  end
	end
		
	if IsReady(_W) and OriannaMenu.Combo.W:Value() and GoS:ValidTarget(target, 1200) and GoS:GetDistance(Ball, target) <= 250 then
	CastSpell(_W)
        end

        if Ball ~= myHero and IsReady(_E) and GoS:ValidTarget(target, 1000) and OriannaMenu.Combo.E:Value() then
          local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(GoS:myHeroPos(), GetOrigin(target), Vector(Ball))
          if pointLine and GoS:GetDistance(pointSegment, target) < 80 then
          CastTargetSpell(myHero, _E)
          end
        end	
     end
	
     if IOW:Mode() == "Harass" and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= OriannaMenu.Harass.Mana:Value() then
	
        local target = GetCurrentTarget()

	if IsReady(_Q) and OriannaMenu.Harass.Q:Value() and GoS:EnemiesAround(GoS:myHeroPos(), 825) < 2 and GoS:ValidTarget(target, 825) then
        Cast(_Q,target,Ball)   
	end
	
	if IsReady(_W) and OriannaMenu.Harass.W:Value() and GoS:ValidTarget(target, 825) and GoS:GetDistance(Ball, target) <= 250 then
	 CastSpell(_W)
         end

        if Ball ~= myHero and IsReady(_E) and GoS:ValidTarget(target, 1000) and OriannaMenu.Harass.E:Value() then
          local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(GoS:myHeroPos(), GetOrigin(target), Vector(Ball))
          if pointLine and GoS:GetDistance(pointSegment, target) <= 80 then
          CastTargetSpell(myHero, _E)
          end
        end	
     end
    
	local KillableEnemies = 0
	
        for i,enemy in pairs(GoS:GetEnemyHeroes()) do
		
	    if Ignite and OriannaMenu.Misc.AutoIgnite:Value() then
              if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2.5 and GoS:ValidTarget(enemy, 600) then
              CastTargetSpell(enemy, Ignite)
              end
            end
						
  	    if IOW:Mode() == "Combo" and GoS:ValidTarget(enemy, 1200) and OriannaMenu.Combo.R.Rkill:Value() and GoS:GetDistance(Ball, enemy) < 400 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 75*GetCastLevel(myHero, _R)+75+0.7*GetBonusAP(myHero) + Ludens()) then 
            CastSpell(_R)
            end
		
	    if IsReady(_R) and OriannaMenu.Misc.AutoUlt.Enabled:Value() then
              if GoS:ValidTarget(enemy, 1200) and GoS:GetDistance(Ball, enemy) <= 400 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 75*GetCastLevel(myHero, _R)+75+0.7*GetBonusAP(myHero) + Ludens()) then 
              KillableEnemies = KillableEnemies + 1
              end
		  
	      if KillableEnemies >= OriannaMenu.Misc.AutoUlt.killable:Value() then
	      CastSpell(_R)
	      end
	    end
		
	    if IsReady(_W) and OriannaMenu.Killsteal.W:Value() and GoS:ValidTarget(enemy, 1200) and GoS:GetDistance(Ball, enemy) <= 250 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 45*GetCastLevel(myHero,_W)+25+0.7*GetBonusAP(myHero) + Ludens()) then
	    CastSpell(_W)
	    elseif IsReady(_Q) and GoS:ValidTarget(enemy, 825) and OriannaMenu.Killsteal.Q:Value() and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 30*GetCastLevel(myHero, _Q)+30+0.5*GetBonusAP(myHero) + Ludens()) then 
            Cast(_Q,enemy,Ball)
            elseif Ball ~= myHero and IsReady(_E) and GoS:ValidTarget(enemy, 1000) and OriannaMenu.Killsteal.E:Value() then
              local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(GoS:myHeroPos(), GetOrigin(enemy), Vector(Ball))
              if pointLine and GoS:GetDistance(pointSegment, enemy) <= 80 and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 30*GetCastLevel(myHero, _R)+30+0.3*GetBonusAP(myHero) + Ludens()) then
              CastTargetSpell(myHero, _E)
              end 
	    end
		
		local QThrowPos = GetMEC(400,GoS:GetEnemyHeroes()) 
		if IOW:Mode() == "Combo" and GoS:EnemiesAround(GoS:myHeroPos(), 825) >= 2 and GoS:ValidTarget(enemy, 825) and IsReady(_R) and OriannaMenu.Combo.Q:Value() then 
                CastSkillShot(_Q, QThrowPos.x, QThrowPos.y, QThrowPos.z)
                end
		
	end
	
	if IsReady(_R) and OriannaMenu.Misc.AutoUlt.Enabled:Value() then
	  if GoS:EnemiesAround(GetOrigin(Ball), 400) >= OriannaMenu.Misc.AutoUlt.catchable:Value() then
	  CastSpell(_R)
	  end
	end
	
        for _,mob in pairs(GoS:GetAllMinions(MINION_JUNGLE)) do
		
            if IOW:Mode() == "LaneClear" then
	    
		if IsReady(_W) and OriannaMenu.JungleClear.W:Value() and GoS:ValidTarget(mob, 1200) and GoS:GetDistance(Ball, mob) <= 250 then
		CastSpell(_W)
		end
		
		if IsReady(_Q) and OriannaMenu.JungleClear.Q:Value() and GoS:ValidTarget(mob, 825) then
		CastSkillShot(_Q, GetOrigin(mob).x, GetOrigin(mob).y, GetOrigin(mob).z) 
		end
		
		if Ball ~= myHero and IsReady(_E) and OriannaMenu.JungleClear.E:Value() and GoS:ValidTarget(mob, 1000) then
		  local pointSegment,pointLine,isOnSegment  = VectorPointProjectionOnLineSegment(GoS:myHeroPos(), GetOrigin(mob), Vector(Ball))
                  if pointLine and GoS:GetDistance(pointSegment, mob) <= 80 then
		  CastTargetSpell(myHero, _E)
		  end
		end
            end
	  
        end
	
if OriannaMenu.Misc.Autolvl:Value() then  
    if OriannaMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    elseif OriannaMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_Q, _W, _E, _W, _W, _R, _W, _Q, _W, _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
    elseif OriannaMenu.Misc.Autolvltable:Value() == 3 then leveltable = {_Q, _W, _E, _Q, _Q, _R, _Q, _E, _Q, _E, _R, _E, _E, _W, _W, _R, _W, _W}
    end
GoS:DelayAction(function() LevelSpell(leveltable[GetLevel(myHero)]) end, math.random(1000,3000))
end

end)

OnProcessSpell(function(unit, spell)
  if unit == myHero and spell.name:lower():find("orianaredactcommand") then 
  Ball = spell.target
  end
end)

OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "Orianna_Base_Q_yomu_ring_green.troy" then
  Ball = Object
  end
end)

OnUpdateBuff(function(Object,buffProc)
  if Object == myHero and buffProc.Name == "orianaghostself" and buffProc.Count == 1 then
  Ball = myHero
  end
end)

--[[addInterrupterCallback(function(target, spellType)
  if IsReady(_R) and GoS:GetDistance(Ball, enemy) <= 400 and OriannaMenu.Misc.Interrupt:Value() and spellType == CHANELLING_SPELLS then
  CastSpell(_R)
  end
end)]]
