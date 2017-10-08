class SamuraiClass_Effect_SoulSteal extends X2Effect_Persistent
	 config(SamuraiClass);

var config float SOUL_STEAL_ADD_CHARGES_PER_KILL;
var config float SOUL_STEAL_ADD_TOTALCOUNT_PER_KILL;

var name KillCountName;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
	local X2EventManager EventMgr;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent(EffectObj, 'UnitDied', class'SamuraiClass_Effect_SoulSteal'.static.SoulStealKillCheck, ELD_OnStateSubmitted);
	EventMgr.RegisterForEvent(EffectObj, 'UnitMoveFinished', class'SamuraiClass_Effect_SoulSteal'.static.OnUnitMoveFinished, ELD_OnStateSubmitted);
}

static function EventListenerReturn OnUnitMoveFinished(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit UnitState;
	
	UnitState = XComGameState_Unit(EventData);
	if (UnitState != none)
	{
		UnitState.SetUnitFloatValue('UnitHasMoved', 1, eCleanup_BeginTurn);
	}
	return ELR_NoInterrupt;
}

static function EventListenerReturn SoulStealKillCheck(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability		   AbilityState;
	local XComGameState_Unit           UnitState, DeadUnitState;
	local StateObjectReference         AbilityRef;
	local X2AbilityTemplate            AbilityTemplate;
	local XComGameState                NewGameState;
	local UnitValue                    SoulStealKillCount, SoulStealKillCountTotal;
	local float                        NewKillCountTotal, NewKillCount;
	
	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());

	//  was this a melee kill made by the soul steal unit? if so, add to killcount
	if (AbilityContext != None) //  && EventData.ApplyEffectParameters.SourceStateObjectRef == AbilityContext.InputContext.SourceObject
	{
		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
		if (AbilityTemplate != none && AbilityTemplate.IsMelee())
		{
			// Find Killer and Victim
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
			DeadUnitState = XComGameState_Unit(EventSource);
			
			// Find SamuraiSoulStealConsumeSoul ability
			AbilityRef = UnitState.FindAbility('SamuraiSoulStealConsumeSoul');
			AbilityState = XComGameState_Ability(`XCOMHISTORY.GetGameStateForObjectID(AbilityRef.ObjectID));

			if(AbilityState != none && AbilityState.GetMyTemplateName() == 'SamuraiSoulStealConsumeSoul')
			{
				if (class'X2Ability_TemplarAbilitySet'.default.FocusKillAbilities.Find(AbilityContext.InputContext.AbilityTemplateName) != INDEX_NONE)
				{
					// Get old KillCount value
					UnitState.GetUnitValue('SoulStealKillCount', SoulStealKillCount);
					UnitState.GetUnitValue('SoulStealKillCountTotal', SoulStealKillCountTotal);
			
					NewKillCount = SoulStealKillCount.fValue + default.SOUL_STEAL_ADD_CHARGES_PER_KILL;
					NewKillCountTotal = SoulStealKillCountTotal.fValue + default.SOUL_STEAL_ADD_TOTALCOUNT_PER_KILL;
			
					NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState(string(GetFuncName()));
					XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = SoulStealKillVisualizationFn;
			
					UnitState = XComGameState_Unit(NewGameState.CreateStateObject(UnitState.Class, UnitState.ObjectID));
					UnitState.SetUnitFloatValue('SoulStealKillCount', NewKillCount, eCleanup_BeginTactical);
					UnitState.SetUnitFloatValue('SoulStealKillCountTotal', NewKillCountTotal, eCleanup_Never);

					//NewKillCount = int((NewKillCount + 1)/2);
					AbilityState.iCharges = NewKillCount;
					`COMBATLOG("SoulStealKillCount:" @ NewKillCount @ "NewKillCountTotal" @ NewKillCountTotal);

					NewGameState.AddStateObject(AbilityState);
					NewGameState.AddStateObject(UnitState);
					`TACTICALRULES.SubmitGameState(NewGameState);
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

function SoulStealKillVisualizationFn(XComGameState VisualizeGameState)
{
	local XComGameState_Unit UnitState;
	local X2Action_PlaySoundAndFlyOver SoundAndFlyOver;
	local VisualizationActionMetadata ActionMetaData;
	local XComGameStateHistory History;
	local X2AbilityTemplate AbilityTemplate;

	History = `XCOMHISTORY;
	foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
	{
		History.GetCurrentAndPreviousGameStatesForObjectID(UnitState.ObjectID, ActionMetaData.StateObject_OldState, ActionMetaData.StateObject_NewState, , VisualizeGameState.HistoryIndex);
		ActionMetaData.StateObject_NewState = UnitState;
		ActionMetaData.VisualizeActor = UnitState.GetVisualizer();

		AbilityTemplate = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager().FindAbilityTemplate('SamuraiSoulSteal');

		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetaData, VisualizeGameState.GetContext()));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', eColor_Good, AbilityTemplate.IconImage);

		break;
	}
}
