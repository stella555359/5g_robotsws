*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    ./resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Force Tags      CA_VRF_WRO2

Suite Setup         Change PLMNs    1    540
Suite Teardown      Change PLMNs    540    1
Test Teardown       Teardown

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT302/ue_config.yaml
${TL_CONFIG}             /home/ute/testline_configuration/7_16_UTE5GCLOUDT302
&{CONFIGURATION}         pyro_port=9092    com_port=COM3    python=python
${CELL_1_ALIAS}          GNB_1_CELL_1
${CELL_2_ALIAS}          GNB_1_CELL_2
${CELL_3_ALIAS}          GNB_2_CELL_1
${CELL_4_ALIAS}          GNB_2_CELL_2
${CELL_5_ALIAS}          GNB_2_CELL_3
${CELL_6_ALIAS}          GNB_1_CELL_4

*** Test Cases ***
CB008225_A_B2_Feature_activation_with_actRanSharing=false
    [Setup]    Test Setup   A_B2=${TRUE}    ELT=${TRUE}
    A_B2_Feature_activation_RAN_non_Sharing

CB008225_B_B1_RRCRelease_with_SC_after_ICS
    [Setup]    Test Setup   COMMON=${TRUE}
    B_B1_RRCRelease_with_SC_after_ICS

CB008225_C_B1_B3_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF
    [Setup]    Test Setup   COMMON=${TRUE}    ELT=${TRUE}
    C_B1_B3_Successful_RAN_Paging_in_RRC_Inactive_State_DL_User_Plane_Data_from_UPF

CB008225_D_B1_RRC_Inactive_to_RRC_Connected_State_UL_User_Data
    [Setup]    Test Setup   COMMON=${TRUE}    ELT=${TRUE}
    D_B1_RRC_Inactive_to_RRC_Connected_State_UL_User_Data

CB008225_E_B3_PMO23_Successful_transition_of_suspended_UE_in_RRC_INACTIVE_state_to_RRC_CONNECTED_with_A1_meas_CA
    [Setup]    Test Setup    COMMON=${TRUE}
    E_B3_PMO23_Successful_transition_of_suspended_UE_in_RRC_INACTIVE_state_to_RRC_CONNECTED_with_A1_meas_CA

CB008225_H_B1_PMO29_RRCRelease_with_CA_aware_cellReselectionPriorities_via_drbRrcInactInactivityTimerSA
    [Setup]    Test Setup    H_B1=${TRUE}   ELT=${TRUE}
    H_B1_PMO29_RRCRelease_with_CA_aware_cellReselectionPriorities_via_drbRrcInactInactivityTimerSA

CB008225_I_B5_Fallback_to_RRCSetup_by_resumeCause=emergency_using_numOfRadioResReservForEmergency_resources
    [Setup]    Test Setup    COMMON=${TRUE}
    I_B5_Fallback_to_RRCSetup_by_resumeCause=emergency_using_numOfRadioResReservForEmergency_resources

CB008225_J_B05_PCMD_and_Cell_trace_records_during_RNA_update_in_same_gNB
    [Setup]    Test Setup    COMMON=${TRUE}
    J_B05_PCMD_and_Cell_trace_records_during_RNA_update_in_same_gNB

CB008225_L_PMO6_Sleeping_Cell_Detection_by_RRCResumeRequestReject
    [Setup]    Test Setup    L=${TRUE}
    L_PMO6_Sleeping_Cell_Detection_by_RRCResumeRequestReject
