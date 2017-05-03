/*
	API
	
	Simple KZ Local Ranks API.
*/

/*===============================  Forwards  ===============================*/

void CreateGlobalForwards()
{
	gH_SKZ_OnNewRecord = CreateGlobalForward("SKZ_DB_OnNewRecord", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float);
	gH_SKZ_OnNewPersonalBest = CreateGlobalForward("SKZ_DB_OnNewPersonalBest", ET_Ignore, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Cell, Param_Float, Param_Float, Param_Cell, Param_Cell);
}

void Call_SKZ_OnNewRecord(int client, int steamID, int mapID, int course, KZStyle style, KZRecordType recordType, float runTime)
{
	Call_StartForward(gH_SKZ_OnNewRecord);
	if (IsValidClient(client) && GetSteamAccountID(client) == steamID)
	{
		Call_PushCell(client);
	}
	else
	{
		Call_PushCell(-1);
	}
	Call_PushCell(steamID);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(recordType);
	Call_PushFloat(runTime);
	Call_Finish();
}

void Call_SKZ_OnNewPersonalBest(int client, int steamID, int mapID, int course, KZStyle style, KZTimeType timeType, bool firstTime, float runTime, float improvement, int rank, int maxRank)
{
	Call_StartForward(gH_SKZ_OnNewPersonalBest);
	if (IsValidClient(client) && GetSteamAccountID(client) == steamID)
	{
		Call_PushCell(client);
	}
	else
	{
		Call_PushCell(-1);
	}
	Call_PushCell(steamID);
	Call_PushCell(mapID);
	Call_PushCell(course);
	Call_PushCell(style);
	Call_PushCell(timeType);
	Call_PushCell(firstTime);
	Call_PushFloat(runTime);
	Call_PushFloat(improvement);
	Call_PushCell(rank);
	Call_PushCell(maxRank);
	Call_Finish();
} 