*** Settings ***
Documentation
...   author: Dariusz Maciocha
...   contact: dariusz.maciocha@nokia.com

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB008490/resources/test_specific_keywords_CB008490.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Test Teardown    Test Teardown

*** Test Cases ***
CB008490_MB_B4_TC06_A4MeasurementReport_Discarded_While_gNB_Overloaded
    [Setup]  Test Setup
    A4MeasurementReport_Discarded_While_gNB_Overloaded

CB008490_M_B5_TC07_UE_Capability_Enquiring_About_NR-DC_Support_For_All_Cells_On_Target_gNB_after_inter-gNB_HO
    [Setup]  Test Setup    GNB_2_CELL_582
    UE_Capability_Enquiring_About_NR-DC_Support_For_All_Cells_On_Target_gNB_after_inter_gNB_HO

CB008490_M_B3_TC08_Activate_A4_Measurements_For_NR-DC_PSCell_Addition_After_Inter-gNB_HO_via_NG
    [Setup]  Test Setup    GNB_2_CELL_582
    Activate_A4_Measurements_For_NR-DC_PSCell_Addition_After_Inter-gNB_HO_via_NG

CB008490_MB_B2_TC10_Alt5_A4_Timer_After_Successfull_Reestablishment_To_Different_Serving_Cell_With_A2_actRedirect
    [Setup]  Test Setup    GNB_1_CELL_591
    A4_Timer_After_Successfull_Reestablishment_To_Different_Serving_Cell_With_A2_actRedirect

CB008490_M_B1_EC5_TC11_Not_Inter_Freq_A4_Meas_For_NR_DC_PSCell_Addition_After_Intra_gNB_DU_HO_For_NR_DC_Setup_Not_FWA
    [Setup]  Test Setup    GNB_1_CELL_591
    Not_Configure_Inter-frequency_A4_Measurements_For_NR-DC_PSCell_Addition_After_Intra-gNB_Intra-DU_Handover_For_NR-DC_Setup_Not_FWA

CB008490_M_B19_TC12_Activate_NR_DC_A4_meas_after_success_transition_of_suspended_UE_in_RRC_INACTIVE_to_RRC_CONNECTED
    [Setup]  Test Setup    GNB_1_CELL_592
    Activate_NR-DC_A4_measurements_after_successful_transition_of_suspended_UE_in_RRC_INACTIVE_state_to_RRC_CONNECTED

CB008490-GC_B1_Dynamic_Reconfiguration_Of_NR_DC_SN_Cells_With_Config_Update_Procedures_On_F1_And_Xn_Interfaces
    [Setup]  Test Setup
    Dynamic_Reconfiguration_Of_NR_DC_SN_Cells_With_Config_Update_Procedures_On_F1_And_Xn_Interfaces

CB008490-SR-GF_EC1_4_TC06_Unsuccessful_XN_Setup_due_to_lack_of_configured_NR_DC_SN_cells
    [Setup]  Test Setup
    Unsuccessful_XN_Setup_due_to_lack_of_configured_NR_DC_SN_cells

CB008490-SR-MA_B1_TC01_Blocking_periodical_NR-DC_A4_activation_if_UE_stays_outside_NR-DC_PSCell_coverage_after_ICS
    [Setup]  Test Setup    GNB_1_CELL_592
    Blocking_periodical_NR-DC_A4_activation_if_UE_stays_outside_NR-DC_PSCell_coverage_after_ICS

CB008490-SR-GD_B3_TC05_ALT2_Graceful_shutdown_of_the_last_NR-DC-SN_cell_and_Xn_link_release
    [Setup]    Test Setup
    Graceful_shutdown_of_the_last_NR-DC-SN_cell_and_Xn_link_release

CB008490-SR-DF_B6_TC10_Dynamic_removal_of_SN_cell_with_supported_PLMN_from_already_configured_NR-DC_A4_measurements_set
    [Setup]  Test Setup    GNB_1_CELL_592
    Dynamic_removal_of_SN_cell_with_supported_PLMN_from_already_configured_NR-DC_A4_measurements_set

