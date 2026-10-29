--Copyright (c) 2019 Nokia. All rights reserved.

---------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

EDAEMON_PORT="22222"

--Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.112"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7880  eci=0x000021f mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666  gscn=7880  eci=0x000021f mandatory_for_activation=off')
--exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=347380:425040  gscn=5313 mandatory_for_activation=off')
--exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=640000:640000  gscn=7915 mandatory_for_activation=off')
--exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=167300:176300   gscn=2203 mandatory_for_activation=off')
--exec('set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x05 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=349000:431000    gscn=5389 mandatory_for_activation=off')
--exec('set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x06 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=650000:650000    gscn=8019 mandatory_for_activation=off')
--exec('set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x04 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=529002:529002 gscn=6609 mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

FIRST_UE_SA = 1
END_UE_SA = 150
FIRST_UE_NSA = 153
END_UE_NSA = 154
IMSI_FIRST_UE = 21645400

for UEID = FIRST_UE_SA, END_UE_SA do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
    --for gw_id = 1, 250 do
    exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
    --end 
end

for UEID = FIRST_UE_NSA, END_UE_NSA do   
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=zuc nea=zuc imsi=311:489:'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=01000000010800000004D780000000000001150000000000000150 dual_conn=eutra_nr ue_eutra_nr_capabilities=A112C0EC100910400007F00000000040D8201209A0040FE00000000081B080241362080080FE00000000081004012026C1041004100008040400801080004020200400880002010100200404008010')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)  
end

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')


----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

exec('sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47')
exec('sim_param_set NR_PDCP_BUNDLE_DL_MAX_SIZE=1200')
exec('sim_param_set NR_PDCP_BUNDLE_DL_TIMEOUT=100')

----------------------------------------------------------------------------------------------------
--beamforming CONFIGURATION
-----------------------------------------------------------------------------------------------------
--FIRST_UE_IN_BEAM1 = 1
--END_UE_IN_BEAM1 = 12
--FIRST_UE_IN_BEAM2 = 13
--END_UE_IN_BEAM2 = 25

--exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
--exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
--for UEID = FIRST_UE_IN_BEAM1, END_UE_IN_BEAM1 do
    --exec('ue_testmode_set_nr id='..UEID..' testmode=beam_control action=activate profile_id=1 beamaction=attach scell=0')
--end 

--for UEID = FIRST_UE_IN_BEAM2, END_UE_IN_BEAM2 do
    --exec('ue_testmode_set_nr id='..UEID..' testmode=beam_control action=activate profile_id=2 beamaction=attach scell=0')
--end 
--exec('beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3,4,5,6,7 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50')
--exec('beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0,2,3,4,5,6,7 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120')
--exec('beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=2,0,1,3,4,5,6,7 ssbeam_bestbeam=2 ssbeam_rsrp_best=-50 ssbeam_rsrp_avg=-125')
--exec('beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=3,0,1,2,4,5,6,7 ssbeam_bestbeam=3 ssbeam_rsrp_best=-55 ssbeam_rsrp_avg=-120')
--exec('beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=4,0,1,2,3,5,6,7 ssbeam_bestbeam=4 ssbeam_rsrp_best=-60 ssbeam_rsrp_avg=-139')
--exec('beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=5,0,1,2,3,4,6,7 ssbeam_bestbeam=5 ssbeam_rsrp_best=-65 ssbeam_rsrp_avg=-70')
--exec('beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=6,0,1,2,3,4,5,7 ssbeam_bestbeam=6 ssbeam_rsrp_best=-46 ssbeam_rsrp_avg=-100')
--exec('beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=7,0,1,2,3,4,5,6 ssbeam_bestbeam=7 ssbeam_rsrp_best=-48 ssbeam_rsrp_avg=-100')
---------------------------------------------------------------------------------------------------
exec('debug_log level=5')
--exec('sim_debug_log level=4 mme=1')
--exec('sim_debug_log level=4 uec=1')
--exec('sim_debug_log level=4 pgw=1')
--exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param use_hb=off')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('trace enb=1 protocol=x2 on')
--exec('trace uec=1 protocol=x2 on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')



