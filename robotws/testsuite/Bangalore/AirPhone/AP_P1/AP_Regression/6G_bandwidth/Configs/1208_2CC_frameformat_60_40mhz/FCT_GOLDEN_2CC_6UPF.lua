# Copyright (c) 2024 Nokia. All rights reserved.
---------------------------------------------------------------------------------------------------
--VARIABLES
---------------------------------------------------------------------------------------------------
CONTAINER_IP="10.0.2.80"
SERVER_IP=CONTAINER_IP

DAEMON_IP=CONTAINER_IP
DAEMON_PORT="22222"

PROXY_SERVER_IP="10.0.2.80"
UPLANE_SENDER_IP_ADDR="10.0.2.98"

GNB_S1U_ADDR="10.0.1.2"

-- AMF IP addresses
AMF_NG_ADDR="10.0.1.1"

-- UE NAT IP addresses
UE1_NAT_IP1="72.23.0.1"
UE1_NAT_IP2="72.23.0.2"
UE1_NAT_IP3="72.23.0.3"
UE1_NAT_IP4="72.23.0.4"
UE1_NAT_IP5="72.23.0.5"
UE1_NAT_IP6="72.23.0.6"


-- UPF IP addresses
UPF1_ADDR="1.2.4.1"
UPF2_ADDR="2.2.4.1"
UPF3_ADDR="3.2.4.1"
UPF4_ADDR="4.2.4.1"
UPF5_ADDR="5.2.4.1"
UPF6_ADDR="6.2.4.1"

UPF1_N3_ADDR="10.0.1.1"
UPF2_N3_ADDR="10.0.1.5"
UPF3_N3_ADDR="10.0.1.6"
UPF4_N3_ADDR="10.0.1.7"
UPF5_N3_ADDR="10.0.1.8"
UPF6_N3_ADDR="10.0.1.9"

---------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn=311:489 s1u='..GNB_S1U_ADDR..' gnb_id=0x01 x2_peers=none amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 nr_arfcn=670000:670000 gscn=8228 eci=0x000021f pci=16:2 tac=200 proxy='..UPLANE_SENDER_IP_ADDR..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x01 tdd_cell=on mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 nr_arfcn=663332:663332 gscn=8158 eci=0x000021f pci=17:0 tac=200 proxy='..UPLANE_SENDER_IP_ADDR..':2152|'..PROXY_SERVER_IP..':8888 nrci=0x02 tdd_cell=on mandatory_for_activation=off')
---------------------------------------------------------------------------------------------------
--CN CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
exec('set_amf id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2 type=external')
exec('set_upf id=1 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF1_ADDR..'/24 ngu='..UPF1_N3_ADDR..' devname=tunUPF1 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
exec('set_upf id=2 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF2_ADDR..'/24 ngu='..UPF2_N3_ADDR..' devname=tunUPF2 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
exec('set_upf id=3 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF3_ADDR..'/24 ngu='..UPF3_N3_ADDR..' devname=tunUPF3 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
exec('set_upf id=4 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF4_ADDR..'/24 ngu='..UPF4_N3_ADDR..' devname=tunUPF4 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
exec('set_upf id=5 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF5_ADDR..'/24 ngu='..UPF5_N3_ADDR..' devname=tunUPF5 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
exec('set_upf id=6 daemon='..DAEMON_IP..':'..DAEMON_PORT..' type=external addr='..UPF6_ADDR..'/24 ngu='..UPF6_N3_ADDR..' devname=tunUPF6 ngu_snd_buff_size=40M ngu_rcv_buff_size=40M ngu_read_packets_threshold=20 n6_read_packets_threshold=40')
---------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_uec id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' peer='..DAEMON_IP..':2152 retries=unlimited gtpu=off proxy_snd_buf_size=40971520 proxy_rcv_buf_size=40971520 proxy_read_packets_threshold=20')
---------------------------------------------------------------------------------------------------
--UE CONFIGURATION
---------------------------------------------------------------------------------------------------
--UE Id=1 SA
exec('set_ue id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+snow3g nea=null+zuc+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:021645400 mode=nr enb=2 cell=1')
exec('ue_param id=1 ue_nr_capabilities=FFA0F200475F7A6B5F83820140682002024107CC02024807031FFF800140F804060380750FC28DF981A150452CB2A20097BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE0D405002B66000F00066000F00002A1F883BF30342A08A596544012F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC1A80A0056CC001E000CC001E0000543F1337E606854114B2CA88025EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF83501400AD98003C00198003C0000A83E0C6FCC0D0A822965951004BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF06A028015B300078003300078000004A27130003882001C28000E0C00071300000015BF0000000020713000000FF0000000000C01880980A86405022E07FAF6E045C0FF5ED81C086307EFFFFFC1701F001E00180E0701E001C0FC1601E001806BB81C05800701AEE07016001C0800400000020010000003780322000000591000000A802C0DBCA9A0193C0000A596509E000152CB2A480001296595240000D4B2CA806A07174AAAA955D503BA00900401002010020040401002010020040401002000802006168250')
--UE Id=2 SA
exec('set_ue id=2 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B620 nia=null+zuc+snow3g nea=null+zuc+snow3g sec_key=0102030405060708090A0B0C0D0EFF01 suci=0:311:489:0000:0:0:021645401 mode=nr enb=2 cell=2')
exec('ue_param id=2 ue_nr_capabilities=FFA0F200475F7A6B5F83820140682002024107CC02024807031FFF800140F804060380750FC28DF981A150452CB2A20097BFF3039036FFFB7FFDBFFEDFFF6FFFB7FFDBFFE7FFFA7FFDF1F9F87FC7FFB7FFDBFFEDFFF6FFFB7FFDBFFEDFFF51804DFE7FEDFE7FE0D405002B66000F00066000F00002A1F883BF30342A08A596544012F7FE607206DFFF6FFFB7FFDBFFEDFFF6FFFB7FFCFFFF4FFFBE3F3F0FF8FFF6FFFB7FFDBFFEDFFF6FFFB7FFDBFFEA3009BFCFFDBFCFFC1A80A0056CC001E000CC001E0000543F1337E606854114B2CA88025EFFCC0E40DBFFEDFFF6FFFB7FFDBFFEDFFF6FFF9FFFE9FFF7C7E7E1FF1FFEDFFF6FFFB7FFDBFFEDFFF6FFFB7FFD460137F9FFB7F9FF83501400AD98003C00198003C0000A83E0C6FCC0D0A822965951004BDFF981C81B7FFDBFFEDFFF6FFFB7FFDBFFEDFFF3FFFD3FFEF8FCFC3FE3FFDBFFEDFFF6FFFB7FFDBFFEDFFF6FFFA8C026FF3FF6FF3FF06A028015B300078003300078000004A27130003882001C28000E0C00071300000015BF0000000020713000000FF0000000000C01880980A86405022E07FAF6E045C0FF5ED81C086307EFFFFFC1701F001E00180E0701E001C0FC1601E001806BB81C05800701AEE07016001C0800400000020010000003780322000000591000000A802C0DBCA9A0193C0000A596509E000152CB2A480001296595240000D4B2CA806A07174AAAA955D503BA00900401002010020040401002010020040401002000802006168250')
---------------------------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosrule id=1 proto=udp qos_flow=1')
exec('set_qosrule id=2 proto=tcp qos_flow=1')
exec('set_nwslice id=1 snssai=0x01:0xd143a5 amf=1 default=on ue=all')
exec('set_pdu_gateway id=1 ue_nat_ip='..UE1_NAT_IP1..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF1_ADDR)
exec('set_pdu_gateway id=2 ue_nat_ip='..UE1_NAT_IP2..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF2_ADDR)
exec('set_pdu_gateway id=3 ue_nat_ip='..UE1_NAT_IP3..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF3_ADDR)
exec('set_pdu_gateway id=4 ue_nat_ip='..UE1_NAT_IP4..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF4_ADDR)
exec('set_pdu_gateway id=5 ue_nat_ip='..UE1_NAT_IP5..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF5_ADDR)
exec('set_pdu_gateway id=6 ue_nat_ip='..UE1_NAT_IP6..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..UPF6_ADDR)


exec('set_pdu_param ue=1 pdu=1 trf_type=internal')
exec('set_pdu_param ue=1 pdu=2 trf_type=internal')
exec('set_pdu_param ue=1 pdu=3 trf_type=internal')
exec('set_pdu_param ue=1 pdu=4 trf_type=internal')
exec('set_pdu_param ue=1 pdu=5 trf_type=internal')
exec('set_pdu_param ue=1 pdu=6 trf_type=internal')


---------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500')
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 uec=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=x2 on')
exec('trace uec=1 protocol=rrc')
exec('trace uec=1 protocol=nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
exec('sim_start version_check=off')
