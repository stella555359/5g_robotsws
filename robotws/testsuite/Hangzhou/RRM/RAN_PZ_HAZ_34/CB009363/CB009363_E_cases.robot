*** Settings ***
Documentation    Author: stella.lin@nokia-sbell.com
Suite Setup    9363_Suite_SetUp    is_suite_commission_needed=${False}
Suite Teardown    9363_Suite_Teardown
Test Teardown    9363_Case_Teardown
Force Tags    PY36
Resource     Resources/CB009363_common.robot
Resource     Resources/CB009363_case_steps.robot


*** Test Cases ***
[1]CB009363-SR-E_013_8Rx_reception_for_PUCCH_F1_F3_1116-0ms_rdRestrictedBeamSetUsed_disabled
    [Tags]    CRT_TRUNK    CRT_24R1    11160ms
    [Setup]     Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_6}
    ...        ELSE    Set Test Variable    ${update_params}    ${None}    AND
    ...        Run Keyword if   '${stream}'!='SBTS00' or '${stream}'!='SBTS26R2'
    ...                Set Test Variable    ${prachindex_param}    ${framestructure_prach_index}
    ...        ELSE    Set Test Variable    ${prachindex_param}    ${framestructure_prach_index_SBTS00}    AND
     ...       9363_D_Case_SetUp    update_params=${update_params}
    ...                             prachindex_param=${prachindex_param}
    ...                             swconfig_flag=E
    CB009363-SR-E_013_8Rx_reception_for_PUCCH_F1_F3_1116-0ms_rdRestrictedBeamSetUsed_disabled
    [Teardown]    9363_Case_Teardown    swconfig_flag=E

[1]CB009363-SR-E_021_checking_the_number_of_PUCCH_when_numberOfRxBeamforming_4RX_and_numberOfRxPucch_8RX
    [Tags]    CRT_TRUNK    CRT_24R1    1208
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_6}
    ...        ELSE    Set Test Variable    ${update_params}    ${scf_update_params_1208}    AND
    ...        9363_D_Case_SetUp    framestructure=1208    update_params=${update_params}
    CB009363-SR-E_021_checking_the_number_of_PUCCH_when_numberOfRxBeamforming_4RX_and_numberOfRxPucch_8RX

[1]CB009363-SR-E_006_Rank_switch_and_TPMI_Measurement_on_8Rx_SRS_and_8Rx_PUSCH_FS_1116_0ms_rdUlRiSelectionThresh8Rx
    [Tags]    CRT_TRUNK    CRT_24R1    1208
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_8}
    ...        ELSE    Set Test Variable    ${update_params}    ${scf_update_params_9363_8_SBTS00}    AND
    ...        Run Keyword if   '${stream}'!='SBTS00' or '${stream}'!='SBTS26R2'
    ...                Set Test Variable    ${prachindex_param}    ${framestructure_prach_index}
    ...        ELSE    Set Test Variable    ${prachindex_param}    ${framestructure_prach_index_SBTS00}    AND
    ...        9363_D_Case_SetUp    framestructure=11163ms
    ...                             update_params=${update_params}
    ...                             prachindex_param=${prachindex_param}
    CB009363-SR-E_006_Rank_switch_and_TPMI_Measurement_on_8Rx_SRS_and_8Rx_PUSCH_FS_1116_0ms_rdUlRiSelectionThresh8Rx

[1]CB009363-SR-F_010_2_UEs_Rank_2_with_non-GBR_high_load_are_paired_with_rdActUlMuMimoNlos_true
    [Tags]    CRT_TRUNK    CRT_24R1    1208
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_8}
    ...        ELSE    Set Test Variable    ${update_params}    ${scf_update_params_9363_8_SBTS00}    AND
    ...        Run Keyword if   '${stream}'!='SBTS00' or '${stream}'!='SBTS26R2'
    ...                Set Test Variable    ${prachindex_param}    ${framestructure_prach_index}
    ...        ELSE    Set Test Variable    ${prachindex_param}    ${framestructure_prach_index_SBTS00}    AND
    ...        9363_D_Case_SetUp    framestructure=11163ms
    ...                             update_params=${update_params}
    ...                             prachindex_param=${prachindex_param}
    CB009363-SR-F_010_2_UEs_Rank_2_with_non-GBR_high_load_are_paired_with_rdActUlMuMimoNlos_true

[1]CB009363-SR-F_007_4_UEs_Rank_1_with_non-GBR_high_load_are_paired_with_LOS_and_NLOS_channel
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_6}
    ...        ELSE    Set Test Variable    ${update_params}    ${scf_update_params_1208}    AND
    ...        9363_D_Case_SetUp    framestructure=1208    update_params=${update_params}
    CB009363-SR-F_007_4_UEs_Rank_1_with_non-GBR_high_load_are_paired_with_LOS_and_NLOS_channel

[1]CB009363-SR-I_003_Rank_1_and_PMI_Measurement_on_8Rx_SRS_with_DFT-s-OFDM_FS_1208
    [Tags]    CRT_TRUNK    CRT_24R1    1208
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS25R1'     Set Test Variable    ${update_params}    ${scf_update_params_9363_6}
    ...        ELSE    Set Test Variable    ${update_params}    ${scf_update_params_1208}    AND
    ...        9363_D_Case_SetUp    framestructure=1208    update_params=${update_params}
    CB009363-SR-I_003_Rank_1_and_PMI_Measurement_on_8Rx_SRS_with_DFT-s-OFDM_FS_1208

#[1]CB009363-SR-J_002_L3_call_with_custom_beam_set
#    [Setup]   Run Keywords
#    ...    ${update_params}    Set Variable If    '${stream}'!='SBTS00'    ${scf_update_params_9363_8}    ${scf_update_params_9363_8_SBTS00}    AND
#    ...    ${prachindex_param}    Set Variable If    '${stream}'!='SBTS00'    ${framestructure_prach_index}    ${framestructure_prach_index_SBTS00}
#    ...    AND
#    ...        9363_D_Case_SetUp    framestructure=11163ms
#    ...                             update_params=${update_params}
#    ...                             prachindex_param=${prachindex_param}
#    CB009363-SR-J_002_L3_call_with_custom_beam_set
