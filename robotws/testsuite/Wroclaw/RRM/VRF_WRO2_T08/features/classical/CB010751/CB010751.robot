*** Settings ***
Documentation
...    author: Rafal Kaczmarski
...    contact: rafal.kaczmarski@nokia.com

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/CB010751/resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Test Teardown   Teardown

*** Variables ***
${ABSTRACT_LIB_CONFIG}   /home/ute/testline_configuration/7_16_UTE5GCLOUDT196/ue_conf.yaml
&{CONFIGURATION}         pyro_port=9092    com_port=COM3    python=python
${CODES}    +CGPADDR:
${CELL_1_ALIAS}          GNB_1_CELL_221
${CELL_2_ALIAS}          GNB_1_CELL_222
${CELL_3_ALIAS}          GNB_1_CELL_223
${CELL_4_ALIAS}          GNB_2_CELL_501
${CELL_5_ALIAS}          GNB_2_CELL_502

*** Test Cases ***
CB010751_AB1_TC01_Suspend_after_NRBTS_drbRrcInactInactivityRedCapTimerSA_expiration
    [Setup]    Test Setup
    CB010751_AB1_TC01_Suspend_after_NRBTS_drbRrcInactInactivityRedCapTimerSA_expiration

CB010751_PMO_A2_TC02_Counter_update_due_to_successful_Resume
    [Setup]    Test Setup
    CB010751_PMO_A2_TC02_Counter_update_due_to_successful_Resume

CB010751_AEC1_TC03_Release_to_RRC_Idle_due_to_lack_of_ranac
    [Setup]    Test Setup
    CB010751_AEC1_TC03_Release_to_RRC_Idle_due_to_lack_of_ranac

CB010751_AEC2_TC04_RRCReject_by_maxNumOfRrcSARedCap_AC_failure_with_CB008225_DE1
    [Setup]    Test Setup   set_maxNumOfRrcSARedCap=${TRUE}
    CB010751_AEC2_TC04_RRCReject_by_maxNumOfRrcSARedCap_AC_failure_with_CB008225_DE1

CB010751_PMO_A3_TC05_Counter_update_due_to_fallback_after_intra-gNB_reselection_to_cell_without_ranAC
    [Setup]    Test Setup
    CB010751_PMO_A3_TC05_Counter_update_due_to_fallback_after_intra-gNB_reselection_to_cell_without_ranAC

CB010751_BIWK2_TC06_Suspend_with_NRDRB_and_SNSSAI_timers_configured
    [Setup]    Test Setup    BIWK2=${TRUE}
    CB010751_BIWK2_TC06_Suspend_with_NRDRB_and_SNSSAI_timers_configured

CB010751_BIWK4_TC07_RNA_update_with_non_CA_aware_mobility_steering
    [Setup]    Test Setup    BIWK4=${TRUE}
    CB010751_BIWK4_TC07_RNA_update_with_non_CA_aware_mobility_steering

CB010751_AB3_TC08_Resume_by_DL_user_plane_data_after_intra-gNB_reselection_to_NRCELL_with_different_RANAC
    [Setup]    Test Setup    AB3=${TRUE}
    CB010751_AB3_TC08_Resume_by_DL_user_plane_data_after_intra-gNB_reselection_to_NRCELL_with_different_RANAC

[1]CB011041_PMO_A2_Alt2_Counter_update_for_RAN_Paging_due_to_DL_cplane_msg_for_RedCap_UE
    [Setup]    Test Setup    CB011041_AB2=${TRUE}
    CB011041_A_B2_Alt2_RAN_Paging_due_to_DL_cplane_msg_for_RedCap_UE

CB011041_PMO_B3_Counter_update_for_Intra-GNB_Fallback_to_RRCSetup_by_RNAU_with_RRCResumeRequest
    [Setup]    Test Setup    CB011041_AB2=${TRUE}
    CB011041_PMO_B3_Counter_update_for_Intra-GNB_Fallback_to_RRCSetup_by_RNAU_with_RRCResumeRequest

CB011041_B_EC1_Failed_RAN_Paging_due_to_DL_data_with_Paging_Repetition_Strategy
    [Setup]    Test Setup    CB011041_BEC1=${TRUE}
    CB011041_B_EC1_Failed_RAN_Paging_due_to_DL_data_with_Paging_Repetition_Strategy
