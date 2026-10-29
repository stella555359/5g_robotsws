-- IP ADDRESSES FOR WTS NODES
local CONTAINER_IP="10.0.2.1"
local SERVER_IP="10.0.2.1"

local GNB_NG_ADDR="10.0.1.2"
local PROXY_SERVER_IP="10.0.2.80"
local AMF_NG_ADDR="10.0.1.1"
local UEC_ADDR="72.22.0.1"
local UPF_ADDR="10.12.2.1"

local DAEMON_IP="10.0.2.1"
local DAEMON_PORT="10000"

local ENB1_S1_ADDR="10.0.1.136"
local GNB_S1U_ADDR="10.0.1.112"

local ENB1_X2_ADDR="10.0.1.137"
local GNB_X2_ADDR="10.0.1.2"

local MME1_S1_ADDR="10.0.1.131"

local SERVER_ADDR="10.0.1.132"
local SGW_S1U_ADDR="10.0.1.133"
local SGW_S11_ADDR="10.0.1.134"


local ENB_X2U_ADDR="10.0.1.135"
local PGW_ADDR="4.7.254.207"

local PROXY_SERVER_IP="10.0.2.80"
local PDN_IP="4.7.254.208"

local PDN_IP11="4.7.254.211"

require('os')
os.execute('sudo ip addr add 10.0.1.131/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.132/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.133/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.134/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.135/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.136/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.137/24 dev eth3')
os.execute('sudo ip addr add 10.0.1.99/24 dev eth3')
os.execute('sudo ip addr add 10.0.2.99/24 dev eth4')
os.execute('sudo ip addr add 10.0.1.121/24 dev eth3')

-- LTE CONFIG
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 bw=10MHz enb=1 eci=0x1234601 pci=3:2 tac=200 proxy='..SERVER_IP..':12219 earfcn=68787:133323')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on serving_cell_index_range_scg=8:14')

-- NR CORE CONFIG
exec('set_amf_region id=1 tac_list=200,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null nea=null')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=8M ngu_rcv_buff_size=8M ngu_read_packets_threshold=10')

-- EXT GNB AND ITS CELLS
exec('set_gnb id=2 type=external plmn=311:489 x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=D7A4 daemon='..SERVER_IP..':'..DAEMON_PORT..' x2_peers=none xn='..GNB_X2_ADDR..' amf=1')
exec('set_cell id=1 gnb=2 pci=16:0 tac=200 nrci=0x3FFF tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135600:126400 mandatory_for_activation=off gscn=1565')
exec('set_cell id=2 gnb=2 pci=48:1 tac=200 nrci=0x3FFF tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=135600:126400 mandatory_for_activation=off gscn=1565')
exec('set_cell id=21 gnb=2 pci=125:0 tac=200 nrci=0x3FFF tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=381000:397000 mandatory_for_activation=off gscn=4961')
exec('set_cell id=22 gnb=2 pci=63:1 tac=200 nrci=0x3FFF tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=381000:397000 mandatory_for_activation=off gscn=4961')
exec('set_cell id=201 gnb=2 pci=3:0 tac=200 nrci=0x3FFF tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=528000:528000 mandatory_for_activation=off gscn=6501')
exec('set_cell id=211 gnb=2 pci=3:1 tac=200 nrci=0x3FFF tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=509058:509058 mandatory_for_activation=off gscn=6276')
exec('set_cell id=202 gnb=2 pci=83:1 tac=200 nrci=0x3FFF tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=528000:528000 mandatory_for_activation=off gscn=6501')
exec('set_cell id=212 gnb=2 pci=83:2 tac=200 nrci=0x3FFF tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=509058:509058 mandatory_for_activation=off gscn=6276')

-- 4G CORE CONFIG
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s1u_snd_buff_size=20971520 s1u_rcv_buff_size=20971520 gtpu_read_packets_threshold=0')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20971520 sgi_snd_buff_size=20971520 s5u_rcv_buff_size=20971520 s5u_snd_buff_size=20971520 gtpu_read_packets_threshold=0')

-- UE CONFIGURATION
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' peer='..DAEMON_IP..':2152 gtpu=off retries=unlimited proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 tun_read_packet_threshold=20 sctp_rto_min=400')
--
-- NRCELL 201 UE, TDD+FDD CA Capable, INACTIVITY ON
for i=1,9 do
		exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i)..':0:0:02164540'..(i).. ' enb=2 cell=201')
		exec('ue_param capability_file=/home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Main/config_59/skywatch_ue_nr_capa.cfg id='..i..' ue_nr_capabilities=SA_S24_CAPA_inact_OFF')
end
-- NRCELL 201 UE, TDD+FDD CA Capable
for i=10,99 do
		exec('set_ue simulated id='..i..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g+aes mode=nr nea=null sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:00'..(i)..':0:0:0216540'..(i).. ' enb=2 cell=201')
		exec('ue_param capability_file=/home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Main/config_59/skywatch_ue_nr_capa.cfg id='..i..' ue_nr_capabilities=SA_S24_CAPA')
end
--NSA_UES
for i=101,160 do
exec('set_ue simulated id='..i..
          ' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00'..
          ' nia=null nea=null eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g'..
          ' imsi=310:260:21645'..i)
     exec('ue_param capability_file=/home/ute/robotws/testsuite/Wroclaw/RRM/VRF_WRO1_T04/SKYWATCH/Main/config_59/skywatch_ue_nr_capa.cfg id='..i..
          ' ue_nr_capabilities=NSA_S23_UE_CAPA dual_conn=eutra_nr'..
          ' ue_eutra_nr_capabilities=NR_EUTRA_S23_CAPA')
     exec('set_bearer id=2 ue='..i..
          ' qci=9 pdn=1 ip=4.7.254.'..i..' default=on ul_nat_gw=10.0.2.1 dl_nat_gw=10.0.2.1 trf_type=internal')
end

--PDU GW FOR SA UE
for i=1,255 do
    exec('set_pdu_gateway id='..i..' ue_nat_ip=72.23.'..i..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
end

-- NETWORK SLICING AND QI
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0x0003e8 default=on ue=all amf=1')
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')

--exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=40,20,-40,-40')
--exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
--exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')

-- MISC
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('debug_log level=6')
exec('link_ctrl_param use_hb=off')
exec('trace uec=1 protocol=rrc off')
exec('trace uec=1 protocol=nr_rrc off')
exec('sim_trace uec=1 protocol=nr_rrc off')
exec('sim_trace amf=1 protocol=ng off')
exec('sim_trace uec=1 protocol=all off')
exec('sim_trace amf=1 protocol=all off')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')

sleep(10)
for i=1,99 do
    exec('set_pdu_param ue='..i..' pdu=1 trf_type=internal')
end
for i=1,99 do
    exec('set_pdu_param ue='..i..' pdu=2 trf_type=internal default_qos_flow=2')
end

sleep(240)
exec('enb_x2_link_up enb=1 target=2')
