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

function ue_proxy_loglevel()
    exec('sim_debug_log level=3 app_type=ueproxy')
end

function seq_configuration(duration)

    -----------TC4 : 10SA UE 4CELL TPUT DL1940 UL930Mbps------------------------

    exec('seq_set id=1 name=TC4_CELL1 ue_group=1')
    exec('ue_register ue_nr_capabilities=FDD_B71_B66 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=26500 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=13 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    exec('seq_set id=2 name=TC4_CELL2 ue_group=2')
    exec('ue_register ue_nr_capabilities=FDD_B71_B66 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=26500 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul mbps=13 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    exec('seq_set id=3 name=TC4_CELL3 ue_group=3')
    exec('ue_register ue_nr_capabilities=FDD_B71_B66 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=22 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=10250 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

    exec('seq_set id=4 name=TC4_CELL4 ue_group=4')
    exec('ue_register ue_nr_capabilities=FDD_B71_B66 capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl mbps=22 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=10250 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

function TC4_SA_MixBand_nonCA_DL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1-4 rate=1 detailed_print=on max_start=20')
	sleep(25)
	vm0_print("TC4_SA_MixBand_nonCA_DL script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(sansa,84000) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_8SA_8CELL_DL_UL
  script file=test_sequence.lua entry=TC2_10SA_10NSA_8CELL_DL_UL
  script file=test_sequence.lua entry=TC3_SA_4CC_DL
  script file=test_sequence.lua entry=TC4_SA_MixBand_nonCA_DL

--]]


