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


---## Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.2"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP1="4.7.254.1"

---#---------------------------------------------------------------------------------------------------
---#ENB CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=302:630 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

---#---------------------------------------------------------------------------------------------------
---#EPC CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=302:630 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=20')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=20')

---#---------------------------------------------------------------------------------------------------
---#5GCN CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=302:630')
exec('set_amf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

---#add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

---#---------------------------------------------------------------------------------------------------
---#GNB CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=302:630 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=302:630 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=18:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x05 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=18:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x06 tdd_cell=on mandatory_for_activation=off')
---#---------------------------------------------------------------------------------------------------

---#---------------------------------------------------------------------------------------------------
---#UEC CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')
---#---------------------------------------------------------------------------------------------------
---#UE CONFIGURATION
---#---------------------------------------------------------------------------------------------------

---#UE Id=1 SA
MAX_SA_UE = 6
SUCI_FIRST_UE = 21645400

exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:302:630:0000:0:0:021645400')
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:302:630:0000:0:0:021645401')
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:302:630:0000:0:0:021645402')
exec('set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:302:630:0000:0:0:021645403')
exec('set_ue simulated id=5 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:302:630:0000:0:0:021645404')
exec('set_ue simulated id=6 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:302:630:0000:0:0:021645405')
for ueId = 1, MAX_SA_UE
do
	exec('ue_param id='..ueId..' ue_nr_capabilities=UE_CAPA capability_file=./ue_capabilities.cfg')
end

---#UE Id=2 SA
---#UE Id=3 SA
---#UE Id=4 SA
---#UE Id=5 SA
---#UE Id=6 SA

---#UE Id=11 NSA


---#UE Id=12 NSA
---#UE Id=13 NSA
---#UE Id=14 NSA
---#UE Id=15 NSA
---#UE Id=16 NSA

---#---------------------------------------------------------------------------------------------------
---#COMMON CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
---#set_nwslice id=1 snssai=0x01:0xd143a5             amf=1 default=on ue=all

---#add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
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
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
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
