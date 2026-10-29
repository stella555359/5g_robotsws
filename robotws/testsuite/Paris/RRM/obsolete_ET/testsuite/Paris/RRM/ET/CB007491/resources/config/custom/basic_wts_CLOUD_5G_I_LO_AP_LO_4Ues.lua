---# Copyright (c) 2019 Nokia. All rights reserved.

---#---------------------------------------------------------------------------------------------------
---#VARIABLES
---#---------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
DAEMON_IP="10.0.2.1"


DAEMON_PORT="22222"
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

SA_UE_CAPABILITIES_TDD="E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0"
SA_UE_CAPABILITIES_FDD="E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A010080000000000200400840"


---## Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.112"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP101="4.7.254.101"

NSA_UE_CAPABILITIES_TDD="E120700047D0FFB17DE8E6BC3A000D01A4E7CD2279F002400C403E03E0101F8005B79C00003DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C00803DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783379C06C03DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA1607038783779F13403DEF5B8683228107000003AE0D00516C96A81604F90E7D011E31CF9863CA160703878293FE4FF8B10006CA0000A000006F3802007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3803807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3809807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3812807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3813807BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3814007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F066F3826007BDEB70D0645020E0000075C1A00A2D92D502C09F21CFA023C639F30C7942C0E070F06FE0000005C007C005638280381F84800E07C003968000038000395340006000025949400F2AA685800E001E006A054000810181C4C040C2C4044486430606C7D0494989CA0915200"
NSA_UE_CAPABILITIES_FDD="E1201000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298400283E236B0C6D1D262A08FE5949B28340105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D03CBA559740EAE9564D2AC8AEE40B003C00D008040000004"
NR_EUTRA_CAPABILITIES_TDD="A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801"
NR_EUTRA_CAPABILITIES_FDD="A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180"


---#---------------------------------------------------------------------------------------------------
---#ENB CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---#---------------------------------------------------------------------------------------------------
---#GNB CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')

---#---------------------------------------------------------------------------------------------------
---#EPC CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

---#---------------------------------------------------------------------------------------------------
---#5GCN CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

---#add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

---#---------------------------------------------------------------------------------------------------
---#UEC CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')
---#---------------------------------------------------------------------------------------------------
---#UE CONFIGURATION
---#---------------------------------------------------------------------------------------------------

---#---------------------------------------------------------------------------------------------------
---#TDD_SA_UEID_Configuration
---#---------------------------------------------------------------------------------------------------
---#UE Id=1 SA cell 1
MAX_SA_UE = 4
SUCI_FIRST_UE = 21645400

exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:021645400')
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:021645401')
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:021645402')
exec('set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:021645403')
for ueId = 1, MAX_SA_UE
do
	exec('ue_param id='..ueId..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD)
end

---#UE Id=2 SA cell=1
---#UE Id=3 SA cell=1
---#UE Id=4 SA cell=1
---#UE Id=5 SA cell=1
---#UE Id=6 SA cell=1
---#UE Id=7 SA cell=1
---#UE Id=8 SA cell=1
---#UE Id=9 SA cell=1
---#UE Id=10 SA cell=1

---#UE Id=21 SA cell 2
---#UE Id=22 SA cell=2
---#UE Id=23 SA cell=2
---#UE Id=24 SA cell=2
---#UE Id=25 SA cell=2
---#UE Id=26 SA cell=2
---#UE Id=27 SA cell=2
---#UE Id=28 SA cell=2
---#UE Id=29 SA cell=2
---#UE Id=30 SA cell=2


---#---------------------------------------------------------------------------------------------------------
---#FDD_SA_UEID_Configuration
---#---------------------------------------------------------------------------------------------------------

---#UE Id=51 SA cell=3
---#UE Id=52 SA cell=3
---#UE Id=53 SA cell=3
---#UE Id=54 SA cell=3
---#UE Id=55 SA cell=3
---#UE Id=56 SA cell=3
---#UE Id=57 SA cell=3
---#UE Id=58 SA cell=3
---#UE Id=59 SA cell=3
---#UE Id=60 SA cell=3

---#UE Id=71 SA cell=4
---#UE Id=72 SA cell=4
---#UE Id=73 SA cell=4
---#UE Id=74 SA cell=4
---#UE Id=75 SA cell=4
---#UE Id=76 SA cell=4
---#UE Id=77 SA cell=4
---#UE Id=78 SA cell=4
---#UE Id=79 SA cell=4
---#UE Id=80 SA cell=4

---#---------------------------------------------------------------------------------------------------
---#TDD_NSA_UEID_Configuration
---#---------------------------------------------------------------------------------------------------

---#UE Id=101 NSA cell=1


---#UE Id=102 NSA cell=1
---#UE Id=103 NSA cell=1
---#UE Id=104 NSA cell=1
---#UE Id=105 NSA cell=1
---#UE Id=106 NSA cell=1
---#UE Id=107 NSA cell=1
---#UE Id=108 NSA cell=1
---#UE Id=109 NSA cell=1
---#UE Id=110 NSA cell=1

---#UE Id=121 NSA cell=2
---#UE Id=122 NSA cell=2
---#UE Id=123 NSA cell=2
---#UE Id=124 NSA cell=2
---#UE Id=125 NSA cell=2
---#UE Id=126 NSA cell=2
---#UE Id=127 NSA cell=2
---#UE Id=128 NSA cell=2
---#UE Id=129 NSA cell=2
---#UE Id=130 NSA cell=2

---#---------------------------------------------------------------------------------------------------
---#FDD_NSA_UEID_Configuration
---#---------------------------------------------------------------------------------------------------
---#UE Id=151 NSA cell=3
---#UE Id=152 NSA cell=3
---#UE Id=153 NSA cell=3
---#UE Id=154 NSA cell=3
---#UE Id=155 NSA cell=3
---#UE Id=156 NSA cell=3
---#UE Id=157 NSA cell=3
---#UE Id=158 NSA cell=3
---#UE Id=159 NSA cell=3
---#UE Id=160 NSA cell=3

---#UE Id=171 NSA cell=4
---#UE Id=172 NSA cell=4
---#UE Id=173 NSA cell=4
---#UE Id=174 NSA cell=4
---#UE Id=175 NSA cell=4
---#UE Id=176 NSA cell=4
---#UE Id=177 NSA cell=4
---#UE Id=178 NSA cell=4
---#UE Id=179 NSA cell=4
---#UE Id=180 NSA cell=4

---#---------------------------------------------------------------------------------------------------
---#COMMON CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')

---#add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')

for ueId = 1, MAX_SA_UE
do
	exec('set_pdu_gateway id='..ueId..' ue_nat_ip=72.23.0.'..ueId..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end




---#---------------------------------------------------------------------------------------------------
---#OTHER CONFIGURATION
---#---------------------------------------------------------------------------------------------------


exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

---#---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('trace uec=1 protocol=rrc,nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')
