class SamuraiClass_Effect_SoulStealToHitModifier extends X2Effect_ToHitModifier;

simulated protected function OnEffectAdded(const out EffectAppliedData ApplyEffectParameters, XComGameState_BaseObject kNewTargetState, XComGameState NewGameState, XComGameState_Effect NewEffectState)
{
	local XComGameState_Unit TargetUnitState;
	local UnitValue SoulStealKillCountTotal;
	local int CritBonus;

	TargetUnitState = XComGameState_Unit(kNewTargetState);
	TargetUnitState.GetUnitValue('SoulStealKillCountTotal', SoulStealKillCountTotal);

	CritBonus = int(SoulStealKillCountTotal.fValue / 10);

	`LOG("SamuraiClass_Effect_SoulStealToHitModifier: Critical hit bonus:" @ CritBonus @ " / SoulStealKillCountTotal: " @ int(SoulStealKillCountTotal.fValue));

	Super.AddEffectHitModifier(eHit_Crit, CritBonus, FriendlyName, class'X2AbilityToHitCalc_StandardMelee', true, false);
}