# *** Settings ***
# Documentation
# ...   author: zheyuan.chen@nokia-sbell.com
# ...   contact: zheyuan.chen@nokia-sbell.com
# ...   RF
# 
# Suite Setup    CI_interface.Common Suite Setup
# 
# Resource    ./resource/comm_956AF.robot
# Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    ../../../SISO/RAN_PZ_HAZ_34/CB006487/resources/CB006487_common_keyword.robot
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABILB1_2xAWHHF    STATE_SW_UPLOADED
# ...    PY36
# 
# 
# *** Variable ***
# @{band41_thresholds}    41    100    3
# ${ue_type}    ${tl.ues[2].capabilities[1]}
# ${server_ip}    ${tl.ues[1].iperf_details.network_interface_address}
# ${server_port_ul_sam}       ${tl.ues[1].iperf_details.ports[2]}
# ${server_port_dl_sam}       ${tl.ues[1].iperf_details.ports[3]}
# ${dl_peak_sam}    100
# ${ul_peak_sam}    30
# ${start_time_name}      BTS test start time GMT +0800
# ${stop_time_name}       BTS test stop time GMT +0800
# 
# *** Test Cases ***
# [1]5GC000956_001_Create_RFTHLD_and_Set_RF_Diagnostic_Thresholds_valuse_online_from_WebEM
#     [Tags]
#     [Setup]
#     Create Default RFTHLD
# 
# [1]5GC000956_003_trigger_RF_Diagnostic_test_by_WebEM_normal_mode_without_L3_call
#     [Documentation]
#     ...    The purpose of this case is to verify that RF diagnostic test for selected NR cells or for all NR cells can be run by WebEM.
#     ...    -12.04.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]
#     [Setup]
#     Create Default RFTHLD
#     ${versiontitle}    Get Version
#     comm_956AF.WEBUI Login    version=SBTS21B
#     ${bts_thresholds}    create dictionary    Low RSSI threshold=${-160}
#     ${bands_thresholds}    create list    ${band41_thresholds}
#     [Teardown]
# 
# [1]5GC000956_004_trigger_RF_Diagnostic_test_by_WebEM_normal_mode_with_L3_call
#     [Documentation]
#     ...    The purpose of this case is to verify that RF diagnostic test for selected NR cells when make L3 call can be run by WebEM.
#     ...    -21.04.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]
# 
# [1]5GC000956_006_Set_RF_diagnostic__threshold_and_managed object_illegal_values_and_wrong_cell_status_by_WebEM
#     [Documentation]
#     ...    The purpose of this case is to set the TEST managed object and/or RF diagnostic illegal threshold values and
#     ...    wrong cell status online by WebEM.
#     ...    -13.04.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]
# 
# [1]5GC000956_010_trigger_RF_Diagnostic_test_lock_unlock_cell_and_RU_by_WebEM_normal_mode_without_L3_call
#     [Documentation]
#     ...    The purpose of this case is to verify that RF diagnostic test for selected NR cells after
#     ...    lock/unlock cell and RU can be run by WebEM.
#     ...    -14.04.2021,zheyuan.chen@nokia-sbell.com,case draft
#     [Tags]
#     [Setup]
#     Should Be Equal As Strings    ${PREV_TEST_STATUS}   PASS
#     [Teardown]
# 
# *** Keywords ***
# Create Default RFTHLD
#     Log To Console    Delete RFTHLD If Exist
#     Delete RFTHLD If Exist OK
#     Modify actRemoteRfDiag Parameters
#     Set default value for RFTHLD
#     Verify value for RFTHLD    totalRFPowerHighThreshold=${0}    totalRFPowerLowThreshold=${0}
#     ...    rFPowerErrorHighThreshold=${1}    rFPowerErrorLowThreshold=${-9}    rxAntennaRSSIHighThreshold=${-181}
#     ...    rxAntennaRSSILowThreshold=${-181}    rxAntennaRTWPHighThreshold=${-181}    rxAntennaRTWPLowThreshold=${-181}
#     ...    txAntennaVSWRHighThreshold=${0}
#     Verify value for RFTHLD    totalRFPowerHighThreshold=${151}    totalRFPowerLowThreshold=${151}
#     ...    rFPowerErrorHighThreshold=${9}    rFPowerErrorLowThreshold=${-1}    rxAntennaRSSIHighThreshold=${1}
#     ...    rxAntennaRSSILowThreshold=${1}    rxAntennaRTWPHighThreshold=${1}    rxAntennaRTWPLowThreshold=${1}
#     ...    txAntennaVSWRHighThreshold=${11}
# 
# Start L3 Call
#     log To Console        Start L3 Call
#     samsung attach
#     log To Console        Start traffic
#     UE start traffic sam       ue_index=${2}    tp_direction=both    time=100s
#     ...    ul_throughput=500M    dl_throughput=500M   ue_type=samsung
#     ...    iperf_port_ul=${server_port_ul_sam}    iperf_port_dl=${server_port_dl_sam}
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=dl    throughput=${dl_peak_sam}     cellid=11468802
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=samsung    direction=ul    throughput=${ul_peak_sam}     cellid=11468802
# 
# 
# Stop L3 Call
#     Log To Console    Stop L3 Call
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${2}    iperf_port=${server_port_dl_sam}    ue_mode=NSA
#     power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${2}    iperf_port=${server_port_ul_sam}    ue_mode=NSA
#     run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}
# 
# Check RF Diagnostic Test Result
#     [Arguments]    ${versiontitle}   ${bts_thresholds}=${None}    ${bands_thresholds}=${None}
#     comm_956AF.RF Diagnostic Test Setup And Check Time    bts_thresholds=${bts_thresholds}    bands_thresholds=@{bands_thresholds}
#     comm_956AF.Check Detailed Antenna    RSSI_low=-160
#     comm_956AF.Check General Information
#     ${if_sbts}    run keyword and return status    should contain    ${versiontitle}    SBTS
#     ${start_time_name}    run keyword if    ${if_sbts}    set variable    BTS test start time GMT +0800
#     ...    ELSE    set variable    Start time GMT +0800
#     ${stop_time_name}    run keyword if    ${if_sbts}    set variable    BTS test stop time GMT +0800
#     ...    ELSE    set variable    Stop time GMT +0800
#     comm_956AF.Check Start And Stop Time     start_time_name=${start_time_name}    stop_time_name=${stop_time_name}
# 
# case_teardown
#     comm_956AF.WEBUI Logout
#     CI_interface.Common Case Teardown
# 
# suite_setup
#     Input default SCF
#     Create TEST If Not Exit
#     Check BTS Should Be Normal
# 
# Input default SCF
#     [Timeout]  20 min
#     [Arguments]    ${timeout}=10 min
#     ${conn}    Connect to DU
#     BuiltIn.Log    \n Input default SCF \n    console=yes
#     COAM Commission with scf file ignore error    scf_file_path=${default_scf_path}    connection=${conn}
#     BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
#     wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
#     wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
# 
# COAM Commission with scf file ignore error
#     [Documentation]  Author: Liu Steven
#     ...              Description: Do commission and verify commission status
#     ...                           2019-11-12, add argument ${is_pdl_checking_needed} to open interface to tester if pdl checking is needed,
#     ...                                       Valid values are: ${True} or ${False}, if ${True}, then pdl validation is needed,
#     ...                                       otherwise will ignore this validation. Now it's default to ${True}
#     [Arguments]  ${scf_file_path}    ${connection}=GNB_OAM    ${timeout}=300    ${is_pdl_checking_needed}=${True}
#     &{result}    coam.perform_commissioning    scf_file=${scf_file_path}
#     ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}