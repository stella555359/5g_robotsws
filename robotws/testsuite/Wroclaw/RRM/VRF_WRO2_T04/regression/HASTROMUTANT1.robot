*** Settings ***
Documentation
...   author: Pawel Zabawczuk
...   contact: pawel.k.zabawczuk@nokia.com
...   Test cases execute on T-Mobile US #27 setup


Resource        ./regression_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000474/5GC000474_X2_management.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000570/5GC000570_5G-LTE_flow_control_at_X2.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/5GC000630/5GC000630_F1-U_Interface.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB007516/CB007516_NR_CA_Aware_Idle_mode_Mobility_SA.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008225/CB008225_RRC_Inactive_State_under_same_gNB.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011041/CB011041_Paging_Enhancements_to_RRC_Inactive_State.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB013438/CB013438_REAL_UE/CB013438_Extension_of_scheduling_weight_range.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009009/CB009009_ANR.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB006449/CB006449_TDD_FR1_UL_CA_up_to_2CCs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB009842/CB009842.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB005935/CB005935_Inter_band_FDD_UL_CA_2CC.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008083/CB008083.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB011022/CB011022_Adaptive_Selection_in_DL_of_MCS_Index_Tables_and_of_DMRS_Type.robot
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py


Suite Setup    Run Keywords
...                 Initialise Attenuator
...                 Set Sector for Testing


Test Setup      Run Keywords
...                 Start Collecting Syslog
...                 AdminUtils.wait_for_all_cells_on_air_state

Test Teardown   Run Keywords
...                 Clear Cache
...                 Collect and Verify Syslog
...                 Make Snapshot In Case Of Error
...                 Add Scout Data Info To Testcase

Test Timeout    120 minutes


*** Test Cases ***
5GC000474_CNI41523_x2LinkLock-X2_link_reestablishment
    [Tags]    5GC000474
    5GC000474_CNI41523_x2LinkLock-X2_link_reestablishment


5GC000570_A_Max_expected_TCP_Downlink_and_Uplink_data_throughput_splitted_over_F1UX2U_interfaces_for_given_qci
    [Tags]    5GC000570
    5GC000570_A_Max_expected_TCP_Downlink_and_Uplink_data_throughput_splitted_over_F1UX2U_interfaces_for_given_qci


CB007516_A_NR_Aware_Idle_mode_mobility_SA
    [Tags]    CB007516   CB007516_A
    CB007516_A_NR_Aware_Idle_mode_mobility_SA


CB007516_B_NR_Aware_Idle_mode_mobility_SA
    [Tags]    CB007516   CB007516_B
    CB007516_B_NR_Aware_Idle_mode_mobility_SA


CB008225_RRC_Inactive_State
    [Tags]    CDRT   CB008225
    CB008225_RRC_Inactive_State


CB011041_A_B1_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF_with_Priority_RAN_Paging
    [Tags]    CB011041
    CB011041_A_B1_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF_with_Priority_RAN_Paging


CB009009_ANR_for_SA_intra_NR
    [Tags]    CDRT   ANR   ANR_SA
    CB009009_ANR_for_SA_intra_NR


CB009009_ANR_for_NSA_intra_NR
    [Tags]    ANR   ANR_NSA
    CB009009_ANR_for_NSA_intra_NR


CB009009_ANR_for_SA_Inter_RAT_NR_LTE
    [Tags]    ANR   ANR_NR_LTE
    CB009009_ANR_for_SA_Inter_RAT_NR_LTE


CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_and_parameter_avgDataRateReinitProhibitTimer
    [Tags]    CB013438
    CB013438-A-A1-A3_Online_modification_of_scheduling_weight_with_extended_range_and_parameter_avgDataRateReinitProhibitTimer


CB006449_UL_CA_2CC
    [Tags]    CB006449   CB006449_A
    CB006449_UL_CA_2CC


CB006449_Successful_PCell_switch_in_FR1_TDD_TDD_UL_CA_mode
    [Tags]    CB006449   CB006449_C
    CB006449_Successful_PCell_switch_in_FR1_TDD_TDD_UL_CA_mode


CB009842_NR_Timing_Advance_reporting_for_UL_NR_ECID
    [Tags]    CB009842
    CB009842_NR_Timing_Advance_reporting_for_UL_NR_ECID


CB005935_UL_CA_2CC
    [Tags]    CB005935
    CB005935_UL_CA_2CC


CB005935_Interworking_with_3GPP_based_overheating_handling
    [Tags]    CB005935_OVH
    CB005935_Interworking_with_3GPP_based_overheating_handling


CB008083_C_block_nglink
    [Tags]    CB008083
    CB008083_C_block_nglink


FGCR-3464_Distribution_of_estimated_throughput_over_F1-U
    [Tags]    5GC000630
    FGCR-3464_Distribution_of_estimated_throughput_over_F1-U


CB011022_PCell_only_DMRS_MCS_Table_switching_based_on_indication_for_PCell
    [Tags]    CB011022   CB011022_1
    CB011022_PCell_only_DMRS_MCS_Table_switching_based_on_indication_for_PCell


CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_PCell
    [Tags]    CB011022   CB011022_2
    CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_PCell


CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_Serving_Cell
    [Tags]    CB011022   CB011022_3
    CB011022_PCell_and_SCell_DMRS_MCS_Table_switching_based_on_indication_for_Serving_Cell
