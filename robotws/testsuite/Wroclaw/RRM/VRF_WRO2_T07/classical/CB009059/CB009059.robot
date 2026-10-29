*** Settings ***
Documentation
...   author:        Mateusz Cieciura and Filip Jozefczak
...   contact:       marcin.wolczynski@nokia.com
...   maintainer:    filip.jozefczak@nokia.com
...   Description:   Feature CB009059

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/keywords_9059.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py

Suite Setup     Run keywords
...             Prepare Attenuator                                    AND
...             Perform gNB commissioning with 9059 basic SCF         AND
...             Require Ue  ${UE_ALIAS}  capabilities=${UE_CAPA}

Test Setup      Run Keywords
...             Wait for next counter interval                        AND
...             Start syslog capture                                  AND
...             nullify_all_custom_data_in_pcf                        AND
...             Create init list of dts for tc

Test Teardown   Run Keywords
...             Stop All Data Transfers                               AND
...             Detach Ue                   ${UE_ALIAS}               AND
...             Reset DRBs to default                                 AND
...             stop_webem_ip_capturing                               AND
...             Stop syslog capture   alias=${SYSLOG_ALIAS}           AND
...             Stop syslog capture                                   AND
...             AdminUtils.collect_snapshot

Suite Teardown  Run Keywords
...             Stop Using Ue               ${UE_ALIAS}               AND
...             Set Scout Configuration ID


*** Test Cases ***
[1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow
    [Tags]  CRT  24R2  A1
    [1]CB009059_A_1_One_PDU_ICS_Blind_SCell_Add_two_FR1_CA_eligible_DRB_one_no_FR1_CA_eligible_DRB_with_additional_QoS_Flow


[1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB
    [Tags]  CRT  24R2  A3
    [1]CB009059_A_3_PDU_Session_Modification_with_new_DRB_when_UE_is_not_in_CA_due_to_incompatible_DRB


[1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release
    [Tags]  CRT  24R2  A8
    [1]CB009059_A_8_PDU_Session_Modification_with_eligible_DRB_setup_and_CA_incompatible_DRB_release


[1]CB009059_AB_3_PDU_Session_Modification_last_CA_eligible_DRB_release_CA_release
    [Tags]  CRT  24R2  AB3
    [1]CB009059_AB_3_PDU_Session_Modification_last_CA_eligible_DRB_release_CA_release


[1]CB009059_AC_4_Online_DRB_profile_setting_parameter_modification
    [Tags]  CRT  24R2  AC4
    [1]CB009059_AC_4_Online_DRB_profile_setting_parameter_modification


[1]CB009059_BA_9_DL_buffer_monitoring_for_SCell_Addition_only_FR1_CA_eligible_DRB_blind_SCell_Addition_method_buffer-based_activated
    [Tags]  CRT  24R2  BA9
    [1]CB009059_BA_9_DL_buffer_monitoring_for_SCell_Addition_only_FR1_CA_eligible_DRB_blind_SCell_Addition_method_buffer-based_activated


[1]CB009059_BE_2_Interworking_with_VoNR_Call_setup_after_ICS_one_DRB_FR1_CA_incompatible
    [Tags]  CRT  24R2  BE2
    [1]CB009059_BE_2_Interworking_with_VoNR_Call_setup_after_ICS_one_DRB_FR1_CA_incompatible


CB009059_C_2_ICS_and_SCell_Addition_one_FR1_CA_eligible_DRB_no_FR1_CA_incompatible_DRB_UM_RLC_mode_DRB_FR1_CA_eligible
    [Tags]  CRT  24R2  C2
    CB009059_C_2_ICS_and_SCell_Addition_one_FR1_CA_eligible_DRB_no_FR1_CA_incompatible_DRB_UM_RLC_mode_DRB_FR1_CA_eligible


CB009059_F_2_Interworking_with_PCMD_for_CA_eligible_DRB_release_PDU_Modification
    [Tags]       CRT  24R2  F2
    CB009059_F_2_Interworking_with_PCMD_for_CA_eligible_DRB_release_PDU_Modification


CB009059_BC_4_Interaction_with_RRC_Resume_procedure_CB008225_SCell_Addition_Method_blind_buffer_based_activated
    [Tags]  CRT  24R2  BC4
    CB009059_BC_4_Interaction_with_RRC_Resume_procedure_CB008225_SCell_Addition_Method_blind_buffer_based_activated
