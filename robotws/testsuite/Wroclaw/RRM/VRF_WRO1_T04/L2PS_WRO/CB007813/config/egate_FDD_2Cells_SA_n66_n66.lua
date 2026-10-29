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
exec('set_cell id=1 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=355000:437000 gscn=5437 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=348000:429000 gscn=5337 mandatory_for_activation=off')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')


-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
--UE1 PCell_N66_30M_SCell_N66_30M
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=F5A03C0047D4FFBEFFFFBAF064003C170101E0935F3FFFB7C009009B3CE3FF30C7942C020DC0407E3004517C18FF9BCA3BC857C1043E594962090105B29BA01893EB1079127C245116F9F8053FF4FFEA2F883FF37944215F0410F9652588240416CA6E80624FAC41E449F091445BE7E014FFD3FF121000C1145F007FE6F288403E000012CA4B1048082D94DD00C49F5883C893E12288B7CFC029FFA7FE02A0F104003882000001FE7FFFFFFFFC3C0044031234081B24F807FFFC00026007C005038280301884C00C000F07400E0A00C06000040000601200301F00AC900100000804AC90000022C9000004002606560A560A500990000012CA4AC8000089652564000084B292804A0755406AA80D50900A801792701E49C0792500000206008014018030300600E00C01851140')
--UE2 PCell_N66_20M_SCell_N66_20M
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1')
exec('ue_param id=2 ue_nr_capabilities=F5A03C0047D4FFBEFFFFBAF064003C170101E0935F3FFFB7C009009B3CE3FF30C7942C020DC0407E3004517C18FF9BCA3BC857C1043E594962090105B29BA01893EB1079127C245116F9F8053FF4FFEA2F883FF37944215F0410F9652588240416CA6E80624FAC41E449F091445BE7E014FFD3FF121000C0145F007FE6F288403E000012CA4B1048082D94DD00C49F5883C893E12288B7CFC029FFA7FE02A0F104003882000001FE7E000000003C0044031234081B24F807FFFC00026007C005038280301884C00C000F07400E0A00C06000040000601200301F00AC900100000804AC90000022C900000400260656065606500990000012CA4AC8000089652564000084B292804A075540EAA80D50900A801792701E49C0792500000206008014018030100600C288A0')
-----------------------------------------------------------------------------------------------------
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')


exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('start version_check=off')
