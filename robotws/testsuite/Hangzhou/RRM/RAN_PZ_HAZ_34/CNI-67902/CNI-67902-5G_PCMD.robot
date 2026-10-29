# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation
# # #...         author: shangyu.xu
# # #...         contact: shangyu.xu@nokia-sbell.com
# # #...         squad group: 5G_PZ_MMW_HZ_3_SG
# # #...         PCMD test
# # #
# # #Suite Setup       Suite setup
# # #Suite Teardown    Suite teardown
# # #
# # #Library     taf.sw.dcap.rd		WITH NAME	DCAP
# # #Resource    ./resources/common_keyword.robot
# # #Library     ./resources/PCMD.py
# # #
# # #
# # #*** Variables ***
# # #${ute_host}           ${tl.test_pc.default_ssh_connection_details.addr}
# # #${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
# # #${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
# # #
# # #${DCAP_host}    ${tl.test_pcs[0].default_ssh_connection_details.addr}
# # #${DCAP_port}    ${tl.test_pcs[0].default_ssh_connection_details.port}
# # #&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
# # #${bts_id}   10045
# # #${txt_log_name}    Emil_log_PCMD.txt
# # #${alias}    gnb_923
# # #${EMIL_HOST}    10.101.47.116
# # #${EMIL_USER}    nokia5G
# # #${EMIL_PASSWORD}    noki@123
# # #${TS_CASE_LOG_PATH}    /home/ute/logs/
# # #${pcmd_log_path}    /home/ute/logs
# # #
# # #*** Test Cases ***
# # #Step 1: Start test
# # #    Reboot UE for NSA
# # #    L3 call setup for NSA      UE_TYPE=askey
# # #
# # #    Log To Console    \n ### Step 2: Start DCAP log ###
# # #    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}     username=dcapuser
# # #    ...     password=dcapadmin!     rd_version=dcapv3    secure=${True}
# # #    ${gnb_custom_profile}=     Create List     cp_5g
# # #    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
# # #    ...     control_plane_interface=${True}
# # #    Log    &{output}[id]
# # #    ${result_id}      Convert To Integer      &{output}[id]
# # #    set suite variable    ${result_id}
# # #    sleep    20s
# # #
# # #    Log To Console    \n ### step3:Stop DCAP log ###
# # #    ${profile_file}    set variable    SourceProfile_PCMD.ini
# # #    DCAP.stop_trace    trace_id=${result_id}
# # #    sleep    120s
# # #    Log To Console    \n ### download zip ###
# # #    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}    target_dir=${TS_CASE_LOG_PATH}
# # #    sleep    60s
# # #    Get the exact emil log and convert to txt
# # #    ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}
# # #
# # #    Log To Console    \n ### step4:L3 Call Stop ###
# # #    Stop traffic and UE detach      UE_TYPE=askey
# # #
# # #
# # ##[1]CNI-67902-5G_7_L2_PCMD_Trace_DL_RLC_and_DL_RLC_Record_SA
# # ##    [Tags]
# # ##    [Setup]
# # ##    ${offset}    set variable    36
# # ##    ${length}    set variable    8
# # ##    ${all_length}    set variable   200
# # ##    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # ##    ${conditions}    set variable     0
# # ##    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # ##    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}
# # #
# # ##   13???????
# # #
# # #[1]CNI-67902-5G_14_L2_PCMD_Trace_dlTimeUeSched_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    24
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_15_L2_PCMD_Trace_dlMacPdusIniTx_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    28
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_16_L2_PCMD_Trace_dlBadMacPdusIniTx_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    32
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_17_L2_PCMD_Trace_dlBadMacPdusLastTx_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    36
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_18_L2_PCMD_Trace_sumOfWbCqi_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    40
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_19_L2_PCMD_Trace_numOfWbCqiSamples_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    44
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_20_L2_PCMD_Trace_numberOfPdschWithRank1&2&3&4_SDlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    48
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   80
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_21_L2_PCMD_Trace_ulTimeUeSched_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    24
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_22_L2_PCMD_Trace_ulMacPdusIniTx_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    28
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_23_L2_PCMD_Trace_ulBadMacPdusIniTx_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    32
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_24_L2_PCMD_Trace_ulBadMacPdusLastTx_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    36
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_25_L2_PCMD_Trace_sumOfSinr_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    40
# # #    ${length}    set variable    8
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_26_L2_PCMD_Trace_numOfSinrSamples_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    48
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_27_L2_PCMD_Trace_numberOfPuschWithRank1&2&3&4_SUlSchedulingTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    56
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   88
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_28_L2_PCMD_Trace_numOfTotalBeamChanges_SBeamUsageTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    24
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   200
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_29_L2_PCMD_Trace_numOfFailedBeamChange_SBeamUsageTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    26
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   200
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_30_L2_PCMD_Trace_numOfTotalBeamRecovery_SBeamUsageTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    28
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   200
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_31_L2_PCMD_Trace_numOfSuccessfulBeamRecoveries_SBeamUsageTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    30
# # #    ${length}    set variable    2
# # #    ${all_length}    set variable   200
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_32_L2_PCMD_Trace_beamIdUsageCount[4]_beamIdUsageCount[8]_beamIdUsageCount[64]_SBeamUsageTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    36
# # #    ${length}    set variable    8
# # #    ${all_length}    set variable   200
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_34_L2_PCMD_Trace_recordCollectionDuration_DL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    44
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
# # #    ${conditions}    set variable     0
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_35_L2_PCMD_Trace_dlRlcPduTxBytes_DL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    32
# # #    ${length}    set variable    8
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_36_L2_PCMD_Trace_dlRlcTxTime_DL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    40
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_37_L2_PCMD_Trace_ulRlcPduTxBytes_UL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    32
# # #    ${length}    set variable    8
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDULRADIOBEARERRLCMEASIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_38_L2_PCMD_Trace_ulRlcTxTime_UL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    40
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #[1]CNI-67902-5G_39_L2_PCMD_Trace_recordCollectionDuration_UL_RLCTraceRecord
# # #    [Tags]
# # #    [Setup]
# # #    ${offset}    set variable    44
# # #    ${length}    set variable    4
# # #    ${all_length}    set variable   432
# # #    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
# # #    ${conditions}    set variable     1
# # #    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
# # #    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}
# # #
# # #
# # #
# # #
# # ##20 27 35 37
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
# # 
