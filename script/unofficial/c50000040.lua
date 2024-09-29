local s,id=GetID()
function s.initial_effect(c)
	--disable spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)  -- هنا التعديل ليؤثر فقط عليك (اللاعب المسيطر)
	e1:SetTarget(s.sumlimit)
	c:RegisterEffect(e1)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x701)  -- تقييد الاستدعاء ليقتصر على وحوش المجموعة المحددة
end