-- بطاقة سحر سريع
function c100076.initial_effect(c)
local EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE
    -- التأثير الأول: إرسال 3 أوراق من ملعب الخصم واستدعاء وحش "Divine" مع زيادة الهجوم
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCondition(c100076.condition)
    e1:SetTarget(c100076.target)
    e1:SetOperation(c100076.activate)
    c:RegisterEffect(e1)

    -- التأثير الثاني: استدعاء وحش "Divine" إذا كانت الورقة في المقبرة وملعبك فارغ (كويك إيفكت)
    local e2=Effect.CreateEffect(c)
    e2:SetProperty(EFFECT_FLAG_CANNOT_NEGATE_ACTIV_EFF)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCondition(c100076.gravecon)
    e2:SetTarget(c100076.gravetarget)
    e2:SetOperation(c100076.graveop)
    e2:SetCountLimit(1)
    c:RegisterEffect(e2)
end

-- شرط التأثير الأول: خصمك يجب أن يكون لديه ثلاث أوراق أو أكثر في الملعب
function c100076.condition(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>=3
end

-- تحديد الأوراق المستهدفة للتأثير الأول
function c100076.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,3,nil)
        and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c100076.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,3,1-tp,LOCATION_ONFIELD)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- استدعاء وحش من نوع "Divine" وزيادة الهجوم
function c100076.spfilter(c,e,tp)
    return c:IsRace(RACE_DIVINE) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end

-- تنفيذ التأثير الأول
function c100076.activate(e,tp,eg,ep,ev,re,r,rp)
    -- إرسال 3 أوراق من ملعب الخصم إلى المقبرة
    local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,3,3,nil)
    if g:GetCount()>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
    end
    
    -- استدعاء وحش من نوع "Divine"
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,c100076.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
    if tc and Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)~=0 then
        -- زيادة 10,000 نقطة هجوم
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(10000)
        e1:SetReset(RESET_EVENT+RESETS_STANDARD)
        tc:RegisterEffect(e1)
    end
end

-- شرط التأثير الثاني: إذا كانت الورقة في المقبرة وملعبك فارغ
function c100076.gravecon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end

-- تحديد وحش "Divine" للاستدعاء من المقبرة أو المنفى أو المجموعة أو اليد
function c100076.gravetarget(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(c100076.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end

-- تنفيذ التأثير الثاني: استدعاء وحش "Divine"
function c100076.graveop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
    local tc=Duel.SelectMatchingCard(tp,c100076.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp):GetFirst()
    if tc then
        Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end