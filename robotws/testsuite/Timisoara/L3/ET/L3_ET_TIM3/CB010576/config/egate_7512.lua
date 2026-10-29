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


local AP_CONFIG_FILE="/home/ute/MN/UTE/robotws/testsuite/Wroclaw/RRM/5G_SW_WRO/CB007512/config/AirPhoneConfig_TDD_NSA_L1B_eCPRI.xml"

exec('set NSA_UE_CAPABILITIES=0300000002000800000180008002002000100000018004000000DE00000000000004E8000200000000020023B4')
exec('set NR_EUTRA_CAPABILITIES=01080402E000007134003A0000000000100801002020040080801002')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9,8,7,6')
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
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2077819:2077819 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2077919:2077919 mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 file='..AP_CONFIG_FILE)
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

--UE Id=1 SA
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C032A36146B04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D899AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F570004F001C0013C002A3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C0013C0070004F000A8D89DAC10143404B2CA261A007AD8202020E1DE38720C38002064F1F55000005000000108389A00000000404D1700007008089EC2E003000281C1401C0C026007000683E0000000000000E6340004000025965400D32A85800E001600000008010023162600020406080A0C0E10162022242632424A4C4E5094')

--UE Id=11 NSA
--exec('set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=aes+zuc+snow3g+null nea=aes+zuc+snow3g+null imsi=311:489:21645502')
--exec('ue_param id=11 ue_nr_capabilities=010000000188000080009A20001000000078000000000000118000080000000000008640  dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')


exec('set_ue simulated id=11 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:21645400')
exec('ue_param id=11 ue_nr_capabilities=$NSA_UE_CAPABILITIES dual_conn=eutra_nr ue_eutra_nr_capabilities=$NR_EUTRA_CAPABILITIES')

---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=7 default=off')
exec('set_qosflow id=3 5qi=8 default=off')
exec('set_qosflow id=4 5qi=9 default=off')

exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=1,11')
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_bearer id=1 ue=11 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('set_bearer id=2 ue=11 qci=8 pdn=1 default=off')
exec('set_bearer id=3 ue=11 qci=7 pdn=1 default=off')
exec('set_bearer id=4 ue=11 qci=6 pdn=1 default=off')

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
exec('start version_check=off')
