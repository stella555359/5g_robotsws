---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------

local EDAEMON_PORT="10000"
local CONTINER_IP="localhost"
local SERVER_IP="10.0.2.1"
local DAEMON_PORT="10000"
local DAEMON_IP="10.0.2.1"

--VARIABLES for SA configuration

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--VARIABLES for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local PDN_IP1="4.7.254.1"
local PDN_IP2="4.7.254.2"

local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.44.76.28"

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

exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x1:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')

exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off  mandatory_for_activation=on')
exec('set_cell id=4 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off  mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB3 SIM CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' gnb_id=0x3:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none xn='..GNB_SIM_XN_ADDR..' nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=18:0 tac=0 nrci=0x01 tdd_cell=off proxy='..GNB_SIM_NG_ADDR..':9999 gscn=1582 nr_arfcn=135760:126380 nr_scs=15kHz bs_channel_bandwidth=20MHz')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off measEvent=A5 sa_ho=xn_based sib1_period=40 sib2_period=40 sib5_period=40')

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')
---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=3')
exec('ue_param id=1 ue_nr_capabilities=E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A010080000000000200400840')

exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=4')
exec('ue_param id=2 ue_nr_capabilities=E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A010080000000000200400840')

exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=3 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A010080000000000200400840')

exec('set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:21645400')
exec('ue_param id=11 ue_nr_capabilities=E1201000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298400283E236B0C6D1D262A08FE5949B28340105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D03CBA559740EAE9564D2AC8AEE40B003C00D008040000004 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180')

exec('set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:21645401')
exec('ue_param id=12 ue_nr_capabilities=E1201000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298400283E236B0C6D1D262A08FE5949B28340105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D03CBA559740EAE9564D2AC8AEE40B003C00D008040000004 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')

exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

exec('set_pdu_gateway id=11 ue_nat_ip=72.23.0.11 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200 srb_reordering_enabled=off')

exec('set_bearer id=2 ue=11 qci=9 pdn=1 ip='..PDN_IP1..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('set_bearer id=2 ue=12 qci=9 pdn=1 ip='..PDN_IP2..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200 srb_reordering_enabled=off')

-- MISC
exec('debug_log level=4')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('set_log flush')
exec('cfg_end')
exec('set_log log_to_file=on')
sleep(1)
