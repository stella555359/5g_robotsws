----------------------------------------------------------------------------------------------------
-- VARIABLES
----------------------------------------------------------------------------------------------------

AMF_COUNT = 3  -- Total number of AMF/UPF: Single AMF supports Max 2000UEs only
FIRST_AMF_ID = 1  -- Starting AMF id
END_AMF_ID = FIRST_AMF_ID + AMF_COUNT - 1
UEC_COUNT = 3  -- Total number of UEC
PLMN = "311:489"  -- gNB/AMF supported PLMN, Append zero '0' if its 5 digit (244:08) insted of 6 digit (233:489)
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
CELL_TABLE = {
	{cell_id=1, tdd_flag="off", pci="16:2", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=2, tdd_flag="off", pci="17:0", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=3, tdd_flag="off", pci="17:1", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
	{cell_id=4, tdd_flag="off", pci="17:2", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
	{cell_id=5, tdd_flag="off", pci="18:0", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=6, tdd_flag="off", pci="18:1", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=7, tdd_flag="off", pci="18:2", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
	{cell_id=8, tdd_flag="off", pci="19:0", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
	{cell_id=9, tdd_flag="off", pci="19:1", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=10, tdd_flag="off", pci="19:2", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
	{cell_id=11, tdd_flag="off", pci="20:0", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
	{cell_id=12, tdd_flag="off", pci="20:1", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=13, tdd_flag="off", pci="20:2", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=14, tdd_flag="off", pci="21:0", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=15, tdd_flag="off", pci="21:1", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=16, tdd_flag="off", pci="21:2", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=17, tdd_flag="off", pci="22:0", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=18, tdd_flag="off", pci="22:1", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=19, tdd_flag="off", pci="22:2", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=20, tdd_flag="off", pci="23:0", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=21, tdd_flag="off", pci="23:1", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=22, tdd_flag="off", pci="23:2", nrarfcn="142600:153600", gscn="1917", ap_num=1, additional="none"},
--	{cell_id=23, tdd_flag="off", pci="24:0", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"},
--	{cell_id=24, tdd_flag="off", pci="24:1", nrarfcn="146600:157600", gscn="1967", ap_num=1, additional="none"}
}

--------------------------------------------------------------------------------------
-- UE groups and allocation tables and variables
--------------------------------------------------------------------------------------

-- Include cell ids for which you want similar UE groups.
-- Specify those UE groups in the next table TEST_TYPES_PER_CELL
INCLUDED_FOR_TEST_TYPES_PER_CELL = {1, 4, 5, 8, 9, 12}
-- UE groups will be allocated for each cell that are included in INCLUDED_FOR_TEST_TYPES_PER_CELL
-- These will be created with ue_group id 11, 12, 21, 22, 31, 32 and so on.. (f.e. when 2 groups per cell) 
-- RESTRICTION: Currently only 9 groups can be defined (ids may overlap otherwise).
TEST_TYPES_PER_CELL = {
	--{ue_amount = 15, file = 'Simulation_State_transition_10s_inactivity.cfg'},
	--{ue_amount = 10, file = 'Simulation_UE_AMF_paging.cfg'},
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
	{cell_id = 1, file = 'Mobility_intrafreq_intragnb_ho_Cell1_Cell3_Cell2.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 5, file = 'Mobility_intrafreq_intragnb_ho_Cell5_Cell4_Cell6.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 7, file = 'Mobility_intrafreq_intragnb_ho_Cell7_Cell9_Cell8.cfg', ue_amount = 30, uec_id = 'auto'},
	{cell_id = 11, file = 'Mobility_intrafreq_intragnb_ho_Cell11_Cell10_Cell12.cfg', ue_amount = 30, uec_id = 'auto'},
--	{cell_id = 13, file = 'Mobility_intrafreq_intragnb_ho_Cell13_Cell15_Cell14.cfg', ue_amount = 15, uec_id = 'auto'},
--	{cell_id = 17, file = 'Mobility_intrafreq_intragnb_ho_Cell17_Cell16_Cell18.cfg', ue_amount = 15, uec_id = 'auto'},
--	{cell_id = 19, file = 'Mobility_intrafreq_intragnb_ho_Cell19_Cell21_Cell20.cfg', ue_amount = 15, uec_id = 'auto'},
--	{cell_id = 23, file = 'Mobility_intrafreq_intragnb_ho_Cell23_Cell22_Cell24.cfg', ue_amount = 15, uec_id = 'auto'}
}
