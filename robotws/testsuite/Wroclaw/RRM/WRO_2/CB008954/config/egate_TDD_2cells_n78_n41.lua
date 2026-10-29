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

local ENB1_S1_ADDR="10.0.1.20"
local ENB1_X2_ADDR="10.0.1.21"
local ENB1_X2U_ADDR="10.0.1.21"
local AMF1_NG_ADDR="10.0.1.1"

local GNB_SIM_NG_ADDR="10.0.1.30"
local GNB_SIM_XN_ADDR="10.0.1.31"
local GNB_SIM_X2_ADDR="10.0.1.32"
local GNB_SIM_S1U_ADDR="10.0.1.33"
local AMF1_NG_ADDR="10.0.1.1"

local MME1_S1_ADDR="10.0.1.11"
local SGW_S1U_ADDR=MME1_S1_ADDR
local SGW_S11_ADDR=MME1_S1_ADDR

local PDN_IP="4.7.254.208"

require('os')
os.execute('sudo ifconfig eth3:AMF1 add '..AMF1_NG_ADDR)
os.execute('sudo ifconfig eth3:WTS1 add '..ENB1_S1_ADDR)
os.execute('sudo ifconfig eth3:WTS2 add '..ENB1_X2_ADDR)
os.execute('sudo ifconfig eth3:MME1 add '..MME1_S1_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB_SIM_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB_SIM_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB3_X2 add '..GNB_SIM_X2_ADDR)
os.execute('sudo ifconfig eth3:gNB3_S1U add '..GNB_SIM_S1U_ADDR)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY2_SERVER_IP)

-----------------------------------------------------------------------------------------------------
--EPCSIM CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..':2152 s11='..SGW_S11_ADDR..':2153')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' devtype=tun devname=tunPGW addr=4.7.254.207/16')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,200,788,0 plmn=311:489')
exec('set_amf id=1 name=AMF1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF1_NG_ADDR.. ' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

-----------------------------------------------------------------------------------------------------
--ENB1 sim CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB1_X2U_ADDR..' type=simulated x2_peers=all')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=300:18300 tdd_cell=off mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 x2='..GNB_X2_ADDR..':36422 xn='..GNB_XN_ADDR..':38422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 bwp_arfcn=634002:634002,635600:635600 gscn=7853 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=518598:518598 bwp_arfcn=517600:517600 gscn=6468 mandatory_for_activation=off')

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 s1u='..GNB_SIM_S1U_ADDR..' ng='..GNB_SIM_NG_ADDR..' gnb_id=0x76D x2='..GNB_SIM_X2_ADDR..':36422 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=1 xn='..GNB_SIM_XN_ADDR..':38422 nssai=0x1:0xD143A5 amf=1')
exec('set_cell id=1 gnb=3 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' gscn=7853 nr_arfcn=633984:633984 nr_scs=30kHz bs_channel_bandwidth=70MHz suggested_band=78')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s measEvent=A5')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26')


-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1')
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1')
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645403 mode=nr enb=2 cell=1')
exec('set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645404 mode=nr enb=2 cell=1')
exec('set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645405 mode=nr enb=2 cell=1')

exec('ue_param id=1 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531004507C1BD618DA210000000000200900F5B000000000007FE618F28581C0E1E93C04F00A0F851AC31B47498A823F96526CA090105B260901831E31FF9863CA16070387808BC02F00A0E09BAC31B47498A823F96526CA090105B260901831E31FF9863CA1607038780805C2E0D80070A000389A000001FE0103EC260070005838280381804C00E000D03C0290400000290400000A90400001200981B591B595340204000025949410000196525040000A5949402503CAA47954AB200020100200404010020100600C200')
exec('ue_param id=2 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531004507C1BD618DA210000000000200900F5B000000000007FE618F28581C0E1E93C04F00A0F851AC31B47498A823F96526CA090105B260901831E31FF9863CA16070387808BF02FC2A0E09BAC31B47498A823F96526CA090105B260901831E31FF9863CA1607038780848800D94000140000002E1706C003850001C4D000000FF0081F6130038002C1C1401C0C026007000681E01482000001482000005482000009004C0DAC99ACA5A0102000012CA4A080000CB29282000052CA4A01281E5526CAA539000100801002020080100803006100')
exec('ue_param id=3 ue_nr_capabilities=E1A01000014F5E0342C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C401141F06F5863688400000000008044003D6C00000000001FF9863CA16070387A4F013C0283E146B0C6D1D262A08FE5949B284400416C9824060C78C7FE618F28581C0E1E022F00BC0283E26EB0C6D1D262A08FE5949B284400416C9824060C78C7FE618F28581C0E1E022FE0BF80170B836001C28000E268000007F8040F2683C0290400000290400000A90400001200981B5933594B40204000025949410000196525040000A5949402503CAA4D954A7200020100200404010020100600C20')
exec('ue_param id=4 ue_nr_capabilities=E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531004507C1BD618DA210000000000200900F5B000000000007FE618F28581C0E1E93C04F00A0F851AC31B47498A823F96526CA090105B260901831E31FF9863CA16070387808BF82FE0A0F89BAC31B47498A823F96526CA090105B260901831E31FF9863CA16070387808BC02F0005C2E0D80070A000389A000001FE0103C9A0F00A41000000A41000002A41000004802606D64CD652D008100000965250400006594941000029652500940F2A9365529C800080400801010040080400801080')
exec('ue_param id=5 ue_nr_capabilities=E1A01000014F5E0342C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C401141F06F5863688400000000008044003D6C00000000001FF9863CA16070387A4F013C0283E146B0C6D1D262A08FE5949B284400416C9824060C78C7FE618F28581C0E1E022F00BC0A83826EB0C6D1D262A08FE5949B284400416C9824060C78C7FE618F28581C0E1E021C20001B28000280000005C2E0D80070A000389A000001FE0103C9A0F00A41000000A41000002A41000004802606D64CD652D008100000965250400006594941000029652500940F2A9365529C80008040080101004008040180308')
-----------------------------------------------------------------------------------------------------
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on ue=all amf=1')

exec('debug_log level=4')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng off')
exec('cfg_end')
sleep(1)
exec('set_log log_to_file=on')
exec('start version_check=off')
