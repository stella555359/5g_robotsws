---  Copyright (c) 2019 Nokia. All rights reserved.

------------------------------------------------------------------------------------------------------
--- VARIABLES
------------------------------------------------------------------------------------------------------
local CONTAINER_IP="localhost"
local SERVER_IP="10.0.2.1"
local DAEMON_PORT="22222"
local GNB1_NG_ADDR="10.0.1.2"
local GNB2_NG_ADDR="10.0.1.3"
local GNB2_XN_ADDR="10.0.1.4"
local GNB3_NG_ADDR="10.0.1.5"
local GNB3_XN_ADDR="10.0.1.6"
local GNB4_NG_ADDR="10.0.1.7"
local GNB4_XN_ADDR="10.0.1.8"
local PROXY_SERVER_IP="10.0.2.80"
local PROXY2_SERVER_IP="10.0.2.90"
local PROXY21_SERVER_IP="10.0.2.91"
local PROXY3_SERVER_IP="10.0.2.100"
local PROXY4_SERVER_IP="10.0.2.110"
local PROXY5_SERVER_IP="10.0.2.120"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="1.2.4.1"
local EDAEMON_PORT="10000"

local SA_UE_CAPABILITIES="E9A09000575F5A13160003C52000160BF170019C2EB42C013641873E618F28581C13018062380DDC6C4CC0D608C21A081078844006D6C98AB1A1CF88E3D033EC09F1891C790E7D473E618F28581C0E1E0BFFFFF800FFFFFE000D80000703A0D85155AC1184341020F108800CAD931562439F604F88E3C62471E439F51CF9863CA1607038784FEC7FE003FB1FF8003600001C0EA3626D56B04610D04083C4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05FFFFFC007FFFFF0006C0000381D06C46AAD608C21A08107884400656C98AB121CF88E3D813E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000001B00000E0771B00B03582308682041E211001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFF800003FFE000003600001C0A83620EB04610D00083C4220032B64C55890E7D813E238F0091C790E7D473E618F28581C0E1E13FB000000FEC000000D80000702A8D837AC1184341020F108800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C17FFC00001FFF000001B00000E006AC3C4C000E140000000B02B17130003850001C4D000004160563E26000706C00388C001C4D00000E160561E26000713000000858158B898001C4D000E140000040B02B0F0A00038500000242C0AC5C4D000E26800711800005058158789A001C4D000018160401E23000710400001AC5C46000E20800710400002858158F804001C1B000E23000710400005858158788C001C4600000C160561E0D800713400004058100D011A026404D8051006E00140411B4002941B0A244D8E7C38912244D8E7C38D0204081B1CF810A040D8E7C08902040D8E7C0850206C73E044810206C73E0428103639F0214489B1CF871224489B1CF871A0408103639F0214081B1CF810A040D8E7C00054346318C6318C6318C607EAAAAA83E000F000A070500703009401C0018090010180F82800800000004000008020000080100000200800002004000018020000100100000A008004010040100000C0080000700400200000008000080040000480200000C010000140080000B004002048120080000C00400201004000008020080203B953591B594358195833582B594B5933580B581B58095811583B5953582940D04000025949410000196525040000A594901000039652404000125949010000596524040001A594901000079652404000225949010000996524040002A5949010000B96525040003259490100003165240374AAAE91D55288BA55154162A82C55068AA531549A2A80C55028AA4D5541E2A95450F002F012A05028140A05028140A05028140A05028140A05028006040400801010020042020040080801002201002004040080101002004202044058080D014201002004040080101002004402044058080D014020340504040880B0102202C602004008081101602044058080100210102202C0400801080801002020040088040080101002004040880B18080D0140204405808110160203405040400801010020046A87C0004080C10181C282C30344044484C5060646C70747C8494989CA0A4A8B4BD05955555554E0B40"

--- Variables for NSA configuration

local ENB1_S1_ADDR="10.0.1.136"
local GNB1_S1U_ADDR="10.0.1.112"
local GNB2_S1U_ADDR="10.0.1.113"

local ENB1_X2_ADDR="10.0.1.137"
local GNB1_X2_ADDR="10.0.1.2"
local GNB2_X2_ADDR="10.0.1.4"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"

local ENB_X2U_ADDR="10.0.1.135"

local PGW_ADDR="4.7.254.1"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local NSA_UE_CAPABILITIES="E1201000014F5E0302C0020A400024106CE261F0A16009B0083FF30C7942C0E0980C0311406014C203141F11B586368E9315047F2CA4D94220020B64C1203063C63FF30C7942C0E070F0113804E0771B00B03582308682041E211001B5B062B1A1CF88E3D033EC09F1891C790E7D473E618F28581C7E1E02FFF800003FFE000003600001C0A83620EB04610D04083C422002CB24C55890E7D813E238F0091C790E7D473E618F40E1F3FB000000FEC000000D80000702A89837AC11843410001108800C2D931544439F11C788E3D033EC09F18E7CC31E50B0381C3C1FFF000007FFC000006C0000381DC6C4CC0D608C01A0800011001B5B262AC6873E238F40CFB027C62471E439F51CF9863CA1607038782FFFFFE003FFFFF8003600001C0E82614556B04610D04083C4220032B64C55890E7D813E238F1891C790E7D473E618F28581C0E1E0FEC7FE003FB1FF8003600001C0EA3626D56B04610D04083C4220030B64C55110E7C471E238F40CFB027C639F30C7942C0E070F05FFFFFC007FFFFF0006C000038001C20C0468005010600DC04C805101379343E02C8200000148200000548200000949280000D392400002292400002A01781B7953781B5BAC646D650D01C1000009652504000065949410000296525040000E594941000049652524000154B292920000CA594941000079652501F40F2E9565D03ABA55934AB22BB9148F2A94650F000F0034020100000010"
local EUTRAN_CAPABILITIES="A10186102C0C0388C000000888160641C460000024440B0320E0D800002222058190706C0000191102C0C03804000010888160641C0200000A4440B0300E1400000622205819070A00000391102C0C03898000020888160641C4C0000124440B0300E2680000A22205819071340000591006007011A00DC00280510132026900B080004020200C01840004010100600C200010080803006100010040401803080004020200C01840004010100600C2000100808020041000100404010020800040202008010400040101004008200010080802004100010040401002"


os.execute('sudo ifconfig eth4:gNB2_PR add '..PROXY2_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB21_PR add '..PROXY21_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB3_PR add '..PROXY3_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB4_PR add '..PROXY4_SERVER_IP)
os.execute('sudo ifconfig eth4:gNB4_PR2 add '..PROXY5_SERVER_IP)
os.execute('sudo ifconfig eth3:gNB2_NG add '..GNB2_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB2_XN add '..GNB2_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB3_NG add '..GNB3_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB3_XN add '..GNB3_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB4_NG add '..GNB4_NG_ADDR)
os.execute('sudo ifconfig eth3:gNB4_XN add '..GNB4_XN_ADDR)
os.execute('sudo ifconfig eth3:gNB1_S1U add '..GNB1_S1U_ADDR)


------------------------------------------------------------------------------------------------------
--- 5GCN CONFIGURATION
------------------------------------------------------------------------------------------------------

exec('set_amf_region id=1 tac_list=7627107,222,100,0,1 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+aes+snow3g+zuc nea=null+aes+snow3g+zuc ims_voice_3gpp=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..' ngu='..AMF_NG_ADDR..'')

------------------------------------------------------------------------------------------------------
--- GNB2 MN real CONFIGURATION
------------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB1_S1U_ADDR..' x2='..GNB1_X2_ADDR..':36422 ng='..GNB1_NG_ADDR..' xn='..GNB1_NG_ADDR..' gnb_id=0x02:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0x000001')
exec('set_cell id=1 gnb=2 pci=16:2 tac=1 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=640000:640000 mandatory_for_activation=off gscn=7916')
exec('set_cell id=2 gnb=2 pci=17:0 tac=1 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=640010:640010 mandatory_for_activation=off gscn=7916')
exec('set_cell id=3 gnb=2 pci=18:0 tac=1 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=167300:177500 mandatory_for_activation=off gscn=2218')
exec('set_cell id=4 gnb=2 pci=18:1 tac=1 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=167200:175560 mandatory_for_activation=off gscn=2193')

---------------------------------------------------------------------------------------------------
--- GNB3 SN sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=3 type=simulated plmn=311:489 ng='..GNB2_NG_ADDR..' gnb_id=0x03:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB2_XN_ADDR..' nssai=0x1:0x000001 amf=1')
exec('set_cell id=3 gnb=3 pci=17:1 tac=1 nrci=0x03 tdd_cell=on proxy='..PROXY2_SERVER_IP..':'..EDAEMON_PORT..' gscn=22446 nr_arfcn=2071591:2071591 nr_scs=120kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=2071387 ssb_subcarrier_spacing=kHz120 ssb_mtc_periodicity_and_offset=sf10:0 ssb_mtc_duration=sf4 suggested_band=261')
exec('set_cell id=4 gnb=3 pci=17:2 tac=1 nrci=0x04 tdd_cell=on proxy='..PROXY21_SERVER_IP..':'..EDAEMON_PORT..' gscn=22446 nr_arfcn=2071593:2071593 nr_scs=120kHz bs_channel_bandwidth=100MHz meas_timing_carrier_freq=2071387 ssb_subcarrier_spacing=kHz120 ssb_mtc_periodicity_and_offset=sf10:0 ssb_mtc_duration=sf4 suggested_band=257')
exec('gnb_param id=3 xn_listening_socket=on send_xn_setup=off sib1_period=10s measEvent=A2 measEvent=A3 sa_ho=xn_based')
exec('enb_cell_param id=3 enb=3 allow_endc=off')

---------------------------------------------------------------------------------------------------
--- GNB4 MN sim configuration
---------------------------------------------------------------------------------------------------
exec('set_gnb id=4 type=simulated plmn=311:489 ng='..GNB3_NG_ADDR..' gnb_id=0x76D daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB3_XN_ADDR..' nssai=0x1:0x000001 amf=1')
exec('set_cell id=1 gnb=4 pci=15:1 tac=0 nrci=0x01 tdd_cell=on proxy='..PROXY3_SERVER_IP..':'..EDAEMON_PORT..' gscn=7916 nr_arfcn=640000:640000 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('set_cell id=2 gnb=4 pci=15:2 tac=0 nrci=0x02 tdd_cell=on proxy='..PROXY5_SERVER_IP..':'..EDAEMON_PORT..' gscn=7916 nr_arfcn=636666:636666 nr_scs=30kHz bs_channel_bandwidth=100MHz')
exec('gnb_param id=4 xn_listening_socket=on send_xn_setup=off sib1_period=10s')

---------------------------------------------------------------------------------------------------
--- ENB1 sim configuration with fake enb cell
---------------------------------------------------------------------------------------------------
exec('set_gnb id=1 type=simulated plmn=311:489 ng='..GNB4_NG_ADDR..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' gnb_id=0x76E x2_peers=none xn='..GNB4_XN_ADDR..' nssai=0x1:0x000001 amf=1')
exec('set_cell id=1 gnb=1 pci=3:2 tac=222 nrci=0x01 tdd_cell=on proxy='..PROXY4_SERVER_IP..':'..EDAEMON_PORT..' earfcn=2000:20000 bw=20MHz technology=lte mandatory_for_activation=off')
exec('gnb_param id=1 xn_listening_socket=on send_xn_setup=off')

------------------------------------------------------------------------------------------------------
--- UEC CONFIGURATION
------------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26')

------------------------------------------------------------------------------------------------------
--- UE CONFIGURATION
------------------------------------------------------------------------------------------------------

--- supports n5,n26,n77,n261 and n5(2A)-n77-n261 BC,   5 OK, 77 NOK
exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645416 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=E7A05000574F7E03560803C4A0002C10010180910600098385C00C4834000A040260300C45018053380B546C4CD608C21A08107483C00A2D954542439F40CFB027C639F30C7942C0E070F017001DF001C0077C001820006CA0000A00000283E026B04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F0000001FC000000A83E0CEB04610D04083C41E00496CAA2A0A1CFA067C639F30C7942C0E070F027F6000001FD800000181000182A81681EF1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180E81682606F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8FC7188000180A816806F1C610E00151E7E2878011FB660AA40078F0021C4106115028FDFC81B8DC61880001800318F808001C4C000E8200070100000002217010003898001D031860020805C28000E20800740C618010048009013201441038208328002F01C4893A7E0649F1624E9D3F0324F8B1274E9F81927C500D034020400A01E837001F00140018080A00E0601280380030101088008216021000800193C0400400000492800004B000002008020000000240000201807006C0CADD2328637CA0182000012CA4A080000CB292800080200800000401281D5576A1142010C04008010100600C04010020100200440200400808010020200C01880C020048040080600400C008010300600E014018940380018D8212A0810021720100650')

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
