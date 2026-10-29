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

--Variables for NSA configuration
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
PDN_IP="4.7.254.208"
PDN_IP_2="4.7.254.209"
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7881 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on  mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=640000:640000 gscn=7915 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on  mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')	
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

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
END_UE_SA_CELL_1 = 5

--Cell 2 UEs
FIRST_UE_SA_CELL_2 = 6
END_UE_SA_CELL_2 = 10




IMSI_1 = 21645100
IMSI_2 = 21645200
IMSI_3 = 21645300
IMSI_4 = 21645400
IMSI_5 = 21645500
IMSI_6 = 21645600

QOS_ID = 2


for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F1C02ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBB8EF800EEE3BE00036014001D0ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F33BB8EF800EEE3BE00036014001D0ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBF8FF800EFE3FE00036014001D00650389A000000C40A81C4D000002620560E268400023102A0713420001988158389A100010C40A83C4D000C2680014C40800809A0A8FC0D0236C93E04085B24F810236C93E04085B24F810276C93E042853B649F0002C186318C637FFFC0001701B001400180E0601C0C41701C001C00180F812208000001040000088200100000104002000022080040100041000802008820010080210400201006208004030084100080601806C1DBCA9AC1DBCA9A0182000012CB2A080000CB2CA82000052CB28080001CB2CA006A0F574AAAA83D5D2AAA0273009F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00002800C0080180200400300200E00802001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A02801041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000301')
   for gw_id = 1, 5 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F1C02ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBB8EF800EEE3BE00036014001D0ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F33BB8EF800EEE3BE00036014001D0ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBF8FF800EFE3FE00036014001D00650389A000000C40A81C4D000002620560E268400023102A0713420001988158389A100010C40A83C4D000C2680014C40800809A0A8FC0D0236C93E04085B24F810236C93E04085B24F810276C93E042853B649F0002C186318C637FFFC0001701B001400180E0601C0C41701C001C00180F812208000001040000088200100000104002000022080040100041000802008820010080210400201006208004030084100080601806C1DBCA9AC1DBCA9A0182000012CB2A080000CB2CA82000052CB28080001CB2CA006A0F574AAAA83D5D2AAA0273009F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00002800C0080180200400300200E00802001C0180180400300A00A01801001C0180380400700A01201802001C0380180800301200A02801041C0080180100300400A0080103801001004002004004010001AB0602072125262728770000000301')
   for gw_id = 6, 10 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
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
exec('sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
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
