-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
DAEMON_IP="10.0.2.1"
SERVER_IP=DAEMON_IP
DAEMON_PORT=22222
DAEMON_IP2="10.0.2.11"
DAEMON_IP3="10.0.2.4"

--Real-gNB--
GNB1_S1U_ADDR="10.0.1.111"
GNB1_X2_1ADDR="10.0.1.111"
GNB1_Xn_1ADDR="10.0.1.55"
--Diff IPs for Ngc & Ngu planes--
GNB1_NGC1_ADDR="10.0.1.67"
GNB1_NGU1_ADDR="10.0.1.161"

--Sim-gNBs--
GNB2_S1U_ADDR="10.0.1.114"
GNB2_X2_ADDR="10.0.1.115"
GNB2_Xn_ADDR="10.0.1.126"
GNB2_NGC_ADDR="10.0.1.107"
GNB2_NGU_ADDR="10.0.1.160"

GNB3_S1U_ADDR="10.0.1.116"
GNB3_X2_ADDR="10.0.1.117"
GNB3_Xn_ADDR="10.0.1.127"
GNB3_NGC_ADDR="10.0.1.108"
GNB3_NGU_ADDR="10.0.1.167"

--Real-eNB--
ENB1_S1_ADDR="10.0.1.2"

--Sim-eNBs--
ENBSIM1_S1_ADDR="10.0.1.101"
ENBSIM1_X2_ADDR="10.0.1.101"
ENBSIM1_X2U_ADDR="10.0.1.101"

--Core IPs--
MME1_S1_ADDR="10.0.1.1"

NGU1_ADDR="10.0.1.75"

AMF1_NG_ADDR="10.0.1.61"

PGW_ADDR="4.7.254.207"
PROXY_SERVER_IP="10.0.2.80"
PDN_IP1="4.7.254.208"
PDN_IP2="4.7.254.209"
PDN_IP3="4.7.254.210"
PDN_IP4="4.7.254.211"

UEC_ADDR="72.22.0.1"
UPF1_ADDR="1.2.3.1"

for QCI = 128, 148 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=8103,100,788,200,0 plmn=234:77')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..NGU1_ADDR..' devname=tunUPF ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')

exec('smf_upf_mapping id=1 upf=1')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb type=external id=1 plmn=234:77 s1='..ENB1_S1_ADDR..' enb_id_macro=0x00001 daemon=127.0.0.1:22222')

exec('set_cell id=11 technology=lte enb=1 pci=3:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010b shared_plmn=234:77 is_cus_cell=on cus_addr=10.0.2.2:10011')
---------------------------------------------------------------------------------------------------
--SIM ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('set_enb id=16 plmn=234:77 s1='..ENBSIM1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENBSIM1_X2_ADDR..' x2u='..ENBSIM1_X2U_ADDR..' type=simulated x2_peers=2 mme=1' )
--exec('enb_param id=16 drb_id_begin=3 endc_capable_qci=9,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148')
--exec('set_cell id=11 enb=16 eci=0x1234601  pci=4:2 tac=124 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
--exec('enb_endc_param id=16 control_flow_period=3gpp1 use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
exec('proxy_log GEN=debug')
exec('proxy_log DLER=debug')
exec('proxy_log SCH=debug')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
--WITH DIFF IPs FOR NGU & NGC
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=234:77 s1u='..GNB1_S1U_ADDR..' x2='..GNB1_X2_1ADDR..' x2u='..GNB1_X2_1ADDR..' xn='..GNB1_Xn_1ADDR..' xnu='..GNB1_Xn_1ADDR..' ng='..GNB1_NGC1_ADDR..' ngu='..GNB1_NGU1_ADDR..' gnb_id=0x1 x2_peers=none amf=1 plmnList=234:77 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=16:2 tac=8103 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF mandatory_for_activation=off tdd_cell=on')

---------------------------------------------------------------------------------------------------
--SIM GNB CONFIGURATION --X2 NSA
---------------------------------------------------------------------------------------------------
exec('set_gnb id=4 type=simulated plmn=234:77 daemon='..DAEMON_IP2..':'..DAEMON_PORT..' s1u='..GNB2_S1U_ADDR..' x2='..GNB2_X2_ADDR..' x2u='..GNB2_X2_ADDR..' gnb_id=0x4 x2_peers=none')
exec('gnb_param id=4 xn_listening_socket=on send_xn_setup=off sib1_period=10s measEvent=A3')
exec('gnb_endc_param id=4 use_nr_ran_cont=on t_reordering=160 scg_dl_dist_percent=100 ul_data_path=nr:0')
exec('set_cell id=1 gnb=4 nr_arfcn=636666:636666 pci=17:0 tac=8103 proxy=10.0.1.118:2152 nrci=0x1 mandatory_for_activation=off tdd_cell=on gscn=7880')

---------------------------------------------------------------------------------------------------
--SIM GNB CONFIGURATION --Xn SA
---------------------------------------------------------------------------------------------------
exec('set_gnb id=22 type=simulated plmn=234:77 daemon='..DAEMON_IP2..':'..DAEMON_PORT..' xn='..GNB2_Xn_ADDR..' xnu='..GNB2_Xn_ADDR..' gnb_id=0x16 ng='..GNB2_NGC_ADDR..' ngu='..GNB2_NGU_ADDR..' amf=1 plmnList=234:77 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8 x2_peers=none')
exec('gnb_param id=22 xn_listening_socket=on send_xn_setup=on')
exec('set_cell id=1 gnb=22 nr_arfcn=636666:636666 pci=19:0 tac=8103 proxy='..DAEMON_IP2..':9999|'..DAEMON_IP2..':8888 nrci=0x1 mandatory_for_activation=off tdd_cell=on gscn=7880')

exec('set_gnb id=23 type=simulated plmn=234:77 daemon='..DAEMON_IP3..':'..DAEMON_PORT..' xn='..GNB3_Xn_ADDR..' xnu='..GNB3_Xn_ADDR..' ng='..GNB3_NGC_ADDR..' ngu='..GNB3_NGU_ADDR..' gnb_id=0x17 amf=1 plmnList=234:77 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8 x2_peers=none')
exec('gnb_param id=23 xn_listening_socket=on send_xn_setup=on')
exec('set_cell id=1 gnb=23 nr_arfcn=636666:636666 pci=19:1 tac=8103 proxy='..DAEMON_IP3..':9999|'..DAEMON_IP3..':8888 nrci=0x2 mandatory_for_activation=off tdd_cell=on gscn=7880')
-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=234:77 tac_list=555,234,222,444,333,124')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1 #mmegi=1 mmec=3 plmn=234:77')

SGWID = 1
for U_ADDR = 133, 152 do
    exec('set_sgw id='..SGWID..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u=10.0.1.'..U_ADDR..' s11=10.0.1.'..U_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
    SGWID = SGWID + 1
end

exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec file=AirPhoneConfig.xml  id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.10:40000 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.1/26 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
MAX_NUM_UES = 100
IMSI_FIRST_UE=111111001
IMSI_FIRST_UE_SA=21645400
FIRST_UE_SA = 51
END_UE_SA = 100
QCI = 128
QCI2 = 129
QCI3 = 130
QOS_ID = 2
for UEID = 1, 20 do
    exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096140211807135E0000018800000080 ue_nr_capabilities=E120700047D0FFB17DE8E6BC32001A0349CF9A44F3E0048018807C07C0203F08006F3826807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0C0200413400FF00000026007C005638280381F84800E07C003968000038000395340006000010600000F2A8284801C003C00D40A80010203038980858808890C860C0D8FA09293139414922A400 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010')
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1')
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
        QCI = QCI + 1
        if (QCI2 < 147) then
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1
        end
        if (QCI3 < 145) then
        QCI3 = QCI3 + 1
        else QCI3 = QCI3 - 2
        end
end
QCI = 128
QCI2 = 129
QCI3 = 130

for UEID = 21, 40 do
    exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=5DA00200A4000801001850AA5F80000001202004078500000E908020800014401C369A0600FA000AE00000 ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1')
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
        QCI = QCI + 1
        if (QCI2 < 147) then
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1
        end
        if (QCI3 < 145) then
        QCI3 = QCI3 + 1
        else QCI3 = QCI3 - 2
        end
end

QCI = 128
QCI2 = 129
QCI3 = 130

for UEID = 41, 50 do
    exec('set_ue id='..UEID..' rohc=16 sec_key=0102030405060708090A0B0C0D011001 enb=1 cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A2E31D0100000208000420000860001100002280004600008E0001200002480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B40003F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000504000003CE800000000000000000000000000000000000000000000000000000000000808E21090002A8001802297000020000104B1A0108C03808F0000006000000242000800210 ue_nr_capabilities=e1201000014f5e0302c00201404820d9c4c3e140426c020ffcc31e50b03826010188a01014c200141f11b586368e9315047f2ca4d940220b64c1203063c63ff30c7942c0e070f0113804e0001083011b9343e01c8200000148200000548200000949280000d300f81b7953781b5bac0141000009652504000065949410000296525040000e594941000049652524000154b29280ba07974ab2e81e4d2ac9a55915dc8020f00340201000000100 ue_eutra_nr_capabilities=0108040460201C04000E23000701C001820000000080001008080100202004008080100200010080')
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=internal')
    exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')
    exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1')
    exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
        QCI = QCI + 1
        if (QCI2 < 147) then
        QCI2 = QCI2 + 1
        else QCI2 = QCI2 - 1
        end
        if (QCI3 < 145) then
        QCI3 = QCI3 + 1
        else QCI3 = QCI3 - 2
        end
end

for UEID = FIRST_UE_SA, 70 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:234:77:0000:0:0:00'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')
end
--[[
for UEID = 71, END_UE_SA  do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:234:77:0000:0:0:00'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFAEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3800517046FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F8040400E2300000000101181406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F002C9000000800606D0001000009652500140EE8082C003C9380000000100200420')
end
--]]
for UEID = FIRST_UE_SA, END_UE_SA  do
    exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
for QI = 128, 147 do
    exec('set_qosflow id='..QOS_ID..' 5qi='..QI..' default=off')
    QOS_ID = QOS_ID + 1
end

--SA Single DRB configuration--
---[[
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')
exec('set_nwslice id=2 snssai=0x80:0xd143a6 amf=1 default=off ue=52')
exec('set_nwslice id=3 snssai=0x81:0xd143a7 amf=1 default=off ue=53')
exec('set_nwslice id=4 snssai=0x82:0xd143a8 amf=1 default=off ue=54')
exec('set_nwslice id=5 snssai=0x83:0xd143a9 amf=1 default=off ue=55')
exec('set_nwslice id=6 snssai=0x84:0xd143aa amf=1 default=off ue=56')
exec('set_nwslice id=7 snssai=0x85:0xd143ab amf=1 default=off ue=57')
exec('set_nwslice id=8 snssai=0x86:0xd143ac amf=1 default=off ue=58')
exec('set_nwslice id=9 snssai=0x87:0xd143ad amf=1 default=off ue=59')
exec('set_nwslice id=10 snssai=0x88:0xd143ae amf=1 default=off ue=60')
exec('set_nwslice id=11 snssai=0x89:0xd143af amf=1 default=off ue=61')
exec('set_nwslice id=12 snssai=0x8a:0xd143b0 amf=1 default=off ue=62')
exec('set_nwslice id=13 snssai=0x8b:0xd143b1 amf=1 default=off ue=63')
exec('set_nwslice id=14 snssai=0x8c:0xd143b2 amf=1 default=off ue=64')
exec('set_nwslice id=15 snssai=0x8d:0xd143b3 amf=1 default=off ue=65')
exec('set_nwslice id=16 snssai=0x8e:0xd143b4 amf=1 default=off ue=66')
exec('set_nwslice id=17 snssai=0x8f:0xd143b5 amf=1 default=off ue=67')
exec('set_nwslice id=18 snssai=0x90:0xd143b6 amf=1 default=off ue=68')
exec('set_nwslice id=19 snssai=0x91:0xd143b7 amf=1 default=off ue=69')
exec('set_nwslice id=20 snssai=0x92:0xd143b8 amf=1 default=off ue=70')
---]]

--SA Multi DRB configuration--
--[[
exec('set_nwslice id=1 qos_flows=1,2 snssai=0x01:0xd143a5 amf=1 default=on ue=51')
exec('set_nwslice id=2 qos_flows=1,3 snssai=0x80:0xd143a6 amf=1 default=on ue=52')
exec('set_nwslice id=3 qos_flows=1,4 snssai=0x81:0xd143a7 amf=1 default=on ue=53')
exec('set_nwslice id=4 qos_flows=1,5 snssai=0x82:0xd143a8 amf=1 default=on ue=54')
exec('set_nwslice id=5 qos_flows=1,6 snssai=0x83:0xd143a9 amf=1 default=on ue=55')
exec('set_nwslice id=6 qos_flows=1,7 snssai=0x84:0xd143aa amf=1 default=on ue=56')
exec('set_nwslice id=7 qos_flows=1,8 snssai=0x85:0xd143ab amf=1 default=on ue=57')
exec('set_nwslice id=8 qos_flows=1,9 snssai=0x86:0xd143ac amf=1 default=on ue=58')
exec('set_nwslice id=9 qos_flows=1,10 snssai=0x87:0xd143ad amf=1 default=on ue=59')
exec('set_nwslice id=10 qos_flows=1,11 snssai=0x88:0xd143ae amf=1 default=on ue=60')
exec('set_nwslice id=11 qos_flows=1,12 snssai=0x89:0xd143af amf=1 default=on ue=61')
exec('set_nwslice id=12 qos_flows=1,13 snssai=0x8a:0xd143b0 amf=1 default=on ue=62')
exec('set_nwslice id=13 qos_flows=1,14 snssai=0x8b:0xd143b1 amf=1 default=on ue=63')
exec('set_nwslice id=14 qos_flows=1,15 snssai=0x8c:0xd143b2 amf=1 default=on ue=64')
exec('set_nwslice id=15 qos_flows=1,16 snssai=0x8d:0xd143b3 amf=1 default=on ue=65')
exec('set_nwslice id=16 qos_flows=1,17 snssai=0x8e:0xd143b4 amf=1 default=on ue=66')
exec('set_nwslice id=17 qos_flows=1,18 snssai=0x8f:0xd143b5 amf=1 default=on ue=67')
exec('set_nwslice id=18 qos_flows=1,19 snssai=0x90:0xd143b6 amf=1 default=on ue=68')
exec('set_nwslice id=19 qos_flows=1,20 snssai=0x91:0xd143b7 amf=1 default=on ue=69')
exec('set_nwslice id=20 qos_flows=1,21 snssai=0x92:0xd143b8 amf=1 default=on ue=70')
--]]
exec('set_cnode ip=10.63.68.198:7676')
exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('debug_log level=6 uec=1')
exec('sim_debug_log level=6 pgw=1 enb=4')
exec('sim_trace uec=1 protocol=nr_rrc,rrc on')
exec('set_log log_to_file=true max_file_num=1')
--exec('trace uec=1 protocol=rrc on')
--exec('trace uec=1 protocol=nr_rrc on')
--exec('trace uec=1 protocol=x2 on')
exec('start version_check=off')
--exec('trace protocol=s1 on mme=1')
exec('sim_debug_log level=6 uec=1')
