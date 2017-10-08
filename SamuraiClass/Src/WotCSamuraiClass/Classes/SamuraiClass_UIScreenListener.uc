class SamuraiClass_UIScreenListener extends UIScreenListener config(XcomGameData_SoldierSkills);

var bool didUpdateTemplates;

// This event is triggered after a screen is initialized
event OnInit(UIScreen Screen)
{
    if(IsStrategyState())
    {
        if(!didUpdateTemplates)
        {
            AddHawkEyeTemplate();
            didUpdateTemplates = true;
        }   
    }
}

function AddHawkEyeTemplate()
{
  local X2StrategyElementTemplateManager templateManager;
  local X2FacilityTemplate Template;

  templateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

  Template = X2FacilityTemplate(templateManager.FindStrategyElementTemplate('OfficerTrainingSchool'));
  Template.SoldierUnlockTemplates.AddItem('HawkEye');

}

function bool IsStrategyState()
{
    return `HQGAME  != none && `HQPC != None && `HQPRES != none;
}

// This event is triggered after a screen receives focus
event OnReceiveFocus(UIScreen Screen);

// This event is triggered after a screen loses focus
event OnLoseFocus(UIScreen Screen);

// This event is triggered when a screen is removed
event OnRemoved(UIScreen Screen);

defaultproperties
{
	// Leaving this assigned to none will cause every screen to trigger its signals on this class
	ScreenClass = none;
}