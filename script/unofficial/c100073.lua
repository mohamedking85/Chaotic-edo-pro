--Ritual of Rebirth
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.AddProcEqual(c,aux.FilterBoolFunction(Card.IsType,TYPE_RITUAL))
	e1:SetTarget(s.target(e1))
end
function s.target(eff)
	local tg = eff:GetTarget()
	return function(e,...)
		local ret = tg(e,...)
		if ret then return ret end
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
			Duel.SetChainLimit(s.chlimit)
		end
	end
end
function s.chlimit(e,ep,tp)
	return tp==ep
end