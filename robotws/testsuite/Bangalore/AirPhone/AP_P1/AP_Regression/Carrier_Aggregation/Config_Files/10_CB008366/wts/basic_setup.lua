# Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT=50000
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

EDAEMON_PORT="50000"

DAEMON_IP2="10.0.2.3"
DAEMON_IP3="10.0.2.4"

--Sim-gNBs--
GNB2_NG_ADDR="10.0.1.107"
GNB2_S1U_ADDR="10.0.1.114"
GNB2_X2_ADDR="10.0.1.115"
GNB2_Xn_ADDR="10.0.1.126"
--GNB2_NGC_ADDR="10.0.1.107"
--GNB2_NGU_ADDR="10.0.1.160"

GNB3_NG_ADDR="10.0.1.108"
GNB3_S1U_ADDR="10.0.1.116"
GNB3_X2_ADDR="10.0.1.117"
GNB3_Xn_ADDR="10.0.1.127"
--GNB3_NGC_ADDR="10.0.1.108"
--GNB3_NGU_ADDR="10.0.1.167"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.2"

ENB1_X2_ADDR="10.0.1.121"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"

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
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x076C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5 xn='..GNB_XN_ADDR..' xp_management=on xp='..GNB_X2_ADDR..':36422 xpu='..GNB_X2_ADDR..':36422')
exec('set_cell id=1 gnb=2 nr_arfcn=376000:392080 gscn=4901 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=350600:426000 gscn=5325 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=145700:156600 gscn=1959 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
--SIM GNB CONFIGURATION --Xn SA
---------------------------------------------------------------------------------------------------
exec('set_gnb id=22 type=simulated plmn=311:489 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB2_Xn_ADDR..' xnu='..GNB2_Xn_ADDR..' gnb_id=0x16 ng='..GNB2_NG_ADDR..' amf=1 plmnList=311:489 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8 x2_peers=none')
exec('gnb_param id=22 xn_listening_socket=on send_xn_setup=on')
exec('set_cell id=1 gnb=22 nr_arfcn=145700:156600 gscn=1959 pci=19:0 tac=200 proxy='..DAEMON_IP2..':9999|'..DAEMON_IP2..':8888 nrci=0x06 mandatory_for_activation=off tdd_cell=off')

exec('set_gnb id=23 type=simulated plmn=311:489 daemon='..SERVER_IP..':'..EDAEMON_PORT..' xn='..GNB3_Xn_ADDR..' xnu='..GNB3_Xn_ADDR..' gnb_id=0x17 ng='..GNB3_NG_ADDR..' amf=1 plmnList=311:489 nssai=0x01:0xd143a5,0x80:0xd143a6,0x81:0xd143a7,0x82:0xd143a8,0x83:0xd143a9,0x84:0xd143aa,0x85:0xd143ab,0x86:0xd143ac,0x87:0xd143ad,0x88:0xd143ae,0x89:0xd143af,0x8a:0xd143b0,0x8b:0xd143b1,0x8c:0xd143b2,0x8d:0xd143b3,0x8e:0xd143b4,0x8f:0xd143b5,0x90:0xd143b6,0x91:0xd143b7,0x92:0xd143b8 x2_peers=none')
exec('gnb_param id=23 xn_listening_socket=on send_xn_setup=on')
exec('set_cell id=1 gnb=23 nr_arfcn=350600:426000 gscn=5325 pci=19:1 tac=200 proxy='..DAEMON_IP3..':9999|'..DAEMON_IP3..':8888 nrci=0x07 mandatory_for_activation=off tdd_cell=off')


----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')	
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=40M sgi_snd_buff_size=40M s5u_rcv_buff_size=40M s5u_snd_buff_size=40M gtpu_read_packets_threshold=20')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')

--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_3 = 1
END_UD_SA_CELL_3 = 10
FIRST_UE_SA_NONCA_CELL_1 = 181
END_UD_SA_NONCA_CELL_1 = 190
FIRST_UE_NSA_CELL_1 = 11
END_UE_NSA_CELL_1 = 20
FIRST_UE_SA_CELL_2 = 31
END_UD_SA_CELL_2 = 40
FIRST_UE_SA_NONCA_CELL_2 = 191
END_UD_SA_NONCA_CELL_2 = 200
FIRST_UE_NSA_CELL_2 = 41
END_UE_NSA_CELL_2 = 50
FIRST_UE_SA_CELL_1 = 61
END_UD_SA_CELL_1 = 70
FIRST_UE_SA_NONCA_CELL_3 = 201
END_UD_SA_NONCA_CELL_3 = 210
FIRST_UE_NSA_CELL_3 = 71
END_UE_NSA_CELL_3 = 80
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700
IMSI_5 = 21645800
IMSI_6 = 21645900
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_3, END_UD_SA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805517C41FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FD8000007F60000001C00E0545F063FE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000000700381517C1BFF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E000AC5C18000E20800706C0000005810050062020C01B0501A01811B649F03FFFE0000B00F800A070300C0620B00C000F07C02B24000000B24000008B2400001000981B581B582B40204000025949410000196525040000A5949402503AAA0755416A8082C003C9380000020100200404010020100600C20')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end   
end

for UEID = FIRST_UE_SA_NONCA_CELL_1, END_UD_SA_NONCA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F831AC31B47498A823F96525CA01105B260901831E31FF9863CA16070387809BFF761BFF76008006000000000E0C00000000210600C72687C0390400000290400000A90400001292500001A6017066F266B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501341B6E936DD0AD9A55B15DD8020F003402010000000000040080108')
   for gw_id = 11, 20 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end   
end

for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F831AC31B47498A823F96526CA01105B260901831E31FF9863CA16070387809BFF701BFF700008418031C9A1F00E41000000A41000002A41000004A494000069807C05BC85BC05ADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D01DBA43B740766956CD2AD8AEEC0107801A010080000008 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03830000000888160641C180000024400401C0182002100008040401803080008020200C0180')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)      
end 

for UEID = FIRST_UE_SA_CELL_2, END_UD_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_3 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805517C41FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FD8000007F60000001C00E0545F063FE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000000700381517C1BFF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E000AC5C18000E20800706C0000005810050062020C01B0501A01811B649F03FFFE0000B00F800A070300C0620B00C000F07C02B24000000B24000008B2400001000981B581B582B40204000025949410000196525040000A5949402503AAA0755416A8082C003C9380000020100200404010020100600C20')
   for gw_id = 31, 40 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_NONCA_CELL_2, END_UD_SA_NONCA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F883AC31B47498A823F96525CA01105B260901831E31FF9863CA16070387809BFF761BFF76008006000000000E20800000002106020F2687C0390400000290400000A90400001292500001A6017066F266B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501341B6E936DD0AD9A55B15DD8020F003402010000000000040080108')
   for gw_id = 41, 50 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end   
end

for UEID = FIRST_UE_NSA_CELL_2, END_UE_NSA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_4 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F883AC31B47498A823F96526CA01105B260901831E31FF9863CA16070387809BFF701BFF700008418083C9A1F00E41000000A41000002A41000004A494000069807C05BC85BC05ADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D01DBA43B740766956CD2AD8AEEC0107801A010080000008 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03882000000888160641C410000024400401C0412002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_1, END_UD_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_5 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805517C41FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FD8000007F60000001C00E0545F063FE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000000700381517C1BFF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E000AC5C18000E20800706C0000005810050062020C01B0501A01811B649F03FFFE0000B00F800A070300C0620B00C000F07C02B24000000B24000008B2400001000981B581B582B40204000025949410000196525040000A5949402503AAA0755416A8082C003C9380000020100200404010020100600C20')
   for gw_id = 61, 70 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_NONCA_CELL_3, END_UD_SA_NONCA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A01000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A63000A0F837AC31B47498A823F96525CA01105B260901831E31FF9863CA16070387809BFF761BFF76008006000000000E0D80000000210600DF2687C0390400000290400000A90400001292500001A6017066F266B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501341B6E936DD0AD9A55B15DD8020F003402010000000000040080108')
   for gw_id = 71, 80 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end   
end

for UEID = FIRST_UE_NSA_CELL_3, END_UE_NSA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_6 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1201000014F5E0302C00201404820D9C4C3E140C1360107FE618F28581C130080C450080A61000A0F837AC31B47498A823F96526CA01105B260901831E31FF9863CA16070387809BFF701BFF700008418037C9A1F00E41000000A41000002A41000004A494000069807C15BC95BC15ADD600A0800004B29282000032CA4A0800014B29282000072CA4A0800024B292920000AA5949405D05DBA4BB741766956CD2AD8AEEC0107801A010080000008 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03836000000888160641C1B0000024400401C01B2002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_nwslice id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
exec('sim_debug_log level=2 app_type=l2nrt')
exec('sim_debug_log level=2 app_type=l2rt')
exec('sim_debug_log level=2 app_type=ueproxy')
exec('sim_debug_log enable_events_date=on')
exec('sim_debug_log enable_debug_date=on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
--exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=xn on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
