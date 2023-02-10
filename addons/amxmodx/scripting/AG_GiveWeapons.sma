    #include <amxmodx>
    #include <amxmisc>
    #include <fun>
    #include <fakemeta>
    #include <hamsandwich>
    #include <hl>

    #define PLUGIN 			"AG weapon give"
    #define VERSION 		"1.0"
    #define AUTHOR 			"teylo"


    #define SHOTGUN_BPAMMO_OFFSET			305 	
    #define GLOCK_MP5_9MM_BPAMMO_OFFSET		306 
    #define CHAINGUN_BPAMMO_OFFSET			307
    #define PYTHON_BPAMMO_OFFSET			308
    #define GAUSS_EGON_BPAMMO_OFFSET		309		
    #define RPG_BPAMMO_OFFSET				310
    #define CROSSBOW_BPAMMO_OFFSET			311
	#define TRIPMINE_BPAMMO_OFFSET			312
    #define SATCHEL_BPAMMO_OFFSET			313
    #define GRENADE_BPAMMO_OFFSET			314
    #define SNARK_BPAMMO_OFFSET				315	
    #define HORNET_BPAMMO_OFFSET			316
new const m_iDefaultAmmo = 40
new const weaponOffset = 4
new bool: g_bUsedCommand1 [ 33 ],g_bUsedCommand2 [ 33 ]


    public plugin_init()
    {
        register_plugin( PLUGIN, VERSION, AUTHOR );
        register_concmd( "hl_weapon", "cmdGiveWeapon");
        register_clcmd("say /hw", "cmdGiveWeapon");

        
    }

    public cmdGiveAmmo1(id) {
        if (g_bUsedCommand1 [id])
        {
            set_pdata_int(give_item( id, "weapon_rpg"), m_iDefaultAmmo, 999999, weaponOffset);
            set_pdata_int(give_item( id, "weapon_357" ), m_iDefaultAmmo, 999999, weaponOffset);
            g_bUsedCommand1 [id] = false;  
        }
    }

    public cmdGiveAmmo2(id) {   
        if (g_bUsedCommand2 [id])
        { 
            set_pdata_int(give_item( id, "weapon_9mmhandgun" ), m_iDefaultAmmo, 999999, weaponOffset);     
            set_pdata_int(give_item( id, "weapon_9mmAR" ), m_iDefaultAmmo, 999999, weaponOffset);  
            g_bUsedCommand2 [id] = false;  
        }
    }
      
    public cmdGiveWeapon(id)
    {
            client_cmd(id,"use weapon_9mmhandgun");
            client_cmd(id,"drop");
            g_bUsedCommand1 [id] = true;
            g_bUsedCommand2 [id] = true;
            give_item( id, "weapon_crowbar" );
            give_item( id, "weapon_hornetgun" );
            give_item( id, "weapon_snark");   
            give_item( id, "weapon_tripmine" ); 
            give_item( id, "weapon_satchel" );  
            give_item( id, "weapon_handgrenade" );
            give_item( id, "weapon_gauss" );
            give_item( id, "weapon_egon" );
            give_item( id, "item_longjump" );
            set_pdata_int(give_item( id, "weapon_crossbow" ), m_iDefaultAmmo, 999999, weaponOffset);       
            set_pdata_int(give_item( id, "weapon_shotgun" ), m_iDefaultAmmo, 999999, weaponOffset);  
 
            
            //ammo
            set_user_bpammo( id, HLW_HORNETGUN, 999999 );
            set_user_bpammo( id, HLW_PYTHON, 999999 );
            set_user_bpammo( id, HLW_CROSSBOW, 999999 );
            set_user_bpammo( id, HLW_SNARK, 15 );
            set_user_bpammo( id, HLW_TRIPMINE, 5 );
            set_user_bpammo( id, HLW_SATCHEL, 99 );
            set_user_bpammo( id, HLW_HANDGRENADE, 99 );
            set_user_bpammo( id, HLW_GLOCK, 999999 );
            set_user_bpammo( id, HLW_GAUSS, 999999 );
            set_user_bpammo( id, HLW_MP5, 999999 );			   
            set_user_bpammo( id, HLW_EGON, 999999 );
            set_user_bpammo( id, HLW_RPG, 999999 );
            set_user_bpammo( id, HLW_SHOTGUN, 999999 );
            set_user_bpammo( id, HLW_CHAINGUN, 999999 );

            // weapon ammo
            set_task(0.1,"cmdGiveAmmo1",id)
            set_task(0.2,"cmdGiveAmmo2",id)

    return PLUGIN_HANDLED;
    }
     
    stock set_user_bpammo( index, weapon, amount )
    {
        new offset;
        switch( weapon )
        {
            case HLW_GLOCK, HLW_MP5: offset = GLOCK_MP5_9MM_BPAMMO_OFFSET; 
            case HLW_PYTHON: offset = PYTHON_BPAMMO_OFFSET;
            case HLW_CHAINGUN: offset = CHAINGUN_BPAMMO_OFFSET;
            case HLW_CROSSBOW: offset = CROSSBOW_BPAMMO_OFFSET;
            case HLW_SHOTGUN: offset = SHOTGUN_BPAMMO_OFFSET;
            case HLW_RPG: offset = RPG_BPAMMO_OFFSET;
            case HLW_GAUSS, HLW_EGON: offset = GAUSS_EGON_BPAMMO_OFFSET;
            case HLW_HORNETGUN: offset = HORNET_BPAMMO_OFFSET;
            case HLW_HANDGRENADE: offset = GRENADE_BPAMMO_OFFSET;
            case HLW_TRIPMINE: offset = TRIPMINE_BPAMMO_OFFSET;
            case HLW_SATCHEL: offset = SATCHEL_BPAMMO_OFFSET;
            case HLW_SNARK: offset = SNARK_BPAMMO_OFFSET;
        }
        
        set_pdata_int( index, offset, amount );

    }
