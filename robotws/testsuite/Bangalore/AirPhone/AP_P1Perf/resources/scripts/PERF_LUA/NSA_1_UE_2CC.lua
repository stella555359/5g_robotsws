# Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
--SERVER_IP2="10.0.2.4"
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
--AMF2_NG_ADDR="10.0.1.61"

UEC_ADDR="72.22.0.1"

--UEC2_ADDR="72.24.0.1"
UPF_ADDR="1.2.4.1"
--UPF2_ADDR="1.2.5.1"


EDAEMON_PORT="22222"

--Variables for NSA configuration
ENB1_S1_ADDR="10.0.1.136"
GNB_S1U_ADDR="10.0.1.2"

ENB1_X2_ADDR="10.0.1.137"
GNB_X2_ADDR="10.0.1.2"



MME1_S1_ADDR="10.0.1.131"

SERVER_ADDR="10.0.1.132"
SGW_S1U_ADDR="10.0.1.133"
SGW_S11_ADDR="10.0.1.134"
SGW2_S1U_ADDR="10.0.1.121"
SGW2_S11_ADDR="10.0.1.138"



PGW_ADDR="4.7.254.254"
PGW2_ADDR="4.7.252.254"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"
PDN_IP_2="4.7.252.208"

--iwf config

GNB_NGU_ADDR="10.0.2.150"
ENB_X2U_ADDR="10.0.2.103"
ENB1_S1U_ADDR="10.0.2.103"
SGW_S11U="10.0.2.102"
UPF_NGU_ADDR="10.0.2.100"
UEC_PEERUPLANE="10.0.2.101"
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..'  s1u='..ENB1_S1U_ADDR..'   type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_NGU_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' ngu='..GNB_NGU_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xD143A5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=643330:643330 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=649994:649994 mandatory_for_activation=off')
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
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..UPF_NGU_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('smf_upf_mapping id=1 upf=1')
exec('smf_param id=1  max_pdu_session_supported=2000')


----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 peer_uplane='..UEC_PEERUPLANE..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 50
FIRST_UE_NSA_CELL_1 = 51
END_UE_NSA_CELL_1 = 100
FIRST_UE_SA_CELL_3 = 101
END_UE_SA_CELL_3 = 150
FIRST_UE_NSA_CELL_3 = 151
END_UE_NSA_CELL_3 = 200
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700
QOS_ID = 2


for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1203FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F0000ABBE26FBC5E10EC5F0410FEA804416CA8E80624FAC41E420F081425BE7E02BBF8EF800EFE3BE00026028003A1FCC000005C07C0050006038180603105C060007000603E0288200100000104002000022080040100041000802008820000004100000200B2A6F2A68020800004B2CA82000032CB2A00A9565D2ACA0247005F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E0003161200040C0E26363E4A4E52EE000000040 dual_conn=eutra_nr ue_eutra_nr_capabilities=A18FF02F858100713420000103D1903F130200E268006134000240F4640801809A0084D001C81429D0B649F0224E853B649F00007010C60E00420C01008020100402008041C0080180200300600A0100108180201004020080401008380500300A006018014030020700A002018004028008060018')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.254.'..UEID-150)
end 

for UEID = FIRST_UE_NSA_CELL_3, END_UE_NSA_CELL_3 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+zuc+aes+snow3g eea=null+zuc+aes+snow3g nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g imsi=311:489:'.. IMSI_4 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1203FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F0000ABBE26FBC5E10EC5F0410FEA804416CA8E80624FAC41E420F081425BE7E02BBF8EF800EFE3BE00026028003A1FCC000005C07C0050006038180603105C060007000603E0288200100000104002000022080040100041000802008820000004100000200B2A6F2A68020800004B2CA82000032CB2A00A9565D2ACA0247005F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E0003161200040C0E26363E4A4E52EE000000040 dual_conn=eutra_nr ue_eutra_nr_capabilities=A18FF02F858100713420000103D1903F130200E268006134000240F4640801809A0084D001C81429D0B649F0224E853B649F00007010C60E00420C01008020100402008041C0080180200300600A0100108180201004020080401008380500300A006018014030020700A002018004028008060018')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.2.'..UEID-240)
end



--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')

--add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=128 default=off')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
--exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')
exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai=0x01:0xD143A5 default=on ue=all amf=1')

---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
--------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')

exec('debug_log level=5')
--exec('sim_debug_log level=4 mme=1')
--exec('sim_debug_log level=4 pgw=1')
--exec('sim_debug_log level=4 uec=1')
--exec('sim_debug_log level=4 sgw=1')
--link_ctrl_param use_hb=off
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('trace enb=1 protocol=x2 on')
exec('trace uec=1 protocol=rrc,nr_rrc on')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
