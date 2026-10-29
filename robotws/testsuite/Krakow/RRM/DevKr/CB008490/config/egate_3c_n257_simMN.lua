---  Copyright (c) 2019 Nokia. All rights reserved.

------------------------------------------------------------------------------------------------------
--- VARIABLES
------------------------------------------------------------------------------------------------------
local SERVER_IP="10.0.2.1"
local DAEMON_PORT="10000"
local EDAEMON_PORT="10000"
-- local GNB1_NG_ADDR="10.0.1.2"
local GNB2_NG_ADDR="10.0.1.3"
local GNB2_XN_ADDR="10.0.1.2"
local GNB3_NG_ADDR="10.0.1.4"
local GNB3_XN_ADDR="10.0.1.4"
-- local GNB4_NG_ADDR="10.0.1.7"
-- local GNB4_XN_ADDR="10.0.1.8"
local PROXY_SERVER_IP="10.0.2.80"
-- local PROXY2_SERVER_IP="10.0.2.90"
-- local PROXY3_SERVER_IP="10.0.2.100"
-- local PROXY4_SERVER_IP="10.0.2.110"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"

--- Variables for NSA configuration

-- local ENB1_S1_ADDR="10.0.1.136"
-- local GNB1_S1U_ADDR="10.0.1.112"
-- local GNB2_S1U_ADDR="10.0.1.113"
--
-- local ENB1_X2_ADDR="10.0.1.137"
-- local GNB1_X2_ADDR="10.0.1.2"
-- local GNB2_X2_ADDR="10.0.1.4"
--
-- local MME1_S1_ADDR="10.0.1.131"
--
-- local SERVER_ADDR="10.0.1.132"
-- local SGW_S1U_ADDR="10.0.1.133"
-- local SGW_S11_ADDR="10.0.1.134"
--
-- local ENB_X2U_ADDR="10.0.1.135"

-- local PGW_ADDR="4.7.254.1"
local PDN_IP="4.7.254.208"


-- os.execute('sudo ifconfig eth4:gNB2_PR add '..PROXY2_SERVER_IP)
-- os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY3_SERVER_IP)
-- os.execute('sudo ifconfig eth4:gNB4_PR add '..PROXY4_SERVER_IP)
-- os.execute('sudo ifconfig eth3:gNB1_NG add '..GNB1_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB2_NG add '..GNB2_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB2_XN add '..GNB2_XN_ADDR)
-- os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB3_NG_ADDR)
-- os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB3_XN_ADDR)
-- os.execute('sudo ifconfig eth3:gNB4_NG add '..GNB4_NG_ADDR)
-- os.execute('sudo ifconfig eth3:gNB4_XN add '..GNB4_XN_ADDR)
-- os.execute('sudo ifconfig eth3:gNB1_S1U add '..GNB1_S1U_ADDR)


------------------------------------------------------------------------------------------------------
--- 5GCN CONFIGURATION
------------------------------------------------------------------------------------------------------

exec('set_amf_region id=1 tac_list=7627107,222,100,0,1,2 plmn=311:489,311:490')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..'')

------------------------------------------------------------------------------------------------------
--- GNB2 MN sim CONFIGURATION
------------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=simulated plmn=311:489 ng='..GNB2_NG_ADDR..' xn='..GNB2_XN_ADDR..' gnb_id=0x02:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0x000001')
exec('gnb_param id=2 xn_listening_socket=1 sib1_period=160 send_xn_setup=true measEvent=A2 measEvent=A3 sa_ho=xn_based')
exec('set_cell id=1 gnb=2 pci=16:2 tac=1 nrci=0x01 tdd_cell=on proxy='..GNB2_XN_ADDR..':9999|'..GNB2_XN_ADDR..':8888  nr_arfcn=633364:633364 mandatory_for_activation=off gscn=7846 suggested_band=78')
exec('gnb_cell_param gnb=2 id=all scs_common=30 scs_ss_pbsch=30 ssb_offset=0 cell_barred=off allow_intra_freq_reselection=on ssb_period=5 allow_nrdc=on')

---------------------------------------------------------------------------------------------------
--- GNB3 SN real configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=external plmn=311:489 ng='..GNB3_NG_ADDR..' xn='..GNB3_XN_ADDR..' gnb_id=0x03:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0x000001')
exec('set_cell id=2 gnb=3 pci=17:1 tac=1 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2071591:2071591 mandatory_for_activation=off gscn=22446 suggested_band=257')
exec('set_cell id=3 gnb=3 pci=17:2 tac=1 nrci=0x03 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2071593:2071593 mandatory_for_activation=off gscn=22446 suggested_band=257')
exec('set_cell id=4 gnb=3 pci=18:0 tac=1 nrci=0x04 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=2071595:2071595 mandatory_for_activation=off gscn=22446 suggested_band=257')

---------------------------------------------------------------------------------------------------
--- GNB4 MN sim configuration
---------------------------------------------------------------------------------------------------
-- exec('set_gnb id=4 type=simulated plmn=311:489 ng='..GNB3_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB3_XN_ADDR..' nssai=0x1:0x000001 amf=1')
-- exec('set_cell id=1 gnb=4 pci=15:1 tac=0 nrci=0x01 tdd_cell=off proxy='..PROXY3_SERVER_IP..':'..EDAEMON_PORT..' gscn=5313 nr_arfcn=347380:425040 nr_scs=15kHz bs_channel_bandwidth=10MHz')
-- exec('gnb_param id=4 xn_listening_socket=on send_xn_setup=off sib1_period=10s')
--
-- ---------------------------------------------------------------------------------------------------
-- --- ENB1 sim configuration with fake enb cell
-- ---------------------------------------------------------------------------------------------------
-- exec('set_gnb id=1 type=simulated plmn=311:489 ng='..GNB4_NG_ADDR..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x76E x2_peers=none xn='..GNB4_XN_ADDR..' nssai=0x1:0x000001 amf=1')
-- exec('set_cell id=1 gnb=1 pci=3:2 tac=222 nrci=0x01 tdd_cell=on proxy='..PROXY4_SERVER_IP..':'..EDAEMON_PORT..' earfcn=2000:20000 bw=20MHz technology=lte mandatory_for_activation=off')
-- exec('gnb_param id=1 xn_listening_socket=on send_xn_setup=off')

------------------------------------------------------------------------------------------------------
--- UEC CONFIGURATION
------------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 sctp_rto_min=100')

------------------------------------------------------------------------------------------------------
--- UE CONFIGURATION
------------------------------------------------------------------------------------------------------

--- UE Id=1 SA with support of inter-RAT HO
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C4DD608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E236B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC6188000180E81680E06F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800118789A001D000000000801809B0400650001E01851276C73E180E028003D06E003E002800301C1401C0C0250070006020211001042C04200100032780200800000925000009600F282B7480082000012CA4A080000CB292803A51555DA800040400801010040084AC2800080C54708494A01105350A1720100670')

exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=1')
exec('ue_param id=2 ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C4DD608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E236B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC6188000180E81680E06F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800118789A001D000000000801809B0400650001E01851276C73E180E028003D06E003E002800301C1401C0C0250070006020211001042C04200100032780200800000925000009600F282B7480082000012CA4A080000CB292803A51555DA800040400801010040084AC2800080C54708494A01105350A1720100670')

exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645402 mode=nr enb=2 cell=1')
exec('ue_param id=3 ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C4DD608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E236B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E20EB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC6188000180E81680E06F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800118789A001D000000000801809B0400650001E01851276C73E180E028003D06E003E002800301C1401C0C0250070006020211001042C04200100032780200800000925000009600F282B7480082000012CA4A080000CB292803A51555DA800040400801010040084AC2800080C54708494A01105350A1720100670')
---
------------------------------------------------------------------------------------------------------
--- COMMON CONFIGURATION
------------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 ue=all')
exec('set_qosflow id=3 5qi=1 ue=all')
exec('set_qosflow id=4 5qi=7 ue=all')
exec('set_qosflow id=5 5qi=8 ue=all')
exec('set_qosflow id=6 5qi=9 ue=all')
exec('set_qosflow id=7 5qi=170 ue=all')
exec('set_qosrule id=1 proto=tcp qos_flow=1')
exec('set_qosrule id=2 proto=udp qos_flow=2')
exec('set_qosrule id=3 proto=tcp qos_flow=3')
exec('set_qosrule id=4 proto=tcp qos_flow=4')
exec('set_qosrule id=5 proto=tcp qos_flow=5')
exec('set_qosrule id=6 proto=tcp qos_flow=6')
exec('set_qosrule id=7 proto=tcp qos_flow=7')
exec('set_nwslice id=1 snssai=0x01:0x000001 amf=1 default=on ue=all qos_flows=1,2,3,4,5,6,7 qos_rules=1,2,3,4,5,6,7')
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=2 ue_nat_ip=72.23.0.2 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=3 ue_nat_ip=72.23.0.3 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=4 ue_nat_ip=72.23.0.4 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=5 ue_nat_ip=72.23.0.5 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=6 ue_nat_ip=72.23.0.6 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=7 ue_nat_ip=72.23.0.7 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=8 ue_nat_ip=72.23.0.8 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=11 ue_nat_ip=72.23.0.11 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=12 ue_nat_ip=72.23.0.12 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=13 ue_nat_ip=72.23.0.13 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=14 ue_nat_ip=72.23.0.14 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=15 ue_nat_ip=72.23.0.15 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=16 ue_nat_ip=72.23.0.16 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=17 ue_nat_ip=72.23.0.17 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
exec('set_pdu_gateway id=18 ue_nat_ip=72.23.0.18 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')

------------------------------------------------------------------------------------------------------
--- OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
--- exec('set_bearer id=2 ue=11 qci=9 pdn=1 ip='..PDN_IP..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=12 qci=9 pdn=1 ip=4.7.254.211 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=13 qci=9 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=14 qci=9 pdn=1 ip=4.7.254.213 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=15 qci=9 pdn=1 ip=4.7.254.214 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=16 qci=9 pdn=1 ip=4.7.254.215 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=17 qci=9 pdn=1 ip=4.7.254.216 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
--- exec('set_bearer id=2 ue=18 qci=9 pdn=1 ip=4.7.254.217 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

------------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param use_hb=off')
--- exec('trace uec=1 protocol=rrc on')
--- exec('trace uec=1 protocol=nr_rrc on')
--- exec('trace uec=1 protocol=x2 on')
--- exec('sim_trace uec=1 protocol=nr_rrc on')
--- exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')
