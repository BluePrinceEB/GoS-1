if GetObjectName(myHero) ~= "Ashe" then return end

require('Deftlib')

local AsheMenu = Menu("Ashe", "Ashe")
AsheMenu:SubMenu("Combo", "Combo")
AsheMenu.Combo:Boolean("Q", "Use Q", true)
AsheMenu.Combo:Boolean("W", "Use W", true)
AsheMenu.Combo:Boolean("R", "Use R", true)
AsheMenu.Combo:Key("FireKey", "Ult Fire Key", string.byte("T"))
AsheMenu.Combo:Boolean("Items", "Use Items", true)
AsheMenu.Combo:Slider("myHP", "if HP % <", 50, 0, 100, 1)
AsheMenu.Combo:Slider("targetHP", "if Target HP % >", 20, 0, 100, 1)
AsheMenu.Combo:Boolean("QSS", "Use QSS", true)
AsheMenu.Combo:Slider("QSSHP", "if HP % <", 75, 0, 100, 1)

AsheMenu:SubMenu("Harass", "Harass")
AsheMenu.Harass:Boolean("Q", "Use Q", true)
AsheMenu.Harass:Boolean("W", "Use W", true)
AsheMenu.Harass:Slider("Mana", "if Mana % >", 30, 0, 80, 1)
AsheMenu.Harass:Boolean("AutoW", "Auto W", true)
AsheMenu.Harass:Slider("WMana", "if Mana % >", 50, 0, 80, 1)

AsheMenu:SubMenu("Killsteal", "Killsteal")
AsheMenu.Killsteal:Boolean("W", "Killsteal with W", true)
AsheMenu.Killsteal:Boolean("R", "Killsteal with R", false)

AsheMenu:SubMenu("Misc", "Misc")
AsheMenu.Misc:Boolean("AutoIgnite", "Auto Ignite", true)
AsheMenu.Misc:Boolean("Autolvl", "Auto level", false)
AsheMenu.Misc:List("Autolvltable", "Priority", 1, {"W-Q-E", "Q-W-E"})

AsheMenu:SubMenu("LaneClear", "LaneClear")
AsheMenu.LaneClear:Boolean("Q", "Use Q", false)
AsheMenu.LaneClear:Boolean("W", "Use W", false)
AsheMenu.LaneClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AsheMenu:SubMenu("JungleClear", "JungleClear")
AsheMenu.JungleClear:Boolean("Q", "Use Q", true)
AsheMenu.JungleClear:Boolean("W", "Use W", true)
AsheMenu.JungleClear:Slider("Mana", "if Mana % >", 30, 0, 80, 1)

AsheMenu:SubMenu("Drawings", "Drawings")
AsheMenu.Drawings:Boolean("W", "Draw W Range", true)

local InterruptMenu = Menu("Interrupt (R)", "Interrupt")

GoS:DelayAction(function()

  local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}

  for i, spell in pairs(CHANELLING_SPELLS) do
    for _,k in pairs(GoS:GetEnemyHeroes()) do
        if spell["Name"] == GetObjectName(k) then
        InterruptMenu:Boolean(GetObjectName(k).."Inter", "On "..GetObjectName(k).." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
        end
    end
  end
		
end, 1)

OnProcessSpellComplete(function(unit, spell)
  if unit and spell and spell.name then
    if GetObjectType(unit) == Obj_AI_Hero and GetTeam(unit) ~= GetTeam(GetMyHero()) and IsReady(_R) then
      if CHANELLING_SPELLS[spell.name] then
        if GoS:IsInDistance(unit, 1000) and GetObjectName(unit) == CHANELLING_SPELLS[spell.name].Name and InterruptMenu[GetObjectName(unit).."Inter"]:Value() then 
        Cast(_R,unit)
        end
      end
    end
  end
end)

OnDraw(function(myHero)
if AsheMenu.Drawings.W:Value() then DrawCircle(GoS:myHeroPos(),1200,1,0,0xff00ff00) end
end)

QReady = false

OnTick(function(myHero)

    if IOW:Mode() == "Combo" then
	
	local target = GetCurrentTarget()

	if IsReady(_Q) and QReady and GoS:ValidTarget(target, 700) and AsheMenu.Combo.Q:Value() then
        CastSpell(_Q)
        end
						
        if IsReady(_W) and GoS:ValidTarget(target, 1200) and AsheMenu.Combo.W:Value() then
        Cast(_W,target)
        end
						
        if IsReady(_R) and GoS:ValidTarget(target, 2000) and 100*GetCurrentHP(target)/GetMaxHP(target) < 50 and AsheMenu.Combo.R:Value() then
        Cast(_R,target)
	end
		
	if GetItemSlot(myHero,3140) > 0 and AsheMenu.Combo.QSS:Value() and IsCCed and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) < AsheMenu.Combo.QSSHP:Value() then
        CastTargetSpell(myHero, GetItemSlot(myHero,3140))
        end

        if GetItemSlot(myHero,3139) > 0 and AsheMenu.Combo.QSS:Value() and IsCCed and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) < AsheMenu.Combo.QSSHP:Value() then
        CastTargetSpell(myHero, GetItemSlot(myHero,3139))
        end
    end

    if IOW:Mode() == "Harass" and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= AsheMenu.Harass.Mana:Value() then 
    
        local target = GetCurrentTarget()
      
	if IsReady(_Q) and QReady and GoS:ValidTarget(target, 700) and AsheMenu.Harass.Q:Value() then
        CastSpell(_Q)
        end
						
        if IsReady(_W) and GoS:ValidTarget(target, 1200) and AsheMenu.Harass.W:Value() then
        Cast(_W,target)
	end
		
    end

    if AsheMenu.Combo.FireKey:Value() then
      
      local target = GetCurrentTarget()
     
      if IsReady(_R) and GoS:ValidTarget(target, 3000) then 
      Cast(_R,target)
      end  

    end

      if AsheMenu.Harass.AutoW:Value() and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= AsheMenu.Harass.WMana:Value() then 
    
        local target = GetCurrentTarget()
   
        if IsReady(_W) and GoS:ValidTarget(target, 1200) and not IsRecalling then
        Cast(_W,target)
	end

      end

for i,enemy in pairs(GoS:GetEnemyHeroes()) do
	
      if IOW:Mode() == "Combo" then	
	if GetItemSlot(myHero,3153) > 0 and AsheMenu.Combo.Items:Value() and GoS:ValidTarget(enemy, 550) and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) < AsheMenu.Combo.myHP:Value() and 100*GetCurrentHP(enemy)/GetMaxHP(enemy) > AsheMenu.Combo.targetHP:Value() then
        CastTargetSpell(enemy, GetItemSlot(myHero,3153))
        end

        if GetItemSlot(myHero,3144) > 0 and AsheMenu.Combo.Items:Value() and GoS:ValidTarget(enemy, 550) and 100*GetCurrentHP(myHero)/GetMaxHP(myHero) < AsheMenu.Combo.myHP:Value() and 100*GetCurrentHP(enemy)/GetMaxHP(enemy) > AsheMenu.Combo.targetHP:Value() then
        CastTargetSpell(enemy, GetItemSlot(myHero,3144))
        end

        if GetItemSlot(myHero,3142) > 0 and AsheMenu.Combo.Items:Value() and GoS:ValidTarget(enemy, 600) then
        CastTargetSpell(myHero, GetItemSlot(myHero,3142))
        end	
      end
      
	if Ignite and AsheMenu.Misc.AutoIgnite:Value() then
          if IsReady(Ignite) and 20*GetLevel(myHero)+50 > GetCurrentHP(enemy)+GetDmgShield(enemy)+GetHPRegen(enemy)*2.5 and GoS:ValidTarget(enemy, 600) then
          CastTargetSpell(enemy, Ignite)
          end
	end
	
	if IsReady(_W) and GoS:ValidTarget(enemy, 1200) and AsheMenu.Killsteal.W:Value() and GetCurrentHP(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 15*GetCastLevel(myHero,_W)+5+GetBaseDamage(myHero), 0) then 
	Cast(_W,enemy)
	end
		  
	if IsReady(_R) and GoS:ValidTarget(enemy, 3000) and AsheMenu.Killsteal.R:Value() and GetCurrentHP(enemy)+GetMagicShield(enemy)+GetDmgShield(enemy) < GoS:CalcDamage(myHero, enemy, 0, 175*GetCastLevel(myHero,_R)+75 + GetBonusAP(myHero)) then
        Cast(_R,enemy)
	end
		
end

for _,minion in pairs(GoS:GetAllMinions(MINION_ENEMY)) do

                if IOW:Mode() == "LaneClear" and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= AsheMenu.LaneClear.Mana:Value() then

		  if IsReady(_Q) and AsheMenu.LaneClear.Q:Value() and QReady and GoS:ValidTarget(minion, 700) then
                  CastSpell(_Q)
                  end

                  if IsReady(_W) and AsheMenu.LaneClear.W:Value() then
                    local BestPos, BestHit = GetFarmPosition(1200, 300)
		    if BestPos and BestHit > 0 then
	            CastSkillShot(_W, BestPos.x, BestPos.y, BestPos.z)
		    end
                  end  

	        end
	        
end

for _,mob in pairs(GoS:GetAllMinions(MINION_JUNGLE)) do
		
        if IOW:Mode() == "LaneClear" and 100*GetCurrentMana(myHero)/GetMaxMana(myHero) >= AsheMenu.JungleClear.Mana:Value() then
		local mobPos = GetOrigin(mob)

                if IsReady(_Q) and AsheMenu.JungleClear.Q:Value() and QReady and GoS:ValidTarget(mob, 700) then
                CastSpell(_Q)
                end		

		if IsReady(_W) and AsheMenu.JungleClear.W:Value() and GoS:ValidTarget(mob, 1200) then
		CastSkillShot(_W,mobPos.x, mobPos.y, mobPos.z)
		end
		
        end
end

if AsheMenu.Misc.Autolvl:Value() then  
    if AsheMenu.Misc.Autolvltable:Value() == 1 then leveltable = {_W, _Q, _E, _W, _W, _R, _W, _Q, _W , _Q, _R, _Q, _Q, _E, _E, _R, _E, _E}
    elseif AsheMenu.Misc.Autolvltable:Value() == 2 then leveltable = {_W, _Q, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}
    end
LevelSpell(leveltable[GetLevel(myHero)])
end

end)

OnUpdateBuff(function(unit,buff)
  if unit == myHero and buff.Name == "asheqcastready" then 
  QReady = true
  end
end)

OnRemoveBuff(function(unit,buff)
  if unit == myHero and buff.Name == "asheqcastready" then 
  QReady = false
  end
end)

OnCreateObj(function(Object) 
  if GetObjectBaseName(Object) == "Ashe_Base_Q_ready.troy" and GoS:GetDistance(Object) < 100 then
  QReady = true
  end
end)

OnDeleteObj(function(Object) 
  if GetObjectBaseName(Object) == "Ashe_Base_Q_ready.troy" and GoS:GetDistance(Object) < 100 then
  QReady = false
  end
end)

GoS:AddGapcloseEvent(_R, 69, false)
