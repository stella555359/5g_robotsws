-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
local CONTAINER_IP="10.0.2.1"
local  DAEMON_IP="10.0.2.1"
local  SERVER_IP="10.0.2.1"
local  DAEMON_PORT=10000
local  GNB_NG_ADDR="10.0.1.2"
local  PROXY_SERVER_IP="10.0.2.80"
local  AMF_NG_ADDR="10.0.1.1"
local  UEC_ADDR="72.22.0.1"
local  UPF_ADDR="1.2.4.1"
local  EDAEMON_PORT="10000"


-- Variables for NSA configuration

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
local PDN_IP="4.7.254.208"

require('os')
os.execute('sudo ip addr add 10.0.1.131/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.132/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.133/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.134/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.135/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.136/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.137/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.99/24 dev eth3')
os.execute('sudo ip addr add 10.0.2.99/24 dev eth4')
os.execute('sudo ip addr add 10.0.1.121/24 dev eth3')

----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=250:255 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=300:18300 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=777:14 eq_plmn=250:255 tac_list=777,111,222,444,333')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135760:126380 mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
----------------------------------------------------------------------------------------------------

--UE 1,2 VoNR supported
for i=1,2 do
exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
exec('ue_param id='..i..' ue_nr_capabilities=21A000000109000800C46AA4FFD3FF0110388C00000014DE000000000000040A00000000000000A000004008011280000114')
end
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(3+10)..':0:0:0216454'..(3+10).. ' enb=2 cell=1')
exec('ue_param id=3 ue_nr_capabilities=21A000000109000800C46AA4FFD3FF0110388C00000014DE000000000000040A00000000000000A000004008011280000000')
for i=4,15 do
    exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null+zuc+snow3g+aes sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i+10)..':0:0:0216454'..(i+10).. ' enb=2 cell=1')
    exec('ue_param id='..i..' ue_nr_capabilities=21A000000109000800C46AA4FFD3FF0110388C00000014DE000000000000040A00000000000000A000004008011280000114')
end
-- UE Id=1 SA vonr not supported
-- set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1
-- ue_param id=1 ue_nr_capabilities=212000000109000800046AA0110023000053780000000000001150000000000000150940000088

exec('set_ue simulated id=16 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00  nia=zuc nea=zuc imsi=250:555:21645500')
exec('ue_param id=16 ue_nr_capabilities=E1A01000014F5E0302C0020640024106CE261F0A1201360107FE618F28581C130080C450180531800507C46D618DA3A4C5411FCB293650580416C9824060C78C7FE618F28581C0E1E0227009C00110388C000000100210602372687C0390400000290400000A90400001292500001A601F036F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501740F2E9565D03C9A55934AB22BB902401E006804020000000000080100210  dual_conn=eutra_nr ue_eutra_nr_capabilities=a10181102c0c0388c000000888160641c460000024400401c0462002100008040401803080008020200c0180')
----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=1 ue=all')
exec('set_qosflow id=5 5qi=5 default=on')
exec('set_qosflow id=6 5qi=6 ue=all')
exec('set_qosflow id=2 5qi=2 ue=all')

exec('qosrule_set id=1 proto=udp qos_flow=1')
exec('qosrule_set id=2 proto=tcp qos_flow=5')
exec('qosrule_set id=3 proto=udp qos_flow=6')
exec('qosrule_set id=4 proto=udp qos_flow=2')

exec('set_nwslice id=1 snssai=0x01:0xD143A5 default=on amf=1 qos_flows=1,2,5,6 qos_rules=1,2,3,4')
exec('set_nwslice id=2 snssai=0x01:0xD143A6 amf=1 qos_flows=1,2,5,6 qos_rules=1,2,3,4')
for i=1,15 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
exec('set_pdu_gateway id=16 ue_nat_ip=72.23.0.16 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_bearer id=2 ue=16 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

----------------------------------------------------------------------------------------------------
exec('debug_log level=0')
exec('link_ctrl_param use_hb=off')
exec('set_log log_to_file=on')
exec("set_log flush")
exec('cfg_end')
sleep(1)


