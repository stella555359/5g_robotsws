*** Settings ***
Documentation
...    Author: xinzhu
...    Contact: xinran.zhu@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC000938_RA in 5G21A program

Suite Setup    Run keywords    CI_interface.Common Suite Setup    AND    PCMD Coam Suite Setup    AND    Suite Setup
...    AND    robot_common_operations.Common Suite Setup
Suite Teardown    Run keywords    Suite Teardown    AND    robot_common_operations.Common Suite Teardown
...    AND    CI_interface.Common Case Teardown
Test Timeout         300 min

Resource     Resources/5GC000938_C-keyword.robot
Resource     Resources/5GC002056-ABAS_classcial_keywords.robot
Library     Resources/PCMD.py
Library    OperatingSystem

Force Tags       RAN_5G_FDD   STATE_SW_UPLOADED     RAN_5G    CLOUD_5G_CLASSICAL_ASIBR_ABIOB1_AHPB_ENB
...    PY36
...    CRT_UTE    SBTS00    SBTS21B    SBTS22R1

*** Variables ***
${ute_host}           ${tl.test_pc.default_ssh_connection_details.addr}
${ute_user}    ${tl.test_pc.default_ssh_connection_details.username}
${ute_password}    ${tl.test_pc.default_ssh_connection_details.password}
${DCAP_host}    ${tl.host[0].default_ssh_connection_details.addr}
${DCAP_port}    ${tl.host[0].default_ssh_connection_details.port}
${DCAP_username}    ${tl.host[0].default_ssh_connection_details.username}
${DCAP_password}    ${tl.host[0].default_ssh_connection_details.password}
&{bts}      host=${bts_host}    username=Nemuadmin    password=nemuuser    port=443
${bts_host}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${profiles}    5G
${txt_log_name}    Emil_log_PCMD.txt
${alias}    gnb_923
${EMIL_HOST}    10.101.47.116
${EMIL_USER}    nokia5G
${EMIL_PASSWORD}    noki@123
${TS_CASE_LOG_PATH}    /home/ute/logs/
${pcmd_log_path}    /home/ute/logs
${profile_path}     C:\\Program Files\\Emil\\profiles\\5G
${nrbtsId}    ${tl.gnbs[0].global_bts_id}
${mrbtsId}    ${tl.gnbs[0].instance_id}

*** Test Cases ***
[1]CNI-67902-5G_14_L2_PCMD_Trace_dlTimeUeSched_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    Site reset
    Set parameter    key=actIpThpt    value=true    dict_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}
    Wait Until Keyword Succeeds    15min    20s    COAM Check All Cells Onair
    Step5: Check X2 available Status
    Step 1: Start test
    ${offset}    set variable    24
    ${length}    set variable    4
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_15_L2_PCMD_Trace_dlMacPdusIniTx_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    28
    ${length}    set variable    4
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_16_L2_PCMD_Trace_dlBadMacPdusIniTx_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    32
    ${length}    set variable    4
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_17_L2_PCMD_Trace_dlBadMacPdusLastTx_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    36
    ${length}    set variable    4
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_18_L2_PCMD_Trace_sumOfWbCqi_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    40
    ${length}    set variable    4
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_19_L2_PCMD_Trace_numOfWbCqiSamples_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    44
    ${length}    set variable    2
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_20_L2_PCMD_Trace_numberOfPdschWithRank1&2&3&4_SDlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    48
    ${length}    set variable    2
    ${all_length}    set variable   80
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDDLSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_21_L2_PCMD_Trace_ulTimeUeSched_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    24
    ${length}    set variable    4
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_22_L2_PCMD_Trace_ulMacPdusIniTx_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    28
    ${length}    set variable    4
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_23_L2_PCMD_Trace_ulBadMacPdusIniTx_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    32
    ${length}    set variable    4
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_24_L2_PCMD_Trace_ulBadMacPdusLastTx_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    36
    ${length}    set variable    4
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_25_L2_PCMD_Trace_sumOfSinr_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    40
    ${length}    set variable    8
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_26_L2_PCMD_Trace_numOfSinrSamples_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    48
    ${length}    set variable    2
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_27_L2_PCMD_Trace_numberOfPuschWithRank1&2&3&4_SUlSchedulingTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    56
    ${length}    set variable    2
    ${all_length}    set variable   88
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDULSCHEDULINGIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_28_L2_PCMD_Trace_numOfTotalBeamChanges_SBeamUsageTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    24
    ${length}    set variable    2
    ${all_length}    set variable   200
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_29_L2_PCMD_Trace_numOfFailedBeamChange_SBeamUsageTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    26
    ${length}    set variable    2
    ${all_length}    set variable   200
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_30_L2_PCMD_Trace_numOfTotalBeamRecovery_SBeamUsageTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    28
    ${length}    set variable    2
    ${all_length}    set variable   200
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_31_L2_PCMD_Trace_numOfSuccessfulBeamRecoveries_SBeamUsageTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    30
    ${length}    set variable    2
    ${all_length}    set variable   200
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_32_L2_PCMD_Trace_beamIdUsageCount[4]_beamIdUsageCount[8]_beamIdUsageCount[64]_SBeamUsageTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    36
    ${length}    set variable    8
    ${all_length}    set variable   200
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_34_L2_PCMD_Trace_recordCollectionDuration_DL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    44
    ${length}    set variable    4
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
    ${conditions}    set variable     0
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_35_L2_PCMD_Trace_dlRlcPduTxBytes_DL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    32
    ${length}    set variable    8
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_36_L2_PCMD_Trace_dlRlcTxTime_DL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    40
    ${length}    set variable    4
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDDLRADIOBEARERRLCMEASIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_37_L2_PCMD_Trace_ulRlcPduTxBytes_UL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    32
    ${length}    set variable    8
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_LOTRACE_PCMDULRADIOBEARERRLCMEASIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_38_L2_PCMD_Trace_ulRlcTxTime_UL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    40
    ${length}    set variable    4
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]CNI-67902-5G_39_L2_PCMD_Trace_recordCollectionDuration_UL_RLCTraceRecord
    [Tags]
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    robot_common_operations.Common Case Teardown
    ${offset}    set variable    44
    ${length}    set variable    4
    ${all_length}    set variable   432
    ${pcmd_event_name}    set variable     ITF_L2_NRT_PSTRACE_PCMDBEAMUSAGEIND_ID
    ${conditions}    set variable     1
    ${offset}    ${length}    ${all_length}    Input PCMD search value    ${offset}    ${length}    ${all_length}
    Check PCMD Event    ${offset}    ${length}    ${all_length}    ${pcmd_event_name}    ${conditions}    ${txt_log_name}

[1]5GC000938-C_29_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_20MHz
    [Tags]    HAZ3_T03
    [Documentation]    Author: Zhu Xinran
    ...    Description: this case is to verify NSA L3 call with askey
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    Run keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown
    Step1: Check GNB cell on air
    #Step2: Set parameter prachConfigurationIndex to 40ms
    #Step3: set bandwidth to 20MHz
    Step4: Reboot UE for NSA
    Step5: Check X2 available Status
    Step6: L3 call setup for NSA
    Step7: Check PM counters
    #Step8: change prachConfigurationIndex and check for 20ms

[1]5GC000938-C_30_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_15MHz
    [Tags]    HAZ3_T03
    [Documentation]    Author: Zhu Xinran
    ...    Description: this case is to verify NSA L3 call with askey
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    Run keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown
    Step1: Scf commission and wait on-air
    Step2: Set parameter prachConfigurationIndex to 40ms
    Step3: set bandwidth to 15MHz
    Step4: Reboot UE for NSA
    Step5: Check X2 available Status
    Step6: L3 call setup for NSA
    Step7: Check PM counters
    #Step8: change prachConfigurationIndex and check for 20ms

[1]5GC000938-C_32_Enable_Disable_20ms_PRACH_Format_1_NSA_FDD_FR1_5MHz
    [Tags]    HAZ3_T03
    [Documentation]    Author: Zhu Xinran
    ...    Description: this case is to verify NSA L3 call with askey
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    Run keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown
     Scf commission and wait on-air    scf_name=SCF_TL923_5M.xml
     Step2: Set parameter prachConfigurationIndex to 40ms
     #Step3: set bandwidth to 5MHz
     Step4: Reboot UE for NSA
     Step5: Check X2 available Status
     Step6: L3 call setup for NSA
     Step7: Check PM counters
     #Step8: change prachConfigurationIndex and check for 20ms

[1]5GC000938-C_36_Enable_Disable_40ms_PRACH_Format_1_NSA_FDD_FR1_5MHz
    [Tags]    HAZ3_T03
    [Documentation]    Author: Zhu Xinran
    ...    Description: this case is to verify NSA L3 call with askey
    [Setup]    robot_common_operations.Common Case Setup
	[Teardown]    Run keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown
     Step1: Check GNB cell on air
     Step2: Set parameter prachConfigurationIndex to 36ms
     #Step3: set bandwidth to 5MHz
     Step4: Reboot UE for NSA
     Step5: Check X2 available Status
     Step6: L3 call setup for NSA
     Step7: Check PM counters
     #Step8: change prachConfigurationIndex and check for 40ms




*** Keywords ***
Step 1: Start test
    Log To Console    \n ### Step 2: Start DCAP log ###
    DCAP.connect_to     host=${DCAP_host}    port=${DCAP_port}
    ...     rd_version=dcapv3    secure=${True}
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    ...     control_plane_interface=${True}
    Log    ${output}[tracer_id]
    ${result_id}      Convert To Integer      ${output}[tracer_id]
    set suite variable    ${result_id}
    sleep    60s

    Reboot UE for NSA
    L3 call setup for PCMD      UE_TYPE=askey

    Log To Console    \n ### step3:Stop DCAP log ###
    ${profile_file}    set variable    SourceProfile_PCMD.ini
    DCAP.stop_trace    trace_id=${result_id}
    sleep    120s
    Log To Console    \n ### download zip ###
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${result_id}    target_dir=${TS_CASE_LOG_PATH}
    sleep    60s
    Get the exact emil log and convert to txt
    ...    txt_log_name=${txt_log_name}    DCAP_log_path=${downloaded_emil_file_path}    profile_file=${profile_file}

    Log To Console    \n ### step4:L3 Call Stop ###
    Stop traffic and UE detach      UE_TYPE=askey


Step1: Check GNB cell on air
    Log    \nStep1:Check GNB cell on air    console=yes
    Check GNB cell on air

Step2: Set parameter prachConfigurationIndex to 40ms
    Log    \nStep2:Set parameter prachConfigurationIndex to 40ms     console=yes
     Set parameter    key=prachConfigurationIndex    value=${40}

Step2: Set parameter prachConfigurationIndex to 36ms
    Log    \nStep2:Set parameter prachConfigurationIndex to 36ms     console=yes
     Set parameter    key=prachConfigurationIndex    value=${36}

Step3: set bandwidth to 20MHz
    Log    \nStep3:set bandwidth to 20MHz    console=yes
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='23R2' or '${RELEASE}'=='23R3'    set bandwidth with 20MHz
    ...    ELSE IF    '${RELEASE}'=='23R4'    set bandwidth with 20MHz for 23R4
    ...    ELSE    set bandwidth with 20MHz for Trunk

Step3: set bandwidth to 15MHz
    Log    \nStep3:set bandwidth to 15MHz    console=yes
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='23R2' or '${RELEASE}'=='23R3'    set bandwidth with 15MHz
    ...    ELSE IF    '${RELEASE}'=='23R4'    set bandwidth with 15MHz for 23R4
    ...    ELSE    set bandwidth with 15MHz for Trunk

Step3: set bandwidth to 5MHz
    Log    \nStep3:set bandwidth to 5MHz    console=yes
    ${RELEASE}=   Get program version
    run keyword if    '${RELEASE}'=='23R2' or '${RELEASE}'=='23R3'    set bandwidth with 5MHz
    ...    ELSE IF    '${RELEASE}'=='23R4'    set bandwidth with 5MHz for 23R4
    ...    ELSE    set bandwidth with 5MHz for Trunk

Step4: Reboot UE for NSA
    Log    \nStep4:Reboot UE for NSA    console=yes
    Reboot UE for NSA

Step5: Check X2 available Status
    Log    \nStep5: Check X2 available Status    console=yes
    Wait Until Keyword Succeeds    20min    20s    Check X2 Status

Step6: L3 call setup for NSA
    Log    \nStep6: L3 call setup for NSA    console=yes
    L3 call setup for NSA      UE_TYPE=askey

Step7: Check PM counters
    Log    \nStep7: Check PM counters       console=yes
     Check PM counters

Step8: change prachConfigurationIndex and check for 20ms
    Log    \nStep8: change prachConfigurationIndex and check for 20ms    console=yes
    change prachConfigurationIndex and check for 20ms

Step8: change prachConfigurationIndex and check for 40ms
    Log    \nStep8: change prachConfigurationIndex and check for 40ms    console=yes
    change prachConfigurationIndex and check for 40ms

Step1: Scf commission and wait on-air
    Log    \nStep1: Scf commission and wait on-air
    Scf commission and wait on-air    scf_name=SCF_TL923_15M_5M.xml

Step2: Modify actPCMDReport to true On Local gNB
    Log    \nModify actPCMDReport to true On Local gNB    console=yes
    Modify actPCMDReport to true On Local gNB     true
    sleep     30

Step3: Check ESTABLISHED Not Empty
    Log    \nStep3: Check ESTABLISHED Not Empty    console=yes
    Connect to DU
    Check ESTABLISHED Not Empty
    sleep     30
    Disconnect from DU

Step4: Modify actPCMDReport to false On Local gNB
     Log    \nStep4: Modify actPCMDReport to false On Local gNB    console=yes
	 Modify actPCMDReport to false On Local gNB     false
	 sleep     90

Step5: Check ESTABLISHED Empty
     Log    \nStep5: Check ESTABLISHED Empty    console=yes
     Connect to DU
     Check ESTABLISHED Empty
     sleep     30
	 Disconnect from DU
