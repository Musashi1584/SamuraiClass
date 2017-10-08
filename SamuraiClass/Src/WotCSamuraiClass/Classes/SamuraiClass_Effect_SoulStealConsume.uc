class SamuraiClass_Effect_SoulStealConsume extends X2Effect_Persistent;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Ability		   AbilityState;
	local StateObjectReference         AbilityRef;
	local XComGameState_Unit           UnitState;
	local UnitValue                    SoulStealKillCount;
	
	UnitState = XComGameState_Unit(kNewTargetState);
	AbilityRef = UnitState.FindAbility('SamuraiSoulStealConsumeSoul');
	AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));
	if (UnitState != none && AbilityState != none && AbilityState.GetMyTemplateName() == 'SamuraiSoulStealConsumeSoul')
	{
		UnitState.GetUnitValue('SoulStealKillCount', SoulStealKillCount);

		if (int(SoulStealKillCount.fValue) > 0)
		{
			UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
				
			UnitState.SetUnitFloatValue('SoulStealKillCount', SoulStealKillCount.fValue - 1, eCleanup_BeginTactical);
				
			//UnitState.ActionPoints.AddItem(class'X2CharacterTemplateManager'.default.StandardActionPoint);
				
			AbilityState.iCharges = int(SoulStealKillCount.fValue - 1);
			NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID);
			NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityState.ObjectID);

			`COMBATLOG("SoulStealActivatedCheck: 1AP added KillCount" @ SoulStealKillCount.fValue);
		}
	}
	super.OnEffectAdded(ApplyEffectParameters, kNewTargetState, NewGameState, NewEffectState);
}