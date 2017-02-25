/*	commands.sp
	
	Commands for player use.
*/


void RegisterCommands() {
	RegConsoleCmd("sm_maprank", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <map> <player>");
	RegConsoleCmd("sm_pb", CommandMapRank, "[KZ] Prints map time and rank to chat. Usage: !maprank <map> <player>");
	RegConsoleCmd("sm_maprecord", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_wr", CommandMapRecord, "[KZ] Prints map record times to chat. Usage: !maprecord <map>");
	RegConsoleCmd("sm_maptop", CommandMapTop, "[KZ] Opens a menu showing the top times of a map. Usage !maptop <map>");
	RegConsoleCmd("sm_completion", CommandCompletion, "[KZ] Prints map completion to chat. Usage !completion <player>");
	RegConsoleCmd("sm_pc", CommandCompletion, "[KZ] Prints map completion to chat. Usage !completion <player>");
	RegConsoleCmd("sm_top", CommandPlayerTop, "[KZ] Opens a menu showing the top record holders on the server.");
	
	RegAdminCmd("sm_updatemappool", CommandUpdateMapPool, ADMFLAG_ROOT, "[KZ] Updates the ranked map pool with the list of maps in cfg/sourcemod/SimpleKZ/mappool.cfg.");
}



/*===============================  Command Handlers  ===============================*/

public Action CommandMapRank(int client, int args) {
	if (args < 1) {
		char currentMap[64];
		SimpleKZ_GetCurrentMap(currentMap, sizeof(currentMap));
		DB_PrintPBs(client, client, currentMap, SimpleKZ_GetMovementStyle(client));
	}
	else if (args == 1) {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintPBs(client, client, specifiedMap, SimpleKZ_GetMovementStyle(client));
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(2, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_PrintPBs(client, target, specifiedMap, SimpleKZ_GetMovementStyle(client));
		}
	}
	return Plugin_Handled;
}

public Action CommandMapRecord(int client, int args) {
	if (args < 1) {
		char currentMap[64];
		SimpleKZ_GetCurrentMap(currentMap, sizeof(currentMap));
		DB_PrintMapRecords(client, currentMap, SimpleKZ_GetMovementStyle(client));
	}
	else {
		char specifiedMap[33];
		GetCmdArg(1, specifiedMap, sizeof(specifiedMap));
		DB_PrintMapRecords(client, specifiedMap, SimpleKZ_GetMovementStyle(client));
	}
	return Plugin_Handled;
}

public Action CommandMapTop(int client, int args) {
	if (args < 1) {
		char currentMap[64];
		SimpleKZ_GetCurrentMap(currentMap, sizeof(currentMap));
		gC_MapTopMap[client] = currentMap;
	}
	else {
		GetCmdArg(1, gC_MapTopMap[client], sizeof(gC_MapTopMap[]));
	}
	DB_OpenMapTop(client, gC_MapTopMap[client], SimpleKZ_GetMovementStyle(client));
	return Plugin_Handled;
}

public Action CommandCompletion(int client, int args) {
	if (args < 1) {
		DB_GetCompletion(client, client, SimpleKZ_GetMovementStyle(client), true);
	}
	else {
		char specifiedPlayer[MAX_NAME_LENGTH];
		GetCmdArg(1, specifiedPlayer, sizeof(specifiedPlayer));
		
		int target = FindTarget(client, specifiedPlayer, true, false);
		if (target != -1) {
			DB_GetCompletion(client, target, SimpleKZ_GetMovementStyle(client), true);
		}
	}
	return Plugin_Handled;
}

public Action CommandPlayerTop(int client, int args) {
	g_PlayerTopStyle[client] = SimpleKZ_GetMovementStyle(client);
	DisplayPlayerTopMenu(client);
	return Plugin_Handled;
}



/*===============================  Command Handlers  ===============================*/

public Action CommandUpdateMapPool(int client, int args) {
	DB_UpdateMapPool(client);
} 