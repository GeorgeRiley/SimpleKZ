/*
	Pistol Menu
	
	Lets players view and set options.
*/

void OptionsMenuCreateMenus()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		OptionsMenuCreate(client);
	}
}

void OptionsMenuDisplay(int client, int atItem = 0)
{
	OptionsMenuUpdate(client, g_OptionsMenu[client]);
	g_OptionsMenu[client].DisplayAt(client, atItem, MENU_TIME_FOREVER);
}



/*===============================  Public Callbacks  ===============================*/

public int MenuHandler_Options(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:CycleOption(param1, KZOption_ShowingTPMenu, false);
			case 1:CycleOption(param1, KZOption_ShowingInfoPanel, false);
			case 2:CycleOption(param1, KZOption_TimerText, false);
			case 3:CycleOption(param1, KZOption_SpeedText, false);
			case 4:CycleOption(param1, KZOption_ShowingKeys, false);
			case 5:CycleOption(param1, KZOption_ShowingPlayers, false);
			case 6:CycleOption(param1, KZOption_CheckpointMessages, false);
			case 7:CycleOption(param1, KZOption_CheckpointSounds, false);
			case 8:CycleOption(param1, KZOption_TeleportSounds, false);
			case 9:CycleOption(param1, KZOption_ErrorSounds, false);
			case 10:CycleOption(param1, KZOption_ShowingWeapon, false);
			case 11:
			{
				gB_CameFromOptionsMenu[param1] = true;
				PistolMenuDisplay(param1);
			}
			case 12:CycleOption(param1, KZOption_AutoRestart, true);
			case 13:CycleOption(param1, KZOption_SlayOnEnd, true);
		}
		if (param2 != 11) // Pistol
		{
			// Reopen the menu at the same place
			OptionsMenuDisplay(param1, param2 / 6 * 6); // Round item number down to multiple of 6
		}
	}
}



/*===============================  Static Functions  ===============================*/

static void OptionsMenuCreate(int client)
{
	g_OptionsMenu[client] = new Menu(MenuHandler_Options);
	g_OptionsMenu[client].Pagination = 6;
}

static void OptionsMenuUpdate(int client, Menu menu)
{
	menu.SetTitle("%T", "Options Menu - Title", client);
	menu.RemoveAllItems();
	OptionsMenuAddToggle(client, menu, g_ShowingTPMenu[client], "Options Menu - Teleport Menu");
	OptionsMenuAddToggle(client, menu, g_ShowingInfoPanel[client], "Options Menu - Info Panel");
	OptionsMenuAddTimerText(client, menu);
	OptionsMenuAddSpeedText(client, menu);
	OptionsMenuAddShowingKeys(client, menu);
	OptionsMenuAddToggle(client, menu, g_ShowingPlayers[client], "Options Menu - Show Players");
	OptionsMenuAddToggle(client, menu, g_CheckpointMessages[client], "Options Menu - Checkpoint Messages");
	OptionsMenuAddToggle(client, menu, g_CheckpointSounds[client], "Options Menu - Checkpoint Sounds");
	OptionsMenuAddToggle(client, menu, g_TeleportSounds[client], "Options Menu - Teleport Sounds");
	OptionsMenuAddToggle(client, menu, g_ErrorSounds[client], "Options Menu - Error Sounds");
	OptionsMenuAddToggle(client, menu, g_ShowingWeapon[client], "Options Menu - Show Weapon");
	OptionsMenuAddPistol(client, menu);
	OptionsMenuAddToggle(client, menu, g_AutoRestart[client], "Options Menu - Auto Restart");
	OptionsMenuAddToggle(client, menu, g_SlayOnEnd[client], "Options Menu - Slay On End");
}

static void OptionsMenuAddToggle(int client, Menu menu, any optionValue, const char[] optionPhrase)
{
	char text[32];
	if (view_as<int>(optionValue) == 0)
	{
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Disabled", client);
	}
	else
	{
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Enabled", client);
	}
	menu.AddItem("", text);
}

static void OptionsMenuAddPistol(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %s", "Options Menu - Pistol", client, gC_Pistols[g_Pistol[client]][1]);
	menu.AddItem("", text);
}

static void OptionsMenuAddShowingKeys(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Show Keys", client, gC_ShowingKeysOptionPhrases[g_ShowingKeys[client]], client);
	menu.AddItem("", text);
}

static void OptionsMenuAddTimerText(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Timer Text", client, gC_TimerTextOptionPhrases[g_TimerText[client]], client);
	menu.AddItem("", text);
}

static void OptionsMenuAddSpeedText(int client, Menu menu)
{
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Speed Text", client, gC_SpeedTextOptionPhrases[g_SpeedText[client]], client);
	menu.AddItem("", text);
} 