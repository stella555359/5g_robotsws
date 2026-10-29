-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local SERVER_IP=CONTAINER_IP

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local EDAEMON_PORT="10000"

--Variables for NSA configuration
local ENB1_S1_ADDR="10.0.1.20"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.21"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"
local PDN_IP2="4.7.254.209"
local PDN_IP3="4.7.254.210"

require('os')
os.execute('sudo sysctl -w net.sctp.rto_min=400')
os.execute('sudo ip addr add 10.0.1.131/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.132/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.133/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.134/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.135/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.20/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.21/24 dev eth3')


-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..SERVER_IP..':12219|'..SERVER_IP..':8889 earfcn=300:18300 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..SERVER_IP..':'..EDAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..SERVER_IP..':'..EDAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..'')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION NR-ARFCN values UL:DL
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1')

exec('set_cell id=1 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=499200:499200 gscn=6240 mandatory_for_activation=off bwp_arfcn=497220:497220')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=499200:499200 gscn=6240 mandatory_for_activation=off bwp_arfcn=497220:497220')
exec('set_cell id=3 gnb=2 pci=17:2 tac=200 nrci=0x03 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=345000:425000 gscn=5311 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=18:0 tac=200 nrci=0x04 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=345000:425000 gscn=5311 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec("set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=lte enb=1 cell=1 imsi=311:489:21645500")
exec("set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=lte enb=1 cell=1 imsi=311:489:21645501")

exec('set_bearer id=2 ue=1 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('set_bearer id=2 ue=2 qci=9 pdn=1 ip='..PDN_IP2..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')

exec("ue_param id=1 ue_nr_capabilities=E1A01000014F5E0342C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014CE00941F107586368E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E024081020283E146B0C6D1D262A08FE5949B281C082D930480C18F18FFCC31E50B0381C3C04401900604E0F0A0003882000001FE017FFFFFFFFDC1E14000710400000BFC02FFFFFFFFF801808300A0290070218C1C9A1F00E41000000A41000002A41000004A41000006803E52D650C608C608C00C1000009652504000040000010000200000040000C0000003D29CBA519141322826409007801A010080000000400600400C018030808020040201002040")
exec("ue_param id=1 dual_conn=eutra_nr ue_eutra_nr_capabilities=a10381384c0403850001c410000001602e7ffffffdc260201c28000e208000010b0173ffffffe00800c041805024800380863020022000080404008010100600c40001008080200402010020")
exec("ue_param id=2 ue_nr_capabilities=E1A01000014F5E0342C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014CE00941F107586368E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E024081020283E146B0C6D1D262A08FE5949B281C082D930480C18F18FFCC31E50B0381C3C04401900604E0F0A0003882000001FE017FFFFFFFFDC1E14000710400000BFC02FFFFFFFFF801808300A0290070218C1C9A1F00E41000000A41000002A41000004A41000006803E52D650C608C608C00C1000009652504000040000010000200000040000C0000003D29CBA519141322826409007801A010080000000400600400C018030808020040201002040")
exec("ue_param id=2 dual_conn=eutra_nr ue_eutra_nr_capabilities=a10381384c0403850001c410000001602e7ffffffdc260201c28000e208000010b0173ffffffe00800c041805024800380863020022000080404008010100600c40001008080200402010020")
-----------------------------------------------------------------------------------
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=7 ue_nat_ip=72.23.0.7 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=8 ue_nat_ip=72.23.0.8 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')

exec('debug_log level=6')
exec('sim_debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
sleep(1)
exec('set_log log_to_file=on')
exec('start version_check=off')

