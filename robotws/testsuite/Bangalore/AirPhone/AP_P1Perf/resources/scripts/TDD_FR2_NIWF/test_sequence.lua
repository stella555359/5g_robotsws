function x2_link()
    exec('enb_x2_link_up enb=1 target=2')
end

function enable_vip_logs()
    exec('sim_rfm_filter disable=all')
    exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function vm0_print(text)
    exec('sim_rfm_filter enable=all')
	print(text)
	exec('sim_rfm_filter disable=all')
    exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function disable_telnet_events()
    exec('sim_param_set disable_events_on_telnet_session=on')
end

function enable_telnet_events()
    exec('sim_param_set disable_events_on_telnet_session=off')
end

function ue_proxy_loglevel()
    exec('sim_debug_log level=3 app_type=ueproxy')
end

function seq_configuration(duration)

    -----------TC1 : 106SA UE 1S8CC TPUT DL1060Mbps------------------------

    exec('seq_set id=1 name=CELL1 ue_group=1')
    exec('ue_register ue_nr_capabilities=1S_8CC_SA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=10 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

function TC1_106SA_DL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1 rate=1 detailed_print=on max_start=106')
	sleep(120)
	vm0_print("TC1_106SA_DL script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sansa,84000) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_106SA_DL

--]]
