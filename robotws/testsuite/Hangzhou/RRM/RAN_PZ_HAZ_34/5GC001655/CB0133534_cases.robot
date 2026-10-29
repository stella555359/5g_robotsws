*** Settings ***
Documentation     author: Yu Lu
...               contact: lu.1.yu@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC000679_AA/Resources/5GC000679_common_keyword_Dingli.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF
@{check_print}    ERR/

*** Test Cases ***
[1]CNI133534-A_3_check SRS interference mitigation enhancement
    [Setup]    Case Setup
    Reboot cpe for test for T788    ue_index=${1}
    Sleep    5min
    Run keyword and ignore error    Single UE Attach And Send Traffic
    [Teardown]    Case Teardown


*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/CB0133534.xml
    robot_common_operations.Common Case Setup

Case Teardown
    robot_common_operations.Common Case Teardown
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Reboot cpe for test for T788
    [Arguments]    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=1500M    ${duration}=3000    ${pci}=891    ${i}=0
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[${i}]
    log to console    \n***Prepare UE_0***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${1}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    Run keyword and ignore error    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}     log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${1}
    ...                       process_num=5
    Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    dl_target=200    ul_target=30
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${1}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${1}

Check DL UL Throughput On Site
    [Arguments]    ${cells}    ${dl_target}=1000    ${ul_target}=80
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=2m    ignore_time=0min    ue_index=${1}
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
    ...    ue_index=${1}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}
    ...    ue_index=${1}
