-- IP ADDRESSES FOR WTS NODES
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local AMF_NG_ADDR="10.0.1.1"
local UPF_ADDR="10.12.2.1"

local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.136"
local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"
local MME1_S1_ADDR="10.0.1.131"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"
local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local GNB3_NG_ADDR="10.0.1.3"
local GNB3_XN_ADDR="10.0.1.4"
local GNB4_NG_ADDR="10.0.1.5"
local GNB5_XN_ADDR="10.0.1.6"
local ENB5_S1_ADDR="10.0.1.110"
local SERVER_IP3="10.0.2.2"

local PROXY_SERVER_IP="10.0.2.80"
local CFG_CAPA="/home/ute/test_repository/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/SKYWATCH/config_65/skywatch_ue_nr_capa.cfg"

require('os')
--os.execute('sudo ip addr add 10.0.1.3/24 dev eth3:GNBSIM_X2')
--os.execute('sudo ip addr add 10.0.1.102/24 dev eth3:GNBSIM_NG')
--os.execute('sudo ip addr add 10.0.1.101/24 dev eth3:GNBSIM_XN')
os.execute('sudo ip addr add 10.0.1.131/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.132/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.133/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.134/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.135/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.136/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.137/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.99/24 dev eth3')
os.execute('sudo ip addr add 10.0.2.99/24 dev eth4')
os.execute('sudo ip addr add 10.0.1.3/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.4/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.5/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.6/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.110/24 dev eth3')
os.execute('sudo ip addr add 10.0.2.2/24 dev eth4')
os.execute('sudo ip addr add 10.0.1.121/24 dev eth3')
os.execute('sudo sysctl -w net.core.wmem_max=20971520')
os.execute('sudo sysctl -w net.core.wmem_default=20971520')
os.execute('sudo sysctl -w net.core.rmem_max=20971520')
os.execute('sudo sysctl -w net.core.rmem_default=20971520')

-- LTE CONFIG
exec('set_enb id=1 plmn=310:260 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 bw=10MHz enb=1 eci=0x1234601 pci=3:2 tac=200 proxy='..SERVER_IP..':12219 earfcn=68787:133323')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')

-- NR CORE CONFIG
exec('set_amf_region id=1 tac_list=200,100,788,200,0 plmn=310:260')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/21 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('smf_param id=1 max_pdu_session_supported=2000')

-- EXT GNB AND ITS CELLS
exec('set_gnb id=2 type=external plmn=310:260 x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=D7A4 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none xn='..GNB_X2_ADDR..' amf=1')
exec('set_cell id=1 gnb=2 pci=16:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135600:126400 mandatory_for_activation=off gscn=1565')
exec('set_cell id=2 gnb=2 pci=48:1 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135600:126400 mandatory_for_activation=off gscn=1565')
exec('set_cell id=21 gnb=2 pci=125:0 tac=200 nrci=0x15 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=381000:397000 mandatory_for_activation=off gscn=4961')
exec('set_cell id=22 gnb=2 pci=63:1 tac=200 nrci=0x16 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=381000:397000 mandatory_for_activation=off gscn=4961')
exec('set_cell id=201 gnb=2 pci=3:0 tac=200 nrci=0xC9 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=528000:528000 mandatory_for_activation=off gscn=6501')
exec('set_cell id=211 gnb=2 pci=3:1 tac=200 nrci=0xD3 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=509058:509058 mandatory_for_activation=off gscn=6276')
exec('set_cell id=202 gnb=2 pci=83:1 tac=200 nrci=0xCA tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=528000:528000 mandatory_for_activation=off gscn=6501')
exec('set_cell id=212 gnb=2 pci=83:2 tac=200 nrci=0xD4 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=509058:509058 mandatory_for_activation=off gscn=6276')

-- SIM GNB3 AND ITS CELLS
exec('set_gnb id=3 type=simulated plmn=310:260 ng='..GNB3_NG_ADDR..' gnb_id=0x3:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB3_XN_ADDR..' x2_peers=none nssai=0x01:0xFFFFFF amf=1')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off measEvent=A3 sa_ho=xn_based sib1_period=40 sib2_period=40 sib5_period=40 gbr_data_forwarding_HO=on')
exec('set_cell id=31 gnb=3 pci=21:0 tac=200 nrci=0x01 tdd_cell=off proxy='..GNB3_NG_ADDR..':7777 nr_arfcn=135600:126400 gscn=1565 suggested_band=71')
exec('set_cell id=32 gnb=3 pci=21:1 tac=200 nrci=0x02 tdd_cell=off proxy='..GNB3_NG_ADDR..':8888 nr_arfcn=381000:397000 gscn=4961 suggested_band=25')
exec('set_cell id=33 gnb=3 pci=21:2 tac=200 nrci=0x03 tdd_cell=on proxy='..GNB3_NG_ADDR..':9999 nr_arfcn=528000:528000 gscn=6501 suggested_band=41')

-- SIM GNB4 AND ITS CELLS
exec('set_gnb id=4 type=simulated plmn=310:260 ng='..GNB4_NG_ADDR..' gnb_id=0x4:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none nssai=0x01:0xFFFFFF amf=1')
exec('gnb_param id=4 xn_listening_socket=off send_xn_setup=off measEvent=A3 sa_ho=ng_based sib1_period=40 sib2_period=40 sib5_period=40 ng_data_forwarding_HO=off')
exec('set_cell id=41 gnb=4 pci=22:0 tac=200 nrci=0x01 tdd_cell=off proxy='..GNB4_NG_ADDR..':7777 nr_arfcn=135600:126400 gscn=1565 suggested_band=71')
exec('set_cell id=42 gnb=4 pci=22:1 tac=200 nrci=0x02 tdd_cell=off proxy='..GNB4_NG_ADDR..':8888 nr_arfcn=381000:397000 gscn=4961 suggested_band=25')
exec('set_cell id=43 gnb=4 pci=22:2 tac=200 nrci=0x03 tdd_cell=on proxy='..GNB4_NG_ADDR..':9999 nr_arfcn=528000:528000 gscn=6501 suggested_band=41')

-- SIM ENB5 AND ITS CELLS
exec('set_gnb id=5 type=simulated plmn=310:260 ng='..ENB5_S1_ADDR..' xn='..GNB5_XN_ADDR..' x2_peers=none daemon='..SERVER_IP..':'..DAEMON_PORT..' gnb_id=0x5:28 nssai=0x01:0xFFFFFF')
exec('gnb_param id=5 xn_listening_socket=1 send_xn_setup=off')
exec('set_cell id=51 gnb=5 pci=23:0 tac=200 nrci=0x01 tdd_cell=off earfcn=854:18854 proxy='..SERVER_IP3..':12219 bw=20MHz technology=lte mandatory_for_activation=off suggested_band=2')
exec('set_cell id=52 gnb=5 pci=23:1 tac=200 nrci=0x02 tdd_cell=off earfcn=5035:23035 proxy='..SERVER_IP3..':12220 bw=20MHz technology=lte mandatory_for_activation=off suggested_band=12')

-- 4G CORE CONFIG
exec('mme_pool_area id=1 mmegi=1 plmn=310:260 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s1u_snd_buff_size=20971520 s1u_rcv_buff_size=20971520 gtpu_read_packets_threshold=0')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20971520 sgi_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s5u_snd_buff_size=20971520 gtpu_read_packets_threshold=0')

-- UE CONFIGURATION
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 tun_read_packet_threshold=20 sctp_rto_min=100')

-- UES

-- UEID		Purpose				Comment
-- 1-199		SA Background			Generated via gen_sa_ue with SA_START_UE_ID and SA_MAX_UE_ID
-- 1001-1120	NSA sequences			Unique ID assigned per sequence per carrier - 1001-1060 for cell-1, 1061-1120 for cell-201
-- 1121-1200	NSA Background			Generated via gen_sa_ue with NSA_START_UE_ID and NSA_MAX_UE_ID
-- 2001-2104	SA Sequences for n25	      Unique ID assigned per sequence for n25, first digit from left "2" for n25, rest for sequence ID
-- 4001-4104	SA Sequences for n41	      Unique ID assigned per sequence for n41, first digit from left "4" for n41, rest for sequence ID
-- 7001-7104	SA Sequences for n71	      Unique ID assigned per sequence for n71, first digit from left "7" for n71, rest for sequence ID

-- Pros:
-- MaskedIMEI is set per UE so the sequences are marked in L3 Emil logs
-- Easy to identify failing sequence in AP logs, for "ERROR - [ERROR] Didn't found pattern 'UE4024: IS IDLE' in time 29 seconds." -> sequence 024 for n41 carrier
-- We can extend the test simply by multiplying all_scenarios_list and don't worry about UE_ID running out
-- We can shorten the loops for sequences from 20 to 5 if we can extend the test - less errors

-- Cons:
-- We have to be sure that sequences with the same UE_ID are not runnign at the same time

-- SA_UES
SA_IMSI = 21640000

-- BACKGROUND SA UES, UEID "1" AS FIRST DIGIT - WITH IMEISV SET FOR EMIL TRACES IDENTIFICATION
for SA_UEID = 1, 199 do
     if SA_UEID < 10 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=0000001'..SA_UEID..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_DL4CC_UL2CC_IDLE')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
     elseif SA_UEID >= 10 and SA_UEID < 100 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=000001'..SA_UEID..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_DL4CC_UL2CC_IDLE')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
     else
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=00001'..SA_UEID..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_DL4CC_UL2CC_IDLE')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    end
end

-- SEQUENCE UES FOR N25, UEID "2" AS FIRST DIGIT + SEQUENCE NUMBER - WITH IMEISV SET FOR EMIL TRACES IDENTIFICATION
for SA_UEID = 2001, 2104 do
    if SA_UEID < 2010 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=0000002'..SA_UEID - 2000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    elseif SA_UEID >= 2010 and SA_UEID < 2100 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=000002'..SA_UEID - 2000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    else
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=00002'..SA_UEID - 2000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    end
end

-- SEQUENCE UES FOR N41, UEID "4" AS FIRST DIGIT + SEQUENCE NUMBER - WITH IMEISV SET FOR EMIL TRACES IDENTIFICATION
for SA_UEID = 4001, 4104 do
    if SA_UEID < 4010 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=0000004'..SA_UEID - 4000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    elseif SA_UEID >= 4010 and SA_UEID < 4100 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=000004'..SA_UEID - 4000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    else
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=00004'..SA_UEID - 4000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
     end
end

-- SEQUENCE UES FOR N71, UEID "7" AS FIRST DIGIT + SEQUENCE NUMBER - WITH IMEISV SET FOR EMIL TRACES IDENTIFICATION
for SA_UEID = 7001, 7104 do
    if SA_UEID < 7010 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=0000007'..SA_UEID - 7000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    elseif SA_UEID >= 7010 and SA_UEID < 7100 then
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=000007'..SA_UEID - 7000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
    else
          exec('set_ue simulated id='..SA_UEID..' uec=1 imeisv=00007'..SA_UEID - 7000 ..':000001:01 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:310:260:0000:0:0:0'.. SA_IMSI + SA_UEID - 1 ..' enb=2 cell=201')
          exec('ue_param capability_file='..CFG_CAPA..' id='..SA_UEID..' ue_nr_capabilities=SA_S24_CAPA')
          exec('set_pdu_param ue='..SA_UEID..' pdu=1 trf_type=internal')
          exec('set_pdu_param ue='..SA_UEID..' pdu=2 trf_type=internal default_qos_flow=2')
     end
end

--NSA_UES

for i=1001,1200 do
	 local ip = (i - 1000)
	 exec('set_ue simulated id='..i..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null nea=null eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi=310:260:21645'..i)
     exec('ue_param capability_file='..CFG_CAPA..' id='..i..
          ' ue_nr_capabilities=NSA_S23_UE_CAPA dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities=NR_EUTRA_S23_CAPA')
     exec('set_bearer id=2 ue='..i..
          ' qci=9 pdn=1 ip=4.7.254.'..ip..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
end

-- NETWORK SLICING AND QI
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=9')
exec('set_qosflow id=5 5qi=128')
exec('set_qosflow id=6 5qi=7')
exec('set_qosflow id=7 5qi=2')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=tcp qos_flow=5')
exec('set_qosrule id=4 proto=tcp qos_flow=6')
exec('set_qosrule id=5 proto=tcp qos_flow=1')
exec('set_qosrule id=6 proto=tcp qos_flow=1')
exec('set_qosrule id=7 proto=tcp qos_flow=4')
exec('set_qosrule id=8 proto=tcp qos_flow=7')
--SNSSAI-1
exec('nwslice_set id=1 qos_flows=1,2,3,4,7 qos_rules=1,2,5,7,8 snssai=0x01:0xFFFFFF default=on ue=all amf=1')
--SNSSAI-2 SD:1000
exec('nwslice_set id=2 qos_flows=4 qos_rules=7 snssai=0x01:0x3E8 ue=all amf=1')
--SNSSAI-3 SD:2000
exec('nwslice_set id=3 qos_flows=1 qos_rules=6 snssai=0x01:0x7D0 ue=all amf=1')
--SNSSAI-4 SD:3000
exec('nwslice_set id=4 qos_flows=1 qos_rules=6 snssai=0x01:0xBB8 ue=all amf=1')
--SNSSAI-8 SD:7000
exec('nwslice_set id=8 qos_flows=5 qos_rules=3 snssai=0x01:0x1B58 ue=all amf=1')
--SNSSAI-10 SD:9000
exec('nwslice_set id=10 qos_flows=1 qos_rules=5 snssai=0x01:0x2328 ue=all amf=1')
--SNSSAI-11 SD:10000
exec('nwslice_set id=11 qos_flows=6 qos_rules=4 snssai=0x01:0x2710 ue=all amf=1')
--SNSSAI-19 SD:9001
exec('nwslice_set id=19 qos_flows=1 qos_rules=5 snssai=0x01:0x2329 ue=all amf=1')






exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
exec('amf_paging_param id=1 default_drx=128')

--exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=40,20,-40,-40')
--exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
--exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')

-- MISC
exec('sim_param_set TTI=2 NR_CLUB_PROXY_PROTO_MSGS=enabled NR_PDCP_CIPHERING=distributed NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
--exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('debug_log level=6')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('sim_trace amf=1 protocol=ng off')
exec('sim_trace uec=1 protocol=all off')
exec('sim_trace amf=1 protocol=all off')
--exec('sim_debug_log level=0 uec=1')
--exec('sim_debug_log level=4 enb=1')
--exec('sim_debug_log level=4 enb=2')

exec('set_log log_to_file=off')
--exec('sim_debug_log level=0 uec=1')
--exec('sim_debug_log level=1 app_type=ueproxy')
exec('cfg_end')
--exec('sim_rfm_filter disable=all')
--exec('sim_rfm_filter enable=VIP')
--exec('sim_rfm_filter uec=1 enable=INFO')
--exec('sim_rfm_filter amf=1 enable=INFO')
exec('sim_start version_check=off')

sleep(30)
exec('amf_ue_ics_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=310:260 tac_id=200 include_masked_imeisv=on')
exec('amf_ue_path_switch_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=310:260 tac_id=200')
exec('amf_ue_ng_handover_request_param id=1 core_network_assistance_info=on ue_identity_index_value=1 ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=310:260 tac_id=200')
exec('enb_x2_link_up enb=1 target=2')
