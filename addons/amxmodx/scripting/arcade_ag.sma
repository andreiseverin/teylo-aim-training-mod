#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <hlstocks>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <fun>

#define PLUGIN	"Arcade"
#define VERSION	"2.3"
#define AUTHOR	"Kemal & teylo"

#pragma semicolon 1
#define MAX_WORDS 250
#define GAME_DESCRIPTION "RO Arcade"


// ===== variables ini file ====
new g_mapData[MAX_WORDS][25];
new g_mapNum;


// ===== Cvars defines   =======
new cvar_enable;
new cvar_Wcrowbar;
new cvar_W9mmhandgun;
new cvar_Wgauss;
new cvar_Wegon;
new cvar_Wcrossbow;
new cvar_Wrpg;
new cvar_Wsatchel;
new cvar_Whornetgun;
new cvar_W357;
new cvar_Wshotgun;
new cvar_W9mmAR;
new cvar_Whandgrenade;
new cvar_Wsnark;
new cvar_Wtripmine;
new cvar_ammo_crossbow;
new cvar_ammo_buckshot;
new cvar_ammo_gaussclip;
new cvar_ammo_rpgclip;
new cvar_ammo_9mmAR;
new cvar_ammo_ARgrenades;
new cvar_ammo_357;
new cvar_ammo_glock;
new cvar_ammo_satchel;
new cvar_ammo_tripmine;
new cvar_ammo_hgrenade;
new cvar_ammo_snark;
new cvar_ihealth;
new cvar_iarmour;
new cvar_ilongjump;

// ====== Cvars
new remove_game_equip;



// ====== Entitiys
new const entGameEquip[]		= "game_player_equip";


static const _HLW_to_rgAmmoIdx[] =
{
	0, 	// none
	0,	// crowbar
	2, 	// 9mmhandgun
	4, 	// 357
	2, 	// 9mmAR
	3, 	// m203
	7, 	// crossbow
	1, 	// shotgun
	6, 	// rpg
	20, 	// gauss
	5, 	// egon
	12,	// hornetgun
	10, // handgrenade
	8, 	// tripmine
	9, 	// satchel
	11  // snark
};




// ============= Hud variables ==============
static D_color, D_x, D_y, D_effect, D_fxtime, D_holdtime, D_fadeintime, D_fadeouttime, D_reliable;

public plugin_init() 
{

	register_plugin(PLUGIN,VERSION,AUTHOR);
	mapFile();
	removeGequip();		
	register_forward(FM_GetGameDescription	, "fwd_GetGameDescription");
	RegisterHam(Ham_Killed, "player", "playerKill");
	RegisterHam(Ham_Spawn, "player", "playerSpawn",true);
}

stock hl_get_ammo(client, weapon)
{
	return get_ent_data(client, "CBasePlayer", "m_rgAmmo", _HLW_to_rgAmmoIdx[weapon]);
}

stock hl_set_ammo(client, weapon, ammo)
{
	if (weapon <= HLW_CROWBAR)
		return;
	set_ent_data(client, "CBasePlayer", "m_rgAmmo", ammo, _HLW_to_rgAmmoIdx[weapon]);
}

// ===== PLUGIN STOP ==============
stock StopPlugin() {
	new pluginName[32];
	get_plugin(-1, pluginName, sizeof(pluginName));
	pause("d", pluginName);
	return;
}

public plugin_precache() 
{
// ===== cvar plugin enable   ======= (1-on 0-off)
	cvar_enable          = create_cvar("sv_arcade_enable", "1");	
	
// ===== cvars weapons ======= (1-on 0-off)
	cvar_Wcrowbar        = create_cvar("sv_arcade_crowbar", "1");
	cvar_W9mmhandgun     = create_cvar("sv_arcade_9mmhandgun", "1");
	cvar_Wgauss          = create_cvar("sv_arcade_gauss", "1");
	cvar_Wegon           = create_cvar("sv_arcade_egon", "1");
	cvar_Wcrossbow       = create_cvar("sv_arcade_crossbow", "1");
	cvar_Wrpg            = create_cvar("sv_arcade_rpg", "1");
	cvar_Wsatchel        = create_cvar("sv_arcade_satchel", "1");
	cvar_Whornetgun      = create_cvar("sv_arcade_hornetgun", "1");
	cvar_W357            = create_cvar("sv_arcade_357", "1");
	cvar_Wshotgun        = create_cvar("sv_arcade_shotgun", "1");
	cvar_W9mmAR          = create_cvar("sv_arcade_9mmAR", "1");
	cvar_Whandgrenade    = create_cvar("sv_arcade_handgrenade", "1");
	cvar_Wsnark          = create_cvar("sv_arcade_snark", "1");
	cvar_Wtripmine       = create_cvar("sv_arcade_tripmine", "1");
	
// ===== cvars ammo =======
	cvar_ammo_crossbow   = create_cvar("sv_arcade_ammo_crossbow", "50");
	cvar_ammo_buckshot   = create_cvar("sv_arcade_ammo_buckshot", "128");
	cvar_ammo_gaussclip  = create_cvar("sv_arcade_ammo_gaussclip", "100");
	cvar_ammo_rpgclip    = create_cvar("sv_arcade_ammo_rpgclip", "5");
	cvar_ammo_9mmAR      = create_cvar("sv_arcade_ammo_9mmAR", "250");
	cvar_ammo_ARgrenades = create_cvar("sv_arcade_ammo_ARgrenades", "10");
	cvar_ammo_357        = create_cvar("sv_arcade_ammo_357", "128");
	cvar_ammo_glock      = create_cvar("sv_arcade_ammo_glock", "250");	
	cvar_ammo_satchel    = create_cvar("sv_arcade_ammo_satchel", "5");
	cvar_ammo_tripmine   = create_cvar("sv_arcade_ammo_tripmine", "5");
	cvar_ammo_hgrenade   = create_cvar("sv_arcade_ammo_hgrenade", "10");
	cvar_ammo_snark      = create_cvar("sv_arcade_ammo_snark", "15");			

// ===== cvars items =======
	cvar_ihealth         = create_cvar("sv_arcade_health", "100");
	cvar_iarmour         = create_cvar("sv_arcade_armour", "100");
	cvar_ilongjump       = create_cvar("sv_arcade_longjump", "1"); // (1-on 0-off)
	
// ===== cvar game equip =====

	remove_game_equip    = create_cvar("sv_arcade_remove_game_equip", "1"); // (1-on 0-off)
	
}

// ===== WHEN CONNECTED ==========
public client_putinserver(id)
{
	if(get_pcvar_num(cvar_enable))
	{	
		set_task(1.5,"give_weapons",id);
	}
}

// ====== RESTORE AMMO WHEN KILL =========
public restore_ammo(id) 
{
	// 9mmhandgun 
	if(get_pcvar_num(cvar_W9mmhandgun))
	{
	
		if(hl_get_ammo(id,HLW_GLOCK) < get_pcvar_num(cvar_ammo_glock))
		{
			hl_set_ammo(id,HLW_GLOCK,get_pcvar_num(cvar_ammo_glock)); 	
		}
	
		if(hl_get_ammo(id,HLW_GLOCK) > get_pcvar_num(cvar_ammo_glock))
		{
			hl_set_ammo(id,HLW_GLOCK,get_pcvar_num(cvar_ammo_glock));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_GLOCK)),17);		
	}
	
	// gauss
	if(get_pcvar_num(cvar_Wgauss))	
	{
		if(hl_get_ammo(id,HLW_GAUSS) < get_pcvar_num(cvar_ammo_gaussclip))
		{
			hl_set_ammo(id,HLW_GAUSS,get_pcvar_num(cvar_ammo_gaussclip)); 	
		}
	
		if(hl_get_ammo(id,HLW_GAUSS) > get_pcvar_num(cvar_ammo_gaussclip))
		{
			hl_set_ammo(id,HLW_GAUSS,get_pcvar_num(cvar_ammo_gaussclip));
		}
	}
	
	// egon 
	if(get_pcvar_num(cvar_Wegon))
	{
		if(hl_get_ammo(id,HLW_EGON) < get_pcvar_num(cvar_ammo_gaussclip))
		{
			hl_set_ammo(id,HLW_EGON,get_pcvar_num(cvar_ammo_gaussclip)); 	
		}
	
		if(hl_get_ammo(id,HLW_EGON) > get_pcvar_num(cvar_ammo_gaussclip))
		{
			hl_set_ammo(id,HLW_EGON,get_pcvar_num(cvar_ammo_gaussclip));
		}
	}
	
	// crossbow 
	if(get_pcvar_num(cvar_Wcrossbow))
	{
		
		if(hl_get_ammo(id,HLW_CROSSBOW) < get_pcvar_num(cvar_ammo_crossbow))
		{
			hl_set_ammo(id,HLW_CROSSBOW,get_pcvar_num(cvar_ammo_crossbow)); 	
		}
	
		if(hl_get_ammo(id,HLW_CROSSBOW) > get_pcvar_num(cvar_ammo_crossbow))
		{
			hl_set_ammo(id,HLW_CROSSBOW,get_pcvar_num(cvar_ammo_crossbow));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_CROSSBOW)),5);		
	}
	
	// rpg 
	if(get_pcvar_num(cvar_Wrpg))
	{
		if(hl_get_ammo(id,HLW_RPG) < get_pcvar_num(cvar_ammo_rpgclip))
		{
			hl_set_ammo(id,HLW_RPG,get_pcvar_num(cvar_ammo_rpgclip)); 	
		}
	
		if(hl_get_ammo(id,HLW_RPG) > get_pcvar_num(cvar_ammo_rpgclip))
		{
			hl_set_ammo(id,HLW_RPG,get_pcvar_num(cvar_ammo_rpgclip));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_RPG)),1);			
	}
	
	//357
	if(get_pcvar_num(cvar_W357))
	{
		if(hl_get_ammo(id,HLW_PYTHON) < get_pcvar_num(cvar_ammo_357))
		{
			hl_set_ammo(id,HLW_PYTHON,get_pcvar_num(cvar_ammo_357)); 	
		}
	
		if(hl_get_ammo(id,HLW_PYTHON) > get_pcvar_num(cvar_ammo_357))
		{
			hl_set_ammo(id,HLW_PYTHON,get_pcvar_num(cvar_ammo_357));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_PYTHON)),6);		
	}
	
	//9mmAR
	if(get_pcvar_num(cvar_W9mmAR))
	{
		if(hl_get_ammo(id,HLW_MP5) < get_pcvar_num(cvar_ammo_9mmAR))
		{
			hl_set_ammo(id,HLW_MP5,get_pcvar_num(cvar_ammo_9mmAR)); 	
		}
	
		if(hl_get_ammo(id,HLW_MP5) > get_pcvar_num(cvar_ammo_9mmAR))
		{
			hl_set_ammo(id,HLW_MP5,get_pcvar_num(cvar_ammo_9mmAR));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_MP5)),50);			
	
		// ammo ARgrenades
		if(hl_get_ammo(id,HLW_CHAINGUN) < get_pcvar_num(cvar_ammo_ARgrenades))
		{
			hl_set_ammo(id,HLW_CHAINGUN,get_pcvar_num(cvar_ammo_ARgrenades)); 	
		}
	
		if(hl_get_ammo(id,HLW_CHAINGUN) > get_pcvar_num(cvar_ammo_ARgrenades))
		{
			hl_set_ammo(id,HLW_CHAINGUN,get_pcvar_num(cvar_ammo_ARgrenades));
		}	
	}
	
	//buckshot - shotgun
	if(get_pcvar_num(cvar_Wshotgun))
	{
		if(hl_get_ammo(id,HLW_SHOTGUN) < get_pcvar_num(cvar_ammo_buckshot))
		{
			hl_set_ammo(id,HLW_SHOTGUN,get_pcvar_num(cvar_ammo_buckshot)); 	
		}
	
		if(hl_get_ammo(id,HLW_SHOTGUN) > get_pcvar_num(cvar_ammo_buckshot))
		{
			hl_set_ammo(id,HLW_SHOTGUN,get_pcvar_num(cvar_ammo_buckshot));
		}
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_SHOTGUN)),8);		
	}
	
	//satchel
	if(get_pcvar_num(cvar_Wsatchel))
	{
		if(hl_get_ammo(id,HLW_SATCHEL) < get_pcvar_num(cvar_ammo_satchel))
		{
			hl_set_ammo(id,HLW_SATCHEL,get_pcvar_num(cvar_ammo_satchel)); 	
		}
	
		if(hl_get_ammo(id,HLW_SATCHEL) > get_pcvar_num(cvar_ammo_satchel))
		{
			hl_set_ammo(id,HLW_SATCHEL,get_pcvar_num(cvar_ammo_satchel));
		}
	}
	
	//tripmine
	if(get_pcvar_num(cvar_Wtripmine))
	{
		if(hl_get_ammo(id,HLW_TRIPMINE) < get_pcvar_num(cvar_ammo_tripmine))
		{
			hl_set_ammo(id,HLW_TRIPMINE,get_pcvar_num(cvar_ammo_tripmine)); 	
		}
		
		if(hl_get_ammo(id,HLW_TRIPMINE) > get_pcvar_num(cvar_ammo_tripmine))
		{
			hl_set_ammo(id,HLW_TRIPMINE,get_pcvar_num(cvar_ammo_tripmine));
		}
	}
	
	//handgrenade
	if(get_pcvar_num(cvar_Whandgrenade))
	{
		if(hl_get_ammo(id,HLW_HANDGRENADE) < get_pcvar_num(cvar_ammo_hgrenade))
		{
			hl_set_ammo(id,HLW_HANDGRENADE,get_pcvar_num(cvar_ammo_hgrenade)); 	
		}
	
		if(hl_get_ammo(id,HLW_HANDGRENADE) > get_pcvar_num(cvar_ammo_hgrenade))
		{
			hl_set_ammo(id,HLW_HANDGRENADE,get_pcvar_num(cvar_ammo_hgrenade));
		}	
	}
	
	//snark
	if(get_pcvar_num(cvar_Wsnark))
	{
		if(hl_get_ammo(id,HLW_SNARK) < get_pcvar_num(cvar_ammo_snark))
		{
			hl_set_ammo(id,HLW_SNARK,get_pcvar_num(cvar_ammo_snark)); 	
		}
	
		if(hl_get_ammo(id,HLW_SNARK) > get_pcvar_num(cvar_ammo_snark))
		{
			hl_set_ammo(id,HLW_SNARK,get_pcvar_num(cvar_ammo_snark));
		}
	}	
}

// ====== SPAWN EQUIP WEAPONS =========
public give_weapons(id) 
{
	if(is_user_alive(id))
	{
		if(get_pcvar_num(cvar_ilongjump))
		{
			hl_set_user_longjump(id,true);
		}
		if(get_pcvar_num(cvar_ihealth) > 0)
		{
			hl_set_user_health(id,get_pcvar_num(cvar_ihealth));
		}
		if(get_pcvar_num(cvar_iarmour) > 0 )
		{
			hl_set_user_armor(id,get_pcvar_num(cvar_iarmour));
		}
		if(get_pcvar_num(cvar_Wcrowbar))
		{
			give_item( id, "weapon_crowbar" );
		}
		if(get_pcvar_num(cvar_W9mmhandgun))
		{		
			give_item( id, "weapon_9mmhandgun" );
		}
		if(get_pcvar_num(cvar_Wgauss))	
		{
			give_item( id, "weapon_gauss" );
		}
		if(get_pcvar_num(cvar_Wegon))
		{
			give_item( id, "weapon_egon" );
		}
		if(get_pcvar_num(cvar_Wcrossbow))
		{
			give_item( id, "weapon_crossbow" );
		}
		if(get_pcvar_num(cvar_Wrpg))
		{
			give_item( id, "weapon_rpg" );
		}
		if(get_pcvar_num(cvar_Wsatchel))
		{
			give_item( id, "weapon_satchel" );
		}
		if(get_pcvar_num(cvar_Wsnark))
		{
			give_item( id, "weapon_snark" );
		}
		if(get_pcvar_num(cvar_Whandgrenade))
		{
			give_item( id, "weapon_handgrenade" );		
		}	
		if(get_pcvar_num(cvar_Whornetgun))
		{
			give_item( id, "weapon_hornetgun" );
		}	
		if(get_pcvar_num(cvar_Wtripmine))
		{
			give_item( id, "weapon_tripmine" );
		}		
		if(get_pcvar_num(cvar_W357))
		{
			give_item( id, "weapon_357" );
		}
		if(get_pcvar_num(cvar_W9mmAR))
		{
			give_item( id, "weapon_9mmAR" );
		}		
		if(get_pcvar_num(cvar_Wsnark))
		{
			give_item( id, "weapon_snark" );
		}	
		if(get_pcvar_num(cvar_Wshotgun))
		{
			give_item( id, "weapon_shotgun" );
		}		
		
		restore_ammo(id);
	}
}

// hud metodu
stock Set_Director_Hud_Message(red = 0,green = 160,blue = 0,Float:x = -1.0,Float:y = 0.65,effects = 2,Float:fxtime = 6.0,Float:holdtime = 0.5,Float:fadeintime = 0.1,Float:fadeouttime = 0.5,bool:reliable = false)
{
	#define clamp_byte(%1) (clamp(%1,0,255))
	#define pack_color(%1,%2,%3) (%3 + (%2 << 8) + (%1 << 16))

	D_color       = pack_color(clamp_byte(red),clamp_byte(green),clamp_byte(blue));
	D_x           = _:x;
	D_y           = _:y;
	D_effect      = effects;
	D_fxtime      = _:fxtime;
	D_holdtime    = _:holdtime;
	D_fadeintime  = _:fadeintime;
	D_fadeouttime = _:fadeouttime;
	D_reliable    = _:reliable;

	return 1;
}

// hud gosterme metodu
stock Show_Director_Hud_Message(index,const message[],any:...)
{
	static buffer[128], playersList[32], numPlayers,
	numArguments, size;

	numArguments = numargs();
	new Array:handleArrayML = ArrayCreate();
	size = ArraySize(handleArrayML);


	if(numArguments == 2)
	{
		Send_Director_Hud_Message(index,message);
	}
	else if(index || numArguments == 3)
	{
		vformat(buffer,charsmax(buffer),message,3);
		Send_Director_Hud_Message(index,buffer);
	}
	else
	{
		get_players(playersList,numPlayers,"ch");

		if(!numPlayers)
		{
			return 0;
		}

		for(new i = 2, j; i < numArguments; i++)
		{

			if(getarg(i) == LANG_PLAYER)
			{
				while((buffer[j] = getarg(i + 1,j++))){}
				j = 0;

				if(GetLangTransKey(buffer) != TransKey_Bad)
				{
					ArrayPushCell(handleArrayML,i++);
				}
			}
		}
		if(!size)
		{
			vformat(buffer,charsmax(buffer),message,3);
			Send_Director_Hud_Message(index,buffer);
		}
		else
		{
			for(new i = 0,j; i < numPlayers; i++)
			{
				index = playersList[i];

				for(j = 0; j < size; j++)
				{
					setarg(ArrayGetCell(handleArrayML,j),0,index);
				}
				vformat(buffer,charsmax(buffer),message,3);
				Send_Director_Hud_Message(index,buffer);
			}
		}
		ArrayDestroy(handleArrayML);
	}
	return 1;
}

// hud gonderme metodu
stock Send_Director_Hud_Message(const index, const message[])
{
	message_begin(D_reliable ?(index ? MSG_ONE : MSG_ALL) : (index ? MSG_ONE_UNRELIABLE : MSG_BROADCAST),SVC_DIRECTOR,_,index);
	{
		write_byte(strlen(message) + 31);
		write_byte(DRC_CMD_MESSAGE);
		write_byte(D_effect);
		write_long(D_color);
		write_long(D_x);
		write_long(D_y);
		write_long(D_fadeintime);
		write_long(D_fadeouttime);
		write_long(D_holdtime);
		write_long(D_fxtime);
		write_string(message);
	}
	message_end();
}

public playerKill(victim, attacker)
{
	if(get_pcvar_num(cvar_enable))
	{
		if (is_user_alive(attacker))
		{
			give_weapons(attacker);
			
			new origin[3];
			get_user_origin(attacker,origin);
	
			message_begin(MSG_PVS,SVC_TEMPENTITY,origin,attacker);
			write_byte(TE_TELEPORT);
			write_coord(origin[0]);
			write_coord(origin[1]);
			write_coord(origin[2]);
			message_end();
		}
		
		///////////////////////////////
		const r	= 0;
		const g	= 255;
		const b	= 0;
		const Float:x	= -1.0;
		const Float:y	= 0.30;
		
		///////////////////////////////
		const efekt		= 0;	
		const Float:fxtime	= 0.9;
		const Float:holdtime	= 3.0;	
		const Float:fadeintime	= 0.02;
		const Float:fadeouttime	= 0.02;	
		///////////////////////////////
		Set_Director_Hud_Message(r, g, b, x, y, efekt, fxtime, holdtime, fadeintime, fadeouttime);
		Show_Director_Hud_Message(victim,"Running Arcade's v%s AMXX Mod by |-RT-| teylo and Kemal", VERSION);
	}
}

public playerSpawn(id)
{
	if(get_pcvar_num(cvar_enable))
	{
		give_weapons(id);
	}
}

mapFile()
{
	new DataFile[128];
	new map_file[128];
	get_configsdir( DataFile, 127 );
	format(map_file, 127, "%s/arcade_maps.ini", DataFile );

	if ( !file_exists(map_file) )
	{
		server_print ( "================================================" );
		server_print ( "[Arcade List] arcade_maps.ini file not found!");
		server_print ( "================================================" );
		return;
	}
	
	new len, i=0;
	while( i < MAX_WORDS && read_file( map_file, i , g_mapData[g_mapNum], 19, len ) )
	{
		i++;
		if( g_mapData[g_mapNum][0] == ';' || len == 0 )
			continue;
		g_mapNum++;
	}

	server_print ( "===================================================" );
	server_print ( "[Arcade List] %i Maps Loaded.", g_mapNum );
	server_print ( "===================================================" );
	
	mapControl();
	
}

mapControl()
{
	static map_name[33];
	get_mapname(map_name, charsmax(map_name));

	new i = 0;
	while ( i < g_mapNum )
	{
		if ( equali ( map_name, g_mapData[i++] ) )
		{
			client_print ( 0 , print_chat , "[HL.Pyro-Zone.com] Arcade Romania Fun mod!");
			set_cvar_num("sv_arcade_enable",1);
			set_cvar_num("sv_arcade_remove_game_equip", 1);				

			return PLUGIN_HANDLED;	
		}
	}
	
	set_cvar_num("sv_arcade_enable", 0);
	set_cvar_num("sv_arcade_remove_game_equip", 0);	
    StopPlugin();
	return PLUGIN_HANDLED;	
}

removeGequip()
{
	if(get_pcvar_num(remove_game_equip))
	{
		remove_entity_name(entGameEquip);
	}
}

public fwd_GetGameDescription()
{ 
	forward_return(FMV_STRING, GAME_DESCRIPTION);
	return FMRES_SUPERCEDE;
}
