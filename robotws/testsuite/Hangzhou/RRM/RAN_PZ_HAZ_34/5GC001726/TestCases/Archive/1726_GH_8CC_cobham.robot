# # #*** Settings ***
# # #Resource   ../Resources/5GC001726_keywords_cobham.robot
# # #
# # #Documentation    Suite description
# # #...   author: Wang Yixiang
# # #...   contact: yixiang.x.wang@nokia-sbell.com
# # #...   squad group: MMW_SG1
# # #...   Feature 1726 in 5G19B program
# # #
# # #Force Tags    5G_RRM      
# # #
# # #Suite Setup    Suite preparation
# # #Suite Teardown    run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# # #
# # #*** Variables ***
# # #${DL_TPUT_801}    2989
# # #${UL_TPUT_801}    115
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GH_801_GNB-5CCDL_1CCUL_maxScell4DL0UL_non_contiguous_peak_tput_with_new_deployment
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify new deploymentpeak throughput for one ue when non-contiguous frequency 5CC DL and 1CC UL with analog beamforming in mmW bands
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_5CCDL_1CCUL_MUL_DRB_VIA_API_ALL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_MUL_DRB}    dl_tput_size=${DL_TPUT_801}    ul_tput_size=${UL_TPUT_801}
# # #    ...    is_need_to_check_mul_drb_established=${True}    mul_drb_code_stream=${MULTI_DRB_CODE_STREAM}   delta=10
# # #    run keyword and continue on failure    Verify peak throughput on gnb L2Lo
# # #    ...    dl_cell=1-5    expected_dl_tput=${DL_TPUT_801}    ul_cell=1    expected_ul_tput=${UL_TPUT_801}
# # #    run keyword and continue on failure    Verify L2Hi and TRSW deployment logs
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #*** Keywords ***
# # #Case preparation
# # #    [Documentation]  Author: Wang Yixiang
# # #    ...              Description: Case preparation
# # #    [Arguments]      ${scf_paras_via_api}
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    Connect to Capacity Unit Master case
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${scf_paras_via_api}
# # #    ...    timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Wait for gnb ready and cell setup    timeout=60 sec
# # #    Download L2Hi and TRSW deployment logs
