/*
*	PLUGIN NAME 	: HLAim Training 
*	VERSION		: v1.2.0
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
new VERSION[] = "1.2.0";

// ================================================================================== //
// ============================ DEFINE VARIABLES AREA =============================== //
// ================================================================================== //


// In HL stocks, it is called with the prefix HL_, but since it is the same as in 1.6, I don't include it xD
#if !defined MAX_ITEM_TYPES
    #define MAX_ITEM_TYPES 6
#endif
#define SECONDS 4.0					// time to disapear (seconds) 
#define TASKID        81732619124   // task id for the menu timer
#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

// ================================================================================== //
// ============================ GLOBAL VARIABLES AREA =============================== //
// ================================================================================== //

new g_gRoom 			= 0;			// room number for Noel's teylo_training_facility map
new g_gFireRoom 		= 0;			// room number for Fire's map
new g_gRoom_aim 		= 0;			// room number for aim_training map
new g_gReflexRoom 		= 0;			// room number for fire_reflex map
new g_gHorizontalRoom	= 0;			// room number for fire_horizontal map
new const g_szClassname[] = "_task";	// classname for the fake timer
new gConnexion[33];						// variable to store the connexion status of each player
new bool:g_bStarted[33];				// variable to store the start status of each player
new Float:g_fStart[33];					// variable to store the start time of each player
new g_iMaxPlayers;						// variable to store the maxplayers
new g_iFrags[ 33 ];						// variable to store the frags of the players
new bool:g_Freeze 		= false;		// variable to store the freeze status of the bots
new gSetPrevExitMenu 	= 0;			// variable to store the previous menu
new bool:g_StartAmmo;					// variable to store the start ammo status
new g_BoostBotHP 		= 0;			// variable to store the boost bot HP status
new bool:firstSpawn[33];				// variable to store the first spawn status of the players
new spawnMessage		= 0;			// variable to store the spawn message status
new dmgMessage			= 0;			// variable to store the damage message status
new origin_resp[3],origin_fix[3];		// variable to store the origin of the players
new is_bot[32];							// variable to store the bot status of the players
new players[32], inum, player;			// variable to store the players and the number of players
new blueFade 			= 0;			// variable to store the blue fade status
new weaponbox 			= 0;			// variable to store the weaponbox status
new gBotCounter 		= 0; 			// variable to store the number of bots
new bool: msgMenu [33];					// variable to store the menu message status

/* Top15  */
new gAuthScore[33][33];					// variable to store the auth score of the players
new gNameScore[33][33];					// variable to store the name score of the players
new gKillScore[15];						// variable to store the kill score of the players
new gScorePath[128];					// variable to store the score file path

new bool:g_chStarted[33];				// variable to store the challange status of each player
new cv_ctime;							// variable to store the challange time cvar

// WallHack area
new const SpritesPath[] = "sprites/hl_train/hl.spr"; // path to the sprite used for the wallhack
new SpritePathIndex[33];							 // variable to store the sprite path index
new EntitiesOwner;									 // variable to store the owner of the entities

new MaxPlayers;									 	 // variable to store the maxplayers
const MaxSlots = 32;							     // variable to store the maxslots
new bool:g_CheckWh[MaxSlots+1];					     // variable to store the wallhack status of the players

enum Individual										// enum for the individual wallhack status
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

new Float:ScaleMultiplier = 0.013;			 	 // variable to store the scale multiplier
new Float:ScaleLower = 0.005;				 	 // variable to store the scale lower

new Float:SomeNonZeroValue = 1.0;				 // variable to store the non zero value

new ForwardAddToFullPack;						 // variable to store the forward for the wallhack

new bool:whMessage[33];							 // variable to store the wallhack message status

// ================================================================================== //
// ============================== TRAINING MAPS AREA ================================ //
// ================================================================================== //

// Map: hl_aim_training central room coordinates
new const g_fOrigin_hlaim[][ 3 ] = {
{-511 , 0 , -196}
};

// Fire_horizontal room coordinates for bots spawn
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

// Fire_horizontal room 2 coordinates for bots spawn
new const g_botOrigin_horizontal2[][ 3 ] = {
{-2201,2439,-1479},
{-2431,2435,-1479},
{-2313,2446,-1479}
};

// Fire Reflex + vertical training map coordinates for bots spawn
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

// Fire Reflex training map, vertical room2 coordinates for bots spawn
new const g_botOrigin_vertical2[][ 3 ] = {
{-1780,-1094,-960},
{-1772,-1478,-960},
{-1766,-1414,-960},
{-1761,-1350,-960},
{-1771,-1285,-960},
{-1761,-1221,-960},
{-1764,-1159,-960}
};

// Noel map : teylo_training_facility - room 1 coordinates for bots spawn
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
// Noel map : teylo_training_facility - room 2 coordinates for bots spawn
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
// Noel map : teylo_training_facility - room 3 coordinates for bots spawn
new const g_fOrigin_room3[][ 3 ] = {
{-1960, -1640, -1900},
{-1959, -1930, -1900},
{-1855, -1441, -1900},
{-1604, -1684, -1900},
{-1568, -2428, -1900},
{-1796, -2313, -1900},
{-2356, -2322, -1900},
{-2806, -2306, -1900},
{-3023, -2267, -1900},
{-2918, -1579, -1900},
{-2744, -1704, -1900},
{-2302, -1532, -1900},
{-2306, -3063, -1900},
{-1658, -3002, -1900},
{-2841, -2835, -1900},
{-2299, -2615, -1900},
{-2295, -1980, -1900}
};
// Noel map : teylo_training_facility - room 4 coordinates for bots spawn
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
// Noel map : teylo_training_facility - room 5 coordinates for bots spawn
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
// Noel map : teylo_training_facility - room 6 coordinates for bots spawn
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

// Dutch Neo map : aimtraining center room 1 coordinates for bots spawn
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
// Dutch Neo map : aimtraining center room 2 coordinates for bots spawn
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
// Dutch Neo map : aimtraining center room 3 coordinates for bots spawn
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
// Dutch Neo map : aimtraining center room 4 coordinates for bots spawn
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

// Fire map : fire_training_facility room 1 coordinates for bots spawn
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

// Fire map : fire_training_facility room 2 coordinates for bots spawn
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

// ================================================================================== //
// ============================ HL WEAPON OFFSET CLASS ============================== //
// ================================================================================== //

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
		VERSION,	//: 1.2.0
		AUTHOR		//: teylo
	);
	
	register_forward(FM_Think, "fwd_Think", 0);
	register_event( "DeathMsg", "Event_DeathMsg", "a" );
	register_clcmd("say /train", "ShowMenuMain", _, "Open training menu");
	register_clcmd("say train", "ShowMenuMain", _, "Open training menu");
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

	// add and remove bots on location
	register_clcmd("say /bot", "add_bot");
	register_clcmd("say /remove", "remove_bot");
}

public plugin_cfg()
{
	EntitiesOwner = create_entity("info_target")
	
	MaxPlayers = get_maxplayers()
	
	for(new id=1;id<=MaxPlayers;id++)
		createSprite(id,EntitiesOwner)	
	
}

public ShowMenuMain(id)
{
	if (msgMenu[id]){
		client_print ( id , print_chat , "^^8[|-^^5RT^^8-| ^^5teylo^^8 AIM Training Mod] Use ^^1NUMPPAD keys ^^8for the training menu");
		msgMenu[id] = false;
	}	
	new menu = menu_create("Teylo AIM Training", "fw_MenuHandler");

	menu_additem(menu, "Classic Training", "a1", 0); 
	menu_additem(menu, "Spawn Training", "a2", 0); 
	menu_additem(menu, "Challange Training <ON/OFF>", "a3", 0); 
	menu_additem(menu, "Training Maps", "a4", 0); 
	menu_additem(menu, "Global settings", "a5", 0);


	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ShowMenuClassic(id)
{
	new menu = menu_create("Classic Training Menu", "fw_MenuHandler");

	menu_additem(menu, "Start/Reset Training", "c1", 0); 
	menu_additem(menu, "Start/Reset Training - No Ammo", "c2", 0);
	menu_additem(menu, "Stop training", "c3", 0); 
	menu_additem(menu, "Add BOT Menu", "c4", 0); 
	menu_additem(menu, "Add DUMMY BOT ( on aim)", "c5", 0);
	menu_additem(menu, "Kick BOT Menu", "c6", 0); 
	menu_additem(menu, "Global Settings", "c7", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ShowMenuSpawn(id)
{
	new menu = menu_create("Spawn Training Menu", "fw_MenuHandler");

	menu_additem(menu, "Start/Reset Training", "s1", 0); 
	menu_additem(menu, "Add BOT Menu", "s2", 0);
	menu_additem(menu, "Add Stationary BOT (fast spawn)", "s3", 0);
	menu_additem(menu, "Kick BOT Menu", "s4", 0); 
	menu_additem(menu, "Show Spawn Info <ON/OFF>", "s5", 0);
	menu_additem(menu, "Show Damage info <ON/OFF>", "s6", 0);
	menu_additem(menu, "Global Settings", "s7", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);	

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public ShowMenuBot(id)
{
	new menu = menu_create("Add BOT Menu", "fw_MenuHandler");

	menu_additem(menu, "Add BOT Level 1 (highest)", "b1", 0);
	menu_additem(menu, "Add BOT Level 2", "b2", 0);
	menu_additem(menu, "Add BOT Level 3", "b3", 0);
	menu_additem(menu, "Add BOT Level 4", "b4", 0);
	menu_additem(menu, "Add BOT Level 5 (lowest)", "b5", 0);

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public ShowMenuMap(id)
{
	new menu = menu_create("Choose the training map", "fw_MenuHandler");

	menu_additem(menu, "[AIM-training] teylo_training_facility", "p1", 0); 
	menu_additem(menu, "[AIM-training] aimtrainingcenter", "p2", 0); 
	menu_additem(menu, "[AIM-training] aim_training", "p3", 0); 
	menu_additem(menu, "[AIM-training] hlaim_train", "p4", 0); 
	menu_additem(menu, "[AIM-training] fire_training_facility", "p5", 0); 
	menu_additem(menu, "[AIM-training] fire_reflex_training", "p6", 0); 
	menu_additem(menu, "[AIM-training] ptk_aimtracking2", "p7", 0);
	menu_additem(menu, "[AIM-training] fire_horizontal", "p8", 0);
	menu_additem(menu, "[BHOP-training] test_ro", "p9", 0); 
	menu_additem(menu, "[BHOP-training] test_ro2", "p10", 0); 

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}


public ShowMenuSettings(id)
{
	new menu = menu_create("Global Settings Menu", "fw_MenuHandler");

	menu_additem(menu, "WallHack <ON/OFF>", "g1", 0);
	menu_additem(menu, "Freeze bots <ON/OFF>", "g2", 0); 
	menu_additem(menu, "Show Spawn Info <ON/OFF>", "g3", 0);
	menu_additem(menu, "Show Damage info <ON/OFF>", "g4", 0);
	menu_additem(menu, "Boost bots HP - 200/200 <ON/OFF>", "g5", 0);
	menu_additem(menu, "Killing Blue Fade <ON/OFF>", "g6", 0);
	menu_additem(menu, "Drop weaponbox <ON/OFF>", "g7", 0);	


	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;

}

public ShowMenuKick(id)
{
	new menu = menu_create("Kick BOT Menu", "fw_MenuHandler");

	menu_additem(menu, "Kick a BOT", "k1", 0); 
	menu_additem(menu, "Kick All BOTS", "k2", 0);	

	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);

	menu_display(id, menu, 0);
	return PLUGIN_HANDLED;
}

public fw_MenuHandler(id,menu,item)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED;

	if(item == MENU_EXIT)
	{
		menu_cancel(id);		
		// Show the right menu on exit : Main, Classic, Spawn training or exit
		switch(gSetPrevExitMenu)
		{
			case 0:{
				ShowMenuMain(id);		// Show the main menu on exit
				gSetPrevExitMenu = 9;	// Reset the previous menu to be able to exit from the main menu
			}
			case 1:{
				ShowMenuClassic(id);	// Show the classic menu on exit (used for the bot, kick bot and global settings menus) 
				gSetPrevExitMenu = 0;	// Reset the previous menu to be able to exit to the main menu 
			}
			case 2:{		
				ShowMenuSpawn(id);		// Show the spawn menu on exit (used for the bot, kick bot and global settings menus)
				gSetPrevExitMenu = 0;	// Reset the previous menu to be able to exit to the main menu
			}
		}
		return PLUGIN_HANDLED;
	}
	
	new data[6],name[64]
	new access,callback
	menu_item_getinfo(menu,item,access,data,5,name,63,callback)

	
	new key = str_to_num(data[1])
	
	switch(data[0]){
		case 'a':{
			// Check the last menu
			gSetPrevExitMenu = 0;		
			switch(key){		
				case 1: 
				{ 
					// Classic Training
					client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Classic Training");
					menu_destroy(menu);		// Destroy current menu  
					ShowMenuClassic(id);	// Show the next menu
				}
				case 2: 
				{
					// Spawn Training
					client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Spawn Training");
					menu_destroy(menu); 	// Destroy current menu
					ShowMenuSpawn(id);		// Show the next menu
				}
				case 3: 
				{
					// Challange Training
					switch_challange(id);	// Start the challange training with ammo, 1 bot and a timer of 90 seconds <ON/OFF>
					ShowMenuMain(id);		// Reshow the menu
				}
				case 4: 
				{
					// Training Maps
					client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Training Maps");
					menu_destroy(menu);		// Destroy current menu
					ShowMenuMap(id);		// Show the next menu		
				}
				case 5: 
				{
					// Global Settings
					client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have selected Global settings");	
					menu_destroy(menu);		// Destroy current menu
					ShowMenuSettings(id);	// Show the next menu
				}							
			}
		}
		case 'c':{
			// Check the last menu
			gSetPrevExitMenu = 1;					
			switch(key){
				case 1: 
				{ 
					// Start/Reset Training
					g_StartAmmo = true;
					classicTrain(id);		// Start the training with ammo
					ShowMenuClassic(id);	// Reshow the menu
				}
				case 2: 
				{
					// Start/Reset Training - No Ammo
					g_StartAmmo = false;
					classicTrain(id);		// Start the training without ammo
					ShowMenuClassic(id);	// Reshow the menu
				}
				case 3: 
				{
					// Stop training
					clcmdResetTimer(id);	// Reset the timer
					ShowMenuClassic(id);	// Reshow the menu
				}
				case 4: 
				{
					// Add BOT Menu
					client_print(id, print_chat, "^^8[Classic Training] ^^2You have selected Add BOT Menu");				
					menu_destroy(menu);		// Destroy current menu 
					ShowMenuBot(id);		// Show the next menu
				}
				case 5: 
				{ 
					// Add DUMMY BOT ( on aim) - message on make dummy function			
					Add_MTBot_Dummy(id);	// Make a dummy bot on the aim							
					ShowMenuClassic(id);	// Reshow the menu	
				}
				case 6: 
				{ 
					// Kick BOT Menu
					client_print(id, print_chat, "^^8[Classic Training] ^^2You have selected Kick BOT Menu");
					menu_destroy(menu);		// Destroy current menu
					ShowMenuKick(id);		// Show the next menu
				}
				case 7: 
				{
					// Global Settings
					client_print(id, print_chat, "^^8[Classic Training] ^^5You have selected Global settings");
					menu_destroy(menu);		// Destroy current menu
					ShowMenuSettings(id);	// Show the next menu
				}
			}								
		}
		case 's': {
			// Check the last menu
			gSetPrevExitMenu = 2;				
			switch(key){				
				case 1: 
				{ 
					// Start/Reset Training
					g_StartAmmo = true;		
					classicTrain(id);		// Start the training with ammo
					ShowMenuSpawn(id);		// Reshow the menu
				}
				case 2:
				{
					// Add BOT Menu
					client_print(id, print_chat, "^^8[Spawn Training] ^^2You have selected Add BOT Menu");
					menu_destroy(menu)		// Destroy current menu
					ShowMenuBot(id)			// Show the next menu
				}
				case 3: 
				{ 
					// Add Stationary BOT (fast spawn)
					client_print(id, print_chat, "^^8[Spawn Training] ^^2You added a stationary bot");
					Add_MTBot(id);			// Add a stationary bot
				}		
				case 4: 
				{ 
					// Kick BOT Menu
					client_print(id, print_chat, "^^8[Spawn Training] ^^2You have selected Kick BOT Menu");
					menu_destroy(menu);		// Destroy current menu
					ShowMenuKick(id);		// Show the next menu
				}			
				case 5: 
				{
					// Show Spawn Info <ON/OFF>
					switch_spawn()			// Switch the spawn info
				}
				case 6: 
				{
					// Show Damage info <ON/OFF>
					switch_dmg();			// Switch the damage info
				}	
				case 7: 
				{
					// Global Settings
					client_print(id, print_chat, "^^8[Spawn Training] ^^5You have selected Global settings");
					menu_destroy(menu);		// Destroy current menu
					ShowMenuSettings(id);	// Show the next menu
				}
			}		
		}		
		case 'b': {	
			switch(key){
				case 1: 
				{
					Add_JKbotti(id, 1);		// Add a level 1 bot
					ShowMenuBot(id);		// Reshow the menu
				}
				case 2: 
				{
					Add_JKbotti(id, 2);		// Add a level 2 bot
					ShowMenuBot(id);		// Reshow the menu
				}
				case 3: 
				{
					Add_JKbotti(id, 3);		// Add a level 3 bot
					ShowMenuBot(id);		// Reshow the menu
				}
				case 4: 
				{
					Add_JKbotti(id, 4);		// Add a level 4 bot
					ShowMenuBot(id);		// Reshow the menu
				}
				case 5: 
				{
					Add_JKbotti(id, 5);		// Add a level 5 bot
					ShowMenuBot(id);		// Reshow the menu
				}
			}				
		}
		case 'p':{		
			switch(key){
				case 1:  Vote_Map(id, "teylo_training_facility");
				case 2:  Vote_Map(id, "aimtrainingcenter");
				case 3:  Vote_Map(id, "aim_training");
				case 4:  Vote_Map(id, "hlaim_train");	
				case 5:  Vote_Map(id, "fire_training_facility");
				case 6:  Vote_Map(id, "fire_reflex_training");
				case 7:  Vote_Map(id, "ptk_aimtracking2");
				case 8:  Vote_Map(id, "fire_horizontal");
				case 9:  Vote_Map(id, "test_ro");
				case 10: Vote_Map(id, "test_ro2");	
			}
			menu_destroy(menu);
		}
		case 'g':{		
			switch(key){
				case 1: {
					switch_wh(id);			// Switch the wallhack <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				} 
				case 2: {
					switch_freezebots();	// Switch the freezing bots <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
				case 3: {
					switch_spawn();			// Switch the spawn info <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
				case 4: {
					switch_dmg();			// Switch the damage info <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
				case 5: {
					switch_hp();			// Switch the boost bots HP 200/200 <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
				case 6: {
					switch_fade();			// Switch the killing blue fade <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
				case 7: {
					switch_weaponbox();		// Switch the drop weaponbox <ON/OFF>
					ShowMenuSettings(id);	// Reshow the menu
				}
			}		

		}
		case 'k':{
			switch(key){
				case 1: {
					kickBot(id);			// Kick a BOT
					ShowMenuKick(id);		// Reshow the menu
				}				
				case 2: {
					KickAllBots(id);		// Kick all the bots
					ShowMenuKick(id);		// Reshow the menu
				}
			}
		}
	}
	
	return PLUGIN_CONTINUE
}


public Add_JKbotti(id, iLevel)
{
	new num, players[32],playername[32];							// Declare the variables
	server_cmd("jk_botti addbot ^"green^" ^"^" ^"%d^"", iLevel);	// Add a bot with the level iLevel
	gBotCounter +=1;												// Increment the bot counter
	get_user_name(id, playername, charsmax(playername));			// Get the player name
	get_players(players,num); 										// Get the number of players

	// Print the message for everyone
	client_print(id, print_chat, "^^8[AIM Training] ^^2%s ^^8added a Level ^^1%d ^^8bot. There are ^^1%d ^^8bots added to the server", playername, iLevel, num);
}

public Vote_Map(id, map[32])
{
	// Check if the map name contain "test" in the name to display a dynamic message for bhop or aim training
	if ( containi(map, "test" ) != -1 ) 
		client_print(id, print_chat, "^^8[BHOP-TRAINING] You have selected the bhop training map: ^^1%s", map);
	else
		client_print(id, print_chat, "^^8[AIM-TRAINING] You have selected the aim training map: ^^1%s", map);

	server_cmd("amx_votemap %s", map);

}

public kickBot(id)
{

	new playername[32];
	get_user_name(id, playername, charsmax(playername));	// Get the player name
	get_players(players, inum);								// Get the number of players
	
	for(new i; i < inum; i++) {
		player = players[i]
		if (is_user_bot(player) ){
			server_cmd("kick #%i", get_user_userid(players[i]));	// Kick the bot
			gBotCounter -=1;										// Decrement the bot counter
			client_cmd(0, "spk vox/destroyed.wav");					// Play the sound
			client_print(id, print_chat, "^^8[AIM Training] ^^1%s ^^8kicked a bot. There are ^^1%d ^^8bots added to the server", playername, gBotCounter);
			i = inum;												// Exit the loop
		}
	}

}

public KickAllBots(id)
{
	new playername[32];
	new bool:botsKicked = false;
	get_user_name(id, playername, charsmax(playername));		// get caller name
	get_players(players, inum);									// get all players a
	
	
	for(new i; i < inum; i++) {
		player = players[i];
		if (is_user_bot(player) ){
			server_cmd("kick #%i", get_user_userid(players[i]));// kick the bot
			botsKicked = true;
		}
	}
	if (botsKicked)
	{
		client_print(id, print_chat, "^^8[AIM-Training] ^^1%s ^^8removed all bots.", playername);	// Display global message
		gBotCounter = 0;											// reset bot counter
		client_cmd(0, "spk vox/destroyed.wav");						// play sound
	}
	else
		client_print(id, print_chat, "^^8[AIM-Training] ^^1There are no bots to remove.");	// Display private message
			
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

public cmdFreeze()
{

	get_players(players, inum);								// Get the number of players
	
	for(new i; i < inum; i++) {
		player = players[i]
	
		if (is_user_bot(player))							// Check if the player is a bot
		{
			set_user_maxspeed(player, 1.0);					// Set the maxspeed to 1.0
			set_user_gravity(player,10.0);					// Set the gravity to 10.0
			hl_strip_user_weapons(player);					// Strip the weapons
		}
	}
	
} 

public cmdUnfreeze()
{	
	get_players(players, inum);											// Get the number of players
	
	for(new i; i < inum; i++) {
		player = players[i]
	
		if (is_user_bot(player))										// Check if the player is a bot
		{
			set_user_maxspeed(player, get_cvar_float("sv_maxspeed"));	// Set the maxspeed to the server maxspeed
			set_user_gravity(player,1.0);								// Set the gravity multiplier to 1.0
		}

	}
}

public fwd_Room(iEnt, id)
{
	// get the func button entity by name 
	new szTarget[32];
	pev(iEnt, pev_target, szTarget, 31);					// Get the target name

	// FIRE HORIZONTAL CONVEYOR ROOM
	// room 1
	if ((equal(szTarget, "con")) && !is_user_bot(id) )
		{	
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 1 ^^8- ^^2Horizontal Training ^^8- Good luck!");
			g_gHorizontalRoom = 1;							// Set the horizontal room to 1
			killBots();										// Kill the bots from other rooms
			cmdFreeze();									// Freeze the bots	
		}
	//room 2
	if ((equal(szTarget, "roomt")) && !is_user_bot(id) )
		{	
			client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Room 2 ^^8- ^^2Horizontal Strafes ^^8- Good luck!");
			g_gHorizontalRoom = 2;							// Set the horizontal room to 2
			killBots();										// Kill the bots from other rooms
			cmdUnfreeze();									// Unfreeze the bots

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
	msgMenu[id] = true;						// Set the menu message to true
	firstSpawn[id] = false;					// Set the first spawn to false
	gConnexion[id] = 1;						// Set the connexion to 1
	client_cmd(id,"violence_agibs 0");		// Hide the bones
	client_cmd(id,"violence_hgibs 0");		// Hide the bones

	// Set the key bindings for the vote system
	client_cmd(id,"bind kp_end slot1");				// Numpad 1 - vote 1
	client_cmd(id,"bind kp_downarrow slot2");		// Numpad 2 - vote 2
	client_cmd(id,"bind kp_pgdn slot3");			// Numpad 3 - vote 3
	client_cmd(id,"bind kp_leftarrow slot4");		// Numpad 4 - vote 4
	client_cmd(id,"bind kp_5 slot5");				// Numpad 5 - vote 5
	client_cmd(id,"bind kp_rightarrow slot6");		// Numpad 6 - vote 6
	client_cmd(id,"bind kp_home slot7");			// Numpad 7 - vote 7
	client_cmd(id,"bind kp_uparrow slot8");			// Numpad 8 - vote 8
	client_cmd(id,"bind kp_pgup slot9");			// Numpad 9 - vote 9
	client_cmd(id,"bind kp_ins slot10");			// Numpad 0 - vote 0
}

public client_disconnected(id)
{
	if(gConnexion[id]==1)
	{
		// redisplay bones when disconnected
		client_cmd(id,"violence_agibs 1");	// Show the bones
		client_cmd(id,"violence_hgibs 1");	// Show the bones
		gConnexion[id]=0;
	}
	
	msgMenu[id] = false;					// Set the menu message to false
	clcmdResetTimer(id);					// Reset the timer to avoid the timer to continue when the player is disconnected
	remove_task(id);						// Remove the task
	whMessage[id] = false;					// Set the wallhack message to false
	firstSpawn[id] = false;					// Set the first spawn to false
	return PLUGIN_HANDLED;
}

public OpenMenu(taskid)
{
	new id = taskid - TASKID;
	remove_task(taskid);
	ShowMenuMain(id);
}


public playerSpawn(id)
{
	// Check if the player is a bot and if it's the first spawn
	if (!is_user_bot(id) && !firstSpawn[id])
	{
		firstSpawn[id] = true;						// Set the first spawn to true
		set_task( 1.5, "OpenMenu", id + TASKID);	// Open the main menu after 1.5 seconds
	}

	// Teleport to center in hlaim_training map
	new map_name[10];
	get_mapname(map_name, charsmax(map_name));
	if ( containi(map_name, "hlaim" ) != -1 && !is_user_bot(id)) 
	{
		client_print ( 0 , print_chat , "^^8[AIM Training Map] ^^1Center Room ^^8- ^^2Training all weapons ^^8- Good luck!");
		set_user_origin(id,g_fOrigin_hlaim[0]);		// Teleport the player to the center of the map
	}

	// Bot respawn 
	MTBot_AGRespawn(id);							// Respawn the MTBot (stationary bot)
	if (is_user_bot(id))
		get_bot_spawn(id);							// Get the bot spawn

	// Check the global settings to boost the bots HP
	if (g_BoostBotHP)
		{
			hl_set_user_health(id,200);				// Set the health to 200
			hl_set_user_armor(id,200);				// Set the armor to 200
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
	get_players(players, inum);					// Get the number of players
	
	for(new i; i < inum; i++) {
		player = players[i]						// Get the current player
	
		if (is_user_bot(player) )				// Check if the player is a bot
			user_kill(players[i]);				// Kill the bot
	}
}


public fwd_Info() 
{
	set_hudmessage(255, 255, 255, 0.01, 0.18, 0, 0.0, 1.0, 0.0, 0.0, -1 );
	show_hudmessage(0, "^^8[teylo AIM training MOD] Say ^^1/train ^^8to start training !!!");
}


public create_fake_timer()
{
	new iEnt = fm_create_entity("info_target");				// create a fake entity
	set_pev(iEnt,pev_classname, g_szClassname);				// set the classname	
	set_pev(iEnt, pev_nextthink, get_gametime() + 1.0);		// set the next think
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
	clcmdStartTimer(id);									// start timer for the training with all weapons and ammo
	return PLUGIN_HANDLED;
}

public challangeTrain(id)
{
	
	if( !is_user_alive( id ) )
	{  
		client_print( id, print_chat, "^^8[Challange Training] ^^1You can't use this command while you are dead." );  
		return PLUGIN_HANDLED; 
	}

	if (g_bStarted[id])
	{
		client_print( id, print_chat, "^^8[Challange Training] ^^1You already started a training." );  
		return PLUGIN_HANDLED; 
	}	
	
	client_print(id, print_chat, "^^8[Half-Life Aim Training] ^^2You have started a challenge! Do the most score/min !");
	KickAllBots(id);											// remove all bots
	server_cmd("jk_botti addbot ^"green^" ^"^" ^"1^"");			// add a bot
	g_StartAmmo = true;
	clcmdStartTimer(id);										// start timer for the challange with all weapons and ammo
	set_task(get_pcvar_float(cv_ctime)*60,"clcmdResetTimer",id);// stop the timer after x seconds
	return PLUGIN_HANDLED;
}

public clcmdStartTimer(id)
{

	if (is_user_alive(id))
	{
		give_weapons(id);						// give weapons to the player

		if(!g_bStarted[id])
			g_bStarted[id] = true;				// set the training started to true
		
		g_fStart[id] = get_gametime();			// get the start time
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
	   		 	g_iFrags[ iKiller ]++; 			// increment the frags for the killer hud message
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
		WeaponBox_Kill(ent)
	}	
	return PLUGIN_HANDLED;
}

stock WeaponBox_Kill(iEnt)
{
    if (get_ent_data(iEnt, "CBaseEntity", "m_pfnThink"))
    {
        // This Weaponbox has a brain (CWeaponBox::Kill), let gamedll do the rest
        set_pev(iEnt, pev_nextthink, get_gametime() + 0.1);
        return;
    }

    // Dumb Weaponbox
    for (new i = 0, iWeapon; i < MAX_ITEM_TYPES; i++)
    {
        iWeapon = get_ent_data_entity(iEnt, "CWeaponBox", "m_rgpPlayerItems", i);
        while (iWeapon > 0)
        {
            ExecuteHam(Ham_Item_Kill, iWeapon);
            iWeapon = get_ent_data_entity(iWeapon, "CBasePlayerItem", "m_pNext");
        }
    }

    ExecuteHam(Ham_Killed, iEnt);
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

public Add_MTBot(id)
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
	// Increment the number of bots
	gBotCounter +=1;

	return PLUGIN_CONTINUE;
}


public Add_MTBot_Dummy(id)
{
	// calculate aim origin for the bot
	new orig[3],Float:origin[3]
	get_user_origin(id,orig,3)
	
	origin[0] = float(orig[0])
	origin[1] = float(orig[1])
	origin[2] = float(orig[2]) + 38.0
	
	// create a dummy bot
	new name[32]
	new bot_name[33] = "[DUMMY] BOT"
	new bot_model[33] = "green"

	if (hl_get_user_spectator(id))
	{
		client_print(id, print_chat, "^^8[DUMMY BOT] ^^1You can't create a bot when you are a spectator!")
		return PLUGIN_HANDLED;
	}

	new playername[32]
	get_user_name(id, playername, charsmax(playername))

	formatex(name, 255, "%s %d", bot_name, random_num(100, 300)) 
	new id_bot = engfunc(EngFunc_CreateFakeClient, name)
	
	if(!id_bot) {
		client_print(id, print_chat, "^^8[DUMMY BOT] ^^1A bot can't join! This server may be full.")
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
		pev(id_bot, pev_origin, 1.0)
		pev(id_bot, pev_velocity, 320.0)
		hl_user_spawn(id_bot)
		engfunc(EngFunc_DropToFloor, id_bot)
		set_pev(id_bot, pev_effects, (pev(id_bot, pev_effects) | 1 ))
		set_pev(id_bot, pev_solid, SOLID_BBOX)
		set_user_rendering(id_bot, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 100)

		if (hl_get_user_spectator(id_bot))
		{
			client_print(id, print_chat, "^^8[DUMMY BOT] ^^1You can't create a bot when match is started!")
			server_cmd("kick #%i", get_user_userid(id_bot))
		}
		else
		{
			client_print(0, print_chat, "^^8[DUMMY BOT] ^^2%s^^8 created a DUMMY BOT.", playername)
		}
	}

	// set bot origin
	entity_set_origin(id_bot,origin)

	// increment the number of bots
	gBotCounter +=1;

	return PLUGIN_CONTINUE;
}

public setDummyBotOrigin(id)
{
	new origin[3]
	get_user_origin(id,origin,3)
	set_user_origin(id,origin)
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

public switch_hp()
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

public switch_spawn()
{	
	if(spawnMessage==0)
	{
		spawnMessage=1;
		client_print(0,print_chat,"^^8[Spawn Training] ^^2Spawn system activated.");
	}else{
		spawnMessage=0;
		client_print(0,print_chat,"^^8[Spawn Training] ^^1Spawn system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_dmg()
{
	if(dmgMessage==0)
	{
		dmgMessage=1;
		client_print(0,print_chat,"^^8[Spawn Training] ^^2Damage system activated.");
	}else{
		dmgMessage=0;
		client_print(0,print_chat,"^^8[Spawn Training] ^^1Damage system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_fade()
{
	if(blueFade==0)
	{
		blueFade=1;
		client_print(0,print_chat,"^^8[Spawn Training] ^^2Blue Fade Kill system activated.");
	}else{
		blueFade=0;
		client_print(0,print_chat,"^^8[Spawn Training] ^^1Blue Fade Kill system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_weaponbox()
{
	if(weaponbox==0)
	{
		weaponbox=1;
		client_print(0,print_chat,"^^8[Classic Training] ^^2Weaponbox system activated.");
	}else{
		weaponbox=0;
		client_print(0,print_chat,"^^8[Classic Training] ^^1Weaponbox system deactivated.");
	}	
	return PLUGIN_CONTINUE;
}

public switch_freezebots()
{
	if(!g_Freeze)
	{

		g_Freeze = true;
		client_print(0,print_chat,"^^8[Classic Training] ^^2Freezing bots system activated.");
		cmdFreeze();	
	}else{
		g_Freeze = false;
		client_print(0,print_chat,"^^8[Classic Training] ^^1Freezing bots system deactivated.");
		cmdUnfreeze();	
	}	
	return PLUGIN_CONTINUE;
}

public switch_challange(id)
{
	
	if(!g_chStarted[id])
	{
		g_chStarted[id] = true;
		challangeTrain(id);
	}else{
		g_chStarted[id] = false;
		clcmdResetTimer(id);	// Reset the timer
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

