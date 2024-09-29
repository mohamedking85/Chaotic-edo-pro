--Emperor of chaotic
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
	Pendulum.AddProcedure(c,false)
	Fusion.AddProcMixRep(c,true,true,s.ffilter,1,99,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT))
		--summon cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
	local e99=e0:Clone()
	e99:SetCode(EFFECT_CANNOT_DISABLE_SUMMON)
	c:RegisterEffect(e99)
		--Take no effect damage, if the amount is less than this card's ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	c:RegisterEffect(e1)
		--activate cost
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.costchk)
	e2:SetOperation(s.costop)
	c:RegisterEffect(e2)
		--Negate summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_REMOVE)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_SPSUMMON)
	c:RegisterEffect(e5)
		--While face-up on the field, this card is also DARK-Attribute
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_ADD_ATTRIBUTE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e7)
		--Unaffected by activated effects
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetRange(LOCATION_PZONE)
	e8:SetTargetRange(LOCATION_MZONE,0)
	e8:SetValue(s.unaval)
	c:RegisterEffect(e8)
		--Your opponent applies 1 effect
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOEXTRA)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_PZONE)
	e9:SetTarget(s.applytg)
	e9:SetOperation(s.applyop)
	c:RegisterEffect(e9)
			--cannot be destroyed by battle
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_SINGLE)
	e11:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e11:SetRange(LOCATION_MZONE)
	e11:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e11:SetValue(1)
	c:RegisterEffect(e11)
	--unaffected by opponent's card effects
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetCode(EFFECT_IMMUNE_EFFECT)
	e6:SetRange(LOCATION_MZONE+LOCATION_EXTRA)
	e6:SetValue(s.efilter)
	c:RegisterEffect(e6)
end
s.material_location=LOCATION_ONFIELD
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_EFFECT,fc,sumtype,tp) and c:IsOnField()
end
--unaffected by opponent's card effects
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.damval(e,re,val,r,rp,rc)
	local atk=e:GetHandler():GetAttack()
	if val<=atk then return 0 else return val end
end
function s.costchk(e,te_or_c,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.CheckLPCost(tp,ct*2000)
end
function s.costop(e,tp,eg,ep,ev,re,r,rp)
	Duel.PayLPCost(tp,2000)
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return tp==1-ep and Duel.GetCurrentChain()==0
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,#eg,0,0)
end
function s.rmfilter(c)
	return c:IsAbleToRemove()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	Duel.NegateSummon(eg)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_ONFIELD,nil)
	g:Merge(eg)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
function s.unaval(e,te)
	local tc=te:GetOwner()
	return te:IsMonsterEffect() and te:IsActivated()
		and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
		and te:IsActiveType(TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK)
end
function s.applytg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ex_ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local b1=ex_ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,ex_ct//2,nil)
	local texg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK),tp,0,LOCATION_MZONE,nil)
	local b2=#texg>0 and #texg==texg:FilterCount(Card.IsAbleToExtra,nil)
	if chk==0 then return b1 or b2 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_HAND|LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOEXTRA,nil,1,1-tp,LOCATION_MZONE)
end
function s.applyop(e,tp,eg,ep,ev,re,r,rp)
	local ex_ct=Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)
	local b1=ex_ct>=2 and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,ex_ct//2,nil)
	local texg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,TYPE_FUSION|TYPE_SYNCHRO|TYPE_XYZ|TYPE_LINK),tp,0,LOCATION_MZONE,nil)
	local b2=#texg>0 and #texg==texg:FilterCount(Card.IsAbleToExtra,nil)
	if not (b1 or b2) then return end
	local op=Duel.SelectEffect(1-tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		local send_ct=ex_ct//2
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToGrave,tp,0,LOCATION_HAND|LOCATION_EXTRA,send_ct,send_ct,nil)
		if #g>0 then
			Duel.SendtoGrave(g,REASON_EFFECT,PLAYER_NONE,1-tp)
		end
	elseif op==2 then
		texg:Match(Card.IsAbleToExtra,nil)
		Duel.SendtoDeck(texg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,1-tp)
	end
end