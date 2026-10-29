 -- Copyright (c) 2019 Nokia. All rights reserved.
os.execute("ulimit -c unlimited")	--To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")	--To enable all types of coredumps on WTS VM

-------------------------------------------------------------------------------------
--VLAN Finder
-------------------------------------------------------------------------------------
function find_vlan(interface)
    local filename = os.tmpname()
    local command = "ip link > " .. filename
    os.execute(command)
  
    local file = io.open(filename, "r")
    local output = ""
    if file then
      for line in file:lines() do
		if string.match(line, "trunk") then
			break
        elseif string.match(line, interface) then
          local vlan = string.match(line, "%.%d+")
          if vlan then
            output = vlan
            break
          end
        end
      end
      file:close()
      os.remove(filename)
    end
    if output ~= "" then
      return output -- Return VLAN ID if found
    else
      return "" -- Return empty string if VLAN ID is not found
    end
  end
  
  GNB_VLAN = find_vlan("eth3")
  AP_VLAN = find_vlan("eth4")
  
  -- Write the VLAN IDs to file
  os.execute('echo "GNB_VLAN:'..GNB_VLAN..'"> /opt/wts/latest/vlan')
  os.execute('echo "AP_VLAN'..AP_VLAN..'">> /opt/wts/latest/vlan')

require ("PET_SE_CFG")
require ("hw_var")
---------------------------------------------------------------------------------------------------
--ENB CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('sim_param_set ENABLE_CORE_LIMIT=on')

exec('set_enb id=1 plmn='..PLMN..' s1='..ENB1_S1_ADDR..' enb_id_macro=0x12346 daemon='..DAEMON_IP..':'..DAEMON_PORT..' x2='..ENB1_X2_ADDR..' x2u='..ENB_X2U_ADDR..' type=simulated x2_peers=none')
exec('enb_param id=1 drb_id_begin=3 endc_capable_qci=9')
exec('set_cell id=1 enb=1 eci=0x1234601 pci=3:2 tac='..TAC..' proxy='..DAEMON_IP..':12219|'..DAEMON_IP..':8889 earfcn=2000:20000 mapped_earfcn=4200:22200 tdd_cell=on mandatory_for_activation=off')
exec('enb_endc_param id=1 control_flow_period=3gpp1 use_nr_ran_cont=on')

----------------------------------------------------------------------------------------------------
--GNB CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x76C daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf=1-5 plmnList='..PLMN..' nssai='..NSSAI..'')
exec('set_cell id='..LCRID1..' gnb=2 pci='..PCI1..' tac='..TAC..' nrci=0x01 gscn='..GSCN1..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN1..' mandatory_for_activation=off')
exec('set_cell id='..LCRID2..' gnb=2 pci='..PCI2..' tac='..TAC..' nrci=0x02 gscn='..GSCN1..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN1..' mandatory_for_activation=off')
exec('set_cell id='..LCRID3..' gnb=2 pci='..PCI3..' tac='..TAC..' nrci=0x03 gscn='..GSCN2..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN2..' mandatory_for_activation=off')
exec('set_cell id='..LCRID4..' gnb=2 pci='..PCI4..' tac='..TAC..' nrci=0x04 gscn='..GSCN2..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN2..' mandatory_for_activation=off')
exec('set_cell id='..LCRID5..' gnb=2 pci='..PCI5..' tac='..TAC..' nrci=0x05 gscn='..GSCN3..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN3..' mandatory_for_activation=off')
exec('set_cell id='..LCRID6..' gnb=2 pci='..PCI6..' tac='..TAC..' nrci=0x06 gscn='..GSCN3..' tdd_cell=on proxy='..PROXY_SERVER_IP..':9999|'..PROXY_SERVER_IP..':8888 nr_arfcn='..NRARFCN3..' mandatory_for_activation=off')

----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
--EPC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('mme_pool_area id=1 mmegi=1 plmn='..PLMN..' tac_list='..TAC..'')
exec('set_mme id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1='..MME1_S1_ADDR..':36412 supported_rat=lte,nblte pool=1:1')
exec('set_sgw id=1 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW_S1U_ADDR..' s11='..SGW_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_pgw id=1 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW_ADDR..'/17 apn=lteapn1.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA13 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')

exec('set_pgw id=2 type=simulated ip='..DAEMON_IP..':'..DAEMON_PORT..' addr='..PGW2_ADDR..'/17 apn=lteapn2.com.mnc69.mcc450.gprs devtype=tun devname=tunLTEA2 sgi_rcv_buff_size=20M sgi_snd_buff_size=20M s5u_rcv_buff_size=20M s5u_snd_buff_size=20M gtpu_read_packets_threshold=10')
exec('set_sgw id=2 ip='..DAEMON_IP..':'..DAEMON_PORT..' s1u='..SGW2_S1U_ADDR..' s11='..SGW2_S11_ADDR..':60100 s5u_snd_buff_size=20M s5u_rcv_buff_size=20M s1u_snd_buff_size=20M s1u_rcv_buff_size=20M gtpu_read_packets_threshold=10')

----------------------------------------------------------------------------------------------------
--5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_amf_region id=1 tac_list='..TAC..' plmn='..PLMN..'')
exec('set_amf id=1 name=SimModeAMF-1 daemon='..SERVER_IP6..':'..EDAEMON_PORT..' ng='..AMF_NG_ADDR..':38412 region='..AMF_REGION_ID1..' set_id='..AMF_SET_ID1..' pointer='..AMF_POINTER_ID1..'')
exec('amf_param id=1 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_amf_region id=2 tac_list='..TAC..' plmn='..PLMN..'')
exec('set_amf id=2 name=SimModeAMF-2 daemon='..SERVER_IP2..':'..EDAEMON_PORT..' ng='..AMF2_NG_ADDR..':38412 region='..AMF_REGION_ID2..' set_id='..AMF_SET_ID2..' pointer='..AMF_POINTER_ID2..'')
exec('amf_param id=2 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_amf_region id=3 tac_list='..TAC..' plmn='..PLMN..'')
exec('set_amf id=3 name=SimModeAMF-3 daemon='..SERVER_IP3..':'..EDAEMON_PORT..' ng='..AMF3_NG_ADDR..':38412 region='..AMF_REGION_ID3..' set_id='..AMF_SET_ID3..' pointer='..AMF_POINTER_ID3..'')
exec('amf_param id=3 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_amf_region id=4 tac_list='..TAC..' plmn='..PLMN..'')
exec('set_amf id=4 name=SimModeAMF-4 daemon='..SERVER_IP4..':'..EDAEMON_PORT..' ng='..AMF4_NG_ADDR..':38412 region='..AMF_REGION_ID4..' set_id='..AMF_SET_ID4..' pointer='..AMF_POINTER_ID4..'')
exec('amf_param id=4 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_amf_region id=5 tac_list='..TAC..' plmn='..PLMN..'')
exec('set_amf id=5 name=SimModeAMF-5 daemon='..SERVER_IP5..':'..EDAEMON_PORT..' ng='..AMF5_NG_ADDR..':38412 region='..AMF_REGION_ID5..' set_id='..AMF_SET_ID5..' pointer='..AMF_POINTER_ID5..'')
exec('amf_param id=5 full_nas_auth=on nia=null+zuc nea=null+zuc')

exec('set_upf id=1 daemon='..SERVER_IP6..':'..EDAEMON_PORT..' type=simulated addr='..UPF_ADDR..'/21 ngu='..AMF_NG_ADDR..' devname=tunUPF ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('set_upf id=2 daemon='..SERVER_IP2..':'..EDAEMON_PORT..' type=simulated addr='..UPF2_ADDR..'/21 ngu='..AMF2_NG_ADDR..' devname=tunUPF2 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('set_upf id=3 daemon='..SERVER_IP3..':'..EDAEMON_PORT..' type=simulated addr='..UPF3_ADDR..'/21 ngu='..AMF3_NG_ADDR..' devname=tunUPF3 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('set_upf id=4 daemon='..SERVER_IP4..':'..EDAEMON_PORT..' type=simulated addr='..UPF4_ADDR..'/21 ngu='..AMF4_NG_ADDR..' devname=tunUPF4 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')
exec('set_upf id=5 daemon='..SERVER_IP5..':'..EDAEMON_PORT..' type=simulated addr='..UPF5_ADDR..'/21 ngu='..AMF5_NG_ADDR..' devname=tunUPF5 ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')


exec('smf_upf_mapping id=1 upf=1 id=2 upf=2 id=3 upf=3 id=4 upf=4 id=5 upf=5')
exec('smf_param id=1 max_pdu_session_supported=3000')
exec('smf_param id=2 max_pdu_session_supported=3000')
exec('smf_param id=3 max_pdu_session_supported=3000')
exec('smf_param id=4 max_pdu_session_supported=3000')
exec('smf_param id=5 max_pdu_session_supported=3000')

---------------------------------------------------------------------------------------------------
--SIMGNB CONFIGURATION--
---------------------------------------------------------------------------------------------------
if HO_Enabled == 'yes' then
	exec('set_gnb id=3 type=simulated plmn='..PLMN..' daemon='..SERVER_IP13..':'..DAEMON_PORT..' xn='..GNB3_XN_ADDR..' ng='..GNB3_NG_ADDR..' gnb_id='..NGNB_ID1..' x2_peers=none amf=1-5 plmnList='..PLMN..' nssai='..SNSSAI)
	exec('gnb_param id=3  xn_listening_socket=on send_xn_setup=on sib1_period=2000')
    exec('gnb_param id=3 measEvent=A1  measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
	exec('set_cell id=1 gnb=3 pci='..NGNBPCI1..' tac='..TAC..' nrci=0x01 tdd_cell=on proxy='..SERVER_IP13..':9999|'..SERVER_IP13..':8888 nr_arfcn='..NRARFCN1..' mandatory_for_activation=off gscn='..GSCN1..' suggested_band='..NRBAND1)
    exec('set_gnb id=4 type=simulated plmn='..PLMN..' daemon='..SERVER_IP14..':'..DAEMON_PORT..' xn='..GNB4_XN_ADDR..' ng='..GNB4_NG_ADDR..' gnb_id='..NGNB_ID2..' x2_peers=none amf=1-5 plmnList='..PLMN..' nssai='..SNSSAI)
    exec('gnb_param id=4  xn_listening_socket=on send_xn_setup=on sib1_period=2000')
    exec('gnb_param id=4 measEvent=A1  measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
    exec('set_cell id=1 gnb=4 pci='..NGNBPCI2..' tac='..TAC..' nrci=0x01 tdd_cell=on proxy='..SERVER_IP14..':9999|'..SERVER_IP14..':8888 nr_arfcn='..NRARFCN2..' mandatory_for_activation=off gscn='..GSCN2..' suggested_band='..NRBAND1)
    exec('set_gnb id=5 type=simulated plmn='..PLMN..' daemon='..SERVER_IP15..':'..DAEMON_PORT..' xn='..GNB5_XN_ADDR..' ng='..GNB5_NG_ADDR..' gnb_id='..NGNB_ID3..' x2_peers=none amf=1-5 plmnList='..PLMN..' nssai='..SNSSAI)
    exec('gnb_param id=5  xn_listening_socket=on send_xn_setup=on sib1_period=2000')
    exec('gnb_param id=5 measEvent=A1  measEvent=A2 measEvent=A3 measEvent=A5 measEvent=A4')
    exec('set_cell id=1 gnb=5 pci='..NGNBPCI3..' tac='..TAC..' nrci=0x01 tdd_cell=on proxy='..SERVER_IP15..':9999|'..SERVER_IP15..':8888 nr_arfcn='..NRARFCN3..' mandatory_for_activation=off gscn='..GSCN3..' suggested_band='..NRBAND1)
	end 
----------------------------------------------------------------------------------------------------
--UEC CONFIGURATION
----------------------------------------------------------------------------------------------------
exec('set_uec id=1 daemon='..SERVER_IP..':'..EDAEMON_PORT..' peer='..SERVER_IP..':2152 peer_uplane='..SERVER_IP7..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC addr='..UEC_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=2 daemon='..SERVER_IP2..':'..EDAEMON_PORT..' peer='..SERVER_IP2..':2152 peer_uplane='..SERVER_IP8..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC2 addr='..UEC2_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=3 daemon='..SERVER_IP3..':'..EDAEMON_PORT..' peer='..SERVER_IP3..':2152 peer_uplane='..SERVER_IP9..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC3 addr='..UEC3_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=4 daemon='..SERVER_IP4..':'..EDAEMON_PORT..' peer='..SERVER_IP4..':2152 peer_uplane='..SERVER_IP10..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC4 addr='..UEC4_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=5 daemon='..SERVER_IP5..':'..EDAEMON_PORT..' peer='..SERVER_IP5..':2152 peer_uplane='..SERVER_IP11..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC5 addr='..UEC5_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=6 daemon='..SERVER_IP6..':'..EDAEMON_PORT..' peer='..SERVER_IP6..':2152 peer_uplane='..SERVER_IP12..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC6 addr='..UEC6_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=7 daemon='..SERVER_IP16..':'..EDAEMON_PORT..' peer='..SERVER_IP16..':2152 peer_uplane='..SERVER_IP18..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC7 addr='..UEC7_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
exec('set_uec id=8 daemon='..SERVER_IP17..':'..EDAEMON_PORT..' peer='..SERVER_IP17..':2152 peer_uplane='..SERVER_IP19..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC8 addr='..UEC8_ADDR..'/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
------------------------------------------------------------------
--NUM_OF_PET_SE_GROUP
-------------------------------------------------------------------------
pet_se_group()
------------------------------------------------------------------------------------------------------
--Traffic profile creation
-------------------------------------------------------------------------------------------------------
exec('set_trf_data_profile profile_id=1 trf_id=1  size=355 kbps=200  seconds=8')
exec('set_trf_data_profile profile_id=2 trf_id=1  size=1277 kbps=1055  seconds=8')
exec('set_trf_data_profile profile_id=3 trf_id=1  size=60 kbps=50  seconds=120')
----------------------------------------------------------------------------------------------------
--UES_PER_PET_SE_GROUP
-----------------------------------------------------------------------
pet_se_ue_per_group()
---------------------------------------------------------------------------------------------------------------------------------------------
exec('sim_param_set PAGING_BUFFER_TIMER=10 PAGING_BUFFER_VALUE=6')
exec('sim_param_set NR_COMPRESS_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set NR_CLUB_PROXY_PROTO_MSGS=enabled')
exec('sim_param_set purge_buffer_on_full=on')
--exec('sim_param_set CM_OPTIMIZATION=on') --- for reducing amf CPU utlization
--exec('amf_ng_setup_param id=1-5 ue_retention=on retention_time=indefinite') --- for NgLink down recovery  
exec('set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=10.0.2.1 ul_nat_gw=10.0.2.1')
--------------------------------------------------------------------------------
--COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5 default=off')
exec('set_qosflow id=3 5qi=1 default=off')
exec('set_qosflow id=4 5qi=8 default=off')
--exec('set_qosrule id=1 proto=tcp qos_flow=2')
--exec('set_qosrule id=2 proto=udp qos_flow=3')
--exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
exec('set_nwslice default=on id=1 snssai='..SNSSAI..' qos_flows=1,2,3 amf_region_id=1-5 plmn_list='..PLMN..'  ue=all')
exec("smf_param id=1 additional_qosflows_to_activate=2")
exec("smf_param id=2 additional_qosflows_to_activate=2")
exec("smf_param id=3 additional_qosflows_to_activate=2")
exec("smf_param id=4 additional_qosflows_to_activate=2")
exec("smf_param id=5 additional_qosflows_to_activate=2")
------------------------------------------------------------------------------------------------------
--PET_SE SEQUENCE SET GROUPS FOR traffic model
--------------------------------------------------------------------------------------------------
if  VTM_RUN_DURATION == '2Hrs' then
pet_se_seq_vtm(205,42,318,28.18,625,14.40,8990,48,187.4,18,1014) --(paging_loop,paging_sleep,ue_st_loop,ue_st_sleep,TAU_loop,TAU_sleep,maxUeRrcInactTime,rna_loop,rna_sleep,page_per_amf_per_burst,page_period)
end
if  VTM_RUN_DURATION == '4Hrs' then
pet_se_seq_vtm(410,42,636,28.18,1250,14.40,17990,96,187.4,18,1014)
end
if VTM_RUN_DURATION == '6Hrs' then
pet_se_seq_vtm(615,42,954,28.18,1875,14.40,23390,144,187.4,18,1014)
end
-------------------------------------------------------------------------------------------------
--OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------
--exec('uec_param id=1 reordering_window_size=1000 reordering_timer=500  srb_reordering_enabled=on')
--exec('uec_param id=2 reordering_window_size=1000 reordering_timer=500')
--exec('uec_param id=3 reordering_window_size=1000 reordering_timer=500')
--exec('uec_param id=4 reordering_window_size=1000 reordering_timer=500')
--exec('uec_param id=5 reordering_window_size=1000 reordering_timer=500')
--exec('uec_param id=6 reordering_window_size=1000 reordering_timer=500')
exec('uec_param id=1 srb_reordering_enabled=on')
exec('uec_param id=2 srb_reordering_enabled=on')
exec('uec_param id=3 srb_reordering_enabled=on')
exec('uec_param id=4 srb_reordering_enabled=on')
exec('uec_param id=5 srb_reordering_enabled=on')
exec('uec_param id=6 srb_reordering_enabled=on')
exec('uec_param id=7 srb_reordering_enabled=on')
exec('uec_param id=8 srb_reordering_enabled=on')

-------------------------------------------------------------------------------------------------
--SRS Configuration
---------------------------------------------------------------------------------------------------
exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')
exec('cell_testmode_set_nr cell_id=1 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=2 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=3 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=4 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=5 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
exec('cell_testmode_set_nr cell_id=6 gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')

---------------------------------------------------------------------------------------------------
--CNI flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------
exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set TTI=3')
exec('debug_log level=4 max_file_num=50 max_log_size=500M')
--exec('sim_debug_log level=4 mme=1')
--exec('sim_debug_log level=4 pgw=1')
--exec('sim_debug_log level=1 uec=1')
--exec('sim_debug_log level=1 amf=1')
--exec('sim_debug_log level=4 sgw=1')
--link_ctrl_param use_hb=off
exec('link_ctrl_param hb_period=5 hb_retries=5')
--exec('trace enb=1 protocol=x2 on')
--exec('trace uec=1 protocol=x2 on')
--exec('trace uec=1 protocol=rrc,nr_rrc on')
--exec('sim_trace uec=1 protocol=nr_rrc on')
--exec('sim_trace amf=1 protocol=ng on')
exec('cfg_end')
exec('set_log log_to_file=true file=auto  max_log_size=500M max_file_num=50')
exec('sim_start version_check=off')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')  
