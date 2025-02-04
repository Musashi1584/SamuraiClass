class SamuraiClass_Effect_BonusDamage extends X2Effect_Persistent;

var int Bonus;
var name AbilityName;
var bool bAbilityOnly;
var bool bSidearmOnly;
var bool bFlankingOnly;
var bool bConcealedOnly;
var bool bUnflankableOnly;

function int GetAttackingDamageModifier(XComGameState_Effect EffectState, XComGameState_Unit Attacker, Damageable TargetDamageable, XComGameState_Ability AbilityState, const out EffectAppliedData AppliedData, const int CurrentDamage, optional XComGameState NewGameState)
{
	// Return 0 if any of these conditions are not met
	//if ( AppliedData.AbilityResultContext.HitResult != HitResult )	{ return 0; }
	if ( bAbilityOnly && AbilityName != AbilityState.GetMyTemplateName() )	{ return 0; }
	if ( bFlankingOnly && !CheckFlanking(Attacker, XComGameState_Unit(TargetDamageable), AbilityState) )	{ return 0; }
	if ( bConcealedOnly && !CheckConcealment( Attacker ) )	{ return 0; }
	if ( bUnflankableOnly && XComGameState_Unit(TargetDamageable).CanTakeCover() )	{ return 0; }
	if ( !IsCorrectWeaponType( AbilityState.GetSourceWeapon() ) )	{ return 0; }

	// we met all conditions, simply return the bonus
	return Bonus;
}

function bool CheckConcealment( XComGameState_Unit Attacker ) {
	local int EventChainStartHistoryIndex;
	
	EventChainStartHistoryIndex = `XCOMHISTORY.GetEventChainStartIndex();
	if ( Attacker.IsConcealed() || Attacker.WasConcealed(EventChainStartHistoryIndex) ) {
		return true;
	}
	return false;
}

function bool CheckFlanking( XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState ) {
	local GameRulesCache_VisibilityInfo VisInfo;

	if (!AbilityState.IsMeleeAbility() && Target != None ) {
		if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(Attacker.ObjectID, Target.ObjectID, VisInfo)) {
			if (Attacker.CanFlank() && Target.CanTakeCover() && VisInfo.TargetCover == CT_None) {
				return true;
			}
		}
	}
	return false;
}

function bool IsCorrectWeaponType(XComGameState_Item SourceWeapon) {
	if ( SourceWeapon == none ) { return false; }
	return ( SourceWeapon.InventorySlot == eInvSlot_SecondaryWeapon ) == bSidearmOnly;
}

defaultproperties
{
	Bonus = 0;
	bAbilityOnly = false;
	bSidearmOnly = false;
	bFlankingOnly = false;
	bConcealedOnly = false;
	bUnflankableOnly = false;
}