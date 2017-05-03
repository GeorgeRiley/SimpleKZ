/*
	Options
	
	Player options to customise their experience.
*/

// Set's all the player's option to default.
void OptionsSetupClient(int client)
{
	g_Style[client] = view_as<KZStyle>(GetConVarInt(gCV_DefaultStyle));
	g_ShowingTPMenu[client] = KZShowingTPMenu_Enabled;
	g_ShowingInfoPanel[client] = KZShowingInfoPanel_Enabled;
	g_ShowingKeys[client] = KZShowingKeys_Spectating;
	g_ShowingPlayers[client] = KZShowingPlayers_Enabled;
	g_ShowingWeapon[client] = KZShowingWeapon_Enabled;
	g_AutoRestart[client] = KZAutoRestart_Disabled;
	g_SlayOnEnd[client] = KZSlayOnEnd_Disabled;
	g_Pistol[client] = KZPistol_USP;
	g_CheckpointMessages[client] = KZCheckpointMessages_Disabled;
	g_CheckpointSounds[client] = KZCheckpointSounds_Enabled;
	g_TeleportSounds[client] = KZTeleportSounds_Disabled;
	g_ErrorSounds[client] = KZErrorSounds_Enabled;
	g_TimerText[client] = KZTimerText_InfoPanel;
	g_SpeedText[client] = KZSpeedText_InfoPanel;
}

// Returns the option value. Note: Returns an int, so you may need to use view_as<enum>().
int GetOption(int client, KZOption option)
{
	switch (option)
	{
		case KZOption_Style:return view_as<int>(g_Style[client]);
		case KZOption_ShowingTPMenu:return view_as<int>(g_ShowingTPMenu[client]);
		case KZOption_ShowingInfoPanel:return view_as<int>(g_ShowingInfoPanel[client]);
		case KZOption_ShowingKeys:return view_as<int>(g_ShowingKeys[client]);
		case KZOption_ShowingPlayers:return view_as<int>(g_ShowingPlayers[client]);
		case KZOption_ShowingWeapon:return view_as<int>(g_ShowingWeapon[client]);
		case KZOption_AutoRestart:return view_as<int>(g_AutoRestart[client]);
		case KZOption_SlayOnEnd:return view_as<int>(g_SlayOnEnd[client]);
		case KZOption_Pistol:return view_as<int>(g_Pistol[client]);
		case KZOption_CheckpointMessages:return view_as<int>(g_CheckpointMessages[client]);
		case KZOption_CheckpointSounds:return view_as<int>(g_CheckpointSounds[client]);
		case KZOption_TeleportSounds:return view_as<int>(g_TeleportSounds[client]);
		case KZOption_ErrorSounds:return view_as<int>(g_ErrorSounds[client]);
		case KZOption_TimerText:return view_as<int>(g_TimerText[client]);
		case KZOption_SpeedText:return view_as<int>(g_SpeedText[client]);
	}
	return -1;
}

// Sets the specified option of the client to the provided value (use the enumerations!)
void SetOption(int client, KZOption option, any optionValue, bool printMessage = true)
{
	bool changedOption = false;
	
	switch (option)
	{
		case KZOption_Style:
		{
			if (g_Style[client] != optionValue)
			{
				changedOption = true;
				g_Style[client] = optionValue;
			}
		}
		case KZOption_ShowingTPMenu:
		{
			if (g_ShowingTPMenu[client] != optionValue)
			{
				changedOption = true;
				g_ShowingTPMenu[client] = optionValue;
			}
		}
		case KZOption_ShowingInfoPanel:
		{
			if (g_ShowingInfoPanel[client] != optionValue)
			{
				changedOption = true;
				g_ShowingInfoPanel[client] = optionValue;
			}
		}
		case KZOption_ShowingKeys:
		{
			if (g_ShowingKeys[client] != optionValue)
			{
				changedOption = true;
				g_ShowingKeys[client] = optionValue;
			}
		}
		case KZOption_ShowingPlayers:
		{
			if (g_ShowingPlayers[client] != optionValue)
			{
				changedOption = true;
				g_ShowingPlayers[client] = optionValue;
			}
		}
		case KZOption_ShowingWeapon:
		{
			if (g_ShowingWeapon[client] != optionValue)
			{
				changedOption = true;
				g_ShowingWeapon[client] = optionValue;
			}
		}
		case KZOption_AutoRestart:
		{
			if (g_AutoRestart[client] != optionValue)
			{
				changedOption = true;
				g_AutoRestart[client] = optionValue;
			}
		}
		case KZOption_SlayOnEnd:
		{
			if (g_SlayOnEnd[client] != optionValue)
			{
				changedOption = true;
				g_SlayOnEnd[client] = optionValue;
			}
		}
		case KZOption_Pistol:
		{
			if (g_Pistol[client] != optionValue)
			{
				changedOption = true;
				g_Pistol[client] = optionValue;
			}
		}
		case KZOption_CheckpointMessages:
		{
			if (g_CheckpointMessages[client] != optionValue)
			{
				changedOption = true;
				g_CheckpointMessages[client] = optionValue;
			}
		}
		case KZOption_CheckpointSounds:
		{
			if (g_CheckpointSounds[client] != optionValue)
			{
				changedOption = true;
				g_CheckpointSounds[client] = optionValue;
			}
		}
		case KZOption_ErrorSounds:
		{
			if (g_ErrorSounds[client] != optionValue)
			{
				changedOption = true;
				g_ErrorSounds[client] = optionValue;
			}
		}
		case KZOption_TeleportSounds:
		{
			if (g_TeleportSounds[client] != optionValue)
			{
				changedOption = true;
				g_TeleportSounds[client] = optionValue;
			}
		}
		case KZOption_TimerText:
		{
			if (g_TimerText[client] != optionValue)
			{
				changedOption = true;
				g_TimerText[client] = optionValue;
			}
		}
		case KZOption_SpeedText:
		{
			if (g_SpeedText[client] != optionValue)
			{
				changedOption = true;
				g_SpeedText[client] = optionValue;
			}
		}
	}
	
	if (changedOption)
	{
		if (printMessage)
		{
			PrintOptionChangeMessage(client, option);
		}
		Call_SKZ_OnChangeOption(client, option, optionValue);
	}
}

// Steps through an option's possible settings.
void CycleOption(int client, KZOption option, bool printMessage = true)
{
	// Add 1 to the current value of the option
	// Modulo the result with the total number of that option which can be obtained by using view_as<int>(tag).
	switch (option)
	{
		case KZOption_Style:SetOption(client, option, (view_as<int>(g_Style[client]) + 1) % view_as<int>(KZStyle), printMessage);
		case KZOption_ShowingTPMenu:SetOption(client, option, (view_as<int>(g_ShowingTPMenu[client]) + 1) % view_as<int>(KZShowingTPMenu), printMessage);
		case KZOption_ShowingInfoPanel:SetOption(client, option, (view_as<int>(g_ShowingInfoPanel[client]) + 1) % view_as<int>(KZShowingInfoPanel), printMessage);
		case KZOption_ShowingKeys:SetOption(client, option, (view_as<int>(g_ShowingKeys[client]) + 1) % view_as<int>(KZShowingKeys), printMessage);
		case KZOption_ShowingPlayers:SetOption(client, option, (view_as<int>(g_ShowingPlayers[client]) + 1) % view_as<int>(KZShowingPlayers), printMessage);
		case KZOption_ShowingWeapon:SetOption(client, option, (view_as<int>(g_ShowingWeapon[client]) + 1) % view_as<int>(KZShowingWeapon), printMessage);
		case KZOption_AutoRestart:SetOption(client, option, (view_as<int>(g_AutoRestart[client]) + 1) % view_as<int>(KZAutoRestart), printMessage);
		case KZOption_SlayOnEnd:SetOption(client, option, (view_as<int>(g_SlayOnEnd[client]) + 1) % view_as<int>(KZSlayOnEnd), printMessage);
		case KZOption_Pistol:SetOption(client, option, (view_as<int>(g_Pistol[client]) + 1) % view_as<int>(KZPistol), printMessage);
		case KZOption_CheckpointMessages:SetOption(client, option, (view_as<int>(g_CheckpointMessages[client]) + 1) % view_as<int>(KZCheckpointMessages), printMessage);
		case KZOption_CheckpointSounds:SetOption(client, option, (view_as<int>(g_CheckpointSounds[client]) + 1) % view_as<int>(KZCheckpointSounds), printMessage);
		case KZOption_TeleportSounds:SetOption(client, option, (view_as<int>(g_TeleportSounds[client]) + 1) % view_as<int>(KZTeleportSounds), printMessage);
		case KZOption_ErrorSounds:SetOption(client, option, (view_as<int>(g_ErrorSounds[client]) + 1) % view_as<int>(KZErrorSounds), printMessage);
		case KZOption_TimerText:SetOption(client, option, (view_as<int>(g_TimerText[client]) + 1) % view_as<int>(KZTimerText), printMessage);
		case KZOption_SpeedText:SetOption(client, option, (view_as<int>(g_SpeedText[client]) + 1) % view_as<int>(KZSpeedText), printMessage);
	}
}



/*===============================  Static Functions  ===============================*/

// Prints a specific message when an option is changed.
static void PrintOptionChangeMessage(int client, KZOption option) {
	if (!IsClientInGame(client))
	{
		return;
	}
	
	// NOTE: Not all options have a message for when they are changed.
	switch (option)
	{
		case KZOption_Style:
		{
			CPrintToChat(client, "%t %t", "KZ Prefix", "Switched Style", gC_StylePhrases[g_Style[client]]);
		}
		case KZOption_ShowingTPMenu:
		{
			switch (g_ShowingTPMenu[client])
			{
				case KZShowingTPMenu_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Disable");
				}
				case KZShowingTPMenu_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Teleport Menu - Enable");
				}
			}
		}
		case KZOption_ShowingInfoPanel:
		{
			switch (g_ShowingInfoPanel[client])
			{
				case KZShowingInfoPanel_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Disable");
				}
				case KZShowingInfoPanel_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Info Panel - Enable");
				}
			}
		}
		case KZOption_ShowingPlayers:
		{
			switch (g_ShowingPlayers[client])
			{
				case KZShowingPlayers_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Disable");
				}
				case KZShowingPlayers_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Players - Enable");
				}
			}
		}
		case KZOption_ShowingWeapon:
		{
			switch (g_ShowingWeapon[client])
			{
				case KZShowingWeapon_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Disable");
				}
				case KZShowingWeapon_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Show Weapon - Enable");
				}
			}
		}
		case KZOption_AutoRestart:
		{
			switch (g_AutoRestart[client])
			{
				case KZAutoRestart_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Disable");
				}
				case KZAutoRestart_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Auto Restart - Enable");
				}
			}
		}
		case KZOption_SlayOnEnd:
		{
			switch (g_SlayOnEnd[client])
			{
				case KZSlayOnEnd_Disabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Disable");
				}
				case KZSlayOnEnd_Enabled:
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Option - Slay On End - Enable");
				}
			}
		}
	}
} 