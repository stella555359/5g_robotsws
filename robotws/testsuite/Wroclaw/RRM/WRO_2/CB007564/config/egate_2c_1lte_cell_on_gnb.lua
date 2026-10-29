-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
local  CONTAINER_IP="10.0.2.1"
local  DAEMON_IP="10.0.2.1"
local  SERVER_IP="10.0.2.1"
local  DAEMON_PORT=10000
local  GNB_NG_ADDR="10.0.1.2"
local  PROXY_SERVER_IP="10.0.2.80"
local  PROXY2_SERVER_IP="10.0.2.90"
local  PROXY3_SERVER_IP="10.0.2.100"
local  GNB_SIM_NG_ADDR="10.0.1.30"
local  GNB_SIM_XN_ADDR="10.0.1.31"
local  AMF_NG_ADDR="10.0.1.1"
local  UEC_ADDR="72.22.0.1"
local  UPF_ADDR="1.2.4.1"
local  EDAEMON_PORT="10000"
local  AP_CONFIG_PATH="/home/ute/Auto5G/testsuite/Krakow/RRM/DevKr/CB007564/config/AirPhoneConfigFDD.xml"


-- Variables for NSA configuration

local GNB_S1U_ADDR="10.0.1.112"
local GNB_X2_ADDR="10.0.1.2"
local SERVER_ADDR="10.0.1.132"
local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"
exec('set_log log_to_file=on')
require('os')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.80')
os.execute('sudo ifconfig eth4:gNB3_PR add 10.0.2.90')
os.execute('sudo ifconfig eth4:gNB3_PR2 add 10.0.2.100')
os.execute('sudo ifconfig eth3:gNB3_NG add 10.0.1.30')
os.execute('sudo ifconfig eth3:gNB3_XN add 10.0.1.31')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0,222 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' xn='..GNB_NG_ADDR..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5,0x01:0xD143A6')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--GNB3 sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=1 type=simulated plmn=311:489 ng='..GNB_SIM_NG_ADDR..' daemon='..SERVER_IP..':'..DAEMON_PORT..' gnb_id=76D nssai=0x01:0xD143A5,0x01:0xD143A6 xn='..GNB_SIM_XN_ADDR..'')
exec('set_cell id=1 gnb=1 pci=3:2 earfcn=300:18300 tac=222 proxy='..PROXY2_SERVER_IP..':'..DAEMON_PORT..' nrci=0x01 tdd_cell=on bw=20MHz technology=lte mandatory_for_activation=off')
exec('set_cell id=2 gnb=1 pci=18:0 tac=0 nrci=0x02 tdd_cell=off proxy='..PROXY3_SERVER_IP..':'..DAEMON_PORT..' gscn=1582 nr_arfcn=135760:126380 mandatory_for_activation=off')
exec('gnb_param id=1 xn_listening_socket=on send_xn_setup=off')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')
----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
----------------------------------------------------------------------------------------------------
--UE 1,15 VoNR supported
for i=1,15 do
exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=3')
exec('ue_param id='..i..' ue_nr_capabilities=35A000000109000800C46AA4FFD3FF0110388C0000001D01200300CC0500501802400501E000000000000040A00000000000000A0000040080112800001140')
end
----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_qosflow id=5 5qi=5 default=on')
exec('set_qosflow id=6 5qi=6 ue=all')
exec('set_qosflow id=1 5qi=1 ue=all')

exec('qosrule_set id=1 proto=udp qos_flow=1')
exec('qosrule_set id=2 proto=tcp qos_flow=5')
exec('qosrule_set id=3 proto=udp qos_flow=6')
exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,5,6 qos_rules=1,2,3')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=1,5,6 qos_rules=1,2,3')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
----------------------------------------------------------------------------------------------------
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)

