-- Lua dissector for I-PHY's ProxyProto.h

local proxyproto_protocol = Proto("iphy", "WTS UEC ProxyProto")  --TODO change to proxyproto once agreement with UTE and ta_library will be there!
local proxyproto_filter = "iphy" --TODO change to proxyproto once agreement with UTE and ta_library will be there!
local lte_protocol_type = 12851
local nr_protocol_type = 13363

-- Declaration of tables that users may opt to use.
local msg_field_name = {}
local msg_field_filter = {}
local msg_field_radix = {}
local msg_field_num_bytes = {}
local msg_field_proto = {}
local msg_register_fields = {}
local msg_dissect = {}
local tree_arr = {}

--Describe Wireshark names of logical channels inside RRC messages (it is different in different Wireshark versions as we know now...)
	local bcch_bch_ie_name = "lte_rrc.bcch_bch"
	local bcch_bch_nb_ie_name = "lte_rrc.bcch_bch_nb"
	local bcch_dl_sch_ie_name = "lte_rrc.bcch_dl_sch"
	local bcch_dl_sch_nb_ie_name = "lte_rrc.bcch_dl_sch_nb"
	local bcch_dl_sch_br_ie_name = "lte_rrc.bcch_dl_sch_br"
	local pcch_ie_name = "lte_rrc.pcch"
	local pcch_nb_ie_name = "lte_rrc.pcch_nb"
	local dl_ccch_ie_name = "lte_rrc.dl_ccch"
	local dl_ccch_nb_ie_name = "lte_rrc.dl_ccch_nb"
	local dl_dcch_ie_name = "lte_rrc.dl_dcch"
	local dl_dcch_nb_ie_name = "lte_rrc.dl_dcch_nb"
	local ul_ccch_ie_name = "lte_rrc.ul_ccch"
	local ul_ccch_nb_ie_name = "lte_rrc.ul_ccch_nb"
	local ul_dcch_ie_name = "lte_rrc.ul_dcch"
	local ul_dcch_nb_ie_name = "lte_rrc.ul_dcch_nb"
	local mcch_ie_name = "lte_rrc.mcch"
	--nr-rrc
	local bcch_bch_nr_ie_name = "nr-rrc.bcch.bch"
	local bcch_dl_sch_nr_ie_name = "nr-rrc.bcch.dl.sch"
	local pcch_nr_ie_name = "nr-rrc.pcch"
	local dl_ccch_nr_ie_name = "nr-rrc.dl.ccch"
	local dl_dcch_nr_ie_name = "nr-rrc.dl.dcch"
	local ul_ccch_nr_ie_name = "nr-rrc.ul.ccch"
	local ul_ccch1_nr_ie_name = "nr-rrc.ul.ccch1"
	local ul_dcch_nr_ie_name = "nr-rrc.ul.dcch"

	local wireshark_version = get_version()

	major_ver, minor_ver = string.match(wireshark_version, "(%d+).(%d+).*")
	local decimal_version = tonumber(major_ver) + tonumber(minor_ver) / 10

	if decimal_version >= 2.4 then
		bcch_bch_ie_name = "lte_rrc.bcch_bch"
		bcch_bch_nb_ie_name = "lte_rrc.bcch_bch.nb"
		bcch_dl_sch_ie_name = "lte_rrc.bcch_dl_sch"
		bcch_dl_sch_nb_ie_name = "lte_rrc.bcch_dl_sch.nb"
		bcch_dl_sch_br_ie_name = "lte_rrc.bcch_dl_sch_br"
		pcch_ie_name = "lte_rrc.pcch"
		pcch_nb_ie_name = "lte_rrc.pcch.nb"
		dl_ccch_ie_name = "lte_rrc.dl_ccch"
		dl_ccch_nb_ie_name = "lte_rrc.dl_ccch.nb"
		dl_dcch_ie_name = "lte_rrc.dl_dcch"
		dl_dcch_nb_ie_name = "lte_rrc.dl_dcch.nb"
		ul_ccch_ie_name = "lte_rrc.ul_ccch"
		ul_ccch_nb_ie_name = "lte_rrc.ul_ccch.nb"
		ul_dcch_ie_name = "lte_rrc.ul_dcch"
		ul_dcch_nb_ie_name = "lte_rrc.ul_dcch.nb"
		mcch_ie_name = "lte_rrc.mcch"
	end

-- Mapping of message types to message names.
-- The order of messages in this section should correspond to the order of the messages
-- in the "#define PROXY_PROTO_MSG_MAP" section of ProxyProto.h.
local msg_type_to_name = {}
msg_type_to_name[0x0000] = "CTRL_CONN"
msg_type_to_name[0x0001] = "CTRL_CONN_RSP"
msg_type_to_name[0x0002] = "CTRL_DISC"
msg_type_to_name[0x0003] = "CTRL_ADD_UE"
msg_type_to_name[0x0004] = "CTRL_ADD_UE_RSP"
msg_type_to_name[0x0005] = "CTRL_DEL_UE"
msg_type_to_name[0x0006] = "CTRL_FAILURE_IND"
msg_type_to_name[0x0007] = "DL_DCCH_NB"
msg_type_to_name[0x0008] = "CTRL_RLC_DELIV_IND"
msg_type_to_name[0x0009] = "CTRL_RLC_DISCARD"
msg_type_to_name[0x000a] = "CTRL_RLC_REESTAB_REQ"
msg_type_to_name[0x000b] = "CTRL_RLC_REESTAB_COMPLETE"
msg_type_to_name[0x000c] = "CTRL_ADD_MOD_RB"
msg_type_to_name[0x000d] = "CTRL_ADD_MOD_RB_RSP"
msg_type_to_name[0x000e] = "CTRL_DEL_RB"
msg_type_to_name[0x000f] = "CTRL_DEL_RB_RSP"
msg_type_to_name[0x0010] = "CTRL_POOL_STATE"
msg_type_to_name[0x0011] = "CTRL_UE_SUSPEND"
msg_type_to_name[0x0012] = "CTRL_UE_RESUME"
msg_type_to_name[0x0013] = "CTRL_ADD_UE_HO"
msg_type_to_name[0x0014] = "CTRL_ADD_UE_HO_RSP"
msg_type_to_name[0x0015] = "CTRL_UE_RACH_COMPLETE"
msg_type_to_name[0x0016] = "CTRL_UPDATE_UE_CQI"
msg_type_to_name[0x0017] = "CTRL_UPDATE_UE_UL_POWER_CONTROL"
msg_type_to_name[0x0018] = "CTRL_UPDATE_RB"
msg_type_to_name[0x0019] = "CTRL_UE_RR_CONFIG_DEDICATED"
msg_type_to_name[0x001a] = "CTRL_UPDATE_UE_UL_TTI_BUNDLING_HARQ_ERROR"
msg_type_to_name[0x001b] = "CTRL_DEL_UE_RSP"
msg_type_to_name[0x001c] = "CTRL_UPD_MOD_RB"
msg_type_to_name[0x001d] = "CTRL_UE_STATS_REQ"
msg_type_to_name[0x001e] = "CTRL_UPDATE_UE_RACH_OVERRIDE"
msg_type_to_name[0x001f] = "CTRL_UE_STATS_CLR"
msg_type_to_name[0x0020] = "CTRL_UPDATE_UE_EXTRA_ERROR"
msg_type_to_name[0x0021] = "CTRL_UE_BSR_OVERRIDE"
msg_type_to_name[0x0022] = "CTRL_HB_REQ"
msg_type_to_name[0x0023] = "CTRL_HB_RSP"
msg_type_to_name[0x0024] = "CTRL_UE_SRS_OVERRIDE"
msg_type_to_name[0x0025] = "CTRL_UE_MEAS_CONF"
msg_type_to_name[0x0026] = "CTRL_SIB13"
msg_type_to_name[0x0027] = "CTRL_MBSFN_AREA_CONF"
msg_type_to_name[0x0028] = "DL_MCCH"
msg_type_to_name[0x0029] = "DL_MTCH"
msg_type_to_name[0x002a] = "CTRL_UE_LCID_OVERRIDE"
msg_type_to_name[0x002b] = "CTRL_UE_MAC_ERROR"
msg_type_to_name[0x002c] = "CTRL_PRX_RFM"
msg_type_to_name[0x002d] = "CTRL_SIB1"
msg_type_to_name[0x002e] = "CTRL_SIB2"
msg_type_to_name[0x002f] = "CTRL_UE_UL_POWER_CONTROL_DISP_REQ"
msg_type_to_name[0x0030] = "CTRL_UE_UL_POWER_CONTROL_DISP_RSP"
msg_type_to_name[0x0031] = "CTRL_PROXY_CELL_INFO"
msg_type_to_name[0x0032] = "CTRL_PROXY_COMMAND_DISP_REQ"
msg_type_to_name[0x0033] = "CTRL_PROXY_COMMAND_DISP_RSP"
msg_type_to_name[0x0034] = "CTRL_PROXY_COMMAND_DISP_CLR"
msg_type_to_name[0x0035] = "CTRL_PROXY_COMMAND_CFG"
msg_type_to_name[0x0036] = "UL_CCCH_NB"
msg_type_to_name[0x0037] = "SIM_DSP_SCT_TEST_IND"
msg_type_to_name[0x0038] = "DL_CCCH_NB"
msg_type_to_name[0x0039] = "CTRL_UPDATE_UE_DL_HARQ_ERROR"
msg_type_to_name[0x003a] = "CTRL_UPDATE_UE_UL_HARQ_ERROR"
msg_type_to_name[0x003b] = "CTRL_CELL_STATS_REQ"
msg_type_to_name[0x003c] = "CTRL_CELL_STATS_CLR"
msg_type_to_name[0x003d] = "CTRL_LOG_BITMAP"
msg_type_to_name[0x003e] = "DL_BCCH_BCH"
msg_type_to_name[0x003f] = "DL_BCCH_SCH"
msg_type_to_name[0x0040] = "DL_PCCH"
msg_type_to_name[0x0041] = "DL_CCCH"
msg_type_to_name[0x0042] = "DL_DCCH"
msg_type_to_name[0x0043] = "DL_DTCH"
msg_type_to_name[0x0044] = "CTRL_UE_RR_CONFIG_DEDICATED_NB_R13"
msg_type_to_name[0x0045] = "UL_CCCH"
msg_type_to_name[0x0046] = "UL_DCCH"
msg_type_to_name[0x0047] = "UL_DTCH"
msg_type_to_name[0x0048] = "UL_DCCH_NB"
msg_type_to_name[0x0049] = "CTRL_SIB2_RSP"
msg_type_to_name[0x004a] = "CTRL_UE_ADD_SCELL"
msg_type_to_name[0x004b] = "CTRL_UE_REL_SCELL"
msg_type_to_name[0x004c] = "CTRL_UE_DL_LAST_ALLOC_RSP"
msg_type_to_name[0x004d] = "CTRL_UE_DL_HARQ_DCI_AND_ERR_RSP"
msg_type_to_name[0x004e] = "CTRL_UE_PDSCH_STATS_RSP"
msg_type_to_name[0x004f] = "CTRL_UE_UL_LAST_ALLOC_RSP"
msg_type_to_name[0x0050] = "CTRL_UE_UL_HARQ_DCI_AND_ERR_RSP"
msg_type_to_name[0x0051] = "CTRL_UE_PUSCH_STATS_RSP"
msg_type_to_name[0x0052] = "CTRL_UE_DL_RLC_STATS_RSP"
msg_type_to_name[0x0053] = "CTRL_UE_UL_RLC_STATS_RSP"
msg_type_to_name[0x0054] = "CTRL_UE_DL_MAC_STATS_RSP"
msg_type_to_name[0x0055] = "CTRL_UE_UL_MAC_STATS_RSP"
msg_type_to_name[0x0056] = "CTRL_CELL_STATS_DL_HARQ_RSP"
msg_type_to_name[0x0057] = "CTRL_CELL_STATS_PDSCH_RSP"
msg_type_to_name[0x0058] = "CTRL_CELL_STATS_UL_HARQ_RSP"
msg_type_to_name[0x0059] = "CTRL_CELL_STATS_PUSCH_RSP"
msg_type_to_name[0x005a] = "CTRL_CELL_STATS_RISE_RSP"
msg_type_to_name[0x005b] = "CTRL_CELL_STATS_DL_RLC_RSP"
msg_type_to_name[0x005c] = "CTRL_CELL_STATS_UL_RLC_RSP"
msg_type_to_name[0x005d] = "CTRL_CELL_STATS_DL_MAC_RSP"
msg_type_to_name[0x005e] = "CTRL_CELL_STATS_UL_MAC_RSP"
msg_type_to_name[0x005f] = "CTRL_CELL_STATS_DRX_RSP"
msg_type_to_name[0x0060] = "CTRL_CELL_STATS_RS_TX_POWER_RSP"
msg_type_to_name[0x0061] = "CTRL_CELL_STATS_PHY_RSP"
msg_type_to_name[0x0062] = "CTRL_CELL_STATS_UE_FAILURE_RSP"
msg_type_to_name[0x0063] = "CTRL_CELL_STATS_DSP_CPU_UTIL_RSP"
msg_type_to_name[0x0064] = "CTRL_UE_UPDATE_RADIO_STATE"
msg_type_to_name[0x0065] = "CTRL_UE_UPDATE_SCELL_LIST"
msg_type_to_name[0x0066] = "CTRL_UE_FLUSH_REQ"
msg_type_to_name[0x0067] = "CTRL_UE_FLUSH_IND"
msg_type_to_name[0x0068] = "CTRL_RLC_SRB1_ACK"
msg_type_to_name[0x0069] = "CTRL_UE_SR_EXHAUSTION"
msg_type_to_name[0x006a] = "CTRL_UE_SECURITY"
msg_type_to_name[0x006b] = "CTRL_UE_SCH_STATS_RSP"
msg_type_to_name[0x006c] = "CTRL_CELL_STATS_SCH_RSP"
msg_type_to_name[0x006d] = "CTRL_CELL_PARAM_REQ"
msg_type_to_name[0x006e] = "CTRL_ERR_REESTAB_IND"
msg_type_to_name[0x006f] = "CTRL_UE_TIME_ADJUSTMENT"
msg_type_to_name[0x0070] = "CTRL_UE_FADING"
msg_type_to_name[0x0071] = "CTRL_TTI_TRACE_BITMAP"
msg_type_to_name[0x0072] = "CTRL_CELL_STATS_MBMS_RSP"
msg_type_to_name[0x0073] = "CTRL_SUBCELL_STATS_REQ"
msg_type_to_name[0x0074] = "CTRL_SUBCELL_STATS_RSP"
msg_type_to_name[0x0075] = "CTRL_UE_PHY_PARAM"
msg_type_to_name[0x0076] = "CTRL_CQI_TABLE_TX"
msg_type_to_name[0x0077] = "CTRL_HARQ_TABLE_TX"
msg_type_to_name[0x0078] = "CTRL_POWER_DENSITY_TABLE_TX"
msg_type_to_name[0x0079] = "CTRL_TABLE_ACK"
msg_type_to_name[0x007a] = "CTRL_HARQ_GENERATOR"
msg_type_to_name[0x007b] = "CTRL_CELLC_READY_ACTIVE"
msg_type_to_name[0x007c] = "CTRL_CELLC_MCI_READY_SIB2_IND"
msg_type_to_name[0x007d] = "CTRL_MCI_READY_ACTIVE"
msg_type_to_name[0x007e] = "CTRL_UE_CHANGE_MASTER_PHY"
msg_type_to_name[0x007f] = "CTRL_UE_NOISE"
msg_type_to_name[0x0080] = "CTRL_RB_TX_STATE"
msg_type_to_name[0x0081] = "CTRL_CELL_RECONF_INFO"
msg_type_to_name[0x0082] = "DL_BCCH_SCH_BR"
msg_type_to_name[0x0083] = "CTRL_SIB1_BR"
msg_type_to_name[0x0084] = "CTRL_SIB2_BR"
msg_type_to_name[0x0085] = "CTRL_SIB2_BR_RSP"
msg_type_to_name[0x0086] = "DL_BCCH_BCH_NB"
msg_type_to_name[0x0087] = "DL_BCCH_SCH_NB"
msg_type_to_name[0x0088] = "DL_PCCH_NB"
msg_type_to_name[0x0089] = "CTRL_SIB1_NB"
msg_type_to_name[0x008a] = "CTRL_SIB2_NB"
msg_type_to_name[0x008b] = "CTRL_SIB2_NB_RSP"
msg_type_to_name[0x008c] = "SIM_DSP_PROFILING"
msg_type_to_name[0x008d] = "CTRL_CELL_STATS_LAA_CELL_COUNTERS_RSP"
msg_type_to_name[0x008e] = "CTRL_CONN_IND"
msg_type_to_name[0x008f] = "CTRL_UE_FREQUENCY_OFFSET"
msg_type_to_name[0x0090] = "CTRL_CELL_STATS_ENERGY_MEAS_RSP"
msg_type_to_name[0x0091] = "CTRL_ADD_UE_DC"
msg_type_to_name[0x0092] = "CTRL_ADD_UE_DC_RSP"
msg_type_to_name[0x0093] = "CTRL_CELL_STATS_LAA_SUBBANDS_COUNTERS_RSP"
msg_type_to_name[0x0094] = "CTRL_CELL_STATS_LAA_DCS_COUNTERS_RSP"
msg_type_to_name[0x0095] = "CTRL_CELL_STATS_LAA_RADARS_COUNTERS_RSP"
msg_type_to_name[0x0096] = "CTRL_SUBBAND_CHANGE_IND"
msg_type_to_name[0x0097] = "CTRL_UE_DL_BEAM_STATS_RSP"
msg_type_to_name[0x0098] = "DL_CRLC_IPHY_MSG_IND"
msg_type_to_name[0x0099] = "UL_CRLC_IPHY_MSG_IND"
msg_type_to_name[0x009a] = "CTRL_CELL_STATS_DL_BEAM_COUNTERS_RSP"
msg_type_to_name[0x009b] = "CTRL_UE_RBR_QUERY"
msg_type_to_name[0x009c] = "CTRL_UE_MAC_RBR"
msg_type_to_name[0x009d] = "CTRL_RLF_IND"
msg_type_to_name[0x009e] = "CTRL_UE_ADDMODREL_SCELL"
msg_type_to_name[0x009f] = "CTRL_UE_ADDMODREL_SCELL_RSP"
msg_type_to_name[0x00a0] = "CTRL_UE_RRC_CONN_RELEASE_IND"
msg_type_to_name[0x00a1] = "CTRL_UE_RRC_CONN_RELEASE_DROPPED_IND"
msg_type_to_name[0x00a2] = "CTRL_CUS_CELL_CONFIG_IND"
msg_type_to_name[0x00a3] = "CTRL_UE_UL_MAC_ERROR"
msg_type_to_name[0x00a4] = "CTRL_ENB_CELL_CONFIG_IND"
msg_type_to_name[0x00a5] = "DL_PCCH_MULTI"
msg_type_to_name[0x00a6] = "CTRL_RFM_FILTER_UPDATE"
msg_type_to_name[0x00a7] = "CTRL_PET_SE_STATUS_RESULT_IND"
-- Mapping of message types to message names.
-- The order of messages in this section should correspond to the order of the messages
-- in the "#define PROXY_PROTO_MSG_AP_MAP" section of ProxyProto_AP.h.
msg_type_to_name[0x00a8] = "CTRL_CELL_STATS_THRUPUT_NR_REQ"
msg_type_to_name[0x00a9] = "CTRL_CELL_STATS_THRUPUT_NR_RSP"
msg_type_to_name[0x00aa] = "CTRL_QFI_OR_BEARER_STATS"
msg_type_to_name[0x00ab] = "CTRL_QFI_OR_BEARER_STATS_RSP"
msg_type_to_name[0x00ac] = "CTRL_TRAFFIC_COMMAND_IND"
msg_type_to_name[0x00af] = "CTRL_CG_CONFIG_CLUBBED_RSP"
msg_type_to_name[0x00b0] = "CTRL_MIB_NR"
msg_type_to_name[0x00b1] = "CTRL_ADD_UE_NR"
msg_type_to_name[0x00b2] = "CTRL_ADD_UE_NR_RSP"
msg_type_to_name[0x00b3] = "DL_SHORT_MESSAGE"
msg_type_to_name[0x00b4] = "CTRL_UE_MEAS_CONF_NR"
msg_type_to_name[0x00b5] = "CTRL_AP_TESTMODE_ADDMOD"
msg_type_to_name[0x00b6] = "CTRL_CG_CONFIG"
msg_type_to_name[0x00b7] = "CTRL_CG_CONFIG_RSP"
msg_type_to_name[0x00b8] = "CTRL_ADD_UE_HO_NR"
msg_type_to_name[0x00b9] = "CTRL_ADD_UE_HO_NR_RSP"
msg_type_to_name[0x00ba] = "CTRL_SIB1_NR"
msg_type_to_name[0x00bb] = "CTRL_AP_L2_TESTMODE_PARAMS"
msg_type_to_name[0x00bc] = "CTRL_AP_UE_TESTMODE_SET_DAS_AREA"
msg_type_to_name[0x00bd] = "CTRL_AP_TEST_BLER_NR"
msg_type_to_name[0x00be] = "CTRL_AP_UE_TESTMODE_SET_NR"
msg_type_to_name[0x00bf] = "CTRL_AP_TEST_PHR_OVERRIDE_NR"
msg_type_to_name[0x00c0] = "CTRL_AP_TEST_UL_SINR_NR"
msg_type_to_name[0x00c1] = "CTRL_UE_MOD_NR"
msg_type_to_name[0x00c2] = "CTRL_UE_MOD_NR_RSP"
msg_type_to_name[0x00c3] = "CTRL_UE_ADDMOD_SCELL_NR"
msg_type_to_name[0x00c4] = "CTRL_AP_TEST_BEAM_CONTROL"
msg_type_to_name[0x00c5] = "CTRL_AP_GEN_TESTMODE_NR"
msg_type_to_name[0x00c6] = "CTRL_AP_TEST_SRS_UPLINK_BEAMFORMING"
msg_type_to_name[0x00c7] = "CTRL_UE_STATS_REQ_NR"
msg_type_to_name[0x00c8] = "CTRL_UE_STATS_CLR_NR"
msg_type_to_name[0x00c9] = "CTRL_UE_PDSCH_STATS_NR_RSP"
msg_type_to_name[0x00ca] = "CTRL_CRNTI_UPDATE"
msg_type_to_name[0x00cb] = "CTRL_UE_DCI_STATS_NR_RSP"
msg_type_to_name[0x00cc] = "CTRL_CELL_STATS_REQ_NR"
msg_type_to_name[0x00cd] = "CTRL_CELL_STATS_CLEAR_NR"
msg_type_to_name[0x00ce] = "CTRL_CELL_STATS_SCH_NR_RSP"
msg_type_to_name[0x00cf] = "CTRL_CELL_STATUS_NR"
msg_type_to_name[0x00d0] = "CTRL_CELL_STATUS_NR_RSP"
msg_type_to_name[0x00d1] = "CTRL_UE_PUSCH_STATS_NR_RSP"
msg_type_to_name[0x00d2] = "CTRL_AP_SIM_DEBUG_LOG_PARAMS"
msg_type_to_name[0x00d3] = "CTRL_AP_CELL_TESTMODE_SET_NR"
msg_type_to_name[0x00d4] = "CTRL_CELL_SYNC_STATUS_NR"
msg_type_to_name[0x00d5] = "CTRL_CELL_SYNC_STATUS_NR_RSP"
msg_type_to_name[0x00d6] = "CTRL_CELL_LINK_STATUS_REQ_NR"
msg_type_to_name[0x00d7] = "CTRL_CELL_LINK_STATUS_RSP_NR"
msg_type_to_name[0x00d8] = "CTRL_UE_CG_STATS_NR_RSP"
msg_type_to_name[0x00d9] = "UL_CCCH1"
msg_type_to_name[0x00da] = "CTRL_CELL_CONFIGURATION_STATUS_NR"
msg_type_to_name[0x00db] = "CTRL_BEAM_INFO_OTA_REQ_NR"
msg_type_to_name[0x00de] = "CTRL_TRAFFIC_CONFIGURATION_IND"
msg_type_to_name[0x00df] = "CTRL_CG_CONFIG_CLUBBED"
msg_type_to_name[0x00e0] = "CTRL_RU_TIME_ALGO_UPDATE_NR"
msg_type_to_name[0x00e1] = "CTRL_RU_TIME_ALGO_DISP_NR"
msg_type_to_name[0x00e2] = "CTRL_UE_MEAS_REPORT_NR"
msg_type_to_name[0x00e3] = "CTRL_UE_MEAS_CONFIG_NR"
msg_type_to_name[0x00e4] = "CTRL_PHYCELLID_CHANGE_NR"
msg_type_to_name[0x00e5] = "CTRL_CELL_SEARCH_TRIGGER_OTA_NR"
msg_type_to_name[0x00e6] = "CTRL_EXT_TRAFFIC_CONFIGURATION_IND_RSP"
msg_type_to_name[0x00e7] = "CTRL_CASCADED_MESSAGE_NR"
msg_type_to_name[0x00e8] = "CTRL_CASCADED_MESSAGE_NR_RSP"
msg_type_to_name[0x00e9] = "CTRL_OTA_CAPTURE_ACTIVATION_REQ"
msg_type_to_name[0x00ea] = "CTRL_OTA_CAPTURE_DEACTIVATION_REQ"
msg_type_to_name[0x00eb] = "CTRL_OTA_CAPTURE_ACTIVATION_RESP"
msg_type_to_name[0x00ec] = "CTRL_OTA_CAPTURE_DEACTIVATION_RESP"
msg_type_to_name[0x00ed] = "CTRL_CAPTURE_READY_IND"
msg_type_to_name[0x00ee] = "CTRL_SUSPICIOUS_EVENT_IND"

-- Mapping of message types to message names.
-- -- The order of messages in this section should correspond to the order of the messages
-- -- in the "#define PROXY_PROTO_MSG_CUS_MAP" section of ProxyProto_CUS.h.

msg_type_to_name[0x02e0] = "ENDC_CONN"
msg_type_to_name[0x02e1] = "ENDC_CONN_RESP"
msg_type_to_name[0x02e2] = "ENDC_CELL_STATUS_UPDATE"
msg_type_to_name[0x02e3] = "ENDC_CELL_STATUS_UPDATE_RSP"
msg_type_to_name[0x02e4] = "ENDC_CREATE_UE_CONTEXT"
msg_type_to_name[0x02e5] = "ENDC_RRC_RECONFIG"
msg_type_to_name[0x02e6] = "ENDC_RRC_RECONFIG_COMPLETE"
msg_type_to_name[0x02e7] = "ENDC_RRC_RECONFIG_FAILURE"
msg_type_to_name[0x02e8] = "ENDC_RELEASE"
msg_type_to_name[0x02e9] = "ENDC_RELEASE_ACK"
msg_type_to_name[0x02ea] = "ENDC_MEASUREMENT_REQ"
msg_type_to_name[0x02eb] = "ENDC_MEASUREMENT_RSP"
msg_type_to_name[0x02ec] = "ENDC_DL_DTCH"
msg_type_to_name[0x02ed] = "ENDC_UL_DTCH"
msg_type_to_name[0x02ee] = "ENDC_HANDLE_NON_SCG_RECONFIG_MSG"
msg_type_to_name[0x02ef] = "ENDC_HANDLE_NON_SCG_RECONFIG_RSP_MSG"
msg_type_to_name[0x02f0] = "ENDC_RLC_DELIV_IND"
msg_type_to_name[0x02f1] = "ENDC_UE_SUSPEND"
msg_type_to_name[0x02f2] = "ENDC_UE_RESUME"
msg_type_to_name[0x02f3] = "ENDC_UE_MEAS_CONF_NR"

local function add_ctrl_update_ue_cqi_mapping(msg_id)
	if (msg_type_to_name[msg_id] ~= nil) then
		return
	end
	for cell=0,7 do
		for csi_set=0,1 do
			local msg_name = "CTRL_UPDATE_UE_CQI.cqi" .. "." .. cell .. "." .. csi_set
			msg_type_to_name[msg_id] = msg_name
			msg_id = msg_id + 1
			msg_name = msg_name..".ue_native_cqi"
			msg_type_to_name[msg_id] = msg_name
			msg_id = msg_id + 1
			msg_type_to_name[msg_id] = msg_name..".wb"
			msg_id = msg_id + 1
			for sb_num = 0,12 do
				msg_type_to_name[msg_id] = msg_name..".sb." .. sb_num
				msg_id = msg_id + 1
			end
		end
	end
end

-- List of supplementary structs used by the messages and the structs themselves.
-- These structs are mostly declared using "DECLARE_PACKED" in ProxyProto.h.
-- In contrast to messages, these structs are not declared in the
-- "#define PROXY_PROTO_MSG_MAP" section of ProxyProto.h
do
	-- Some large random offset to separate the messages from structs.
	-- ProxyProto messages and supplementary structs are very similar,
	-- so it might not be substantially beneficial to maintain separate tables for
	-- supplementary structs.
	local offset = 10000

	local structs =
	{
		  "MBSFN_COMMON_SF_ALLOC"
		, "MBSFN_SUBFRAME_CONFIG"
		, "PMCH_CONFIG"
		, "MBMS_SESSION_INFO"
		, "PMCH_AND_SESSION_INFO"
		, "TIME_ADJUSTMENT"
		, "CELL_MBMS_MAC_STATS"
		, "RATE"
		, "B_DL_RLC_DCCH"
		, "DL_RLC_DCCH_DTCH_NON_CC"
		, "DL_RLC_DCCH_DTCH_CC"
		, "RB_DL_RLC_DCCH"
	}

	for index, name in ipairs(structs) do
		offset = offset + index
		msg_type_to_name[offset] = name
	end

	offset = offset + 1
	add_ctrl_update_ue_cqi_mapping(offset)
end

--  Constants from sim_capacity.h and gtp_proto.h
local SIM_MAX_UEC_QTY           = 16
local SIM_MAX_ENB_QTY           = 254
local SIM_MAX_GNB_QTY           = 254
local SIM_MAX_CELL_PER_ENB_QTY  = 257
local SIM_MAX_CELL_PER_GNB_QTY  = 257
local TEID_BASE                 = 0x0010
local UEC_TEID_BASE             = TEID_BASE
local AIRPHONE_L2HI_TEID_BASE   = 0x14
local UEC_UPLANE_TEID_BASE      = SIM_MAX_UEC_QTY * SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + UEC_TEID_BASE
local UECDL_TEID_MARKER         = SIM_MAX_UEC_QTY * SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + UEC_UPLANE_TEID_BASE
local UECTRL_TEID_BASE          = UEC_TEID_BASE + SIM_MAX_CELL_PER_ENB_QTY + UECDL_TEID_MARKER
local SCH_TEID_BASE             = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + UECTRL_TEID_BASE
local MAC_TEID_BASE             = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + SCH_TEID_BASE
local RLCDL_TEID_BASE           = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + MAC_TEID_BASE
local MAC_CORE_TEID_BASE        = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + RLCDL_TEID_BASE
local END_USED_TEID             = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY + MAC_CORE_TEID_BASE
local AIRPHONE_L2PROXY_TEID_BASE = SIM_MAX_GNB_QTY * SIM_MAX_CELL_PER_GNB_QTY + AIRPHONE_L2HI_TEID_BASE
local SIM_MAX_TRAFFICS_PER_BEARER = 32

-- Constants to be used for deriving cell ID from TEID
local TOTAL_POSSIBLE_CELLS      = SIM_MAX_ENB_QTY * SIM_MAX_CELL_PER_ENB_QTY;
local MAX_TEID                  = MAC_CORE_TEID_BASE + TOTAL_POSSIBLE_CELLS - 1;

local MAC_CELLGROUP_CONFIG_T_SIZE = 76
local PHYSICAL_CELL_GROUP_CONFIG_T_SIZE = 19
local SPCELL_CONFIG_T_SIZE = 15613
local SUB_HDR_T_SIZE = 12

-- Initialization of tables
local msg_name_to_type = {}
local msg_type_to_display_name = {}
for type, name in pairs(msg_type_to_name) do
	msg_name_to_type[name] = type
	msg_type_to_display_name[type] = string.gsub(name, "_", "-")..' '
	msg_field_name[type] = {}
end

-- Extract TEID field from GTP header
local f_gtp_teid       = Field.new("gtp.teid")

-- Common fields for messages
local f_hdr_proto_type    = ProtoField.new   ("Protocol Type", proxyproto_filter..".protocol.type", ftypes.UINT16, {[0x3233] = 'I-PHY PoC '}, base.HEX)
local f_hdr_proto_nr_type = ProtoField.new   ("Protocol Type", proxyproto_filter..".protocol.type", ftypes.UINT16, {[0x3433] = 'AirPhone PoC '}, base.HEX)
local f_hdr_msg_type      = ProtoField.new   ("Message Type", proxyproto_filter..".message.type", ftypes.UINT16, msg_type_to_display_name, base.HEX)
local f_hdr_enb_id        = ProtoField.uint16(proxyproto_filter..".enb_id", "eNodeB ID", base.DEC)
local f_hdr_cell_id       = ProtoField.uint16(proxyproto_filter..".cell_id", "Cell ID", base.DEC)
local f_remaining_data    = ProtoField.new   ("L3 Message Data", proxyproto_filter..".data", ftypes.BYTES, base.NONE)

-- Default method for generating a ProtoField
local function generate_default_protofield(num_bytes, filter, name, radix)
	local protofield

	if name == "direction" then
        protofield = direction_enum
	elseif name == "version" then
        protofield = version_enum
	elseif name == "traffic_type" then
		protofield = traffic_type_enum
	elseif name == "ipv4_address" then
        protofield = ipv4_field
	elseif name == "ipv6_address" then
        protofield = ipv6_field
	elseif num_bytes == 1 then
		protofield = ProtoField.uint8 (filter, name, radix)
	elseif num_bytes == 2 then
		protofield = ProtoField.uint16(filter, name, radix)
	elseif num_bytes == 4 then
		protofield = ProtoField.uint32(filter, name, radix)
	elseif num_bytes == 8 then
		protofield = ProtoField.uint64(filter, name, radix)
	elseif num_bytes == 3000 then  -- 3000 is arbitrary value to decide to decode as ipv4 ... could be enhanced surely
		protofield = ProtoField.ipv4(filter, name, ftypes.HEX, nil, base.HEX)
	else
		protofield = ProtoField.new(name, filter, ftypes.BYTES, nil, base.NONE)
	end

	return protofield
end

local function initialize_ue_id_field(mtype, field_filter)
	msg_field_name[mtype].ue_id = "UE Id"
	msg_field_filter[mtype].ue_id = proxyproto_filter..field_filter..".ue_id"
	msg_field_radix[mtype].ue_id = base.DEC
	msg_field_num_bytes[mtype].ue_id = 2
end

local function register_ue_id_field(mtype)
	msg_field_proto[mtype].ue_id = ProtoField.uint16(
		msg_field_filter[mtype].ue_id, msg_field_name[mtype].ue_id, msg_field_radix[mtype].ue_id)
end

local function initialize_global_ue_id_field(mtype, field_filter)
	msg_field_name[mtype].global_ue_id = "Global UE Id"
	msg_field_filter[mtype].global_ue_id = proxyproto_filter..field_filter..".global_ue_id"
	msg_field_radix[mtype].global_ue_id = base.DEC
	msg_field_num_bytes[mtype].global_ue_id = 2
end

local function register_global_ue_id_field(mtype)
	msg_field_proto[mtype].global_ue_id = ProtoField.uint16(
		msg_field_filter[mtype].global_ue_id, msg_field_name[mtype].global_ue_id, msg_field_radix[mtype].global_ue_id)
end

local function initialize_local_ue_id_field(mtype, field_filter)
	msg_field_name[mtype].local_ue_id = "Local UE Id"
	msg_field_filter[mtype].local_ue_id = proxyproto_filter..field_filter..".local_ue_id"
	msg_field_radix[mtype].local_ue_id = base.DEC
	msg_field_num_bytes[mtype].local_ue_id = 2
end

local function register_local_ue_id_field(mtype)
	msg_field_proto[mtype].local_ue_id = ProtoField.uint16(
		msg_field_filter[mtype].local_ue_id, msg_field_name[mtype].local_ue_id, msg_field_radix[mtype].local_ue_id)
end

local function initialize_mac_main_config_data_inactivity_timer_r14_field(mtype, field_filter)
	msg_field_name[mtype].mac_main_config_data_inactivity_timer_r14 = "Data Inactivity Timer R14"
	msg_field_filter[mtype].mac_main_config_data_inactivity_timer_r14 = proxyproto_filter..field_filter..".mac_main_config.data_inactivity_timer_r14"
	msg_field_radix[mtype].mac_main_config_data_inactivity_timer_r14 = base.DEC
	msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14 = 1
end

local function register_mac_main_config_data_inactivity_timer_r14_field(mtype)
	msg_field_proto[mtype].mac_main_config_data_inactivity_timer_r14 = ProtoField.uint8(
		msg_field_filter[mtype].mac_main_config_data_inactivity_timer_r14,
		msg_field_name[mtype].mac_main_config_data_inactivity_timer_r14,
		msg_field_radix[mtype].mac_main_config_data_inactivity_timer_r14)
end

-- Default method for registering the fields of a message as protocol fields
local function default_registration(mtype, protocol)
	for i, _ in pairs(msg_field_name[mtype]) do
		msg_field_proto[mtype][i] = generate_default_protofield(msg_field_num_bytes[mtype][i], msg_field_filter[mtype][i], msg_field_name[mtype][i], msg_field_radix[mtype][i])
		protocol.fields[#protocol.fields + 1] = msg_field_proto[mtype][i]
	end
end

-- Default method for dissecting a message.
-- This method assumes that the fields of a message are indexed as consecutive integers starting from 1.
-- Should not use this method for a message whose fields are indexed by name instead of integer.
local function default_dissection(mtype, buffer, pinfo, tree, offset)
	for i = 1, #msg_field_name[mtype] do
		local num_bytes = msg_field_num_bytes[mtype][i]
		if (msg_field_num_bytes[mtype][i] == 3000) then num_bytes = 4
		end
			tree:add(msg_field_proto[mtype][i], buffer(offset, num_bytes));
		offset = offset + num_bytes
	end

	return offset
end

-- Method for dissecting the embedded RRC message of an I-PHY message
local function dissect_rrc(buffer, pinfo, tree, offset, len_num_bytes, dissector_name, pdcp_adjust)
	local remaining_bytes = buffer:len() - offset

	if remaining_bytes > 0 then
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));

		local rrc_len = buffer(offset - len_num_bytes, len_num_bytes):uint()
		local dis = Dissector.get(dissector_name)

		dis:call(buffer(offset + pdcp_adjust, rrc_len - pdcp_adjust):tvb(), pinfo, tree_arr[0])
	end
end

local function dissect_ul_dcch(mtype, buffer, pinfo, tree, offset)
	tree:add(msg_field_proto[mtype].ue_id, buffer(offset, msg_field_num_bytes[mtype].ue_id));
	offset = offset + msg_field_num_bytes[mtype].ue_id
	tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id));
	offset = offset + msg_field_num_bytes[mtype].local_ue_id
	tree:add(msg_field_proto[mtype].logical_channel_id, buffer(offset, msg_field_num_bytes[mtype].logical_channel_id));
	offset = offset + msg_field_num_bytes[mtype].logical_channel_id
	tree:add(msg_field_proto[mtype].sdu_id_present, buffer(offset, msg_field_num_bytes[mtype].sdu_id_present));
	offset = offset + msg_field_num_bytes[mtype].sdu_id_present
	tree:add(msg_field_proto[mtype].sdu_id, buffer(offset, msg_field_num_bytes[mtype].sdu_id));
	offset = offset + msg_field_num_bytes[mtype].sdu_id
	tree:add(msg_field_proto[mtype].len, buffer(offset, msg_field_num_bytes[mtype].len));
	offset = offset + msg_field_num_bytes[mtype].len

	protocol_type = get_protocol_type(buffer)
	if protocol_type == lte_protocol_type then
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_dcch_ie_name, 1)
	elseif protocol_type == nr_protocol_type then
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_dcch_nr_ie_name, 2)
	end
end

local function dissect_ul_ccch(mtype, buffer, pinfo, tree, offset)
	tree:add(msg_field_proto[mtype].ue_id, buffer(offset, msg_field_num_bytes[mtype].ue_id));
	offset = offset + msg_field_num_bytes[mtype].ue_id
	tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id));
	offset = offset + msg_field_num_bytes[mtype].local_ue_id
	tree:add(msg_field_proto[mtype].c_rnti, buffer(offset, msg_field_num_bytes[mtype].c_rnti));
	offset = offset + msg_field_num_bytes[mtype].c_rnti
	tree:add(msg_field_proto[mtype].rapid, buffer(offset, msg_field_num_bytes[mtype].rapid));
	offset = offset + msg_field_num_bytes[mtype].rapid
	tree:add(msg_field_proto[mtype].ramask, buffer(offset, msg_field_num_bytes[mtype].ramask));
	offset = offset + msg_field_num_bytes[mtype].ramask

	tree:add("Extra mask:")
	tree:add(msg_field_proto[mtype].sim_nacks_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_nacks_msg3));
	tree:add(msg_field_proto[mtype].sim_nacks_msg4, buffer(offset, msg_field_num_bytes[mtype].sim_nacks_msg4));
	tree:add(msg_field_proto[mtype].sim_dtxs_msg3,  buffer(offset, msg_field_num_bytes[mtype].sim_dtxs_msg3));
	offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg4
	tree:add("Extra error:")
	tree:add(msg_field_proto[mtype].sim_num_nacks_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_num_nacks_msg3));
	offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg3
	tree:add(msg_field_proto[mtype].sim_num_dtxs_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_num_dtxs_msg3));
	offset = offset + msg_field_num_bytes[mtype].sim_dtxs_msg3
	tree:add(msg_field_proto[mtype].sim_num_nacks_msg4, buffer(offset, msg_field_num_bytes[mtype].sim_num_nacks_msg4));
	offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg4
	tree:add(msg_field_proto[mtype].turn_enc_off, buffer(offset, msg_field_num_bytes[mtype].turn_enc_off));
	offset = offset + msg_field_num_bytes[mtype].turn_enc_off
	tree:add(msg_field_proto[mtype].red_cap_ue, buffer(offset, msg_field_num_bytes[mtype].red_cap_ue));
	offset = offset + msg_field_num_bytes[mtype].red_cap_ue
	tree:add(msg_field_proto[mtype].len, buffer(offset, msg_field_num_bytes[mtype].len));
	offset = offset + msg_field_num_bytes[mtype].len

	protocol_type = get_protocol_type(buffer)
	if protocol_type == lte_protocol_type then
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_ccch_ie_name, 0)
	elseif protocol_type == nr_protocol_type then
		if get_len(buffer) == 8 then
		    dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_ccch1_nr_ie_name, 0)
		else
		    dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_ccch_nr_ie_name, 0)
		end
	end
end

local function initialize_common_ul_dcch_ul_ccch_fields(mtype, field_filter)
	initialize_ue_id_field(mtype, field_filter)
	initialize_local_ue_id_field(mtype, field_filter)

	msg_field_name[mtype].len = "L3 Message Length"
	msg_field_filter[mtype].len = proxyproto_filter..field_filter..".len"
	msg_field_radix[mtype].len = base.DEC
	msg_field_num_bytes[mtype].len = 2
end

local function initialize_ul_dcch_fields(mtype, field_filter)
	msg_field_name[mtype].logical_channel_id = "Logical channel ID"
	msg_field_filter[mtype].logical_channel_id = proxyproto_filter..field_filter..".logical_channel_id"
	msg_field_radix[mtype].logical_channel_id = base.DEC
	msg_field_num_bytes[mtype].logical_channel_id = 1

	msg_field_name[mtype].sdu_id_present = "SDU id present"
	msg_field_filter[mtype].sdu_id_present = proxyproto_filter..field_filter..".sdu_id_present"
	msg_field_radix[mtype].sdu_id_present = base.HEX
	msg_field_num_bytes[mtype].sdu_id_present = 1

	msg_field_name[mtype].sdu_id = "SDU id"
	msg_field_filter[mtype].sdu_id = proxyproto_filter..field_filter..".sdu_id"
	msg_field_radix[mtype].sdu_id = base.HEX
	msg_field_num_bytes[mtype].sdu_id = 4
end

local function initialize_ul_ccch_fields(mtype, field_filter)
	msg_field_name[mtype].c_rnti = "C-RNTI"
	msg_field_filter[mtype].c_rnti = proxyproto_filter..field_filter..".c_rnti"
	msg_field_radix[mtype].c_rnti = base.HEX
	msg_field_num_bytes[mtype].c_rnti = 2

	msg_field_name[mtype].rapid = "Rapid"
	msg_field_filter[mtype].rapid = proxyproto_filter..field_filter..".rapid"
	msg_field_radix[mtype].rapid = base.DEC
	msg_field_num_bytes[mtype].rapid = 1

	msg_field_name[mtype].ramask = "Ramask"
	msg_field_filter[mtype].ramask = proxyproto_filter..field_filter..".ramask"
	msg_field_radix[mtype].ramask = base.HEX
	msg_field_num_bytes[mtype].ramask = 1

	-- extra_mask
	msg_field_name[mtype].sim_nacks_msg3 = "Simulated NACKs for MSG3"
	msg_field_filter[mtype].sim_nacks_msg3 = proxyproto_filter..field_filter..".sim_nacks_msg3"
	msg_field_radix[mtype].sim_nacks_msg3 = 8
	msg_field_num_bytes[mtype].sim_nacks_msg3 = 1

	msg_field_name[mtype].sim_dtxs_msg3 = "Simulated DTXs for MSG3"
	msg_field_filter[mtype].sim_dtxs_msg3 = proxyproto_filter..field_filter..".sim_dtxs_msg3"
	msg_field_radix[mtype].sim_dtxs_msg3 = 8
	msg_field_num_bytes[mtype].sim_dtxs_msg3 = 1

	msg_field_name[mtype].sim_nacks_msg4 = "Simulated NACKs for MSG4"
	msg_field_filter[mtype].sim_nacks_msg4 = proxyproto_filter..field_filter..".sim_nacks_msg4"
	msg_field_radix[mtype].sim_nacks_msg4 = 8
	msg_field_num_bytes[mtype].sim_nacks_msg4 = 1

	-- extra_error
	msg_field_name[mtype].sim_num_nacks_msg3 = "Number of MSG3 NACKs"
	msg_field_filter[mtype].sim_num_nacks_msg3 = proxyproto_filter..field_filter..".sim_num_nacks_msg3"
	msg_field_radix[mtype].sim_num_nacks_msg3 = base.DEC
	msg_field_num_bytes[mtype].sim_num_nacks_msg3 = 1

	msg_field_name[mtype].sim_num_dtxs_msg3 = "Number of MSG3 DTXs"
	msg_field_filter[mtype].sim_num_dtxs_msg3 = proxyproto_filter..field_filter..".sim_num_dtxs_msg3"
	msg_field_radix[mtype].sim_num_dtxs_msg3 = base.DEC
	msg_field_num_bytes[mtype].sim_num_dtxs_msg3 = 1

	msg_field_name[mtype].sim_num_nacks_msg4 = "Number of MSG4 NACKs"
	msg_field_filter[mtype].sim_num_nacks_msg4 = proxyproto_filter..field_filter..".sim_num_nacks_msg4"
	msg_field_radix[mtype].sim_num_nacks_msg4 = base.DEC
	msg_field_num_bytes[mtype].sim_num_nacks_msg4 = 1

	msg_field_name[mtype].turn_enc_off = "Turn encryption off"
	msg_field_filter[mtype].turn_enc_off = proxyproto_filter..field_filter..".turn_enc_off"
	msg_field_radix[mtype].turn_enc_off = base.DEC
	msg_field_num_bytes[mtype].turn_enc_off = 1

	msg_field_name[mtype].red_cap_ue = "Red Cap UE"
	msg_field_filter[mtype].red_cap_ue = proxyproto_filter..field_filter..".red_cap_ue"
	msg_field_radix[mtype].red_cap_ue = base.DEC
	msg_field_num_bytes[mtype].red_cap_ue = 1
end

local function register_common_ul_dcch_ul_ccch_fields(mtype)
	register_ue_id_field(mtype)
	register_local_ue_id_field(mtype)
	msg_field_proto[mtype].len = ProtoField.uint16(msg_field_filter[mtype].len, msg_field_name[mtype].len, msg_field_radix[mtype].len)
end

local function register_ul_dcch_fields(mtype)
	msg_field_proto[mtype].logical_channel_id = ProtoField.uint8(msg_field_filter[mtype].logical_channel_id, msg_field_name[mtype].logical_channel_id, msg_field_radix[mtype].logical_channel_id)
	msg_field_proto[mtype].sdu_id_present = ProtoField.uint8(msg_field_filter[mtype].sdu_id_present, msg_field_name[mtype].sdu_id_present, msg_field_radix[mtype].sdu_id_present)
	msg_field_proto[mtype].sdu_id = ProtoField.uint32(msg_field_filter[mtype].sdu_id, msg_field_name[mtype].sdu_id, msg_field_radix[mtype].sdu_id)
end

local function register_ul_ccch_fields(mtype)
	msg_field_proto[mtype].c_rnti = ProtoField.uint16(msg_field_filter[mtype].c_rnti, msg_field_name[mtype].c_rnti, msg_field_radix[mtype].c_rnti)
	msg_field_proto[mtype].rapid = ProtoField.uint8(msg_field_filter[mtype].rapid, msg_field_name[mtype].rapid, msg_field_radix[mtype].rapid)
	msg_field_proto[mtype].ramask = ProtoField.uint8(msg_field_filter[mtype].ramask, msg_field_name[mtype].ramask, msg_field_radix[mtype].ramask)
	msg_field_proto[mtype].sim_nacks_msg3 = ProtoField.new(msg_field_name[mtype].sim_nacks_msg3, msg_field_filter[mtype].sim_nacks_msg3, ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_nacks_msg3, 0x1)
	msg_field_proto[mtype].sim_nacks_msg4 = ProtoField.new(msg_field_name[mtype].sim_nacks_msg4, msg_field_filter[mtype].sim_nacks_msg4, ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_nacks_msg4, 0x2)
	msg_field_proto[mtype].sim_dtxs_msg3  = ProtoField.new(msg_field_name[mtype].sim_dtxs_msg3,  msg_field_filter[mtype].sim_dtxs_msg3,  ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_dtxs_msg3,  0x4)
	msg_field_proto[mtype].sim_num_nacks_msg3 = ProtoField.uint8(msg_field_filter[mtype].sim_num_nacks_msg3, msg_field_name[mtype].sim_num_nacks_msg3, msg_field_radix[mtype].sim_num_nacks_msg3)
	msg_field_proto[mtype].sim_num_dtxs_msg3 = ProtoField.uint8(msg_field_filter[mtype].sim_num_dtxs_msg3, msg_field_name[mtype].sim_num_dtxs_msg3, msg_field_radix[mtype].sim_num_dtxs_msg3)
	msg_field_proto[mtype].sim_num_nacks_msg4 = ProtoField.uint8(msg_field_filter[mtype].sim_num_nacks_msg4, msg_field_name[mtype].sim_num_nacks_msg4, msg_field_radix[mtype].sim_num_nacks_msg4)
	msg_field_proto[mtype].turn_enc_off = ProtoField.new(msg_field_name[mtype].turn_enc_off, msg_field_filter[mtype].turn_enc_off, ftypes.UINT8, {[0] = "security enabled ", [1] = "security disabled "}, msg_field_radix[mtype].turn_enc_off)
	msg_field_proto[mtype].red_cap_ue = ProtoField.new(msg_field_name[mtype].red_cap_ue, msg_field_filter[mtype].red_cap_ue, ftypes.UINT8, {[0] = "redcap disabled ", [1] = "redcap enabled "}, msg_field_radix[mtype].red_cap_ue)
end

-- Method for calculating the cell ID, given the TEID in GTP-U header.
-- Return value is displayed in proxyproto.cell_id.
local function derive_cell_id_from_teid(teid)
	local offset       = 0
	local consider_uec = false

	if (teid > MAX_TEID) then
		return 0    -- ERROR: TEID should be less than or equal to MAX_TEID

	elseif (teid >= MAC_CORE_TEID_BASE) then
		offset = MAC_CORE_TEID_BASE

	elseif (teid >= RLCDL_TEID_BASE) then
		offset = RLCDL_TEID_BASE

	elseif (teid >= MAC_TEID_BASE) then
		offset = MAC_TEID_BASE

	elseif (teid >= SCH_TEID_BASE) then
		offset = SCH_TEID_BASE

	elseif (teid >= UECTRL_TEID_BASE) then
		offset = UECTRL_TEID_BASE

	elseif (teid >= UECDL_TEID_MARKER) then
		return 0, 0    -- ERROR: No TEIDs are defined from UECDL_TEID_MARKER to (UECTRL_TEID_BASE-1) inclusive

	elseif (teid >= UEC_UPLANE_TEID_BASE) then
		offset = UEC_UPLANE_TEID_BASE
		consider_uec = true

	elseif (teid >= AIRPHONE_L2PROXY_TEID_BASE ) then
		offset = AIRPHONE_L2PROXY_TEID_BASE

	elseif (teid >= UEC_TEID_BASE) then
		offset = UEC_TEID_BASE
		consider_uec = true

	else
		return 0, 0    -- ERROR: TEID should be greater than or equal to UEC_TEID_BASE
	end

	local unshifted = teid - offset

	if (consider_uec) then
		uec_id = (unshifted / TOTAL_POSSIBLE_CELLS) + 1
		unshifted = unshifted % TOTAL_POSSIBLE_CELLS
	end

	local enb_id  = unshifted / SIM_MAX_CELL_PER_ENB_QTY
	local cell_id = unshifted % SIM_MAX_CELL_PER_ENB_QTY + 1

	return enb_id, cell_id
end

-- The following sections are example customizations for the dissection of I-PHY messages.
-- Here you can define the attributes of message fields, how these fields are registered as protocol fields,
-- and how these fields will be dissected. Basically, each section below corresponds to the DECLARE_PACKED
-- struct definition of the corresponding message found in ProxyProto.h.

do
    local mtype = msg_name_to_type.CTRL_ADD_MOD_RB

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "Local UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "UPDATE Mode")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".update_mode")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "RB Addition to Cell")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".rb_addition_to_cell")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
    local mtype = msg_name_to_type.CTRL_ADD_MOD_RB_RSP

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "LCID")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "Is UlTeId Valid")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".isUlTeIdValid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "UlTeId")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".UlTeId")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 4)

    table.insert(msg_field_name[mtype], "RESULT")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".result")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
    local mtype = msg_name_to_type.CTRL_DEL_RB

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "Local UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "LCID")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
    local mtype = msg_name_to_type.CTRL_DEL_RB_RSP

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "LCID")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "RESULT")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".result")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
	local mtype = msg_name_to_type.CTRL_UE_SUSPEND
	msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "Local UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "MAC RESET")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".mac_reset")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SRB BITMAP")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".srb_bitmap")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 4)
end

do
	local mtype = msg_name_to_type.CTRL_UE_RACH_COMPLETE
	msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "TC-RNTI")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".tc_rnti")
    table.insert(msg_field_radix[mtype], base.HEX)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "TIMING ADV")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".timing_adv")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "TX COUNT")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".tx_count")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "STATUS")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".status")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
	local mtype = msg_name_to_type.CTRL_RLC_REESTAB_REQ
	msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "LCID")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
	local mtype = msg_name_to_type.CTRL_RLC_REESTAB_COMPLETE
	msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "LCID")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "IS DL")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".is_dl")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)
end

do
    local mname = "CTRL_CRNTI_UPDATE"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}
    msg_fields = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "C-RNTI")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".crnti")
    table.insert(msg_field_radix[mtype], base.HEX)
    table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
    local mname = "CTRL_ADD_UE_NR"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    local msg_fields = {}
    local fname

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	fname = "isCompressed"
	msg_fields[1] = fname
	msg_field_name[mtype][fname] = "SUB HDR IsCompressed"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "compressedMsgSize"
	msg_fields[2] = fname
	msg_field_name[mtype][fname] = "SUB HDR Compressed MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "originalMsgSize"
	msg_fields[3] = fname
	msg_field_name[mtype][fname] = "SUB HDR Orignal MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "ue_id"
	msg_fields[4] = fname
	msg_field_name[mtype][fname] = "SUB HDR Global UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "sub_hdr_lcid"
	msg_fields[5] = fname
	msg_field_name[mtype][fname] = "SUB HDR LCID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "sub_hdr_reserved"
	msg_fields[6] = fname
	msg_field_name[mtype][fname] = "SUB HDR Reserved"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

    fname = "global_ue_id"
    msg_fields[7] = fname
    msg_field_name[mtype][fname] = "Global UE ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 2

    fname = "c_rnti"
    msg_fields[8] = fname
    msg_field_name[mtype][fname] = "C-RNTI"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 2

    fname = "ue_add_cause"
    msg_fields[9] = fname
    msg_field_name[mtype][fname] = "Ue Add Cause"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "type_of_uplane_traffic"
    msg_fields[10] = fname
    msg_field_name[mtype][fname] = "Type Of Uplane Traffic"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "cell_group_id"
    msg_fields[11] = fname
    msg_field_name[mtype][fname] = "Cell Group Id"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "max_tx_power"
    msg_fields[12] = fname
    msg_field_name[mtype][fname] = "Max Tx Power"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "cfo_filter_coefficient"
    msg_fields[13] = fname
    msg_field_name[mtype][fname] = "Cfo Filter Coefficient"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 2

    msg_register_fields[mtype] = function(protocol)
		msg_field_proto[mtype].isCompressed = ProtoField.uint8(msg_field_filter[mtype].isCompressed, msg_field_name[mtype].isCompressed, msg_field_radix[mtype].isCompressed)
		msg_field_proto[mtype].compressedMsgSize = ProtoField.uint16(msg_field_filter[mtype].compressedMsgSize, msg_field_name[mtype].compressedMsgSize, msg_field_radix[mtype].compressedMsgSize)
		msg_field_proto[mtype].originalMsgSize = ProtoField.uint16(msg_field_filter[mtype].originalMsgSize, msg_field_name[mtype].originalMsgSize, msg_field_radix[mtype].originalMsgSize)
		msg_field_proto[mtype].ue_id = ProtoField.uint16(msg_field_filter[mtype].ue_id, msg_field_name[mtype].ue_id, msg_field_radix[mtype].ue_id)
		msg_field_proto[mtype].sub_hdr_lcid = ProtoField.uint8(msg_field_filter[mtype].sub_hdr_lcid, msg_field_name[mtype].sub_hdr_lcid, msg_field_radix[mtype].sub_hdr_lcid)
		msg_field_proto[mtype].sub_hdr_reserved = ProtoField.uint32(msg_field_filter[mtype].sub_hdr_reserved, msg_field_name[mtype].sub_hdr_reserved, msg_field_radix[mtype].sub_hdr_reserved)	

		msg_field_proto[mtype].global_ue_id = ProtoField.uint16(msg_field_filter[mtype].global_ue_id, msg_field_name[mtype].global_ue_id, msg_field_radix[mtype].global_ue_id)
		msg_field_proto[mtype].c_rnti = ProtoField.uint16(msg_field_filter[mtype].c_rnti, msg_field_name[mtype].c_rnti, msg_field_radix[mtype].c_rnti)
		msg_field_proto[mtype].ue_add_cause = ProtoField.uint8(msg_field_filter[mtype].ue_add_cause, msg_field_name[mtype].ue_add_cause, msg_field_radix[mtype].ue_add_cause)
		msg_field_proto[mtype].type_of_uplane_traffic = ProtoField.uint8(msg_field_filter[mtype].type_of_uplane_traffic, msg_field_name[mtype].type_of_uplane_traffic, msg_field_radix[mtype].type_of_uplane_traffic)
		msg_field_proto[mtype].cell_group_id = ProtoField.uint8(msg_field_filter[mtype].cell_group_id, msg_field_name[mtype].cell_group_id, msg_field_radix[mtype].cell_group_id)
		msg_field_proto[mtype].max_tx_power = ProtoField.uint8(msg_field_filter[mtype].max_tx_power, msg_field_name[mtype].max_tx_power, msg_field_radix[mtype].max_tx_power)
		msg_field_proto[mtype].cfo_filter_coefficient = ProtoField.uint16(msg_field_filter[mtype].cfo_filter_coefficient, msg_field_name[mtype].cfo_filter_coefficient, msg_field_radix[mtype].cfo_filter_coefficient)
	
		for _, proto_field in pairs(msg_field_proto[mtype]) do
            table.insert(protocol.fields, proto_field)
        end
    end

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		for _, fieldname in pairs(msg_fields) do
			tree:add(msg_field_proto[mtype][fieldname], buffer(offset, msg_field_num_bytes[mtype][fieldname]))
            offset = offset + msg_field_num_bytes[mtype][fieldname]
			if fieldname == "sub_hdr_reserved" then
				local isCompressed = buffer(offset-SUB_HDR_T_SIZE, 1):uint()
				if isCompressed == 1 then 
					local remaining_bytes = buffer:len() - offset
					tree:add(f_remaining_data, buffer(offset, remaining_bytes));
					break 
				end
			end
        end
    end
end


do
	local mname = "CTRL_DEL_UE"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mname = "CTRL_DEL_UE_RSP"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_del_ue_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end

end

do
	local mname = "CTRL_ADD_UE_NR_RSP"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_nr_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
    local mname = "CTRL_ADD_UE_HO_NR"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    local msg_fields = {}
    local fname

	fname = "isCompressed"
	msg_fields[1] = fname
	msg_field_name[mtype][fname] = "SUB HDR IsCompressed"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "compressedMsgSize"
	msg_fields[2] = fname
	msg_field_name[mtype][fname] = "SUB HDR Compressed MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "originalMsgSize"
	msg_fields[3] = fname
	msg_field_name[mtype][fname] = "SUB HDR Orignal MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "ue_id"
	msg_fields[4] = fname
	msg_field_name[mtype][fname] = "SUB HDR Global UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "sub_hdr_lcid"
	msg_fields[5] = fname
	msg_field_name[mtype][fname] = "SUB HDR LCID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "sub_hdr_reserved"
	msg_fields[6] = fname
	msg_field_name[mtype][fname] = "SUB HDR Reserved"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

    fname = "global_ue_id"
    msg_fields[7] = fname
    msg_field_name[mtype][fname] = "Global UE ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 2

    fname = "c_rnti"
    msg_fields[8] = fname
    msg_field_name[mtype][fname] = "C-RNTI"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 2

    fname = "cell_group_id"
    msg_fields[9] = fname
    msg_field_name[mtype][fname] = "Cell Group Id"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "max_tx_power"
    msg_fields[10] = fname
    msg_field_name[mtype][fname] = "Max Tx Power"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "cfo_filter_coefficient"
    msg_fields[11] = fname
    msg_field_name[mtype][fname] = "Cfo Filter Coefficient"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 2

    fname = "ue_add_cause"
    msg_fields[12] = fname
    msg_field_name[mtype][fname] = "Ue Add Cause"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "type_of_uplane_traffic"
    msg_fields[13] = fname
    msg_field_name[mtype][fname] = "Type Of Uplane Traffic"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "num_rbs"
    msg_fields[14] = fname
    msg_field_name[mtype][fname] = "Num Rbs"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "num_of_scells"
    msg_fields[21] = fname
    msg_field_name[mtype][fname] = "Num Of SCells"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "is_gbr"
    msg_fields[22] = fname
    msg_field_name[mtype][fname] = "Is Gbr"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "uplane_ip"
    msg_fields[23] = fname
    msg_field_name[mtype][fname] = "Uplane Ip"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 4

    fname = "uplane_port"
    msg_fields[24] = fname
    msg_field_name[mtype][fname] = "Uplane Port"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 4

    fname = "te_id"
    msg_fields[25] = fname
    msg_field_name[mtype][fname] = "Te Id"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 4

    msg_register_fields[mtype] = function(protocol)
		msg_field_proto[mtype].isCompressed = ProtoField.uint8(msg_field_filter[mtype].isCompressed, msg_field_name[mtype].isCompressed, msg_field_radix[mtype].isCompressed)
		msg_field_proto[mtype].compressedMsgSize = ProtoField.uint16(msg_field_filter[mtype].compressedMsgSize, msg_field_name[mtype].compressedMsgSize, msg_field_radix[mtype].compressedMsgSize)
		msg_field_proto[mtype].originalMsgSize = ProtoField.uint16(msg_field_filter[mtype].originalMsgSize, msg_field_name[mtype].originalMsgSize, msg_field_radix[mtype].originalMsgSize)
		msg_field_proto[mtype].ue_id = ProtoField.uint16(msg_field_filter[mtype].ue_id, msg_field_name[mtype].ue_id, msg_field_radix[mtype].ue_id)
		msg_field_proto[mtype].sub_hdr_lcid = ProtoField.uint8(msg_field_filter[mtype].sub_hdr_lcid, msg_field_name[mtype].sub_hdr_lcid, msg_field_radix[mtype].sub_hdr_lcid)
		msg_field_proto[mtype].sub_hdr_reserved = ProtoField.uint32(msg_field_filter[mtype].sub_hdr_reserved, msg_field_name[mtype].sub_hdr_reserved, msg_field_radix[mtype].sub_hdr_reserved)	

        msg_field_proto[mtype].global_ue_id = ProtoField.uint16(msg_field_filter[mtype].global_ue_id, msg_field_name[mtype].global_ue_id, msg_field_radix[mtype].global_ue_id)
        msg_field_proto[mtype].c_rnti = ProtoField.uint16(msg_field_filter[mtype].c_rnti, msg_field_name[mtype].c_rnti, msg_field_radix[mtype].c_rnti)
        msg_field_proto[mtype].cell_group_id = ProtoField.uint8(msg_field_filter[mtype].cell_group_id, msg_field_name[mtype].cell_group_id, msg_field_radix[mtype].cell_group_id)
        msg_field_proto[mtype].max_tx_power = ProtoField.uint8(msg_field_filter[mtype].max_tx_power, msg_field_name[mtype].max_tx_power, msg_field_radix[mtype].max_tx_power)
        msg_field_proto[mtype].cfo_filter_coefficient = ProtoField.uint16(msg_field_filter[mtype].cfo_filter_coefficient, msg_field_name[mtype].cfo_filter_coefficient, msg_field_radix[mtype].cfo_filter_coefficient)
        msg_field_proto[mtype].ue_add_cause = ProtoField.uint8(msg_field_filter[mtype].ue_add_cause, msg_field_name[mtype].ue_add_cause, msg_field_radix[mtype].ue_add_cause)
        msg_field_proto[mtype].type_of_uplane_traffic = ProtoField.uint8(msg_field_filter[mtype].type_of_uplane_traffic, msg_field_name[mtype].type_of_uplane_traffic, msg_field_radix[mtype].type_of_uplane_traffic)
        msg_field_proto[mtype].num_rbs = ProtoField.uint8(msg_field_filter[mtype].num_rbs, msg_field_name[mtype].num_rbs, msg_field_radix[mtype].num_rbs)
        msg_field_proto[mtype].num_of_scells = ProtoField.uint8(msg_field_filter[mtype].num_of_scells, msg_field_name[mtype].num_of_scells, msg_field_radix[mtype].num_of_scells)
        msg_field_proto[mtype].is_gbr = ProtoField.uint8(msg_field_filter[mtype].is_gbr, msg_field_name[mtype].is_gbr, msg_field_radix[mtype].is_gbr)
        msg_field_proto[mtype].uplane_ip = ProtoField.ipv4(msg_field_filter[mtype].uplane_ip, msg_field_name[mtype].uplane_ip, ftypes.HEX, nil, base.HEX)
        msg_field_proto[mtype].uplane_port = ProtoField.uint32(msg_field_filter[mtype].uplane_port, msg_field_name[mtype].uplane_port, msg_field_radix[mtype].uplane_port)
        msg_field_proto[mtype].te_id = ProtoField.uint32(msg_field_filter[mtype].te_id, msg_field_name[mtype].te_id, msg_field_radix[mtype].te_id)

        for _, proto_field in pairs(msg_field_proto[mtype]) do
            table.insert(protocol.fields, proto_field)
        end
    end

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "isCompressed"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "compressedMsgSize"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "originalMsgSize"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "ue_id"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "sub_hdr_lcid"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "sub_hdr_reserved"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "global_ue_id"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "c_rnti"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "cell_group_id"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "max_tx_power"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "cfo_filter_coefficient"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "ue_add_cause"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "type_of_uplane_traffic"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "num_rbs"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        offset = offset + 48 * 19 -- PRX_RB_CFG_T
        offset = offset + 60 * 19 -- PRX_PDCP_CFG_T
        offset = offset + MAC_CELLGROUP_CONFIG_T_SIZE            -- MAC_CELLGROUP_CONFIG_T
        offset = offset + PHYSICAL_CELL_GROUP_CONFIG_T_SIZE      -- PHYSICAL_CELL_GROUP_CONFIG_T
        offset = offset + 2                                      -- RLF_TIMERS_AND_CONSTANTS_T
        offset = offset + SPCELL_CONFIG_T_SIZE                   -- SPCELL_CONFIG_T

        fname = "num_of_scells"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "is_gbr"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "uplane_ip"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "uplane_port"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        fname = "te_id"
        tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
        offset = offset + msg_field_num_bytes[mtype][fname]

        return offset
    end
end

do 
	local mname = "CTRL_ADD_UE_HO_NR_RSP"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2) 

	table.insert(msg_field_name[mtype], "Local UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_ho_nr_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
    local mname = "CTRL_UE_MOD_NR"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)


    local msg_fields = {}
    local fname

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	fname = "isCompressed"
	msg_fields[1] = fname
	msg_field_name[mtype][fname] = "SUB HDR IsCompressed"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "compressedMsgSize"
	msg_fields[2] = fname
	msg_field_name[mtype][fname] = "SUB HDR Compressed MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "originalMsgSize"
	msg_fields[3] = fname
	msg_field_name[mtype][fname] = "SUB HDR Orignal MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "ue_id"
	msg_fields[4] = fname
	msg_field_name[mtype][fname] = "SUB HDR Global UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "sub_hdr_lcid"
	msg_fields[5] = fname
	msg_field_name[mtype][fname] = "SUB HDR LCID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "sub_hdr_reserved"
	msg_fields[6] = fname
	msg_field_name[mtype][fname] = "SUB HDR Reserved"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

    fname = "global_ue_id"
    msg_fields[7] = fname
    msg_field_name[mtype][fname] = "Global UE ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 2

    fname = "c_rnti"
    msg_fields[8] = fname
    msg_field_name[mtype][fname] = "C-RNTI"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 2

    fname = "cell_group_id"
    msg_fields[9] = fname
    msg_field_name[mtype][fname] = "CELL GROUP ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "max_tx_power"
    msg_fields[10] = fname
    msg_field_name[mtype][fname] = "MAX TX POWER"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "cfo_filter_coefficient"
    msg_fields[11] = fname
    msg_field_name[mtype][fname] = "CFO FILTER COEFFICIENT"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 2

	msg_register_fields[mtype] = function(protocol)
		msg_field_proto[mtype].isCompressed = ProtoField.uint8(msg_field_filter[mtype].isCompressed, msg_field_name[mtype].isCompressed, msg_field_radix[mtype].isCompressed)
		msg_field_proto[mtype].compressedMsgSize = ProtoField.uint16(msg_field_filter[mtype].compressedMsgSize, msg_field_name[mtype].compressedMsgSize, msg_field_radix[mtype].compressedMsgSize)
		msg_field_proto[mtype].originalMsgSize = ProtoField.uint16(msg_field_filter[mtype].originalMsgSize, msg_field_name[mtype].originalMsgSize, msg_field_radix[mtype].originalMsgSize)
		msg_field_proto[mtype].ue_id = ProtoField.uint16(msg_field_filter[mtype].ue_id, msg_field_name[mtype].ue_id, msg_field_radix[mtype].ue_id)
		msg_field_proto[mtype].sub_hdr_lcid = ProtoField.uint8(msg_field_filter[mtype].sub_hdr_lcid, msg_field_name[mtype].sub_hdr_lcid, msg_field_radix[mtype].sub_hdr_lcid)
		msg_field_proto[mtype].sub_hdr_reserved = ProtoField.uint32(msg_field_filter[mtype].sub_hdr_reserved, msg_field_name[mtype].sub_hdr_reserved, msg_field_radix[mtype].sub_hdr_reserved)	

        msg_field_proto[mtype].global_ue_id = ProtoField.uint16(msg_field_filter[mtype].global_ue_id, msg_field_name[mtype].global_ue_id, msg_field_radix[mtype].global_ue_id)
        msg_field_proto[mtype].c_rnti = ProtoField.uint16(msg_field_filter[mtype].c_rnti, msg_field_name[mtype].c_rnti, msg_field_radix[mtype].c_rnti)
        msg_field_proto[mtype].cell_group_id = ProtoField.uint8(msg_field_filter[mtype].cell_group_id, msg_field_name[mtype].cell_group_id, msg_field_radix[mtype].cell_group_id)
        msg_field_proto[mtype].max_tx_power = ProtoField.uint8(msg_field_filter[mtype].max_tx_power, msg_field_name[mtype].max_tx_power, msg_field_radix[mtype].max_tx_power)
        msg_field_proto[mtype].cfo_filter_coefficient = ProtoField.uint16(msg_field_filter[mtype].cfo_filter_coefficient, msg_field_name[mtype].cfo_filter_coefficient, msg_field_radix[mtype].cfo_filter_coefficient)
        for _, proto_field in pairs(msg_field_proto[mtype]) do
            table.insert(protocol.fields, proto_field)
        end
    end

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
        for _, fieldname in ipairs(msg_fields) do
            tree:add(msg_field_proto[mtype][fieldname], buffer(offset, msg_field_num_bytes[mtype][fieldname]));
            offset = offset + msg_field_num_bytes[mtype][fieldname]
			if fieldname == "sub_hdr_reserved" then
				local isCompressed = buffer(offset-SUB_HDR_T_SIZE, 1):uint()
				if isCompressed == 1 then 
					local remaining_bytes = buffer:len() - offset
					tree:add(f_remaining_data, buffer(offset, remaining_bytes));
					break 
				end
			end
        end
    end
end

do
    local mname = "CTRL_UE_ADDMOD_SCELL_NR"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    local msg_fields = {}
    local fname

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

	fname = "isCompressed"
	msg_fields[1] = fname
	msg_field_name[mtype][fname] = "SUB HDR IsCompressed"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "compressedMsgSize"
	msg_fields[2] = fname
	msg_field_name[mtype][fname] = "SUB HDR Compressed MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "originalMsgSize"
	msg_fields[3] = fname
	msg_field_name[mtype][fname] = "SUB HDR Orignal MSG Size"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "ue_id"
	msg_fields[4] = fname
	msg_field_name[mtype][fname] = "SUB HDR Global UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "sub_hdr_lcid"
	msg_fields[5] = fname
	msg_field_name[mtype][fname] = "SUB HDR LCID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "sub_hdr_reserved"
	msg_fields[6] = fname
	msg_field_name[mtype][fname] = "SUB HDR Reserved"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

    fname = "global_ue_id"
    msg_fields[7] = fname
    msg_field_name[mtype][fname] = "Global UE ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.HEX
    msg_field_num_bytes[mtype][fname] = 2

	msg_register_fields[mtype] = function(protocol)
		msg_field_proto[mtype].isCompressed = ProtoField.uint8(msg_field_filter[mtype].isCompressed, msg_field_name[mtype].isCompressed, msg_field_radix[mtype].isCompressed)
		msg_field_proto[mtype].compressedMsgSize = ProtoField.uint16(msg_field_filter[mtype].compressedMsgSize, msg_field_name[mtype].compressedMsgSize, msg_field_radix[mtype].compressedMsgSize)
		msg_field_proto[mtype].originalMsgSize = ProtoField.uint16(msg_field_filter[mtype].originalMsgSize, msg_field_name[mtype].originalMsgSize, msg_field_radix[mtype].originalMsgSize)
		msg_field_proto[mtype].ue_id = ProtoField.uint16(msg_field_filter[mtype].ue_id, msg_field_name[mtype].ue_id, msg_field_radix[mtype].ue_id)
		msg_field_proto[mtype].sub_hdr_lcid = ProtoField.uint8(msg_field_filter[mtype].sub_hdr_lcid, msg_field_name[mtype].sub_hdr_lcid, msg_field_radix[mtype].sub_hdr_lcid)
		msg_field_proto[mtype].sub_hdr_reserved = ProtoField.uint32(msg_field_filter[mtype].sub_hdr_reserved, msg_field_name[mtype].sub_hdr_reserved, msg_field_radix[mtype].sub_hdr_reserved)	

        msg_field_proto[mtype].global_ue_id = ProtoField.uint16(msg_field_filter[mtype].global_ue_id, msg_field_name[mtype].global_ue_id, msg_field_radix[mtype].global_ue_id)
        
        for _, proto_field in pairs(msg_field_proto[mtype]) do
            table.insert(protocol.fields, proto_field)
        end
    end

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
        for _, fieldname in ipairs(msg_fields) do
            tree:add(msg_field_proto[mtype][fieldname], buffer(offset, msg_field_num_bytes[mtype][fieldname]));
            offset = offset + msg_field_num_bytes[mtype][fieldname]
			if fieldname == "sub_hdr_reserved" then
				local isCompressed = buffer(offset-SUB_HDR_T_SIZE, 1):uint()
				if isCompressed == 1 then 
					local remaining_bytes = buffer:len() - offset
					tree:add(f_remaining_data, buffer(offset, remaining_bytes));
					break 
				end
			end
        end
    end
end

do
	local mname = "CTRL_UE_MOD_NR_RSP"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2) 

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_mod_nr_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mtype = msg_name_to_type.CTRL_CONN

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Proxy ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.proxy_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UEC IP")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_ip")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "UEC IP U-Plane 0")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_ip_uplane_0")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "UEC IP U-Plane 1")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_ip_uplane_1")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "UEC IP U-Plane 2")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_ip_uplane_2")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "UEC Port")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_port")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UEC U-Plane Port 0")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_uplane_port_0")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UEC U-Plane Port 1")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_uplane_port_1")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UEC U-Plane Port 2")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uec_uplane_port_2")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RLC DL ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RLC DL IP 0")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_ip_0")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "RLC DL IP 1")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_ip_1")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "RLC DL IP 2")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_ip_2")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 3000)

	table.insert(msg_field_name[mtype], "RLC DL Port 0")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_port_0")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RLC DL Port 1")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_port_1")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RLC DL Port 2")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.rlc_dl_port_2")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SCTP C-plane")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.sctp_cplane")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Log Bitmap Array")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.log_bitmap.array")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 16)

	table.insert(msg_field_name[mtype], "TTI Trace Bitmap Array")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.tti_trace_bitmap.array")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Master ENB UT ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.master_enb_ut_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Is UEC MBMS")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.is_uec_mbms")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "total amount of UECs")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.uecs_amount")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCP decryption mode")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.pdcp_decryption")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "nr pdcp integrity protection")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.nr_pdcp_integrity_protection")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	
	table.insert(msg_field_name[mtype], "Multiple L2NRT Mode Enabled")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_conn.is_multipleL2NrtModeEnabled")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)
end

do
	local mtype = msg_name_to_type.CTRL_ADD_UE

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue.global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)
end

do
	local mtype = msg_name_to_type.CTRL_ADD_UE_RSP

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_rsp.global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_rsp.local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)
end

do
	local mname = "TIME_ADJUSTMENT"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	local fname

	fname = "mask"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "rach_delay"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "shr_adjust"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_register_fields[mtype] = function(protocol)
		fname = "mask"
			msg_field_proto[mtype][fname] = generate_default_protofield(msg_field_num_bytes[mtype][fname], msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])
		fname = "rach_delay"
			msg_field_proto[mtype][fname] = generate_default_protofield(msg_field_num_bytes[mtype][fname], msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])
		fname = "shr_adjust"
			msg_field_proto[mtype][fname] = ProtoField.int8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

		for _, proto_field in pairs (msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "mask"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "rach_delay"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "shr_adjust"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		return offset
	end
end

do
	local mname = "CTRL_UE_TIME_ADJUSTMENT"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	local fname

	fname = "global_ue_id"
	msg_field_name[mtype][fname] = "Global UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "local_ue_id"
	msg_field_name[mtype][fname] = "Local UE ID"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "global_ue_id"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "local_ue_id"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		subtree1 = tree:add("ta_data_tag[] 4 elements")
		for i=0,3 do
			local subtree2 = subtree1:add("ta_data_stag[" .. i .."]")
			offset = msg_dissect[msg_name_to_type.TIME_ADJUSTMENT](buffer, pinfo, subtree2, offset)
		end
	end
end

do
	local mtype = msg_name_to_type.DL_BCCH_BCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	-- Customizing the dissection method for this message
	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		protocol_type = get_protocol_type(buffer)

		if protocol_type == lte_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_bch_ie_name, 0)
		elseif protocol_type == nr_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_bch_nr_ie_name, 0)
		end
	end
end

do
	local mtype = msg_name_to_type.DL_BCCH_SCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "xsfn")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".xsfn")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "rv index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".rv_index")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		protocol_type = get_protocol_type(buffer)

		if protocol_type == lte_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_dl_sch_ie_name, 0)
		elseif protocol_type == nr_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_dl_sch_nr_ie_name, 0)
		end
	end
end

do
	local mtype = msg_name_to_type.DL_BCCH_SCH_BR

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "xsfn")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".xsfn")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "rv index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".rv_index")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_dl_sch_br_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.DL_PCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "NHF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nhf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NSF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nsf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PNB")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".dl_pcch.pnb")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		protocol_type = get_protocol_type(buffer)

		if protocol_type == lte_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], pcch_ie_name, 0)
		elseif protocol_type == nr_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], pcch_nr_ie_name, 0)
		end
	end
end

do
	local mtype = msg_name_to_type.DL_PCCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "NHF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nhf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NSF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nsf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PNB")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".dl_pcch.pnb")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], pcch_nb_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.DL_CCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "C-RNTI")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".c_rnti")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		protocol_type = get_protocol_type(buffer)

		if protocol_type == lte_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], dl_ccch_ie_name, 0)
		elseif protocol_type == nr_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], dl_ccch_nr_ie_name, 0)
		end
	end
end

do
	local mtype = msg_name_to_type.DL_CCCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "C-RNTI")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".c_rnti")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], dl_ccch_nb_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.DL_DCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	initialize_ue_id_field(mtype, "")

	msg_field_name[mtype].logical_channel_id = "Logical channel ID"
	msg_field_filter[mtype].logical_channel_id = proxyproto_filter..".logical_channel_id"
	msg_field_radix[mtype].logical_channel_id = base.DEC
	msg_field_num_bytes[mtype].logical_channel_id = 1

	msg_field_name[mtype].encryption = "Encryption (EEA)"
	msg_field_filter[mtype].encryption = proxyproto_filter..".encryption"
	msg_field_radix[mtype].encryption = base.DEC
	msg_field_num_bytes[mtype].encryption = 1

	msg_field_name[mtype].integrity = "Integrity (EIA)"
	msg_field_filter[mtype].integrity = proxyproto_filter..".integrity"
	msg_field_radix[mtype].integrity = base.DEC
	msg_field_num_bytes[mtype].integrity = 1

	msg_field_name[mtype].len = "L3 Message Length"
	msg_field_filter[mtype].len = proxyproto_filter..".len"
	msg_field_radix[mtype].len = base.DEC
	msg_field_num_bytes[mtype].len = 2

	-- Customizing the registration of fields for this message
	msg_register_fields[mtype] = function(protocol)
		register_ue_id_field(mtype)
		msg_field_proto[mtype].logical_channel_id = ProtoField.uint8(msg_field_filter[mtype].logical_channel_id, msg_field_name[mtype].logical_channel_id, msg_field_radix[mtype].logical_channel_id)
		msg_field_proto[mtype].encryption = ProtoField.new(msg_field_name[mtype].encryption, msg_field_filter[mtype].encryption, ftypes.UINT8, nil, msg_field_radix[mtype].encryption, 0xF0)
		msg_field_proto[mtype].integrity = ProtoField.new(msg_field_name[mtype].integrity, msg_field_filter[mtype].integrity, ftypes.UINT8, nil, msg_field_radix[mtype].integrity, 0x0F)
		msg_field_proto[mtype].len = ProtoField.uint16(msg_field_filter[mtype].len, msg_field_name[mtype].len, msg_field_radix[mtype].len)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].ue_id, buffer(offset, msg_field_num_bytes[mtype].ue_id));
		offset = offset + msg_field_num_bytes[mtype].ue_id
		tree:add(msg_field_proto[mtype].logical_channel_id, buffer(offset, msg_field_num_bytes[mtype].logical_channel_id));
		offset = offset + msg_field_num_bytes[mtype].logical_channel_id
		tree:add("Security:")
		tree:add(msg_field_proto[mtype].encryption, buffer(offset, msg_field_num_bytes[mtype].encryption));
		tree:add(msg_field_proto[mtype].integrity, buffer(offset, msg_field_num_bytes[mtype].integrity));
		offset = offset + msg_field_num_bytes[mtype].integrity
		tree:add(msg_field_proto[mtype].len, buffer(offset, msg_field_num_bytes[mtype].len));
		offset = offset + msg_field_num_bytes[mtype].len

		protocol_type = get_protocol_type(buffer)

		if protocol_type == lte_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, dl_dcch_ie_name, 1)
		elseif protocol_type == nr_protocol_type then
			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, dl_dcch_nr_ie_name, 2)
		end

	end
end

do
	local mtype = msg_name_to_type.DL_DCCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Logical channel ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".logical_channel_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], dl_dcch_nb_ie_name, 0)
	end
end

local function data_inact_timer_val_to_str(timer_value)
	local inact_timer_str_to_add = "deactivated"
	if timer_value > 0 then
		inact_timer_str_to_add = "seconds"
	end
	return inact_timer_str_to_add
end

do
	local mtype = msg_name_to_type.CTRL_UE_RR_CONFIG_DEDICATED

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	-- CTRL_UE_RR_CONFIG_DEDICATED Fields
	local field_filter = ".ctrl_ue_rr_config_dedicated"
	initialize_global_ue_id_field(mtype, field_filter)
	initialize_local_ue_id_field(mtype, field_filter)
	initialize_mac_main_config_data_inactivity_timer_r14_field(mtype, field_filter)

	msg_register_fields[mtype] = function(protocol)
		register_global_ue_id_field(mtype)
		register_local_ue_id_field(mtype)
		register_mac_main_config_data_inactivity_timer_r14_field(mtype)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].global_ue_id, buffer(offset, msg_field_num_bytes[mtype].global_ue_id))
		offset = offset + msg_field_num_bytes[mtype].global_ue_id
		tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id))
        offset = offset + msg_field_num_bytes[mtype].local_ue_id

        offset = offset + 1 -- bit_mask
		offset = offset + 63 -- MAC_MAIN_CONFIG_T members up to dataInactivityTimer_r14

		local inact_timer_val = buffer(offset, msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14):uint()
		local inact_timer_str_to_add = data_inact_timer_val_to_str(inact_timer_val)
		tree:add(msg_field_proto[mtype].mac_main_config_data_inactivity_timer_r14, buffer(offset, msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14)):append_text(" ("..inact_timer_str_to_add..")")
		offset = offset + msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14
	end
end

do
	local mtype = msg_name_to_type.CTRL_UE_RRC_CONN_RELEASE_DROPPED_IND

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	-- CTRL_UE_RRC_CONN_RELEASE_DROPPED_IND Fields
	local field_filter = ".ctrl_ue_rrc_conn_release_dropped_ind"
	initialize_global_ue_id_field(mtype, field_filter)
	initialize_local_ue_id_field(mtype, field_filter)

	-- Customizing the registration of fields for this message
	msg_register_fields[mtype] = function(protocol)
		register_global_ue_id_field(mtype)
		register_local_ue_id_field(mtype)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].global_ue_id, buffer(offset, msg_field_num_bytes[mtype].global_ue_id))
		offset = offset + msg_field_num_bytes[mtype].global_ue_id
		tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id))
		offset = offset + msg_field_num_bytes[mtype].local_ue_id
	end
end

local function get_ctrl_ue_rrc_conn_release_ind_release_cause_name(release_cause_value)
	local name = "UNKNOWN"
	if release_cause_value == 1 then name = "DATA_INACTIVITY_TIMER_EXPR"
	end
	return name
end

do
	local mtype = msg_name_to_type.CTRL_UE_RRC_CONN_RELEASE_IND

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	-- CTRL_UE_RRC_CONN_RELEASE_IND Fields
	local field_filter = ".ctrl_ue_rrc_conn_release_ind"
	initialize_global_ue_id_field(mtype, field_filter)

	msg_field_name[mtype].release_cause = "Release Cause"
	msg_field_filter[mtype].release_cause = proxyproto_filter..field_filter..".release_cause"
	msg_field_radix[mtype].release_cause = base.DEC
	msg_field_num_bytes[mtype].release_cause = 1

	-- Customizing the registration of fields for this message
	msg_register_fields[mtype] = function(protocol)
		register_global_ue_id_field(mtype)
		msg_field_proto[mtype].release_cause = ProtoField.uint8(msg_field_filter[mtype].release_cause, msg_field_name[mtype].release_cause, msg_field_radix[mtype].release_cause)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].global_ue_id, buffer(offset, msg_field_num_bytes[mtype].global_ue_id))
		offset = offset + msg_field_num_bytes[mtype].global_ue_id
		local release_cause_value = buffer(offset, msg_field_num_bytes[mtype].release_cause):uint()
		local release_cause_name = get_ctrl_ue_rrc_conn_release_ind_release_cause_name(release_cause_value)
		tree:add(msg_field_proto[mtype].release_cause, buffer(offset, msg_field_num_bytes[mtype].release_cause)):append_text(" ("..release_cause_name..")")
		offset = offset + msg_field_num_bytes[mtype].release_cause
	end
end

do
    local mname = "CTRL_CELL_STATUS_NR"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}
    msg_fields = {}

    local fname

    fname = "cell_id"
    msg_fields[1] = fname
    msg_field_name[mtype][fname] = "CELL ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "enb_id"
    msg_fields[2] = fname
    msg_field_name[mtype][fname] = "ENB ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
        for _, fieldname in ipairs(msg_fields) do
            tree:add(msg_field_proto[mtype][fieldname], buffer(offset, msg_field_num_bytes[mtype][fieldname]));
            offset = offset + msg_field_num_bytes[mtype][fieldname]
        end
    end
end


do
    local mname = "CTRL_CELL_STATUS_NR_RSP"
    local mtype = msg_name_to_type[mname]
    mname = string.lower(mname)

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}
    msg_fields = {}

    local fname

    fname = "cell_id"
    msg_fields[1] = fname
    msg_field_name[mtype][fname] = "CELL ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "enb_id"
    msg_fields[2] = fname
    msg_field_name[mtype][fname] = "ENB ID"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    fname = "cell_status"
    msg_fields[3] = fname
    msg_field_name[mtype][fname] = "CELL STATUS"
    msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. fname
    msg_field_radix[mtype][fname] = base.DEC
    msg_field_num_bytes[mtype][fname] = 1

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
        for _, fieldname in ipairs(msg_fields) do
            tree:add(msg_field_proto[mtype][fieldname], buffer(offset, msg_field_num_bytes[mtype][fieldname]));
            offset = offset + msg_field_num_bytes[mtype][fieldname]
        end
    end
end

do
	local mtype = msg_name_to_type.CTRL_ADD_UE_HO

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	-- CTRL_ADD_UE_HO_T Fields
	local field_filter = ".ctrl_add_ue_ho"
	initialize_global_ue_id_field(mtype, field_filter)
	initialize_mac_main_config_data_inactivity_timer_r14_field(mtype, field_filter)

	msg_field_name[mtype].rrc_msg_chosen = "RRC Message Chosen"
	msg_field_filter[mtype].rrc_msg_chosen = proxyproto_filter..field_filter..".rrc_msg_chosen"
	msg_field_radix[mtype].rrc_msg_chosen = base.DEC
	msg_field_num_bytes[mtype].rrc_msg_chosen = 1

	initialize_common_ul_dcch_ul_ccch_fields(mtype, field_filter)
	initialize_ul_dcch_fields(mtype, field_filter)
	initialize_ul_ccch_fields(mtype, field_filter)

	msg_register_fields[mtype] = function(protocol)
		register_global_ue_id_field(mtype)
		register_mac_main_config_data_inactivity_timer_r14_field(mtype)
		msg_field_proto[mtype].rrc_msg_chosen = ProtoField.uint8(msg_field_filter[mtype].rrc_msg_chosen, msg_field_name[mtype].rrc_msg_chosen, msg_field_radix[mtype].rrc_msg_chosen)

		register_common_ul_dcch_ul_ccch_fields(mtype)
		register_ul_dcch_fields(mtype)
		register_ul_ccch_fields(mtype)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].global_ue_id, buffer(offset, msg_field_num_bytes[mtype].global_ue_id));
		offset = offset + msg_field_num_bytes[mtype].global_ue_id

		offset = offset + 198  -- PRX_PDCP_CFG_T
		offset = offset + 33   -- PRX_PDCP_CFG_T
		offset = offset + 121  -- PRX_PDCP_HFN_DESYNC_T
		offset = offset + 352  -- PRX_RB_CFG_T
		offset = offset + 1309 -- Other data after global_ue_id up to mac_main_config.dataInactivityTimer_r14

		local inact_timer_val = buffer(offset, msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14):uint()
		local inact_timer_str_to_add = data_inact_timer_val_to_str(inact_timer_val)
		tree:add(msg_field_proto[mtype].mac_main_config_data_inactivity_timer_r14, buffer(offset, msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14)):append_text(" ("..inact_timer_str_to_add..")")
		offset = offset + msg_field_num_bytes[mtype].mac_main_config_data_inactivity_timer_r14

		offset = offset + 2868 -- Other Data after MAC_MAIN_CONFIG_T

		local rrc_choice = buffer(offset, 1):uint()
		tree:add(msg_field_proto[mtype].rrc_msg_chosen, buffer(offset, msg_field_num_bytes[mtype].rrc_msg_chosen));
		offset = offset + msg_field_num_bytes[mtype].rrc_msg_chosen

		offset = offset + 14 -- PROXY_MSG_HDR_T

		if 0 == rrc_choice then
			dissect_ul_ccch(mtype, buffer, pinfo, tree, offset)
		else
			dissect_ul_dcch(mtype, buffer, pinfo, tree, offset)
		end
	end
end

do
    local mtype = msg_name_to_type.CTRL_PET_SE_STATUS_RESULT_IND

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    table.insert(msg_field_name[mtype], "Global UE Id")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 2)

    table.insert(msg_field_name[mtype], "PROCEDURE Code")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".procedure_code")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "STATUS")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".status")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    table.insert(msg_field_name[mtype], "Bearer Release Count")
    table.insert(msg_field_filter[mtype], proxyproto_filter..".bearer_release_count")
    table.insert(msg_field_radix[mtype], base.DEC)
    table.insert(msg_field_num_bytes[mtype], 1)

    local count = 16 

    for i = 1, count do
        table.insert(msg_field_name[mtype], "Bearer Release ID " .. i)
        table.insert(msg_field_filter[mtype], proxyproto_filter .. ".bearer_release_id_" .. (i-1))
        table.insert(msg_field_radix[mtype], base.DEC)
        table.insert(msg_field_num_bytes[mtype], 1)
    end
end

-- PRX_UE_SB_CQI_PARAM

local function initialize_prx_ue_sb_cqi_param_fields(mtype, mname)
	local fname

	fname = "pmi"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	local fname = "cqi.0"
	msg_field_name[mtype][fname] = "cqi[0]"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	local fname = "cqi.1"
	msg_field_name[mtype][fname] = "cqi[1]"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1
end

local function register_prx_ue_native_cqi_param_fields(mtype)
	local fname

	fname = "cqi.0"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])
	fname = "cqi.1"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "pmi"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])
end

local function dissect_prx_ue_native_cqi_param_fields(buffer, pinfo, tree, offset, mtype)
	local fname

	fname = "cqi.0"
	tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
	offset = offset + msg_field_num_bytes[mtype][fname]
	fname = "cqi.1"
	tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
	offset = offset + msg_field_num_bytes[mtype][fname]

	fname = "pmi"
	tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
	offset = offset + msg_field_num_bytes[mtype][fname]

	return offset
end

do
	for cell=0,7 do
		for csi_set=0,1 do
			local mname = "CTRL_UPDATE_UE_CQI.cqi" .. "." .. cell .. "." .. csi_set .. ".ue_native_cqi.wb"
			local mtype = msg_name_to_type[mname]
			mname = string.lower(mname)

			msg_field_name[mtype] = {}
			msg_field_num_bytes[mtype] = {}
			msg_field_filter[mtype] = {}
			msg_field_radix[mtype] = {}

			initialize_prx_ue_sb_cqi_param_fields(mtype, mname)

			msg_register_fields[mtype] = function(protocol)
				register_prx_ue_native_cqi_param_fields(mtype)

				for _, proto_field in pairs(msg_field_proto[mtype]) do
					table.insert(protocol.fields, proto_field)
				end
			end

			msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
				offset = dissect_prx_ue_native_cqi_param_fields(buffer, pinfo, tree, offset, mtype)
				return offset
			end
		end
	end
end

do
	for cell=0,7 do
		for csi_set=0,1 do
			for sb_num = 0,12 do
				local mname = "CTRL_UPDATE_UE_CQI.cqi" .. "." .. cell .. "." .. csi_set .. ".ue_native_cqi.sb."..sb_num
				local mtype = msg_name_to_type[mname]
				mname = string.lower(mname)

				msg_field_name[mtype] = {}
				msg_field_num_bytes[mtype] = {}
				msg_field_filter[mtype] = {}
				msg_field_radix[mtype] = {}

				initialize_prx_ue_sb_cqi_param_fields(mtype, mname)

				msg_register_fields[mtype] = function(protocol)
					register_prx_ue_native_cqi_param_fields(mtype)

					for _, proto_field in pairs(msg_field_proto[mtype]) do
						table.insert(protocol.fields, proto_field)
					end
				end

				msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
					 offset = dissect_prx_ue_native_cqi_param_fields(buffer, pinfo, tree, offset, mtype)
					return offset
				end
			end
		end
	end
end

-- PRX_UE_NATIVE_CQI_PARAM

local function initialize_prx_ue_native_cqi_params_fields(mtype, mname)
	local fname

	fname = "pref_pmi"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "rank"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "ri_pti"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "ri_i1"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "beam_pmi"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1
end

local function register_sb_elem(mtype, mname, index)
	local abbrev = proxyproto_filter .. "." .. mname .. "." .. "sb."..index
	local name = "sb["..index.."]"
	msg_field_proto[mtype]["sb_array."..index] = ProtoField.protocol(abbrev, name)
end

local function register_prx_ue_native_cqi_params_fields(mtype, mname)
	local fname

	fname = "wb"
	local abbrev = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_proto[mtype].wb = ProtoField.protocol(abbrev, fname)

	abbrev = proxyproto_filter .. "." .. mname .. "." .. "sb"
	local name = "sb[] (13 elements)"
	msg_field_proto[mtype].sb = ProtoField.protocol(abbrev, name)
	for sb_num=0,12 do
		register_sb_elem(mtype, mname, sb_num)
	end

	fname = "pref_pmi"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "rank"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "ri_pti"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "ri_i1"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "beam_pmi"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])
end

do
	for cell=0,7 do
		for csi_set=0,1 do
			local name = "CTRL_UPDATE_UE_CQI.cqi" .. "." .. cell .. "." .. csi_set .. ".ue_native_cqi"
			local mtype = msg_name_to_type[name]
			local mname = string.lower(name)

			local fname

			msg_field_name[mtype] = {}
			msg_field_num_bytes[mtype] = {}
			msg_field_filter[mtype] = {}
			msg_field_radix[mtype] = {}

			initialize_prx_ue_native_cqi_params_fields(mtype, mname)

			msg_register_fields[mtype] = function(protocol)

				register_prx_ue_native_cqi_params_fields(mtype, mname)

				for _, proto_field in pairs(msg_field_proto[mtype]) do
					table.insert(protocol.fields, proto_field)
				end
			end

			msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
				local fname = "wb"
				local subtree1 = tree:add(msg_field_proto[mtype].wb)
				offset = msg_dissect[msg_name_to_type[name.."."..fname]](buffer, pinfo, subtree1, offset)

				fname = "sb"
				local subtree2 = tree:add(msg_field_proto[mtype].sb)
				for sb_num=0,12 do
					local subtree3 = subtree2:add(msg_field_proto[mtype]["sb_array."..sb_num])
					offset = msg_dissect[msg_name_to_type[name.."."..fname.."."..sb_num]](buffer, pinfo, subtree3, offset)
				end

				fname = "pref_pmi"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "rank"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "ri_pti"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "ri_i1"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "beam_pmi"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				return offset
			end
		end
	end
end

-- PRX_UE_CQI_PARAM

local function initialize_prx_ue_cqi_params_fields(mtype, mname)
	local fname

	fname = "bit_mask"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "table_id"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "disable_cqi_reporting"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "disable_ri_reporting"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "disable_acsi_reporting"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "ue_native_cqi"
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
end

local function register_prx_ue_cqi_params_fields(mtype)
	local fname

	fname = "bit_mask"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "table_id"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "disable_cqi_reporting"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "disable_ri_reporting"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "disable_acsi_reporting"
	msg_field_proto[mtype][fname] = ProtoField.uint8(msg_field_filter[mtype][fname], msg_field_name[mtype][fname], msg_field_radix[mtype][fname])

	fname = "ue_native_cqi"
	msg_field_proto[mtype][fname] = ProtoField.protocol(msg_field_filter[mtype][fname], fname)
end

do
	for cell=0,7 do
		for csi_set=0,1 do
			local name = "CTRL_UPDATE_UE_CQI.cqi" .. "." .. cell .. "." .. csi_set
			local mtype = msg_name_to_type[name]
			mname = string.lower(name)

			msg_field_name[mtype] = {}
			msg_field_num_bytes[mtype] = {}
			msg_field_filter[mtype] = {}
			msg_field_radix[mtype] = {}

			initialize_prx_ue_cqi_params_fields(mtype, mname)

			msg_register_fields[mtype] = function(protocol)
				register_prx_ue_cqi_params_fields(mtype)

				for _, proto_field in pairs(msg_field_proto[mtype]) do
					table.insert(protocol.fields, proto_field)
				end
			end

			msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
				fname = "bit_mask"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "table_id"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "disable_cqi_reporting"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "disable_ri_reporting"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "disable_acsi_reporting"
				tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
				offset = offset + msg_field_num_bytes[mtype][fname]

				fname = "ue_native_cqi"
				local subtree1 = tree:add(msg_field_proto[mtype][fname])
				offset = msg_dissect[msg_name_to_type[name.."."..fname]](buffer, pinfo, subtree1, offset)

				return offset
			end
		end
	end
end

-- CTRL_UPDATE_UE_CQI

local function register_cqi_elem(mtype, mname, index_x, index_y)
	local abbrev = proxyproto_filter .. "." .. mname .. "." .. "cqi."..index_x.."."..index_y
	local name = "cqi["..index_x.."]["..index_y.."]"
	msg_field_proto[mtype]["cqi_array."..index_x.."."..index_y] = ProtoField.protocol(abbrev, name)
end

do
	local name = "CTRL_UPDATE_UE_CQI"
	local mtype = msg_name_to_type[name]
	mname = string.lower(name)
	local field_filter = "." .. mname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	initialize_global_ue_id_field(mtype, field_filter)
	initialize_local_ue_id_field(mtype, field_filter)

	msg_register_fields[mtype] = function(protocol)
		register_global_ue_id_field(mtype)
		register_local_ue_id_field(mtype)

		local abbrev = proxyproto_filter .. "." .. mname .. "." .. "cqi"
		local name = "cqi[][] (8 cells * 2 csi_sets)"
		msg_field_proto[mtype].cqi = ProtoField.protocol(abbrev, name)

		for cell=0,7 do
			for csi_set=0,1 do
				register_cqi_elem(mtype, mname, cell, csi_set)
			end
		end

		for _, proto_field in pairs(msg_field_proto[mtype]) do
				table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		tree:add(msg_field_proto[mtype].global_ue_id, buffer(offset, msg_field_num_bytes[mtype].global_ue_id));
		offset = offset + msg_field_num_bytes[mtype].global_ue_id

		tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id))
		offset = offset + msg_field_num_bytes[mtype].local_ue_id

		local fname = "cqi"
		local subtree1 = tree:add(msg_field_proto[mtype].cqi)
		for cell=0,7 do
			for csi_set=0,1 do
				local subtree2 = subtree1:add(msg_field_proto[mtype]["cqi_array."..cell.."."..csi_set])
				offset = msg_dissect[msg_name_to_type[name.."."..fname.."."..cell.."."..csi_set]](buffer, pinfo, subtree2, offset)
			end
		end

		return offset
	end
end

do
	local mtype = msg_name_to_type.DL_DTCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Logical channel ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".logical_channel_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "EEA")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".eea")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

        table.insert(msg_field_name[mtype], "Highest delivered UL PDCP count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".highest_deliv_ul_pdcp_count")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Packet num")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".packet_num")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Truncated packet original length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".l3_msg_original_len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Integrity Verification Failed")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ip_failed")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)
	
	table.insert(msg_field_name[mtype], "Reserved Field")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".reserved_ffs")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	local proto_pdcp_enc = Proto(
		proxyproto_filter..".pdcp.encrypted", "PDCP envelope with encrypted payload")
	local field_enc_data = ProtoField.new(
		"Encrypted data", proxyproto_filter..".pdcp.encrypted.data", ftypes.BYTES, base.HEX)
	table.insert(proxyproto_protocol.fields, field_enc_data)
	local field_enc_length = ProtoField.new(
		"Length", proxyproto_filter..".pdcp.encrypted.length", ftypes.UINT16)
	table.insert(proxyproto_protocol.fields, field_enc_length)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		local eea = buffer(9, 1)
		if 0 == eea:uint()
		then
			dissect_rrc(
				buffer, pinfo, tree, offset,
				msg_field_num_bytes[mtype][#msg_field_name[mtype]], "ip", 2)
		else
			local bytes_left = buffer:len() - offset
			local pdcp_buf   = buffer(offset, bytes_left)
			local branch     = tree:add(proto_pdcp_enc, pdcp_buf):
									append_text(" ("..bytes_left.." bytes)")
			branch:add(field_enc_data, pdcp_buf)
			branch:add(field_enc_length, bytes_left):
					prepend_text("["):append_text("]")
		end
	end
end

do
	local mtype = msg_name_to_type.UL_CCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	initialize_common_ul_dcch_ul_ccch_fields(mtype, "")
	initialize_ul_ccch_fields(mtype, "")

	msg_register_fields[mtype] = function(protocol)
		register_common_ul_dcch_ul_ccch_fields(mtype)
		register_ul_ccch_fields(mtype)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		dissect_ul_ccch(mtype, buffer, pinfo, tree, offset)
	end
end


do
    local mtype = msg_name_to_type.UL_CCCH1

    msg_field_name[mtype] = {}
    msg_field_num_bytes[mtype] = {}
    msg_field_filter[mtype] = {}
    msg_field_radix[mtype] = {}

    initialize_common_ul_dcch_ul_ccch_fields(mtype, "")
    initialize_ul_ccch_fields(mtype, "")

    msg_register_fields[mtype] = function(protocol)
        register_common_ul_dcch_ul_ccch_fields(mtype)
        register_ul_ccch_fields(mtype)

        for _, proto_field in pairs(msg_field_proto[mtype]) do
            table.insert(protocol.fields, proto_field)
        end
    end

    msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
        dissect_ul_ccch(mtype, buffer, pinfo, tree, offset)
    end
end



do
		local mtype = msg_name_to_type.UL_CCCH_NB

		msg_field_name[mtype] = {}
		msg_field_num_bytes[mtype] = {}
		msg_field_filter[mtype] = {}
		msg_field_radix[mtype] = {}

		initialize_ue_id_field(mtype, "")
		initialize_local_ue_id_field(mtype, "")

		msg_field_name[mtype].c_rnti = "C-RNTI"
		msg_field_filter[mtype].c_rnti = proxyproto_filter..".c_rnti"
		msg_field_radix[mtype].c_rnti = base.HEX
		msg_field_num_bytes[mtype].c_rnti = 2

		msg_field_name[mtype].rapid = "Rapid"
		msg_field_filter[mtype].rapid = proxyproto_filter..".rapid"
		msg_field_radix[mtype].rapid = base.DEC
		msg_field_num_bytes[mtype].rapid = 1

		msg_field_name[mtype].ramask = "Ramask"
		msg_field_filter[mtype].ramask = proxyproto_filter..".ramask"
		msg_field_radix[mtype].ramask = base.HEX
		msg_field_num_bytes[mtype].ramask = 1

		msg_field_name[mtype].sim_nacks_msg3 = "Simulated NACKs for MSG3"
		msg_field_filter[mtype].sim_nacks_msg3 = proxyproto_filter..".sim_nacks_msg3"
		msg_field_radix[mtype].sim_nacks_msg3 = 8
		msg_field_num_bytes[mtype].sim_nacks_msg3 = 1

		msg_field_name[mtype].sim_dtxs_msg3 = "Simulated DTXs for MSG3"
		msg_field_filter[mtype].sim_dtxs_msg3 = proxyproto_filter..".sim_dtxs_msg3"
		msg_field_radix[mtype].sim_dtxs_msg3 = 8
		msg_field_num_bytes[mtype].sim_dtxs_msg3 = 1

		msg_field_name[mtype].sim_nacks_msg4 = "Simulated NACKs for MSG4"
		msg_field_filter[mtype].sim_nacks_msg4 = proxyproto_filter..".sim_nacks_msg4"
		msg_field_radix[mtype].sim_nacks_msg4 = 8
		msg_field_num_bytes[mtype].sim_nacks_msg4 = 1

		msg_field_name[mtype].sim_num_nacks_msg3 = "Number of MSG3 NACKs"
		msg_field_filter[mtype].sim_num_nacks_msg3 = proxyproto_filter..".sim_num_nacks_msg3"
		msg_field_radix[mtype].sim_num_nacks_msg3 = base.DEC
		msg_field_num_bytes[mtype].sim_num_nacks_msg3 = 1

		msg_field_name[mtype].sim_num_dtxs_msg3 = "Number of MSG3 DTXs"
		msg_field_filter[mtype].sim_num_dtxs_msg3 = proxyproto_filter..".sim_num_dtxs_msg3"
		msg_field_radix[mtype].sim_num_dtxs_msg3 = base.DEC
		msg_field_num_bytes[mtype].sim_num_dtxs_msg3 = 1

		msg_field_name[mtype].sim_num_nacks_msg4 = "Number of MSG4 NACKs"
		msg_field_filter[mtype].sim_num_nacks_msg4 = proxyproto_filter..".sim_num_nacks_msg4"
		msg_field_radix[mtype].sim_num_nacks_msg4 = base.DEC
		msg_field_num_bytes[mtype].sim_num_nacks_msg4 = 1

		msg_field_name[mtype].turn_enc_off = "Turn encryption off"
		msg_field_filter[mtype].turn_enc_off = proxyproto_filter..".turn_enc_off"
		msg_field_radix[mtype].turn_enc_off = base.DEC
		msg_field_num_bytes[mtype].turn_enc_off = 1

		msg_field_name[mtype].len = "L3 Message Length"
		msg_field_filter[mtype].len = proxyproto_filter..".len"
		msg_field_radix[mtype].len = base.DEC
		msg_field_num_bytes[mtype].len = 2

		msg_register_fields[mtype] = function(protocol)
			register_ue_id_field(mtype)
			register_local_ue_id_field(mtype)
			msg_field_proto[mtype].c_rnti = ProtoField.uint16(msg_field_filter[mtype].c_rnti, msg_field_name[mtype].c_rnti, msg_field_radix[mtype].c_rnti)
			msg_field_proto[mtype].rapid = ProtoField.uint8(msg_field_filter[mtype].rapid, msg_field_name[mtype].rapid, msg_field_radix[mtype].rapid)
			msg_field_proto[mtype].ramask = ProtoField.uint8(msg_field_filter[mtype].ramask, msg_field_name[mtype].ramask, msg_field_radix[mtype].ramask)
			msg_field_proto[mtype].sim_nacks_msg3 = ProtoField.new(msg_field_name[mtype].sim_nacks_msg3, msg_field_filter[mtype].sim_nacks_msg3, ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_nacks_msg3, 0x1)
			msg_field_proto[mtype].sim_nacks_msg4 = ProtoField.new(msg_field_name[mtype].sim_nacks_msg4, msg_field_filter[mtype].sim_nacks_msg4, ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_nacks_msg4, 0x2)
			msg_field_proto[mtype].sim_dtxs_msg3  = ProtoField.new(msg_field_name[mtype].sim_dtxs_msg3,  msg_field_filter[mtype].sim_dtxs_msg3,  ftypes.BOOLEAN, {"Set", "Not set"}, msg_field_radix[mtype].sim_dtxs_msg3,  0x4)
			msg_field_proto[mtype].sim_num_nacks_msg3 = ProtoField.uint8(msg_field_filter[mtype].sim_num_nacks_msg3, msg_field_name[mtype].sim_num_nacks_msg3, msg_field_radix[mtype].sim_num_nacks_msg3)
			msg_field_proto[mtype].sim_num_nacks_msg4 = ProtoField.uint8(msg_field_filter[mtype].sim_num_nacks_msg4, msg_field_name[mtype].sim_num_nacks_msg4, msg_field_radix[mtype].sim_num_nacks_msg4)
			msg_field_proto[mtype].sim_num_dtxs_msg3 = ProtoField.uint8(msg_field_filter[mtype].sim_num_dtxs_msg3, msg_field_name[mtype].sim_num_dtxs_msg3, msg_field_radix[mtype].sim_num_dtxs_msg3)
			msg_field_proto[mtype].turn_enc_off = ProtoField.new(msg_field_name[mtype].turn_enc_off, msg_field_filter[mtype].turn_enc_off, ftypes.UINT8, {[0] = "security enabled ", [1] = "security disabled "}, msg_field_radix[mtype].turn_enc_off)
			msg_field_proto[mtype].len = ProtoField.uint16(msg_field_filter[mtype].len, msg_field_name[mtype].len, msg_field_radix[mtype].len)

			for _, proto_field in pairs(msg_field_proto[mtype]) do
					table.insert(protocol.fields, proto_field)
			end
		end

		msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
			tree:add(msg_field_proto[mtype].ue_id, buffer(offset, msg_field_num_bytes[mtype].ue_id));
			offset = offset + msg_field_num_bytes[mtype].ue_id
			tree:add(msg_field_proto[mtype].local_ue_id, buffer(offset, msg_field_num_bytes[mtype].local_ue_id));
			offset = offset + msg_field_num_bytes[mtype].local_ue_id
			tree:add(msg_field_proto[mtype].c_rnti, buffer(offset, msg_field_num_bytes[mtype].c_rnti));
			offset = offset + msg_field_num_bytes[mtype].c_rnti
			tree:add(msg_field_proto[mtype].rapid, buffer(offset, msg_field_num_bytes[mtype].rapid));
			offset = offset + msg_field_num_bytes[mtype].rapid
			tree:add(msg_field_proto[mtype].ramask, buffer(offset, msg_field_num_bytes[mtype].ramask));
			offset = offset + msg_field_num_bytes[mtype].ramask
			tree:add("Extra mask:")
			tree:add(msg_field_proto[mtype].sim_nacks_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_nacks_msg3));
			tree:add(msg_field_proto[mtype].sim_nacks_msg4, buffer(offset, msg_field_num_bytes[mtype].sim_nacks_msg4));
			tree:add(msg_field_proto[mtype].sim_dtxs_msg3,  buffer(offset, msg_field_num_bytes[mtype].sim_dtxs_msg3));
			offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg4
			tree:add("Extra error:")
			tree:add(msg_field_proto[mtype].sim_num_nacks_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_num_nacks_msg3));
			offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg3
			tree:add(msg_field_proto[mtype].sim_num_dtxs_msg3, buffer(offset, msg_field_num_bytes[mtype].sim_num_dtxs_msg3));
			offset = offset + msg_field_num_bytes[mtype].sim_dtxs_msg3
			tree:add(msg_field_proto[mtype].sim_num_nacks_msg4, buffer(offset, msg_field_num_bytes[mtype].sim_num_nacks_msg4));
			offset = offset + msg_field_num_bytes[mtype].sim_nacks_msg4
			tree:add(msg_field_proto[mtype].turn_enc_off, buffer(offset, msg_field_num_bytes[mtype].turn_enc_off));
			offset = offset + msg_field_num_bytes[mtype].turn_enc_off

			tree:add(msg_field_proto[mtype].len, buffer(offset, msg_field_num_bytes[mtype].len));
			offset = offset + msg_field_num_bytes[mtype].len

			dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype].len, ul_ccch_nb_ie_name, 0)
		end
end

do
	local mtype = msg_name_to_type.UL_DCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	initialize_common_ul_dcch_ul_ccch_fields(mtype, "")
	initialize_ul_dcch_fields(mtype, "")

	msg_register_fields[mtype] = function(protocol)
		register_common_ul_dcch_ul_ccch_fields(mtype)
		register_ul_dcch_fields(mtype)

		for _, proto_field in pairs(msg_field_proto[mtype]) do
			table.insert(protocol.fields, proto_field)
		end
	end

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		dissect_ul_dcch(mtype, buffer, pinfo, tree, offset)
	end
end

do
	local mtype = msg_name_to_type.UL_DTCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Logical channel ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".logical_channel_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Skip cipher")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".skip_cipher")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SDU id present")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sdu_id_present")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SDU id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sdu_id")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Packet num")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".packet_num")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Padding")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".padding")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)
	
	table.insert(msg_field_name[mtype], "corrupt mac-I")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".corrupt_mac_i")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], "ip", 2)
	end
end

do
	local mname = "ENDC_UL_DTCH"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SDU ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sdu_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "Packet ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".packet_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "LCID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SDU ID Present")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sdu_id_present")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCP PDU length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], "ip", 3)
	end
end

do
	local mname = "ENDC_DL_DTCH"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "LCID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".lcid")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Padding")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".padding")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Highest delivered UL PDCP count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".highest_deliv_ul_pdcp_count")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "PDCP PDU length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], "ip", 3)
	end
end

do
	local mtype = msg_name_to_type.DL_MCCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "NF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NSF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nsf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "MBSFN Area ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".mbsfn_area_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], mcch_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.DL_MTCH

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "NF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "NSF")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".nsf")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "MBSFN Area ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".mbsfn_area_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Session ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".dl_mtch.session_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], "ip", 0)
	end
end

do
	local mtype = msg_name_to_type.DL_BCCH_BCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "sfn")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sfn")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_bch_nb_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.DL_BCCH_SCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "xsfn")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".xsfn")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "rv index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".rv_index")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], bcch_dl_sch_nb_ie_name, 0)
	end
end

do
	local mname = "MBSFN_SUBFRAME_CONFIG"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "radio_frame_allocation_period"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "radio_frame_allocation_offset"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "subframe_allocation_frames"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "subframe_bitmap"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		local subtree1

		fname = "radio_frame_allocation_period"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "radio_frame_allocation_offset"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "subframe_allocation_frames"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		subtree1 = tree:add("subframe_bitmap[] (4 elements)")
		fname = "subframe_bitmap"
		for i=1,4 do
			subtree1:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname])):prepend_text("[" .. i - 1 .. "] ");
			offset = offset + msg_field_num_bytes[mtype][fname]
		end
		return offset
	end
end

do
	local mname = "MBSFN_COMMON_SF_ALLOC"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "num_mbsfn_subframe_config"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "num_mbsfn_subframe_config"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		local subtree1 = tree:add("mbsfn_subframe_config[] (8 elements)")
		for i=1,8 do
			local subtree2 = subtree1:add("mbsfn_subframe_config[" .. i - 1 .. "]")
			offset = msg_dissect[msg_name_to_type.MBSFN_SUBFRAME_CONFIG](buffer, pinfo, subtree2, offset)
		end

		return offset
	end
end

do
	local mname = "PMCH_CONFIG"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname
	local index = 0

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	-- Avoid table.insert as it is super slow
	index = index + 1
	fname = "sf_alloc_end"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 2

	index = index + 1
	fname = "data_mcs"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 1

	index = index + 1
	fname = "mch_scheduling_period"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 2
end

do
	local mname = "MBMS_SESSION_INFO"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname
	local index = 0

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	index = index + 1
	fname = "session_id_present"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 1

	index = index + 1
	fname = "session_id"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 1

	index = index + 1
	fname = "logical_channel_identity"
	msg_field_name[mtype][index] = fname
	msg_field_filter[mtype][index] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][index] = base.DEC
	msg_field_num_bytes[mtype][index] = 1
end

do
	local mname = "PMCH_AND_SESSION_INFO"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "pmch_idx"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "pmch_idx"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		local subtree1 = tree:add("pmch_config")
		offset = default_dissection(msg_name_to_type.PMCH_CONFIG, buffer, pinfo, subtree1, offset)

		local subtree1 = tree:add("mbms_session_info")
		offset = default_dissection(msg_name_to_type.MBMS_SESSION_INFO, buffer, pinfo, subtree1, offset)

		return offset
	end
end

do
	local mname = "CTRL_MBSFN_AREA_CONF"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "mbsfn_area_id"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "mbsfn_common_sf_alloc_period"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "num_pmch_and_session_info"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "mbsfn_area_id"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "mbsfn_common_sf_alloc_period"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		local subtree1 = tree:add("mbsfn_common_sf_alloc")
		offset = msg_dissect[msg_name_to_type.MBSFN_COMMON_SF_ALLOC](buffer, pinfo, subtree1, offset)

		fname = "num_pmch_and_session_info"
		local num_pmch_and_session_info = buffer(offset, msg_field_num_bytes[mtype][fname]):uint()
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		subtree1 = tree:add("pmch_and_session_info[] ("..num_pmch_and_session_info.." elements)")
		for i=1,num_pmch_and_session_info do
			local subtree2 = subtree1:add("pmch_and_session_info[" .. i - 1 .. "]")
			offset = msg_dissect[msg_name_to_type.PMCH_AND_SESSION_INFO](buffer, pinfo, subtree2, offset)
		end
	end
end

do
	local mtype = msg_name_to_type.UL_DCCH_NB

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Logical channel ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".logical_channel_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], ul_dcch_nb_ie_name, 0)
	end
end

do
	local mtype = msg_name_to_type.CTRL_ADD_UE_DC

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "C-RNTI")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".c_rnti")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "TYPE OF UPLANE TRAFFIC")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".type_of_uplane_traffic")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SKgNB Key")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".skgnb_key")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 32)

	table.insert(msg_field_name[mtype], "MIMO UL Layers")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".mimo_ul_layers")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mtype = msg_name_to_type.CTRL_ADD_UE_DC_RSP

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_add_ue_dc_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mname = "DL_CRLC_IPHY_MSG_IND"
	local mtype = msg_name_to_type[mname]

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	mname = string.lower(mname)

	table.insert(msg_field_name[mtype], "IPHY id")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "iphy_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "IPHY message padding")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "message_padding")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		local iphy_id_index = 1
		local iphy_id = buffer(offset, msg_field_num_bytes[mtype][iphy_id_index]):uint()

		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		local remaining_bytes = buffer:len() - offset

		if remaining_bytes > 0 then
			local l3_msg_tree = tree:add(f_remaining_data, buffer(offset, remaining_bytes));

			if iphy_id == 8977 then
				l3_msg_tree:add("MAC_UE_ADD_REQ")
			elseif iphy_id == 8979 then
				l3_msg_tree:add("MAC_UE_DEL_REQ")
			elseif iphy_id == 8980 then
				l3_msg_tree:add("MAC_RB_ADD_REQ")
			elseif iphy_id == 8983 then
				l3_msg_tree:add("MAC_RB_DEL_REQ")
			elseif iphy_id == 8990 then
				l3_msg_tree:add("RLC_TX_STATUS_CNF")
			end
		end
	end
end

do
	local mname = "UL_CRLC_IPHY_MSG_IND"
	local mtype = msg_name_to_type[mname]

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	mname = string.lower(mname)

	table.insert(msg_field_name[mtype], "IPHY id")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "iphy_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "IPHY message padding")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "message_padding")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "L3 Message Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter .. "." .. mname .. "." .. "len")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		local iphy_id_index = 1
		local iphy_id = buffer(offset, msg_field_num_bytes[mtype][iphy_id_index]):uint()

		offset = default_dissection(mtype, buffer, pinfo, tree, offset)
		local remaining_bytes = buffer:len() - offset

		if remaining_bytes > 0 then
			local l3_msg_tree = tree:add(f_remaining_data, buffer(offset, remaining_bytes));

			if iphy_id == 8978 then
				l3_msg_tree:add("MAC_UE_ADD_RSP")
			elseif iphy_id == 8982 then
				l3_msg_tree:add("MAC_RB_ADD_RSP")
			elseif iphy_id == 8989 then
				l3_msg_tree:add("RLC_TX_STATUS_IND")
			end
		end
	end
end

do
	local mtype = msg_name_to_type.CTRL_CG_CONFIG

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "SUB HDR IsCompressed")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".isCompressed")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SUB HDR Compressed MSG Size")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".compressedMsgSize")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SUB HDR Orignal MSG Size")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".orignalMsgSize")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)

	table.insert(msg_field_name[mtype], "SUB HDR Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SUB HDR LCID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sub_hdr_lcid")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SUB HDR Reserved")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".sub_hdr_reserved")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 4)


	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "C-RNTI")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".c_rnti")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UE Add Cause")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_add_cause")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Cell group Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".cell_group_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mtype = msg_name_to_type.CTRL_CG_CONFIG_RSP

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Result")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_cg_config_rsp.result")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		offset = default_dissection(mtype, buffer, pinfo, tree, offset)

		--TODO: change lines below with call to dissect_rrc() with correct NR RRC IE to display L3_MSG payload
		--dissect_rrc(buffer, pinfo, tree, offset, msg_field_num_bytes[mtype][#msg_field_name[mtype]], rrc_ie_name, 0)
		local remaining_bytes = buffer:len() - offset
		tree:add(f_remaining_data, buffer(offset, remaining_bytes));
	end
end

do
	local mtype = msg_name_to_type.CTRL_UE_RBR_QUERY

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_rbr_query.global_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Local UE ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_rbr_query.local_ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Lcid")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_rbr_query.lcid")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Direction")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_rbr_query.direction")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Desired Bitrate Index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_ue_rbr_query.desired_bit_rate_idx")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		  offset = default_dissection(mtype, buffer, pinfo, tree, offset)
	end
end

do
	local mtype = msg_name_to_type.CTRL_RLF_IND

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Failure Type")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_rlf_ind.failureType")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)
end

local eDirection = {
    [0] = "NONE",
    [1] = "UPLINK",
    [2] = "DOWNLINK",
    [3] = "BOTH",
}

local eVersion = {
    [0] = "IP_INVALID",
    [4] = "IP_VERSION_4",
    [6] = "IP_VERSION_6",
    [24] = "IP_VERSION_DUAL",
}

local eTrafficType = {
    [0] = "TRAFFIC_INTERNAL",
    [1] = "TRAFFIC_EXTERNAL",
}

local direction_enum = ProtoField.uint8("proxyproto.direction", "direction", base.DEC, eDirection)
table.insert(proxyproto_protocol.fields, direction_enum)

local version_enum = ProtoField.uint8("proxyproto.direction", "version", base.DEC, eVersion)
table.insert(proxyproto_protocol.fields, version_enum)

local traffic_type_enum = ProtoField.uint8("proxyproto.traffic_type", "traffic_type", base.DEC, eTrafficType)
table.insert(proxyproto_protocol.fields, traffic_type_enum)

local ipv4_field = ProtoField.ipv4("proxyproto.ipv4_address", "ipv4_address", base.HEX)
table.insert(proxyproto_protocol.fields, ipv4_field)
local ipv6_field = ProtoField.ipv6("proxyproto.ipv6_address", "IPv6 Address", base.COLON)
table.insert(proxyproto_protocol.fields, ipv6_field)

do
	local mname = "CTRL_TRAFFIC_COMMAND_IND"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname
	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "global_ue_id"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 2

	fname = "drbId"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "direction"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "numOfTrfIds"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	for index = 1, SIM_MAX_TRAFFICS_PER_BEARER
	do
		fname = "trf_id " .. index
		msg_field_name[mtype][fname] = fname
		msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. "trf_id" .. "." .. index
		msg_field_radix[mtype][fname] = base.DEC
		msg_field_num_bytes[mtype][fname] = 1
	end

	fname = "stop"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "global_ue_id"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "drbId"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "direction"
		tree:add(direction_enum, buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]
		

		fname = "numOfTrfIds"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]

		local trf_ids_tree = tree:add("list_of_trf_ids")

		for index = 1, SIM_MAX_TRAFFICS_PER_BEARER
		do
			fname = "trf_id " .. index
			trf_ids_tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
			offset = offset + msg_field_num_bytes[mtype][fname]
		end

		fname = "stop"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]
	end
end

do
	local mname = "CTRL_TRAFFIC_CONFIGURATION_IND"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

    local IPV6_ADDR_LENGTH = 16
 
	local fname
	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

    local fields = {
        {name = "global_ue_id", size = 2, radix = base.DEC},
        {name = "local_ue_id", size = 2, radix = base.DEC},
        {name = "drbId", size = 4, radix = base.DEC},
        {name = "direction", size = 1, radix = base.DEC},
        {name = "nL3PktLo", size = 4, radix = base.DEC},
        {name = "nL3PktHi", size = 4, radix = base.DEC},
        {name = "nPeriod", size = 4, radix = base.DEC},
        {name = "nBurst", size = 4, radix = base.DEC},
        {name = "nTrProto", size = 4, radix = base.DEC},
        {name = "nLimit", size = 4, radix = base.DEC},
        {name = "nLimitType", size = 1, radix = base.DEC},
        {name = "nTrfId", size = 1, radix = base.DEC},
        {name = "clearTrfStats", size = 1, radix = base.DEC},
        {name = "clearBearerStats", size = 1, radix = base.DEC},
        {name = "bAckMode", size = 1, radix = base.DEC},
        {name = "isCmdForTcpClient", size = 1, radix = base.DEC},
        {name = "ndlCrptPacket", size = 4, radix = base.DEC},
        {name = "nCrptPacketThrshld", size = 4, radix = base.DEC},
        {name = "nfieldCorruptionIndicator", size = 4, radix = base.DEC},
        {name = "nipVersionOverrideValue", size = 1, radix = base.DEC},
        {name = "traffic_type", size = 1, radix = base.DEC},
		{name = "cmdsRtpCodecType", size = 4, radix = base.DEC},
		{name = "rtpCodecType", size = 4, radix = base.DEC},
		{name = "rtpPayloadSize", size = 4, radix = base.DEC},
		{name = "rtpPeriod", size = 4, radix = base.DEC},
		{name = "rtpTimestampStep", size = 4, radix = base.DEC},
		{name = "rtp_ssrc", size = 4, radix = base.DEC},
		{name = "session_id", size = 4, radix = base.DEC},
		{name = "rtpSilencePayloadSize", size = 4, radix = base.DEC},
		{name = "rtpSendSilencePeriod", size = 2, radix = base.DEC},
		{name = "rtpVoiceSeconds", size = 2, radix = base.DEC},
		{name = "rtpSilenceSeconds", size = 2, radix = base.DEC},
		{name = "src_port", size = 2, radix = base.DEC},
		{name = "version", size = 1, radix = base.DEC},
		{name = "dst_port", size = 2, radix = base.DEC},
		{name = "port", size = 4, radix = base.DEC},
		{name = "ipv4_address", size = 4, radix = base.HEX},
		{name = "ipv6_address", size = 16, radix = base.NONE},
    }

    for _, field in pairs(fields) do
        fname = field.name
        msg_field_name[mtype][fname] = fname
        msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
        msg_field_radix[mtype][fname] = field.radix
        msg_field_num_bytes[mtype][fname] = field.size
    end
	
	local function addField(tree, fname, buffer, offset)
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]))
		return offset + msg_field_num_bytes[mtype][fname]
	end
	
	local function addIpAddress(ip_addr_tree, buffer, offset)
		fname = "version"
		local vrsn = buffer(offset, msg_field_num_bytes[mtype][fname]):uint()
		ip_addr_tree:add(version_enum, buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]
		if vrsn == 4 then
			fname = "ipv4_address"
			ip_addr_tree:add(ipv4_field, buffer(offset, msg_field_num_bytes[mtype][fname]))
			offset = offset + msg_field_num_bytes[mtype][fname]offset = offset + 16
		elseif vrsn == 6 then
			fname = "ipv6_address"
			ip_addr_tree:add(ipv6_field, buffer(offset, msg_field_num_bytes[mtype][fname]))
			offset = offset + msg_field_num_bytes[mtype][fname]
			offset = offset + 4
		elseif vrsn == 24 then
			local ipv4ipv6_tree = ip_addr_tree:add("IP_V4V6_ADDRESS")
			fname = "ipv4_address"
			ipv4ipv6_tree:add(ipv4_field, buffer(offset, msg_field_num_bytes[mtype][fname]))
			offset = offset + msg_field_num_bytes[mtype][fname]
			fname = "ipv6_address"
			ipv4ipv6_tree:add(ipv6_field, buffer(offset, msg_field_num_bytes[mtype][fname]))
			offset = offset + msg_field_num_bytes[mtype][fname]
		end
		return offset
	end
	
	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
	
		local idsToAdd = {"global_ue_id", "local_ue_id", "drbId"}
		for _, fname in ipairs(idsToAdd) do
			offset  = addField(tree, fname, buffer, offset)
		end
		
		
		fname = "traffic_type"
		local trf_type = buffer(offset, msg_field_num_bytes[mtype][fname]):uint()
		tree:add(traffic_type_enum, buffer(offset, msg_field_num_bytes[mtype][fname]))
		offset = offset + msg_field_num_bytes[mtype][fname]
			
		if trf_type == 0 then
			local internal_traffic_tree = tree:add("INTERNAL_TRAFFIC_CONFIGURATION")
			do
				fname = "direction"
				internal_traffic_tree:add(direction_enum, buffer(offset, msg_field_num_bytes[mtype][fname]))
				offset = offset + msg_field_num_bytes[mtype][fname]

				
				local ue_src_ip_tree = internal_traffic_tree:add("ue_src_ip")
				do	
					offset = addIpAddress(ue_src_ip_tree, buffer, offset)
				end
				
				local ue_dst_ip_tree = internal_traffic_tree:add("ue_dst_ip")
				do
					offset = addIpAddress(ue_dst_ip_tree, buffer, offset)
				end
				
				local intTrfFieldsToAdd = {
					"nL3PktLo", "nL3PktHi", "nPeriod", "nBurst",
					"nTrProto", "nLimit", "nLimitType", "nTrfId",
					"clearTrfStats", "clearBearerStats", "bAckMode",
					"isCmdForTcpClient", "ndlCrptPacket", "nCrptPacketThrshld",
					"nfieldCorruptionIndicator", "nipVersionOverrideValue"
				}
				
				for _, fname in ipairs(intTrfFieldsToAdd) do
					offset = addField(internal_traffic_tree, fname, buffer, offset)
				end
				
				local rtp_traffic_tree = internal_traffic_tree:add("rtp_traffic")
				do
					local rtpFieldsToAdd = {
						"cmdsRtpCodecType", "rtpCodecType", "rtpPayloadSize", "rtpPeriod",
						"rtpTimestampStep", "rtp_ssrc", "session_id", "rtpSilencePayloadSize",
						"rtpSendSilencePeriod", "rtpVoiceSeconds", "rtpSilenceSeconds"
					}
					
					for _, fname in ipairs(rtpFieldsToAdd) do
						offset = addField(rtp_traffic_tree, fname, buffer, offset)
					end
					
					local remote_ip_tree = rtp_traffic_tree:add("remote_ip")
					do
						offset = addIpAddress(remote_ip_tree, buffer, offset)
					end	
					
					fname = "port"
					offset = addField(rtp_traffic_tree, fname, buffer, offset)
						
					fname = "src_port"
					offset = addField(rtp_traffic_tree, fname, buffer, offset)
				
					fname = "dst_port"
					offset = addField(rtp_traffic_tree, fname, buffer, offset)	
				end
			end
		elseif trf_type == 1 then
			do
				local external_traffic_tree = tree:add("EXTERNAL_TRAFFIC_CONFIGURATION")
				local pdu_session_ip_config_tree = external_traffic_tree:add("PDU_SESSION_IP_ADDR_CFG")
				do
					local pdu_session_ip_tree = pdu_session_ip_config_tree:add("pdu_session_ip")
					offset = addIpAddress(pdu_session_ip_tree, buffer, offset)
				end
				do
					local ext_dl_nat_gw_ip_tree = pdu_session_ip_config_tree:add("ext_dl_nat_gw_ip")
					offset = addIpAddress(ext_dl_nat_gw_ip_tree, buffer, offset)
				end
				do
					local ext_ul_nat_gw_ip_tree = pdu_session_ip_config_tree:add("ext_ul_nat_gw_ip")
					offset = addIpAddress(ext_ul_nat_gw_ip_tree, buffer, offset)
				end
				do
					local ext_ue_nat_ip_tree = pdu_session_ip_config_tree:add("ext_ue_nat_ip")
					offset = addIpAddress(ext_ue_nat_ip_tree, buffer, offset)
				end
			end
		end
	end
end

do
	local mtype = msg_name_to_type.CTRL_MIB_NR

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "System Frame Number")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.systemFrameNumber")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SubCarrier Spacing Common")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.subCarrierSpacingCommon")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SSB Subcarrier Offset")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.ssb_SubcarrierOffset")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Dmrs TypeA Position")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.dmrs_TypeA_Position")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Control Resource Set Zero")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.pdcch_ConfigSIB1.controlResourceSetZero")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Search Space Zero")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ctrl_mib_nr.pdcch_ConfigSIB1.searchSpaceZero")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		  offset = default_dissection(mtype, buffer, pinfo, tree, offset)
	end
end

do
	local mtype = msg_name_to_type.CTRL_SIB1_NR

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	local ctrlSib1NR = ".ctrl_sib1_nr"
	local si_SchedulingInfo = ctrlSib1NR..".si_SchedulingInfo"
	local servingCellConfigCommon = ctrlSib1NR..".servingCellConfigCommon"
	local uplinkConfigCommon = servingCellConfigCommon..".uplinkConfigCommon"
	local initialUlBwp = uplinkConfigCommon..".initialUplinkBWP"
	local downlinkConfigCommon = servingCellConfigCommon..".downlinkConfigCommon"
	local initialDlBwp = downlinkConfigCommon..".initialDownlinkBWP"
	local ssbPos       = servingCellConfigCommon..".ssb_PositionsInBurst"

	table.insert(msg_field_name[mtype], "Ctrl Sib1 Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..ctrlSib1NR..".bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SI SchedulingInfo Si Mask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..si_SchedulingInfo..".si_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	local maxNumberOfSIMsg = 4
	for index = 1, maxNumberOfSIMsg do
		table.insert(msg_field_name[mtype], "Scheduling Info Periodicity")
		table.insert(msg_field_filter[mtype], proxyproto_filter..si_SchedulingInfo..".schedulingInfo"..index..".si_Periodicity")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)
	end

	table.insert(msg_field_name[mtype], "SI SchedulingInfo Window Length")
	table.insert(msg_field_filter[mtype], proxyproto_filter..si_SchedulingInfo..".si_WindowLength")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Serving Cell Info Config Common Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..servingCellConfigCommon..".bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "UL BWP Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "UL BWP Location")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".genericParameters.location")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UL BWP Bandwidth")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".genericParameters.bandwidth")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "UL BWP Subcarrier Spacing")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".genericParameters.subcarrierSpacing")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUSCH Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pusch_ConfigCommon.bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUSCH Time Domain Resource Allocation Count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pusch_ConfigCommon.puschTimeDomainAllocationCommonList.numOfPuschTimeDomainResourceAllocation")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	local numOfPuschTimeDomainResourceAllocation = 16
	local puschTimeDomainResourceAllocation = ".pusch_ConfigCommon.puschTimeDomainAllocationCommonList.PUSCH_TimeDomainResourceAllocation"

	for index = 1, numOfPuschTimeDomainResourceAllocation do
		local k2          = puschTimeDomainResourceAllocation..index..".k2"
		local mappingType = puschTimeDomainResourceAllocation..index..".mappingType"
		local startSymbol = puschTimeDomainResourceAllocation..index..".startSymbol"
		local length      = puschTimeDomainResourceAllocation..index..".length"

		table.insert(msg_field_name[mtype], "PUSCH Time Domain Resource Allocation K2")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..k2)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PUSCH Time Domain Resource Allocation Mapping Type")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..mappingType)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PUSCH Time Domain Resource Allocation Start Symbol")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..startSymbol)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PUSCH Time Domain Resource Allocation Length")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..length)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)
	end

	table.insert(msg_field_name[mtype], "PUSCH Delta Preamble")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pusch_ConfigCommon.msg3_DeltaPreamble")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUSCH P0 Nominal With Grant")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pusch_ConfigCommon.p0_NominalWithGrant")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "PUCCH Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pucch_ConfigCommon.bit_mask")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUCCH Resource Common")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pucch_ConfigCommon.pucch_ResourceCommon")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUCCH Group Hopping")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pucch_ConfigCommon.pucch_GroupHopping")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PUCCH Hopping ID")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pucch_ConfigCommon.hoppingId")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "PUCCH P0 Nominal")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".pucch_ConfigCommon.p0_nominal")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RACH Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Subcarrier Spacing")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.msg1_SubcarrierSpacing")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Contention Resolution Timer")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.ra_ContentionResolutionTimer")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Rsrp Threshold Ssb")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rsrp_ThresholdSSB")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Total Number Of RA Preambles")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.totalNumberOfRA_Preambles")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Config Generic Prach Configuration Index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.prach_ConfigurationIndex")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Config Generic Message 1 Frequency Start")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.msg1_FrequencyStart")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RACH Config Generic Ra Response Window")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.ra_ResponseWindow")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Config Generic Preamble Received Target Power")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.preambleReceivedTargetPower")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "RACH Config Generic Preamble Trans Max")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.preambleTransMax")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Config Generic Power Ramping Step")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.powerRampingStep")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Config Generic Message 1 Fdm")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.rach_ConfigGeneric.msg1_FDM")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Group B Configured Number Of RA Preambles Group A")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.groupBconfigured.numberOfRA_PreamblesGroupA")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Ssb Per Rach Occassion And Cb Preambles Per Ssb Choice")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.ssb_perRACH_OccasionAndCB_PreamblesPerSSB.choice")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Ssb Per Rach Occassion And Cb Preambles Per Ssb")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.ssb_perRACH_OccasionAndCB_PreamblesPerSSB.u")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Root Sequence Choice")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.prach_RootSequenceIndex.choice")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "RACH Root Sequence Index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialUlBwp..".rach_ConfigCommon.prach_RootSequenceIndex.u")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	local maxScsULCount = 5
	for index = 1, maxScsULCount do
		table.insert(msg_field_name[mtype], "Frequency Info UL SCSSpecificCarrierList OffsetToCarrier")
		table.insert(msg_field_filter[mtype], proxyproto_filter..uplinkConfigCommon..".frequencyInfoUL.scsSpecificCarrierList"..index..".offsetToCarrier")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "Frequency Info UL SCSSpecificCarrierList SubcarrierSpacing")
		table.insert(msg_field_filter[mtype], proxyproto_filter..uplinkConfigCommon..".frequencyInfoUL.scsSpecificCarrierList"..index..".subcarrierSpacing")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "Frequency Info UL SCSSpecificCarrierList CarrierBandwidth")
		table.insert(msg_field_filter[mtype], proxyproto_filter..uplinkConfigCommon..".frequencyInfoUL.scsSpecificCarrierList"..index..".carrierBandwidth")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)
	end

	table.insert(msg_field_name[mtype], "Frequency Info UL PMax")
	table.insert(msg_field_filter[mtype], proxyproto_filter..uplinkConfigCommon..".frequencyInfoUL.p_Max")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "TimeAlignmentTimerCommon")
	table.insert(msg_field_filter[mtype], proxyproto_filter..uplinkConfigCommon..".timeAlignmentTimerCommon")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Frequency Info DL Specific Carrier Count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.specificCarrierCount")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	local maxScsDLCount = 5
	for index = 1, maxScsDLCount do
		table.insert(msg_field_name[mtype], "Frequency Info DL SCSSpecificCarrierListsubcarrierSpacing OffsetToCarrier")
		table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.scsSpecificCarrierList"..index..".offsetToCarrier")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "Frequency Info DL SCSSpecificCarrierList SubcarrierSpacing")
		table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.scsSpecificCarrierList"..index..".subcarrierSpacing")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "Frequency Info DL SCSSpecificCarrierList CarrierBandwidth")
		table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.scsSpecificCarrierList"..index..".carrierBandwidth")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)
	end

	table.insert(msg_field_name[mtype], "Frequency Info DL FreqBandIndicatorNR")
	table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.freqBandIndicatorNR")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "Frequency Info DL OffsetToPointA")
	table.insert(msg_field_filter[mtype], proxyproto_filter..downlinkConfigCommon..".frequencyInfoDL.offsetToPointA")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "DL BWP Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "DL BWP Location")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".genericParameters.location")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "DL BWP Bandwidth")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".genericParameters.bandwidth")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "DL BWP SubCarrier Spacing")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".genericParameters.subcarrierSpacing")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDSCH Time Domain Resource Allocation Count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdsch_ConfigCommon.pdschTimeDomainAllocationCommonList.numOfPdschTimeDomainResourceAllocation")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	local numOfPdschTimeDomainResourceAllocation = 16

	for index = 1, numOfPdschTimeDomainResourceAllocation do
		local k2          = ".pusch_ConfigCommon.pdschTimeDomainAllocationCommonList.PDSCH_TimeDomainResourceAllocation"..index..".k2"
		local mappingType = ".pusch_ConfigCommon.pdschTimeDomainAllocationCommonList.PDSCH_TimeDomainResourceAllocation"..index..".mappingType"
		local startSymbol = ".pusch_ConfigCommon.pdschTimeDomainAllocationCommonList.PDSCH_TimeDomainResourceAllocation"..index..".startSymbol"
		local length      = ".pusch_ConfigCommon.pdschTimeDomainAllocationCommonList.PDSCH_TimeDomainResourceAllocation"..index..".length"

		table.insert(msg_field_name[mtype], "PDSCH Time Domain Resource Allocation K2")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..k2)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDSCH Time Domain Resource Allocation Mapping Type")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..mappingType)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDSCH Time Domain Resource Allocation Start Symbol")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..startSymbol)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDSCH Time Domain Resource Allocation Length")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..length)
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)
	end

	table.insert(msg_field_name[mtype], "PDCCH Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Control Resource Set Zero")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.controlResourceSetZero")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Bitmask")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.bit_mask")
	table.insert(msg_field_radix[mtype], base.HEX)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Control Resource Set Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.controlResourceSetId")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Frequency Domain Resources")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.frequencyDomainResources")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 8)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet duration")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.duration")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Cce Req Mapping Type")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.cce_REG_MappingType")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Shift Index")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.shiftIndex")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Interleaver Size")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.interleaverSize")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Reg Bundle Size")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.reg_BundleSize")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Control ResourceSet Precoder Granularity")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonControlResourceSet.precoderGranularity")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Search Space Zero")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.searchSpaceZero")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Common Search Space Count")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceCount")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	local commonSearchSpaceCount = 4
	for index = 1, commonSearchSpaceCount do
		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Bitmask")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".bit_mask")
		table.insert(msg_field_radix[mtype], base.HEX)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Search Space Id")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".searchSpaceId")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Control Resource Set Id")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".controlResourceSetId")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Monitoring Slot Periodicity And Offset Type")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".monitoringSlotPeriodicityAndOffset.type")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Monitoring Slot Periodicity And Offset Value")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".monitoringSlotPeriodicityAndOffset.value")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Duration")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".duration")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Monitoring Symbols Within Slot")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".monitoringSymbolsWithinSlot")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 2)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Number Of Canditates AggregationLevel1")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".nrofCandidates.aggregationLevel1")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Number Of Canditates AggregationLevel2")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".nrofCandidates.aggregationLevel2")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Number Of Canditates aggregationLevel4")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".nrofCandidates.aggregationLevel4")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Number Of Canditates aggregationLevel8")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".nrofCandidates.aggregationLevel8")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space List Number Of Canditates aggregationLevel16")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".nrofCandidates.aggregationLevel16")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)

		table.insert(msg_field_name[mtype], "PDCCH Common Search Space Search Space Type")
		table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.commonSearchSpaceList"..index..".searchSpaceType")
		table.insert(msg_field_radix[mtype], base.DEC)
		table.insert(msg_field_num_bytes[mtype], 1)
	end

	table.insert(msg_field_name[mtype], "PDCCH Search Space SIB1")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.searchSpaceSIB1")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Search Space Other System Information")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.searchSpaceOtherSystemInformation")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "PDCCH Ra Search Space")
	table.insert(msg_field_filter[mtype], proxyproto_filter..initialDlBwp..".pdcch_ConfigCommon.ra_SearchSpace")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SSB PositionsInBurst BitMapType")
	table.insert(msg_field_filter[mtype], proxyproto_filter..ssbPos..".bitmapType")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "SSB PositionsInBurst BitMap")
	table.insert(msg_field_filter[mtype], proxyproto_filter..ssbPos..".bitmap")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 8)

	table.insert(msg_field_name[mtype], "SS PBCH BlockPower")
	table.insert(msg_field_filter[mtype], proxyproto_filter..servingCellConfigCommon..".ss_PBCH_BlockPower")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	table.insert(msg_field_name[mtype], "Timing Advance Offset")
	table.insert(msg_field_filter[mtype], proxyproto_filter..servingCellConfigCommon..".n_TimingAdvanceOffset")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

	table.insert(msg_field_name[mtype], "SSB Periodicity Serving Cell")
	table.insert(msg_field_filter[mtype], proxyproto_filter..servingCellConfigCommon..".ssb_PeriodicityServingCell")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 1)

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		  offset = default_dissection(mtype, buffer, pinfo, tree, offset)
	end
end

do
        local mtype = msg_name_to_type.DL_SHORT_MESSAGE

        msg_field_name[mtype] = {}
        msg_field_num_bytes[mtype] = {}
        msg_field_filter[mtype] = {}
        msg_field_radix[mtype] = {}

        table.insert(msg_field_name[mtype], "Sfn")
        table.insert(msg_field_filter[mtype], proxyproto_filter..".sfn")
        table.insert(msg_field_radix[mtype], base.DEC)
        table.insert(msg_field_num_bytes[mtype], 2)


        table.insert(msg_field_name[mtype], "Slot")
        table.insert(msg_field_filter[mtype], proxyproto_filter..".slot")
        table.insert(msg_field_radix[mtype], base.DEC)
        table.insert(msg_field_num_bytes[mtype], 1)

        table.insert(msg_field_name[mtype], "System Info Modification")
        table.insert(msg_field_filter[mtype], proxyproto_filter..".systemInfoModification")
        table.insert(msg_field_radix[mtype], base.DEC)
        table.insert(msg_field_num_bytes[mtype], 1)
        table.insert(msg_field_name[mtype], "Etws And Cmas Indication")
        table.insert(msg_field_filter[mtype], proxyproto_filter..".etwsAndCmasIndication")
        table.insert(msg_field_radix[mtype], base.DEC)
        table.insert(msg_field_num_bytes[mtype], 1)

        msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
                offset = default_dissection(mtype, buffer, pinfo, tree, offset)
        end
end

do
	local mname = "RATE"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	local avgWinSize = 8
	for index = 1, avgWinSize do
		fname = "rate"
		msg_field_name[mtype][fname .. index] = fname .. index
		msg_field_filter[mtype][fname .. index] = proxyproto_filter .. "." .. mname .. "." .. fname .. "." .. index
		msg_field_radix[mtype][fname .. index] = base.DEC
		msg_field_num_bytes[mtype][fname .. index] = 4
	end

	fname = "xhsfn_index"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4


	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		local avgWinSize = 8
		for index = 1, avgWinSize do
			fname = "rate" .. index
			tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
			offset = offset + msg_field_num_bytes[mtype][fname]
		end

		fname = "xhsfn_index"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		return offset
	end
end

do
	local mname = "CELL_MBMS_MAC_STATS"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "num_of_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "size_of_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 8

	fname = "num_of_ce_padding"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "size_of_padding"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 8

	fname = "num_of_discarded_ierr"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_discarded_acr"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_sfns"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_missed_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_unexpected_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_empty_sfns"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_reserved_lcid"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_mcch_sdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_mtch_sdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_msis"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_incorrect_lcid_in_msi"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_exceeded_mtch_in_msi"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)

		local subtree1 =  tree:add("rate")
		offset = msg_dissect[msg_name_to_type.RATE](buffer, pinfo, subtree1, offset)

		fname = "num_of_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "size_of_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_ce_padding"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "size_of_padding"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_discarded_ierr"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_discarded_acr"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_sfns"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_missed_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_unexpected_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_empty_sfns"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_reserved_lcid"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_mcch_sdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_mtch_sdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_msis"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_incorrect_lcid_in_msi"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_exceeded_mtch_in_msi"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		return offset
	end
end

do
	local mname = "DL_RLC_DCCH_DTCH_NON_CC"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "num_of_sdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "size_of_sdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 8

	fname = "num_of_sdus_discarded_ierr"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_reestablish"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_timer_reorder_exp"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "num_of_sdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "size_of_sdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_sdus_discarded_ierr"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_reestablish"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_timer_reorder_exp"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		return offset
	end
end

do
	local mname = "DL_RLC_DCCH_DTCH_CC"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "num_of_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "size_of_pdus"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 8

	fname = "num_of_pdus_ctrl"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_full"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_segment"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_dup_full"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_dup_full_for_segment"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_dup_segment"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_dup_segment_for_full"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_overlap_segment"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_discarded_oow"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_discarded_acr"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "num_of_pdus_discarded_ierr"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	fname = "time_first_to_last_pdu"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 4

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "num_of_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "size_of_pdus"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_ctrl"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_full"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_segment"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_dup_full"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_dup_full_for_segment"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_dup_segment"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_dup_segment_for_full"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_overlap_segment"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_discarded_oow"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_discarded_acr"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "num_of_pdus_discarded_ierr"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "time_first_to_last_pdu"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		return offset
	end
end

do
	local mname = "RB_DL_RLC_DCCH"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	local fname

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	fname = "lcid"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	fname = "rlc_mode"
	msg_field_name[mtype][fname] = fname
	msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
	msg_field_radix[mtype][fname] = base.DEC
	msg_field_num_bytes[mtype][fname] = 1

	msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
		fname = "lcid"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		fname = "rlc_mode"
		tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
		offset = offset + msg_field_num_bytes[mtype][fname]

		local subtree1 = tree:add("data_0")
		offset = msg_dissect[msg_name_to_type.DL_RLC_DCCH_DTCH_NON_CC](buffer, pinfo, subtree1, offset)

		local subtree2 = tree:add("data_1")
		offset = msg_dissect[msg_name_to_type.DL_RLC_DCCH_DTCH_CC](buffer, pinfo, subtree2, offset)
		return offset
	end
end

do
		local mname = "CTRL_CELL_STATS_MBMS_RSP"
		local mtype = msg_name_to_type[mname]
		mname = string.lower(mname)

		local fname
        msg_field_name[mtype] = {}
        msg_field_num_bytes[mtype] = {}
        msg_field_filter[mtype] = {}
        msg_field_radix[mtype] = {}

		fname = "tran_node"
		msg_field_name[mtype][fname] = fname
		msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
		msg_field_radix[mtype][fname] = base.DEC
		msg_field_num_bytes[mtype][fname] = 2

		fname = "tran_param"
		msg_field_name[mtype][fname] = fname
		msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
		msg_field_radix[mtype][fname] = base.DEC
		msg_field_num_bytes[mtype][fname] = 2

		fname = "area_id"
		msg_field_name[mtype][fname] = fname
		msg_field_filter[mtype][fname] = proxyproto_filter .. "." .. mname .. "." .. fname
		msg_field_radix[mtype][fname] = base.DEC
		msg_field_num_bytes[mtype][fname] = 2

		msg_dissect[mtype] = function(buffer, pinfo, tree, offset)
			fname = "tran_node"
			tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
			offset = offset + msg_field_num_bytes[mtype][fname]

			fname = "tran_param"
			tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
			offset = offset + msg_field_num_bytes[mtype][fname]

			local subtree1 = tree:add("mac")
			offset = msg_dissect[msg_name_to_type.CELL_MBMS_MAC_STATS](buffer, pinfo, subtree1, offset)

			local maxNumSessionPerMbsfnArea = 32
			subtree2 = tree:add("rlc[] ("..maxNumSessionPerMbsfnArea.." elements)")
			for i=1,maxNumSessionPerMbsfnArea do
				local subtree3 = subtree2:add("rlc[" .. i - 1 .. "]")
				offset = msg_dissect[msg_name_to_type.RB_DL_RLC_DCCH](buffer, pinfo, subtree3, offset)
			end

			subtree4 = tree:add("pdu_rate[] ("..maxNumSessionPerMbsfnArea.." elements)")
			for i=1,maxNumSessionPerMbsfnArea do
				local subtree5 = subtree4:add("pdu_rate[" .. i - 1 .. "]")
				offset = msg_dissect[msg_name_to_type.RATE](buffer, pinfo, subtree5, offset)
			end

			fname = "area_id"
			tree:add(msg_field_proto[mtype][fname], buffer(offset, msg_field_num_bytes[mtype][fname]));
			offset = offset + msg_field_num_bytes[mtype][fname]
		end

end

do
	local mname = "CTRL_UE_PDSCH_STATS_NR_RSP"
	local mtype = msg_name_to_type[mname]
	mname = string.lower(mname)

	msg_field_name[mtype] = {}
	msg_field_num_bytes[mtype] = {}
	msg_field_filter[mtype] = {}
	msg_field_radix[mtype] = {}

	table.insert(msg_field_name[mtype], "Global UE Id")
	table.insert(msg_field_filter[mtype], proxyproto_filter..".ue_id")
	table.insert(msg_field_radix[mtype], base.DEC)
	table.insert(msg_field_num_bytes[mtype], 2)

end

-- Registration of protocol fields
proxyproto_protocol.fields = { f_hdr_proto_type, f_hdr_proto_nr_type, f_hdr_msg_type, f_hdr_enb_id, f_hdr_cell_id, f_remaining_data }

for mtype, _ in pairs(msg_type_to_name) do
	msg_field_proto[mtype] = {}

	if msg_register_fields[mtype] ~= nil then
		msg_register_fields[mtype](proxyproto_protocol)
	else
		default_registration(mtype, proxyproto_protocol)
	end
end

function msg_dissect_common(buffer, pinfo, root, hdr_proto_type)
	pinfo.cols.protocol = proxyproto_protocol.name;
	local offset = 0

	local pktlen = buffer:reported_length_remaining();
	local tree = root:add(proxyproto_protocol, buffer:range(0,pktlen));
	tree_arr[0] = root
	tree_arr[1] = tree

	-- Common Header Fields
	tree_arr[1]:add(hdr_proto_type, buffer(offset, 2))
	offset = offset + 2
	tree_arr[1]:add(f_hdr_msg_type, buffer(offset, 2))
	offset = offset + 2

	-- Calculate Cell ID
	local gtp_teid_field_info  = f_gtp_teid()
	local enb_id, cell_id = derive_cell_id_from_teid(gtp_teid_field_info.value)
	tree_arr[1]:add(f_hdr_enb_id, buffer(offset, 2):uint())
	tree_arr[1]:add(f_hdr_cell_id, buffer(offset + 2, 2):uint())
	offset = offset + 2

	local mtype = buffer(2, 2):uint()
	pinfo.cols.info = msg_type_to_name[mtype]
	if msg_dissect[mtype] ~= nil then
		msg_dissect[mtype](buffer, pinfo, tree_arr[1], offset)
	else
		default_dissection(mtype, buffer, pinfo, tree_arr[1], offset)
	end
end

function get_protocol_type(buffer)
	return buffer(0, 2):uint()
end

function get_len(buffer)
	return buffer(21, 1):uint()
end

-- Entry point for the dissection of an I-PHY message
function proxyproto_protocol.dissector(buffer, pinfo, root)
	protocol_type = get_protocol_type(buffer)

	-- ProxyProto (LTE) protocol
	if protocol_type == lte_protocol_type then
		msg_dissect_common(buffer, pinfo, root, f_hdr_proto_type)
	-- ProxyProto (NR) protocol
	elseif protocol_type == nr_protocol_type then
		msg_dissect_common(buffer, pinfo, root, f_hdr_proto_nr_type)
	end
end

DissectorTable.get("gtp.sub_proto_id"):add(0x32, proxyproto_protocol)
DissectorTable.get("gtp.sub_proto_id"):add(0x34, proxyproto_protocol)
DissectorTable.get("sctp.ppi"):add(0x3233, Dissector.get("gtp"))
DissectorTable.get("sctp.ppi"):add(0x3433, Dissector.get("gtp"))
