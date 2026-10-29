-- Copyright (c) 2019 Nokia. All rights reserved.

---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local DAEMON_IP="10.0.2.1"
local SERVER_IP="10.0.2.1"
local DAEMON_PORT="10000"
local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"


--Variables for NSA configuration


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

local PDN_IP="4.7.254.208"



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
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR)

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

--UE Id=1 SA
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c80008780818806804c020301c032a36146b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36266b04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a3626eb04050d012cb2898087ad8202020e1de38720c38002064f1f570004f001c0013c002a36276b04050d012cb2898087ad8202020e1de38720c38002064f1f55000005000000108389a00000000404d0103804044f60701800140e020381801c07000683e0000000000000e54d000100000965950034aaa8081c002c000000100200462c4c0004080c1014181c202c4044484c648494989ca128')

--UE Id=11-16 NSA'
exec('set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=null+aes imsi=311:489:21645502')
exec('ue_param id=11 ue_nr_capabilities=29000000010800000004D4D3F780000000000001150000000000000150  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')
exec('set_ue simulated id=12 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=snow3g+zuc imsi=311:489:21645503')
exec('ue_param id=12 ue_nr_capabilities=21000000010800000004D4DE00000000000004540000000000000540  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')
exec('set_ue simulated id=13 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=snow3g+aes imsi=311:489:21645504')
exec('ue_param id=13 ue_nr_capabilities=29000000010800000004D4D3F780000000000001150000000000000150  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')
exec('set_ue simulated id=14 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645505')
exec('ue_param id=14 ue_nr_capabilities=21000000010800000004D4DE00000000000004540000000000000540  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')
exec('set_ue simulated id=15 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645506')
exec('ue_param id=15 ue_nr_capabilities=29000000010800000004D4D3F780000000000001150000000000000150  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')
exec('set_ue simulated id=16 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645507')
exec('ue_param id=16 ue_nr_capabilities=21000000010800000004D4DE00000000000004540000000000000540  dual_conn=eutra_nr ue_eutra_nr_capabilities=210C040160801C4D00000000402404D1000100010080400801')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1')
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_bearer id=2 ue=11-16 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

---------------------------------------------------------------------------------------------------
exec('debug_log level=0')
exec('sim_debug_log level=1 mme=1')
exec('sim_debug_log level=1 uec=1')
exec('sim_debug_log level=1 pgw=1')
exec('sim_debug_log level=1 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')

exec('set_log log_to_file=on')
