/*
*	PLUGIN NAME 	: HLAim Training 
*	VERSION		: v1.1.0
*	AUTHOR		: teylo
*
*
*  	Copyright (C) 2023, teylo 
*	
*
*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <hlstocks>
#include <fun>

new PLUGIN[] = "HL Aim Training";
new AUTHOR[] = "teylo";
new VERSION[] = "1.1.0";



#define SECONDS 4.0	// time to disapear (seconds) 
new gConnexion[33];



#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

new const g_szClassname[] = "_task";

new bool:g_bStarted[33];

new Float:g_fStart[33];

new g_iMaxPlayers;

new g_iFrags[ 33 ];

new g_gRoom = 0;
new g_gRoom_aim = 0;
new bool:g_Freeze = false;
new bool:g_StartAmmo;
new g_BoostBotHP=0;
new gVerif =  0;

//spawn training variables
new spawnMessage=0
new dmgMessage=0
new origin_resp[3],origin_fix[3]
new is_bot[32]
new players[32], inum, player

// blue fade
new blueFade = 0

// weaponbox
new weaponbox =0

// hl aim training central room
new const g_fOrigin_hlaim[][ 3 ] = {
{-511 , 0 , -196}
};

// Fire horizontal room
new const g_botOrigin_horizontal[][ 3 ] = {
{740,704,71},
{740,192,71},
{740,-255,71},
{740,-697,71},
{740,-694,199},
{740,-147,199},
{740,254,199},
{740,585,199},
{740,583,319},
{740,147,319},
{740,-196,319},
{740,-608,319},
{740,-702,451},
{740,-48,451},
{740,284,451},
{740,678,451},
{740,610,575},
{740,62,575},
{740,-337,575},
{740,-698,575},
{740,-652,703},
{740,230,703},
{740,-638,835},
{740,-75,835},
{740,481,835}
};

new const g_botOrigin_horizontal2[][ 3 ] = {
{-2201,2439,-1479},
{-2431,2435,-1479},
{-2313,2446,-1479}
};

// Fire Reflex + vertical training map
new const g_botOrigin_vertical1[][ 3 ] = {
{200,202,530},
{206,110,530},
{200,14,530},
{192,-97,530},
{187,-204,530},
{133,206,530},
{142,98,530},
{118,-6,530},
{119,-112,530},
{106,-210,530},
{42,194,530},
{42,76,530},
{26,-13,530},
{26,-114,530},
{13,-209,530},
{-85,187,530},
{-89,65,530},
{-87,-22,530},
{-93,-125,530},
{-89,-220,530},
{-207,-201,530},
{-210,-118,530},
{-212,-24,530},
{-201,76,530},
{-208,200,530},
{200,202,-448},
{206,110,-448},
{200,14,-448},
{192,-97,-448},
{187,-204,-448},
{133,206,-448},
{142,98,-448},
{118,-6,-448},
{119,-112,-448},
{106,-210,-448},
{42,194,-448},
{42,76,-448},
{26,-13,-448},
{26,-114,-448},
{13,-209,-448},
{-85,187,-448},
{-89,65,-448},
{-87,-22,-448},
{-93,-125,-448},
{-89,-220,-448},
{-207,-201,-448},
{-210,-118,-448},
{-212,-24,-448},
{-201,76,-448},
{-208,200,-448}
};

new const g_botOrigin_vertical2[][ 3 ] = {
{-1780,-1094,-960},
{-1772,-1478,-960},
{-1766,-1414,-960},
{-1761,-1350,-960},
{-1771,-1285,-960},
{-1761,-1221,-960},
{-1764,-1159,-960}
};

// Noel map rooms 
new const g_fOrigin_room1[][ 3 ] = {
{431, 32, -456},
{592, -325, -445},
{1124, -561, -456},
{806, -146, -408},
{1327, -32, -456},
{1289, 314, -456},
{1190, 698, -385},
{863, 417, -456},
{840, 163, -456},
{592, 269, -456},
{1045, 402, -456},
{1135, -115, -456},
{1483, -353, -456},
{1404, -622, -456},
{1663, -3, -456},
{1018, 651, -421},
{1332, 754, -200},
{1548, 289, -456},
{1602, 370, -200}
	
};
new const g_fOrigin_room2[][ 3 ] = {
{-2528, 908, -2120},
{-2225, 1042, -2120},
{-1719, 1021, -2120},
{-1951, 824, -2120},
{-1958, 1420, -2120},
{-2426, 1371, -2120},
{-1362, 1294, -2120},
{-1371, 788, -2120},
{-1297, 385, -2120},
{-1816, 122, -2120},
{-1740, 521, -2120},
{-2274, 703, -2120},
{-2271, 216, -2120},
{-2592, 431, -2120},
{-1715, 1348, -2120},
{-2319, 1357, -2120},
{-1650, 566, -2120},
{-2249, 466, -2120}
};
new const g_fOrigin_room3[][ 3 ] = {
{-1960, -1640, -1992},
{-1959, -1930, -1992},
{-1855, -1441, -1992},
{-1604, -1684, -1992},
{-1568, -2428, -1992},
{-1796, -2313, -1992},
{-2356, -2322, -1992},
{-2806, -2306, -1992},
{-3023, -2267, -1960},
{-2918, -1579, -1992},
{-2744, -1704, -1992},
{-2302, -1532, -1992},
{-2306, -3063, -1992},
{-1658, -3002, -1973},
{-2841, -2835, -1992},
{-2299, -2615, -1960},
{-2295, -1980, -1992}
};
new const g_fOrigin_room4[][ 3 ] = {
{879, -2848, -1672},
{520, -2942, -1672},
{325, -2634, -1672},
{654, -2531, -1672},
{576, -2260, -1672},
{564, -2005, -1672},
{294, -2033, -1672},
{267, -2352, -1672},
{-106, -2171, -1672},
{57, -3177, -1656},
{946, -2050, -1736},
{-90, -2553, -1736},
{708, -2998, -1672}
};
new const g_fOrigin_room5[][ 3 ] = {
{2116, 3183, -982},
{2289, 3060, -1000},
{2327, 2666, -1000},
{2137, 2716, -1000},
{2067, 2386, -1000},
{2074, 1869, -1000},
{2289, 1560, -1000},
{2109, 1132, -968},
{2054, 1385, -975},
{2171, 1460, -988},
{2118, 3013, -1000},
{2031, 2011, -1000},
{1991, 1156, -968}
};
new const g_fOrigin_room6[][ 3 ] = {
{2265, -2955, -1464},
{2717, -2610, -1464},
{2477, -2274, -1464},
{2355, -1960, -1464},
{2792, -1942, -1464},
{2573, -2511, -1464},
{2370, -2405, -1464},
{3440, -1991, -1464},
{3443, -2407, -1464},
{3498, -2895, -1410},
{3288, -2901, -1422},
{3167, -2661, -1460},
{3021, -2416, -1464},
{3581, -2660, -1443},
{2129, -2364, -1464},
{1852, -2024, -1464},
{1935, -2958, -1464},
{2102, -1769, -1464}
};

// aimtraining center rooms
new const g_fOrigin_aim_room1[][ 3 ] = {
{1630, 1269, 55},
{1462, 1508, 55},
{1234, 1653, 55},
{1216, 2347, 55},
{1644, 2309, 55},
{1632, 2630, 55},
{2242, 2636, 55},
{2190, 2230, 55},
{2612, 2299, 55},
{2593, 1550, 55},
{2168, 1585, 55},
{2340, 1230, 55},
{2096, 1209, 55},
{2004, 1646, 55},
{1133, 1169, 55},
{2692, 2696, 55},
{2748, 1987, 55},
{2708, 1149, 55},
{1729, 1047, 55},
{1359,  989, 55}
};
new const g_fOrigin_aim_room2[][ 3 ] = {
{2269, -1179, 55},
{2264, -1479, 55},
{2615, -1871, 55},
{1907, -1561, 55},
{1617, -1540, 55},
{1424, -1307, 55},
{1179, -1047, 55},
{1196, -2238, 55},
{1501, -2486, 55},
{1640, -2328, 55},
{1900, -2620, 55},
{1835, -2138, 55},
{2139, -2433, 55},
{2641, -2366, 55},
{2583, -2747, 55},
{2363, -2130, 55},
{2653, -1372, 55},
{2822, -1087, 55},
{2204, -1760, 55},
{1810, -1869, 55}
};
new const g_fOrigin_aim_room3[][ 3 ] = {
{-1301, -1428, 63},
{-1197, -2439, 63},
{-1685, -2349, 63},
{-1104, -1957, 63},
{-1482, -1704, 63},
{-1376, -2814, 63},
{-1815, -2721, 63},
{-2503, -2747, 63},
{-2479, -2347, 63},
{-2425, -1948, 63},
{-2739, -1256, 63},
{-2035, -1731, 63},
{-1939, -1404, 63},
{-1839, -2067, 63},
{-2856, -2262, 63},
{-2779, -1892, 63},
{-2400, -1652, 63},
{-1944, -2269, 63}
};
new const g_fOrigin_aim_room4[][ 3 ] = {
{-1519, 1113, 55},
{-1112, 1547, 55},
{-1118, 2368, 55},
{-2753, 1439, 55},
{-2174, 1165, 55},
{-1960, 1584, 55},
{-988 , 2676, 55},
{-1516, 2739, 55},
{-2003, 2185, 55},
{-2206, 2498, 55},
{-2762, 2199, 55},
{-2604, 2871, 55},
{-1221, 2612, 183},
{-1921, 2608, 183},
{-2602, 2609, 183},
{-2603, 1236, 183},
{-1915, 1234, 183},
{-1238, 1237, 183},
{-1219, 1921, 183},
{-1571, 1831, 55}
};

// Fire map rooms 
new const g_FireOrigin_room1[][ 3 ] = {
{1757,2480,330},
{1803,2485,329},
{1853,2488,328},
{1907,2487,328},
{1962,2487,329},
{2017,2487,328},
{2077,2484,329},
{2131,2481,330},
{2188,2482,330},
{2257,2482,330},
{2344,2486,329},
{2430,2482,330},
{2511,2483,329},
{2569,2486,329},
{2635,2485,329},
{2695,2483,329},
{2761,2482,330}
	
};
new const g_FireOrigin_room2[][ 3 ] = {
{73,340,55},
{58,153,55},
{89,-103,55},
{-111,-112,55},
{-283,-82,55},
{-337,78,55},
{-325,291,55},
{-159,362,55},
{-94,268,55},
{-110,114,55},
{-242,111,55},
{-246,255,55},
{-96,191,55},
{-266,353,55},
{133,-22,55},
{36,-205,55},
{35,-344,55},
{-144,-372,55},
{-175,-243,55},
{-293,-187,55},
{-334,-331,55},
{-412,110,55},
{-426,-125,55},
{-436,-255,55},
{-427,-327,55}
};

new g_gFireRoom;
new g_gReflexRoom;
new g_gHorizontalRoom;

new menu2,menu3;

new gBotCounter = 0;

// =========== WEAPON OFFSET CLASS ============ //
static const _HLW_to_rgAmmoIdx[] =
{
	0, 	// bos
	0,	// crowbar
	2, 	// 9mmhandgun
	5, 	// 357
	3, 	// 9mmAR
	4, 	// m203 
	8, 	// crossbow
	2, 	// shotgun
	7, 	// rpg
	6, 	// gauss
	6, 	// egon
	13,	// hornetgun
	11, // handgrenade
	9, 	// tripmine
	10, // satchel
	12  // snark
};

/* Top15  */
new gAuthScore[33][33];
new gNameScore[33][33];
new gKillScore[15];
new gScorePath[128];

new bool:g_chStarted[33];
new cv_ctime;


// WallHack area

new const SpritesPath[] = "sprites/hl_train/hl.spr";
new SpritePathIndex[33];
new EntitiesOwner;

new MaxPlayers;
const MaxSlots = 32;
new bool:g_CheckWh[MaxSlots+1];

enum Individual
{
	Host,
	Viewed
}

enum _:Vector
{
	X,
	Y,
	Z
}

enum OriginOffset
{
	FrameSide,
	FrameTop,
	FrameBottom,
}

enum FramePoint
{
	TopLeft,
	TopRight,
	BottomLeft,
	BottomRight
}

new Float:OriginOffsets[OriginOffset] =  {_:13.0,_:25.0,_:36.0};

new Float:ScaleMultiplier = 0.013;
new Float:ScaleLower = 0.005;

new Float:SomeNonZeroValue = 1.0;

new ForwardAddToFullPack;

new bool:whMessage[33];

public plugin_precache()
{
	precache_sound("fvox/bell.wav")

	if(!dir_exists(gScorePath))
		mkdir(gScorePath)

	SpritePathIndex[0] = precache_model(SpritesPath)
}

public plugin_init() 
{

	register_plugin(
		PLUGIN,		//: HL Aim Training
		VERSION,	//: 1.0.0
		AUTHOR		//: teylo
	);
	
	register_forward(FM_Think, "fwd_Think", 0);
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	register_clcmd("say /train", "ShowMenuS", _, "Open training menu");
	RegisterHam(Ham_Use, "func_button", "fwd_Room", 0);
	RegisterHam(Ham_Spawn, "player", "playerSpawn",true);
	RegisterHam(Ham_Killed, "player", "MTBot_BotDeath", 1);
	RegisterHam(Ham_Killed, "player", "fwdKilledPost");
	RegisterHam(Ham_TakeDamage, "player", "BotTakeDamage");

	g_iMaxPlayers = get_maxplayers();
	create_fake_timer();
	set_task( 0.9, "fwd_Info", 0, _, _, "b" );

	// remove corpses, weaponbox and gibs (organs)
	register_forward(FM_PlayerPreThink, "Fw_FmPlayerPreThinkPost", 1);
	set_task(1.0,"remove_gib");
	set_task(SECONDS,"clear_weaponbox",_,_,_,"b");
	set_task(2.0,"timeControl",_,_,_,"b");

	// top 15 area
	register_clcmd("say /ctop15", "show_top15");
	format(gScorePath,sizeof(gScorePath),"addons/amxmodx/data/train_top15/");
	cv_ctime = register_cvar("train_ctime","1.5"); //mins
	read_top15();

}

public plugin_cfg()
{
	EntitiesOwner = create_entity("info_target")
	
	MaxPlayers = get_maxplayers()
	
	for(new id=1;id<=MaxPlayers;id++)
		createSprite(id,EntitiesOwner)	
	
}

// if 10 seconds untill the end of the map display statistics
public timeControl(id)
{
	if(get_timeleft() == 10)
	{
		get_players(players, inum)
	
		for(new i; i < inum; i++) 
		{
			player = players[i]
	
			if (!is_user_bot(player))
			{
				clcmdResetTimer(players[i]);
			}
		}
		
	}	
}

stock hl_set_ammo(client, weapon, ammo)
{
	if (weapon <= HLW_CROWBAR)
		return;
	set_ent_data(client, "CBasePlayer", "m_rgAmmo", ammo, _HLW_to_rgAmmoIdx[weapon]);
}

public ShowMenuS(id)
{
	new menus = menu_create("Teylo AIM Training", "mh_MyMenuS");

	menu_additem(menus, "Classic Training", "1", 0); 
	menu_additem(menus, "Spawn Training", "2", 0); 
	menu_additem(menus, "Training Maps", "3", 0); 
	menu_additem(menus, "Challange", "4", 0); 


	menu_setprop(menus, MPROP_EXIT, MEXIT_ALL);
	//menu_setprop(menu, MPROP_NOCOLORS, 1);
	//menu_setprop(menu, MPROP_NUMBER_COLOR, "\w");

	menu_display(id, menus, 0);
	return PLUGIN_HANDLED;
}

public ShowMenu(id)
{
	new menu = menu_create("Classic Training Menu", "mh_MyMenu");

	menu_additem(menu, "Start/Reset training", "1", 0); 
	menu_additem(menu, "Start/Reset training - no ammo", "2", 0);
	menu_additem(menu, "Stop training", "3", 0); 
	menu_additem(menu, "Add more bots", "4", 0); 
	menu_additem(menu, "Kick a bot", "5", 0); 
	menu_additem(menu, "Boost bots HP - 200/200", "6", 0);
	menu_additem(menu, "Freeze bots", "7", 0); 
	menu_additem(menu, "Unfreeze bots", "8", 0); 
	menu_additem(menu, "Killing Blue Fade <ON/OFF>", "9", 0);
	menu_additem(menu, "Drop weaponbox <ON/OFF>", "10", 0);	
	menu_additem(menu, "WallHack <ON/OFF>", "11", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	//menu_setprop(menu, MPROP_NOCOLORS, 1);
	//menu_setprop(menu, MPROP_NUMBER_COLOR, "\w");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ShowMenu2(id)
{
	// bot level menu
		menu2 = menu_create("Add bot by level:", "mh_MyMenu2");
		menu_additem(menu2, "Add bot level 1 (highest)", "1", 0);
		menu_additem(menu2, "Add bot level 2", "2", 0);
		menu_additem(menu2, "Add bot level 3", "3", 0);
		menu_additem(menu2, "Add bot level 4", "4", 0);
		menu_additem(menu2, "Add bot level 5 (lowest)", "5", 0);
		menu_setprop(menu2, MPROP_EXIT, MEXIT_ALL);
		
		menu_display(id, menu2, 0);
		return PLUGIN_HANDLED;
}

public ShowMenu3(id)
{
	// bot level menu
		menu3 = menu_create("Spawn Training Menu", "mh_MyMenu3");
		menu_additem(menu3, "Add a moving bot", "1", 0);
		menu_additem(menu3, "Add a stationary bot (fast spawn)", "2", 0);
		menu_additem(menu3, "Remove bots", "3", 0);
		menu_additem(menu3, "Show Spawn Info <ON/OFF>", "4", 0);
		menu_additem(menu3, "Show Damage info <ON/OFF>", "5", 0);
		menu_additem(menu3, "Killing Blue Fade <ON/OFF>", "6", 0);
		menu_additem(menu3, "Drop weaponbox <ON/OFF>", "7", 0);
		menu_additem(menu3, "WallHack <ON/OFF>", "8", 0);
		menu_setprop(menu3, MPROP_EXIT, MEXIT_ALL);
		
		
		menu_display(id, menu3, 0);
		return PLUGIN_HANDLED;
}

public ShowMenu4(id)
{
	new menu = menu_create("Choose the training map", "mh_MyMenu4");

	menu_additem(menu, "[AIM-training] teylo_training_facility", "1", 0); 
	menu_additem(menu, "[AIM-training] aimtrainingcenter", "2", 0); 
	menu_additem(menu, "[AIM-training] aim_training", "3", 0); 
	menu_additem(menu, "[AIM-training] hlaim_train", "4", 0); 
	menu_additem(menu, "[AIM-training] fire_training_facility", "5", 0); 
	menu_additem(menu, "[AIM-training] fire_reflex_training", "6", 0); 
	menu_additem(menu, "[AIM-training] ptk_aimtracking2", "7", 0);
	menu_additem(menu, "[AIM-training] fire_horizontal", "8", 0);
	menu_additem(menu, "[BHOP-training] test_ro", "9", 0); 
	menu_additem(menu, "[BHOP-training] test_ro2", "10", 0); 

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	//menu_setprop(menu, MPROP_NOCOLORS, 1);
	//menu_setprop(menu, MPROP_NUMBER_COLOR, "\w");

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public mh_MyMenuS(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new key = str_to_num(data);
	switch(key) 
	{
		case 1: 
		{ 
			client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Classic Training");
			// verification for bots menu
			gVerif = 1;
			menu_destroy(menu);
			ShowMenu(id);
		}
		case 2: 
		{
			client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Spawn Training");
			// verification for bots menu
			gVerif = 2;
			menu_destroy(menu);
			ShowMenu3(id);
		}
		case 3: 
		{
			client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Training Maps");
			menu_destroy(menu);
			ShowMenu4(id);
		}
		case 4: 
		{
			challangeTrain(id);
		}	

	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public mh_MyMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		ShowMenuS(id);
		return PLUGIN_HANDLED;
	}

	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new key = str_to_num(data);
	switch(key) 
	{
		case 1: 
		{ 
			g_StartAmmo = true;
			classicTrain(id);
		}
		case 2: 
		{
			g_StartAmmo = false;
			classicTrain(id);
		}
		case 3: 
		{
			clcmdResetTimer(id);
		}
		case 4: 
		{
			menu_destroy(menu);
			ShowMenu2(id);
		}
		case 5: 
		{ 
			//client_print(id, print_chat, "You have selected to Kick a bot");
			kickBot(id);
		}
		case 6: 
		{ 
			switch_hp(id);
		}
		case 7: 
		{ 
			client_print(id, print_chat, "^^8[Classic Training] ^^5You have selected Freeze bots");
			g_Freeze = true;
			cmdFreeze();	
			
		}
		case 8: 
		{
			client_print(id, print_chat, "^^8[Classic Training] ^^5You have selected Unfreeze bots");
			g_Freeze = false;
			cmdUnfreeze();	
		}
		case 9: 
		{
			switch_fade(id);
		}	
		case 10: 
		{
			switch_weaponbox(id);
		}
		case 11: 
		{
			switch_wh(id);
		}			
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public mh_MyMenu2(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		// Show the right menu on exit : Classic or Spawn training
		if (gVerif == 1 )
			ShowMenu(id);
		if (gVerif == 2 )
			ShowMenu3(id);
		return PLUGIN_HANDLED;
	}
	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
		
	new key = str_to_num(data);

	switch(key)
	{
		case 1: 
		{
			server_cmd("jk_botti addbot ^"green^" ^"^" ^"1^"");
			new num, players[32];
			get_players(players,num); 
			client_print(id, print_chat, "^^8[AIM Training] You added a Level ^^11 ^^8bot. There are ^^1%d ^^8bots added to the server", num);	
			gBotCounter +=1
		
		}
		case 2: 
		{
			server_cmd("jk_botti addbot ^"green^" ^"^" ^"2^"");
			new num, players[32];
			get_players(players,num); 
			client_print(id, print_chat, "^^8[AIM Training] You added a Level ^^12 ^^8bot. There are ^^1%d ^^8bots added to the server", num);	
			gBotCounter +=1
		}
		case 3: 
		{
			server_cmd("jk_botti addbot ^"green^" ^"^" ^"3^"");
			new num, players[32];
			get_players(players,num); 
			client_print(id, print_chat, "^^8[AIM Training] You added a Level ^^13 ^^8bot. There are ^^1%d ^^8bots added to the server", num);
			gBotCounter +=1
		}
		case 4: 
		{
			server_cmd("jk_botti addbot ^"green^" ^"^" ^"4^"");
			new num, players[32];
			get_players(players,num); 
			client_print(id, print_chat, "^^8[AIM Training] You added a Level ^^14 ^^8bot. There are ^^1%d ^^8bots added to the server", num);
			gBotCounter +=1
		}
		case 5: 
		{
			server_cmd("jk_botti addbot ^"green^" ^"^" ^"5^"");
			new num, players[32];
			get_players(players,num); 
			client_print(id, print_chat, "^^8[AIM Training] You added a Level ^^15 ^^8bot. There are ^^1%d ^^8bots added to the server", num);	
			gBotCounter +=1
		}
	}
	menu_display(id, menu2, 0);
	return PLUGIN_HANDLED;
}

public mh_MyMenu3(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		ShowMenuS(id);
		return PLUGIN_HANDLED;
	}

	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new key = str_to_num(data);
	switch(key) 
	{
		case 1: 
		{ 
			client_print(id, print_chat, "^^8[Spawn Training] ^^2You choosed a moving bot");
			menu_destroy(menu)
			ShowMenu2(id)
		}
		case 2: 
		{ 
			client_print(id, print_chat, "^^8[Spawn Training] ^^2You added a stationary bot");
			MTBot_Make(id)
			gBotCounter +=1
		}		
		case 3: 
		{ 
			client_print(id, print_chat, "^^8[Spawn Training] ^^1You removed the all the bots");
			MTBot_Remove(id)
			gBotCounter =0
		}			
		case 4: 
		{
			switch_spawn(id)
		}
		case 5: 
		{
			switch_dmg(id)
		}	
		case 6: 
		{
			switch_fade(id);
		}
		case 7:
		{
			switch_weaponbox(id);
		}
		case 8: 
		{
			switch_wh(id);
		}		
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public mh_MyMenu4(id, menu, item)
{

	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		ShowMenuS(id);
		return PLUGIN_HANDLED;
	}

	new data[6], iName[64];
	new access, callback;
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);

	new key = str_to_num(data);
	switch(key) 
	{
		case 1: 
		{ 
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1teylo_training_facility")
			menu_destroy(menu)
			server_cmd("amx_votemap teylo_training_facility")
		}
		case 2: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1aimtrainingcenter")
			menu_destroy(menu);
			server_cmd("amx_votemap aimtrainingcenter")
		}
		case 3: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1aim_training")
			server_cmd("amx_votemap aim_training")
			menu_destroy(menu);
		}
		case 4: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1hlaim_train")
			server_cmd("amx_votemap hlaim_train")
			menu_destroy(menu);
		}	
		case 5: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1fire_training_facility")
			server_cmd("amx_votemap fire_training_facility")
			menu_destroy(menu);
		}	

		case 6: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1fire_reflex_training")
			server_cmd("amx_votemap fire_reflex_training")
			menu_destroy(menu);
		}

		case 7: 
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1ptk_aimtracking2")
			server_cmd("amx_votemap ptk_aimtracking2")
			menu_destroy(menu);
		}
		case 8:
		{
			client_print(id, print_chat, "^^8[Classic Training] You have selected the aim training map ^^1fire_horizontal")
			server_cmd("amx_votemap fire_horizontal")
			menu_destroy(menu);
		}
		case 9: 
		{ 
			client_print(id, print_chat, "^^8[Classic Training] You have selected the bhop training map ^^1test_ro")
			menu_destroy(menu);
			server_cmd("amx_votemap test_ro")
		}
		case 10: 
		{ 
			client_print(id, print_chat, "^^8[Classic Training] You have selected the bhop training map ^^1test_ro2")
			menu_destroy(menu);
			server_cmd("amx_votemap test_ro2")
		}
		
	}
	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public kickBot(id)
{
	get_players(players, inum)

	client_cmd(0, "spk vox/destroyed.wav")
	
	for(new i; i < inum; i++) {
		player = players[i]
		if (is_user_bot(player) ){
			server_cmd("kick #%i", get_user_userid(players[i]))
			gBotCounter -=1
			client_print(id, print_chat, "^^8[AIM Training] There are ^^1%d ^^8bots left", gBotCounter)
			i = inum
		}
	}

}

public cmdFreeze()
{

	get_players(players, inum)
	
	for(new i; i < inum; i++) {
		player = players[i]
	
		if (is_user_bot(player))
		{
			set_user_maxspeed(players[i], 1.0);
			set_user_gravity(players[i],10.0);
			hl_strip_user_weapons(players[i]);

		}
	}
	
} 

public cmdUnfreeze()
{	
	get_players(players, inum)
	
	for(new i; i < inum; i++) {
		player = players[i]
	
		if (is_user_bot(player))
		{
			set_user_maxspeed(player, get_cvar_float("sv_maxspeed"));
			set_user_gravity(player,1.0);

		}
	}
}

public fwd_Room(iEnt, id)
{
	// get the func button entity by name 
	new szTarget[32];
	pev(iEnt, pev_target, szTarget, 31);

	// FIRE HORIZONTAL CONVEYOR ROOM
	// room 1
	if ((equal(szTarget, "con")) && !is_user_bot(id) )
		{	
			g_gHorizontalRoom = 1;
			killBots();
			cmdFreeze()
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Horizontal Training ^^8- Good luck!");
		}
	//room 2
	if ((equal(szTarget, "roomt")) && !is_user_bot(id) )
		{	
			g_gHorizontalRoom = 2;
			killBots();
			cmdUnfreeze()
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Horizontal Strafes ^^8- Good luck!");
		}			

	// FIRE REFLEX + VERTICAL AIM TRAINING 
	//room 1
	if ((equal(szTarget, "reflexControl")) && !is_user_bot(id) )
		{	
			g_gReflexRoom = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Reflex Training - Bottom ^^8- Good luck!");
		}
	if ((equal(szTarget, "reflexControlMid")) && !is_user_bot(id) )
		{	
			g_gReflexRoom = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Reflex Training - Center ^^8- Good luck!");
		}

	if ((equal(szTarget, "reflexControlHigh")) && !is_user_bot(id) )
		{	
			g_gReflexRoom = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Reflex Training - Top ^^8- Good luck!");
		}
	//room 2
	if ((equal(szTarget, "floorscontrol")) && !is_user_bot(id) )
		{	
			g_gReflexRoom = 2;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Floors Control ^^8- Good luck!");
		}	
	//room 3
	if ((equal(szTarget, "verticalcontrol")) && !is_user_bot(id) )
		{	
			g_gReflexRoom = 3;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 3 ^^8- ^^2Vertical Control ^^8- Good luck!");
		}	


	// FIRE TRAINING MAP //
	//room 1
	if ((equal(szTarget, "tele_master1")) && !is_user_bot(id) )
		{	
			g_gFireRoom = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Training 9mmAR ^^8- Good luck!");
		}
		
	//room 2
	if ((equal(szTarget, "tele_master")) && !is_user_bot(id) )
		{	
			g_gFireRoom = 2;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Training gauss/crossbow with flying enemy ^^8- Good luck!");
		}


	// NOEL TRAINING MAP //

	//room 1
	if ((equal(szTarget, "tele_master_0_1")) && !is_user_bot(id) )
		{	
			g_gRoom = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Training gauss ^^8- Good luck!");
		}
		
	//room 2
	if ((equal(szTarget, "tele_master_0_2")) && !is_user_bot(id) )
		{	
			g_gRoom = 2;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Training gauss bouncing ^^8- Good luck!");
		}
		
	//room 3
	if ((equal(szTarget, "tele_master_0_3")) && !is_user_bot(id) )
		{	
			g_gRoom = 3;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 3 ^^8- ^^2Training RPG on conveyors ^^8- Good luck!");
		}
		
	//room 4
	if ((equal(szTarget, "tele_master_0_4")) && !is_user_bot(id) )
		{	
			g_gRoom = 4;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 4 ^^8- ^^2Training 9mmAR & shotgun ^^8- Good luck!");
		}
		
	//room 5
	if ((equal(szTarget, "tele_master_0_5")) && !is_user_bot(id) )
		{	
			g_gRoom = 5;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 5 ^^8- ^^2Training handgrenade & satchel ^^8- Good luck!");
		}
	//room 6
	if ((equal(szTarget, "tele_master_0_6")) && !is_user_bot(id) )
		{	
			g_gRoom = 6;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 6 ^^8- ^^2Training 357 ^^8- Good luck!");
		}		
		
	// NEO map aimtraining center
	// room 1 - 9mmAR
	if ((equal(szTarget, "teleport_room1")) && !is_user_bot(id) )
		{	
			g_gRoom_aim = 1;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Training 9mmAR ^^8- Good luck!");
		}
	// room 2 - gauss
	if ((equal(szTarget, "teleport_room2")) && !is_user_bot(id) )
		{	
			g_gRoom_aim = 2;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Training gauss ^^8- Good luck!");
		}
	// room 3 - crossbow
	if ((equal(szTarget, "teleport_room3")) && !is_user_bot(id) )
		{	
			g_gRoom_aim = 3;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 3 ^^8- ^^2Training crossbow ^^8- Good luck!");
		}
	// room 4 - rpg
	if ((equal(szTarget, "teleport_room4")) && !is_user_bot(id) )
		{	
			g_gRoom_aim = 4;
			killBots();
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 4 ^^8- ^^2Training RPG ^^8- Good luck!");
		}	
	
		
}

public client_putinserver(id)
{
	gConnexion[id]=1;
	client_cmd(id,"violence_agibs 0");
	client_cmd(id,"violence_hgibs 0");
}

public client_disconnected(id)
{
	if(gConnexion[id]==1)
	{
		// redisplay bones when disconnected
		client_cmd(id,"violence_agibs 1");
		client_cmd(id,"violence_hgibs 1");
		gConnexion[id]=0;
	}
	
	clcmdResetTimer(id);
	remove_task(id);
	whMessage[id] = false;
	//menu_cancel(id);
	return PLUGIN_HANDLED;

}


public playerSpawn(id)
{
	// Teleport to center in hlaim_training map
	new map_name[10];
	get_mapname(map_name, charsmax(map_name));
	if ( containi(map_name, "hlaim" ) != -1 && !is_user_bot(id)) 
	{
		client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Center Room ^^8- ^^2Training all weapons ^^8- Good luck!");
		set_user_origin(id,g_fOrigin_hlaim[0]);
	}

	
	// spawn training bot respawn 
	MTBot_AGRespawn(id)

	// Boost BOT HP
	if (g_BoostBotHP)
		{
			hl_set_user_health(id,200);
			hl_set_user_armor(id,200);
		}

	// FIRE Horizontal training map /////////////////////////////////////
	// room 1 - conveyors
	if((g_gHorizontalRoom == 1) && (is_user_bot(id)))
	{
		new num1=random_num(0,24);
		set_user_origin(id,g_botOrigin_horizontal[num1]);
		if (is_user_alive(id)) 
		{
			hl_strip_user_weapons(id);
			set_user_maxspeed(id, 1.0);
			set_user_gravity(id,10.0);
		}
	}
	// room 2 - strafes
	if((g_gHorizontalRoom == 2) && (is_user_bot(id)))
	{
		new num1=random_num(0,2);
		set_user_origin(id,g_botOrigin_horizontal2[num1]);
		if (is_user_alive(id)) 
		{
			give_item( id, "weapon_gauss" );
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			hl_set_user_longjump(id,true);
		}
	}
	

	// FIRE Reflex map //////////////////////////////////////////////////

	// Reflex room
	if((g_gReflexRoom == 1) && (is_user_bot(id)))
	{
		
		new originReflex[3];
		// set a random origin in the cube
		originReflex[0]=random_num(-1400,-70);
		originReflex[1]=random_num(1150,2400);
		originReflex[2]=random_num(63,810);
		set_user_origin(id,originReflex);
		hl_strip_user_weapons(id)
	}

	// Floor room
	if((g_gReflexRoom == 2) && (is_user_bot(id)))
	{
		new num1=random_num(0,49);
		set_user_origin(id,g_botOrigin_vertical1[num1]);
	}
	// Vertical control room 
	if((g_gReflexRoom == 3) && (is_user_bot(id)))
	{
		new num1=random_num(0,6);
		set_user_origin(id,g_botOrigin_vertical2[num1]);
	}

	// FIRE Map
	if((g_gFireRoom == 1) && (is_user_bot(id)))
	{
		new num1=random_num(0,16);
		set_user_origin(id,g_FireOrigin_room1[num1]);
		if (is_user_alive(id)) 
		{
			give_item( id, "weapon_9mmAR" );
			give_item( id, "weapon_shotgun" );
			hl_set_ammo( id,HLW_MP5,250); 
			hl_set_ammo( id,HLW_SHOTGUN,250); 
		}
	}
	
	//room 2 - bot bouncing
	if((g_gFireRoom == 2) && (is_user_bot(id)))
	{
		new num2=random_num(0,24);
		set_user_origin(id,g_FireOrigin_room2[num2]); 
		if (is_user_alive(id)) 
		{
			give_item( id, "weapon_9mmAR" );
			give_item( id, "weapon_shotgun" );
			hl_set_ammo( id,HLW_MP5,250); 
			hl_set_ammo( id,HLW_SHOTGUN,250); 
		}
	}

	// NOEL Map
	// room 1 - gauss
	if((g_gRoom == 1) && (is_user_bot(id)))
	{
		new num1=random_num(0,18);
		set_user_origin(id,g_fOrigin_room1[num1]);
		if (is_user_alive(id)) 
		{
			give_item( id, "weapon_gauss" );
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			give_item( id, "ammo_gaussclip" );	
			hl_set_user_longjump(id,true);
		}
	}
	
	//room 2 - gauss bouncing
	if((g_gRoom == 2) && (is_user_bot(id)))
		{
			new num2=random_num(0,17);
			set_user_origin(id,g_fOrigin_room2[num2]); 
			give_item( id, "weapon_gauss" );
			hl_set_ammo(id,HLW_GAUSS,99); 	
		}
	
	//room 3 - rpg
	if((g_gRoom == 3) && (is_user_bot(id)))
	{
		new num3=random_num(0,16);
		set_user_origin(id,g_fOrigin_room3[num3]); 
		hl_set_user_longjump(id,true);
	}
	//room 4 - 9mmar +shotgun
	if((g_gRoom == 4) && (is_user_bot(id)))
	{
		new num4=random_num(0,12);
		set_user_origin(id,g_fOrigin_room4[num4]); 
		give_item( id, "weapon_9mmAR" );
		give_item( id, "weapon_shotgun" );
		hl_set_ammo(id,HLW_MP5,250); 
		hl_set_ammo(id,HLW_SHOTGUN,250); 
		hl_set_user_longjump(id,true);	
	}
	//room 5 - handgrenade & satchel
	if((g_gRoom == 5) && (is_user_bot(id)))
	{
		new num5=random_num(0,12);
		set_user_origin(id,g_fOrigin_room5[num5]); 
	}	
	//room 6 - 357
	if((g_gRoom == 6) && (is_user_bot(id)))
	{
		new num6=random_num(0,17);
		set_user_origin(id,g_fOrigin_room6[num6]); 
	}	
	
	
	// NEO aimtraining map
	
	// room 1 - 9mmAR
	if((g_gRoom_aim == 1) && (is_user_bot(id)))
	{
		new num_aim1=random_num(0,19);
		set_user_origin(id,g_fOrigin_aim_room1[num_aim1]); 
		give_item( id, "weapon_9mmAR" );
		give_item( id, "weapon_shotgun" );
		hl_set_ammo(id,HLW_MP5,250); 
		hl_set_ammo(id,HLW_SHOTGUN,250); 
		hl_set_user_longjump(id,true);
	}
	
	// room 2 - gauss
	if((g_gRoom_aim == 2) && (is_user_bot(id)))
	{
		new num_aim2=random_num(0,19);
		set_user_origin(id,g_fOrigin_aim_room2[num_aim2]); 
		give_item( id, "weapon_gauss" );
		hl_set_ammo(id,HLW_GAUSS,99); 	
		hl_set_user_longjump(id,true);
	}
	
	// room 3 - crossbow
	if((g_gRoom_aim == 3) && (is_user_bot(id)))
	{
		new num_aim3=random_num(0,17);
		set_user_origin(id,g_fOrigin_aim_room3[num_aim3]); 
		give_item( id, "weapon_crossbow" );
		hl_set_ammo(id,HLW_CROSSBOW,999999);
		hl_set_user_longjump(id,true);
	}
	
	// room 4 - RPG
	if((g_gRoom_aim == 4) && (is_user_bot(id)))
	{
		new num_aim4=random_num(0,19);
		set_user_origin(id,g_fOrigin_aim_room4[num_aim4]); 
		hl_set_user_longjump(id,true);
	}
	
	// freeze bots if freeze is on
	if ((g_Freeze == true) && (is_user_bot(id)))
	{
		set_user_maxspeed(id, 1.0);
		set_user_gravity(id,10.0);
		hl_strip_user_weapons(id);
	}
	
}

public killBots()

{
	get_players(players, inum)
	
	for(new i; i < inum; i++) {
		player = players[i]
	
		if (is_user_bot(player) )
		{
			user_kill(players[i]);
		}
	}
}

public fwd_Info() 
{
	set_hudmessage(255, 255, 255, 0.01, 0.18, 0, 0.0, 1.0, 0.0, 0.0, -1 );
	show_hudmessage(0, "[teylo AIM training MOD] Say /train to start training !!!");
}


public create_fake_timer()
{
	new iEnt = fm_create_entity("info_target");
	set_pev(iEnt,pev_classname, g_szClassname);
	set_pev(iEnt, pev_nextthink, get_gametime() + 1.0);
}

public classicTrain(id)

{
	// verify if challange started
	if (g_chStarted[id] )
	{	
		client_print(id, print_chat, "^^8[Challange Training] ^^1You can't start another after starting a challange!");
		return PLUGIN_HANDLED;
	}

	if( !is_user_alive( id ) )
	{  
		client_print( id, print_chat, "^^8[Classic Training] ^^1You can't use this command while you are dead." );  
		return PLUGIN_HANDLED; 
	} 
	client_print(id, print_chat, "^^8[Classic Training] ^^2You have selected Start/Reset training");
	// start timer
	clcmdStartTimer(id);
	return PLUGIN_HANDLED;
}

public challangeTrain(id)
{
	
	if( !is_user_alive( id ) )
	{  
		client_print( id, print_chat, "^^8[Challange Training] ^^1You can't use this command while you are dead." );  
		return PLUGIN_HANDLED; 
	}

	if (g_chStarted[id])
	{
		client_print( id, print_chat, "^^8[Challange Training] ^^1You already started a challange." );  
		return PLUGIN_HANDLED; 
	}

	if (g_bStarted[id])
	{
		client_print( id, print_chat, "^^8[Challange Training] ^^1You already started a training." );  
		return PLUGIN_HANDLED; 
	}	

	g_chStarted[id] = true;

	client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have started a challenge! Do the most score/min !");
	// remove all bots for the challange
	MTBot_Remove(id)
	// add a level 1 bot
	server_cmd("jk_botti addbot ^"green^" ^"^" ^"1^"");
	// start timer + all weapons
	g_StartAmmo = true;
	clcmdStartTimer(id);
	// stop timer after x seconds set in the cvar 
	set_task(get_pcvar_float(cv_ctime)*60,"clcmdResetTimer",id);
	return PLUGIN_HANDLED;
}

public clcmdStartTimer(id)
{

	if (is_user_alive(id))
	{
		give_weapons(id);

		if(!g_bStarted[id])
			g_bStarted[id] = true;
		
		g_fStart[id] = get_gametime();
	}
}


public clcmdResetTimer(id)
{

	// Classic train timer 
	if (g_bStarted[id] == true)
	{
		// Challange part
		if (g_chStarted[id] == true)
		{
			client_print(id, print_chat, "^^8[Challange Training] Challange finished! Use ^^2/ctop15 ^^8to see the best players !");
			check_top15(id);
			clientPrintColor(id, "^^8[Challange Training] You did ^^1%d ^^8kills in  ^^1%.1f ^^8sec. Kills per minute: ^^1%.1f ^^8.",g_iFrags[ id ], get_gametime() - g_fStart[id],g_iFrags[id]/(get_pcvar_float(cv_ctime)));
			g_chStarted[id] = false;	
		} else {
			clientPrintColor(id, "^^8[Training statistics] You did ^^1%d ^^8kills in  ^^1%.1f ^^8sec. Kills per minute: ^^1%.1f ^^8.",g_iFrags[ id ], get_gametime() - g_fStart[id],g_iFrags[id]/((get_gametime() - g_fStart[id])/60)); 
		}
		g_bStarted[id] = false;
		g_fStart[id] = 0.0;
		arrayset( g_iFrags, 0, sizeof( g_iFrags ) );
	} else {
		clientPrintColor(id, "^^8[Training statistics] ^^1You did not started a training");
	}


}

public fwd_Think(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED;
	
	static szClassname[32];
	pev(ent, pev_classname, szClassname, sizeof szClassname - 1);
	
	if(szClassname[0] != '_' && szClassname[1] != 't')
		return FMRES_IGNORED;
	
	for(new i = 1 ; i <= g_iMaxPlayers ; i++)
	{
		if(is_user_connected(i) && g_bStarted[i] && g_fStart[i] > 0.0)
		{
			if (g_chStarted[i])
			{
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 0.1, 0.1, 0.1, 1);
				show_hudmessage(i, "Time: %.1f/%.1f sec. ^nKill: %d", (get_gametime() - g_fStart[i]), (get_pcvar_float(cv_ctime)*60),g_iFrags[ i ]);
			} 
			else 
			{
				set_hudmessage(255, 255, 255, -1.0, 0.8, 0, 6.0, 0.1, 0.1, 0.1, 1);
				show_hudmessage(i, "Time: %.1f sec. ^nKill: %d", (get_gametime() - g_fStart[i]), g_iFrags[ i ]);
			}
		}
	}
	set_pev(ent, pev_nextthink, get_gametime() + 0.1);
	
	return FMRES_IGNORED;
}


public clientPrintColor( id, String[ ], any:... )
{
	new szMsg[ 190 ];
	vformat( szMsg, charsmax( szMsg ), String, 3 );
	
	replace_all( szMsg, charsmax( szMsg ), "!n", "^1" );
	replace_all( szMsg, charsmax( szMsg ), "!t", "^3" );
	replace_all( szMsg, charsmax( szMsg ), "!g", "^4" );
	
	static msgSayText = 0;
	static fake_user;
	
	if( !msgSayText )
	{
		msgSayText = get_user_msgid( "SayText" );
		fake_user = get_maxplayers( ) + 1;
	}
	
	message_begin( id ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, msgSayText, _, id );
	write_byte( id ? id : fake_user );
	write_string( szMsg );
	message_end( );
}

public Event_DeathMsg( ) 
{
		new iKiller = read_data( 1 );
		new iVictim = read_data( 2 );
	
		if( iVictim != iKiller ) {
		if(g_bStarted[iKiller])
		{
	   		 	g_iFrags[ iKiller ]++; 
			}	
	}

}

// ====== SPAWN EQUIP WEAPONS =========
public give_weapons(id) 
{

	// Teleport to center in hlaim_training map
	new map_name[10];
	get_mapname(map_name, charsmax(map_name));
	if ( containi(map_name, "hlaim" ) != -1 ) 
	{
		client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Center Room ^^8- ^^2Training all weapons ^^8- Good luck!");
		set_user_origin(id,g_fOrigin_hlaim[0]);
	}

	if(is_user_alive(id))
	{
			
			hl_set_user_health(id,999999);
			hl_set_user_armor(id,999999);

			if (g_StartAmmo)
			{
				hl_set_user_longjump(id,true);
				give_item( id, "weapon_crowbar" );	
				give_item( id, "weapon_9mmhandgun" );
				give_item( id, "weapon_gauss" );
				give_item( id, "weapon_egon" );
				give_item( id, "weapon_crossbow" );
				give_item( id, "weapon_rpg" );
				give_item( id, "weapon_satchel" );
				give_item( id, "weapon_snark" );
				give_item( id, "weapon_handgrenade" );		
				give_item( id, "weapon_hornetgun" );
				give_item( id, "weapon_tripmine" );
				give_item( id, "weapon_357" );
				give_item( id, "weapon_9mmAR" );
				give_item( id, "weapon_snark" );
				give_item( id, "weapon_shotgun" );

				restore_ammo(id);
			}
	}
}

// ====== RESTORE AMMO WHEN KILL =========
public restore_ammo(id) 
{
	// 9mmhandgun 

		hl_set_ammo(id,HLW_GLOCK,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_GLOCK)),999999);		

	// gauss 
		hl_set_ammo(id,HLW_GAUSS,999999); 	

	// egon 
		hl_set_ammo(id,HLW_EGON,999999);

	// crossbow 
		hl_set_ammo(id,HLW_CROSSBOW,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_CROSSBOW)),999999);		

	// rpg 
		hl_set_ammo(id,HLW_RPG,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_RPG)),999999);			
	
	//357
		hl_set_ammo(id,HLW_PYTHON,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_PYTHON)),999999);		

	//9mmAR
		hl_set_ammo(id,HLW_MP5,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_MP5)),999999);			
	
	// ammo ARgrenades
		hl_set_ammo(id,HLW_CHAINGUN,999999); 	
	
	//buckshot - shotgun
		hl_set_ammo(id,HLW_SHOTGUN,999999); 	
		hl_set_weapon_ammo((hl_user_has_weapon(id,HLW_SHOTGUN)),999999);		
	
	//satchel
		hl_set_ammo(id,HLW_SATCHEL,999999); 	

	
	//tripmine
		hl_set_ammo(id,HLW_TRIPMINE,999999); 	

	
	//handgrenade
		hl_set_ammo(id,HLW_HANDGRENADE,999999); 	
	
	//snark
		hl_set_ammo(id,HLW_SNARK,999999); 	
		
}

public remove_gib()
{	
	server_cmd("violence_agibs 0");
	server_cmd("violence_hgibs 0");
}


public clear_weaponbox()
{
	if(weaponbox == 1)
		return PLUGIN_HANDLED;

	// silah kutularini yok et
	new ent = 0;
	while ((ent = find_ent_by_class(ent, "weaponbox"))) {
		//hl_remove_wbox(ent);
		engfunc( EngFunc_RemoveEntity, ent );
	}	
	return PLUGIN_HANDLED;
}

public Fw_FmPlayerPreThinkPost(id)
{
	if (pev(id, pev_deadflag) == DEAD_RESPAWNABLE)
	{
		new effects = pev(id, pev_effects);
		if (!(effects & EF_NODRAW))
		{
			set_pev(id, pev_effects, effects | EF_NODRAW);
		}
	}
}

public MTBot_Make(id)
{

	new name[32]
	new bot_name[33] = "[Spawn Training] BOT"
	new bot_model[33] = "green"

	if (hl_get_user_spectator(id))
	{
		client_print(id, print_chat, "^^8[Spawn Training] ^^1You can't create a bot when you are a spectator!")
		return PLUGIN_HANDLED;
	}

	new playername[32]
	get_user_name(id, playername, charsmax(playername))

	formatex(name, 255, "%s %d", bot_name, random_num(100, 300)) 
	new id_bot = engfunc(EngFunc_CreateFakeClient, name)
	
	if(!id_bot) {
		client_print(id, print_chat, "^^8[Spawn Training] ^^1A bot can't join! This server may be full.")
	}

	if(pev_valid(id_bot)) {
		engfunc(EngFunc_FreeEntPrivateData, id_bot)
		dllfunc(MetaFunc_CallGameEntity, "player", id_bot)
		set_user_info(id_bot, "rate", "3500")
		set_user_info(id_bot, "cl_updaterate", "25")
		set_user_info(id_bot, "cl_lw", "1")
		set_user_info(id_bot, "cl_lc", "1")
		set_user_info(id_bot, "cl_dlmax", "128")
		set_user_info(id_bot, "_ah", "0")
		set_user_info(id_bot, "dm", "0")
		set_user_info(id_bot, "tracker", "0")
		set_user_info(id_bot, "friends", "0")
		set_user_info(id_bot, "*bot", "1" )
		hl_set_user_team(id_bot, bot_model)
		set_pev(id_bot, pev_flags, pev( id_bot, pev_flags ) | FL_FAKECLIENT)
		set_pev(id_bot, pev_colormap, id_bot)
		set_pev(id_bot, pev_gravity, 1.0)
		set_pev(id_bot, pev_health, 100)
		set_pev(id_bot, pev_weapons, 0)
		set_user_gravity(id_bot, 1.0)
		dllfunc(DLLFunc_ClientConnect, id_bot, "bot", "127.0.0.1")
		dllfunc(DLLFunc_ClientPutInServer, id_bot)
		engfunc(EngFunc_RunPlayerMove, id_bot, Float:{0.0,0.0,0.0}, 0.0, 0.0, 0.0, 0, 0, 76)
		set_pev(id_bot, pev_velocity, Float:{0.625,-235.5,0.0})
		engfunc(EngFunc_RunPlayerMove, id_bot, Float:{20.4425,270.4504,0.0}, 250.0, 0.0, 0.0, 0, 8, 10)
		pev(id_bot, pev_origin, 1.0)
		pev(id_bot, pev_velocity, 320.0)
		hl_user_spawn(id_bot)
		engfunc(EngFunc_DropToFloor, id_bot)
		set_pev(id_bot, pev_effects, (pev(id_bot, pev_effects) | 1 ))
		set_pev(id_bot, pev_solid, SOLID_BBOX)
		set_user_rendering(id_bot, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 100)

		if (hl_get_user_spectator(id_bot))
		{
			client_print(id, print_chat, "^^8[Spawn Training] ^^1You can't create a bot when match is started!")
			server_cmd("kick #%i", get_user_userid(id_bot))
		}
		else
		{
			client_print(0, print_chat, "^^8[Spawn Training] ^^2%s^^8 created a bot.", playername)
			get_bot_spawn(id_bot)
		}
	}

	return PLUGIN_CONTINUE;
}

public BotTakeDamage(victim, inflictor, attacker, Float:dmg, dmgbits)
{
	new BotDmgTaker[32]
	get_user_name(victim, BotDmgTaker, 31)

	if(is_user_bot(victim) && dmgMessage == 1 && dmg > 1.0 && victim != attacker && victim && inflictor && attacker)
		client_print(0, print_chat, "^^8[Spawn Training] ^^2%s ^^8take ^^2%.1f ^^8damage", BotDmgTaker, dmg);
}

public MTBot_BotDeath(id) {
	if (is_user_bot(id)  && !hl_get_user_spectator(id)) {
		set_task(1.1, "MTBot_Respawn", id)
	}


}

public MTBot_AGRespawn(id)
{
	get_user_info(id, "*bot", is_bot, 255)
	if (str_to_num(is_bot) != 0) {
		engfunc(EngFunc_DropToFloor, id)
	}
}

public MTBot_Respawn(id)
{
	get_user_info(id, "*bot", is_bot, 255)
	if (str_to_num(is_bot) != 0) {
		origin_fix[0] = 1000
		origin_fix[1] = -5000
		origin_fix[2] = 8100
	
		hl_user_spawn(id)
		get_bot_spawn(id)
		get_user_origin(id, origin_resp, 0)
		set_task(0.05, "MTBot_FixRender", id)
		set_user_origin(id, origin_fix)
	}
}


public MTBot_FixRender(id)
{
	set_user_origin(id, origin_resp)
	engfunc(EngFunc_DropToFloor, id)
}


public MTBot_Remove(id)
{
	get_players(players, inum)

	client_cmd(0, "spk vox/destroyed.wav")
	
	for(new i; i < inum; i++) {
		player = players[i]
		//get_user_info(player, "*bot", is_bot, 255)
		if (is_user_bot(player) ){
			server_cmd("kick #%i", get_user_userid(players[i]))
		}
	}
}

public switch_hp(id)
{	
	if(g_BoostBotHP==0)
	{
		g_BoostBotHP=1;
		client_print(0,print_chat,"^^8[Classic Training] ^^2Bots HP boosted to 200/200.");
	}else{
		g_BoostBotHP=0;
		client_print(0,print_chat,"^^8[Classic Training] ^^1Bots HP restored back to normal.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_spawn(id)
{	
	if(spawnMessage==0)
	{
		spawnMessage=1;
		client_print(id,print_chat,"^^8[Spawn Training] ^^2Spawn system activated.");
	}else{
		spawnMessage=0;
		client_print(id,print_chat,"^^8[Spawn Training] ^^1Spawn system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_dmg(id)
{
	if(dmgMessage==0)
	{
		dmgMessage=1;
		client_print(id,print_chat,"^^8[Spawn Training] ^^2Damage system activated.");
	}else{
		dmgMessage=0;
		client_print(id,print_chat,"^^8[Spawn Training] ^^1Damage system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_fade(id)
{
	if(blueFade==0)
	{
		blueFade=1;
		client_print(id,print_chat,"^^8[Spawn Training] ^^2Blue Fade Kill system activated.");
	}else{
		blueFade=0;
		client_print(id,print_chat,"^^8[Spawn Training] ^^1Blue Fade Kill system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_weaponbox(id)
{
	if(weaponbox==0)
	{
		weaponbox=1;
		client_print(id,print_chat,"^^8[Classic Training] ^^2Weaponbox system activated.");
	}else{
		weaponbox=0;
		client_print(id,print_chat,"^^8[Classic Training] ^^12Weaponbox system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public get_bot_spawn(id)
{
	new NameBot[32]
	new entlist[1]
	new ent = -1
	new count_spawn = 1
	get_user_name(id, NameBot, 31)
	find_sphere_class(id, "info_player_deathmatch", 50.0, entlist, sizeof entlist);

	while(entlist[0] != (ent = find_ent_by_class(ent, "info_player_deathmatch")))
	{
		count_spawn++
	}
	if (spawnMessage == 1)
		client_print(0, print_chat, "^^8[Spawn Training] ^^2%s ^^8spawned at ^^1%d ^^8spawn", NameBot, count_spawn);
}

public switch_wh(id)
{
	if(!whMessage[id])
	{
		whMessage[id]=true;
		handleTurnWallHackOn(id)
		client_print(id,print_chat,"^^8[Training] ^^2WallHack system activated.");
	}else{
		whMessage[id]=false;
		handleTurnWallHackOff(id)
		client_print(id,print_chat,"^^8[Training] ^^1WallHack system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public fwdKilledPost(victim, attacker, corpse)
{
		if(!is_user_connected(victim) || !is_user_connected(attacker) || victim == attacker)
			return HAM_IGNORED;

		if (blueFade == 0)
			return HAM_IGNORED;

		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), {0,0,0}, attacker)
		write_short(1<<10)
		write_short(1<<10)
		write_short(0x0000)
		write_byte(0)
		write_byte(0)
		write_byte(200)
		write_byte(75)
		message_end()
		return HAM_IGNORED;
}


///////////////// TOP 15 AREA //////////////////////
// Challange mode


public check_top15(id) 
{

	new name[32],authid[32]
	get_user_name( id, name, 31 )
	get_user_authid( id, authid ,31 )

	new iPlayerScore, iHighScore
	iPlayerScore = g_iFrags[id]
	if (gKillScore[14] == 9999999)
	{ 
		iHighScore = 0
	} 
	else 
	{	
		iHighScore = gKillScore[14]
	}

	if( iPlayerScore > iHighScore) {
		for( new i = 0; i < 15; i++ ) {
			if (gKillScore[i] == 9999999)
			{ 
				iHighScore = 0
			} 
			else 
			{	
					iHighScore = gKillScore[i];
			}
			
			if( iPlayerScore > iHighScore) 
			{
				new pos = i
				while( !equal( gAuthScore[pos], authid ) && pos < 14 )
					pos++
				for( new j = pos; j > i; j-- ) 
				{
					format( gAuthScore[j], 32, gAuthScore[j-1] )
					format( gNameScore[j], 32, gNameScore[j-1] )
					gKillScore[j] = gKillScore[j-1]
				}
			
				format( gAuthScore[i], 32, authid )
				format( gNameScore[i], 32, name )
				gKillScore[i] = g_iFrags[id]

				save_top15()
				return
			}
			if( equal( gAuthScore[i], authid ) )
				return
		}	
	}
	server_cmd("echo Check done!")
	return;
}


public save_top15() 
{

	new cMap[32]
	get_mapname(cMap, 31)

	new cScoreFile[128]	
	format(cScoreFile, 127, "%s%s.txt", gScorePath, cMap)

	if( file_exists(cScoreFile) )	
		delete_file(cScoreFile)
	
	for( new i = 0; i < 15; i++ ) {
		if( gKillScore[i] == 0)
			return PLUGIN_HANDLED
	
		new TextToSave[1024],sNameScore[33]
		format(sNameScore, 127, "^"%s^"", gNameScore[i])
		format(TextToSave,sizeof(TextToSave),"%31s %31s %9d",gAuthScore[i],sNameScore,gKillScore[i])
		write_file(cScoreFile, TextToSave)
	}
	server_cmd("echo Save done!")
	return PLUGIN_HANDLED;
}

public read_top15() 
{
	for( new i = 0 ; i < 15; i++) {
		gAuthScore[i] = "X"
		gNameScore[i] = "X"
		gKillScore[i] = 9999999
	}
	new cMap[32]
	get_mapname(cMap, 31)

	new cScoreFile[128]	
	format(cScoreFile, 127, "%s%s.txt", gScorePath, cMap)

	if(file_exists(cScoreFile) == 1) { 
		new line, stxtsize 
		new data[192] 
		new tAuth[32],tName[32],tKills[10]
		for(line = 0; line < 15; line++) {
			read_file(cScoreFile,line,data,191,stxtsize)
			parse(data,tAuth,31,tName,31,tKills,9)
			format(gAuthScore[line],sizeof(gAuthScore),tAuth)
			format(gNameScore[line],sizeof(gNameScore),tName)
			gKillScore[line] = str_to_num(tKills)
		}
	}
	else
	{
		server_cmd("echo [TOP Train] File created: ^"%s^"!!!",cScoreFile)
		log_message("[TOP Train] File created: ^"%s^"!!!",cScoreFile)
	}
	/*
	for( new i = 0 ; i < 15; ++i) 
	{
		server_cmd("echo [TOP Test %d] AuthScore: ^"%s^"",i,gAuthScore[i])
		server_cmd("echo [TOP Test %d] NameScore: ^"%s^"",i,gNameScore[i])
		server_cmd("echo [TOP Test %d] KillScore: ^"%.1f^"",i,float(gKillScore[i])/(get_pcvar_float(cv_ctime)*1.0))
	}*/

	return PLUGIN_HANDLED;
}

public show_top15(id) 
{
	
	new buffer[2048] 
	new line[256]
	new cMap[32]
	get_mapname(cMap, 31)
	
	new len = format( buffer, 2047, "" )
	len += format( buffer[len], 2047-len, "%5s  %31s  %5s ( %s )^n","Rank","Nick","Score/Min",cMap)

	for(new i = 0; i < 15; i++) {		
		if( gKillScore[i] == 9999999)
			format(line, 255, "%5d  %31s  %5s^n", (i+1), "-------", "-----" )
		else
		{
			// remove AG colored name format
			replace_string(gNameScore[i], 32, "^^0", "");
			replace_string(gNameScore[i], 32, "^^1", "");
			replace_string(gNameScore[i], 32, "^^2", "");
			replace_string(gNameScore[i], 32, "^^3", "");
			replace_string(gNameScore[i], 32, "^^4", "");
			replace_string(gNameScore[i], 32, "^^5", "");
			replace_string(gNameScore[i], 32, "^^6", "");
			replace_string(gNameScore[i], 32, "^^7", "");
			replace_string(gNameScore[i], 32, "^^8", "");
			replace_string(gNameScore[i], 32, "^^9", ""); 			
			format(line, 255, "%5d  %31s  %.1f^n", (i+1), gNameScore[i], float(gKillScore[i])/(get_pcvar_float(cv_ctime)*1.0))
		}
		len += format( buffer[len], 2047-len, line )
	}
	
	format(line, 255, "" )
	len += format( buffer[len], 2047-len, line )
		
	show_motd( id, buffer, "Train Top15")	
	
	return PLUGIN_HANDLED;
}


///////////////// WALLHACK AREA //////////////////////
// 

public createSprite(aiment,owner)	
{
	new sprite = create_entity("info_target")
	
	assert is_valid_ent(sprite);
	
	entity_set_edict(sprite,EV_ENT_aiment,aiment)	
	set_pev(sprite,pev_movetype,MOVETYPE_FOLLOW)
	
	entity_set_model(sprite,SpritesPath)
	
	set_pev(sprite,pev_owner,owner)

	set_pev(sprite,pev_solid,SOLID_NOT)
	
	fm_set_rendering(sprite,.render=kRenderTransAlpha,.amount=0)	
}

public addToFullPackPost(es, e, ent, host, hostflags, player, pSet)
{

	if((1<=host<=MaxPlayers) && is_valid_ent(ent))

	{		
		if(pev(ent,pev_owner) == EntitiesOwner)
		{
			if(engfunc(EngFunc_CheckVisibility,ent,pSet))
			{
				new spectated = host;
				
				new aiment = pev(ent,pev_aiment)
				
				if((spectated != aiment) && is_user_alive(aiment) )
				{
					static ID[Individual]
		
					ID[Host] = spectated
					ID[Viewed] = ent
					
					static Float:origin[Individual][Vector]
					
					entity_get_vector(ID[Host],EV_VEC_origin,origin[Host])
					get_es(es,ES_Origin,origin[Viewed])
					
					static Float:diff[Vector]
					static Float:diffAngles[Vector]
					
					xs_vec_sub(origin[Viewed],origin[Host],diff)			
					xs_vec_normalize(diff,diff)         
					
					vector_to_angle(diff,diffAngles)
					
					diffAngles[0] = -diffAngles[0];
					
					static Float:framePoints[FramePoint][Vector]
					
					calculateFramePoints(origin[Viewed],framePoints,diffAngles)			
					
					static Float:eyes[Vector]
					
					xs_vec_copy(origin[Host],eyes)
					
					static Float:viewOfs[Vector]			
					entity_get_vector(ID[Host],EV_VEC_view_ofs,viewOfs);
					xs_vec_add(eyes,viewOfs,eyes);
					
					static Float:framePointsTraced[FramePoint][Vector]
					
					static FramePoint:closerFramePoint
					
					if(traceEyesFrame(ID[Host],eyes,framePoints,framePointsTraced,closerFramePoint))
					{
						static Float:otherPointInThePlane[Vector]
						static Float:anotherPointInThePlane[Vector]
						
						static Float:sideVector[Vector]
						static Float:topBottomVector[Vector]
						
						angle_vector(diffAngles,ANGLEVECTOR_UP,topBottomVector)
						angle_vector(diffAngles,ANGLEVECTOR_RIGHT,sideVector)
						
						xs_vec_mul_scalar(sideVector,SomeNonZeroValue,otherPointInThePlane)
						xs_vec_mul_scalar(topBottomVector,SomeNonZeroValue,anotherPointInThePlane)	
						
						xs_vec_add(otherPointInThePlane,framePointsTraced[closerFramePoint],otherPointInThePlane)
						xs_vec_add(anotherPointInThePlane,framePointsTraced[closerFramePoint],anotherPointInThePlane)
						
						static Float:plane[4]
						xs_plane_3p(plane,framePointsTraced[closerFramePoint],otherPointInThePlane,anotherPointInThePlane)
						
						moveToPlane(plane,eyes,framePointsTraced,closerFramePoint);
						
						static Float:middle[Vector]
						
						static Float:half = 2.0
						
						xs_vec_add(framePointsTraced[TopLeft],framePointsTraced[BottomRight],middle)
						xs_vec_div_scalar(middle,half,middle)
						
						new Float:scale = ScaleMultiplier * vector_distance(framePointsTraced[TopLeft],framePointsTraced[TopRight])
						
						if(scale < ScaleLower)
							scale = ScaleLower;
						
						set_es(es,ES_AimEnt,0)
						set_es(es,ES_MoveType,MOVETYPE_NONE)
						set_es(es,ES_ModelIndex,SpritePathIndex[0])
						set_es(es,ES_Scale,scale)
						set_es(es,ES_Angles,diffAngles)
						set_es(es,ES_Origin,middle)
						set_es(es,ES_RenderMode,kRenderNormal)
					}
				}
			}
		}
	}
}

public calculateFramePoints(Float:origin[Vector],Float:framePoints[FramePoint][Vector],Float:perpendicularAngles[Vector])
{
	new Float:sideVector[Vector]
	new Float:topBottomVector[Vector]
	
	angle_vector(perpendicularAngles,ANGLEVECTOR_UP,topBottomVector)
	angle_vector(perpendicularAngles,ANGLEVECTOR_RIGHT,sideVector)
	
	new Float:sideDislocation[Vector]
	new Float:bottomDislocation[Vector]
	new Float:topDislocation[Vector]
	
	xs_vec_mul_scalar(sideVector,Float:OriginOffsets[FrameSide],sideDislocation)
	xs_vec_mul_scalar(topBottomVector,Float:OriginOffsets[FrameTop],topDislocation)	
	xs_vec_mul_scalar(topBottomVector,Float:OriginOffsets[FrameBottom],bottomDislocation)
	
	xs_vec_copy(topDislocation,framePoints[TopLeft])
	
	xs_vec_add(framePoints[TopLeft],sideDislocation,framePoints[TopRight])
	xs_vec_sub(framePoints[TopLeft],sideDislocation,framePoints[TopLeft])
	
	xs_vec_neg(bottomDislocation,framePoints[BottomLeft])
	
	xs_vec_add(framePoints[BottomLeft],sideDislocation,framePoints[BottomRight])
	xs_vec_sub(framePoints[BottomLeft],sideDislocation,framePoints[BottomLeft])
	
	for(new FramePoint:i = TopLeft; i <= BottomRight; i++)
		xs_vec_add(origin,framePoints[i],framePoints[i])
	
}

public traceEyesFrame(id,Float:eyes[Vector],Float:framePoints[FramePoint][Vector],Float:framePointsTraced[FramePoint][Vector],&FramePoint:closerFramePoint)
{
	new Float:smallFraction = 1.0
	
	for(new FramePoint:i = TopLeft; i <= BottomRight; i++)
	{
		new trace;
		engfunc(EngFunc_TraceLine,eyes,framePoints[i],IGNORE_GLASS,id,trace)
		
		new Float:fraction
		get_tr2(trace, TR_flFraction,fraction);
		
		if(fraction == 1.0)
		{
			return false;
		}
		else
		{
			if(fraction < smallFraction)
			{
				smallFraction = fraction
				closerFramePoint = i;
			}
			
			get_tr2(trace,TR_EndPos,framePointsTraced[i]);
		}
	}
	
	return true;
}

public moveToPlane(Float:plane[4],Float:eyes[Vector],Float:framePointsTraced[FramePoint][Vector],FramePoint:alreadyInPlane)
{
	new Float:direction[Vector]
	
	for(new FramePoint:i=TopLeft;i<alreadyInPlane;i++)
	{
		xs_vec_sub(eyes,framePointsTraced[i],direction)
		xs_plane_rayintersect(plane,framePointsTraced[i],direction,framePointsTraced[i])
	}
	
	for(new FramePoint:i=alreadyInPlane+FramePoint:1;i<=BottomRight;i++)
	{
		xs_vec_sub(eyes,framePointsTraced[i],direction)
		xs_plane_rayintersect(plane,framePointsTraced[i],direction,framePointsTraced[i])
	}
}	


public handleTurnWallHackOn(id)
{	
	g_CheckWh[id] = true
	ForwardAddToFullPack = register_forward(FM_AddToFullPack,"addToFullPackPost",1)

}

public handleTurnWallHackOff(id)
{
	g_CheckWh[id] = false
	unregister_forward(FM_AddToFullPack,ForwardAddToFullPack,1)
}
