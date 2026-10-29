*** Settings ***
Documentation    Author: jun.8.chen@nokia-sbell.com
Suite Setup    10887_Suite_SetUp
Suite Teardown    10887_Suite_Teardown
Test Teardown    10887_Case_Teardown
Force Tags    PY36
Resource     Resources/CB010887_case_steps.robot
Variables    Resources/TestCaseVariables.py
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010708/Resources/CB010708_case_steps.robot


*** Test Cases ***
#[1]CB011026_D_03_eCPRI_7_2e_L3_call_Work_SUMIMO_Work_for_32Trx_RU
#    [Tags]    CRT_TRUNK    1208
#    [Setup]    10887_Case_SetUp    framestructure=1208
#    ...                            update_params=${scf_params_B_04}
#    CB011026_D_03_eCPRI_7_2e_L3_call_Work_SUMIMO_Work_for_32Trx_RU
#
#[1]CB011026_A_01_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Single_Cells
#    [Tags]    CRT_TRUNK    11160ms
#    [Setup]    10887_Case_SetUp    framestructure=11160ms
#    ...                            update_params=${scf_params_B_02}
#    ...                            swconfig_flag=rdSrsSymPolicy_rdTiltOffset
#    CB011026_A_01_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Single_Cells
#    [Teardown]    10887_Case_Teardown    swconfig_flag=rdSrsSymPolicy_rdTiltOffset
#
#[1]CB011026_A_02_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Multiple_Cells
#    [Tags]    CRT_TRUNK    11160ms
#    [Setup]    10887_Case_SetUp    framestructure=11160ms
#    ...                            update_params=${scf_params_B_02}
#    CB011026_A_02_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Multiple_Cells

[1]CB010708-SR-A_018_Rank_switch_with_SRS-based_Beamforming
    [Tags]    CRT_TRUNK    11160ms
    [Setup]    Run Keywords    Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...                       Set Test Variable    ${ParamterToModify_vlaue}
    ...                                           ${PARAMS_TO_MODIFY_Channels_And_prachConfigurationIndex_For_2T4R_1070_SBTS00}
    ...        ELSE           Set Test Variable    ${ParamterToModify_vlaue}
    ...                                           ${PARAMS_TO_MODIFY_Channels_And_prachConfigurationIndex_For_2T4R_1070}
    ...        AND
    ...        Run Keyword if   '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...                Set Test Variable    ${ListParamterToModify}    ${LIST_PARAMS_TO_MODIFY_For_2T8R_AND_1070_SBTS00}
    ...        ELSE    Set Test Variable    ${ListParamterToModify}    ${LIST_PARAMS_TO_MODIFY_For_2T8R_AND_1070}
    ...        AND
    ...                       10708_Case_SetUp
    ...                            MOsToAdd='NULL'
    ...                            ParamterToModify=${ParamterToModify_vlaue}
    ...                            ListParamterToModify=${ListParamterToModify}
    ...                            ListToAdd=${LIST_TO_ADD_SYNC_SOURCE_FRAME_1070}
    ...                            ParameterToDelete=${PARAMS_TO_DELETE_TOPP_PARAMS_AND_11026}
    CB010708-SR-A_018_Rank_switch_with_SRS-based_Beamforming
    [Teardown]    10708_Case_Teardown

[1]CB010708-SR-C_001_16RX_IRC_reception_for_2_PUSCH_Rank2_UEs
    [Tags]    CIT_TRUNK    11160ms
    [Setup]    10708_Case_SetUp
    CB010708-SR-C_001_16RX_IRC_reception_for_2_PUSCH_Rank2_UEs
    [Teardown]    10708_Case_Teardown

[1]CB010708-SR-E_004_4_RANK1_UEs_paired
    [Tags]    CIT_TRUNK    11160ms
    [Setup]    10708_Case_SetUp
    CB010708-SR-E_004_4_RANK1_UEs_paired
    [Teardown]    10708_Case_Teardown

[1]CB008235-SR-A_004_4_RANK2_UE_pair_with_nrcelltype_16D8U
    [Tags]    CIT_TRUNK    11160ms
    [Setup]    10708_Case_SetUp    scf_path=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_8235.xml
    ...                            modify_scf_file_needed=${False}
    CB008235-SR-A_004_4_RANK2_UE_pair_with_nrcelltype_16D8U
    [Teardown]    10708_Case_Teardown

[1]CB008235-SR-C_001_16_RANK2_UEs_MUgroup_pairing
    [Tags]    CIT_TRUNK    11160ms
    [Setup]    10708_Case_SetUp    scf_path=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_8235.xml
    ...                            modify_scf_file_needed=${False}
    CB008235-SR-C_001_16_RANK2_UEs_MUgroup_pairing
    [Teardown]    10708_Case_Teardown

[1]CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Single_Ue_4CC_16DL
    [Setup]    10708_Case_SetUp    scf_path=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_8235.xml
    ...                            modify_scf_file_needed=${False}
    CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Single_Ue_4CC_16DL
    [Teardown]    10708_Case_Teardown

[1]CB010708-SR-L_002_Rank2_and_TPMI_Measurement_on_16Rx_SRS_with_2_interferers
    [Tags]    CIT_TRUNK    11160ms
    [Setup]    10708_Case_SetUp    scf_path=${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_interferers.xml
    ...                            modify_scf_file_needed=${False}
    CB010708-SR-L_002_Rank2_and_TPMI_Measurement_on_16Rx_SRS_with_2_interferers
    [Teardown]    10708_Case_Teardown
