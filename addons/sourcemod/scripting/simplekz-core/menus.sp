/*	menus.sp
	
	Menus in SimpleKZ.
*/


void CreateMenus() {
	CreateTPMenuAll();
	CreateOptionsMenuAll();
	CreateMovementStyleMenuAll();
	CreatePistolMenuAll();
	CreateMeasureMenuAll();
}


/*===============================  Teleport Menu  ===============================*/

static void CreateTPMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateTPMenu(client);
	}
}

static void CreateTPMenu(int client) {
	g_TPMenu[client] = new Menu(MenuHandler_TPMenu);
	g_TPMenu[client].OptionFlags = MENUFLAG_NO_SOUND;
	g_TPMenu[client].ExitButton = false;
}

void UpdateTPMenu(int client) {
	// Checks that no other menu instead of rudely interrupting it
	if (GetClientMenu(client) == MenuSource_None
		 && g_ShowingTPMenu[client] == KZShowingTPMenu_Enabled
		 && !gB_TPMenuIsShowing[client] && IsPlayerAlive(client)) {
		UpdateTPMenuItems(client, g_TPMenu[client]);
		g_TPMenu[client].Display(client, MENU_TIME_FOREVER);
		gB_TPMenuIsShowing[client] = true;
	}
}

void CloseTPMenu(int client) {
	if (gB_TPMenuIsShowing[client]) {
		CancelClientMenu(client);
		gB_TPMenuIsShowing[client] = false;
	}
}

static void UpdateTPMenuItems(int client, Menu menu) {
	menu.RemoveAllItems();
	AddItemsTPMenu(client, menu);
}

static void AddItemsTPMenu(int client, Menu menu) {
	AddItemTPMenuCheckpoint(client, menu);
	AddItemTPMenuTeleport(client, menu);
	AddItemTPMenuPause(client, menu);
	AddItemTPMenuStart(client, menu);
	AddItemTPMenuUndo(client, menu);
}

static void AddItemTPMenuCheckpoint(int client, Menu menu) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Checkpoint", client);
	menu.AddItem("", text, ITEMDRAW_DEFAULT);
}

static void AddItemTPMenuTeleport(int client, Menu menu) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Teleport", client);
	if (gI_CheckpointCount[client] > 0) {
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else {
		menu.AddItem("", text, ITEMDRAW_DISABLED);
	}
}

static void AddItemTPMenuUndo(int client, Menu menu) {
	char text[16];
	FormatEx(text, sizeof(text), "%T", "TP Menu - Undo TP", client);
	if (gI_TeleportsUsed[client] > 0 && gB_LastTeleportOnGround[client]) {
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else {
		menu.AddItem("", text, ITEMDRAW_DISABLED);
	}
}

static void AddItemTPMenuPause(int client, Menu menu) {
	char text[16];
	if (!gB_Paused[client]) {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Pause", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Resume", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
}

static void AddItemTPMenuStart(int client, Menu menu) {
	char text[16];
	if (gB_HasStartedThisMap[client]) {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Restart", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
	else {
		FormatEx(text, sizeof(text), "%T", "TP Menu - Respawn", client);
		menu.AddItem("", text, ITEMDRAW_DEFAULT);
	}
}

public int MenuHandler_TPMenu(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:MakeCheckpoint(param1);
			case 1:TeleportToCheckpoint(param1);
			case 2:TogglePause(param1);
			case 3:TeleportToStart(param1);
			case 4:UndoTeleport(param1);
		}
	}
	else if (action == MenuAction_Cancel) {
		gB_TPMenuIsShowing[param1] = false;
	}
}



/*===============================  Options Menu ===============================*/

void CreateOptionsMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateOptionsMenu(client);
	}
}

static void CreateOptionsMenu(int client) {
	g_OptionsMenu[client] = new Menu(MenuHandler_Options);
	g_OptionsMenu[client].Pagination = 6;
}

void DisplayOptionsMenu(int client, int atItem = 0) {
	UpdateOptionsMenu(client, g_OptionsMenu[client]);
	g_OptionsMenu[client].DisplayAt(client, atItem, MENU_TIME_FOREVER);
}

static void UpdateOptionsMenu(int client, Menu menu) {
	menu.SetTitle("%T", "Options Menu - Title", client);
	menu.RemoveAllItems();
	OptionsAddToggle(client, menu, g_ShowingTPMenu[client], "Options Menu - Teleport Menu");
	OptionsAddToggle(client, menu, g_ShowingInfoPanel[client], "Options Menu - Info Panel");
	OptionsAddToggle(client, menu, g_ShowingPlayers[client], "Options Menu - Show Players");
	OptionsAddToggle(client, menu, g_ShowingWeapon[client], "Options Menu - Show Weapon");
	OptionsAddToggle(client, menu, g_AutoRestart[client], "Options Menu - Auto Restart");
	OptionsAddPistol(client, menu);
	OptionsAddToggle(client, menu, g_SlayOnEnd[client], "Options Menu - Slay On End");
	OptionsAddToggle(client, menu, g_ShowingKeys[client], "Options Menu - Show Keys");
	OptionsAddToggle(client, menu, g_CheckpointMessages[client], "Options Menu - Checkpoint Messages");
	OptionsAddToggle(client, menu, g_CheckpointSounds[client], "Options Menu - Checkpoint Sounds");
	OptionsAddToggle(client, menu, g_TeleportSounds[client], "Options Menu - Teleport Sounds");
	OptionsAddTimerText(client, menu);
}

static void OptionsAddToggle(int client, Menu menu, any optionValue, const char[] optionPhrase) {
	char text[32];
	if (view_as<int>(optionValue) == 0) {
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Disabled", client);
	}
	else {
		FormatEx(text, sizeof(text), "%T - %T", optionPhrase, client, "Options Menu - Enabled", client);
	}
	
	menu.AddItem("", text);
}

static void OptionsAddPistol(int client, Menu menu) {
	char text[32];
	FormatEx(text, sizeof(text), "%T - %s", "Options Menu - Pistol", client, gC_Pistols[g_Pistol[client]][1]);
	menu.AddItem("", text);
}

static void OptionsAddTimerText(int client, Menu menu) {
	char text[32];
	FormatEx(text, sizeof(text), "%T - %T", "Options Menu - Timer Text", client, gC_TimerTextOptionPhrases[g_TimerText[client]], client);
	menu.AddItem("", text);
}

public int MenuHandler_Options(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:IncrementOption(param1, KZOption_ShowingTPMenu);
			case 1:IncrementOption(param1, KZOption_ShowingInfoPanel);
			case 2:IncrementOption(param1, KZOption_ShowingPlayers);
			case 3:IncrementOption(param1, KZOption_ShowingWeapon);
			case 4:IncrementOption(param1, KZOption_AutoRestart);
			case 5: {
				gB_CameFromOptionsMenu[param1] = true;
				DisplayPistolMenu(param1);
			}
			case 6:IncrementOption(param1, KZOption_SlayOnEnd);
			case 7:IncrementOption(param1, KZOption_ShowingKeys);
			case 8:IncrementOption(param1, KZOption_CheckpointMessages);
			case 9:IncrementOption(param1, KZOption_CheckpointSounds);
			case 10:IncrementOption(param1, KZOption_TeleportSounds);
			case 11:IncrementOption(param1, KZOption_TimerText);
		}
		if (param2 != 5) {
			// Reopen the menu at the same place
			DisplayOptionsMenu(param1, param2 / 6 * 6); // Round item number down to multiple of 6
		}
	}
}



/*===============================  Movement Style Menu  ===============================*/

void CreateMovementStyleMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateMovementStyleMenu(client);
	}
}

void CreateMovementStyleMenu(int client) {
	gH_MovementStyleMenu[client] = CreateMenu(MenuHandler_MovementStyle);
}

void DisplayMovementStyleMenu(int client) {
	SetMenuTitle(gH_MovementStyleMenu[client], "%T", "Style Menu - Title", client);
	AddItemsMovementStyleMenu(client);
	DisplayMenu(gH_MovementStyleMenu[client], client, MENU_TIME_FOREVER);
}

void AddItemsMovementStyleMenu(int client) {
	char text[32];
	RemoveAllMenuItems(gH_MovementStyleMenu[client]);
	for (int style = 0; style < view_as<int>(KZStyle); style++) {
		FormatEx(text, sizeof(text), "%T", gC_StylePhrases[style], client);
		AddMenuItem(gH_MovementStyleMenu[client], "", text, ITEMDRAW_DEFAULT);
	}
}

public int MenuHandler_MovementStyle(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0:SetOption(param1, KZOption_Style, KZStyle_Standard);
			case 1:SetOption(param1, KZOption_Style, KZStyle_Legacy);
		}
	}
}



/*===============================  Pistol Menu ===============================*/

void CreatePistolMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreatePistolMenu(client);
	}
}

void CreatePistolMenu(int client) {
	gH_PistolMenu[client] = CreateMenu(MenuHandler_Pistol);
}

void DisplayPistolMenu(int client) {
	DisplayMenu(gH_PistolMenu[client], client, MENU_TIME_FOREVER);
}

void UpdatePistolMenu(int client) {
	SetMenuTitle(gH_PistolMenu[client], "%T", "Pistol Menu - Title", client);
	RemoveAllMenuItems(gH_PistolMenu[client]);
	for (int pistol = 0; pistol < sizeof(gC_Pistols); pistol++) {
		AddMenuItem(gH_PistolMenu[client], "", gC_Pistols[pistol][1]);
	}
}

public int MenuHandler_Pistol(Menu menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		g_Pistol[param1] = view_as<KZPistol>(param2);
		GivePlayerPistol(param1, view_as<KZPistol>(param2));
		DisplayPistolMenu(param1);
	}
	else if (action == MenuAction_Cancel && gB_CameFromOptionsMenu[param1]) {
		gB_CameFromOptionsMenu[param1] = false;
		DisplayOptionsMenu(param1);
	}
}



/*===============================  Measure Menu ===============================*/
// Credits to DaFox (https://forums.alliedmods.net/showthread.php?t=88830?t=88830)

void CreateMeasureMenuAll() {
	for (int client = 1; client <= MaxClients; client++) {
		CreateMeasureMenu(client);
	}
}

void CreateMeasureMenu(int client) {
	gH_MeasureMenu[client] = CreateMenu(MenuHandler_Measure);
}

void DisplayMeasureMenu(int client) {
	DisplayMenu(gH_MeasureMenu[client], client, MENU_TIME_FOREVER);
}

void UpdateMeasureMenu(int client) {
	SetMenuTitle(gH_MeasureMenu[client], "%T", "Measure Menu - Title", client);
	
	char text[32];
	RemoveAllMenuItems(gH_MeasureMenu[client]);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point A", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Point B", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
	FormatEx(text, sizeof(text), "%T", "Measure Menu - Get Distance", client);
	AddMenuItem(gH_MeasureMenu[client], "", text);
}

public int MenuHandler_Measure(Handle menu, MenuAction action, int param1, int param2) {
	if (action == MenuAction_Select) {
		switch (param2) {
			case 0: {  //Point A (Green)
				MeasureGetPos(param1, 0);
			}
			case 1: {  //Point B (Red)
				MeasureGetPos(param1, 1);
			}
			case 2: {  //Find Distance
				if (gB_MeasurePosSet[param1][0] && gB_MeasurePosSet[param1][1]) {
					float vDist = GetVectorDistance(gF_MeasurePos[param1][0], gF_MeasurePos[param1][1]);
					float vHightDist = (gF_MeasurePos[param1][1][2] - gF_MeasurePos[param1][0][2]);
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Result", vDist, vHightDist);
					MeasureBeam(param1, gF_MeasurePos[param1][0], gF_MeasurePos[param1][1], 5.0, 2.0, 200, 200, 200);
				}
				else {
					CPrintToChat(param1, "%t %t", "KZ Prefix", "Measure Failure (Points Not Set)");
				}
			}
		}
		DisplayMenu(gH_MeasureMenu[param1], param1, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel) {
		MeasureResetPos(param1);
	}
}

void MeasureGetPos(int client, int arg) {
	float origin[3];
	float angles[3];
	
	GetClientEyePosition(client, origin);
	GetClientEyeAngles(client, angles);
	
	Handle trace = TR_TraceRayFilterEx(origin, angles, MASK_SHOT, RayType_Infinite, TraceFilterPlayers, client);
	
	if (!TR_DidHit(trace)) {
		CloseHandle(trace);
		CPrintToChat(client, "%t %t", "KZ Prefix", "Measure Failure (Not Aiming at Solid)");
		return;
	}
	
	TR_GetEndPosition(origin, trace);
	CloseHandle(trace);
	
	gF_MeasurePos[client][arg][0] = origin[0];
	gF_MeasurePos[client][arg][1] = origin[1];
	gF_MeasurePos[client][arg][2] = origin[2];
	
	if (arg == 0) {
		if (gH_P2PRed[client] != INVALID_HANDLE) {
			CloseHandle(gH_P2PRed[client]);
			gH_P2PRed[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][0] = true;
		gH_P2PRed[client] = CreateTimer(1.0, Timer_P2PRed, client, TIMER_REPEAT);
		P2PXBeam(client, 0);
	}
	else {
		if (gH_P2PGreen[client] != INVALID_HANDLE) {
			CloseHandle(gH_P2PGreen[client]);
			gH_P2PGreen[client] = INVALID_HANDLE;
		}
		gB_MeasurePosSet[client][1] = true;
		P2PXBeam(client, 1);
		gH_P2PGreen[client] = CreateTimer(1.0, Timer_P2PGreen, client, TIMER_REPEAT);
	}
}

public Action Timer_P2PRed(Handle timer, int client) {
	if (IsValidClient(client)) {
		P2PXBeam(client, 0);
	}
}

public Action Timer_P2PGreen(Handle timer, int client) {
	if (IsValidClient(client)) {
		P2PXBeam(client, 1);
	}
}

void P2PXBeam(int client, int arg) {
	float Origin0[3];
	float Origin1[3];
	float Origin2[3];
	float Origin3[3];
	
	Origin0[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin0[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin0[2] = gF_MeasurePos[client][arg][2];
	
	Origin1[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin1[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin1[2] = gF_MeasurePos[client][arg][2];
	
	Origin2[0] = (gF_MeasurePos[client][arg][0] + 8.0);
	Origin2[1] = (gF_MeasurePos[client][arg][1] - 8.0);
	Origin2[2] = gF_MeasurePos[client][arg][2];
	
	Origin3[0] = (gF_MeasurePos[client][arg][0] - 8.0);
	Origin3[1] = (gF_MeasurePos[client][arg][1] + 8.0);
	Origin3[2] = gF_MeasurePos[client][arg][2];
	
	if (arg == 0) {
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 0, 255, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 0, 255, 0);
	}
	else {
		MeasureBeam(client, Origin0, Origin1, 0.97, 2.0, 255, 0, 0);
		MeasureBeam(client, Origin2, Origin3, 0.97, 2.0, 255, 0, 0);
	}
}

void MeasureBeam(int client, float vecStart[3], float vecEnd[3], float life, float width, int r, int g, int b) {
	TE_Start("BeamPoints");
	TE_WriteNum("m_nModelIndex", gI_GlowSprite);
	TE_WriteNum("m_nHaloIndex", 0);
	TE_WriteNum("m_nStartFrame", 0);
	TE_WriteNum("m_nFrameRate", 0);
	TE_WriteFloat("m_fLife", life);
	TE_WriteFloat("m_fWidth", width);
	TE_WriteFloat("m_fEndWidth", width);
	TE_WriteNum("m_nFadeLength", 0);
	TE_WriteFloat("m_fAmplitude", 0.0);
	TE_WriteNum("m_nSpeed", 0);
	TE_WriteNum("r", r);
	TE_WriteNum("g", g);
	TE_WriteNum("b", b);
	TE_WriteNum("a", 255);
	TE_WriteNum("m_nFlags", 0);
	TE_WriteVector("m_vecStartPoint", vecStart);
	TE_WriteVector("m_vecEndPoint", vecEnd);
	TE_SendToClient(client);
}

void MeasureResetPos(int client) {
	if (gH_P2PRed[client] != INVALID_HANDLE) {
		CloseHandle(gH_P2PRed[client]);
		gH_P2PRed[client] = INVALID_HANDLE;
	}
	if (gH_P2PGreen[client] != INVALID_HANDLE) {
		CloseHandle(gH_P2PGreen[client]);
		gH_P2PGreen[client] = INVALID_HANDLE;
	}
	gB_MeasurePosSet[client][0] = false;
	gB_MeasurePosSet[client][1] = false;
	
	gF_MeasurePos[client][0][0] = 0.0; //This is stupid.
	gF_MeasurePos[client][0][1] = 0.0;
	gF_MeasurePos[client][0][2] = 0.0;
	gF_MeasurePos[client][1][0] = 0.0;
	gF_MeasurePos[client][1][1] = 0.0;
	gF_MeasurePos[client][1][2] = 0.0;
}

public bool TraceFilterPlayers(int entity, int contentsMask) {
	return (entity > MaxClients);
} 