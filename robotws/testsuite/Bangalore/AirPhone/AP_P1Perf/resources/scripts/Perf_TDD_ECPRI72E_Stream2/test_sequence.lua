function x2_link()
    exec('enb_x2_link_up enb=1 target=2')
end

function enable_vip_logs()
    --exec('sim_rfm_filter disable=all')
    --exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function vm0_print(text)
    --exec('sim_rfm_filter enable=all')
	print(text)
	--exec('sim_rfm_filter disable=all')
    --exec('sim_rfm enable=CSI,ACR,OERR,IERR,VIP')
end

function ue_proxy_loglevel()
    exec('sim_debug_log level=3 app_type=ueproxy')
end

function seq_configuration(duration)

	------------S2 TC5 : 1 SA UE 6CELL 3T+3F TPUT DL 6Gbps----------------------------------

    exec('seq_set id=12 name=TDD_PCELL_CA_UE_WITH_TPUT ue_group=1')
    exec('ue_register ue_nr_capabilities=DL_3T_3F capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')	
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=160000 size=1350') 
    exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=1 trf_id=3 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=4 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=5 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=6 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=7 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=8 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=9 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=10 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=11 dir=dl kbps=160000 size=1350') 
    exec('trf_data_start pdu=1 qfi=1 trf_id=12 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=13 dir=dl kbps=160000 size=1350') --160 Mbps
	exec('trf_data_start pdu=1 qfi=1 trf_id=14 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=15 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=16 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=17 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=18 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=1 trf_id=19 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=1 trf_id=20 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=1 dir=dl kbps=160000 size=1350') 
    exec('trf_data_start pdu=1 qfi=2 trf_id=2 dir=dl kbps=160000 size=1350')
	exec('trf_data_start pdu=1 qfi=2 trf_id=3 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=4 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=2 trf_id=5 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=6 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=7 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=2 trf_id=8 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=9 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=10 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=11 dir=dl kbps=160000 size=1350') 
    exec('trf_data_start pdu=1 qfi=2 trf_id=12 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=2 trf_id=13 dir=dl kbps=160000 size=1350') --160 Mbps
	exec('trf_data_start pdu=1 qfi=2 trf_id=14 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=15 dir=dl kbps=160000 size=1350')
    exec('trf_data_start pdu=1 qfi=2 trf_id=16 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=17 dir=dl kbps=160000 size=1350') --160 Mbps
    exec('trf_data_start pdu=1 qfi=2 trf_id=18 dir=dl kbps=80000 size=1350')
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

	------------S2 TC6 : 1 SA UE 2CELL T+F TPUT UL 220Mbps----------------------------------

    exec('seq_set id=13 name=TDD_PCELL_CA_UE_WITH_TPUT ue_group=3')
    exec('ue_register ue_nr_capabilities=RANK1_ULCA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')	
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=160000 size=1350') 
    exec('trf_data_start pdu=1 qfi=1 trf_id=2 dir=ul kbps=60000 size=1350')
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

	------------S2 TC7 : 40 SA UE 6CELL 3T+3F TPUT DL 6300Mbps----------------------------------

    exec('seq_set id=14 name=DL_MUE_TPUT ue_group=1')
    exec('ue_register ue_nr_capabilities=DL_3T_3F capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')	
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=2 size=1350')
    exec('seq_delay 60')
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=dl kbps=80000 size=1350') 
    exec('trf_data_start pdu=1 qfi=2 trf_id=2 dir=dl kbps=77500 size=1350')
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

	------------S2 TC8 : 40 SA UE TPUT UL 220Mbps----------------------------------

    exec('seq_set id=15 name=TDD_PCELL_CA_UE_WITH_TPUT ue_group=3')
    exec('ue_register ue_nr_capabilities=RANK1_ULCA capability_file=./capability.cfg registration_type=InitialRegistration')
    exec('ue_pdu_session_setup pdu=1 nwslice=1')	
    exec('trf_data_start pdu=1 qfi=1 trf_id=1 dir=ul kbps=11000 size=1350') 
	exec('seq_delay '..duration..'')
    exec('ue_deregister by=ue ue_deregister_type=switch_off')
    exec('seq_end')

end

function TC1_SA_NSA_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=1-2 rate=1 detailed_print=on max_start=1')
	sleep(3)
	vm0_print("TC1_SA_NSA_DL_UL script completed")
end

function TC2_SA_MUMIMO_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=3 rate=1 detailed_print=on duration=50 max_start=40')
	sleep(80)
	vm0_print("TC2_SA_MUMIMO_DL_UL script completed")
end

function TC3_SANSA_500UEs_DL_UL()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=4-7 rate=1 detailed_print=on duration=550 max_start=500')
	sleep(600)
	vm0_print("TC3_SANSA_500UEs_DL_UL script completed")
end

function TC4_SANSA_SUE_DL_50MHz()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=8-9 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
    exec('seq_start id=10-11 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
	vm0_print("TC4_SANSA_SUE_DL_50MHz script completed")
end
--]]
function S2TC1_SA_SUE_DL_6Gbps()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=12 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
	vm0_print("S2TC1_SA_SUE_DL_6Gbps script completed")
end

function S2TC2_SA_SUE_UL_220Mbps()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=13 rate=1 detailed_print=on duration=5 max_start=1')
	sleep(10)
	vm0_print("S2TC2_SA_SUE_UL_220Mbps script completed")
end

function S2TC3_SA_MUE_UL_440Mbps()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=15 rate=1 detailed_print=on duration=45 max_start=40')
	sleep(60)
	exec('ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-51,-51 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=81 testmode=ue_ul_beam_position profile_id=1 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=2 num_beam_paths=2 azimuth=-51,-51 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=82 testmode=ue_ul_beam_position profile_id=2 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=3 num_beam_paths=2 azimuth=-51,-51 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=83 testmode=ue_ul_beam_position profile_id=3 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=4 num_beam_paths=2 azimuth=-51,-51 zenith=-18,-18 power=-250,-250') 
    exec('ue_testmode_set_nr id=84 testmode=ue_ul_beam_position profile_id=4 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=5 num_beam_paths=2 azimuth=-42,-42 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=85 testmode=ue_ul_beam_position profile_id=5 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=6 num_beam_paths=2 azimuth=-42,-42 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=86 testmode=ue_ul_beam_position profile_id=6 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=7 num_beam_paths=2 azimuth=-42,-42 zenith=9,9 power=-250,-250')
    exec('ue_testmode_set_nr id=87 testmode=ue_ul_beam_position profile_id=7 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=8 num_beam_paths=2 azimuth=-42,-42 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=88 testmode=ue_ul_beam_position profile_id=8 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=9 num_beam_paths=2 azimuth=51,51 zenith=-5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=89 testmode=ue_ul_beam_position profile_id=9 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=10 num_beam_paths=2 azimuth=51,51 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=90 testmode=ue_ul_beam_position profile_id=10 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=11 num_beam_paths=2 azimuth=51,51 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=91 testmode=ue_ul_beam_position profile_id=11 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=12 num_beam_paths=2 azimuth=51,51 zenith=-18,-18 power=-250,-250')   
    exec('ue_testmode_set_nr id=92 testmode=ue_ul_beam_position profile_id=12 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=13 num_beam_paths=2 azimuth=55,55 zenith=-5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=93 testmode=ue_ul_beam_position profile_id=13 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=14 num_beam_paths=2 azimuth=42,42 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=94 testmode=ue_ul_beam_position profile_id=14 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=15 num_beam_paths=2 azimuth=42,42 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=95 testmode=ue_ul_beam_position profile_id=15 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=16 num_beam_paths=2 azimuth=42,42 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=96 testmode=ue_ul_beam_position profile_id=16 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=17 num_beam_paths=2 azimuth=-33,-33 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=97 testmode=ue_ul_beam_position profile_id=17 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=18 num_beam_paths=2 azimuth=-33,-33 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=98 testmode=ue_ul_beam_position profile_id=18 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=19 num_beam_paths=2 azimuth=-33,-33 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=99 testmode=ue_ul_beam_position profile_id=19 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=20 num_beam_paths=2 azimuth=-25,-25 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=100 testmode=ue_ul_beam_position profile_id=20 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=21 num_beam_paths=2 azimuth=-25,-25 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=101 testmode=ue_ul_beam_position profile_id=21 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=22 num_beam_paths=2 azimuth=-25,-25 zenith=9,9 power=-250,-250')
    exec('ue_testmode_set_nr id=102 testmode=ue_ul_beam_position profile_id=22 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=23 num_beam_paths=2 azimuth=-25,-25 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=103 testmode=ue_ul_beam_position profile_id=23 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=24 num_beam_paths=2 azimuth=33,33 zenith=-5,-5 power=-250,-250')
    exec('ue_testmode_set_nr id=104 testmode=ue_ul_beam_position profile_id=24 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=25 num_beam_paths=2 azimuth=33,33 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=105 testmode=ue_ul_beam_position profile_id=25 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=26 num_beam_paths=2 azimuth=33,33 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=106 testmode=ue_ul_beam_position profile_id=26 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=27 num_beam_paths=2 azimuth=33,33 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=107 testmode=ue_ul_beam_position profile_id=27 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=28 num_beam_paths=2 azimuth=-33,-33 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=108 testmode=ue_ul_beam_position profile_id=28 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=29 num_beam_paths=2 azimuth=25,25 zenith=-5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=109 testmode=ue_ul_beam_position profile_id=29 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=30 num_beam_paths=2 azimuth=25,25 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=110 testmode=ue_ul_beam_position profile_id=30 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=31 num_beam_paths=2 azimuth=25,25 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=111 testmode=ue_ul_beam_position profile_id=31 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=32 num_beam_paths=2 azimuth=25,25 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=112 testmode=ue_ul_beam_position profile_id=32 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=33 num_beam_paths=2 azimuth=-17,-17 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=113 testmode=ue_ul_beam_position profile_id=33 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=34 num_beam_paths=2 azimuth=-17,-17 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=114 testmode=ue_ul_beam_position profile_id=34 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=35 num_beam_paths=2 azimuth=-17,-17 zenith=-9,-9 power=-250,-250')
    exec('ue_testmode_set_nr id=115 testmode=ue_ul_beam_position profile_id=35 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=36 num_beam_paths=2 azimuth=-17,-17 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=116 testmode=ue_ul_beam_position profile_id=36 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=37 num_beam_paths=2 azimuth=-14,-14 zenith=5,5 power=-250,-250')
    exec('ue_testmode_set_nr id=117 testmode=ue_ul_beam_position profile_id=37 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=38 num_beam_paths=2 azimuth=-14,-14 zenith=0,0 power=-250,-250')
    exec('ue_testmode_set_nr id=118 testmode=ue_ul_beam_position profile_id=38 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=39 num_beam_paths=2 azimuth=-14,-14 zenith=9,9 power=-250,-250')
    exec('ue_testmode_set_nr id=119 testmode=ue_ul_beam_position profile_id=39 action=activate')
    exec('ul_ue_beam_pos_nr profile_id=40 num_beam_paths=2 azimuth=-14,-14 zenith=-18,-18 power=-250,-250')
    exec('ue_testmode_set_nr id=120 testmode=ue_ul_beam_position profile_id=40 action=activate')
    vm0_print("S2TC3_SA_MUE_UL_440Mbps script completed")
end

function S2TC4_SA_MUE_DL_6300Mbps()
	exec('uec_l2_testmode_params fixed_csi_report=true')
	enable_vip_logs()
	sleep(0.5)
    exec('seq_start id=14 rate=1 detailed_print=on duration=50 max_start=40')
	sleep(60)
	vm0_print("S2TC4_SA_MUE_DL_6300Mbps script completed")
end

--[[
commands to egate
  cfg file=sim_config.lua entry=run_configuration(SIM_FDD_12CELL_25MHz_CNI108638,5400) --To configure sim or egate
  script file=test_sequence.lua entry=x2_link()
  script file=test_sequence.lua entry=TC1_SA_NSA_DL_UL
  script file=test_sequence.lua entry=TC2_SA_MUMIMO_DL_UL
  script file=test_sequence.lua entry=TC3_SANSA_500UEs_DL_UL
  script file=test_sequence.lua entry=TC4_SANSA_SUE_DL_50MHz
  script file=test_sequence.lua entry=S2TC1_SA_SUE_DL_6Gbps
  script file=test_sequence.lua entry=S2TC2_SA_SUE_UL_220Mbps
  script file=test_sequence.lua entry=S2TC3_SA_MUE_UL_440Mbps
  script file=test_sequence.lua entry=S2TC4_SA_MUE_DL_6300Mbps
--]]

