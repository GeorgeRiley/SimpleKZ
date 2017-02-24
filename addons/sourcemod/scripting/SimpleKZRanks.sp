#include <sourcemod>
#include <sdktools>
#include <cstrike>

#include <colorvariables>
#include <simplekz>

#pragma newdecls required
#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Simple KZ Ranks", 
	author = "DanZay", 
	description = "Player ranks module for SimpleKZ (local/non-global).", 
	version = "0.9.0", 
	url = "https://github.com/danzayau/SimpleKZ"
};



/*===============================  Definitions  ===============================*/

#define MAPPOOL_FILE_PATH "cfg/sourcemod/SimpleKZ/mappool.cfg"

// TO-DO: Replace with sound config
#define FULL_SOUNDPATH_BEAT_RECORD "sound/SimpleKZ/beatrecord1.mp3"
#define REL_SOUNDPATH_BEAT_RECORD "*/SimpleKZ/beatrecord1.mp3"
#define FULL_SOUNDPATH_BEAT_MAP "sound/SimpleKZ/beatmap1.mp3"
#define REL_SOUNDPATH_BEAT_MAP "*/SimpleKZ/beatmap1.mp3"



/*===============================  Global Variables  ===============================*/

/* Database */
Database gH_DB = null;
bool gB_ConnectedToDB = false;
DatabaseType g_DBType = DatabaseType_None;
char gC_CurrentMap[64];
char gC_SteamID[MAXPLAYERS + 1][24];

/* Menus */
char gC_MapTopMap[MAXPLAYERS + 1][64];
MovementStyle g_MapTopStyle[MAXPLAYERS + 1];
Handle gH_MapTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_MapTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
Handle gH_PlayerTopMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };
MovementStyle g_PlayerTopStyle[MAXPLAYERS + 1];
Handle gH_PlayerTopSubMenu[MAXPLAYERS + 1] =  { INVALID_HANDLE, ... };

/* Other */
bool gB_LateLoad;
bool gB_HasSeenPBs[MAXPLAYERS + 1];

// Styles translation phrases for chat messages (respective to MovementStyle enum)
char gC_StyleChatPhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "Style_Standard", 
	"Style_Legacy"
};

// Styles translation phrases for menus (respective to MovementStyle enum)
char gC_StyleMenuPhrases[SIMPLEKZ_NUMBER_OF_STYLES][] = 
{ "StyleMenu_Standard", 
	"StyleMenu_Legacy"
};



/*===============================  Includes  ===============================*/

// Global Variable Includes
#include "SimpleKZRanks/sql.sp"

#include "SimpleKZRanks/api.sp"
#include "SimpleKZRanks/commands.sp"
#include "SimpleKZRanks/database.sp"
#include "SimpleKZRanks/menus.sp"
#include "SimpleKZRanks/misc.sp"



/*===============================  Plugin Events  ===============================*/

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max) {
	RegPluginLibrary("SimpleKZRanks");
	gB_LateLoad = late;
	return APLRes_Success;
}

public void OnPluginStart() {
	// Check if game is CS:GO
	EngineVersion gameEngine = GetEngineVersion();
	if (gameEngine != Engine_CSGO) {
		SetFailState("This plugin is only for CS:GO.");
	}
	
	CreateGlobalForwards();
	RegisterCommands();
	
	// Translations
	LoadTranslations("common.phrases");
	LoadTranslations("simplekz.phrases");
	LoadTranslations("simplekzranks.phrases");
	
	CreateMenus();
	
	if (gB_LateLoad) {
		OnLateLoad();
	}
}

public void OnAllPluginsLoaded() {
	if (!LibraryExists("SimpleKZ")) {
		SetFailState("This plugin requires the SimpleKZ core plugin.");
	}
}

void OnLateLoad() {
	for (int client = 1; client <= MaxClients; client++) {
		if (IsClientAuthorized(client) && !IsFakeClient(client)) {
			SetupClient(client);
		}
		if (IsClientInGame(client)) {
			OnClientPutInServer(client);
		}
	}
}



/*===============================  SimpleKZ Events  ===============================*/

public void SimpleKZ_OnDatabaseConnect(Database database, DatabaseType DBType) {
	gB_ConnectedToDB = true;
	gH_DB = database;
	g_DBType = DBType;
	DB_CreateTables();
}

public void SimpleKZ_OnTimerStarted(int client, bool firstStart) {
	if (!gB_HasSeenPBs[client] && gB_ConnectedToDB) {
		DB_PrintPBs(client, client, gC_CurrentMap, SimpleKZ_GetMovementStyle(client));
	}
}

public void SimpleKZ_OnTimerEnded(int client, float time, int teleportsUsed, float theoreticalTime, MovementStyle style) {
	DB_ProcessEndTimer(client, gC_CurrentMap, time, teleportsUsed, theoreticalTime, style);
}

public void SimpleKZ_OnChangeMovementStyle(int client, MovementStyle style) {
	gB_HasSeenPBs[client] = false;
}

public void SimpleKZ_OnBeatMapRecord(int client, const char[] map, RecordType recordType, float runTime, MovementStyle style) {
	switch (recordType) {
		case RecordType_Map: {
			CPrintToChatAll(" %t", "BeatMapRecord", client, gC_StyleChatPhrases[style]);
		}
		case RecordType_Pro: {
			CPrintToChatAll(" %t", "BeatProRecord", client, gC_StyleChatPhrases[style]);
		}
		case RecordType_MapAndPro: {
			CPrintToChatAll(" %t", "BeatMapAndProRecord", client, gC_StyleChatPhrases[style]);
		}
	}
	EmitSoundToAll(REL_SOUNDPATH_BEAT_RECORD);
}

public void SimpleKZ_OnBeatMapFirstTime(int client, const char[] map, RunType runType, float runTime, int rank, int maxRank, MovementStyle style) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			CPrintToChat(client, " %t", "BeatMapFirstTime", client, rank, maxRank, gC_StyleChatPhrases[style]);
		}
		case RunType_Pro: {
			CPrintToChat(client, " %t", "BeatMapFirstTime_Pro", client, rank, maxRank, gC_StyleChatPhrases[style]);
			EmitSoundToClient(client, REL_SOUNDPATH_BEAT_MAP);
			EmitSoundToClientSpectators(client, REL_SOUNDPATH_BEAT_MAP);
		}
	}
}

public void SimpleKZ_OnImproveTime(int client, const char[] map, RunType runType, float runTime, float improvement, int rank, int maxRank, MovementStyle style) {
	if (rank == 1) {
		return;
	}
	switch (runType) {
		case RunType_Normal: {
			CPrintToChat(client, " %t", "ImprovedTime", client, FormatTimeFloat(improvement), rank, maxRank, gC_StyleChatPhrases[style]);
		}
		case RunType_Pro: {
			CPrintToChat(client, " %t", "ImprovedTime_Pro", client, FormatTimeFloat(improvement), rank, maxRank, gC_StyleChatPhrases[style]);
		}
	}
}



/*===============================  Miscellaneous Events  ===============================*/

public void OnClientAuthorized(int client, const char[] auth) {
	if (!IsFakeClient(client)) {
		SetupClient(client);
	}
}

public void OnClientPutInServer(int client) {
	if (!IsFakeClient(client)) {
		DB_GetCompletion(client, client, SimpleKZ_GetMovementStyle(client), false);
	}
}

public void OnMapStart() {
	UpdateCurrentMap();
	DB_SaveMapInfo();
	
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_RECORD);
	AddFileToDownloadsTable(FULL_SOUNDPATH_BEAT_MAP);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_RECORD);
	FakePrecacheSound(REL_SOUNDPATH_BEAT_MAP);
} 