# Copyright (c) 2019 Nokia. All rights reserved.

----------------------------------------------------------------------------------------------------
--VARIABLES
----------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.1"
DAEMON_IP=CONTAINER_IP
SERVER_IP=CONTAINER_IP
SERVER_IP2="10.0.2.4"
DAEMON_PORT=22222
GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
AMF2_NG_ADDR="10.0.1.61"
UEC_ADDR="72.22.0.1"
UEC2_ADDR="72.24.0.1"
UPF_ADDR="1.2.4.1"
UPF2_ADDR="1.2.5.1"
AMF4_NG_ADDR="10.0.1.63"
AMF3_NG_ADDR="10.0.1.62"
UPF4_ADDR="1.2.7.1"
UPF3_ADDR="1.2.6.1"

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

ENB_X2U_ADDR="10.0.1.135"
PGW_ADDR="4.7.254.254"
PGW2_ADDR="4.7.252.254"

PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"
PDN_IP_2="4.7.252.208"

SERVER_IP7="10.0.2.8"
SERVER_IP8="10.0.2.9"
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
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1-2 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=650000:650000 mandatory_for_activation=off')
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn=311:489 tac_list=777,111,222,444,333,200')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..' s11='..SGW2_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')


exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/24 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=2 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW2_ADDR..'/24 apn=lteapn2.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA2 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on')
exec('set_upf id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' devname=tunUPF ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

exec('set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region=2 set_id=3 pointer=3')
exec('amf_param id=2 full_nas_auth=on')
exec('set_upf id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/24 ngu='..AMF2_NG_ADDR..' devname=tun2UPF ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

exec('smf_upf_mapping id=1 upf=1 id=2 upf=2')
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 peer_uplane='..SERVER_IP7..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr=72.22.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20')

exec('set_uec id=2 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP2..':2152 peer_uplane='..SERVER_IP8..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tun2UEC addr=72.24.0.1/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')

---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
FIRST_UE_SA_CELL_1 = 1
END_UE_SA_CELL_1 = 50
FIRST_UE_NSA_CELL_1 = 51
END_UE_NSA_CELL_1 = 100
FIRST_UE_SA_CELL_2 = 101
END_UE_SA_CELL_2 = 110
FIRST_UE_NSA_CELL_2 = 111
END_UE_NSA_CELL_2 = 120
IMSI_1 = 21645400
IMSI_2 = 21645500
IMSI_3 = 21645600
IMSI_4 = 21645700
QOS_ID = 2

for UEID = FIRST_UE_SA_CELL_1, END_UE_SA_CELL_1 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_1 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F1C02ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBB8EF800EEE3BE00026028003A1577C4DFF8BC21D8BE0821FD500883D951D220624FAC41E420F081425BE7E67771DF001DDC77C0004C05000742AEF89BFF17843B17C1043FAA01107B2A3A440C49F5883C841E10284B7CFCAEFE3FE003BF8FF8000980A000E803281C4D000000620540E268000013102B0713420001188150389A10000CC40AC1C4D080008620541E268006134000A620400404D0547E06811B649F02042D927C0811B649F02042D927C0813B649F021429DB24F800160C318C631BFFFE0000B80D800A000C070300E0620B80E000E000C07C09104000000820000044100080000082001000011040020080020800401004410008040108200100803104002018042080040300C0360EDE54D60EDE54D00C1000009659504000065965410000296594040000E5965003507CBA559541F2E95650139804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0700001400600400C0100200180100700401000E00C00C0200180500500C00800E00C01C0200380500900C01000E01C00C0400180900501400820E00400C008018020050040081C00800802001002002008000D583010390929313943B80000001808')
   for gw_id = 1, 255 do
       exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end   
end  

for UEID = FIRST_UE_NSA_CELL_1, END_UE_NSA_CELL_1 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_2 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1203FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F0000ABBE26FBC5E10EC5F0410FEA804416CA8E80624FAC41E420F081425BE7E02BBF8EF800EFE3BE00026028003A1FCC000005C07C0050006038180603105C060007000603E0288200100000104002000022080040100041000802008820000004100000200B2A2F2A28020800004B2CA82000032CB2A00A9555D2AAA0247005F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E0003161200040C0E26363E4A4E52EE000000040 dual_conn=eutra_nr ue_eutra_nr_capabilities=A18FF02F858100713420000103D1903F130200E268006134000240F4640801809A0084D001C81429D0B649F0224E853B649F00007010C60E00420C01008020100402008041C0080180200300600A0100108180201004020080401008380500300A006018014030020700A002018004028008060018')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.254.'..UEID-160)
end 

for UEID = FIRST_UE_SA_CELL_2, END_UE_SA_CELL_2 do
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_3 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1A03FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F1C02ABBE26FFC5E10EC5F0410FEA80441ECA8E9103127D620F2107840A12DF3F2BBB8EF800EEE3BE00026028003A1577C4DFF8BC21D8BE0821FD500883D951D220624FAC41E420F081425BE7E67771DF001DDC77C0004C05000742AEF89BFF17843B17C1043FAA01107B2A3A440C49F5883C841E10284B7CFCAEFE3FE003BF8FF8000980A000E803281C4D000000620540E268000013102B0713420001188150389A10000CC40AC1C4D080008620541E268006134000A620400404D0547E06811B649F02042D927C0811B649F02042D927C0813B649F021429DB24F800160C318C631BFFFE0000B80D800A000C070300E0620B80E000E000C07C09104000000820000044100080000082001000011040020080020800401004410008040108200100803104002018042080040300C0360EDE54D60EDE54D00C1000009659504000065965410000296594040000E5965003507CBA559541F2E95650139804F9BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C070079BF01C0700001400600400C0100200180100700401000E00C00C0200180500500C00800E00C01C0200380500900C01000E01C00C0400180900501400820E00400C008018020050040081C00800802001002002008000D583010390929313943B80000001808')
   for gw_id = 1, 255 do
      exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.23.'..UEID..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--      UEID1=UEID-320
--      exec('set_pdu_gateway id='..gw_id..' ue_nat_ip=72.24.'..UEID1..'.1 dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
   end
end

for UEID = FIRST_UE_NSA_CELL_2, END_UE_NSA_CELL_2 do        
    exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 sec_key=0102030405060708090A0B0C0D0EFF00 eia=null+snow3g+aes eea=null imsi=311:489:'.. IMSI_4 + UEID - 1)
    exec('ue_param id='..UEID..' ue_nr_capabilities=E1203FA0474E7AEFFFFFAFC0A03C170101E093DF3FFFFFC003818DF7C000A06E0203F0000ABBE26FBC5E10EC5F0410FEA804416CA8E80624FAC41E420F081425BE7E02BBF8EF800EFE3BE00026028003A1FCC000005C07C0050006038180603105C060007000603E0288200100000104002000022080040100041000802008820000004100000200B2A2F2A28020800004B2CA82000032CB2A00A9555D2AAA0247005F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E00F37E0380E0003161200040C0E26363E4A4E52EE000000040 dual_conn=eutra_nr ue_eutra_nr_capabilities=A18FF02F858100713420000103D1903F130200E268006134000240F4640801809A0084D001C81429D0B649F0224E853B649F00007010C60E00420C01008020100402008041C0080180200300600A0100108180201004020080401008380500300A006018014030020700A002018004028008060018')
	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 ip=4.7.254.'..UEID..' default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP)
--	exec('set_bearer id=2 ue='..UEID..' qci=9 pdn=1 default=on trf_type=internal dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..' ip=4.7.254.'..UEID-400)
end

--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1,2 default=on ue=all')

---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled')
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
--exec('trace uec=1 protocol=rrc,nr_rrc on')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')

