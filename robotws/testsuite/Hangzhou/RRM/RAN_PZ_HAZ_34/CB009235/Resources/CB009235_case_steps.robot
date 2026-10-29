*** Settings ***
Documentation    CB009235 TA cases common steps
...              Author: xiaoxia.hao@nokia-sbell.com


Variables    TestCaseVariables.py
Resource     CB009235_keywords.robot

*** Variables ***
${tddpcell_index}                    ${3}
@{SWCONFIG_PARA_CB009235_B}    0x58077e=1    0x5805c3=1

*** Keywords ***
CB009235-SR-C_001_PM_counter_MU_MIMO_PAIR_DL_SUCC
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    ${mcs_type}    mcs_common.Get MCS Type
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=2600_1_ALL
    Set MCS Phase For SA MultiUE PAIRED
    UE Prepare for UES    ues_index=${${1},${2},${3},${4}}
    Disable AutoConnect For 8UE Module    ues_index=${${1},${2},${3},${4}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${2},${3}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${1},${2},${3},${4}}    is_power_ue_code=${True}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3}}    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3}}    ue_mode=SA
    ...                            whether_start_ul_call=${False}    dl_throughput=600MKbits/sec
    Sleep    30sec
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Wait Until Next Counter Update
    Sleep    60sec
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${M55308C34030_full_path}    set variable    ${dis_name_dir}/NRCELL-${tddpcell_index}/NCELA/MU_MIMO_PAIR_DL_SUCC
    ${M55308C34030_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55308C34030    counter_full_path=${M55308C34030_full_path}
    ${M55308C34030_value}    convert to integer     ${M55308C34030_value}
    should be true    ${M55308C34030_value}>500000
    [Teardown]    Run Keyword And Ignore Error    MultiUE.Stop DL Traffic    ues_index=${${2},${3}}

CB009235-SR-B_004_Support_DL_pairing_for_UEs_with_MAC_CE_1_UE_non-GBR_initial_transmission_and_multiplexed_with_MAC_CE
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    ${mcs_type}    mcs_common.Get MCS Type
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=2600_1_ALL
    Set MCS Phase For SA MultiUE PAIRED
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${3},${4}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${3},${4}}    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4}}    ue_mode=SA
    ...                            whether_start_ul_call=${False}    dl_throughput=50MKbits/sec
    Sleep    30sec
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    ${ttitrace_file}    Capture And Decode TTitrace Log    duration=5    direction=dl
    Check Mustatus Contain NOPAIR_LITTLEDATANOTNEEDPAIR on TTI    ttitrace_file=${ttitrace_file}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${update_dlMuPairingPrbRatio_value}    Catenate    {'dist_name': '${dis_name_dir}/NRCELL-${tddpcell_index}/NRDLMUMIMO-1',
    ...                             'parameter': 'dlMuPairingPrbRatio',
    ...                             'value': '0'}
    ${restore_dlMuPairingPrbRatio_value}    Catenate    {'dist_name': '${dis_name_dir}/NRCELL-${tddpcell_index}/NRDLMUMIMO-1',
    ...                             'parameter': 'dlMuPairingPrbRatio',
    ...                             'value': '100'}
    ${para_restore}    Evaluate    [${restore_dlMuPairingPrbRatio_value}]
    ${para_modify}    Evaluate    [${update_dlMuPairingPrbRatio_value}]
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_modify}    timeout=900
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    ${attachinfo_dict}     UE attach for UES    ues_index=${${3},${4}}    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4}}    ue_mode=SA
    ...                            whether_start_ul_call=${False}    dl_throughput=50MKbits/sec
    Sleep    30sec
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
#    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=10    timeout=1800
    ${ttitrace_file}    Capture And Decode TTitrace Log    duration=5    direction=dl
    Check Mustatus Not Contain NOPAIR_LITTLEDATANOTNEEDPAIR And Contain MUPAIR on TTI    ttitrace_file=${ttitrace_file}
    [Teardown]    run keywords    run keyword and ignore error    COAM Teardown gnb connections    AND
    ...                           Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    AND
    ...                           run keyword and ignore error
    ...                           COAM Update Several Parameters Via Rest Api    parameters_to_update_via_api=${para_restore}    timeout=900    AND
    ...                           COAM Wait For Gnb Ready And Cell Setup    timeout=25 min

CB009235-SR-A_002_MU_aware_TD_scheduling_with_default_condition
    [Documentation]    Auther: xiaoxia.hao@nokia-sbell.com
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}
    ...                                                       swconfig_modify=${SWCONFIG_PARA_CB009235_B}
    Perform gNB Restart And Check on air via rest api
    Set MCS Phase For NSA 4UE PAIRED
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3},${4},${5}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3},${4},${5}}    ue_mode=NSA
    ...                            whether_start_ul_call=${False}    dl_throughput=600MKbits/sec
    Sleep    30sec
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
#    Capture Logs With gNB_logs    bbmod_slots=${bbmod_slots}    duration=10    timeout=1800
#    ...                           tti_log_option=T
    ${ttitrace_file}    Capture And Decode TTitrace Log    duration=5    direction=dl
    Check Mustatus And NumberofCorrCalcDuringSelectUes on TTI    ttitrace_file=${ttitrace_file}
    [Teardown]    run keywords
    ...                           Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api

