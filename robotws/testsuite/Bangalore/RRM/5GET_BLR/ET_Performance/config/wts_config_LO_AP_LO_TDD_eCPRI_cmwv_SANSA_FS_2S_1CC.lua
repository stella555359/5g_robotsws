-- Copyright (c) 2019 Nokia. All rights reserved.

-----------------------------------------------------------------------------------------------------
--VARIABLES
-----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
DAEMON_PORT="22222"
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
AMF2_NG_ADDR="10.0.1.61"
UPF2_ADDR="1.2.5.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"


---- Variables for NSA configuration

ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.112"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"
SGW2_S1U_ADDR="10.0.1.138"
SGW2_S11_ADDR="10.0.1.139"
ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.207"
PGW2_ADDR="4.7.244.207"
PDN2_IP="4.7.244.208"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"

-----------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_enb  id=1  plmn=311:489  s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346  daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated  x2_peers=none')
exec('enb_param  id=1  drb_id_begin=3  endc_capable_qci=9')
exec('set_cell  id=1  enb=1  eci=0x1234601  pci=3:2  tac=222  proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889  earfcn=2000:20000  mapped_earfcn=4200:22200  tdd_cell=on  mandatory_for_activation=off')
exec('enb_endc_param  id=1  control_flow_period=3gpp1  use_nr_ran_cont=on')

-----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('mme_pool_area  id=1  mmegi=1  plmn=311:489  tac_list=777,111,222,444,333,200')
exec('set_mme  id=1  ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412  supported_rat=lte,nblte  pool=1:1')
exec('set_sgw  id=1  ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100  s5u_snd_buff_size=20M  s5u_rcv_buff_size=20M  s1u_snd_buff_size=20M  s1u_rcv_buff_size=20M  gtpu_read_packets_threshold=10')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..'                 s11='..SGW2_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M                 s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw  id=1  type=simulated  ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16  apn=lteapn1.com.mnc69.mcc450.gprs  devtype=tun  devname=tunLTEA13  sgi_rcv_buff_size=20M  sgi_snd_buff_size=20M  s5u_rcv_buff_size=20M  s5u_snd_buff_size=20M  gtpu_read_packets_threshold=10')
exec('set_pgw  id=2 type=simulated  ip='..DAEMON_IP..':'..DAEMON_PORT..'                  addr='..PGW2_ADDR..'/16 apn=lteapn2.com.mnc69.mcc450.gprs  devtype=tun  devname=tunLTEA2                 sgi_rcv_buff_size=20M  sgi_snd_buff_size=20M gtpu_read_packets_threshold=10')

-----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_amf_region  id=1  tac_list=7627107,100,788,200,0  plmn=311:489')
exec('set_amf_region  id=2  tac_list=7627107,100,788,201,0  plmn=311:490')
exec('set_amf  id=1  daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412  region=1  set_id=2  pointer=2')
exec('set_amf  id=2  daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412  region=2  set_id=3  pointer=3')
exec('amf_param  id=1  full_nas_auth=on  nia=null+zuc  nea=null+zuc')
exec('amf_param  id=2  full_nas_auth=on  nia=null+zuc  nea=null+zuc')
exec('set_upf  id=1  daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated  addr='..UPF_ADDR..'/24  ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M  ngu_rcv_buff_size=20M  ngu_read_packets_threshold=10')
exec('set_upf  id=2  daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated                   addr='..UPF2_ADDR..'/24  ngu='..AMF2_NG_ADDR..' devname=tunUPF2 ngu_snd_buff_size=20M                   ngu_rcv_buff_size=20M  ngu_read_packets_threshold=10')
--add ims_voice_3gpp support

--exec('amf_param  id=1  ims_voice_3gpp=on  full_nas_auth=on')
-----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_gnb  id=2  type=external  plmn=311:489  s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422  ng='..GNB_NG_ADDR..' gnb_id=0x76C  daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none  amf=1-2  plmnList=311:489,311:490  nssai=0x1:0xd143a5')
exec('set_cell  id=1  gnb=2  nr_arfcn=636666:636666  gscn=7880  eci=0x000021f  pci=16:2  tac=200  proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  nrci=0x01  tdd_cell=on  mandatory_for_activation=off')
exec('set_cell  id=2  gnb=2  nr_arfcn=636666:636666  gscn=7880  eci=0x000021f  pci=17:0  tac=201  proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888  nrci=0x02  tdd_cell=on  mandatory_for_activation=off')
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_uec  id=1  daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152  retries=unlimited  gtpu=off  pdn=1  devtype=tun  devname=tunUEC  addr=72.22.0.1/26  proxy_snd_buf_size=20971520  proxy_rcv_buf_size=20971520  proxy_read_packets_threshold=10')
-----------------------------------------------------------------------------------------------------
--UE CONFIGURATION
-----------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 40
FIRST_UE_NSA_CELL_1 = 41
END_UE_NSA_CELL_1 = 50
FIRST_UE_SA_CELL_2 = 101
END_UE_SA_CELL_2 = 140
FIRST_UE_NSA_CELL_2 = 141
END_UE_NSA_CELL_2 = 150
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 =                 21645700
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
	exec('set_ue  simulated  id='..UEID..'  uec=1  release=15  idle_edrx_cycle_len=2  ptw=2.56  opc_key=0ED47545168EAFE2C39C075829A7B61F  nia=null+zuc+aes+snow3g  nea=null+zuc+aes+snow3g  sec_key=0102030405060708090A0B0C0D0EFF00  mode=nr  enb=2                                cell=1 suci=0:311:489:0000:0:0:0'..IMSI_1 + UEID - 1)
	exec('ue_param  id='..UEID..'  ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0')
end
for gw_id = 1, 40 do
	exec('set_pdu_gateway  id='..gw_id..'  ue_nat_ip=72.23.'..gw_id..'.1  dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
	exec('set_ue  simulated  id='..UEID..'  uec=1  release=15  idle_edrx_cycle_len=2  ptw=2.56  opc_key=0ED47545168EAFE2C39C075829A7B61F  nia=null+zuc+aes+snow3g  nea=null+zuc+aes+snow3g  sec_key=0102030405060708090A0B0C0D0EFF01  mode=nr  enb=2                                cell=2 suci=0:311:490:0000:0:0:0'..IMSI_3 + UEID - 1)
	exec('ue_param  id='..UEID..'  ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0')
end
for gw_id = 101, 140 do
	exec('set_pdu_gateway  id='..gw_id..'  ue_nat_ip=72.23.'..gw_id..'.2  dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end
for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do
	exec('set_ue  simulated  id='..UEID..'  uec=1  release=15  idle_edrx_cycle_len=2  ptw=2.56  sec_key=0102030405060708090A0B0C0D0EFF00  nia=null+zuc+aes+snow3g  nea=null+zuc+aes+snow3g  eia=null+zuc+aes+snow3g  eea=null+zuc+aes+snow3g  imsi=311:489:'.. IMSI_2 + UEID - 1)
	exec('set_bearer  id=2  ue='..UEID..'  qci=9  pdn=1  ip=4.7.254.'..UEID..' default=on  ul_nat_gw='..SERVER_IP..'  dl_nat_gw='..SERVER_IP..'  trf_type=internal')
	exec('ue_param  id='..UEID..'  ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0  dual_conn=eutra_nr  ue_eutra_nr_capabilities=010C040160801C4D00000000402404D0002000201008010020')
end
for UEID = FIRST_UE_NSA_CELL_2, END_UE_NSA_CELL_2 do
	exec('set_ue  simulated  id='..UEID..'  uec=1  release=15  idle_edrx_cycle_len=2  ptw=2.56  sec_key=0102030405060708090A0B0C0D0EFF00  nia=null+zuc+aes+snow3g  nea=null+zuc+aes+snow3g  eia=null+zuc+aes+snow3g  eea=null+zuc+aes+snow3g  pdn=2 imsi=311:489:'.. IMSI_4 + UEID - 1)
	exec('set_bearer  id=2  ue='..UEID..'  qci=9  pdn=2  ip=4.7.244.'..UEID..'  default=on  ul_nat_gw='..SERVER_IP..'  dl_nat_gw='..SERVER_IP..'  trf_type=internal')
	exec('ue_param  id='..UEID..'  ue_nr_capabilities=e1a00000074e5a031e000380a03c1260c8000878180c4034026010180e01951b0a3582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b133582028680965944c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b137582028688965954c043d6c10101070ef1c39061c00103278fab80027800e0009e00151b13b582028680965944c043d6c10101070ef1c39061c00103278faa8000028000000841c4d00000000202682807008089ec1601800140e0601c0c01601c001a0f8000000000000395340004000025965400d2aba0207000b000000040080118b130001020304050607080b101112131921252627284a0  dual_conn=eutra_nr  ue_eutra_nr_capabilities=010C040160801C4D00000000402404D0002000201008010020')
end
-----------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('set_qosflow  id=1  5qi=6  default=on')

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1,2 default=on ue=all')

--exec('set_qosflow  id=2  5qi=5')
--exec('set_qosflow  id=3  5qi=1')
--exec('set_qosrule  id=1  proto=tcp    qos_flow=2')

--exec('set_qosrule  id=2  proto=udp  qos_flow=3')
--exec('nwslice_set  id=1  qos_flows=1,2,3  qos_rules=1,2  snssai=0x01:0xD143A5  default=on  ue=all  amf=1')

-----------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
-----------------------------------------------------------------------------------------------------
exec('uec_param  id=1  reordering_window_size=1000  reordering_timer=200')

-----------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47                  NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('smf_upf_mapping id=1 upf=1 id=2 upf=2')
--exec('sim_debug_log  level=4  mme=1')
exec('debug_log  level=5')
--exec('sim_debug_log  level=4  uec=1')
--exec('sim_debug_log  level=4  pgw=1')
exec('link_ctrl_param  hb_period=5  hb_retries=5')
--exec('sim_debug_log  level=4  sgw=1')
--exec('trace  uec=1  protocol=rrc  on')
--exec('trace  uec=1  protocol=nr_rrc  on')
--exec('trace  enb=1  protocol=x2  on')
--exec('trace  uec=1  protocol=x2  on')
--exec('sim_trace  uec=1  protocol=nr_rrc  on')
--exec('sim_trace  amf=1  protocol=ng  on')
exec('cfg_end')
--exec('sim_param_set  NR_PDCP_CIPHERING=distributed')

exec('set_log  log_to_file=on')
exec('sim_start  version_check=off')
