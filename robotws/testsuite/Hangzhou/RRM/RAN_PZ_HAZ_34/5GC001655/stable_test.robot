*** Settings ***
Documentation     author: yulu
...               contact: lu.1.yu@nokia-sebll.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
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
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

${tshark_path}         /usr/bin/tshark
${type}                nokia_fastmile

${MAX_LOOP}        20

@{check_print}    ERR/

*** Test Cases ***
stable_test_1
    [Tags]    CRT    CB009331
    [Setup]    Case Setup for 9331
    Reboot cpe for test for T788    ue_index=${0}
    Sleep    5min
    Run keyword and ignore error    Start Btslog Collect
    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Run Keyword And Continue On Failure    Single UE Attach And Send Traffic
    END
    Run Keyword And Continue On Failure    Single UE Attach And Send Traffic for asyslog check
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${TS_CASE_LOG_PATH}
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup for 9331
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    Set Test Variable     ${version}     ${result}[0]
    Run keyword and ignore error    Start Btslog Collect
    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/9331_case1.xml
    Run keyword and ignore error    Stop Btslog Collect    target_dir=${OUTPUT DIR}
    robot_common_operations.Common Case Setup

Case Teardown
    robot_common_operations.Common Case Teardown
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run Keyword If    '${version}' == 'SBTS26R1'    Load Case SCF and Commission new    default_scf=${scf_path}/${version}/SCF_trunk_788_golden.xml
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Single UE Attach And Send Traffic
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=1500M    ${duration}=180    ${pci}=817    ${i}=1
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[${i}]
    log to console    \n***Prepare UE_0***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    log_type=Iperf    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${0}
    ...                       process_num=5
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=10s    ignore_time=0min    ue_index=${0}    check_source=Iperf
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell1}    target_throughput=50    ue_index=${0}
    ...    check_source=Iperf
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell1}    target_throughput=10    ue_index=${0}
    ...    check_source=Iperf
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${0}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${0}

Single UE Attach And Send Traffic for asyslog check
    [Arguments]    ${ul_tp}=200M    ${dl_tp}=1500M    ${duration}=4500    ${pci}=817    ${i}=1
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[${i}]
    log to console    \n***Prepare UE_0***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
#    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    pci=${pci}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}    duration=${duration}    ue_index=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}    duration=${duration}    ue_index=${0}
    ...                       process_num=5
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60m    ignore_time=0min    ue_index=${0}    check_source=Aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell1}    target_throughput=800    ue_index=${0}
    ...    check_source=Aasyslog
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell1}    target_throughput=30    ue_index=${0}
    ...    check_source=Aasyslog
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${0}
    Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${0}

Reboot cpe for test for T788
    [Arguments]    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}    power_reset=True
