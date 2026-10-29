*** Settings ***
Documentation
...    author: Li Yingying
...    contact: yingying.li@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG
...    Feature 5GC001358-B
Force Tags
...    PY36

Resource       Resources/5GC001358-B_5GC001856_common_keywords.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource       ./Resources/5GC001358_common_keyword.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/pre_analysis.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource       ./Resources/5GC001358_DA_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    throughput_computation
Variables      ./Resources/5GC001358_variables.py

Suite Setup         Run Keyword And Ignore Error       Common Suite Setup for COAM
Suite Teardown       Run Keyword And Ignore Error     Common Suite Teardown for COAM


*** Variables ***
${dl_throughput}     1500M
${Expect_DOWNLINK}    1515
${UE_TYPE}    ${tl.ues[-1].capabilities[-1]}
${sleep_time}    6min
${ultp_100MHz}    94.5
${uldata_100MHz}    100M
${data_amount}    2M
${seg_size}    1300
${process_num}    5
${protocol}  udp
${deviation}    1%


*** Test Cases ***
#[1]5GC001358-B_021_5GC001856-M_close_loop_4x4MIMO_throughput_check_with_beamforming
#    [Documentation]
#    ...    The purpose of the test is to check the throughput in Close Loop mode
#    [Tags]    CRT_TRUNK
#    [Setup]     robot_common_operations.Common Case Setup
#    Scf commission and wait for onair    scf_name=SCF_SBTS00.xml
#    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    dlMimoMode     update    4x4 or 4x2 Closed Loop Spatial Multiplexing
#    COAM Reset Site     connection=GNB_OAM
#    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
#    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
#    Check RU Calibration Status And Power
#    Power UE Precondition
#    Run keyword and continue on failure    _Reboot UE    connection=cpc_0
#    sleep    30s
#    Power UE Attach and Verify attach     4g_check=False
#    Power UE Start traffic and check throughput    dl_throughput=${dl_throughput}    Expect_DOWNLINK=${Expect_DOWNLINK}
#    sleep     5s
#    Stop traffic and detach UE
#    [Teardown]    robot_common_operations.Common Case Teardown

[1]5GC001358-B_022_5GC001870-K_open_loop_4x4MIMO_throughput_check_with_beamforming
    [Documentation]
    ...    The purpose of the test is to check the throughput in open Loop mode
    [Tags]    CRT_TRUNK    CDRT_22R2      CRT_22R2
    [Setup]    robot_common_operations.Common Case Setup
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Scf commission and wait for onair    scf_name=SCF_8T8R_${stream}.xml
    Change Parameter    MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-1    dlMimoMode     update    4x4 or 4x2 Open Loop Spatial Multiplexing
    ${mod_params} =         Create Dictionary         SslotMCS=${24}     trsMCS=${28}
    ${theoretical_dl}    ${theoretical_ul_1}    throughput_computation.get_theoretical_throughput
    ...     scf_path=${scf_file_template_path}/SCF_8T8R_${stream}.xml
    ...     cell_id=1
    ...     mod_params=${mod_params}
    Log to console     for askey UE only supported 1 UL layer and not supported UL256QAM, so calculate as following
    ${theoretical_ul}=      Evaluate    ${theoretical_ul_1}*408/1000
    sleep     5s
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_default}
    Prepare UE for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    dltp_expected=${theoretical_dl}    data_send_dl=${dl_throughput}     tp_direction=dl
 	...    sleep_time=${sleep_time}     call_duration=5m    target_avg_percent=0.98    min_percent=0.80
    sleep     5s
    Stop traffic and detach UE
    UE Detach for ${ue_type}
    UE Attach for ${ue_type}
    Start traffic and check result    ultp_expected=${theoretical_ul}    data_send_ul=${uldata_100MHz}    tp_direction=ul
 	...    sleep_time=${sleep_time}    call_duration=5m    target_avg_percent=0.98    min_percent=0.80
    UE Detach for ${ue_type}
    [Teardown]    Run keywords    RUN KEYWORD AND CONTINUE ON FAILURE
    ...    robot_common_operations.Common Case Teardown    AND
    ...    CI_interface.Common Case Teardown
