#include <sourcemod>
#include <sdktools>
#include <neotokyo>

#pragma semicolon 1
#pragma newdecls required

public Plugin myinfo = {
    name = "NT Warmup Lite",
    author = "Agiel, soft as HELL, edits by bauxite",
    description = "Enables TDM warmup on map start",
    version = "0.1.1",
    url = "https://github.com/bauxiteDYS/SM-NT-Warmup-Lite"
};

ConVar cWarmupEnabled; 
ConVar cWarmupTimelimit;
ConVar cRestartCommand;
Handle hWarmupTimer = INVALID_HANDLE;
bool bCanEnable;

public void OnPluginStart()
{
	cWarmupEnabled = CreateConVar("sm_nt_warmup_enabled", "1", "Enables or Disables warmup after map change.", _, true, 0.0, true, 1.0);
	cWarmupTimelimit = CreateConVar("sm_nt_warmup_timelimit", "1.0", "Sets deathmatch timelimit.", _, true, 1.0, true, 60.0);
	cRestartCommand = FindConVar("neo_restart_this");
	AutoExecConfig(true);
}

public void OnMapInit()
{
	bCanEnable = true;
}

public void OnConfigsExecuted()
{
	if(!bCanEnable)
	{
		return;
	}
	
	if(cWarmupEnabled.BoolValue)
	{
		StartWarmup();
	}
}

void StartWarmup()
{
	float timeLimit = cWarmupTimelimit.FloatValue * 60;
	GameRules_SetPropFloat("m_fRoundTimeLeft", timeLimit);
	
	PrintToChatAll("Warmup started!");
	
	if(hWarmupTimer == INVALID_HANDLE)
	{
		hWarmupTimer = CreateTimer(timeLimit, timer_EndWarmup, _, TIMER_FLAG_NO_MAPCHANGE);
	}
}

public Action timer_EndWarmup(Handle timer)
{
	hWarmupTimer = INVALID_HANDLE;
	
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i))
		{
			continue;
		}

		SetPlayerXP(i, 0);
		SetPlayerDeaths(i, 0);
	}
	
	if(!ShouldRestartMatch())
	{
		return Plugin_Stop;
	}

	PrintToChatAll("Warmup ended!");

	CreateTimer(1.0, timer_RestartMatch);
	return Plugin_Stop;
}

public Action timer_RestartMatch(Handle timer)
{
	cRestartCommand.SetInt(1);
	return Plugin_Stop;
}

bool ShouldRestartMatch()
{
	int players = GetTeamClientCount(TEAM_JINRAI) + GetTeamClientCount(TEAM_NSF);

	if(players > 1)
	{
		return true;
	}

	return false;
}
