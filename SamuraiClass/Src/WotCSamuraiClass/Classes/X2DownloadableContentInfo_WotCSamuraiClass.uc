class X2DownloadableContentInfo_WotCSamuraiClass extends X2DownloadableContentInfo
	config(SamuraiClass);

var config array<Name> IgnoreAbilitiesForShinigami;

/// <summary>
/// Called after the Templates have been created (but before they are validated) while this DLC / Mod is installed.
/// </summary>
static event OnPostTemplatesCreated()
{
	LogCrossClassAbilities();
	//AddSecondaryThrowingKnives();
	PatchAbilitiesForShinigami();
}

static function PatchAbilitiesForShinigami()
{
	local array<name> TemplateNames;
	local array<X2AbilityTemplate> AbilityTemplates;
	local name TemplateName;
	local X2AbilityTemplateManager AbilityMgr;
	local X2AbilityTemplate AbilityTemplate;
	local X2AbilityCost Cost;
	local X2AbilityCost_ActionPoints ActionPointCost;


	AbilityMgr = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	AbilityMgr.GetTemplateNames(TemplateNames);
	foreach TemplateNames(TemplateName)
	{
		if (default.IgnoreAbilitiesForShinigami.Find(TemplateName) != INDEX_NONE)
		{
			continue;
		}

		AbilityMgr.FindAbilityTemplateAllDifficulties(TemplateName, AbilityTemplates);
		foreach AbilityTemplates(AbilityTemplate)
		{
			if (!AbilityTemplate.IsMelee())
			{
				continue;
			}

			foreach AbilityTemplate.AbilityCosts(Cost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(Cost);
				if (ActionPointCost != None)
				{
					ActionPointCost.DoNotConsumeAllEffects.AddItem('SoulStealConsume');
				}
			}
		}
	}
}

static function LogCrossClassAbilities()
{
	local X2AbilityTemplateManager						TemplateManager;
	local X2AbilityTemplate								Template;
	local array<name>									TemplateNames;
	local name											TemplateName;
	
	TemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
	TemplateManager.GetTemplateNames(TemplateNames);
	foreach TemplateNames(TemplateName)
	{
		Template = TemplateManager.FindAbilityTemplate(TemplateName);
		if (Template.bCrossClassEligible)
		{
			`Log("AWC Ability:" @ TemplateName,, 'SamuraiClass');
		}
	}
}


static function AddSecondaryThrowingKnives()
{
	local X2ItemTemplateManager ItemTemplateManager;
	local array<X2DataTemplate> DifficultyVariants;
	local array<name> TemplateNames;
	local name TemplateName;
	local X2DataTemplate ItemTemplate;
	local X2WeaponTemplate WeaponTemplate, ClonedTemplate;
	local array<X2WeaponUpgradeTemplate> UpgradeTemplates;
	local X2WeaponUpgradeTemplate UpgradeTemplate;
	local WeaponAttachment UpgradeAttachment;
	local array<WeaponAttachment> UpgradeAttachmentsToAdd;
	
	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	UpgradeTemplates = ItemTemplateManager.GetAllUpgradeTemplates();

	ItemTemplateManager.GetTemplateNames(TemplateNames);

	foreach TemplateNames(TemplateName)
	{
		ItemTemplateManager.FindDataTemplateAllDifficulties(TemplateName, DifficultyVariants);
		// Iterate over all variants
		
		foreach DifficultyVariants(ItemTemplate)
		{
			ClonedTemplate = none;
			WeaponTemplate = X2WeaponTemplate(ItemTemplate);

			//`Log(WeaponTemplate.DataName @ WeaponTemplate.StowedLocation @ WeaponTemplate.WeaponCat, , 'PrimaryMeleeWeapons');

			if (WeaponTemplate.WeaponCat == 'throwingknife' && WeaponTemplate.InventorySlot == eInvSlot_Utility)
			{
				ClonedTemplate = new class'X2WeaponTemplate' (WeaponTemplate);
				ClonedTemplate.SetTemplateName(name(TemplateName $ "_Secondary"));
				ClonedTemplate.InventorySlot =  eInvSlot_SecondaryWeapon;
				ClonedTemplate.UIArmoryCameraPointTag = 'UIPawnLocation_WeaponUpgrade_Shotgun';
			
				// Generic attachments
				foreach UpgradeTemplates(UpgradeTemplate)
				{
					UpgradeAttachmentsToAdd.Length = 0;

					foreach UpgradeTemplate.UpgradeAttachments(UpgradeAttachment)
					{
						if (UpgradeAttachment.ApplyToWeaponTemplate == TemplateName)
						{
							UpgradeAttachment.ApplyToWeaponTemplate = name(TemplateName $ "_Primary");
							UpgradeAttachmentsToAdd.AddItem(UpgradeAttachment);
						}
					}

					foreach UpgradeAttachmentsToAdd(UpgradeAttachment)
					{
						//`Log("Adding Attachment" @ UpgradeAttachment.ApplyToWeaponTemplate @ UpgradeAttachment.AttachMeshName,, 'PrimarySecondaries');
						UpgradeTemplate.UpgradeAttachments.AddItem(UpgradeAttachment);
					}
				}
				
				ItemTemplateManager.AddItemTemplate(ClonedTemplate, true);
			}

		}

		if (ClonedTemplate != none)
		{
			`Log("Generating Template" @ TemplateName $ "_Secondary with" @ ClonedTemplate.DefaultAttachments.Length @ "default attachments",, 'SamuraiClass');
		}
	}

	ItemTemplateManager.LoadAllContent();
}
