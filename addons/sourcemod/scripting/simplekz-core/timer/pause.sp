/*	
	Pause
	
	Pausing and resuming functionality.
*/

#define TIME_PAUSE_COOLDOWN 1.0

void TogglePause(int client)
{
	if (gB_Paused[client])
	{
		Resume(client);
	}
	else
	{
		Pause(client);
	}
}

void Pause(int client)
{
	if (gB_Paused[client])
	{
		return;
	}
	if (gB_TimerRunning[client] && gB_HasResumedInThisRun[client]
		 && GetEngineTime() - gF_LastResumeTime[client] < TIME_PAUSE_COOLDOWN)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Just Resumed)");
		PlayErrorSound(client);
		return;
	}
	// Can't pause in the air if timer is running and player is moving
	if (gB_TimerRunning[client] && !g_KZPlayer[client].onGround
		 && !(g_KZPlayer[client].speed == 0 && g_KZPlayer[client].verticalVelocity == 0))
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Pause (Midair)");
		PlayErrorSound(client);
		return;
	}
	
	gB_Paused[client] = true;
	if (gB_TimerRunning[client])
	{
		gB_HasPausedInThisRun[client] = true;
		gF_LastPauseTime[client] = GetEngineTime();
	}
	FreezePlayer(client);
	
	Call_SKZ_OnPause(client);
}

void Resume(int client)
{
	if (!gB_Paused[client])
	{
		return;
	}
	if (gB_TimerRunning[client] && gB_HasPausedInThisRun[client]
		 && GetEngineTime() - gF_LastPauseTime[client] < TIME_PAUSE_COOLDOWN)
	{
		CPrintToChat(client, "%t %t", "KZ Prefix", "Can't Resume (Just Paused)");
		PlayErrorSound(client);
		return;
	}
	
	gB_Paused[client] = false;
	if (gB_TimerRunning[client])
	{
		gB_HasResumedInThisRun[client] = true;
		gF_LastResumeTime[client] = GetEngineTime();
	}
	g_KZPlayer[client].moveType = MOVETYPE_WALK;
	
	Call_SKZ_OnResume(client);
}

void PauseOnStartNoclipping(int client)
{
	gB_Paused[client] = false;
}

void PauseOnPlayerDeath(int client)
{
	gB_Paused[client] = false;
} 