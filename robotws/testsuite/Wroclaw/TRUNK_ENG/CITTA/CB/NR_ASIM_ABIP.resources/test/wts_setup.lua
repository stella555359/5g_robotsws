require "wts_variable"

os.execute("ulimit -c unlimited")  -- To support unlimited coredump file size on WTS VM
os.execute("sudo bash -c 'echo 'core.%e.%p' > /proc/sys/kernel/core_pattern'")  --To enable all types of coredumps on WTS VM
os.execute('sudo sysctl net.sctp.rto_min=100')  -- UE_APP-OAM SCTP Delay WA, rto flag added in UEC configuration
os.execute('rm egate_console.log.*')  -- Remove old or previous egate_console logs

-------------------------------------------------------------------------------------
-- IP CONFIGURATION
--------------------------------------------------------------------------------------
-- If interface has vlan e.g.: 1801, configure below with 'dev eth3.1801'

for ip1 = 3, 48 do
    os.execute('sudo ip addr add 10.0.2.'..ip1..'/24 dev eth4')
end

for ip2 = 61, 64 do
    os.execute('sudo ip addr add 10.0.1.'..ip2..'/24 dev eth3')
end

----------------------------------------------------------------------------------------------------
-- GNB CONFIGURATION
----------------------------------------------------------------------------------------------------

exec('set_gnb id=2 type=external plmn='..PLMN..' s1u='..GNB_S1U_ADDR..' x2='..GNB_X2_ADDR..':36422 ng='..GNB_NG_ADDR..' xn='..GNB_XN_ADDR..' gnb_id=0x01 daemon='..SERVER_IP..':'..EDAEMON_PORT..' x2_peers=none amf='..FIRST_AMF_ID..','..END_AMF_ID..' plmnList='..PLMN..' nssai='..SNSSAI..'')

for _, cell_data in ipairs(CELL_TABLE) do
	local nrci_o = string.format("%x", cell_data.cell_id)
	exec('set_cell id='..cell_data.cell_id..' gnb=2 gscn='..cell_data.gscn..' pci='..cell_data.pci..' tac='..TAC..' nrci=0x'..nrci_o..' tdd_cell='..cell_data.tdd_flag..' proxy='..AP_IP_TABLE[cell_data.ap_num]..':9999|'..AP_IP_TABLE[cell_data.ap_num]..':8888 nr_arfcn='..cell_data.nrarfcn..' mandatory_for_activation=off')
end

----------------------------------------------------------------------------------------------------
-- 5GCN CONFIGURATION
----------------------------------------------------------------------------------------------------

local array_id = 1
for amf_id = FIRST_AMF_ID, END_AMF_ID do
	exec('set_amf_region id='..amf_id..' tac_list=7627107,100,788,'..TAC..',0 plmn='..PLMN)
	exec('set_amf id='..amf_id..' name=SimModeAMF'..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' ng='..AMF_IP_TABLE[array_id]..':38412 region='..amf_id..' set_id='..amf_id + 1 ..' pointer='..amf_id + 1)
	exec('amf_param id='..amf_id..' full_nas_auth=on nia=null+zuc nea=null+zuc')
	exec('set_upf id='..amf_id..' daemon='..SERVER_IP..':'..EDAEMON_PORT..' type=simulated addr='..UPF_IP_TABLE[array_id]..'/21 ngu='..AMF_IP_TABLE[array_id]..' devname=tunUPF'..amf_id..' ngu_snd_buff_size=20M ngu_rcv_buff_size=20M ngu_read_packets_threshold=20')

	exec('smf_upf_mapping id='..amf_id..' upf='..amf_id)
	exec('smf_param id='..amf_id..' max_pdu_session_supported=2000')
	array_id = array_id + 1
end

----------------------------------------------------------------------------------------------------
-- UEC CONFIGURATION
----------------------------------------------------------------------------------------------------

UEC_IP2 = UEC_COUNT + 2
UEC_IP = 1

for uec_id = 1, UEC_COUNT do
	exec('set_uec id='..uec_id..' daemon=10.0.2.'..UEC_IP..':'..EDAEMON_PORT..' peer=10.0.2.'..UEC_IP..':2152 peer_uplane=10.0.2.'..UEC_IP2..':2152 retries=unlimited gtpu=off pdn=1 devtype=tun devname=tunUEC'..uec_id..' addr=72.'..uec_id + 20 ..'.0.1/16 proxy_snd_buf_size=20971520 proxy_rcv_buf_size=20971520 proxy_read_packets_threshold=20 sctp_rto_min=100')
	exec('uec_param id='..uec_id..' reordering_window_size=1000 reordering_timer=500 disable_sib1_flood=on disable_sib_during_ho=on')
	if UEC_IP == 1 then
		UEC_IP = UEC_IP + 1
	end
	UEC_IP = UEC_IP + 1
	UEC_IP2 = UEC_IP2 + 1
end

----------------------------------------------------------------------------------------------------
-- UE GROUPS AND UE ALLOCATION
----------------------------------------------------------------------------------------------------

uecid = 1
SA_UEID = 1

for index, cell_data in ipairs(CELL_TABLE) do
	cellIncluded = false
	for _, cellid in ipairs(INCLUDED_FOR_TEST_TYPES_PER_CELL) do
		if cell_data.cell_id == cellid then
			cellIncluded = true
		end
	end
	if cellIncluded then
		if uecid > UEC_COUNT then
			uecid = 1
		end
		cell_ue_group = cell_data.cell_id * 10 + 1 --First ue group per cell 11, 21, 31...
		for _, test_type in ipairs(TEST_TYPES_PER_CELL) do
			--Setup UE groups
			exec("set_ue_group id="..cell_ue_group.." name=UE_GRP-"..cell_ue_group.." uec="..uecid.." enb=2 cell="..cell_data.cell_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
			--UE allocation
			for i = 1, test_type.ue_amount do
				exec('set_ue id='..SA_UEID..' group='..cell_ue_group..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..cell_data.cell_id..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
				exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
				SA_UEID = SA_UEID + 1
			end
			cell_ue_group = cell_ue_group + 1
		end
		uecid = uecid + 1
	end
end

-- Individually specified UE groups start at 701 and goes on to 702, 703, 704...
ue_group_id_individual = 700

for _, ue_group in ipairs(INDIVIDUAL_UE_GROUPS) do
	if uecid > UEC_COUNT then
		uecid = 1
	end
	ue_group_id_individual = ue_group_id_individual + 1
	-- Setup UE groups
	if ue_group.uec_id ~= 'auto' then
		exec("set_ue_group id="..ue_group_id_individual.." name=UE_GRP-"..ue_group_id_individual.." uec="..ue_group.uec_id.." enb=2 cell="..ue_group.cell_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
	else
		exec("set_ue_group id="..ue_group_id_individual.." name=UE_GRP-"..ue_group_id_individual.." uec="..uecid.." enb=2 cell="..ue_group.cell_id.." ptw=2.56 idle_edrx_cycle_len=2 release=15 nia=null+zuc+aes+snow3g nea=null+zuc+aes+snow3g")
		uecid = uecid + 1
	end
	-- UE allocation
	for i = 1, ue_group.ue_amount do
		exec('set_ue id='..SA_UEID..' group='..ue_group_id_individual..' opc_key=0ED47545168EAFE2C39C075829A7B61F sec_key=0102030405060708090A0B0C0D0EFF00 mode=nr enb=2 cell='..ue_group.cell_id..' suci=0:'..PLMN..':0000:0:0:0'.. SA_IMSI + SA_UEID - 1)
		exec("set_pdu_param ue="..SA_UEID.." pdu=1 trf_type=internal")
		SA_UEID = SA_UEID + 1
	end
end

---------------------------------------------------------------------------------------------------
-- COMMON CONFIGURATION
---------------------------------------------------------------------------------------------------

--exec('set_qosflow id=1 5qi=6 default=on')
--exec('nwslice_set id=1 qos_flows=1 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)

--1DRB for RRC SA UEs
--exec('set_qosflow id=1 5qi=6 default=on')
--exec('set_qosflow id=2 5qi=5')
--exec('set_qosflow id=3 5qi=1')
--exec('set_qosrule id=1 proto=tcp qos_flow=2')
--exec('set_qosrule id=2 proto=udp qos_flow=3')
--exec('nwslice_set id=1 qos_flows=1,2,3 qos_rules=1,2 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)

--2DRB for RRC SA UEs
exec('set_qosflow id=1 5qi=6 default=on')
exec('set_qosflow id=2 5qi=5')
exec('set_qosflow id=3 5qi=1')
exec('set_qosflow id=4 5qi=9')
exec('set_qosrule id=1 proto=tcp qos_flow=2')
exec('set_qosrule id=2 proto=udp qos_flow=3')
exec('set_qosrule id=3 proto=udp qos_flow=4')
exec('nwslice_set id=1 qos_flows=1,2,3,4 qos_rules=1,2,3 snssai='..SNSSAI..' default=on ue=all amf='..FIRST_AMF_ID..'-'..END_AMF_ID)
-- local array_id = 1
-- for amf_id = FIRST_AMF_ID, END_AMF_ID do
-- 	exec('smf_param id='..amf_id..' additional_qosflows_to_activate=4')
-- 	array_id = array_id + 1
-- end

---------------------------------------------------------------------------------------------------
-- OTHER CONFIGURATION
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Cipher offload flag to distribute:ciphering=uec/distributed
---------------------------------------------------------------------------------------------------

exec('sim_param_set NR_PDCP_CIPHERING=distributed NR_PDCP_TRUNCATE_DL_SIZE=47 NR_PDCP_BUNDLE_DL_MAX_SIZE=1200 NR_PDCP_BUNDLE_DL_TIMEOUT=100')
exec('sim_param_set PET_PROFILE=on TTI=5 NR_CLUB_PROXY_PROTO_MSGS=enabled pet_5g_testing=on') -- Proxy proto flag enabled

---------------------------------------------------------------------------------------------------
-- SRS BF configuration
---------------------------------------------------------------------------------------------------

--exec('cell_srs_beam_pos_nr profile_id=1 num_of_ue_positions=4 azimuth=-70,-19,20,70')

--for _, cell_data in ipairs(CELL_TABLE) do
--	if cell_data.additional == '8DL_SRS' then
--		exec('cell_testmode_set_nr cell_id='..cell_data.cell_id..' gnb=2 testmode=cell_srs_beam_pos profile_id=1 action=activate')
--	end
--end

---------------------------------------------------------------------------------------------------
-- DEBUG CONFIGURATION
---------------------------------------------------------------------------------------------------

exec('debug_log level=4')
exec('link_ctrl_param hb_period=5 hb_retries=5')
exec('link_ctrl_param hb_period=30 hb_retries=5 app_type=uec')
exec('cfg_end')
exec('set_log log_to_file=true max_file_num=1')
