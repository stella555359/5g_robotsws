-- Copyright (c) 2019 Nokia. All rights reserved.

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
--exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=800:18800 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=68787:133323 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')


----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x01:22 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=630000:630000 gscn=7811 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=650000:650000 gscn=8019 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=136100:126900 gscn=1587 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=off mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=349000:431000 gscn=5389 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

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
--Cell 1 UEs:
FIRST_F_T_SA = 1
END_F_T_SA = 40
FIRST_T_T_SA = 41
END_T_T_SA = 60
FIRST_T_T_SA_2 = 61
END_T_T_SA_2 = 100
FIRST_NSA_1 = 101
END_NSA_1 = 120
FIRST_NSA_2 = 121
END_NSA_2 = 140

IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700

QOS_ID = 2

for UEID = FIRST_F_T_SA, END_F_T_SA do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A05000574F7A03560003084000B0400406024C5C00670F42400C48340260300C47006A0D89BAC1184341020E9068028B65515090E7D033EC09F18E7CC31E50B0781C3C0B8002F800E000BE000B10006CA0000A00000A83E20EB04610D04083C41A0082D954540439F18E7CC31E50B0781C3C04FF8000003FE0000002C20006081D60E26840003080758B882001C4D000C2680008A01D61E2680061340002501750788200184D00000483A81C4104000C100542E2080061040C2080010200A83C41000C2082014200801809B01045D0014C0F0226CB5E3C49D0A76CB5E6C2893B65AF3614E9DB2D78F0276CB5E6C49D3A76CB5E6C29D3B65AF1C0341C4310842107A0BC00F800A000C040500703009401C00180F80600800000004000008020010040100400200004013036F2A6B0268040800000000002000020360208000080D80002A07174AA2858027007C0A05038000A100060808010020200800040401002010040004020040080802006020080000040180210080100202004000080100010100200404020000008040022540202048400')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_T_T_SA, END_T_T_SA do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A05000574F7A03560003084000B0400406024C5C00670F42400C48340260300C4700AA0D89BAC1184341020E9068028B65515090E7D033EC09F18E7CC31E50B0781C3C0B8002F800E000BE000B10006CA0000A00000E83614606B04610D04083A41A00A2D954542439F40CFB027C639F30C7942C1E070F02E000BE0038002F8002C4001B280002800000A0F88DAC1184341020F1068020B65515010E7C639F30C7942C1E070F013F8000000FE000000012C1C4D080002100EB0F13400309A0000080B800809A2E0003202811365AF361449DB2D79A3D05E007C0050006020280381804A00E000C07C010040000000200100000003953400040000006C0400D2AAA16006C00D0280002000420200400808010000010040044A80404090800')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end


for UEID = FIRST_T_T_SA_2, END_T_T_SA_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A05000574F7A03560003084000B0400406024C5C00670F42400C48340260300C4700AA0D89BAC1184341020E9068028B65515090E7D033EC09F18E7CC31E50B0781C3C0B8002F800E000BE000B10006CA0000A00000E83614606B04610D04083A41A00A2D954542439F40CFB027C639F30C7942C1E070F02E000BE0038002F8002C4001B280002800000A0F88DAC1184341020F1068020B65515010E7C639F30C7942C1E070F013F8000000FE000000012C1C4D080002100EB0F13400309A0000080B800809A2E0003202811365AF361449DB2D79A3D05E007C0050006020280381804A00E000C07C010040000000200100000003953400040000006C0400D2AAA16006C00D0280002000420200400808010000010040044A80404090800')
   for gw_id = 1, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_NSA_1, END_NSA_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1225000574F7A03560003C3A800B01E800002000C80409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C791E7D8F3EC09323DFA0EFD837EC123634FB207D824EC1A760D7B167C0400406024C5C00670F42400C48340260300C40006A0F883AC1184341020F105C0416CAA2A022D78C73E619F28581C0E3E0025000003480C0704001A7FC000001FF00000014100060AA8D89BAC1184341020E905C0516CAA2A122D7A0ABD825E31CF9863CA1607038F8021000003080C070400B8002F800E000BE000A1000D940001400001E825004800601E01080301F004010000000080000100582B795340104000000000010000101B000054162E954509007C00F028000A10012A00014214A2020066300 dual_conn=eutra_nr ue_eutra_nr_capabilities=A107C1DC260201C41000C268000824441CA160201C410000064441B01004020804388200000089C2602018410389A00001020441C8160241C4D00000A4441301004021C4D00000244E130100E268006134000C1022170050106026801154208907893A74ED8E7C3053A70D3A74E9E24E9D0B639F0C14E8424E9D0C49D0A76C73E1801A071000C004007A03A000100061014120A000100008003080A09050000800040018405048288030C000402000100000040001002004400020100008000200801080004020100200404010000800080402004008800040201002000040100208001004020080108000402010040080401000')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


for UEID = FIRST_NSA_2, END_NSA_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_4 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1225000574F7A03560003C3A800B01E800002000C80409063D011EC00F04C990E7C8B5E82AF6097A067D813E078F11C791E7D8F3EC09323DFA0EFD837EC123634FB207D824EC1A760D7B167C0400406024C5C00670F42400C48340260300C40006A0F883AC1184341020F105C0416CAA2A022D78C73E619F28581C0E3E0025000003480C0704001A7FC000001FF00000014100060AA8D89BAC1184341020E905C0516CAA2A122D7A0ABD825E31CF9863CA1607038F8021000003080C070400B8002F800E000BE000A1000D940001400001E825004800601E01080301F004010000000080000100582B795340104000000000010000101B000054162E954509007C00F028000A10012A00014214A2020066300 dual_conn=eutra_nr ue_eutra_nr_capabilities=A107C1DC260201C41000C268000824441CA160201C410000064441B01004020804388200000089C2602018410389A00001020441C8160241C4D00000A4441301004021C4D00000244E130100E268006134000C1022170050106026801154208907893A74ED8E7C3053A70D3A74E9E24E9D0B639F0C14E8424E9D0C49D0A76C73E1801A071000C004007A03A000100061014120A000100008003080A09050000800040018405048288030C000402000100000040001002004400020100008000200801080004020100200404010000800080402004008800040201002000040100208001004020080108000402010040080401000')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

-------------------------------------------------------------------------------
--COMMON CONFIGURATION
--------------------------------------------------------------------------------------------------
--exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_qosflow id=2 5qi=5')
--exec('set_qosflow id=3 5qi=1')
--exec('set_qosflow id=4 5qi=2')
--exec('set_qosrule id=1 proto=udp  qos_flow=1')
--exec('set_qosrule id=2 proto=tcp  qos_flow=2')
--exec('set_qosrule id=3 proto=udp qos_flow=3')
--exec('set_qosrule id=4 proto=udp qos_flow=4')
--exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3,4 snssai=0x01:0xD143A5 default=on ue=all amf=1')
--qosflow_set id=4  5qi=2   gfbr_ul=30720  gfbr_dl=30720  mfbr_ul=30720  mfbr_dl=30720  qos_flow_type=gbr ue=all

exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=2 gfbr_ul=30720  gfbr_dl=30720  mfbr_ul=30720  mfbr_dl=30720  qos_flow_type=gbr ue=all')
exec('set_qosrule id=1 proto=udp  qos_flow=1')
exec('set_qosrule id=2 proto=tcp  qos_flow=2')
exec('set_qosrule id=3 proto=udp  qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
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
