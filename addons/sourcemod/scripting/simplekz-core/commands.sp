/*
	Commands
	
	Commands for player and admin use.
*/

void CreateCommands()
{
	RegConsoleCmd("sm_menu", CommandToggleMenu, "[KZ] Toggle the visibility of the teleport menu.");
	RegConsoleCmd("sm_checkpoint", CommandMakeCheckpoint, "[KZ] Set your checkpoint.");
	RegConsoleCmd("sm_gocheck", CommandTeleportToCheckpoint, "[KZ] Teleport to your checkpoint.");
	RegConsoleCmd("sm_undo", CommandUndoTeleport, "[KZ] Undo teleport.");
	RegConsoleCmd("sm_start", CommandTeleportToStart, "[KZ] Teleport to the start of the map.");
	RegConsoleCmd("sm_r", CommandTeleportToStart, "[KZ] Teleport to the start of the map.");
	RegConsoleCmd("sm_pause", CommandTogglePause, "[KZ] Toggle pausing your timer and stopping you in your position.");
	RegConsoleCmd("sm_resume", CommandTogglePause, "[KZ] Toggle pausing your timer and stopping you in your position.");
	RegConsoleCmd("sm_stop", CommandStopTimer, "[KZ] Stop your timer.");
	RegConsoleCmd("sm_stopsound", CommandStopSound, "[KZ] Stop all sounds e.g. map soundscapes (music).");
	RegConsoleCmd("sm_goto", CommandGoto, "[KZ] Teleport to another player. Usage: !goto <player>");
	RegConsoleCmd("sm_spec", CommandSpec, "[KZ] Spectate another player. Usage: !spec <player>");
	RegConsoleCmd("sm_options", CommandOptions, "[KZ] Open up the options menu.");
	RegConsoleCmd("sm_hide", CommandToggleShowPlayers, "[KZ] Toggle hiding other players.");
	RegConsoleCmd("sm_speed", CommandToggleInfoPanel, "[KZ] Toggle visibility of the centre information panel.");
	RegConsoleCmd("sm_hideweapon", CommandToggleShowWeapon, "[KZ] Toggle visibility of your weapon.");
	RegConsoleCmd("sm_measure", CommandMeasureMenu, "[KZ] Open the measurement menu.");
	RegConsoleCmd("sm_pistol", CommandPistolMenu, "[KZ] Open the pistol selection menu.");
	RegConsoleCmd("sm_nc", CommandToggleNoclip, "[KZ] Toggle noclip.");
	RegConsoleCmd("+noclip", CommandEnableNoclip, "[KZ] Noclip on.");
	RegConsoleCmd("-noclip", CommandDisableNoclip, "[KZ] Noclip off.");
	RegConsoleCmd("sm_style", CommandStyle, "[KZ] Open the movement style menu.");
	RegConsoleCmd("sm_standard", CommandStandard, "[KZ] Switch to the Standard style.");
	RegConsoleCmd("sm_s", CommandStandard, "[KZ] Switch to the Standard style.");
	RegConsoleCmd("sm_legacy", CommandLegacy, "[KZ] Switch to the Legacy style.");
	RegConsoleCmd("sm_l", CommandLegacy, "[KZ] Switch to the Legacy style.");
	RegConsoleCmd("sm_comp", CommandCompetitive, "[KZ] Switch to the Competitive style.");
	RegConsoleCmd("sm_c", CommandCompetitive, "[KZ] Switch to the Competitive style.");
}



/*===============================  Command Listener Handlers  ===============================*/

public Action CommandBlock(int client, const char[] command, int argc)
{
	return Plugin_Handled;
}

// Allow unlimited team changes
public Action CommandJoinTeam(int client, const char[] command, int argc)
{
	char teamString[4];
	GetCmdArgString(teamString, sizeof(teamString));
	int team = StringToInt(teamString);
	JoinTeam(client, team);
	return Plugin_Handled;
}



/*===============================  Command Handlers  ===============================*/

public Action CommandToggleMenu(int client, int args)
{
	CycleOption(client, KZOption_ShowingTPMenu);
	return Plugin_Handled;
}

public Action CommandMakeCheckpoint(int client, int args)
{
	MakeCheckpoint(client);
	TPMenuUpdate(client);
	return Plugin_Handled;
}

public Action CommandTeleportToCheckpoint(int client, int args)
{
	TeleportToCheckpoint(client);
	TPMenuUpdate(client);
	return Plugin_Handled;
}

public Action CommandUndoTeleport(int client, int args)
{
	UndoTeleport(client);
	TPMenuUpdate(client);
	return Plugin_Handled;
}

public Action CommandTeleportToStart(int client, int args)
{
	TeleportToStart(client);
	TPMenuUpdate(client);
	return Plugin_Handled;
}

public Action CommandTogglePause(int client, int args)
{
	if (GetClientTeam(client) == CS_TEAM_SPECTATOR)
	{
		JoinTeam(client, CS_TEAM_CT);
	}
	else
	{
		TogglePause(client);
	}
	TPMenuUpdate(client);
	return Plugin_Handled;
}

public Action CommandStopTimer(int client, int args)
{
	if (TimerForceStopCommand(client))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped");
	}
	return Plugin_Handled;
}

public Action CommandStopSound(int client, int args)
{
	StopSounds(client);
	return Plugin_Handled;
}

public Action CommandGoto(int client, int args)
{
	// If no arguments, respond with error message
	if (args < 1)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Failure (Didn't Specify Player)");
	}
	// Otherwise try to teleport to the player
	else
	{
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		if (target != -1)
		{
			if (target == client)
			{
				CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Failure (Not Yourself)");
			}
			else if (!IsPlayerAlive(target))
			{
				CPrintToChat(client, "%t %t", "KZ Prefix", "Goto Failure (Dead)");
			}
			else
			{
				GotoPlayer(client, target);
				if (gB_TimerRunning[client])
				{
					CPrintToChat(client, "%t %t", "KZ Prefix", "Time Stopped (Goto)");
				}
				SKZ_ForceStopTimer(client);
			}
		}
	}
	return Plugin_Handled;
}

public Action CommandSpec(int client, int args)
{
	// If no arguments, just join spectators
	if (args < 1)
	{
		JoinTeam(client, CS_TEAM_SPECTATOR);
	}
	// Otherwise try to spectate the player
	else
	{
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, false, false);
		if (target != -1)
		{
			if (target == client)
			{
				CPrintToChat(client, "%t %t", "KZ Prefix", "Spectate Failure (Not Yourself)");
			}
			else if (!IsPlayerAlive(target))
			{
				CPrintToChat(client, "%t %t", "KZ Prefix", "Spectate Failure (Dead)");
			}
			else
			{
				JoinTeam(client, CS_TEAM_SPECTATOR);
				SetEntProp(client, Prop_Send, "m_iObserverMode", 4);
				SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", target);
			}
		}
	}
	return Plugin_Handled;
}

public Action CommandOptions(int client, int args)
{
	OptionsMenuDisplay(client);
	return Plugin_Handled;
}

public Action CommandToggleShowPlayers(int client, int args)
{
	CycleOption(client, KZOption_ShowingPlayers);
	return Plugin_Handled;
}

public Action CommandToggleInfoPanel(int client, int args)
{
	CycleOption(client, KZOption_ShowingInfoPanel);
	return Plugin_Handled;
}

public Action CommandToggleShowWeapon(int client, int args)
{
	CycleOption(client, KZOption_ShowingWeapon);
	return Plugin_Handled;
}

public Action CommandMeasureMenu(int client, int args)
{
	MeasureMenuDisplay(client);
	return Plugin_Handled;
}

public Action CommandPistolMenu(int client, int args)
{
	PistolMenuDisplay(client);
	return Plugin_Handled;
}

public Action CommandToggleNoclip(int client, int args)
{
	ToggleNoclip(client);
	return Plugin_Handled;
}

public Action CommandEnableNoclip(int client, int args)
{
	g_KZPlayer[client].moveType = MOVETYPE_NOCLIP;
	return Plugin_Handled;
}

public Action CommandDisableNoclip(int client, int args)
{
	g_KZPlayer[client].moveType = MOVETYPE_WALK;
	return Plugin_Handled;
}

public Action CommandStyle(int client, int args)
{
	StyleMenuDisplay(client);
	return Plugin_Handled;
}

public Action CommandStandard(int client, int args)
{
	SetOption(client, KZOption_Style, KZStyle_Standard);
	return Plugin_Handled;
}

public Action CommandLegacy(int client, int args)
{
	SetOption(client, KZOption_Style, KZStyle_Legacy);
	return Plugin_Handled;
}

public Action CommandCompetitive(int client, int args)
{
	SetOption(client, KZOption_Style, KZStyle_Competitive);
	return Plugin_Handled;
} 