# *** Settings ***
# Resource          ../../Resources/5GC001200_keywords.robot
# 
# Documentation    Suite description
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001200-A in 5G19A program
# 
# 
# Force Tags    5G_RRM        6.8351  1200
# ...    PY36
# Suite Setup     run keywords    Set suite variables by program    AND
# ...             5GC001200_keywords.Common Suite Preparation
# ...             1200_scf_parameter=${MODIFY_SCF_1200_A_B_E_BASE}
# Suite Teardown  Run keyword and ignore error    5GC001200_keywords.Common Suite Teardown
# 
# *** Test Cases ***
# [1]5GC001200_A_402_NIDD_RLO_online_modification
#     [Tags]    CRT_20A    CRT_20B   CRT_TRUNK    CDRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     ...      CRT_22R4
#     [Documentation]    Author: Bruce.1.wang
#     ...    This test case is to verify the NIDD parameters (pucchDataDtxNumOfSamples, puschDataDtxNumOfSamples,
#     ...    rloDtxRatioThreshold, rloConsecDtxThreshold, rloPathLossThreshold and rloSinrThreshold)
#     ...    can be online modified and taken into effect immediately without any alarm or service interruption.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NR_API_DEFAULT}
#     ...    is_need_to_check_validation_errors=${True}
#     run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
#     ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
#     Online modify nidd parameters via webUI    parameters_to_update_via_webui=${MODIFY_NIDD_VIA_WEBUI_1200_A_402}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RLO}
#     [Teardown]    run keyword and ignore error    run keywords
#     ...    Online modify nidd parameters via rest api    1200_other_nidd_modify_via_api=${MODIFY_NIDD_VIA_API_1200_A_402_RESTORE}    AND
#     ...    5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_A_110_Reconfig_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality
#     [Tags]    CRT_20A    CRT_20B   CRT_TRUNK    CDRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     ...    CRT_22R4
#     [Documentation]    Author: Cui Lingxue
#     ...    This user scenario describes the gNB behavior when the current UL configuration is NR + LTE and detect bad
#     ...    UL channel quality based on the measurement at gNB.
#     ...    The detailed procedure of detction is that L2-PS detects based on the measurements at gNB with DTX ratio exceed
#     ...    the rloDtxRatioThreshold (consecutive time reaches rloConsecDtxThreshold), average SINR below the rloSinrThreshold
#     ...    and Pathloss below the rloPathLossThreshold, then gNB triger and interact with LTE and UE with SQ flow in order to
#     ...    transfer UL data path from NR + LTE to LTE only.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NRLTE_API_DEFAULT}
#     ...    is_need_to_check_validation_errors=${False}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RLO}
#     [Teardown]    run keyword and ignore error        5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_A_301_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad_SRB3
#     [Tags]    CRT_20A    CRT_20B
#     [Documentation]    Author: Cui Lingxue
#     ...    This test case describes the gNB behavior（SRB3 is created）, when the current configuration is NR only and bad UL
#     ...    channel quality is detected based on the measurements at Gnb with DTX ratio exceed the rloDtxRatioThreshold and
#     ...    average SINR below the rloSinrThreshold and Pathloss below the rloPathLossThreshold. UL user data transfer from NR
#     ...    only switch LTE only.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NR_SRB3_API_DEFAULT}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RLO_SRB3}
#     [Teardown]    run keyword and ignore error     5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_A_401_NIDD_actDynUlDataSplitMode_online_modification
#     [Tags]    CRT_20A    CRT_20B   CRT_TRUNK    CDRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3   CRT_22R4
#     [Timeout]    30 min
#     [Documentation]    Author: Cui Lingxue
#     ...    This test case is to verify the NIDD parameter actDynUlDataSplitMode can be online modified and taken into effect
#     ...    immediatel without any alarm or service interruption.
#     [Setup]    coam_gnb_classical.COAM Create log directory    is_set_to_test_case_level=${True}
#     coam_gnb_classical.Connect to gnb coam via ssl
#     log to console    Online modify actDynUlDataSplitMode to False to turn off 1200 function.
#     coam_selenium.COAM Update Several Parameters Via WebUI
#     ...    parameters_to_update_via_webui=${MODIFY_NIDD_VIA_WEBUI_1200_A_401}
#     ...    download_dir=${TS_CASE_LOG_PATH}
#     ...    is_need_to_check_validation_errors=${True}
#     Get UE ready for rlo    is_need_to_check_ul_data_on_NR=${False}
# 
#     ${is_rlo_triggered}    Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RLO}
#     ...    return_status=${True}
#     should not be true    ${is_rlo_triggered}    RLO is triggered, turning off actDynUlDataSplitMode failed.
#     [Teardown]    run keyword and ignore error    5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_B_201_Reconfiguration_From_LTE_Only_To_NR_Only_Detection_UL_Quality_Is_Improved
#     [Tags]    CRT_20A    CRT_20B   CRT_TRUNK    CDRT_TRUNK   CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3
#     ...    CRT_22R4
#     [Documentation]    The purpose of this test case is to test when detect UL quality is improved，
#     ...    reconfiguration from LTE only to NR only succeed.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NR_API_DEFAULT}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RL_RESUME_LTE_TO_NR}
#     [Teardown]    run keyword and ignore error    5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_B_502_Reconfiguration_From_LTE_Only_To_NR+LTE_Detection_UL_Quality_Is_Improved_SRB3
#     [Tags]    CRT_20A    CRT_20B
#     [Documentation]    Author: Cui Lingxue
#     ...    The purpose of this test case is when detect UL quality is improved with SRB3 been created between
#     ...    gNB and UE，reconfiguration from LTE only to NR+LTE succeed.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NRLTE_SRB3_API_DEFAULT}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RL_RESUME_SRB3_LTE_TO_NR_LTE}
#     [Teardown]    run keyword and ignore error    5GC001200_keywords.Common Test Teardown
# 
# [1]5GC001200_B_211_Avoid_Frequently_Switching_Between_LTE_Only_And_NR+LTE
#     [Tags]    CRT_20A    CRT_20B   CRT_TRUNK     CDRT_TRUNK    CRT_21A    CRT_21B    CRT_22R1    CRT_22R2    CRT_22R3   CRT_22R4
#     [Documentation]    Author: Cui Lingxue
#     ...    This test case describes the gNB behavior after a successful reconfiguration due to deteriorated or improved UL
#     ...    channel quality in NR. The first or the earliest UL RL RESUME procedure after a successful reconfiguration to LTE
#     ...    Only shall be triggered only after the prohibit time period is elapsed.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NRLTE_API_DEFAULT}
#     ${l2_ps_trace}    Start L2PS trace capturing    log_prefix=1200_B_211_l2_ps_trace
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RL_RESUME_LTE_TO_NR_LTE}
#     ${sleep_time}    evaluate    ${PARAMETER_VALUES_IN_SCF['rlResumeBackOffTmr']}/1000+2
#     sleep    ${sleep_time} sec
#     stop trace capturing    log_prefix=1200_B_211_l2_ps_trace    connection_alias=${L2PS_CONNECTION}
#     ${l2_ps_trace_ute}    Download trace log    log_full_path=${l2_ps_trace}    connection_alias=${L2PS_CONNECTION}
#     run keyword and continue on failure    Verify rlResumeBackOffTmr in UPUE trace    file_path=${l2_ps_trace_ute}
#     ...    rlResumeBackOffTmr=${PARAMETER_VALUES_IN_SCF['rlResumeBackOffTmr']}
#     [Teardown]      5GC001200_keywords.Common Test Teardown
# 
# 
# [1]5GC001200_A_117_Multi-UE_occured_after_Reconfiguration_From_NR+LTE_To_LTE_Only_Detection_Of_Bad_UL_Channel_Quality
#     [Tags]    CRT_20A    CRT_20B   CRT_21A    CRT_21B
#     [Documentation]    Author: Cui Lingxue
#     ...    This test purpose is that gNB can handle multi-UE which occure Radio Linke Outage on gNB cell simultaneously
#     ...    from NR only to LTE only.
#     [Setup]    Test preparation for multi-UE    parameters_to_update_via_api=${MODIFY_SCF_1200_NRLTE_API_DEFAULT}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RLO}    ue_idx=0,1,2
#     [Teardown]    run keyword and ignore error
#     ...    5GC001200_keywords.Common Test Teardown    e500_attach_script_path=${E500_SCRIPTS_MULTI_UE}    number_of_ue=${NUMBER_OF_UE}
# 
# 5GC001200_A_101_Reconfiguration_From_NR_Only_To_LTE_Only_Detection_UL_Quality_Is_Bad
#     [Tags]   CRT_TRUNK    CDRT_TRUNK    CRT_22R1    CRT_22R2    CRT_22R3    CRT_22R4
#     [Documentation]    Author: Cui Lingxue
#     ...    This caes script should be updated after automation env preparation done.
#     [Setup]    5GC001200_keywords.Common test preparation    parameters_to_update_via_api=${MODIFY_SCF_1200_NRLTE_API_DEFAULT}
#     Trigger RLO or Resume by online modify nidd parameter and log capture    code_stream=${SIG_DRB_RL_RESUME_SRB3_LTE_TO_NR_LTE}
#     [Teardown]    run keyword and ignore error
#     ...    5GC001200_keywords.Common Test Teardown    e500_attach_script_path=${E500_SCRIPTS_MULTI_UE}
