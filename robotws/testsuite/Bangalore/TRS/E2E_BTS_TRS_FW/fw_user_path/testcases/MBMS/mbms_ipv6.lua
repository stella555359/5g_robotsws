-- Copyright (c) 2019 Nokia. All rights reserved.
-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
DAEMON_IP="10.0.2.1"
SERVER_IP=DAEMON_IP
DAEMON_PORT=10000

--IPs for Ngc & Ngu planes--
GNB1_NGC1_ADDR="10.0.1.40"
GNB1_NGU1_ADDR="10.0.1.40"
GNB_XN_ADDR="10.0.1.40"
--Core IPs--
AMF1_NG_ADDR="10.0.1.60"
MME1_S1_ADDR="2c00::1"
GNB1_XN_ADDR="10.0.1.70"
GNB1_NG_ADDR="10.0.1.70"
AMF2_NG_ADDR="fc00::60"
GNB2_XN_ADDR="fc00::40"
GNB2_NG_ADDR="fc00::40"
GNB3_XN_ADDR="fc00::70"
--Real-eNB--
ENB1_S1_ADDR="2c00::2"


NGU1_ADDR="10.0.1.60"
NGU2_ADDR="fc00::60"

SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"

PDN_IP1="4.7.254.208"

UEC_ADDR="72.22.0.1"
UPF1_ADDR="1.2.3.1"

for QCI = 128, 148 do
exec('set_qci qci='..QCI..' gbr=no priority=1 delay=80')
end

---------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=8103,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng=10.0.1.1:38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu=10.0.1.1 devname=tunUPF ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')
exec('set_amf_region id=2 tac_list=8103,100,788,200,0 plmn=311:489')
--exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF2_NG_ADDR..'.38412  region=2  set_id=2 pointer=2')
--exec('amf_param id=2 full_nas_auth=on')
--exec('set_upf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF1_ADDR..'/24 ngu='..NGU2_ADDR..' devname=tunUPF ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')
--exec('smf_upf_mapping id=1 upf=1')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb type=external id=1 plmn=244:09 s1=2c00::2 enb_id_macro=0x00001 daemon=127.0.0.1:10000')
exec('set_cell id=11 technology=lte enb=1 pci=3:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010b shared_plmn=244:09 is_cus_cell=on cus_addr=10.0.2.2:10011')
exec('set_cell id=12 technology=lte enb=1 pci=4:0 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010c shared_plmn=244:09 is_cus_cell=on cus_addr=10.0.2.2:10012')
exec('set_cell id=13 technology=lte enb=1 pci=4:2 tac=124 proxy=10.0.2.2:2152 mandatory_for_activation=on eci=0x000010d shared_plmn=244:09 is_cus_cell=on cus_addr=10.0.2.2:10013')
---------------------------------------------------------------------------------------------------
  
-----------------------------------------------------------------------------------------------------
--exec('proxy_log GEN=debug')
--exec('proxy_log DLER=debug')
--exec('proxy_log SCH=debug')

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
--WITH DIFF IPs FOR NGU & NGC
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 ng=10.0.1.2 ngu=10.0.1.2 gnb_id=0x1 x2_peers=none amf=1 plmnList=311:489 xn=10.0.1.2 nssai=0x01:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=135760:126380 eci=0x000021f pci=16:2 tac=8103 proxy='..PROXY_SERVER_IP..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x3FFF mandatory_for_activation=off tdd_cell=off')


---xn

--exec('set_gnb id=3 type=external plmn=234:77 ng=fc00::70/'..GNB1_NG_ADDR..' gnb_id=0x1 x2_peers=none amf=1,2 plmnList=234:77 xn='..GNB3_XN_ADDR..'  nssai=0x01:0xd143a5')


-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1=2c00::1.36412 mmegi=1 mmec=3 supported_plmn=244:09 m3=2c00::1.36444 sm=127.0.0.1:0  supported_rat=lte,nblte')
--SGWID = 1
--for U_ADDR = 133, 152 do
--	exec('set_sgw id='..SGWID..' ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u=10.0.1.'..U_ADDR..' s11=10.0.1.'..U_ADDR..':60100 s5u_snd_buff_size=8M s5u_rcv_buff_size=8M s1u_snd_buff_size=8M s1u_rcv_buff_size=8M gtpu_read_packets_threshold=10')
--    SGWID = SGWID + 1
--end
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u=10.0.1.133 s11=10.0.1.137:60100')

exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA1')


exec("set_mce id=1 m3=2c00::2.36444")
exec("set_mbmsgw id=1 type=simulated daemon=127.0.0.1:10000 sm=127.0.0.1:0 m1=2c00::5.2154 trf_interface=2.2.2.254/24")
exec("mbms_param time_ref=UTC")
exec("mbms_param sync_ref=0:0")

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec file=AirPhoneConfig.xml  id=1 enable_cus_if=on uec_cus_if_ip=10.0.2.1:40000 ip='..DAEMON_IP..':'..DAEMON_PORT..' pdn=1 devtype=tun addr=72.22.0.2/26 peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=8388608 proxy_rcv_buf_size=8388608')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')

-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
MAX_NUM_UES = 100
IMSI_FIRST_UE=111111001
IMSI_FIRST_UE_SA=21645400


FIRST_UE_SA = 1
END_UE_SA = 20
QCI = 128
QCI2 = 129
QCI3 = 130
QOS_ID = 2
---for UEID = 1, 20 do
--	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
---    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
 ---   exec('ue_param id='..UEID..' ue_eutra_capabilities=DE20009E0008206102860E2048A163069022489942A58B983268D9D3CA56BF3C7800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E0000000078000000037F7FFD9001003838AD78000000080B8401D0100200082100042080021840011020008A100046080023840012020009210004A080025840013020009A10005008002884001482000A610005408002A84001582000AE10005808002C84001682000B610005D08002F04001B42000FE100E9E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000001E000000007800000000F3A00000000000000000000000000000000000000000000000000000000000202288425340C3D55555555555555574141500230C1080A58088080000002096140211807135E0000018800000080 ue_nr_capabilities=E120700047D0FFB17DE8E6BC32001A0349CF9A44F3E0048018807C07C0203F08006F3826807BDEB70D0645020E0000075C160145B25AA05813E439F40478C73E618F28581C0E1E0C0200413400FF00000026007C005638280381F84800E07C003968000038000395340006000010600000F2A8284801C003C00D40A80010203038980858808890C860C0D8FA09293139414922A400 ue_eutra_nr_capabilities=A10CB01A059480713400000010E4600602682930001000080404008010') 
    --exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    --exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    --exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    --exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    --exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	  --  QCI = QCI + 1
        --if (QCI2 < 147) then 
        --QCI2 = QCI2 + 1
        --else QCI2 = QCI2 - 1 
        --end
	--	if (QCI3 < 145) then 
	--	QCI3 = QCI3 + 1 
	--	else QCI3 = QCI3 - 2 
	--	end
--nd
--QCI = 128
--QCI2 = 129
--QCI3 = 130

for UEID = 21, 40 do
	exec('set_param SEC_OP_KEY=01020304050607080910111213141516')
    exec('set_ue id='..UEID..' rohc=16 sec_key=00112233445566778899AABBCCDDEEFF cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=244:09:1'.. IMSI_FIRST_UE + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1201000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298400283E236B0C6D1D262A08FE5949B28340105B260901831E31FF9863CA160703878089C0270000841808DC9A1F00E41000000A41000002A41000004A494000069807C0DBCA9BC0DADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D03CBA559740EAE9564D2AC8AEE40B003C00D008040000004 ue_eutra_nr_capabilities=A10181102C0C0388C000000888160641C460000024400401C0462002100008040401803080008020200C0180') 
    exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=external')
    --exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')  
    --exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1') 
    --exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
	  --  QCI = QCI + 1
       -- if (QCI2 < 147) then 
       -- QCI2 = QCI2 + 1
       -- else QCI2 = QCI2 - 1 
       -- end
		--if (QCI3 < 145) then 
		--QCI3 = QCI3 + 1 
	--	else QCI3 = QCI3 - 2
	end
--end

--QCI = 128
--QCI2 = 129
--QCI3 = 130

--for UEID = 41, 50 do
  --  exec('set_ue id='..UEID..' rohc=16 sec_key=0102030405060708090A0B0C0D011001 enb=1 cell=11 uec=1 pdn=1 category=12 category-dl=19 category-ul=15 release=15 idle_edrx_cycle_len=2 ptw=2.56 eia=null+snow3g+aes eea=null imsi=234:77:1'.. IMSI_FIRST_UE + UEID - 1)
    --exec('ue_param id='..UEID..' ue_eutra_capabilities=DE1809D0008206102860E2048A163069022489942A58B983268D9D3CB5F9D3A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000001BFBFFEC800801C364000000017BA000000080952A2E31D0100000208000420000860001100002280004600008E0001200002480004A000096000130000268000500000A2000148000298000540000AA0001580002B8000580000B20001680002D80005D0000BC0001B40003F800E9D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E800000007400000003A00000001D00000000E80000000504000003CE800000000000000000000000000000000000000000000000000000000000808E21090002A8001802297000020000104B1A0108C03808F0000006000000242000800210 ue_nr_capabilities=e1201000014f5e0302c00201404820d9c4c3e140426c020ffcc31e50b03826010188a01014c200141f11b586368e9315047f2ca4d940220b64c1203063c63ff30c7942c0e070f0113804e0001083011b9343e01c8200000148200000548200000949280000d300f81b7953781b5bac0141000009652504000065949410000296525040000e594941000049652524000154b29280ba07974ab2e81e4d2ac9a55915dc8020f00340201000000100 ue_eutra_nr_capabilities=0108040460201C04000E23000701C001820000000080001008080100202004008080100200010080')
    --exec('ue_param id='..UEID..' dual_conn=eutra_nr')
    --exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'.. UEID + 1 ..' default=on trf_type=internal')
    --exec('set_bearer id=3 ue='..UEID..' qci='..QCI..' pdn=1')
    --exec('set_bearer id=5 ue='..UEID..' qci='..QCI2..' pdn=1')
    --exec('set_bearer id=6 ue='..UEID..' qci='..QCI3..' pdn=1')
      --  QCI = QCI + 1
       -- if (QCI2 < 147) then
       -- QCI2 = QCI2 + 1
       -- else QCI2 = QCI2 - 1
       -- end
       -- if (QCI3 < 145) then
       -- QCI3 = QCI3 + 1
       -- else QCI3 = QCI3 - 2
       -- end
--end

for UEID = FIRST_UE_SA, 20 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_FIRST_UE_SA + UEID - 1)
--    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000383A000F04983200021E12006201A0130080C0700EA8D851AC10143404B2CA261A007AD8202020E1DE38720C38002064F1F57001FF001C007FC00162001DB800040000000380004000000001546C4CD6080A1A025965130D003D6C10101070EF1C39061C00103278FAB800FF800E003FE000B1000EDC000200000001C0002000000000AA3626EB04050D012CB28986801EB608080838778E1C830E0008193C7D5C007FC007001FF0005880076E000100000000E0001000000000551B13B582028680965944C3400F5B0404041C3BC70E418700040C9E3EAA00000A000002C4003B70000800000007000080000000000420E268000000010134540003804044F617001800140E0A00E06013003800341F000000000000072A68000800004B2CA801A55542C007000B000000040080118B130001020304050607080B101112131921252627284A0')


exec('ue_param id='..UEID..' ue_nr_capabilities=E1A01000014F5E0302C002074001208367130F8509009B0083FF30C7942C0E09804062280C0298C00283E236B0C6D1D262A08FE5949328340105B260901831E31FF9863CA160703878099D87619D876008006000000000E2300000000210602372687C0390400000290400000A90400001292500001A6017036F236B7480282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501340EAE91D5D0AA9A55515DA816007801A010080000000000200400840')

--exec('ue_param id='..UEID..' ue_nr_capabilities=E1A00000074E5A031E000380A03C1260C8000878180C4034026010180E01D51B0A3582028680965944C043D6C10101070EF1C39061C00103278FAB800FF800E003FE000310EDC000200000001C0002000000000AA36266B04050D012CB2898087AD8202020E1DE38720C38002064F1F57001FF001C007FC000621DB800040000000380004000000001546C4DD6080A1A02596513010F5B0404041C3BC70E418700040C9E3EAE003FE003800FF8000C43B7000080000000700008000000002A8D89DAC10143404B2CA26021EB608080838778E1C830E0008193C7D540000140000018876E000100000000E000100000000000841C4D00000000202682807008089EC1601900140E0601C0C01601C001A0F8000000000000395340004000025965400D2AAA0207000B000000040080118B130001020304050607080B101112131921252627284A')


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
exec('set_cnode   ip=127.0.0.1:7676')
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


