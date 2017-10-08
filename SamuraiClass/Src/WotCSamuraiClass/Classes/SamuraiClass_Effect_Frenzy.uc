class SamuraiClass_Effect_Frenzy extends X2Effect_PersistentStatChange;

var int AddActionPoints;

function ModifyTurnStartActionPoints(XComGameState_Unit UnitState, out array<name> ActionPoints, XComGameState_Effect EffectState)
{
	local int i;

	for (i = 0; i < default.AddActionPoints; ++i)
	{
		ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
	}
}

defaultproperties
{
	AddActionPoints=1
	EffectName="FrenzyEffect"
}