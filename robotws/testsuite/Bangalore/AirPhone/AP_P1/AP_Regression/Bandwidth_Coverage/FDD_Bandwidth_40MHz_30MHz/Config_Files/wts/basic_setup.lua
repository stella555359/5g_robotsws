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
UPF_ADDR="1.2.4.1"

EDAEMON_PORT="22222"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.2"

ENB1_X2_ADDR="10.0.1.121"
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
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=348440:433000 gscn=5411 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=348440:433000 gscn=5411 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=348440:433000 gscn=5411 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=348440:433000 gscn=5411 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

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
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

--Cell 1 UEs:
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 10
FIRST_UE_NSA_CELL_1 = 11
END_UE_NSA_CELL_1 = 20

--Cell 2 UEs
FIRST_UE_SA_CELL_2 = 41
END_UE_SA_CELL_2 = 50
FIRST_UE_NSA_CELL_2 = 51
END_UE_NSA_CELL_2 = 60


--Cell 3 UEs
FIRST_UE_SA_CELL_3 = 81
END_UE_SA_CELL_3 = 90
FIRST_UE_NSA_CELL_3 = 91
END_UE_NSA_CELL_3 = 100


--Cell 4 UEs
FIRST_UE_SA_CELL_4 = 121
END_UE_SA_CELL_4 = 130
FIRST_UE_NSA_CELL_4 = 131
END_UE_NSA_CELL_4 = 140



IMSI_1 = 21645100
IMSI_2 = 21645200
IMSI_3 = 21645300
IMSI_4 = 21645400
IMSI_5 = 21645500
IMSI_6 = 21645600
IMSI_7 = 21645700
IMSI_8 = 21645800
IMSI_9 = 21645900
IMSI_10 = 21646000
IMSI_11 = 21646100
IMSI_12 = 21646200
IMSI_13 = 21646300
IMSI_14 = 21646400
IMSI_15 = 21646500
IMSI_16 = 21646600
IMSI_17 = 21646700
IMSI_18 = 21646800

IMSI_19 = 21646900
IMSI_20 = 21647000
IMSI_21 = 21647100
IMSI_22 = 21647200
IMSI_23 = 21647300
IMSI_24 = 21647400
IMSI_25 = 21647500
IMSI_26 = 21647600
IMSI_27 = 21647700
IMSI_28 = 21647800
IMSI_29 = 21647900
IMSI_30 = 21648000
IMSI_31 = 21648100
IMSI_32 = 21648200
IMSI_33 = 21648300
IMSI_34 = 21648400
IMSI_35 = 21648500
IMSI_36 = 21648600

QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_3 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03882000000888168241C410000024400420C0412002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_4 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308')
   for gw_id = 41, 50 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_2, END_UE_NSA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_6 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03882000000888168241C410000024400420C0412002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_3, END_UE_SA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_7 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308')
   for gw_id = 81, 90 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_3, END_UE_NSA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_9 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03882000000888168241C410000024400420C0412002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

for UEID = FIRST_UE_SA_CELL_4, END_UE_SA_CELL_4 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_10 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308')
   for gw_id = 121, 130 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_4, END_UE_NSA_CELL_4 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_12 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E3805506C41D608C21A081078804656C98AB121CFB027C471E31238F21CFA8E7CC31E50B0381C3C27FFC00001FFF000000700381517C46FF9BCA3BC857C1043E59496201105B29BA01893EB1079127C245116F9F805FFF000007FFC000001C00E0545F06FFE6F28EF215F0410F965258804416CA6E80624FAC41E449F091445BE7E017FFC00001FFF00000070038002B17118003882001C1B00000016040140468083006C1406806046D927C0FFFF80002C03E00281C0C0301882C030003C1F00AC90000002C90000022C900000400260CD60CD60CD008100000965250400006594941000029652500941AAA8355506AA020B000F24E0000008040080101004008040180308 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C03882000000888168241C410000024400420C0412002100008040401803080008020200C0180')
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
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
--exec('sim_debug_log level=2 app_type=l2nrt')
--exec('sim_debug_log level=2 app_type=l2rt')
--exec('sim_debug_log level=2 app_type=ueproxy')
exec('sim_debug_log enable_events_date=on')
exec('sim_debug_log enable_debug_date=on')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')