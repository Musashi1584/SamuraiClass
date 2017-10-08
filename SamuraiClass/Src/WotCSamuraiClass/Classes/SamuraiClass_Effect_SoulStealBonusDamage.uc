class SamuraiClass_Effect_SoulStealBonusDamage extends X2Effect_Persistent;

function bool AllowCritOverride() { return true; }

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	local UnitValue SoulStealKillCountTotal;
	local int CritBonus;
	local XComGameState_Unit TargetUnit;
	
	TargetUnit = XComGameState_Unit(TargetDamageable);

	if (
		AbilityState.SourceWeapon == EffectState.ApplyEffectParameters.ItemStateObjectRef &&
		AbilityState.IsMeleeAbility() && 
		TargetUnit != None &&
		AppliedData.AbilityResultContext.HitResult == eHit_Crit
		)
	{
		Attacker.GetUnitValue('SoulStealKillCountTotal', SoulStealKillCountTotal);
		CritBonus = int(SoulStealKillCountTotal.fValue / 20);
		`LOG("SamuraiClass_Effect_SoulStealBonusDamage: Critical bonus damage:" @ CritBonus @ " / SoulStealKillCountTotal: " @ int(SoulStealKillCountTotal.fValue));

		return CritBonus;
	}

	return 0;
}