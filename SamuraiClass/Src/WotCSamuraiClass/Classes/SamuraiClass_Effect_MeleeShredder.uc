class SamuraiClass_Effect_MeleeShredder extends X2Effect_Persistent
	config(SamuraiClass);

var int ConventionalShred, MagneticShred, BeamShred;

function int GetExtraShredValue(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData)
{
	local XComGameState_Item SourceWeapon;
	local X2WeaponTemplate WeaponTemplate;
	local int ShredValue;
	SourceWeapon = AbilityState.GetSourceWeapon();

	if (SourceWeapon != none && SourceWeapon.GetWeaponCategory() == 'sword')
	{
		WeaponTemplate = X2WeaponTemplate(SourceWeapon.GetMyTemplate());

		ShredValue = ConventionalShred;

		if (WeaponTemplate.WeaponTech == 'magnetic')
			ShredValue = MagneticShred;
		else if (WeaponTemplate.WeaponTech == 'beam')
			ShredValue = BeamShred;

		return ShredValue;
	}
}