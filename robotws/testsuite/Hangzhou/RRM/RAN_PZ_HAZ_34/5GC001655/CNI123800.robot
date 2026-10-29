*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
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
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/24R3/swconfig_CNI123800.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs
${scf_path}    /home/ute/Downloads/SCF

${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1000M
${UL_EXPECT}    50
${DL_EXPECT}    500

@{check_print}    ERR/

*** Test Cases ***
[1]CNI_123800_A_4_verify TRS allocation when rdTddCsirsOpt on with 1208 _framestruct_non_BBPooling_cell
    [Tags]    CRT    CNI123800
    [Setup]    Case Setup
    Recover swconfig file
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CNI123800.xml
    Common Capture BIP log and download
    Check BIP Log
#    Single UE Attach And Send Traffic
#    Run keyword and ignore error    Check DL UL Throughput On Site
    Reboot cpe for test    ue_index=${9}
    Sleep    5min
    UE Attach and check tuput      throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
    [Teardown]    Case Teardown

*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    check pdl after sw update    download_dir=/home/ute/Downloads

Common Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    COAM Create log directory
    Connect to gnb coam via ssl
    ${build}    Coam Get Active SW Version
    ${result}    String.split string    string=${build}    separator=_
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    #Run keyword and ignore error    Multi UE Detach And Stop Traffic
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Update swconfig file
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${scf_path}/${version}/swconfig_CNI123800.txt    asik_alias=ASIK Master
    Csn.Disconnect    connection=ASIK Master

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup

Single UE Attach And Send Traffic
    [Arguments]    ${send_traffic_ul}=200MKbits/sec    ${send_traffic_dl}=2000MKbits/sec    ${send_duration}=1800    ${ue_no}=1
    Common UE Attach    ue_index=${ue_no}    power_reset=true
    sleep    3s
    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}    send_duration=${send_duration}
    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}    send_duration=${send_duration}

Check DL UL Throughput On Site
    [Arguments]    ${dl_target}=1300    ${ul_target}=130
    ${cells}    Get NRcellid list
    ${cell}    Create list    ${cells}[0]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Load BIP Log
    [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=CNI123800
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...    tshark_path=${tshark_path}
    ...    command_template={tshark_path} -r ${bip_file} -Y 'dldata_csirssendreql1sw and DlData_CsiRsResourceL1sw_t.trsInfo == 1' -T pdml
    ...    alias=${alias}
    [Return]   ${packets}

Check BIP Log
    Load BIP Log
    ${value}    Get value from Bip Log    field_name=_3gpp.slot    pcap_parser=CNI123800
    ${value1}    Get value from Bip Log    field_name=_3gpp.sfn    pcap_parser=CNI123800
	${lenth}    get length    ${value}
    FOR   ${val}   IN   @{value}
        should be true    ${val} == 0 or ${val} == 1 or ${val} == 16 or ${val} == 17
    END
    FOR   ${len}   IN RANGE   ${lenth}
        Run keyword if    ${value}[${len}] == 0 or ${value}[${len}] == 1    should be true    ${value1}[${len}] % 8 == 1
        Run keyword if    ${value}[${len}] == 16 or ${value}[${len}] == 17    should be true    ${value1}[${len}] % 8 == 0
    END

UE Attach and check tuput
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[0]
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${9}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${9}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${9}
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    ...    ue_index=${9}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    ...    ue_index=${9}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m    check_source=Aasyslog    ue_index=${9}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=ul     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_ul}    check_source=Aasyslog
    ...                     ue_index=${9}
    run keyword and continue on failure     power_ue.Check Tput     ue_type=${ue_type}
    ...                     direction=dl     cells=${cell1}    log=${tput_log}
    ...                     target_throughput=${target_throughput_dl}    check_source=Aasyslog
    ...                     ue_index=${9}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=dl    ue_index=${9}
    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul    ue_index=${9}
