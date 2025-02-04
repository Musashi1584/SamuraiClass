//---------------------------------------------------------------------------------------
//  FILE:    X2TargetingMethod_MeleePath.uc
//  AUTHOR:  David Burchanowski  --  2/10/2014
//  PURPOSE: Targeting method for activated melee attacks
//           
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class SamuraiClass_TargetingMethod_MeleeAOE extends X2TargetingMethod_MeleePath; //X2TargetingMethod;

var private X2MeleePathingPawn      PathingPawn;
var private XComActionIconManager   IconManager;
var private XComLevelBorderManager  LevelBorderManager;
var private XCom3DCursor            Cursor;
var private X2Camera_Midpoint       TargetingCamera;
var private XGUnit					TargetUnit;
var protected transient XComEmitter ExplosionEmitter;
var bool SnapToTile;

// the index of the last available target we were targeting
var private int LastTarget;

function Init(AvailableAction InAction, int NewTargetIndex)
{
	local XComPresentationLayer Pres;
	local X2AbilityTemplate AbilityTemplate;

	super.Init(InAction, NewTargetIndex);

	Pres = `PRES;

	Cursor = `CURSOR;
	PathingPawn = Cursor.Spawn(class'X2MeleePathingPawn', Cursor);
	PathingPawn.SetVisible(true);
	PathingPawn.Init(UnitState, Ability, self);
	IconManager = Pres.GetActionIconMgr();
	LevelBorderManager = Pres.GetLevelBorderMgr();

	// force the initial updates
	IconManager.ShowIcons(true);
	LevelBorderManager.ShowBorder(true);
	IconManager.UpdateCursorLocation(true);
	LevelBorderManager.UpdateCursorLocation(Cursor.Location, true);

	AbilityTemplate = Ability.GetMyTemplate();
	if (!AbilityTemplate.SkipRenderOfTargetingTemplate)
	{
		// setup the blast emitter
		ExplosionEmitter = `BATTLE.spawn(class'XComEmitter');
		if(AbilityIsOffensive)
		{
			ExplosionEmitter.SetTemplate(ParticleSystem(DynamicLoadObject("UI_Range.Particles.BlastRadius_Shpere", class'ParticleSystem')));
		}
		else
		{
			ExplosionEmitter.SetTemplate(ParticleSystem(DynamicLoadObject("UI_Range.Particles.BlastRadius_Shpere_Neutral", class'ParticleSystem')));
		}
		
		ExplosionEmitter.LifeSpan = 60 * 60 * 24 * 7; // never die (or at least take a week to do so)
	}

	DirectSelectNearestTarget();
}

function DirectSelectNearestTarget()
{
	local XComGameStateHistory History;
	local XComWorldData WorldData;
	local Vector SourceUnitLocation;
	local X2GameRulesetVisibilityInterface Target;
	local TTile TargetTile;

	local int TargetIndex;
	local float TargetDistanceSquared;
	local int ClosestTargetIndex;
	local float ClosestTargetDistanceSquared;

	if(Action.AvailableTargets.Length == 1)
	{
		// easy case. If only one target, they are the closest
		DirectSetTarget(0);
	}
	else
	{
		// iterate over each target in the target list and select the closest one to the source 
		ClosestTargetIndex = -1;

		History = `XCOMHISTORY;
		WorldData = `XWORLD;

		SourceUnitLocation = WorldData.GetPositionFromTileCoordinates(UnitState.TileLocation);

		for (TargetIndex = 0; TargetIndex < Action.AvailableTargets.Length; TargetIndex++)
		{
			Target = X2GameRulesetVisibilityInterface(History.GetGameStateForObjectID(Action.AvailableTargets[TargetIndex].PrimaryTarget.ObjectID));
			`assert(Target != none);

			Target.GetKeystoneVisibilityLocation(TargetTile);
			TargetDistanceSquared = VSizeSq(WorldData.GetPositionFromTileCoordinates(TargetTile) - SourceUnitLocation);

			if(ClosestTargetIndex < 0 || TargetDistanceSquared < ClosestTargetDistanceSquared)
			{
				ClosestTargetIndex = TargetIndex;
				ClosestTargetDistanceSquared = TargetDistanceSquared;
			}
		}

		// we have a closest target now, so select it
		DirectSetTarget(ClosestTargetIndex);
	}
}

function Canceled()
{
	PathingPawn.Destroy();
	IconManager.ShowIcons(false);
	LevelBorderManager.ShowBorder(false);
	ExplosionEmitter.Destroy();

	`CAMERASTACK.RemoveCamera(TargetingCamera);
}

function Committed()
{
	Canceled();
}

function Update(float DeltaTime)
{
	IconManager.UpdateCursorLocation();
	LevelBorderManager.UpdateCursorLocation(Cursor.Location);
}

function NextTarget()
{
	DirectSetTarget(LastTarget + 1);
}

function DirectSetTarget(int TargetIndex)
{
	local XComPresentationLayer Pres;
	local UITacticalHUD TacticalHud;
	local XComGameStateHistory History;
	local XComGameState_BaseObject Target;

	// advance the target counter
	LastTarget = TargetIndex % Action.AvailableTargets.Length;

	// put the targeting reticle on the new target
	Pres = `PRES;
	TacticalHud = Pres.GetTacticalHUD();
	TacticalHud.TargetEnemy(LastTarget);

	// have the idle state machine look at the new target
	FiringUnit.IdleStateMachine.CheckForStanceUpdate();

	// have the pathing pawn draw a path to the target
	History = `XCOMHISTORY;
	Target = History.GetGameStateForObjectID(Action.AvailableTargets[LastTarget].PrimaryTarget.ObjectID);
	PathingPawn.UpdateMeleeTarget(Target);

	// remove any previous camera
	if(TargetingCamera != none)
	{
		`CAMERASTACK.RemoveCamera(TargetingCamera);
	}

	TargetUnit = XGUnit(Target.GetVisualizer());

	DrawSplashRadius();
	
	// create a midpoint targeting camera to frame the melee unit and his target
	TargetingCamera = new class'X2Camera_Midpoint';
	TargetingCamera.AddFocusActor(FiringUnit);
	TargetingCamera.AddFocusActor(Target.GetVisualizer());
	`CAMERASTACK.AddCamera(TargetingCamera);
}

function int GetTargetIndex()
{
	return LastTarget;
}

function bool GetPreAbilityPath(out array<TTile> PathTiles)
{
	PathingPawn.GetTargetMeleePath(PathTiles);
	return PathTiles.Length > 1;
}

function bool GetCurrentTargetFocus(out Vector Focus)
{
	local StateObjectReference Shooter;

	if( TargetUnit != None )
	{
		Shooter.ObjectID = TargetUnit.ObjectID;
		Focus = TargetUnit.GetShootAtLocation(eHit_Success, Shooter);
		return true;
	}
	
	return false;
}

simulated protected function Vector GetSplashRadiusCenter()
{
	local vector Center;
	local TTile SnapTile;

	GetCurrentTargetFocus(Center);

	if (SnapToTile)
	{
		SnapTile = `XWORLD.GetTileCoordinatesFromPosition( Center );
		`XWORLD.GetFloorPositionForTile( SnapTile, Center );
	}

	return Center;
}

simulated protected function DrawSplashRadius()
{
	local Vector Center;
	local float Radius;
	local LinearColor CylinderColor;

	Center = GetSplashRadiusCenter();
	Radius = Ability.GetAbilityRadius();

	if(ExplosionEmitter != none)
	{
		ExplosionEmitter.SetLocation(Center); // Set initial location of emitter
		ExplosionEmitter.SetDrawScale(Radius / 48.0f);
		ExplosionEmitter.SetRotation( rot(0,0,1) );

		if( !ExplosionEmitter.ParticleSystemComponent.bIsActive )
		{
			ExplosionEmitter.ParticleSystemComponent.ActivateSystem();			
		}

		ExplosionEmitter.ParticleSystemComponent.SetMICVectorParameter(0, Name("RadiusColor"), CylinderColor);
		ExplosionEmitter.ParticleSystemComponent.SetMICVectorParameter(1, Name("RadiusColor"), CylinderColor);
	}
}

defaultproperties
{
	ProvidesPath=true;
	SnapToTile=true;
}
