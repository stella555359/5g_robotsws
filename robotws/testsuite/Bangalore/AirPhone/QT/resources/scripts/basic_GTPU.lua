-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
DAEMON_IP="10.0.2.1"
SERVER_IP=DAEMON_IP
DAEMON_PORT=22222
DAEMON_IP2="10.0.2.11"
DAEMON_IP3="10.0.2.4"

GNB_S1U_ADDR="10.0.1.111"
GNB_X2_ADDR="10.0.1.111"

ENB1_S1_ADDR="10.0.1.2"
MME1_S1_ADDR="10.0.1.1"

PGW_ADDR="4.7.254.207"
PROXY_SERVER_IP="10.0.2.80"
PDN_IP1="4.7.254.208"
PDN_IP2="4.7.254.209"
PDN_IP3="4.7.254.210"
PDN_IP4="4.7.254.211"

---5G_SA_SRAN---------
GNB_NG1_ADDR="10.0.1.67"
NGU1_ADDR="10.0.1.75"
AMF1_NG_ADDR="10.0.1.61"

GNB_S1U_ADDR6="fc00::0a00:0111"
GNB_X2_ADDR6="fc00::0a00:0111"
GNB_Xn_ADDR="10.0.1.111"
GNB_Xn_ADDR6="fc00::0a00:0111"

ENB1_S1_ADDR6="fc00::0a00:0002"
MME1_S1_ADDR6="fc00::0a00:0001"
GNB_NG1_ADDR6="fc00::0a00:0067"
NGU1_ADDR6="fc00::0a00:0075"
AMF1_NG_ADDR6="fc00::0a00:0061"

GNB2_XN_ADDR="10.0.1.115"
GNB2_NG_ADDR="10.0.1.114"

GNB2_XN_ADDR6="fc00::0a00:0115"

UEC_ADDR="72.22.0.1"
UPF1_ADDR="1.2.3.1"
UPF2_ADDR="1.2.4.1"
UPF3_ADDR="1.2.5.1"
UPF4_ADDR="1.2.6.1"
UPF5_ADDR="1.2.7.1"
UPF6_ADDR="1.2.8.1"


for QCI = 128, 148 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=8103,100,788,200,0 plmn=234:77')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR6..'.38412 region=1 set_id=2 pointer=2')
exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF1_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('amf_param id=2 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..NGU1_ADDR6..'/'..NGU1_ADDR..' devname=tunUPF')

exec('smf_upf_mapping id=1 upf=1 id=2 upf=1')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb type=external id=1 plmn=234:77 s1='..ENB1_S1_ADDR6..' enb_id_macro=0x00001 daemon=127.0.0.1:22222')
exec('set_enb type=external id=3 plmn=234:77 s1='..ENB1_S1_ADDR..' enb_id_macro=0x00001 daemon=127.0.0.1:22222')
exec('set_cell id=11 technology=lte enb=1 pci=3:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010b shared_plmn=234:77 is_cus_cell=on cus_addr=10.0.2.2:10011')
-----------------------------------------------------------------------------------------------------
exec('proxy_log GEN=debug')
exec('proxy_log DLER=debug')
exec('proxy_log SCH=debug')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('set_gnb id=2 type=external plmn=234:77 s1u='..GNB_S1U_ADDR6..' x2='..GNB_X2_ADDR6..'.36422 ng='..GNB_NG1_ADDR6..','..GNB_NG1_ADDR..' gnb_id=0x76C x2_peers=none amf=1 plmnList=234:77,234:78,234:79,234:80,234:81,234:82 nssai=0x1:0xd143a5,0x2:0xd143a5,0x3:0xd143a5,0x4:0xd143a5')
exec('set_gnb id=2 type=external plmn=234:77 s1u='..GNB_S1U_ADDR6..' x2='..GNB_X2_ADDR6..'.36422 ng='..GNB_NG1_ADDR6..'/'..GNB_NG1_ADDR..' xn='..GNB_Xn_ADDR..' xnu='..GNB_Xn_ADDR6..'/'..GNB_Xn_ADDR..' gnb_id=0x76C x2_peers=none amf=1,2 plmnList=234:77,234:78,234:79,234:80,234:81,234:82 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 eci=0x000021f pci=16:2 tac=8103 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF mandatory_for_activation=off tdd_cell=on')

exec('set_gnb id=5 type=simulated plmn=234:77 ng='..GNB2_NG_ADDR..' gnb_id=0x5 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2_peers=none xn='..GNB2_XN_ADDR..' xnu='..GNB2_XN_ADDR6..'/'..GNB2_XN_ADDR..' amf=2 nssai=0x1:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8')
exec('gnb_param id=5 xn_listening_socket=on send_xn_setup=on')
exec('set_cell id=1 gnb=5 nr_arfcn=636666:636666 pci=17:0 tac=8103 proxy='..DAEMON_IP2..':'..DAEMON_PORT..' nrci=0x1 mandatory_for_activation=off tdd_cell=on gscn=7880')
-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=234:77 tac_list=555,234,222,444,333,124')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR6..'.36412 supported_rat=lte,nblte pool=1:1 #mmegi=1 mmec=3 plmn=234:77')
exec('set_mme id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:2 #mmegi=1 mmec=3 plmn=234:77')

SGWID = 1
for U_ADDR = 133, 152 do
    exec('set_sgw id='..SGWID..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u=fc00::a00:'..U_ADDR..'/10.0.1.'..U_ADDR..' s11=10.0.1.'..U_ADDR..':60100')
    SGWID = SGWID + 1
end

exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec file=AirPhoneConfig.xml  id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.10:40000 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.1/26 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
exec('uec_param id=1 reordering_window_size=50 reordering_timer=300')

-----------------------------------------------------------------------------------------------------
--UE1 CONFIGURATION
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
    exec('set_ue id='..UEID..' rohc=16 sec_key=0102030405060708090A0B0C0D011001 cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
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
QCI = 128
QCI2 = 129
QCI3 = 130

for UEID = 21, 40 do
    exec('set_ue id='..UEID..' rohc=16 sec_key=0102030405060708090A0B0C0D011001 cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
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

for UEID = 41, 50 do
    exec('set_ue id='..UEID..' rohc=16 sec_key=0102030405060708090A0B0C0D011001 cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_eutra_capabilities=DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A2E31D0100000208000420000860001100002280004600008E0001200002480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B40003F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000504000003CE800000000000000000000000000000000000000000000000000000000000808E21090002A8001802297000020000104B1A0108C03808F0000006000000242000800210 ue_nr_capabilities=e1201000014f5e0302c00201404820d9c4c3e140426c020ffcc31e50b03826010188a01014c200141f11b586368e9315047f2ca4d940220b64c1203063c63ff30c7942c0e070f0113804e0001083011b9343e01c8200000148200000548200000949280000d300f81b7953781b5bac0141000009652504000065949410000296525040000e594941000049652524000154b29280ba07974ab2e81e4d2ac9a55915dc8020f00340201000000100 ue_eutra_nr_capabilities=0108040460201C04000E23000701C001820000000080001008080100202004008080100200010080')
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=internal')
end

for UEID = FIRST_UE_SA, 70 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:234:77:0000:0:0:00'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFAEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3800517046FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F8040400E2300000000101181406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F002C9000000800606D0001000009652500140EE8082C003C9380000000100200420')
end

for UEID = 71, END_UE_SA  do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:234:77:0000:0:0:00'.. IMSI_FIRST_UE_SA + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFAEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3800517046FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F8040400E2300000000101181406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F002C9000000800606D0001000009652500140EE8082C003C9380000000100200420')
end

for UEID = FIRST_UE_SA, END_UE_SA  do
    exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
for QI = 128, 146 do
    exec('set_qosflow id='..QOS_ID..' 5qi='..QI..' default=off')
    QOS_ID = QOS_ID + 1
end

exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1,2 default=on ue=all')
exec('set_nwslice id=2 qos_flows=1,2 snssai=0x80:0xd143a6 amf=1,2 default=off ue=52')
exec('set_nwslice id=3 qos_flows=1,2 snssai=0x81:0xd143a7 amf=1,2 default=off ue=53')
exec('set_nwslice id=4 qos_flows=1,2 snssai=0x82:0xd143a8 amf=1,2 default=off ue=54')
exec('set_nwslice id=5 qos_flows=1,2 snssai=0x83:0xd143a9 amf=1,2 default=off ue=55')
exec('set_nwslice id=6 qos_flows=1,2 snssai=0x84:0xd143aa amf=1,2 default=off ue=56')
exec('set_nwslice id=7 qos_flows=1,2 snssai=0x85:0xd143ab amf=1,2 default=off ue=57')
exec('set_nwslice id=8 qos_flows=1,2 snssai=0x86:0xd143ac amf=1,2 default=off ue=58')
exec('set_nwslice id=9 qos_flows=1,2 snssai=0x87:0xd143ad amf=1,2 default=off ue=59')
exec('set_nwslice id=10 qos_flows=1,2 snssai=0x88:0xd143ae amf=1,2 default=off ue=60')
exec('set_nwslice id=11 qos_flows=1,2 snssai=0x89:0xd143af amf=1,2 default=off ue=61')
exec('set_nwslice id=12 qos_flows=1,2 snssai=0x8a:0xd143b0 amf=1,2 default=off ue=62')
exec('set_nwslice id=13 qos_flows=1,2 snssai=0x8b:0xd143b1 amf=1,2 default=off ue=63')
exec('set_nwslice id=14 qos_flows=1,2 snssai=0x8c:0xd143b2 amf=1,2 default=off ue=64')
exec('set_nwslice id=15 qos_flows=1,2 snssai=0x8d:0xd143b3 amf=1,2 default=off ue=65')
exec('set_nwslice id=16 qos_flows=1,2 snssai=0x8e:0xd143b4 amf=1,2 default=off ue=66')
exec('set_nwslice id=17 qos_flows=1,2 snssai=0x8f:0xd143b5 amf=1,2 default=off ue=67')
exec('set_nwslice id=18 qos_flows=1,2 snssai=0x90:0xd143b6 amf=1,2 default=off ue=68')
exec('set_nwslice id=19 qos_flows=1,2 snssai=0x91:0xd143b7 amf=1,2 default=off ue=69')
exec('set_nwslice id=20 qos_flows=1,2 snssai=0x92:0xd143b8 amf=1,2 default=off ue=70')

exec('link_ctrl_param use_hb=off')
exec('cfg_end')
exec('debug_log  level=5')
exec('set_log log_to_file=true max_file_num=1')
exec('set_cnode ip=10.63.68.198:7676')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace uec=1 protocol=x2 on')

exec('start version_check=off')
exec('trace protocol=s1 on mme=1')
