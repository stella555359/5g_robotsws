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

    -----------TC3 : 20SA UE 4CC TPUT DL1624Mbps------------------------

    exec('seq_set id=1 name=TC3_4CC_CELL6 ue_group=6')
    exec('ue_register ue_nr_capabilities=UE_CAP_4CC_CA_IWF capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=81200 size=1350')
    exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

function TC3_SA_4CC_DL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	exec('sim_param_set disable_events_on_telnet_session=on')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start rate=1 id=1 detailed_print=on duration=30  max_active_ues=20')
	sleep(30)
	vm0_print("TC3_SA_4CC_DL script completed")
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


