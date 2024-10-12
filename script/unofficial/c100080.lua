local s,id=GetID()
function s.initial_effect(c)
    -- Link Summon
    Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),2)
    c:EnableReviveLimit()
    	--summon cannot be negated
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)

    -- تأثير يجعل جميع أوراق الخصم بلا كود (تأثير دائم)
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CHANGE_CODE)
    e1:SetTargetRange(0, LOCATION_ALL)
    e1:SetValue(0)
    e1:SetRange(LOCATION_MZONE)
    c:RegisterEffect(e1)

    -- عدم التدمير بالمعركة
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- المناعة (عدم التأثر)
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e3:SetCode(EFFECT_IMMUNE_EFFECT)
    e3:SetRange(LOCATION_MZONE)
    e3:SetValue(s.immune_value)
    c:RegisterEffect(e3)

    -- منع تفعيل أوراق الخصم بناءً على النوع (وحش/سحر/فخ)
    local e4 = Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
    e4:SetType(EFFECT_TYPE_QUICK_O)
    e4:SetCode(EVENT_FREE_CHAIN)
    e4:SetRange(LOCATION_MZONE)
    e4:SetCountLimit(1)  -- مرة واحدة في الدور
    e4:SetTarget(s.target)
    e4:SetOperation(s.operation)
    c:RegisterEffect(e4)

    -- تغيير تأثير
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id,1))
    e5:SetType(EFFECT_TYPE_QUICK_O)
    e5:SetCode(EVENT_CHAINING)
    e5:SetRange(LOCATION_MZONE)
    e5:SetCountLimit(1)
    e5:SetCondition(s.chcon)
    e5:SetOperation(s.chop)
    c:RegisterEffect(e5)
    	--Special summon from hand, GY or Panished Zone
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_GRAVE+LOCATION_REMOVED)
	e6:SetCountLimit(1)
	e6:SetTarget(s.sptg1)
	e6:SetOperation(s.spop1)
	c:RegisterEffect(e6)
    -- Make all opponent's monsters lose type, attribute, and level/rank
    local e7=Effect.CreateEffect(c)
    e7:SetType(EFFECT_TYPE_FIELD)
    e7:SetCode(EFFECT_CHANGE_TYPE)
    e7:SetTargetRange(0,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
    e7:SetRange(LOCATION_MZONE)
    e7:SetTarget(s.target5)
    e7:SetValue(TYPE_NORMAL)  -- Makes all opponent's monsters normal monsters (no type)
    c:RegisterEffect(e7)

    -- Remove attribute (element) from all opponent's monsters
    local e8=Effect.CreateEffect(c)
    e8:SetType(EFFECT_TYPE_FIELD)
    e8:SetCode(EFFECT_CHANGE_ATTRIBUTE)
    e8:SetTargetRange(0,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
    e8:SetRange(LOCATION_MZONE)
    e8:SetValue(0)  -- No attribute
    c:RegisterEffect(e8)

    -- Remove level/rank from all opponent's monsters
    local e9=Effect.CreateEffect(c)
    e9:SetType(EFFECT_TYPE_FIELD)
    e9:SetCode(EFFECT_CHANGE_LEVEL)
    e9:SetTargetRange(0,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
    e9:SetRange(LOCATION_MZONE)
    e9:SetValue(0)  -- No level or rank
    c:RegisterEffect(e9)

    -- Remove type from all opponent's monsters (no Plant, Fiend, etc.)
    local e10=Effect.CreateEffect(c)
    e10:SetType(EFFECT_TYPE_FIELD)
    e10:SetCode(EFFECT_CHANGE_RACE)
    e10:SetTargetRange(0,LOCATION_MZONE+LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
    e10:SetRange(LOCATION_MZONE)
    e10:SetValue(0)  -- No race/type (e.g. not Plant, Fiend, etc.)
    c:RegisterEffect(e10)
end

-- تحديد أن الهدف هو وحوش الخصم فقط
function s.target5(e,c)
    return c:IsFaceup() or c:IsLocation(LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK+LOCATION_EXTRA)
end


-- دالة للتحقق من تأثير المناعة ضد أوراق الخصم فقط
function s.immune_value(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- استهداف إرسال الأوراق إلى المقبرة
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

-- تنفيذ إرسال الأوراق ومنع الخصم من تفعيل أوراق بنفس النوع
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND+LOCATION_DECK,0,1,3,nil)
    if #g>0 then
        Duel.SendtoGrave(g,REASON_EFFECT)
        local types={}
        for tc in aux.Next(g) do
            if tc:IsType(TYPE_MONSTER) and not types[TYPE_MONSTER] then
                types[TYPE_MONSTER] = true
            end
            if tc:IsType(TYPE_SPELL) and not types[TYPE_SPELL] then
                types[TYPE_SPELL] = true
            end
            if tc:IsType(TYPE_TRAP) and not types[TYPE_TRAP] then
                types[TYPE_TRAP] = true
            end
        end

        -- منع الخصم من تفعيل الأنواع التي تم إرسالها
        for typ,_ in pairs(types) do
            local e1=Effect.CreateEffect(e:GetHandler())
            e1:SetType(EFFECT_TYPE_FIELD)
            e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
            e1:SetCode(EFFECT_CANNOT_ACTIVATE)
            e1:SetTargetRange(0,1)
            e1:SetValue(s.aclimit(typ))
            e1:SetReset(RESET_PHASE+PHASE_END)
            Duel.RegisterEffect(e1,tp)
        end
    end
end

-- تحديد الأوراق التي لا يمكن للخصم تفعيلها
function s.aclimit(typ)
    return function(e,re,tp)
        return re:IsActiveType(typ)
    end
end

function s.chcon(e,tp,eg,ep,ev,re,r,rp)
    -- التحقق من أن الخصم هو من فعل الورقة، سواء كانت وحش، سحر أو فخ
    return rp==1-tp 
end

function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
    -- التأكد من أن التأثير يمكن تفعيله بدون شروط إضافية
    if chk==0 then return true end
end

function s.chop(e,tp,eg,ep,ev,re,r,rp)
    -- تغيير التأثير الأصلي للورقة ليصبح التأثير الخاص بنا
    Duel.ChangeChainOperation(ev,s.new_operation)
end

function s.new_operation(e,tp,eg,ep,ev,re,r,rp)
    -- خسارة 1000 نقطة حياة للخصم
    Duel.SetLP(tp, Duel.GetLP(tp)/2)

    -- تحديد الأوراق التي سيتم نفيها من ملعب الخصم، يده، أو مقبرته
    local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,1-tp,0,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE,nil)
    if #g>0 then
        -- السماح للاعب باختيار ورقة لنفيها، مع تحديد أنها مقلوبة
        local tc=g:Select(tp,1,1,nil):GetFirst()
        Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
    end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
	--Activation legality
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
	--Special summon from hand
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end