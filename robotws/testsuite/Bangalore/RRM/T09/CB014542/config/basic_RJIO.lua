CONTAINER_IP="10.0.2.1"
SERVER_IP="10.0.2.1"
DAEMON_IP="10.0.2.1"

GNB_NG_ADDR="10.0.1.2"
PROXY_SERVER_IP="10.0.2.80"
AMF_NG_ADDR="10.0.1.1"
UEC_ADDR="72.22.0.1"
UPF_ADDR="1.2.4.1"
DAEMON_PORT="22222"
EPC_USER="ute"
EPC_USER_PASSWORD="ute"


PROXY_SERVER_IP="10.0.2.80"
PDN_IP="4.7.254.208"

SA_UE_CAPABILITIES_TDD="E1A01000014F7E0302C00284A00024100101808367130F850B004D9041FF9863CA160704C060188A0300A63000A8F89BAC31B47498A823F96524CA0F0020B64C1203063C63FF30C7942C0E070F018BFF2FFC08006000000000E2680000000210782688F2687C0090400000200395140004000025949000D2A8A1A003C00D0080400000000001002004290280"
SA_UE_CAPABILITIES_FDD="E1A01000014F5E0302C0020940004820D9C4C3E142C01360107FE618F28581C13018062280C0298C00283E0DEB0C6D1D262A08FE59493283C0082D930480C18F18FFCC31E50B0381C3C049FFA7FE04003000000000706C00000001083C06C479343E00482000001001C04A0002000012CA4800680C50D001E0068040200000000000801002148140"





exec('set_amf_region id=1 tac_list=7627107,100,200,0 plmn=311:489')
exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2')
exec('amf_param id=1 full_nas_auth=on ambr_remove=nas_transport,pdu_setup')
exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=10')


-- exec('set_amf_region id=1 tac_list=7627107,100,788,200,0 plmn=311:489')
-- exec('set_amf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region=1 set_id=2 pointer=2 name=amf1')
-- exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')
-- exec('set_upf id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/24 ngu='..AMF_NG_ADDR..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 devname=upf1')
--
-- exec('set_amf_region id=2 tac_list=7627107,100,788,200,0 plmn=311:489')
-- exec('set_amf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng=10.0.1.61:38412 region=2 set_id=2 pointer=2 name=amf2')
-- exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc')
-- exec('set_upf id=2 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr=1.2.4.2/24 ngu=10.0.1.61 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 devname=upf2')
--
-- exec('set_amf_region id=3 tac_list=7627107,100,788,200,0 plmn=311:489')
-- exec('set_amf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng=10.0.1.62:38412 region=2 set_id=2 pointer=2 name=amf3')
-- exec('amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc')
-- exec('set_upf id=3 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr=1.2.4.3/24 ngu=10.0.1.62 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 devname=upf3')
--
-- exec('set_amf_region id=4 tac_list=7627107,100,788,200,0 plmn=311:489')
-- exec('set_amf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng=10.0.1.63:38412 region=2 set_id=2 pointer=2 name=amf4')
-- exec('amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc')
-- exec('set_upf id=4 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr=1.2.4.4/24 ngu=10.0.1.63 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 devname=upf4')
--
-- exec('set_amf_region id=5 tac_list=7627107,100,788,200,0 plmn=311:489')
-- exec('set_amf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' ng=10.0.1.64:38412 region=2 set_id=2 pointer=2 name=amf5')
-- exec('amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc')
-- exec('set_upf id=5 daemon='..SERVER_IP..':'..DAEMON_PORT..' type=simulated addr=1.2.4.5/24 ngu=10.0.1.64 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20 devname=upf5')

exec('amf_param id=1 ims_voice_3gpp=on full_nas_auth=on')

--#---------------------------------------------------------------------------------------------------
--#GNB CONFIGURATION
--#---------------------------------------------------------------------------------------------------
-- exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' amf=1-5 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_gnb id=2 type=external plmn=311:489 ng='..GNB_NG_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..DAEMON_PORT..' amf=1 plmnList=311:489 nssai=0x1:0xd143a5')
exec('set_cell id=1 gnb=2 pci=16:2 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=2 gnb=2 pci=17:0 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=3 gnb=2 pci=17:1 tac=200 nrci=0x01 tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=636666:636666 gscn=7854 mandatory_for_activation=off')
exec('set_cell id=4 gnb=2 pci=17:2 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=5 gnb=2 pci=18:0 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_cell id=6 gnb=2 pci=18:1 tac=200 nrci=0x01 tdd_cell=off proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn=145600:156600 gscn=1956 mandatory_for_activation=off')
exec('set_uec id=1 daemon='..SERVER_IP..':'..DAEMON_PORT..' peer='..SERVER_IP..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/26 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=10')


IMSI_1 = 21645100
IMSI_2 = 21645200
IMSI_3 = 21645300
IMSI_4 = 21645400
IMSI_5 = 21645500
IMSI_6 = 21645600
IMSI_7 = 21645700
IMSI_8 = 21645800
IMSI_9 = 21645900
IMSI_10 = 21646000
IMSI_11 = 21646100
IMSI_12 = 21646200
IMSI_13 = 21646300
IMSI_14 = 21646400
IMSI_15 = 21646500
IMSI_16 = 21646600
IMSI_17 = 21646700
IMSI_18 = 21646800

Cell1=1
Cell1_end=40

for UEID = Cell1, Cell1_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=1 suci=0:311:489:0000:0:0:0'.. IMSI_2 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD..'')
end

Cell2=41
Cell2_end=80

for UEID = Cell2, Cell2_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=2 suci=0:311:489:0000:0:0:0'.. IMSI_4 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD..'')
end

Cell3=81
Cell3_end=120

for UEID = Cell3, Cell3_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=3 suci=0:311:489:0000:0:0:0'.. IMSI_6 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_TDD..'')
end


Cell4=121
Cell4_end=160

for UEID = Cell4, Cell4_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=4 suci=0:311:489:0000:0:0:0'.. IMSI_8 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD..'')
end

Cell5=161
Cell5_end=200

for UEID = Cell5, Cell5_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=5 suci=0:311:489:0000:0:0:0'.. IMSI_10 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD..'')
end

Cell6=201
Cell6_end=240

for UEID = Cell6, Cell6_end do
	exec('set_ue simulated id='..UEID..' uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C075829A7B61F nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell=6 suci=0:311:489:0000:0:0:0'.. IMSI_12 + UEID - 1)
	exec('ue_param id='..UEID..' ue_nr_capabilities='..SA_UE_CAPABILITIES_FDD..'')
end



exec('set_qosflow id=1 5qi=6 default=on')
--#set_nwslice id=1 snssai=0x01:0xd143a5             amf=1 default=on ue=all

--#add for 5Qi-5 & 5Qi-1 support for VoNR
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=2 gfbr_ul=7000 gfbr_dl=7000 mfbr_ul=7000 mfbr_dl=7000')    --gbr
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1')
-- exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1-5')

--exec('set_qosflow id=1 5qi=7 default=on')
--exec('set_qosflow id=2 5qi=8')
--exec('set_qosflow id=3 5qi=9')
--exec('smf_param id=1 additional_qosflows_to_activate=2,3')
--exec('nwslice_set id=1 qos_flows=1,2,3 snssai=0x01:0xD143A5 default=on ue=all amf=1')

--exec('qosfilter_set id=1 proto=udp single_port=7260 dir=bi')
--exec('qosfilter_set id=2 proto=udp single_port=7261 dir=bi')
--exec('qosfilter_set id=3 proto=udp single_port=7262 dir=bi')
--exec('qosfilter_set id=4 proto=udp single_port=7263 dir=bi')
--exec('qosfilter_set id=5 proto=udp single_port=7264 dir=bi')
--exec('ue_pdusession_param ue=71 pdu=1 qos_flow=1 filter_and_precedence=1:1 qos_flow=2 filter_and_precedence=4:4,5:5 qos_flow=3 filter_and_precedence=2:2,3:3')
--exec('qosfilter_set id=6 proto=udp single_port=7360 dir=bi')
--exec('qosfilter_set id=7 proto=udp single_port=7361 dir=bi')
--exec('qosfilter_set id=8 proto=udp single_port=7362 dir=bi')
--exec('qosfilter_set id=9 proto=udp single_port=7363 dir=bi')
--exec('qosfilter_set id=10 proto=udp single_port=7364 dir=bi')
--exec('ue_pdusession_param ue=72 pdu=2 qos_flow=1 filter_and_precedence=6:6 qos_flow=2 filter_and_precedence=9:9,10:10 qos_flow=3 filter_and_precedence=7:7,8:8')

for UEID = 1, 240 do
	exec('set_pdu_gateway id='..UEID..' ue_nat_ip=72.23.0.'..UEID..' dl_nat_gw='..SERVER_IP..' ul_nat_gw='..SERVER_IP..'')
end

exec('uec_param id=1 reordering_window_size=1000 reordering_timer=200')
---------------------------------------------------------------------------------------------------
exec('debug_log level=4')
exec('sim_debug_log level=4 mme=1')
exec('sim_debug_log level=4 pgw=1')
exec('sim_debug_log level=4 uec=1')
exec('sim_debug_log level=4 sgw=1')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('trace uec=1 protocol=rrc,nr_rrc on')
exec('sim_trace uec=1 protocol=nr_rrc on')
exec('sim_trace amf=1 protocol=ng on')
exec('sim_param_set NR_PDCP_CIPHERING=distributed')
exec('cfg_end')
exec('set_log log_to_file=on')
exec('sim_start version_check=off')
