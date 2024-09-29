-- سكريبت تأثير الورقة
local s,id=GetID()
function s.initial_effect(c)
    -- استدعاء خاص وتأثير من المقبرة
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_GRAVE)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end

-- التارجت: التأكد من وجود ورقة واحدة على الأقل في ملعب الخصم وحساب الأماكن الشاغرة
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- تحقق من وجود ورقة واحدة على الأقل في ملعب الخصم يمكن نفيها
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,TYPE_MONSTER) 
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>1  -- يجب أن يكون هناك مكانين فارغين
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
        and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,RACE_SPELLCASTER)
        and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end  -- شرط وجود ورقة في ملعب الخصم
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end

-- العملية: إرسال الوحش ونفي أوراق الخصم واستدعاء الوحشين
function s.spop(e,tp,eg,ep,ev,re,r,rp)
    -- إرسال وحش من اليد أو المجموعة إلى المقبرة
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
    local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,TYPE_MONSTER)
    if #g>0 then
        local lv=g:GetFirst():GetLevel()
        if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
            -- نفي أوراق الخصم بعدد مستوى الوحش
            local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,lv,nil)
            if #sg>0 then
                Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
            end
            -- استدعاء هذا الوحش و وحش من نوع ساحر
            if Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and e:GetHandler():IsRelateToEffect(e) then
                Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
                local sc=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,RACE_SPELLCASTER)
                if #sc>0 then
                    Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
                end
            end
        end
    end
end
function s.filter(c)
	return c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end