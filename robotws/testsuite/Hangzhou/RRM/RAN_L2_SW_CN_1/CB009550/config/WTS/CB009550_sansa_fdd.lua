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
PDN_IP1="4.7.254.1"
PDN_IP2="4.7.254.2"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
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
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off  mandatory_for_activation=off')
--exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x05 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=136100:126900 gscn=1587 mandatory_for_activation=off')
--exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=376500:392500 gscn=4907 mandatory_for_activation=off')
--exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=off proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=349000:431000 gscn=5389 mandatory_for_activation=off')
--exec('set_cell id=11 gnb=2 pci=20:0 tac=200 nrci=0x03 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=663334:663334 gscn=8158 mandatory_for_activation=off')
--exec('set_cell id=12 gnb=2 pci=20:1 tac=200 nrci=0x04 tdd_cell=on proxy=$PROXY_SERVER_IP:9999|$PROXY_SERVER_IP:8888 nr_arfcn=529002:529002 gscn=6609 mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

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
    exec('ue_param id='..UEID..' ue_nr_capabilities=E9A01000074F5A1302000206400241262C001306A12013601873E639F78F83C130080C4704EA0D89DAC1184341020F94160165B262A86873E238F40CFB027C639F31CFBC7C1E070F05C0000000700000000540001C0A83626EB04610D04083E50580596C98AA1A1CF88E3D033EC09F18E7CC73EF1F0781C3C170004F001C0013C00150000702A0F88DAC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FC0000007F0000000540001C0A83E20EB04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027F0000001FC000000150000703A0D85181AC1184341020F94160165B262A86873E238F40CFB027C639F31CFBC7C1E070F05C00FFC007003FF000540001C0A83E0DEB04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027F4000001FD000000150000702A0F831AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FC0000007F0000000540001C0A83E036B04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027F0000001FC000000150000702A0F805AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FC0000007F0000000540001C0A83E00EB04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027F0000001FC000000150000702A0F801AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FD8000007F6000000540001C0A83617EB04610D04083E50580596C98AA1A1CF88E3D033EC09F18E7CC73EF1F0781C3C2700048001C0012000150000702A0D84FAC1184341020F94160165B262A86873E238F40CFB027C639F31CFBC7C1E070F09C0002400700009000540001C0A83612EB04610D04083E50580596C98AA1A1CF88E3D033EC09F18E7CC73EF1F0781C3C2700040001C0010000150000702A0F827AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FC0000007F0000000540001C0A83E06EB04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027C0000001F0000000150000702A0F817AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09F80000007E0000000540001C0A83E03EB04610D04083E50580496C98AA0A1CF88E3C639F31CFBC7C1E070F027F0000001FC000000150000702A0F809AC1184341020F94160125B262A82873E238F18E7CC73EF1F0781C3C09FC0000007F0000000540001C0683626606B04610D04083E50580596C98AA1A1CF88E3D033EC09F18E7CC73EF1F0781C3C12FFCBFF0308389A00000160E14040001010750F850001C46000E208007130000011C810120080204A0A81583707C0FA37601408A00940700D9AFC38442D9AFC38D0274E83079AFC01C0C631FA09801C00140E0A00C060120038060280281F02801000000008000010040000100200000C01000008008000050040000300200001C010000100080000900400005014CA9BCA9AC0DAC0DAC15AC19AC99ACA5AC8DAC05AC09A06060000032CA48080000CB29282000052CA48080001CB29282000092CA4A080002CB292820000D2CA4A080003CB292820000A2CA4A0800044B29282000132CA4A0800054B29282000172CA4A05A954DD2ADAA07354176A836D52ADBA55B549B6A94ED523DAA03B540B684807402A8140E070381C0A050281C0E0004001002004002004008C04008010100600C0401803010020046280C0905091900')
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
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('trace enb=1 protocol=x2 on')
--exec('trace uec=1 protocol=x2 on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')



