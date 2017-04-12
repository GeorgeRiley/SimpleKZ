/*	
	Miscellaneous
	
	Miscellaneous timer related functions.
*/

#define SOUND_TIMER_FORCE_STOP "buttons/button18.wav"

#define STYLE_DEFAULT_SOUND_START "buttons/button9.wav"
#define STYLE_DEFAULT_SOUND_END "buttons/bell1.wav"

#define STYLE_LEGACY_SOUND_START "buttons/button3.wav"
#define STYLE_LEGACY_SOUND_END "buttons/button3.wav"

void PrintEndTimeString(int client)
{
	if (gI_CurrentCourse[client] == 0)
	{
		switch (GetCurrentTimeType(client))
		{
			case KZTimeType_Normal:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map", 
					client, SKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Map (Pro)", 
					client, SKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
	else
	{
		switch (GetCurrentTimeType(client))
		{
			case KZTimeType_Normal:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus", 
					client, gI_CurrentCourse[client], SKZ_FormatTime(gF_CurrentTime[client]), 
					gI_TeleportsUsed[client], SKZ_FormatTime(gF_CurrentTime[client] - gF_WastedTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
			case KZTimeType_Pro:
			{
				CPrintToChatAll("%t %t", "KZ Prefix", "Beat Bonus (Pro)", 
					client, gI_CurrentCourse[client], SKZ_FormatTime(gF_CurrentTime[client]), 
					gC_StylePhrases[g_Style[client]]);
			}
		}
	}
}

void PlayTimerStartSound(int client)
{
	switch (g_Style[client])
	{
		case KZStyle_Standard:
		{
			EmitSoundToClient(client, STYLE_DEFAULT_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_DEFAULT_SOUND_START);
		}
		case KZStyle_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_START);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_START);
		}
	}
}

void PlayTimerEndSound(int client)
{
	switch (g_Style[client])
	{
		case KZStyle_Standard:
		{
			EmitSoundToClient(client, STYLE_DEFAULT_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_DEFAULT_SOUND_END);
		}
		case KZStyle_Legacy:
		{
			EmitSoundToClient(client, STYLE_LEGACY_SOUND_END);
			EmitSoundToClientSpectators(client, STYLE_LEGACY_SOUND_END);
		}
	}
}

void PlayTimerForceStopSound(int client)
{
	EmitSoundToClient(client, SOUND_TIMER_FORCE_STOP);
	EmitSoundToClientSpectators(client, SOUND_TIMER_FORCE_STOP);
} 