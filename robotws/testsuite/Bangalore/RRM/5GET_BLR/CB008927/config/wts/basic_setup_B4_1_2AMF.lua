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
AMF2_NG_ADDR="10.0.1.61"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"
UPF2_ADDR="1.2.8.1"

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
SGW2_S1U_ADDR="10.0.1.137"
SGW2_S11_ADDR="10.0.1.138"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.254"
PGW2_ADDR="4.7.252.254"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"
PDN_IP2="4.7.252.208"
PDN_IP3="4.7.253.208"
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
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=143600:154600 gscn=1931 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=143600:154600 gscn=1931 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=143600:154600 gscn=1931 eci=0x000021f pci=17:1 tac=201 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=off  mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=143600:154600 gscn=1931 eci=0x000021f pci=17:2 tac=201 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off  mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')	
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..' s11='..SGW2_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=2 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW2_ADDR..'/24 apn=lteapn2.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA2 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/21 ngu='..AMF_NG_ADDR..' devname=tunUPF ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

exec('set_amf_region id=2 tac_list=7627108,100,788,201,0 plmn=311:490')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=3 pointer=3')
exec('amf_param id=2 full_nas_auth=on')
exec('set_upf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/21 ngu='..AMF2_NG_ADDR..' devname=tun2UPF ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

exec('smf_param id=1 max_pdu_session_supported=2000')
exec('smf_param id=2 max_pdu_session_supported=2000')
exec('smf_upf_mapping id=1 upf=1 id=2 upf=2')
--add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')
exec('amf_param id=2 ims_voice_3gpp=on full_nas_auth=on')

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------

--Cell 1 UEs:
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 10


--Cell 2 UEs
FIRST_UE_SA_CELL_2 = 11
END_UE_SA_CELL_2 = 20


--Cell 3 UEs
FIRST_UE_SA_CELL_3 = 21
END_UE_SA_CELL_3 = 30


--Cell 4 UEs
FIRST_UE_SA_CELL_4 = 31
END_UE_SA_CELL_4 = 40

--NSA UEs
FIRST_UE_NSA_CELL = 41
END_UE_NSA_CELL = 50



IMSI_1 = 21645100
IMSI_2 = 21645200
IMSI_3 = 21645300
IMSI_4 = 21645400
IMSI_5 = 21645500
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF05400782E0203C126BE7FFF6F800E026CF38FFCC31E50B008370101F8E01545F107FE6F28EF215F0410F96525881C082D94DD00C49F5883C893E12288B7CFC02FEC000003FB0000001E000702A2F837FF37947790AF82087CB292C40E0416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000000F000381517C46FF9BCA3BC857C1043E59496207020B6537403127D620F224F848A22DF3F00BFFE00000FFF80000078001C00158B836001C41000E230000000B0200A00DC041808C16006806046D927C0FFFF80004C00F800A0705006031098018001E0F805648000001648000011648000020013036B036B0568040800004B29282000032CA4A0800014B292804A075540EAA82D509005800792700000040200400808020040200C018D045')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_2 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF094000782E0203C126BE7FFF6F8016009B3CE3FF30C7942C020DC0C03F1C02A8BE20FFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FD8000007F6000000640000702A2F88DFF37947790AF82087CB292C41E00416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000001900001C0A8BE0DFFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FFF000007FFC000006400007000562E2300071040038360000002C0802808D010600D8C800034030236C93E07FFFC00036001F00140E0A00C062130030003C1F00AC90000002C90000022C9000004002606D606D60AD008100000965250400006594941000029652500940EAA81D5505AA1A002C003C9380000020100200404010020100600C68228')
   for gw_id = 11, 20 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_CELL_3, END_UE_SA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:490:0000:0:0:0'.. IMSI_3 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF094000782E0203C126BE7FFF6F8016009B3CE3FF30C7942C020DC0C03F1C02A8BE20FFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FD8000007F6000000640000702A2F88DFF37947790AF82087CB292C41E00416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000001900001C0A8BE0DFFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FFF000007FFC000006400007000562E2300071040038360000002C0802808D010600D8C800034030236C93E07FFFC00036001F00140E0A00C062130030003C1F00AC90000002C90000022C9000004002606D606D60AD008100000965250400006594941000029652500940EAA81D5505AA1A002C003C9380000020100200404010020100600C68228')
   for gw_id = 21, 30 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_CELL_4, END_UE_SA_CELL_4 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:490:0000:0:0:0'.. IMSI_4 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03C0047D4FFBEFFFFBAF094000782E0203C126BE7FFF6F8016009B3CE3FF30C7942C020DC0C03F1C02A8BE20FFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FD8000007F6000000640000702A2F88DFF37947790AF82087CB292C41E00416CA6E80624FAC41E449F091445BE7E017FFC00001FFF000001900001C0A8BE0DFFCDE51DE42BE0821F2CA4B10780105B29BA01893EB1079127C245116F9F805FFF000007FFC000006400007000562E2300071040038360000002C0802808D010600D8C800034030236C93E07FFFC00036001F00140E0A00C062130030003C1F00AC90000002C90000022C9000004002606D606D60AD008100000965250400006594941000029652500940EAA81D5505AA1A002C003C9380000020100200404010020100600C68228')
   for gw_id = 31, 40 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL, END_UE_NSA_CELL do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_5 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1201000014F5E0302C002054004820D9C4C3E141C04D8041FF9863CA160704C020311406014C200141F11B586368E9315047F2CA4D940E0416C9824060C78C7FE618F28581C0E1E026FFDC06FFDC000210602372687C0390400000290400000A90400001292500001A601F036F2A6F036B7580282000012CA4A080000CB29282000052CA4A080001CB29282000092CA4A480002A9652501740F6E956DD03D9A55B34AB62BBB02401E0068040200000020 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10181102C0C0388C000000888168241C460000024400420C0462002100008040401803080008020200C0180')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1,2 default=on ue=all')

--add for 5Qi-5 , 5Qi-1 & 5Qi-2 support for VoNR & ViNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=2 gfbr_ul=10000 mfbr_ul=10000 gfbr_dl=10000 mfbr_dl=10000')
exec('set_qosrule id=1 proto=tcp  qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1,2')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
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
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
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
