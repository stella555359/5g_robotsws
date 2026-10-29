-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP

DAEMON_PORT=22222

PROXY_SERVER_IP="10.0.2.80"

AMF_NG_ADDR="10.0.1.1"


UPF_ADDR="1.2.4.1"

EDAEMON_PORT="22222"

ENB1_S1U_ADDR="10.0.2.103"

ENB1_S1_ADDR="10.0.1.136"
ENB1_X2_ADDR="10.0.1.137"


GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"



PGW_ADDR="4.7.0.254"

--IWF Config

ENB_X2U_ADDR="10.0.2.103"
ENB1_S1U_ADDR="10.0.2.103"
SGW_S11U="10.0.2.102"
GNB_NGU_ADDR="10.0.2.150"
UPF_NGU_ADDR="10.0.2.100"
UEC_PEERUPLANE="10.0.2.101"
--------------------------------------------------------------------------------------------------
exec('set_qci qci=128 gbr=no priority=1 delay=80')
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' s1u='..ENB1_S1U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9,128')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_NGU_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' ngu='..GNB_NGU_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xD143A5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17: tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=643330:643330 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x02 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 s11='..SGW_S11U..':57973 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S11U..' s11='..SGW_S11U..':60100 s11u='..SGW_S11U..':57972 s5='..SGW_S11U..':60518 s5u='..SGW_S11U..':60519 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/16 s5='..SGW_S11U..':60520 s5u='..SGW_S11U..':60521 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/21 ngu='..UPF_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('smf_upf_mapping id=1 upf=1')
exec('smf_param id=1 max_pdu_session_supported=2000')

----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 peer_uplane='..UEC_PEERUPLANE..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_1 = 101
END_UE_SA_CELL_1 = 252
FIRST_UE_NSA_CELL_1 = 1
END_UE_NSA_CELL_1 = 10
FIRST_UE_SA_CELL_3 = 253
END_UE_SA_CELL_3 = 404
FIRST_UE_NSA_CELL_2 = 51
END_UE_NSA_CELL_2 = 60
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
   exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
   exec('ue_param id='..UEID..' ue_nr_capabilities=F5A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E380A517C46FF9BCA3BC857C1043E59496201105B29BA00873EB0CF90E7C245176F9F8053FF4FFCA2F831FF37947790AF82087CB292C40220B65374010E7D619F21CF848A2EDF3F00A7FE9FF945F0BFFE6F28EF215F0410F96525C801105B29BA00873EB0CF90E7C245176F9F805BFFFFDBFFFFCA2F883FF37944215F0410F965258804416CA6E8021CFAC33E439F09145DBE7E014FFD3FF28BE147FCDE510C01F0000096525C801105B29BA00873EB0CF90E7C245176F9F805BFFFFDBFFFFCA2F89BFF379443007C00002594972004416CA6E8020C7AC33E439F09145DBE7E016FFFFF6FFFFF0850F830001C28000E140007134000003FCFFFFFFFFFA85C18000E14041713400001BFCFFFFFFFFFA89C28000E14000710400388C001C4D000004FF3FFFFFFFFEA1F0A020B882001C46000E268000047F9FFFFFFFFF50389A186005FE7FFFFFFFFD41E1780070BC20802BFCFFFFFFFFFA83C2F000E178208057F9FFFFFFFFF50F830001C28000E208007118000033FCFFFFFFFFF804808D0106026C02880300A9BC111A340810367BF0E246810367BF0E4408D02040D9EFC38D0204081B3DF870236CF7E1C2810367BF0E14081B3DF871A040810367BF0C0034200000000607FFFC0001601F00140E060180C416018001E0E801C0C0301800010000180280301F01EC9000000AC90000022C90000042C90000062C90000082C900000A2C9000802010B24004018060180158135943593B5953580B593340764000004B292B20000225949590000212CA4AC8000189652564000104AE92B20000A2594959004010084B292B2010060180625961405502AAA515549EAA9555301299334047A00FE49C0792701E4940793501407935014079350140793501407935014000618080100202008010080300602010020004040082008020040200C018080500A02014028080400820100200404038070100801060201C038080500A020140280804008101008010040380718080100202008010080500A0201402840')
end

for UEID = FIRST_UE_SA_CELL_3, END_UE_SA_CELL_3 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g     	    sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=F5A03C0047D4FFBEFFFFBAF0140782E0203C126BE7FFF6F800609B3CE3FF30C7942C020DC0407E380A517C46FF9BCA3BC857C1043E59496201105B29BA00873EB0CF90E7C245176F9F8053FF4FFCA2F831FF37947790AF82087CB292C40220B65374010E7D619F21CF848A2EDF3F00A7FE9FF945F0BFFE6F28EF215F0410F96525C801105B29BA00873EB0CF90E7C245176F9F805BFFFFDBFFFFCA2F883FF37944215F0410F965258804416CA6E8021CFAC33E439F09145DBE7E014FFD3FF28BE147FCDE510C01F0000096525C801105B29BA00873EB0CF90E7C245176F9F805BFFFFDBFFFFCA2F89BFF379443007C00002594972004416CA6E8020C7AC33E439F09145DBE7E016FFFFF6FFFFF0850F830001C28000E140007134000003FCFFFFFFFFFA85C18000E14041713400001BFCFFFFFFFFFA89C28000E14000710400388C001C4D000004FF3FFFFFFFFEA1F0A020B882001C46000E268000047F9FFFFFFFFF50389A186005FE7FFFFFFFFD41E1780070BC20802BFCFFFFFFFFFA83C2F000E178208057F9FFFFFFFFF50F830001C28000E208007118000033FCFFFFFFFFF804808D0106026C02880300A9BC111A340810367BF0E246810367BF0E4408D02040D9EFC38D0204081B3DF870236CF7E1C2810367BF0E14081B3DF871A040810367BF0C0034200000000607FFFC0001601F00140E060180C416018001E0E801C0C0301800010000180280301F01EC9000000AC90000022C90000042C90000062C90000082C900000A2C9000802010B24004018060180158135943593B5953580B593340764000004B292B20000225949590000212CA4AC8000189652564000104AE92B20000A2594959004010084B292B2010060180625961405502AAA515549EAA9555301299334047A00FE49C0792701E4940793501407935014079350140793501407935014000618080100202008010080300602010020004040082008020040200C018080500A02014028080400820100200404038070100801060201C038080500A020140280804008101008010040380718080100202008010080500A0201402840')
end

--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')
exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')

---------------------------------------------------------------------------------------------------
--Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('sim_param_set NR_PDCP_TRUNCATE_DL_SIZE=47')
exec('sim_param_set NR_PDCP_BUNDLE_DL_MAX_SIZE=1200')
exec('sim_param_set NR_PDCP_BUNDLE_DL_TIMEOUT=100')

---------------------------------------------------------------------------------------------------

exec('debug_log level=5')

--exec('debug_log level=0')
--exec('sim_debug_log level=4 mme=1')
--exec('sim_debug_log level=4 pgw=1')
--exec('sim_debug_log level=1 uec=1')
--exec('sim_debug_log level=1 uec=2')
--exec('sim_debug_log level=1 uec=3')
--exec('sim_debug_log level=1 uec=4')
--exec('sim_debug_log level=1 uec=5')
--exec('sim_debug_log level=1 uec=6')
--exec('sim_debug_log level=4 sgw=1')
--exec('sim_debug_log level=4 enb=1')
--exec('sim_debug_log level=1 app_type=ueproxy')
--exec('trace enb=1 protocol=x2 on')
--exec('trace uec=1-6 protocol=x2 on')
--exec('trace uec=1 protocol=rrc,nr_rrc on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1-2 protocol=ng on')
--link_ctrl_param use_hb=off
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
