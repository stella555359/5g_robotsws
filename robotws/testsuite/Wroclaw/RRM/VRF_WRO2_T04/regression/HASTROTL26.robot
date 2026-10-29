*** Settings ***
Documentation    Suite containing tests for features:
...              5GC000747, 5GC002640, CB008533, 5GC002645, CB008083, CB008509, CB008225, 5GC001167

Resource        ../5GC002640/5GC002640_AB.robot
Resource        ../CB008533/CB008533_A.robot
Resource        ../CB008509/CB008509.robot
Resource        ../5GC000747/5GC000747-A.robot
Resource        ../5GC002645/5GC002645_CD.robot
Resource        ./regression_keywords.robot
Resource        ../5GC001167/5GC001167_FDD_DL_CA_up_to_2CCs.robot
Resource        ../5GC001167/5GC001167_I_Support_of_3CC_FDD_FDD.robot
Resource        ../5GC001167/5GC001167_L_Support_of_3CC_FDD_FDD.robot
Library        ../../VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Resource        ../CB008225/CB008225_RRC_Inactive_State_under_same_gNB.robot
Resource        ../CB008954/CB008954.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T04/CB008954/resources/keywords_8954.py
Library         testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library         testsuite/Wroclaw/RRM/resources/csv4all_helpers.py


Force Tags      CA_VRF_WRO2

Suite Setup    Run Keyword And Ignore Error    Block All Lte Cells    remote_host=${LTE_IP}

Test Setup      Run Keywords
...    Set TESTNAME without spaces  AND
...    Start Collecting Syslog    AND
...    AdminUtils.Wait For All Cells On Air State

Test Teardown   Run Keywords
...    Run Keyword If Test Failed    AdminUtils.Collect Snapshot    ${OUTPUT_DIR}/${TEST_NAME}/snapshot.zip    timeout=600    AND
...    Collect Syslog    AND
...    Add Scout Data Info To Testcase    AND
...    Run Keyword If Test Passed    Find Suspicious Prints In Passed Test

Test Timeout    120 minutes

*** Test Cases ***
5GC002640-AB_TC13_B7_SCell_deactivation_3CC_DL_CA_BufferBased
    [Tags]    SCF_DEFAULT
    5GC002640-AB_TC13_B7_SCell_deactivation_3CC_DL_CA_BufferBased

CB008533-A_B9_Interworking_with_DRX_when_UE_has_VoNR_call_running_SCell_Change_from_4CC_CA_with_Measurement_based_SCell_Addition_to_3CC_CA
    [Tags]    SCF_DEFAULT    CDRT
    CB008533-A_B9_Interworking_with_DRX_when_UE_has_VoNR_call_running_SCell_Change_from_4CC_CA_with_Measurement_based_SCell_Addition_to_3CC_CA

CB008533-A_B12_Single_UE_mobility_Intra-DU_handover_support(PCell change)_4CC_CA_FDD_2F2T_FR1_configured_for_SA_call
    [Tags]    SCF_DEFAULT
    CB008533-A_B12_Single_UE_mobility_Intra-DU_handover_support(PCell change)_4CC_CA_FDD_2F2T_FR1_configured_for_SA_call

5GC002645_C_PWS_Restart_Ind_add_new_cell
    [Tags]    SCF_DEFAULT    CDRT
    5GC002645_C_PWS_Restart_Ind_add_new_cell

5GC002645_D_cancel_all_CMAS_broadcast_on_cells_listed_in_Broadcast-To-Be-Cancelled-List_IE_with_ignored_NotificationInformation_IE
    [Tags]    SCF_DEFAULT
    5GC002645_D_cancel_all_CMAS_broadcast_on_cells_listed_in_Broadcast-To-Be-Cancelled-List_IE_with_ignored_NotificationInformation_IE

5GC000747-A_004_Successful_ETWS_primary_and_secondary_notification_broadcast
    [Tags]    SCF_DEFAULT
    5GC000747-A_004_Successful_ETWS_primary_and_secondary_notification_broadcast

5GC000747-A_009_Successful_ETWS_secondary_notification_broadcast_replace
    [Tags]    SCF_DEFAULT
    5GC000747-A_009_Successful_ETWS_secondary_notification_broadcast_replace

5GC000747-A_010_Successful_ETWS_primary_notification_broadcast_in_RRC_IDLE_state
    [Tags]    SCF_DEFAULT    CDRT
    5GC000747-A_010_Successful_ETWS_primary_notification_broadcast_in_RRC_IDLE_state

5GC000747-A_023_Successful_SIB_reconfiguration_during_ETWS_notification_broadcast
    [Tags]    SCF_DEFAULT    CDRT
    5GC000747-A_023_Successful_SIB_reconfiguration_during_ETWS_notification_broadcast

TC09_CB008509_C_1_PDSCH_PDCCH_SSB_TRS_LowTS_PM
    [Tags]    SCF_DEFAULT
    TC09_CB008509_C_1_PDSCH_PDCCH_SSB_TRS_LowTS_PM

TC12_CB008509_C_4_DUMMY_PDSCH_PDCCH_SSB_TRS_HITS_noBF
    [Tags]    SCF_DEFAULT
    TC12_CB008509_C_4_DUMMY_PDSCH_PDCCH_SSB_TRS_HITS_noBF

5GC001167-H_SCell Addition 2CC and UE Configuration_M55139C01001_counter
    [Tags]    SCF_DEFAULT
    5GC001167-H_ SCell Addition 2CC and UE Configuration_M55139C01001_counter

5GC001167-L_Successful_scenarios_PM_counters
    [Tags]    SCF_DEFAULT
    5GC001167-L_Successful_scenarios_PM_counters

5GC001167_I_001_3CC_FDD-FDD_Inter_band_CA_NR_DL_peak_UDP_throughput_band_combination_1
    [Tags]    SCF_DEFAULT
    5GC001167_I_001_3CC_FDD-FDD_Inter_band_CA_NR_DL_peak_UDP_throughput_band_combination_1

5GC001167_I_020_FDD-FDD_inter_band_CA_bufferAndRLQualityBased_Scell_Activation_combination1_(3CC)
    [Tags]    SCF_DEFAULT
    5GC001167_I_020_FDD-FDD_inter_band_CA_bufferAndRLQualityBased_Scell_Activation_combination1_(3CC)

5GC001167-H_B4_CA_relation_update_within_NRREL_object_with_a_need_to_change_cell_mapping
    [Tags]    SCF_DEFAULT
    5GC001167-H_B4_CA_relation_update_within_NRREL_object_with_a_need_to_change_cell_mapping

CB008954_Multi_Draft_ABE
    [Tags]    SCF_DEFAULT
    CB008954_Multi_Draft_ABE
