class SamuraiClass_ConditionMoved extends X2Condition;

event name CallAbilityMeetsCondition(XComGameState_Ability kAbility, XComGameState_BaseObject kTarget)
{
	local XComGameState_Unit UnitState;
	local UnitValue			 UnitHasMoved;
	
	UnitState = XComGameState_Unit(kTarget);

	if (UnitState == none)
	{
		`LOG("SamuraiClass_ConditionMoved::CallAbilityMeetsCondition Unit not found.");

		return 'AA_UnitHasMoved';
	}

	UnitState.GetUnitValue('UnitHasMoved', UnitHasMoved);
	if (UnitHasMoved.fValue == 1) {
		return 'AA_UnitHasMoved';
	}
	return 'AA_Success';
}