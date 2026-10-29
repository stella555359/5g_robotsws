----------------------------------------------------------------------------------------------------
-- VARIABLES
----------------------------------------------------------------------------------------------------

AMF_COUNT = 3  -- Total number of AMF/UPF: Single AMF supports Max 2000UEs only
FIRST_AMF_ID = 1  -- Starting AMF id
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
UEC_COUNT = 3  -- Total number of UEC
PLMN = "310:260"  -- gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
SNSSAI = "0x01:0xD143A5"  -- SLICE ID
TAC = 200  -- gNB & AMF supported Tracking Area Code
SA_IMSI = 21640000

----------------------------------------------------------------------------------------------------
-- COMMON VARIABLES FOR ALL WTS
----------------------------------------------------------------------------------------------------
SERVER_IP="10.0.2.1"
EDAEMON_PORT="30000"
GNB_S1U_ADDR="10.0.1.2"
GNB_X2_ADDR="10.0.1.2"
GNB_XN_ADDR="10.0.1.2"
GNB_NG_ADDR="10.0.1.2"

--------------------------------------------------------------------------------------
-- TABLES
--------------------------------------------------------------------------------------
-- IP table for each UPF
AP_IP_TABLE = {
	"10.0.2.80"
}

-- IP table for each AMF
AMF_IP_TABLE = {
	"10.0.1.1",
	"10.0.1.61",
	"10.0.1.62",
--	"10.0.1.63",
--	"10.0.1.64"
}  

-- IP table for each UPF
UPF_IP_TABLE = {
	"1.2.0.1",
	"1.2.8.1",
	"1.2.16.1",
--	"1.2.24.1",
--	"1.2.32.1"
}

-- PCI calculation: "16:2" == 16x3+2 == 50 == physical cell id 50. Always multiply by 3 and add 0-2
-- !! Cells id 5, 6, 9 and 12 are MPLANE only
CELL_TABLE = {
	{cell_id=1, tdd_flag="on", pci="17:0", nrarfcn="528000:528000", gscn="6501", ap_num=1, additional="8DL_SRS"},
	{cell_id=2, tdd_flag="on", pci="17:1", nrarfcn="509058:509058", gscn="6276", ap_num=1, additional="8DL_SRS"},
	{cell_id=3, tdd_flag="on", pci="17:2", nrarfcn="528000:528000", gscn="6501", ap_num=1, additional="8DL_SRS"},
	{cell_id=4, tdd_flag="on", pci="18:0", nrarfcn="509058:509058", gscn="6276", ap_num=1, additional="8DL_SRS"},
	{cell_id=5, tdd_flag="on", pci="18:1", nrarfcn="528000:528000", gscn="6501", ap_num=1, additional="none"},
	{cell_id=6, tdd_flag="on", pci="18:2", nrarfcn="509058:509058", gscn="6276", ap_num=1, additional="none"},
	{cell_id=7, tdd_flag="off", pci="19:0", nrarfcn="381000:397000", gscn="4961", ap_num=1, additional="none"},
	{cell_id=8, tdd_flag="off", pci="19:1", nrarfcn="381000:397000", gscn="4961", ap_num=1, additional="none"},
	{cell_id=9, tdd_flag="off", pci="19:2", nrarfcn="381000:397000", gscn="4961", ap_num=1, additional="none"},
	{cell_id=10, tdd_flag="off", pci="20:0", nrarfcn="135600:126400", gscn="1565", ap_num=1, additional="none"},
	{cell_id=11, tdd_flag="off", pci="20:1", nrarfcn="135600:126400", gscn="1565", ap_num=1, additional="none"},
	{cell_id=12, tdd_flag="off", pci="20:2", nrarfcn="135600:126400", gscn="1565", ap_num=1, additional="none"}
}

--------------------------------------------------------------------------------------
-- UE groups and allocation tables and variables
--------------------------------------------------------------------------------------

-- Include cell ids for which you want similar UE groups.
-- Specify those UE groups in the next table TEST_TYPES_PER_CELL
INCLUDED_FOR_TEST_TYPES_PER_CELL = {1, 3, 7, 8, 10, 11}
-- UE groups will be allocated for each cell that are included in INCLUDED_FOR_TEST_TYPES_PER_CELL
-- These will be created with ue_group id 11, 12, 21, 22, 31, 32 and so on.. (f.e. when 2 groups per cell) 
-- RESTRICTION: Currently only 9 groups can be defined (ids may overlap otherwise).
TEST_TYPES_PER_CELL = {
--	{ue_amount = 15, file = 'Simulation_State_transition_10s_inactivity.cfg'},
--	{ue_amount = 10, file = 'Simulation_UE_AMF_paging.cfg'},
	{ue_amount = 5, file = 'Throughput_DL_8Mbps_continuous.cfg'},
	{ue_amount = 5, file = 'Throughput_DL_500kbps_UL_10Mbps_periodic.cfg'},
	{ue_amount = 5, file = 'Simulation_DL_2Mbps_UL_40kbps_TCP_Video_Streaming.cfg'},
	{ue_amount = 5, file = 'Simulation_VoNR_call.cfg'},
}

-- If you want to allocate different amount of UEs for certain cells use this table
-- UE group id naming: Starts at 701 and continues to 702, 703, 704...
-- MAX ID FOR UE_GROUP IS 1024 !!!
-- Setting UEC ID is OPTIONAL ! Set the uec_id to 'auto' if you want it to be set automatically.
INDIVIDUAL_UE_GROUPS = {
	{cell_id = 1, file = 'Mobility_intrafreq_intragnb_ho_Cell1_Cell2_Cell3.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 3, file = 'Mobility_intrafreq_intragnb_ho_Cell3_Cell8_Cell11.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 7, file = 'Mobility_intrafreq_intragnb_ho_Cell7_Cell10_Cell8.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 10, file = 'Mobility_intrafreq_intragnb_ho_Cell10_Cell7_Cell11.cfg', ue_amount = 30, uec_id = 'auto'},
}
