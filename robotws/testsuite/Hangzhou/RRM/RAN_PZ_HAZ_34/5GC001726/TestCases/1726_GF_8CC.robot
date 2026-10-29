# *** Settings ***
# Resource   ../Resources/5GC001726_keywords.robot
# Resource   ../Resources/merge_case_to_one_kw.robot
# 
# 
# Documentation    Suite description
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 1726 in 5G19B program
# 
# Force Tags    5G_RRM
# ...    PY36
# 
# Suite Setup    run keywords   Import NIDD variables    AND    Suite preparation
# Suite Teardown    run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# 
# *** Test Cases ***
# [1]5GC001726_GF_608_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
#     [Tags]    CRT_20B   CRT_21A    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    author: Wang Yixiang
#     ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
#     ...    8CC DL and 2CC UL with analog beamforming in mmW bands
#     [Setup]     Test case preparation
#     GF_608_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# #    Qcom attach UE and start traffic
# #    ${hw_slot}   set variable if  '${BTS_ID}'=='43'    ${1}   ${2}
# #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7,8  hw_slot=${hw_slot}
#     [Teardown]     Run Keyword And Ignore Error    Case teardown
# 
# *** Keywords ***
# Case teardown
#     [Documentation]  Author: Wang Yixiang
#     ...    restore attenuation and other teardown
#     ...    :default_value${IS_ATTENUATION_EXISTS}: set in suite preparation
#     run keyword if    ${IS_ATTENUATION_EXISTS}     Adjust the Attenuation
#     Android Common Test Teardown
# 
# Repeat increase and decrease interface five times and verify
#     [Documentation]    Author: Wang Yixiang
#     ...    Repeat increase and decrease interface five times
#     [Arguments]    ${retry_times}=5    ${delta}=10    ${direction}=DL
#     FOR    ${i}    IN RANGE    ${retry_times}
#        Increase interferece simulate UE move from close gNB to distance and verify
#        ...    retry_times=${retry_times}    delta=${delta}    direction=${direction}
#        Decrease interferece simulate UE move from distance gNB to close and verify
#        ...    retry_times=${retry_times}    delta=${delta}    direction=${direction}
#     END
# 
# Increase interferece simulate UE move from close gNB to distance and verify
#     [Documentation]    Author: Wang Yixiang
#     ...    simulate UE move from close gNB to distance
#     [Arguments]    ${retry_times}=5    ${delta}=10    ${direction}=DL
# 
#     ${pre_bler}    set variable    0
#     ${pre_mcs}     set variable    28
#     ${dl_delta}    set variable if    '${direction}'=='DL'    ${delta}     0
#     ${ul_delta}    set variable if    '${direction}'=='UL'    ${delta}     0
#     FOR    ${i}    IN RANGE    ${retry_times}
#         ${layer0_dl}    evaluate    ${IDEAL_LAYER0_DL_ATTEN}+${i}*${dl_delta}
#         ${layer1_dl}    evaluate    ${IDEAL_LAYER1_DL_ATTEN}+${i}*${dl_delta}
#         ${layer0_ul}    evaluate    ${IDEAL_LAYER0_UL_ATTEN}+${i}*${ul_delta}
#         ${layer1_ul}    evaluate    ${IDEAL_LAYER1_UL_ATTEN}+${i}*${ul_delta}
#         Adjust the Attenuation
#         Start TTI trace log capturing
#         Sleep    5s
#         Stop TTI trace log capturing
#         &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
#         Verify bler is as expected based on event trace log    dict_event_trace_log=${dict_event_trace_log}
#         &{mcs_blers_dict}    event_trace_analysis.get_bler_mcs_single_ue    file_path=${dict_event_trace_log['DL']}
#         ${cur_mcs}     set variable    ${mcs_blers_dict['mcs']}
#         ${cur_bler}    set variable    ${mcs_blers_dict['bler']}
#         should be true    ${cur_mcs} <= ${pre_mcs}
#         should be true    ${cur_bler} >= ${pre_bler}
#         ${pre_mcs}    set variable    ${cur_mcs}
#         ${pre_bler}    set variable    ${cur_bler}
#     END
# 
# Decrease interferece simulate UE move from distance gNB to close and verify
#     [Documentation]    Author: Wang Yixiang
#     ...    simulate UE move from distance gNB to close
#     [Arguments]    ${retry_times}=5    ${delta}=-10    ${direction}=DL
#     ${pre_bler}    set variable    0.1
#     ${pre_mcs}     set variable    1
#     ${dl_delta}    set variable if    '${direction}'=='DL'    ${delta}     0
#     ${ul_delta}    set variable if    '${direction}'=='UL'    ${delta}     0
#     FOR    ${i}    IN RANGE    ${retry_times}
#         ${layer0_dl}    evaluate    ${IDEAL_LAYER0_DL_ATTEN}+${i}*${dl_delta}
#         ${layer1_dl}    evaluate    ${IDEAL_LAYER1_DL_ATTEN}+${i}*${dl_delta}
#         ${layer0_ul}    evaluate    ${IDEAL_LAYER0_UL_ATTEN}+${i}*${ul_delta}
#         ${layer1_ul}    evaluate    ${IDEAL_LAYER1_UL_ATTEN}+${i}*${ul_delta}
#         Adjust the Attenuation
#         Start TTI trace log capturing
#         Sleep    5s
#         Stop TTI trace log capturing
#         &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
#         Verify bler is as expected based on event trace log    dict_event_trace_log=${dict_event_trace_log}
#         &{mcs_blers_dict}    event_trace_analysis.get_bler_mcs_single_ue    file_path=${dict_event_trace_log['DL']}
#         ${cur_mcs}     set variable    ${mcs_blers_dict['mcs']}
#         ${cur_bler}    set variable    ${mcs_blers_dict['bler']}
#         should be true    ${cur_mcs} >= ${pre_mcs}
#         should be true    ${cur_bler} <= ${pre_bler}
#         ${pre_mcs}    set variable    ${cur_mcs}
#         ${pre_bler}    set variable    ${cur_bler}
#     END
