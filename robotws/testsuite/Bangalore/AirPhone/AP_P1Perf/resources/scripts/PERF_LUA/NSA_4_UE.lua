-- Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
SERVER_IP2="10.0.2.3"
SERVER_IP3="10.0.2.4"
SERVER_IP4="10.0.2.5"
SERVER_IP5="10.0.2.6"
SERVER_IP6="10.0.2.7"

SERVER_IP7="10.0.2.8"
SERVER_IP8="10.0.2.9"
SERVER_IP9="10.0.2.10"
SERVER_IP10="10.0.2.11"
SERVER_IP11="10.0.2.12"
SERVER_IP12="10.0.2.13"

DAEMON_PORT=22222

PROXY_SERVER_IP="10.0.2.80"

AMF_NG_ADDR="10.0.1.1"
AMF2_NG_ADDR="10.0.1.61"
AMF3_NG_ADDR="10.0.1.62"
AMF4_NG_ADDR="10.0.1.63"
AMF5_NG_ADDR="10.0.1.64"
UEC_ADDR="72.21.0.1"
UEC2_ADDR="72.22.0.1"
UEC3_ADDR="72.23.0.1"
UEC4_ADDR="72.24.0.1"
UEC5_ADDR="72.25.0.1"
UEC6_ADDR="72.26.0.1"

UPF_ADDR="1.2.4.1"
UPF2_ADDR="1.2.5.1"
UPF3_ADDR="1.2.6.1"
UPF4_ADDR="1.2.7.1"
UPF5_ADDR="1.2.8.1"

EDAEMON_PORT="22222"

ENB1_S1_ADDR="10.0.1.136"
ENB1_X2_ADDR="10.0.1.137"

GNB_S1U_ADDR="10.0.1.2"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

MME1_S1_ADDR="10.0.1.131"

SGW_S1U_ADDR="10.0.1.132"
SGW_S11_ADDR="10.0.1.133"

PGW_ADDR="4.7.0.254"
PDN_IP="4.7.0.253"


--IWF Config

ENB_X2U_ADDR="10.0.2.103"
ENB1_S1U_ADDR="10.0.2.103"
SGW_S11U="10.0.2.102"
GNB_NGU_ADDR="10.0.2.150"
UPF_NGU_ADDR="10.0.2.100"
UEC_PEERUPLANE="10.0.2.101"

---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_enb id=1 plmn=311:489 s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' s1u='..ENB1_S1U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac=222 proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_NGU_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' ngu='..GNB_NGU_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xD143A5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=643330:643330 mandatory_for_activation=off')
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
FIRST_UE_NSA_CELL_1 = 1
END_UE_NSA_CELL_1 = 10
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700
QOS_ID = 2


for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E120700047D0FFB17DE8E6BC0A03406939F3489E7C003018807C07C0203F000B6F3800007BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C19BCE00401EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F066F380D807BDEB70D0645020E0000075C0228B64B540B027C873E808F18E7CC31E50B0381C3C1BBCF89A01EF7ADC341914083800001D7008A2D92D502C09F21CFA023C639F30C7942C0E070F0527FC9FF0620D940001400000DE700400F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C01803DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE700700F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C04C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702500F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C09C03DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0CDE702800F7BD6E1A0C8A041C00000EB804516C96A81604F90E7D011E31CF9863CA1607038783379C13003DEF5B8683228107000003AE01145B25AA05813E439F40478C73E618F28581C0E1E0DFC0000005807C005638180703F0500703E001CB400001C0001CA9A0003000008300000795414040E001E006A054000810181C4C040C2C4044486430606C7D0494989CA091520 dual_conn=eutra_nr ue_eutra_nr_capabilities=A10CF11A118000203040C081C389A00000008723A110003030040C081C389A00000408723A11000203060C0081C389A0000080872320D8000203240C5C4D0000064641A00060640818B89A0000108C83400080C9831071340000291D06800101830700E26800006023F2320D800020304061C4D00000E4641A0006060080C389A0000208C8260000800389A0000248E8160041C4D00001404391D08C0C01030206040E1C4D00000004391D0880C18300206040E1C4D00000204391D06C0C010182060E26800007021C8E83406080C18300713400005810E46413032040E1C4D0000184641203260E01C4D00001A460160268000060180384D17780BE88C80085B1CF87200216C73E1C80085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8718085B1CF8710216C73E1C2216C73E1C80085B1CF87200216C73E1C60216C73E1C60216C73E1C4085B1CF8710216C73E181508800000000000000000091100000009110000000D1100000000006034800010100004000001000000800020040090000200000080800020000010000400801200004000001000000404000200008010023000080800060000018000400801180004000003010000C0002004008C000200000180000060201002004600010000004000002010080100230000808000200000080004008011800040000010100004000200400880002020000800040080108000C0402004008C0002000000800000202010020044000301000080002004008800060000010080400801')
    exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
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
