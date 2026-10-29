# Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF1_ADDR="1.2.4.1"
UPF2_ADDR="1.2.5.1"
UPF1_N3_IPV4="10.0.1.10"
UPF2_N3_IPV4="10.0.1.11"
DNN="internet"
DEV_TUN_NAME="tunUPF"
DEV_TUN2_NAME="tun2UPF"

GNB1_XN_ADDR="10.0.1.2"
GNB2_NG_ADDR="10.0.1.3"
GNB2_XN_ADDR="10.0.1.4"
GNB3_NG_ADDR="10.0.1.30"
GNB3_XN_ADDR="10.0.1.40"

AMF2_NG_ADDR="10.0.1.5"
AMF3_NG_ADDR="10.0.1.6"
EDAEMON_PORT="22222"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.121"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"   
PDN_IP="4.7.254.208"
PDN_IP_2="4.7.254.209"
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')	
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=200,201,202,203 plmn=311:489,311:490,311:491,311:492,311:493,311:494')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=1 pointer=1')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..UPF1_N3_IPV4..' dnn='..DNN..' devname='..DEV_TUN_NAME..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')
exec('set_upf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/24 ngu='..UPF2_N3_IPV4..' dnn='..DNN..' devname='..DEV_TUN2_NAME..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

exec('smf_upf_mapping id=1 upf=1')
exec('smf_upf_mapping id=1 upf=2')

-----------------------------------------------------------------------------------------------------
--SIMULATED GNB - RANSIM
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=5 type=simulated plmn=311:489 xn='..GNB2_XN_ADDR..' ng='..GNB2_NG_ADDR..' gnb_id=0x5:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489,311:490,311:491,311:492,311:493,311:494 nssai=0x1:0xd143a5')
exec('gnb_param id=5 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based')
exec('set_cell id=1 gnb=5 pci=18:0 tac=200 nrci=0x05 tdd_cell=on proxy='..GNB2_XN_ADDR..':9999 nr_arfcn=636666:636666 gscn=7880')

-----------------------------------------------------------------------------------------------------
--SIMULATED GNB - RANSIM2
-----------------------------------------------------------------------------------------------------
exec('set_gnb id=6 type=simulated plmn=311:489 xn='..GNB3_XN_ADDR..' ng='..GNB3_NG_ADDR..' gnb_id=0x6:22 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489,311:490,311:491,311:492,311:493,311:494 nssai=0x1:0xd143a5')
exec('gnb_param id=6 xn_listening_socket=1 send_xn_setup=false measEvent=A3 sa_ho=xn_based')
exec('set_cell id=1 gnb=6 pci=18:1 tac=200 nrci=0x05 tdd_cell=on proxy='..GNB3_XN_ADDR..':9999 nr_arfcn=636666:636666 gscn=7880')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x1:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none xn='..GNB1_XN_ADDR..' amf=1 plmnList=311:489,311:490,311:491,311:492,311:493,311:494 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=650000:650000 gscn=8020 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=650000:650000 gscn=8020 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=on mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------


--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_1 = 1
END_UD_SA_CELL_1 = 20
FIRST_UE_NSA_CELL_1 = 21
END_UE_NSA_CELL_1 = 30

IMSI_1 = 21645400
IMSI_2 = 21645500
QOS_ID = 2

--UE1,2,3 for multi-PLMN
UEID1 = 1
UEID2 = 2
UEID3 = 3
UEID4 = 4
UEID5 = 5
UEID6 = 6
gw_id1 = 1
gw_id2 = 2
gw_id3 = 3
gw_id4 = 4
gw_id5 = 5
gw_id6 = 6

--UE1, PLMN1
exec('set_ue simulated id='..UEID1..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID1 - 1)
exec('ue_param id='..UEID1..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')

--UE2, PLMN2
exec('set_ue simulated id='..UEID2..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:490:0000:0:0:0'.. IMSI_1 + UEID2 - 1)
exec('ue_param id='..UEID2..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')

--UE3, PLMN3
exec('set_ue simulated id='..UEID3..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:491:0000:0:0:0'.. IMSI_1 + UEID3 - 1)
exec('ue_param id='..UEID3..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')


--UE4, PLMN4
exec('set_ue simulated id='..UEID4..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:492:0000:0:0:0'.. IMSI_1 + UEID4 - 1)
exec('ue_param id='..UEID4..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')

--UE5, PLMN5
exec('set_ue simulated id='..UEID5..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:493:0000:0:0:0'.. IMSI_1 + UEID5 - 1)
exec('ue_param id='..UEID5..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')

--UE6, PLMN6
exec('set_ue simulated id='..UEID6..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:494:0000:0:0:0'.. IMSI_1 + UEID6 - 1)
exec('ue_param id='..UEID6..' ue_nr_capabilities=E1A00000074E5A031E0003832001E09306400043C2400C4034026010180E01D51B0A3582028681965944C2C01EB608080838778E1C830E0008193C7D5C007FC007001FF00050800EDC000200000001C0002000000000AA36266B04050D032CB2898580416C96A8061CFBC73E638F68D43C9E3E02B800FF800E003FE000A1001DB800040000000380004000000001546C4DD6080A1A065965130B007AD8202020E1DE38720C38002064F1F57001FF001C007FC00142003B7000080000000700008000000002A8D89DAC1014340CB2CA261600F5B0404041C3BC70E418700040C9E3EAA00000A000002840076E000100000000E000100000000000841C4D000000002026888001C020227B09801C00140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542400E001600000008010023562600020406080A0C0E10162022242632424A4C4E50948350')

exec('set_pdu_gateway id='..gw_id1..' ue_nat_ip=72.23.'..UEID1..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id='..gw_id2..' ue_nat_ip=72.23.'..UEID2..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id='..gw_id3..' ue_nat_ip=72.23.'..UEID3..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

exec('set_pdu_gateway id='..gw_id4..' ue_nat_ip=72.23.'..UEID4..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id='..gw_id5..' ue_nat_ip=72.23.'..UEID5..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
exec('set_pdu_gateway id='..gw_id6..' ue_nat_ip=72.23.'..UEID6..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)

for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389800000008723A110003030040C081C389800000408723A11000203060C0081C38980000080872320D8000203240C5C4C0000064641A00060640818B8980000108C83400080C9831071300000291D06800101830700E26000006023F2320D800020304061C4C00000E4641A0006060080C38980000208C826000080038980000248E8160041C4C00001404391D08C0C01030206040E1C4C00000004391D0880C18300206040E1C4C00000204391D06C0C010182060E26000007021C8E83406080C18300713000005810E46413032040E1C4C0000184641203260E01C4C00001A460160260000060180384C0B7AFA23200216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C60216C73E1C4085B1CF870885B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8710216C73E1C4085B1CF8605422000000000000000000244400000024440000003444000000000180D200004040001000000400000200008010024000080000020200008000004000100200480001000000400000101000080002004008C00020200018000006000100200460001000000C0400030000801002300008000006000001808040080118000400000100000080402004008C00020200008000002000100200460001000000404000100008010022000080800020001002004200030100801002300008000002000000808040080110000C040002000080100220001800000402010020040')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)      
end 

--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
--enable extended slice support
exec('sim_param_set EXTENDED_NWSLICE_TEST_MODE=on')

--configure 2000 slices on AMF for 6 PLMNs
exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x01:0xD143A5 amf=1 plmn_list=311:489 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x02:0xD143A5 amf=1 plmn_list=311:489 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x03:0xD143A5 amf=1 plmn_list=311:489 slice_support_list=false')
exec('addl_nwslice_set number_of_slices=450 starting_snssai=0x04:0xD143A5 amf=1 plmn_list=311:489 slice_support_list=false')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD14567 amf=1 plmn_list=311:490 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD14571 amf=1 plmn_list=311:491 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD1457B amf=1 plmn_list=311:492 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD14585 amf=1 plmn_list=311:493 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD1458F amf=1 plmn_list=311:494 slice_support_list=true')

--configure 2000 slices on gNBSim gnb5 for 6 PLMNs
exec('gnb_make_plmnset dual_conn=off gnb=5 cell=1 plmn_set_id=1 tac=200 plmn_id_list=311:489,311:490,311:491,311:492,311:493,311:494')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:489 nssai=0x1:0xd143a5')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:490 nssai=0x1:0xd143a5')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:491 nssai=0x1:0xd143a5')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:492 nssai=0x1:0xd143a5')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:493 nssai=0x1:0xd143a5')
exec('gnb_set_nwslice_per_plmn gnb=5 cell=1 plmn_set_id=1 plmn=311:494 nssai=0x1:0xd143a5')

exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x01:0xD143A5 gnb=5 cell=1 gnb_plmn_list=311:489 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x01:0xD143A5 gnb=5 cell=1 gnb_plmn_list=311:490 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=500 starting_snssai=0x01:0xD143A5 gnb=5 cell=1 gnb_plmn_list=311:491 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=480 starting_snssai=0x01:0xD143A5 gnb=5 cell=1 gnb_plmn_list=311:492 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD14585 gnb=5 cell=1 gnb_plmn_list=311:493 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=10 starting_snssai=0x01:0xD1458F gnb=5 cell=1 gnb_plmn_list=311:494 slice_support_list=true')

--configure 2000 slices on gNBSim gnb6 for 1 PLMN
exec('addl_nwslice_set number_of_slices=1024 starting_snssai=0x01:0xD143A5 gnb=6 cell=1 gnb_plmn_list=311:489 slice_support_list=true')
exec('addl_nwslice_set number_of_slices=976 starting_snssai=0x01:0xD147A5 gnb=6 cell=1 gnb_plmn_list=311:489 slice_support_list=false')

exec('set_qosflow id=1 5qi=6 default=on')

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=7')
exec('set_qosflow id=5 5qi=8')
exec('set_qosflow id=6 5qi=9')
exec('set_qosflow id=7 5qi=2')
exec('set_qosflow id=8 5qi=3')
exec('set_qosflow id=9 5qi=4')
exec('set_qosflow id=10 5qi=71')
exec('set_qosflow id=11 5qi=72')
exec('set_qosflow id=12 5qi=76')
exec('set_qosflow id=13 5qi=128')
exec('set_qosflow id=14 5qi=170')
exec('set_qosflow id=15 5qi=212')
exec('set_qosflow id=16 5qi=254')

exec('nwslice_set id=1 qos_flows=1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 snssai=0x01:0xD143A5 default=on ue=all amf_region_id=1')
exec('nwslice_set id=2 snssai=0x01:0xD143A6 qos_flows=2 ue=1,2,3,4 amf=1')

exec('nwslice_set id=101 snssai=0x01:0xD14409 qos_flows=5 ue=1 amf=1')
exec('nwslice_set id=102 snssai=0x01:0xD1440A qos_flows=6 ue=1 amf=1')
exec('nwslice_set id=103 snssai=0x01:0xD1440B qos_flows=6 ue=1 amf=1')

exec('nwslice_set id=1951 snssai=0x01:0xD14567 qos_flows=6 ue=2 amf=1')
exec('nwslice_set id=1952 snssai=0x01:0xD14568 qos_flows=6 ue=2 amf=1')
exec('nwslice_set id=1953 snssai=0x01:0xD14569 qos_flows=6 ue=2 amf=1')

exec('nwslice_set id=1961 snssai=0x01:0xD14571 qos_flows=6 ue=3 amf=1')
exec('nwslice_set id=1962 snssai=0x01:0xD14572 qos_flows=6 ue=3 amf=1')
exec('nwslice_set id=1963 snssai=0x01:0xD14573 qos_flows=6 ue=3 amf=1')

exec('nwslice_set id=1971 snssai=0x01:0xD1457B qos_flows=6 ue=4 amf=1')
exec('nwslice_set id=1972 snssai=0x01:0xD1457C qos_flows=6 ue=4 amf=1')
exec('nwslice_set id=1973 snssai=0x01:0xD1457D qos_flows=6 ue=4 amf=1')

exec('nwslice_set id=1981 snssai=0x01:0xD14585 qos_flows=1 ue=5 amf=1')
exec('nwslice_set id=1982 snssai=0x01:0xD14586 qos_flows=2 ue=5 amf=1')

exec('nwslice_set id=1991 snssai=0x01:0xD1458F qos_flows=5 ue=6 amf=1')
exec('nwslice_set id=1992 snssai=0x01:0xD14590 qos_flows=6 ue=6 amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

exec('debug_log level=1')
exec('sim_debug_log level=0')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
exec('sim_debug_log enable_events_date=on')
exec('sim_debug_log enable_debug_date=on')


sleep(30)
exec('set_pdu_param ue=1 pdu=1 trf_type=internal')
exec('set_pdu_param ue=1 pdu=2 trf_type=internal')
exec('set_pdu_param ue=1 pdu=3 trf_type=internal')
exec('set_pdu_param ue=1 pdu=4 trf_type=internal')
exec('set_pdu_param ue=1 pdu=5 trf_type=internal')
exec('set_pdu_param ue=1 pdu=6 trf_type=internal')
exec('set_pdu_param ue=1 pdu=7 trf_type=internal')
exec('set_pdu_param ue=1 pdu=8 trf_type=internal')
sleep(1)
exec('set_pdu_param ue=2 pdu=1 trf_type=internal')
exec('set_pdu_param ue=2 pdu=2 trf_type=internal')
exec('set_pdu_param ue=2 pdu=3 trf_type=internal')
exec('set_pdu_param ue=2 pdu=4 trf_type=internal')
exec('set_pdu_param ue=2 pdu=5 trf_type=internal')
exec('set_pdu_param ue=2 pdu=6 trf_type=internal')
exec('set_pdu_param ue=2 pdu=7 trf_type=internal')
exec('set_pdu_param ue=2 pdu=8 trf_type=internal')
sleep(1)
exec('set_pdu_param ue=3 pdu=1 trf_type=internal')
exec('set_pdu_param ue=3 pdu=2 trf_type=internal')
exec('set_pdu_param ue=3 pdu=3 trf_type=internal')
exec('set_pdu_param ue=3 pdu=4 trf_type=internal')
exec('set_pdu_param ue=3 pdu=5 trf_type=internal')
exec('set_pdu_param ue=3 pdu=6 trf_type=internal')
exec('set_pdu_param ue=3 pdu=7 trf_type=internal')
exec('set_pdu_param ue=3 pdu=8 trf_type=internal')
sleep(1)
exec('set_pdu_param ue=4 pdu=1 trf_type=internal')
exec('set_pdu_param ue=4 pdu=2 trf_type=internal')
exec('set_pdu_param ue=4 pdu=3 trf_type=internal')
exec('set_pdu_param ue=4 pdu=4 trf_type=internal')
exec('set_pdu_param ue=4 pdu=5 trf_type=internal')
exec('set_pdu_param ue=4 pdu=6 trf_type=internal')
exec('set_pdu_param ue=4 pdu=7 trf_type=internal')
exec('set_pdu_param ue=4 pdu=8 trf_type=internal')
sleep(1)
exec('set_pdu_param ue=5 pdu=1 trf_type=internal')
exec('set_pdu_param ue=5 pdu=2 trf_type=internal')
exec('set_pdu_param ue=5 pdu=3 trf_type=internal')
exec('set_pdu_param ue=5 pdu=4 trf_type=internal')
exec('set_pdu_param ue=5 pdu=5 trf_type=internal')
exec('set_pdu_param ue=5 pdu=6 trf_type=internal')
exec('set_pdu_param ue=5 pdu=7 trf_type=internal')
exec('set_pdu_param ue=5 pdu=8 trf_type=internal')
sleep(1)
exec('set_pdu_param ue=6 pdu=1 trf_type=internal')
exec('set_pdu_param ue=6 pdu=2 trf_type=internal')
exec('set_pdu_param ue=6 pdu=3 trf_type=internal')
exec('set_pdu_param ue=6 pdu=4 trf_type=internal')
exec('set_pdu_param ue=6 pdu=5 trf_type=internal')
exec('set_pdu_param ue=6 pdu=6 trf_type=internal')
exec('set_pdu_param ue=6 pdu=7 trf_type=internal')
exec('set_pdu_param ue=6 pdu=8 trf_type=internal')





