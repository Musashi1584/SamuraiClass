class SamuraiClass_Effect_BonusHitResult extends X2Effect_Persistent;

var EAbilityHitResult HitResult;
var int Bonus;
var bool bAnyWeaponType; // overrides bSidearmOnly
var bool bSidearmOnly;
var bool bPrimaryOnly;
var bool bFlankingOnly;
var bool bConcealedOnly;
var bool bUnflankableOnly;
var bool bInjuredOnly;
var bool bOverwatchOnly;
var bool bCannotGraze;

function GetToHitModifiers(XComGameState_Effect EffectState, XComGameState_Unit Attacker, XComGameState_Unit Target, XComGameState_Ability AbilityState, class<X2AbilityToHitCalc> ToHitType, bool bMelee, bool bFlanking, bool bIndirectFire, out array<ShotModifierInfo> ShotModifiers)
{
	local ShotModifierInfo ModInfo;
	
	// Return if any of these conditions are not met
	if ( bFlankingOnly && !CheckFlanking(Attacker, Target, AbilityState) )	{ return; }
	if ( bConcealedOnly && !CheckConcealment( Attacker ) )	{ return; }
	if ( bUnflankableOnly && Target.CanTakeCover() )	{ return; }
	if ( !IsSecondaryWeapon( AbilityState.GetSourceWeapon() ) )	{ return; }
	if ( !IsPrimaryWeapon( AbilityState.GetSourceWeapon() ) )	{ return; }
	if ( bInjuredOnly && Attacker.GetCurrentStat(eStat_HP) >= Attacker.GetMaxStat(eStat_HP) )	{ return; }
	if ( bOverwatchOnly && AbilityState.GetMyTemplateName() != 'OverwatchShot' )	{ return; }
	
	// we met all conditions, simply return the bonus
	ModInfo.ModType = HitResult; // eHit_Success; eHit_Crit; eHit_Graze;
	ModInfo.Reason = FriendlyName;
	ModInfo.Value = Bonus;
	ShotModifiers.AddItem(ModInfo);
}

function bool ShotsCannotGraze() 
{
	return bCannotGraze;
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

function bool IsSecondaryWeapon(XComGameState_Item SourceWeapon) {
	if ( SourceWeapon == none ) { return false; }
	return ( SourceWeapon.InventorySlot == eInvSlot_SecondaryWeapon ) == bSidearmOnly;
}

function bool IsPrimaryWeapon(XComGameState_Item SourceWeapon) {
	if ( SourceWeapon == none ) { return false; }
	return ( SourceWeapon.InventorySlot == eInvSlot_PrimaryWeapon ) == bPrimaryOnly;
}

defaultproperties
{
	HitResult = eHit_Success;
	Bonus = 0;
	bAnyWeaponType = false;
	bSidearmOnly = false;
	bPrimaryOnly = false;
	bFlankingOnly = false;
	bConcealedOnly = false;
	bUnflankableOnly = false;
	bInjuredOnly = false;
	bOverwatchOnly = false;
	bCannotGraze = false;
	DuplicateResponse = eDupe_Allow;
}