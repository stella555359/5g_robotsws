*** Settings ***
Documentation     author: Bijiajian
...               contact: Jiajian.bi@nokia-sbell.com
...               squad group: SG_02
Suite Setup       Common Suite Setup for COAM
Suite Teardown    Common Suite Teardown
Force Tags        5G_RRM    QCD_MN_RAN    QCP_RAN_ST
...    PY36
Library           OperatingSystem
Library           Collections
Library           BuiltIn
Library           String
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/bip_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/Resource_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          Resources/1347_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/topyoung.robot
Resource          Resources/common_keyword_RRM_SG2.robot

*** Variables ***
${mcs_ip}    ${tl.mcses[0].ip_addr}
${mcs_model}    ${tl.mcses[0].model}
${server_port}    ${tl.mcses[0].port}
${tmp_swconfig_dir}    /home/ute/Downloads/SCF/swconfig.txt
${TS_LOG_PATH_BASE}    ${OUTPUT DIR}/Case_Logs

${scf_path}    /home/ute/Downloads/SCF

${scf_path_common}     /home/ute/Downloads/SCF/common.xml
@{beam_set_horizontal}   -50.6   -50.6   -50.6   -50.6   -10.5   -10.5   -10.5   -10.5   10.5   10.5   10.5   10.5
...   50.6   50.6   50.6   50.6
@{beam_set_vertical}   95.9   95.9   89.1   89.1   100.8   100.8   107.4   107.4   105.7   105.7   86.3   86.3
...   95.9   95.9   102.4  102.4
${tshark_path}    /usr/bin/tshark
@{num}    0    2
@{command}    at+gtcelllock=1,1,0,518910,181,1,5041    at+gtcelllock=1,1,0,529950,182,1,5041


${UL_THROUGHPUT}    100M
${DL_THROUGHPUT}    1000M
${UL_EXPECT}    50
${DL_EXPECT}    500

@{check_print}    ERR/

*** Test Cases ***
[1]CB009359-J_02_General_SiSo_Auto_RF_lock_unlock_concurrent_mode_NR1CC_16D8U_100M_LTE3CC_16D16U_3x20M
    [Tags]    CRT    CB009359
    [Setup]    Case Setup
#    Run keyword and ignore error    MCS Set angle    horizontal_set=${beam_set_horizontal}    vertical_set=${beam_set_vertical}
#    Setup MCS    server_ip=${mcs_ip}    server_port=${server_port}    vendor=TOPYOUNG
#	...    model=${mcs_model}    frequency=${None}
#	Set Odd Attenuations    attenuation=${50}    begin_input_port=${1}    end_input_port=${32}    output_port=${2}
    Recover swconfig file
    AlarmWatchdog.add_allow_alarms    fault_id=16
    AlarmWatchdog.add_allow_alarms    fault_id=61631
    Reload Case SCF and Commission    scf_file=${scf_path}/${version}/CB009359_J.xml
#    Common UE Attach    ue_index=1    power_reset=true
#    sleep    3s
#    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=1    send_traffic=200MKbits/sec
#    ...    send_duration=1200
#    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=1    send_traffic=2000MKbits/sec
#    ...    send_duration=1200
#    Common UE Attach    ue_index=2    power_reset=true
#    sleep    3s
#    Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=2    send_traffic=200MKbits/sec
#    ...    send_duration=1200
#    Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=2    send_traffic=2000MKbits/sec
#    ...    send_duration=1200
#    sleep    3s
    Reboot cpe for test    ue_index=${9}
    Sleep    5min
    UE Attach and capture bip check tuput      throughput_ul=${UL_THROUGHPUT}
    ...                           throughput_dl=${DL_THROUGHPUT}
    ...                           target_throughput_ul=${UL_EXPECT}
    ...                           target_throughput_dl=${DL_EXPECT}
#    Run keyword and ignore error    Check DL UL Throughput On Site
#    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${1}    check_traffic=1300
#    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${2}    check_traffic=1300
    Check BIP Log 16D8U
    [Teardown]    Case Teardown

[1]CB009359-G
    [Tags]    CRT    CB009359
    [Setup]    Case Setup
#    MCS Set angle    horizontal_set=${beam_set_horizontal}    vertical_set=${beam_set_vertical}
    Recover swconfig file
    Reload Case SCF and Commission    scf_file=${scf_path}/CB009359_G.xml
    Multi UE Attach And Send Traffic cell1
    Common Capture BIP log and download
    Run Keyword And Continue On Failure    Check DL UL Throughput On Site
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${0}    check_traffic=1300
    Run keyword and ignore error    Common UE Check DL Tput    ue_index=${2}    check_traffic=1300
    Check BIP Log 16D8U
    [Teardown]    Case Teardown unlock band

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
    robot_common_operations.Common Case Setup
    Set Test Variable     ${version}     ${result}[0]

Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Case Teardown unlock band
    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure    Check for unexpected alarms
    Run Keyword And Continue On Failure    Save Coam Snapshot
#    Run keyword and ignore error    Unlock cell band
    Run keyword and ignore error    COAM Teardown gnb connections
    Run keyword and ignore error    CI_interface.Common Case Teardown

Reload Case SCF and Commission
    [Arguments]    ${scf_file}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Multi UE Attach And Send Traffic
    [Arguments]    ${send_traffic_ul}=50MKbits/sec    ${send_traffic_dl}=500MKbits/sec    ${send_duration}=3600    ${num}=1
    FOR    ${ue_no}    IN RANGE    ${num}
        Common UE Attach    ue_index=${ue_no}    power_reset=true
        sleep    3s
        Run Keyword And Continue On Failure    Common UE Send UL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_ul}
        ...    send_duration=${send_duration}
        Run Keyword And Continue On Failure    Common UE Send DL Traffic    ue_index=${ue_no}    send_traffic=${send_traffic_dl}
        ...    send_duration=${send_duration}
    END

Unlock cell band
    FOR    ${ue_no}    IN    @{num}
        ${ue_type}    Get UE type    ue_index=${ue_no}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=true
        ${apn_result}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=at+gtcelllock=0
        ${apn_result1}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=AT+GTACT=10
        ${apn_result1}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=AT+CFUN=15
    END

Multi UE Attach And Send Traffic cell1
    [Arguments]    ${send_traffic_ul}=200MKbits/sec   ${send_traffic_dl}=2000MKbits/sec   ${send_duration}=900
    ...    ${attach_mode}=5G_SA    ${power_reset}=true
    FOR    ${ue_no}    IN    @{num}
        ${ue_type}    Get UE type    ue_index=${ue_no}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}
        ${result}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=${command}[0]
        ${result1}    spark.send_at_command_on_ue    ue_alias=UE_${ue_no}    command=AT+CFUN=15
        sleep    30s
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}
        ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_no}    power_reset=${power_reset}    attach_mode=${attach_mode}
        Run keyword and ignore error    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
        sleep    3s
        Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_no}
        ...    throughput=${send_traffic_ul}   duration=${send_duration}   apn_address=dxdata2    connection_type=current
        Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_no}
        ...    throughput=${send_traffic_dl}    duration=${send_duration}    apn_address=dxdata2
    END

Check counter 16D8U
    ${counter1}    Check BTS Counters via webUI    counter_id=M55308C34023
    ${counter2}    Check BTS Counters via webUI    counter_id=M55308C34019
    ${counter3}    Check BTS Counters via webUI    counter_id=M55308C34015
    should be true    ${counter1}[-1]>=${1} or ${counter1}[-2]>=${1}
    should be true    ${counter3}[-1]>=${1} or ${counter1}[-2]>=${1}

Check DL UL Throughput On Site
    [Arguments]    ${dl_target}=1200    ${ul_target}=120
    ${cells}    Get NRcellid list
    ${cell}    Create list    ${cells}[0]
    ${log_path}    power_ue.Collect Tput    ue_type=huawei    duration=1m    ignore_time=0min
    power_ue.Check Tput    ue_type=huawei    direction=DL    log=${log_path}    cells=${cell}    target_throughput=${dl_target}
    power_ue.Check Tput    ue_type=huawei    direction=UL    log=${log_path}    cells=${cell}    target_throughput=${ul_target}

Load BIP Log
    [Arguments]    ${bip_file}=${bip_log_path}     ${alias}=CB9359
    ${packets}    pcap.load_pcap_file   pcap_file=${bip_file}
	...                                 tshark_path=${tshark_path}
    ...                                 command_template={tshark_path} -r ${bip_file} -Y 'dldata_pdschsendreql1sw' -T pdml
    ...                                 alias=${alias}
    [Return]   ${packets}

Check BIP Log 16D8U
    Load BIP Log
    ${value_layer}    Get value from Bip Log    field_name=DlData_PdschGrantL1sw.numOfLayers    pcap_parser=CB9359
    ${value_subcell}    Get value from Bip Log    field_name=_3gpp.subcellid    pcap_parser=CB9359
    Should Contain    ${value_layer}    1
    Should Contain    ${value_subcell}    0    1

UE Attach and capture bip check tuput
    [Arguments]  ${throughput_ul}    ${throughput_dl}    ${target_throughput_ul}    ${target_throughput_dl}
    ${cells}    Get NRcellid list
    ${cell1}    Create list    ${cells}[0]
    log to console    \n***Prepare UE_1***
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${9}
#    Wait Until Keyword Succeeds    2min    5s     power_ue.Prepare UE     ue_type=${ue_type}    ue_index=${9}
    ${5Grach_ed}     power_ue.UE Attach     ue_type=${ue_type}    ue_index=${9}    pci=181
    power_ue.Start traffic     ue_type=${ue_type}     direction=ul     throughput=${throughput_ul}     duration=2000    process_num=5
    ...    ue_index=${9}
    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${throughput_dl}     duration=2000
    ...    ue_index=${9}
    Common Capture BIP log and download
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
