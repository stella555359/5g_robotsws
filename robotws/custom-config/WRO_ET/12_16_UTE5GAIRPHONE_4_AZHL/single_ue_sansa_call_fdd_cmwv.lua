-- Copyright (c) 2020 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
DAEMON_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
--DAEMON_IP="10.0.2.2"
DAEMON_PORT=10000

ENB2_S1_ADDR="10.0.1.2"

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.116"

ENB1_X2_ADDR="10.0.1.1"
--121
GNB_X2_ADDR="10.0.1.116"
--116

MME1_S1_ADDR="10.0.1.131"
GNB_NG_ADDR="10.0.1.67"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR1="10.0.1.133"
SGW_S11_ADDR1="10.0.1.134"
SGW_S1U_ADDR2="10.0.1.137"
SGW_S11_ADDR2="10.0.1.138"

SGW_S11_PORT1="60100"
SGW_S11_PORT2="60101"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"
--PGW_ADDR1="4.7.253.253"

AMF_NG_ADDR="10.0.1.61"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"
--PDN_IP1="4.7.253.254"

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb type=external id=3 plmn=250:255 s1='..ENB2_S1_ADDR..' enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
--exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
--exec('set_cell id=1 enb=1 eci=0x1234601 pci=16:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=17:2 tac=222 proxy='..DAEMON_IP..':12220|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
--exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 x2_peers=none')
--exec('set_cell id=1 gnb=2 nr_arfcn=134980:127180 eci=0x000021f pci=17:0 tac=4 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=1 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633334:633334 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=633334:633334 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=777:14 eq_plmn=250:255 tac_list=153,777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR1..' s11='..SGW_S11_ADDR1..':'..SGW_S11_PORT1..'')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR2..' s11='..SGW_S11_ADDR2..':'..SGW_S11_PORT2..'')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')
--exec('set_pgw id=2 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR1..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..'')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.1/16 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited file=AirphoneConfig_2Cells.xml')
--exec('set_uec id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.23.0.1/24 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited file=AirPhoneConfig_fullstack_fdd_nsa_cmwv.xml')
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null imsi=250:555:21645400')
exec('ue_param id=1 ue_nr_capabilities=E1201000014F5E0302C00201404820D9C4C3E140426C020FFCC31E50B03826010188A01014C200141F11B586368E9315047F2CA4D940220B64C1203063C63FF30C7942C0E070F0113804E0001083011B9343E01C8200000148200000548200000949280000D300F81B7953781B5BAC0141000009652504000065949410000296525040000E594941000049652524000154B29280BA07974AB2E81E4D2AC9A55915DC8020F00340201000000100 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180')
exec('set_bearer id=2 ue=1 qci=9 pdn=1 ip='..PDN_IP..' default=on trf_type=internal')

-----------------------------------------------------------------------------------------------------
--Common CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1')

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
--exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('debug_log level=5')
--exec('sim_debug_log level=1 mme=1')
--exec('sim_debug_log level=1 uec=1')
--exec('sim_debug_log level=0 enb=1')
exec('sim_debug_log level=5 pgw=1')
exec('sim_debug_log level=5 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('start version_check=off')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('trace enb=1 protocol=x2 on')
--exec('trace uec=1 protocol=x2 on')

