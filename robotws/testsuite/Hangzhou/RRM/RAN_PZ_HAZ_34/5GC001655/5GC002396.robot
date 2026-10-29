*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
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
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${mcs_ip}    ${tl.mcses.ip_addr}
${mcs_model}    ${tl.mcses.model}
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

@{beam_set_16D8U_horizontal}   -50.6   -50.6   -50.6   -50.6   -10.5   -10.5   -10.5   -10.5   10.5   10.5   10.5   10.5
...   50.6   50.6   50.6   50.6
@{beam_set_16D8U_vertical}   95.9   95.9   89.1   89.1   100.8   100.8   107.4   107.4   105.7   105.7   86.3   86.3
...   95.9   95.9   102.4  102.4
${tshark_path}    /usr/bin/tshark
@{num1}    0    1    2    3
@{num2}    4    5    6    7
@{num3}    0    2

@{check_print}    ERR/

*** Test Cases ***
[1]5GC002396_B_01_eCPRI_DBF_SA_TDD_FR1_TX_power_mode1_for_PC2
    [Tags]    CRT
    [Setup]    Case Setup
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/5GC002396.xml
    Run Keyword And Continue On Failure    Check for unexpected alarms
    #Qcom UE Attach And Send Traffic
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup for COAM
    Connect to gnb coam via ssl
    robot_common_operations.Common Suite Setup

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    check pdl after sw update    download_dir=${TS_CASE_LOG_PATH}
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Qcom UE Attach And Send Traffic
    ${ue_type}    Get UE type    ue_index=${8}
	${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[0]
    log to console    \n***Prepare UE_8***
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${8}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${8}
    sleep    5s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${8}
    sleep    5s
	#power_ue.UE Attach    ue_type=${ue_type}    ue_index=${8}
    #power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=1500M    duration=${duration}    ue_index=${8}
    #power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=150M    duration=${duration}    ue_index=${8}
    #sleep    5min
    #Check counter qualcomm    count=M55156C00001
    #Run keyword and ignore error    Check DL UL Throughput On Site    cells=${cell1}    dl_target=1500    ul_target=150
    #Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${8}
	#Run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${8}

Check DL UL Throughput On Site AEHC
    [Arguments]    ${dl_target}=1300    ${ul_target}=0
	${cells}    Get NRcellid list
	${cell}    Create list    ${cells}[0]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Check counter
    [Arguments]    ${count}    ${count_path}=${None}
    ${counter}    Check BTS Counters via webUI    counter_id=${count}    count_path=${count_path}
    should be true    ${counter}[-1]>=${1} or ${counter}[-2]>=${1}

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}    timeout=400
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Check DL UL Throughput On Site
    [Arguments]    ${cells}    ${dl_target}=2700    ${ul_target}=120
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cells}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cells}    target_throughput=${ul_target}
