//---------------------------------------------------------------------------------------
//  FILE:    X2Ability_SamuraiAbilitySet.uc
//  AUTHOR:  Musashi  --  03/21/2016
//  PURPOSE: Defines all Samurai Based Class Abilities
//           
//---------------------------------------------------------------------------------------
class SamuraiClass_SamuraiAbilitySet extends X2Ability
	dependson (XComGameStateContext_Ability) config(SamuraiClass);

var config int SWORD_THRUST_RUPTURE;
var config int SWORD_THRUST_PIERCE;
var config int SWORD_THRUST_COOLDOWN;
var config int SWORD_THRUST_FOCUS_COST;
var config int WAYOFTHESAMURAI_DAMAGE;
var config int WAYOFTHESAMURAI_HIT;
var config int WAYOFTHESAMURAI_AIM_PENALTY_PRIMARY;
var config int TRAININGDISCIPLINE_MOBILITY;
var config int TRAININGDISCIPLINE_DODGE;
var config int WHIRLWINDSTRIKE_FOCUS_COST;
var config int YAMABUSHI_DEFENSE;
var config int YAMABUSHI_ARMOR;
var config int SAMURAI_REAPER_COOLDOWN;
var config int HAWKEYE_HIT;
var config int HAWKEYE_CRIT;
var config int HAWKEYE_CRITDAMAGE;
var config int UNSTOPPABLE_DODGE_PERCING;
var config int CONVENTIONAL_SHRED;
var config int MAGNETIC_SHRED;
var config int BEAM_SHRED;
var config int WHIRLWINDSTRIKE_AIM_PENALTY;
var config int DRAGONSTRIKE_DESTRUCTION_CHANCE;
var config int DRAGONSTRIKE_RADIUS;
var config int DRAGONSTRIKE_COOLDOWN;
var config int DRAGONSTRIKE_FOCUS_COST;
var config int DANGERSENSE_RADIUS;
var config int SAMURAI_FRENZY_TURNS_DURATION;
var config int SAMURAI_FRENZY_DODGE;
var config int SAMURAI_FRENZY_CRITICAL;
var config int SAMURAI_FRENZY_AP;
var config int COUP_DE_GRACE_HIT_BONUS;
var config int COUP_DE_GRACE_CRIT_BONUS;
var config int COUP_DE_GRACE_DAMAGE_BONUS;
var config int TARGET_DAMAGE_CHANCE_MULTIPLIER;
var config int CUTTHROAT_BONUS_CRIT_CHANCE;
var config int CUTTHROAT_BONUS_CRIT_DAMAGE;
var config int SHINIGAMI_FOCUS_COST;

var name LightningReflexesStateName;
var name ConsumeSoulName;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(SwordThrust());
	Templates.AddItem(DangerSense());
	Templates.AddItem(SamuraiTacticalRigging());
	Templates.AddItem(WayOfTheSamurai());
	Templates.AddItem(AddHawkEyeAbility());
	Templates.AddItem(AddUnstoppableAbility());
	Templates.AddItem(AddMeleeShredderAbility());
	Templates.AddItem(AddWhirlwindStrikeAbility());
	Templates.AddItem(WhirlwindSecondStrike());
	Templates.AddItem(TrainingDiscipline());
	Templates.AddItem(Yamabushi());
	Templates.AddItem(AddDragonStrikeAbility());
	Templates.AddItem(AddSamuraiFrenzyAbility());
	Templates.AddItem(AddShinigamiAbility());
	Templates.AddItem(AddSoulStealAbility());
	Templates.AddItem(SamuraiSoulStealConsumeSoul());
	Templates.AddItem(AddCoupDeGraceAbility());
	Templates.AddItem(AddCutthroatAbility());


	Templates.AddItem(SwordThrustAnimSet());
	Templates.AddItem(DangerSenseTrigger());
	Templates.AddItem(DangerSenseSpawnTrigger());

	return Templates;
}


static function X2AbilityTemplate SwordThrust()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee		StandardMelee;
	local X2Effect_ApplyWeaponDamage			WeaponDamageEffect;
	local array<name>							SkipExclusions;
	local X2Effect_AdditionalAnimSets			AnimSets;
	local X2AbilityCooldown						Cooldown;
	local X2AbilityCost_Focus					FocusCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SwordThrust');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;	
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///SamuraiClassMod.UIPerk_SwordThrust";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	FocusCost = new class'X2AbilityCost_Focus';
	FocusCost.FocusAmount = default.SWORD_THRUST_FOCUS_COST;
	Template.AbilityCosts.AddItem(FocusCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.SWORD_THRUST_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	WeaponDamageEffect.EffectDamageValue.Rupture = default.SWORD_THRUST_RUPTURE;
	WeaponDamageEffect.EffectDamageValue.Pierce = default.SWORD_THRUST_PIERCE;
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.CustomFireAnim = 'FF_MeleeThrustA';
	Template.CustomFireKillAnim = 'FF_MeleeThrustA';
	Template.CustomMovingFireAnim = 'MV_MeleeThrustA';
	Template.CustomMovingFireKillAnim =  'MV_MeleeThrustA';
	Template.CustomMovingTurnLeftFireAnim = 'MV_RunTurn90LeftMeleeThrustA';
	Template.CustomMovingTurnLeftFireKillAnim = 'MV_RunTurn90LeftMeleeThrustA';
	Template.CustomMovingTurnRightFireAnim = 'MV_RunTurn90RightMeleeThrustA';
	Template.CustomMovingTurnRightFireKillAnim = 'MV_RunTurn90RightMeleeThrustA';

	Template.SuperConcealmentLoss = class'X2AbilityTemplateManager'.default.SuperConcealmentStandardShotLoss;
	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.StandardShotChosenActivationIncreasePerUse;
	Template.LostSpawnIncreasePerUse = class'X2AbilityTemplateManager'.default.MeleeLostSpawnIncreasePerUse;
	Template.bFrameEvenWhenUnitIsHidden = true;

	Template.AdditionalAbilities.AddItem('SwordThrustAnimSet');

	return Template;
}

static function X2AbilityTemplate SwordThrustAnimSet()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_AdditionalAnimSets		AnimSets;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SwordThrustAnimSet');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	AnimSets = new class'X2Effect_AdditionalAnimSets';
	AnimSets.EffectName = 'SwordThrustAnimsets';
	AnimSets.AddAnimSetWithPath("SamuraiAnimations.Anims.AS_SwordThrurst");
	AnimSets.BuildPersistentEffect(1, true, false, false, eGameRule_TacticalGameStart);
	AnimSets.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(AnimSets);
	
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	
	Template.bSkipFireAction = true;

	return Template;
}

static function X2AbilityTemplate DangerSense()
{
	local X2AbilityTemplate						Template;
	Template = PurePassive('DangerSense', "img:///UILibrary_PerkIcons.UIPerk_bioelectricskin", true);
	Template.AdditionalAbilities.AddItem('DangerSenseTrigger');
	Template.AdditionalAbilities.AddItem('DangerSenseSpawnTrigger');

	return Template;
}

static function X2AbilityTemplate DangerSenseTrigger()
{
	local X2AbilityTemplate					Template;
	local X2AbilityMultiTarget_Radius		RadiusMultiTarget;
	local X2Effect_RevealUnit				TrackingEffect;
	local X2Condition_UnitProperty			TargetProperty;
	local X2Condition_UnitEffects			EffectsCondition;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DangerSenseTrigger');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bioelectricskin";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_MindControl'.default.EffectName, 'AA_UnitIsNotPlayerControlled');
	Template.AbilityShooterConditions.AddItem(EffectsCondition);

	Template.AbilityTargetStyle = default.SelfTarget;

	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.DANGERSENSE_RADIUS;
	RadiusMultiTarget.bIgnoreBlockingCover = true;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	Template.AbilityMultiTargetConditions.AddItem(TargetProperty);

	EffectsCondition = new class'X2Condition_UnitEffects';
	EffectsCondition.AddExcludeEffect(class'X2Effect_Burrowed'.default.EffectName, 'AA_UnitIsBurrowed');
	Template.AbilityMultiTargetConditions.AddItem(EffectsCondition);

	TrackingEffect = new class'X2Effect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddMultiTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitMoveFinished';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'PlayerTurnBegun';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Player;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

// This triggers whenever a unit is spawned within tracking radius. The most likely
// reason for this to happen is a Faceless transforming due to tracking being applied.
// The newly spawned Faceless unit won't have the tracking effect when this happens,
// so we apply it here.
static function X2AbilityTemplate DangerSenseSpawnTrigger()
{
	local X2AbilityTemplate					Template;
	local X2Effect_RevealUnit				TrackingEffect;
	local X2Condition_UnitProperty			TargetProperty;
	local X2AbilityTrigger_EventListener	EventListener;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DangerSenseSpawnTrigger');

	Template.IconImage = "img:///JediClassUI.UIPerk_DangerSense";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	TargetProperty = new class'X2Condition_UnitProperty';
	TargetProperty.ExcludeDead = true;
	TargetProperty.FailOnNonUnits = true;
	TargetProperty.ExcludeFriendlyToSource = false;
	TargetProperty.RequireWithinRange = true;
	TargetProperty.WithinRange = default.DANGERSENSE_RADIUS * class'XComWorldData'.const.WORLD_METERS_TO_UNITS_MULTIPLIER;
	Template.AbilityTargetConditions.AddItem(TargetProperty);

	TrackingEffect = new class'X2Effect_RevealUnit';
	TrackingEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnEnd);
	Template.AddTargetEffect(TrackingEffect);

	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitSpawned';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.VoidRiftInsanityListener;
	EventListener.ListenerData.Filter = eFilter_None;
	Template.AbilityTriggers.AddItem(EventListener);

	Template.bSkipFireAction = true;
	Template.bSkipPerkActivationActions = true;

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;

	return Template;
}

static function X2AbilityTemplate SamuraiTacticalRigging()
{
	local X2AbilityTemplate Template;

	Template = PurePassive('SamuraiTacticalRigging', , , 'eAbilitySource_Perk', false);
	Template.SoldierAbilityPurchasedFn = SamuraiTacticalRiggingPurchased;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_tacticalrigging";

	return Template;
}

function SamuraiTacticalRiggingPurchased(XComGameState NewGameState, XComGameState_Unit UnitState)
{
	`LOG(UnitState.GetCurrentStat(eStat_UtilityItems),, 'SamuraiClass');
	UnitState.SetBaseMaxStat(eStat_UtilityItems, UnitState.GetMyTemplate().GetCharacterBaseStat(eStat_UtilityItems) + 1.0f);
	UnitState.SetCurrentStat(eStat_UtilityItems, UnitState.GetMyTemplate().GetCharacterBaseStat(eStat_UtilityItems) + 1.0f);
	`LOG(UnitState.GetCurrentStat(eStat_UtilityItems),, 'SamuraiClass');
}

//******** WayOfTheSamurai Ability ********
static function X2AbilityTemplate WayOfTheSamurai()
{
	local X2AbilityTemplate						Template;
	local X2Effect_BonusWeaponDamage            DamageEffect;
	local X2Effect_ToHitModifier                HitBonusEffect;

	// Icon Properties
	`CREATE_X2ABILITY_TEMPLATE(Template, 'WayOfTheSamurai');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_momentum";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bHideOnClassUnlock = false;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	// Bonus Damage with swords
	DamageEffect = new class'X2Effect_BonusWeaponDamage';
	DamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false);
	DamageEffect.BonusDmg = default.WAYOFTHESAMURAI_DAMAGE;
	DamageEffect.BuildPersistentEffect(1, true, false, false);
	Template.AddTargetEffect(DamageEffect);

	// Hit bonus swords
	HitBonusEffect = new class'X2Effect_ToHitModifier';
	HitBonusEffect.EffectName = 'WayOfTheSamuraiHitBonus';
	HitBonusEffect.BuildPersistentEffect(1, true, false, false);
	HitBonusEffect.DuplicateResponse = eDupe_Refresh;
	HitBonusEffect.AddEffectHitModifier(eHit_Success, default.WAYOFTHESAMURAI_HIT, Template.LocFriendlyName, class'X2AbilityToHitCalc_StandardMelee', true, false);
	HitBonusEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(HitBonusEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//******** Whirlwind Strike Ability ********
static function X2AbilityTemplate AddWhirlwindStrikeAbility()
{
	local X2AbilityTemplate					Template;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee	StandardMelee;
	local X2Effect_ApplyWeaponDamage		WeaponDamageEffect;
	local array<name>						SkipExclusions;
	local X2Effect_AdditionalAnimSets		AnimSets;
	local X2AbilityCost_Focus				FocusCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'WhirlwindStrike');

	FocusCost = new class'X2AbilityCost_Focus';
	FocusCost.FocusAmount = default.WHIRLWINDSTRIKE_FOCUS_COST;
	Template.AbilityCosts.AddItem(FocusCost);

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";
	Template.bHideOnClassUnlock = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";

	//AnimSets = new class'X2Effect_AdditionalAnimSets';
	//AnimSets.AddAnimSetWithPath("SamuraiAnimations.Anims.AS_WhirlwindStrike");
	//AnimSets.BuildPersistentEffect(1, false, false, false);
	//AnimSets.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	//Template.AddShooterEffect(AnimSets);
	
	//Template.CustomFireAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomFireKillAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingFireAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingFireKillAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingTurnLeftFireAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingTurnLeftFireKillAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingTurnRightFireAnim = 'FF_MeleeWhirlwhindStrike';
	//Template.CustomMovingTurnRightFireKillAnim = 'FF_MeleeWhirlwhindStrike';

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'X2TargetingMethod_MeleePath';

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	addWhilwindStrikeHitPenalty(Template);

	Template.AdditionalAbilities.AddItem('WhirlwindSecondStrike');
	Template.PostActivationEvents.AddItem('WhirlwindSecondStrike');

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	return Template;
}


//******** WhirlwindSecondStrike Ability ********
static function X2AbilityTemplate WhirlwindSecondStrike()
{
	local X2AbilityTemplate                  Template;
	local X2AbilityToHitCalc_StandardMelee   StandardMelee;
	local X2Effect_ApplyWeaponDamage         WeaponDamageEffect;
	local array<name>                        SkipExclusions;
	local X2AbilityTrigger_EventListener     Trigger;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'WhirlwindSecondStrike');

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_chryssalid_slash";
	Template.bHideOnClassUnlock = true;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;
	
	Trigger = new class'X2AbilityTrigger_EventListener';
	Trigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	Trigger.ListenerData.EventID = 'WhirlwindSecondStrike';
	Trigger.ListenerData.Filter = eFilter_Unit;
	Trigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_OriginalTarget;
	Template.AbilityTriggers.AddItem(Trigger);

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	addWhilwindStrikeHitPenalty(Template);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.MergeVisualizationFn = SequentialShot_MergeVisualization;
	Template.bShowActivation = true;
	Template.bSkipExitCoverWhenFiring  = true;

	return Template;
}

//******** Samurai Frenzy Ability ********
static function X2AbilityTemplate AddSamuraiFrenzyAbility()
{
	local X2AbilityTemplate              Template;
	local X2AbilityTrigger_EventListener EventListener;
	local X2Condition_UnitEffects        ExcludeEffects;
	local X2AbilityCost_ActionPoints     ActionPointCost;
	local SamuraiClass_Effect_Frenzy     FrenzyEffect;
	local X2Effect_ToHitModifier         CriticalEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SamuraiFrenzy');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_beserker_rage";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityToHitCalc = default.DeadEye;

	//Template.bDontDisplayInAbilitySummary = true;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.bFreeCost = true;
    Template.AbilityCosts.AddItem(ActionPointCost);

	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	// This ability fires when the unit takes damage
	EventListener = new class'X2AbilityTrigger_EventListener';
	EventListener.ListenerData.Deferral = ELD_OnStateSubmitted;
	EventListener.ListenerData.EventID = 'UnitTakeEffectDamage';
	EventListener.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_Self;
	EventListener.ListenerData.Filter = eFilter_Unit;
	Template.AbilityTriggers.AddItem(EventListener);

	FrenzyEffect = new class'SamuraiClass_Effect_Frenzy';
	FrenzyEffect.AddActionPoints = default.SAMURAI_FRENZY_AP;
	FrenzyEffect.BuildPersistentEffect(default.SAMURAI_FRENZY_TURNS_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	FrenzyEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage, true,,Template.AbilitySourceName);
	FrenzyEffect.DuplicateResponse = eDupe_Ignore;
	FrenzyEffect.AddPersistentStatChange (eStat_Dodge, default.SAMURAI_FRENZY_DODGE);
	FrenzyEffect.EffectHierarchyValue = class'X2StatusEffects'.default.FRENZY_HIERARCHY_VALUE;
	// FrenzyEffect.ApplyChance = default.SAMURAI_FRENZY_ACTIVATE_PERCENT_CHANCE;
	Template.AddTargetEffect(FrenzyEffect);

	CriticalEffect = new class'X2Effect_ToHitModifier';
	CriticalEffect.EffectName = 'SamuraiFrenzyCritical';
	CriticalEffect.BuildPersistentEffect(default.SAMURAI_FRENZY_TURNS_DURATION, false, true, false, eGameRule_PlayerTurnEnd);
	CriticalEffect.DuplicateResponse = eDupe_Ignore;
	CriticalEffect.AddEffectHitModifier(eHit_Crit, default.SAMURAI_FRENZY_CRITICAL, Template.LocFriendlyName, class'X2AbilityToHitCalc_StandardMelee', true, false);
	CriticalEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,false,,Template.AbilitySourceName);
	Template.AddTargetEffect(CriticalEffect);

	// The shooter must not have Frenzy activated
	ExcludeEffects = new class'X2Condition_UnitEffects';
	ExcludeEffects.AddExcludeEffect(class'SamuraiClass_Effect_Frenzy'.default.EffectName, 'AA_UnitIsFrenzied');
	Template.AbilityShooterConditions.AddItem(ExcludeEffects);

	Template.bSkipFireAction = true;
	Template.bShowActivation = true;
	Template.ActivationSpeech = 'ActivateFrenzy';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Archon_Frenzy";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

//******** MeleeShredder Ability ********
static function X2AbilityTemplate AddMeleeShredderAbility()
{
	local X2AbilityTemplate						Template;
	local SamuraiClass_Effect_MeleeShredder     ShredderEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'MeleeShredder');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_coupdegrace";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ShredderEffect = new class'SamuraiClass_Effect_MeleeShredder';
	ShredderEffect.EffectName = 'MeleeShredderEffect';
	ShredderEffect.DuplicateResponse = eDupe_Allow;
	ShredderEffect.BuildPersistentEffect(1, true, false, false);
	ShredderEffect.ConventionalShred = default.CONVENTIONAL_SHRED; 
	ShredderEffect.MagneticShred = default.MAGNETIC_SHRED; 
	ShredderEffect.BeamShred = default.BEAM_SHRED;
	ShredderEffect.FriendlyName = Template.LocFriendlyName;
	ShredderEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(ShredderEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

//******** Unstoppable Ability ********
static function X2AbilityTemplate AddUnstoppableAbility()
{
	local X2AbilityTemplate						Template;
	local SamuraiClass_Effect_BonusHitResult    DodgePiercingEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Unstoppable');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_bullrush";
	
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	DodgePiercingEffect = new class'SamuraiClass_Effect_BonusHitResult';
	DodgePiercingEffect.EffectName = 'UnstoppableDodgePiercing';
	DodgePiercingEffect.BuildPersistentEffect(1, true, false, false);
	DodgePiercingEffect.Bonus = -default.UNSTOPPABLE_DODGE_PERCING;
	DodgePiercingEffect.HitResult = eHit_Graze;
	DodgePiercingEffect.bCannotGraze = true;
	DodgePiercingEffect.bSidearmOnly = true;
	DodgePiercingEffect.FriendlyName = Template.LocFriendlyName;
	DodgePiercingEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,,,Template.AbilitySourceName);
	Template.AddTargetEffect(DodgePiercingEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}

//******** HawkEye Ability **********
static function X2AbilityTemplate AddHawkEyeAbility()
{
	local X2AbilityTemplate						      Template;
	local SamuraiClass_Effect_MeleeCriticalDamage     DamageEffect;
	local X2Effect_ToHitModifier                      HitEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'HawkEye');

	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_hunter";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//Adds bonus crit and hit
	HitEffect = new class'X2Effect_ToHitModifier';
	HitEffect.EffectName = 'HawkEyeHitBuff';
	HitEffect.BuildPersistentEffect(1, true, false);
	HitEffect.DuplicateResponse = eDupe_Ignore;
	// EAbilityHitResult ModType, int ModAmount, string ModReason, class<X2AbilityToHitCalc> MatchToHit=class'X2AbilityToHitCalc_StandardAim',
	// bool Melee=true, bool NonMelee=true, bool Flanked=true, bool NonFlanked=true, optional array<name> AbilityArrayNames, bool ApplyIfImpaired=true
	HitEffect.AddEffectHitModifier(eHit_Crit, default.HAWKEYE_CRIT, Template.LocFriendlyName, class'X2AbilityToHitCalc_StandardMelee', true, false);
	// HitEffect.AddEffectHitModifier(eHit_Success, default.HAWKEYE_HIT, Template.LocFriendlyName, class'X2AbilityToHitCalc_StandardMelee', true, false);
	HitEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,true,,Template.AbilitySourceName);
	Template.AddTargetEffect(HitEffect);

	//increase damage on critical hit
	DamageEffect = new class'SamuraiClass_Effect_MeleeCriticalDamage';
	DamageEffect.EffectName = 'HawkEyeDamageBuff';
	DamageEffect.BonusDamage = default.HAWKEYE_CRITDAMAGE;
	DamageEffect.DuplicateResponse = eDupe_Allow;
	// BuildPersistentEffect Parameter:
	// int _iNumTurns, optional bool _bInfiniteDuration=false, optional bool _bRemoveWhenSourceDies=true, optional bool _bIgnorePlayerCheckOnTick=false, optional GameRuleStateChange _WatchRule=eGameRule_TacticalGameStart 
	DamageEffect.BuildPersistentEffect(1, true, true, true);
	Template.AddTargetEffect(DamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//******** Training Discipline Ability **********
static function X2AbilityTemplate TrainingDiscipline()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange         PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'TrainingDiscipline');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_dash";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//buff
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.TRAININGDISCIPLINE_MOBILITY);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.TRAININGDISCIPLINE_DODGE);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.TRAININGDISCIPLINE_MOBILITY);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.WillLabel, eStat_Dodge, default.TRAININGDISCIPLINE_DODGE);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//******** Yamabushi Ability **********
static function X2AbilityTemplate Yamabushi()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange         PersistentStatChangeEffect;
	local X2Effect_Regeneration                 RegenerationEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Yamabushi');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_absorption_fields";

	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//buff
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage,,,Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, default.YAMABUSHI_DEFENSE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, default.YAMABUSHI_ARMOR);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorChance, 100);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_Defense, default.YAMABUSHI_DEFENSE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.ArmorLabel, eStat_ArmorMitigation, default.YAMABUSHI_ARMOR);
	
    //Build the regeneration effect
	RegenerationEffect = new class'X2Effect_Regeneration';
	RegenerationEffect.BuildPersistentEffect(1, true, true, false, eGameRule_PlayerTurnBegin);
	RegenerationEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	RegenerationEffect.HealAmount = 2;
	RegenerationEffect.MaxHealAmount = 6;
	RegenerationEffect.HealthRegeneratedName = 'SamuraiHealthRegenerated';
	Template.AddTargetEffect(RegenerationEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

//******** Dragon Strike Ability **********
static function X2AbilityTemplate AddDragonStrikeAbility()
{
	local X2AbilityTemplate						Template;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local X2AbilityToHitCalc_StandardMelee		StandardMelee;
	local X2Effect_ApplyWeaponDamage			WeaponDamageEffect;
	local X2AbilityCooldown						Cooldown;
	local SamuraiClass_ApplyRadialWorldDamage	WorldDamage;
	local X2AbilityMultiTarget_Radius			RadiusMultiTarget;
	local X2Effect_ApplyWeaponDamage			RadialDamageEffect;
	local array<name>							SkipExclusions;
	local X2AbilityCost_Focus					FocusCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'DragonStrike');

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.DRAGONSTRIKE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	FocusCost = new class'X2AbilityCost_Focus';
	FocusCost.FocusAmount = default.DRAGONSTRIKE_FOCUS_COST;
	Template.AbilityCosts.AddItem(FocusCost);

	Template.AbilitySourceName = 'eAbilitySource_Standard';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_AlwaysShow;
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Ranger_Reaper";
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_closeandpersonal";
	Template.bHideOnClassUnlock = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_COLONEL_PRIORITY;
	Template.AbilityConfirmSound = "TacticalUI_SwordConfirm";
	Template.Hostility = eHostility_Offensive;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 2;
	ActionPointCost.bConsumeAllPoints = true;
	Template.AbilityCosts.AddItem(ActionPointCost);
	
	StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
	Template.AbilityToHitCalc = StandardMelee;

	Template.AbilityTargetStyle = new class'X2AbilityTarget_MovingMelee';
	Template.TargetingMethod = class'SamuraiClass_TargetingMethod_MeleeAOE';
	
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	Template.AbilityTriggers.AddItem(new class'X2AbilityTrigger_EndOfMove');

	// Target Conditions
	//
	Template.AbilityTargetConditions.AddItem(default.LivingHostileTargetProperty);
	Template.AbilityTargetConditions.AddItem(default.MeleeVisibilityCondition);

	// Shooter Conditions
	//
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	SkipExclusions.AddItem(class'X2StatusEffects'.default.BurningName);
	Template.AddShooterEffectExclusions(SkipExclusions);

	// Damage Effect
	//
	WeaponDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	Template.AddTargetEffect(WeaponDamageEffect);

	// Radius target for the world damage
	RadiusMultiTarget = new class'X2AbilityMultiTarget_Radius';
	RadiusMultiTarget.fTargetRadius = default.DRAGONSTRIKE_RADIUS;
	Template.AbilityMultiTargetStyle = RadiusMultiTarget;


	Template.bAllowBonusWeaponEffects = true;
	Template.bSkipMoveStop = true;

	WorldDamage = new class'SamuraiClass_ApplyRadialWorldDamage';
	WorldDamage.bUseWeaponDamageType = true;
	WorldDamage.bUseWeaponEnvironmentalDamage = true;
	WorldDamage.bApplyOnHit = true;
	WorldDamage.bApplyOnMiss = true;
	WorldDamage.bApplyToWorldOnHit = true;
	WorldDamage.bApplyToWorldOnMiss = true;
	WorldDamage.bHitAdjacentDestructibles = true;
	WorldDamage.PlusNumZTiles = 3;
	WorldDamage.bHitTargetTile = true;
	WorldDamage.bHitSourceTile = false;
	WorldDamage.ApplyChance = default.DRAGONSTRIKE_DESTRUCTION_CHANCE;
	Template.AddTargetEffect(WorldDamage);

	RadialDamageEffect = new class'X2Effect_ApplyWeaponDamage';
	RadialDamageEffect.bIgnoreBaseDamage = false;
	RadialDamageEffect.DamageTag = 'DragonStrikeRadialDamage';
	Template.AddMultiTargetEffect(RadialDamageEffect);

	Template.AddMultiTargetEffect(class'X2StatusEffects'.static.CreateDisorientedStatusEffect(true));
	
	// Voice events
	//
	Template.SourceMissSpeech = 'SwordMiss';

	Template.BuildNewGameStateFn = TypicalMoveEndAbility_BuildGameState;
	Template.BuildInterruptGameStateFn = TypicalMoveEndAbility_BuildInterruptGameState;

	return Template;
}

//******** Shinigami Ability **********
static function X2AbilityTemplate AddShinigamiAbility()
{
	local X2AbilityTemplate             Template;
	local X2Effect_Persistent           PersistentEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'Shinigami');
	Template.AdditionalAbilities.AddItem('SamuraiSoulStealConsumeSoul');
	Template.AdditionalAbilities.AddItem('SamuraiSoulSteal');
	
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deathblossom";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bIsPassive = true;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	//  This is a dummy effect so that an icon shows up in the UI.
	PersistentEffect = new class'X2Effect_Persistent';
	PersistentEffect.BuildPersistentEffect(1, true, false);
	PersistentEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, true,, Template.AbilitySourceName);
	Template.AddTargetEffect(PersistentEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	Template.bCrossClassEligible = false;

	Template.AdditionalAbilities.AddItem('TemplarFocus');

	return Template;
}

//******** ShinigamiConsumeSoul Ability **********
static function X2AbilityTemplate SamuraiSoulStealConsumeSoul()
{
	local X2AbilityTemplate						Template;
	local X2AbilityTargetStyle					TargetStyle;
	local X2AbilityTrigger						Trigger;
	local SamuraiClass_Effect_SoulStealConsume	SoulStealConsume;
	local X2Effect_RemoveEffects				RemoveEffects;
	local X2AbilityCharges						Charges;
	local X2AbilityCost_ActionPoints			ActionPointCost;
	local SamuraiClass_ConditionMoved			NotMovedCondition;
	local X2Effect_Speed						SpeedEffect;
	local X2AbilityCost_Focus					FocusCost;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SamuraiSoulStealConsumeSoul');

	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_ShowIfAvailable;	
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deathblossom";
	Template.Hostility = eHostility_Neutral;
	Template.AbilityConfirmSound = "TacticalUI_Activate_Ability_Wraith_Armor";
	// Template.AbilitySourceName = 'eAbilitySource_Psionic';

	Template.AbilityToHitCalc = default.DeadEye;
	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;
	
 	Trigger = new class'X2AbilityTrigger_PlayerInput';
	Template.AbilityTriggers.AddItem(Trigger);

	NotMovedCondition = new class'SamuraiClass_ConditionMoved';
	Template.AbilityTargetConditions.AddItem(NotMovedCondition);

	FocusCost = new class'X2AbilityCost_Focus';
	FocusCost.FocusAmount = default.SHINIGAMI_FOCUS_COST;
	Template.AbilityCosts.AddItem(FocusCost);

 	//Template.AbilityCosts.AddItem(new class'X2AbilityCost_Charges');
 	//Charges = new class'X2AbilityCharges';
	//Charges.InitialCharges = 0; 
	//Template.AbilityCharges = Charges;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	//ActionPointCost.bConsumeAllPoints = false;
	ActionPointCost.bFreeCost = true;
	Template.AbilityCosts.AddItem(ActionPointCost);

	RemoveEffects = new class'X2Effect_RemoveEffects';
	RemoveEffects.EffectNamesToRemove.AddItem('SoulStealConsume');
 	Template.AddTargetEffect(RemoveEffects);

	SoulStealConsume = new class 'SamuraiClass_Effect_SoulStealConsume';
	SoulStealConsume.EffectName = 'SoulStealConsume';
	SoulStealConsume.BuildPersistentEffect(1, false, true, , eGameRule_PlayerTurnBegin);
	SoulStealConsume.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage,true,,Template.AbilitySourceName);
	SoulStealConsume.bRemoveWhenTargetDies = true;
	SoulStealConsume.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(SoulStealConsume);

	SpeedEffect = new class'X2Effect_Speed';
	SpeedEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnBegin);
	SpeedEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, , , Template.AbilitySourceName);
	Template.AddTargetEffect(SpeedEffect);

 	Template.bShowActivation = true;
	Template.bSkipFireAction = true;
	Template.CustomFireAnim = 'HL_Psi_SelfCast';
	Template.ActivationSpeech = 'CombatStim';
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.CinescriptCameraType = "Psionic_FireAtUnit";
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

//******** ShinigamiSoulSteal Trigger Ability **********
static function X2AbilityTemplate AddSoulStealAbility()
{
	local X2AbilityTemplate								Template;
	local X2AbilityTargetStyle							TargetStyle;
	local X2AbilityTrigger								Trigger;
	local SamuraiClass_Effect_SoulSteal				    TrackerEffect;
	local SamuraiClass_Effect_SoulStealToHitModifier    HitEffect;
	local SamuraiClass_Effect_SoulStealBonusDamage      BonusDamageEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SamuraiSoulSteal');
	Template.bDontDisplayInAbilitySummary = true;
	Template.bDisplayInUITooltip = false;
	Template.bDisplayInUITacticalText = false;
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_deathblossom";
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;

	TargetStyle = new class'X2AbilityTarget_Self';
	Template.AbilityTargetStyle = TargetStyle;

	Trigger = new class'X2AbilityTrigger_UnitPostBeginPlay';
	Template.AbilityTriggers.AddItem(Trigger);
	
 	TrackerEffect = new class'SamuraiClass_Effect_SoulSteal';
	TrackerEffect.EffectName = 'SamuraiClassSoulStealEffect';
	TrackerEffect.BuildPersistentEffect(1, true, false);
	TrackerEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false,,Template.AbilitySourceName);
	TrackerEffect.DuplicateResponse = eDupe_Ignore;
	Template.AddTargetEffect(TrackerEffect);

	HitEffect = new class'SamuraiClass_Effect_SoulStealToHitModifier';
	HitEffect.EffectName = 'SoulStealCritBuff';
	HitEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	HitEffect.DuplicateResponse = eDupe_Refresh;
	HitEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,false,,Template.AbilitySourceName);
	Template.AddTargetEffect(HitEffect);

	BonusDamageEffect = new class'SamuraiClass_Effect_SoulStealBonusDamage';
	BonusDamageEffect.EffectName = 'SoulStealCritDamageBuff';
	BonusDamageEffect.BuildPersistentEffect(1, true, false, false, eGameRule_PlayerTurnBegin);
	BonusDamageEffect.DuplicateResponse = eDupe_Refresh;
	BonusDamageEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.LocHelpText, Template.IconImage,false,,Template.AbilitySourceName);
	Template.AddTargetEffect(BonusDamageEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	return Template;
}
	

static function X2AbilityTemplate AddCoupDeGraceAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_CoupdeGrace				CoupDeGraceEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SamuraiCoupDeGrace');
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.IconImage = "img:///SamuraiClassMod.LW_AbilityCoupDeGrace";
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.bDisplayInUITooltip = true;
    Template.bDisplayInUITacticalText = true;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	CoupDeGraceEffect = new class'X2Effect_CoupdeGrace';
	CoupDeGraceEffect.To_Hit_Modifier=default.COUP_DE_GRACE_HIT_BONUS;
	CoupDeGraceEffect.Crit_Modifier=default.COUP_DE_GRACE_CRIT_BONUS;
	CoupDeGraceEffect.Damage_Bonus=default.COUP_DE_GRACE_DAMAGE_BONUS;
	CoupDeGraceEffect.Half_for_Disoriented=true;
	CoupDeGraceEffect.BuildPersistentEffect (1, true, false);
	CoupDeGraceEffect.SetDisplayInfo (ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect(CoupDeGraceEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;

	return Template;
}

static function X2AbilityTemplate AddCutthroatAbility()
{
	local X2AbilityTemplate					Template;
	local X2Effect_Cutthroat				ArmorPiercingBonus;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'SamuraiCutthroat');
	Template.IconImage = "img:///SamuraiClassMod.LW_AbilityCutthroat";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	Template.bIsPassive = true;
	Template.bCrossClassEligible = false;
	ArmorPiercingBonus = new class 'X2Effect_Cutthroat';
	ArmorPiercingBonus.BuildPersistentEffect (1, true, false);
	ArmorPiercingBonus.Bonus_Crit_Chance = default.CUTTHROAT_BONUS_CRIT_CHANCE;
	ArmorPiercingBonus.Bonus_Crit_Damage = default.CUTTHROAT_BONUS_CRIT_DAMAGE;
	ArmorPiercingBonus.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, true,,Template.AbilitySourceName);
	Template.AddTargetEffect (ArmorPiercingBonus);
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;	
	//no visualization
	return Template;		
}

//******** Helper Functions **********
static function addWhilwindStrikeHitPenalty(X2AbilityTemplate Template)
{
	local X2AbilityToHitCalc_StandardMelee ToHitCalc;
	ToHitCalc = new class'X2AbilityToHitCalc_StandardMelee';
	ToHitCalc.BuiltInHitMod = default.WHIRLWINDSTRIKE_AIM_PENALTY;
	Template.AbilityToHitCalc = ToHitCalc;
	Template.AbilityToHitOwnerOnMissCalc = ToHitCalc;
}