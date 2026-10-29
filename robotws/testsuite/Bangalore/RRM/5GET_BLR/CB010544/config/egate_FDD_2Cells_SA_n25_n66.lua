-- Copyright (c) 2022 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"
local SERVER_IP=DAEMON_IP

local GNB_NG_ADDR="10.0.1.2"
local GNB_X2_ADDR=GNB_NG_ADDR
local GNB_XN_ADDR=GNB_NG_ADDR
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local AMF1_NG_ADDR="10.0.1.1"

local MME1_S1_ADDR="10.0.1.11"
local SGW_S1U_ADDR=MME1_S1_ADDR
local SGW_S11_ADDR=MME1_S1_ADDR

require('os')
os.execute('sudo ifconfig eth3:AMF1 add '..AMF1_NG_ADDR)
os.execute('sudo ifconfig eth3:MME1 add '..MME1_S1_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)

-----------------------------------------------------------------------------------------------------
--EPCSIM CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF1_NG_ADDR)

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 x2='..GNB_X2_ADDR..':36422 xn='..GNB_XN_ADDR..':38422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=374500:390500 gscn=4867 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=345000:425000 gscn=5299 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')


-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0011:0:0:021645411 mode=nr enb=2 cell=1')
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0012:0:0:021645412 mode=nr enb=2 cell=1')
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0013:0:0:021645413 mode=nr enb=2 cell=1')

exec('set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=1')


exec('ue_param id=1 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C18D618DA210000000000200900F5B000000000007FE618F28581C0E1E93F04FC0A0F883AC31B4420000000000401201EB600000000000FFCC31E50B0381C3D27809E000B83C18000E208000007F805FFFFFFFFF003006202672687C0190400000290400000A00782B781B401040000259494100001965250074172E81E509007801A0100800000000202004008080200410')
exec('ue_param id=2 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C18D618DA210000000000200900F5B000000000007FE618F28581C0E1E93F04FC0A0F883AC31B4420000000000401201EB600000000000FFCC31E50B0381C3D27809E000B83C18000E208000007F805FFFFFFFFF003006202672687C0190400000290400000A00782B781B401040000259494100001965250074172E81E509007801A0100800000000202004008080200410')
exec('ue_param id=3 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C18D618DA210000000000200900F5B000000000007FE618F28581C0E1E93F04FC0A0F883AC31B4420000000000401201EB600000000000FFCC31E50B0381C3D27809E000B83C18000E208000007F805FFFFFFFFF003006202672687C0190400000290400000A00782B781B401040000259494100001965250074172E81E509007801A0100800000000202004008080200410')

exec('ue_param id=5 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531802507C18D618DA210000000000200900F5B000000000007FE618F28581C0E1E93F04FC0A0F883AC31B4420000000000401201EB600000000000FFCC31E50B0381C3D27809E000B83C18000E208000007F805FFFFFFFFF003006202672687C0190400000290400000A00782B781B401040000259494100001965250074172E81E509007801A0100800000000202004008080200410')

-----------------------------------------------------------------------------------------------------
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

exec('set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')


exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('start version_check=off')
