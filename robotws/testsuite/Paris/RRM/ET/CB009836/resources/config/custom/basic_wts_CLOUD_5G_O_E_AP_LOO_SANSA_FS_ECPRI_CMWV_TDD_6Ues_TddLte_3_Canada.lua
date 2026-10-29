---#set_log log_to_file=on
---#set_log log_to_file=on
---# Copyright (c) 2019 Nokia. All rights reserved.

---#---------------------------------------------------------------------------------------------------
---#VARIABLES
---#---------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
DAEMON_IP="10.0.2.1"


DAEMON_PORT="22222"

---## Variables for SA configuration

GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"

---## Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.112"
GNB2_NG_ADDR="10.0.1.102"
GNB2_XN_ADDR="10.0.1.101"

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
exec('mme_pool_area id=1 mmegi=1 plmn=302:630 tac_list=777,111,222,444,333,222,200,4580')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=40M s5u_rcv_buff_size=40M s1u_snd_buff_size=40M s1u_rcv_buff_size=40M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

---#---------------------------------------------------------------------------------------------------
---#5GCN CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=302:630')
exec('set_amf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')
---#add ims_voice_3gpp support
exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

---#---------------------------------------------------------------------------------------------------
---#GNB CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=302:630 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2_peers=none amf=1 plmnList=302:630 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=16:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x03 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 nr_arfcn=636666:636666 gscn=7880 eci=0x000021f pci=17:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x04 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x05 tdd_cell=off mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:1 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x06 tdd_cell=off mandatory_for_activation=off')
exec('set_cell id=7 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=18:2 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x07 tdd_cell=off mandatory_for_activation=off')
exec('set_cell id=8 gnb=2 nr_arfcn=135760:126380 gscn=1582 eci=0x000021f pci=19:0 tac=200 proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nrci=0x08 tdd_cell=off mandatory_for_activation=off')

---#---------------------------------------------------------------------------------------------------





---#---------------------------------------------------------------------------------------------------
---#UEC CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---#---------------------------------------------------------------------------------------------------
---#UE CONFIGURATION
---#---------------------------------------------------------------------------------------------------

---#UE Id=1 SA
MAX_SA_UE = 4
SUCI_FIRST_UE = 21645400

exec('set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:302:630:0000:0:0:021645400')
exec('set_ue simulated id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:302:630:0000:0:0:021645401')
exec('set_ue simulated id=3 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:302:630:0000:0:0:021645402')
exec('set_ue simulated id=4 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:302:630:0000:0:0:021645403')
for ueId = 1, MAX_SA_UE
do
	exec('ue_param id='..ueId..' ue_nr_capabilities=E1A09000575F7A13160003C320016080080C0498B800CE1E84804D9061CF9863CA160704C020311C01AA3626EB04610D04083A41601F5B2E2AC6873E238F40CFB027C66471E439F40CFB027D473E618F28581C0E1E2E000BE0038002F8002A4000E003650000500000751B0A303582308682041D20B00FAD971563439F11C7A067D813E33238F21CFA067D813EA39F30C7942C0E070F170005F001C0017C001500007001860E140400000E30F0A000309A00010E30F0A000305000020E30E0A00E268000030E307134200000718789A00184D00010B8018051013444008A068113639F0E1449DB1CF870A244D8E7C3853A26C73E1C089B1CF870A244D8E7C303D04C00F800A040500703009401C00180F84E00800000004000008020000000100000200800002004000018020000100100000A008004010040100000C008000060040000380200001C0100080000002000020010008060180200002401000014008004040100100080E0380200002E49400818061724A0000C2E4940181806018061724A0080C0300C2E494030180601806018060185C928040300C0300C030B92500E060180601806018060185C12800030B925000062724A0040C031392500406018062704A0000C4E49403818060180601806018062724A00C0C0300C0313925000060724A01C0C0300C0300C0300C030392500606018060181C1280003030040000681BCA9ACA9AC14AC0CAC0DAC19ACA5AC99AC05AC04AC08AC8DADD2305681A0800004B29282000032CA480800014B29282000072CA480800024B292020000B2CA480800034B292020000F2CA480800044B29202000132CA480800054B29202000172CA4A0802060192CA4A0800064B292818A55554AA2E9555D2A8AA0B1540E2A83455298AA4D154062A8145523AAAED40902F813D028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A05028140A0000C002038018404018030100600020200C018080100010100600004018031AA06000102030406074306A0')
end

---#UE Id=2 SA

---#UE Id=11 NSA

---#UE Id=12 NSA


---#---------------------------------------------------------------------------------------------------
---#COMMON CONFIGURATION
---#---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
---#set_nwslice id=1 snssai=0x01:0xd143a5             amf=1 default=on ue=all
---# add 5Qi-5 support for IMS Voip sign
exec('set_qosflow id=2 5qi=5')
---# add 5Qi-1 support for VoNR
exec('set_qosflow id=3 5qi=1')
---# add 5Qi-2 support for VideoNR
---# maxDataRateGbr=30720
exec('set_qosflow id=4 5qi=2 mfbr_dl=30720 mfbr_ul=29696 gfbr_dl=30720 gfbr_ul=29696')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
---#amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
---#smf_param additional_qosflows_to_activate=2,3,4 id=1
---#smf_param additional_qosflows_to_activate=2 id=1


exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1')

for ueId = 1, MAX_SA_UE
do
	exec('set_pdu_gateway id='..ueId..' ue_nat_ip=72.23.0.'..ueId..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end


---#---------------------------------------------------------------------------------------------------
---#OTHER CONFIGURATION
---#---------------------------------------------------------------------------------------------------
---# set_bearer id=2 ue=11 qci=9 pdn=1 ip=4.7.254.211 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=12 qci=9 pdn=1 ip=4.7.254.212 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=13 qci=9 pdn=1 ip=4.7.254.213 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=14 qci=9 pdn=1 ip=4.7.254.214 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=15 qci=9 pdn=1 ip=4.7.254.215 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=16 qci=9 pdn=1 ip=4.7.254.216 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=17 qci=9 pdn=1 ip=4.7.254.217 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
---# set_bearer id=2 ue=18 qci=9 pdn=1 ip=4.7.254.218 default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')






---#---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc on')
exec('trace uec=1 protocol=nr_rrc on')
exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=x2 on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_trace uec=1 protocol=all on')
exec('sim_trace amf=1 protocol=all on')
---#sim_param_set NR_PDCP_CIPHERING=distributed
exec('cfg_end')

exec('set_log log_to_file=on')
exec('sim_start version_check=off')
