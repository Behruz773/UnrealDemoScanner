#include <amxmodx>
#include <cstrike>
#include <engine>
#include <reapi>
#include <fakemeta>

new bool:g_bRequestCmdInfo[33];
new Float:tmpViewAngles[33][3];

#define PLUGIN_VERSION "1.2"


public plugin_init()
{
	register_plugin( "Unreal Demo Scanner Helper", PLUGIN_VERSION, "Karaulov" );
	register_forward(FM_CmdStart, "OnCmdStart");
	create_cvar("uds_plugin", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);
	
}

public client_connect(id)
{
	set_task(20.0,"unreal_demo_scanner_plugin_start",id,_,_,"b")
}

public client_disconnected(id)
{
	if (task_exists(id))
		remove_task(id);
	if (task_exists(id + 100))
		remove_task(id + 100);
	if (task_exists(id + 1000))
		remove_task(id + 1000);
	if (task_exists(id + 10000))
		remove_task(id + 10000);
}

public unreal_demo_scanner_plugin_start(id)
{
	if(is_user_connected(id))
	{
		new pluginver_command[64];
		formatex(pluginver_command,charsmax(pluginver_command),"%s%s","UDS:PLUGINVERSION:",PLUGIN_VERSION);
		write_demo_info(id,pluginver_command);
		set_task(1.0,"uds_send_protocol_and_vsync",id + 100)
		set_task(2.0,"uds_send_ip_fps_and_gametime",id + 1000)
		set_task(3.0,"uds_send_weapon_and_ucmd",id + 10000)
	}
}

public uds_send_protocol_and_vsync(id2)
{
	new id = id2 - 100;
	if(is_user_connected(id))
	{
		new protocol = REU_GetProtocol(id);
		new protocol_command[64];
		
		formatex(protocol_command,charsmax(protocol_command),"%s%i","UDS:PROTOCOL:",protocol);
		
		if (protocol < 48)
		{
			write_demo_info(id,"UDS:ERROR:PROTOCOL");
			write_demo_info(id,protocol_command);
		}
		else
		{
			query_client_cvar(id, "gl_vsync", "uds_check_vsync");
			write_demo_info(id,protocol_command);
		}
	}
}


public uds_send_ip_fps_and_gametime(id2)
{
	new id = id2 - 1000;
	
	if(is_user_connected(id))
	{
		new userip[32];
		new userip_command[64];
		new server_gametime[64];
		get_user_ip(id,userip,charsmax(userip))
		formatex(userip_command,charsmax(userip_command),"%s%s","UDS:IP:",userip);
		formatex(server_gametime,charsmax(server_gametime),"%s%f","UDS:GAMETIME:",get_gametime());
		write_demo_info(id,userip_command);
		write_demo_info(id,server_gametime);
		
		query_client_cvar(id, "fps_max", "uds_check_fps");
	}
}

public uds_send_weapon_and_ucmd(id2)
{
	new id = id2 - 10000;
	if(is_user_connected(id))
	{
		new userweapon_command[64];
		formatex(userweapon_command,charsmax(userweapon_command),"%s%i:%i","UDS:WEAPON:",cs_get_user_weapon(id),cs_get_user_weapon_entity(id));
		write_demo_info(id,userweapon_command);
		g_bRequestCmdInfo[id] = true;
		
		remove_task(id);
	}
}


public OnCmdStart(id, uc_handle, seed)
{
	if (g_bRequestCmdInfo[id] && (get_uc(uc_handle, UC_Buttons) & IN_ATTACK) )
	{
		get_uc( uc_handle, UC_ViewAngles, tmpViewAngles[id]);
		g_bRequestCmdInfo[id] = false;
		new userviewangles_command[128];
		formatex(userviewangles_command,charsmax(userviewangles_command),"%s%f:%f","UDS:ANGLE:",tmpViewAngles[id][0],tmpViewAngles[id][1]);
		write_demo_info(id,userviewangles_command);
		set_task(20.0,"unreal_demo_scanner_plugin_start",id,_,_,"b")
	}
	return;
}

public uds_check_fps(id, const cvar[], const value[], const param[])
{
	new userfps_command[64];
	formatex(userfps_command,charsmax(userfps_command),"%s%s","UDS:FPS:",value);
	write_demo_info(id,userfps_command);
}

public uds_check_vsync(id, const cvar[], const value[], const param[])
{
	new uservsync_command[64];
	formatex(uservsync_command,charsmax(uservsync_command),"%s%s","UDS:VSYNC:",value);
	write_demo_info(id,uservsync_command);
}


public write_demo_info(id, info[])
{
	if(is_user_connected(id))
	{
		message_begin(MSG_ONE, SVC_SENDEXTRAINFO, _, id)
		write_string(info)
		write_byte(0)
		message_end()
	}
}