*** Settings ***
Documentation
...   author: Andy
...   contact: fan-andy.yu@nokia-sbell.com
...   this is a robot case about CB009189
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIBL_ABIAB3_FRPA_FRHF_AHEGB_FRHF-ASIBL_ABIL_AEQE
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${93}
${PA_NormalValue}        ${1}
${PA_MinValue}           ${0}
${Handover_MAX_Value}    ${60}
${Handover_MIN_Value}    ${0}
${UE_IP}                 10.107.74.42
&{fault_1932}              faultId=${1932}
&{fault_1933}              faultId=${1933}
&{fault_6327}              faultId=${6327}
&{fault_6203}              faultId=${6203}
@{Ohter_Allow_Alarms}      &{fault_1932}    &{fault_1933}    &{fault_6327}    &{fault_6203}


*** Test Cases ***
# Upgrade
#     [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#     Run Feature Case
#     [Teardown]    TL Suite Teardown

CB009189-A_01_NSA_TDD_Successful admission control for specific SR period configured DRB addition for non-VoNR UEs initial access
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB009189
    AT.Prepare UE
    Start Multi Bts Log
    Adjust signal of GNB10053
    Attach UE By AT
    sleep    30s
    Stop All Bts Log
    # Check CB009189 case2 on BTS1

CB009189-A_02_SA_Successful admission control for specific SR Period
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB009189    CB009189_A
    AT.Prepare UE
    Start Multi Bts Log
    Adjust signal of GNB10053
    Attach UE By AT
    sleep    30s
    Stop All Bts Log
    # Check CB009189 case2 on BTS1

CB009189-D_17_Successful setup of 5QI-80 non GBR QoS flow with Initial Context Setup Request
    [Documentation]    author:tengfei.chen
    [Tags]    10_5_UTESRAN001T2298    SCF_10_5_UTESRAN001T2298_CB009189_case17
    Start Multi Bts Log
    Attach UE To GNB
    Modify UE APN To Mdrb
    ADB.UE Detach
    ADB.UE Attach
    sleep    90s
    # DL And UL Traffic
    # ${filter_values}    Check 5QI80 on BTS1
    # 5QI80 Traffic Check     filter_values=${filter_values}
    # Run Keyword And Ignore Error    5QI80 Traffic Check DL     filter_values=${filter_values}
    # [Teardown]    Run keywords    Case17 Teardown    AND    Common MultiBTS Test Teardown For RRM

*** Keywords ***
Case17 Teardown
    Run Keyword And Ignore Error    Modify UE APN To stdata1
    Case Teardown

Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # # Run Keywords    Commission Full SCF For One GNB    bts_index=${1}    scf_file_path=${SCF_DIR_PATH}/10_5_UTESRAN001T2298/GLODEN_BTS1.xml    AND
    # # ...      Wait One GNB Status    bts_index=${1}
    # Run Keywords    Commission Golden SCF For One GNB    bts_index=${1}    AND
    # ...      Wait One GNB Status    bts_index=${1}
    Run Keyword And Ignore Error    Disconnect All VM

Adjust signal of GNB10053
    Log To Console    Attach UE To ENB
    # Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_NormalValue}
    # Modify Attenuation For One RRU Of One Site    ru_id=${1}    gnb_id=${0}    value=${PA_NormalValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

Attach UE To GNB
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${1}    value=${PA_NormalValue}

Check ENB Attach State
    Log To Console    Check ENB Attach State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH | grep -av grep
    Should Contain    ${ret}    UEC_UEM_INITIAL_CONTEXT_SETUP_ATTACH

Check EN-DC State
    Log To Console    Check ENB Attach State
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE

Check EN-DC CA Mode
    Sleep    80s
    ${ret}    OperatingSystem.Run    cat ${BTS0_LOG_PATH} |grep -E "${CA_CheckPoint}" | grep -av grep
    ${matches}    Get Regexp Matches    ${ret}    ${CA_CheckPoint}
    Should Not Be Empty    ${matches}

# Start Multi Bts Log
#     Prepare BTSLite For Btslog
#     ${log_start_time}    Get TimeStamp With Date
#     Start BTSLite For Btslog On VM    vm_index=0    btslog_name=syslog_${log_start_time}.log
#     Start BTSLite For Btslog On VM    vm_index=1    btslog_path=/home/ute
#     ...    btslog_name=remote_syslog_${log_start_time}.log

Stop All Bts Log
    Stop All BTSLog And Download to Local

# Check CB009189 case2
#     Log To Console    Check ENB Attach State
#     ${ret}    OperatingSystem.Run
#     ...    command=cat ${BTS0_LOG_PATH} |grep -a ServiceAware | grep -av grep
#     Should Contain    ${ret}    preUpdateSrPoolForServiceAwareDrbSetup: 10

# Check CB009189 case2 on BTS${i}
#     ${ret}    OperatingSystem.Run
#     ...    command=cat ${BTS${i}_LOG_PATH} |grep -a ServiceAware | grep -av grep
#     Log    ${ret}
#     Should Contain    ${ret}    preUpdateSrPoolForServiceAwareDrbSetup: 10

Check CB009189 case2 on BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "ServiceAware" | grep -av grep
    Should Contain    ${ret}    serviceAwareSrPeriod\: 10

Modify UE APN To Mdrb
    ADB.Prepare UE
    ADB.Reboot UE
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Change APN    apn=mdrb.nokia.com

Modify UE APN To stdata1
    Log to Console    Start to set apn
    Sleep    10s
    Qualcomm.Change APN    apn=stdata1

Check 5QI80 on BTS${i}
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a "qosId\=80" | grep -av grep
    Should Contain    ${ret}    qosId\=80
    ${matches}    Get Regexp Matches    ${ret}    lcId\=\\d+
    Log    ${matches[-1]}
    ${matches_nums}    Create List
    FOR    ${match}    IN    {matches}
        ${matches_num}    Get Regexp Matches     ${matches[-1]}    \\d+
        Append to List    ${matches_nums}    ${matches_num}[0]
    END
    [Return]    ${matches_nums}

DL And UL Traffic
    Connect All VM
    gnb_tool.prepare_gnb_tool
    gnb_tool.start_to_capture_tti_log_with_gnb_tool
    ...    log_dire=${TEST_LOG_DIRECTORY}
    ...    host=${BTS0_PC_INFO.Host}
    ...    dest_ip=10.108.231.24
    ADB.Start Traffic    tput_type=DL
    ...    server_ip=${BTS0_PC_INFO.Host}
    ...    client_connection=BTS0_VM
    ...    tput_value=20M
    ...    tput_time=120s
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${BTS0_PC_INFO.Host}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=50002
    ...    tput_value=10M
    ...    tput_time=120s
    Sleep    90s
    ADB.Stop Traffic     tput_type=DL
    ...    iperf_port=50001
    ...    client_connection=BTS0_VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ${log_path}    gnb_tool.stop_tti_log_with_gnb_tool
    Set Test Variable    ${log_path}     ${log_path}
    Stop All Bts Log

5QI80 Traffic Check
    [Arguments]    ${filter_values}
    csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=ul
    ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=lcid
    ...    filter_value=${filter_values}    parameter=rcvdBytes
    Should Not Be Empty    ${rows}
    ${result}    csv_analysis.get_value_list_of_rows
    ...    values=${rows}
    ...    formulae=sum
    Should Be True    ${result}!=${0}
    Log To Console    ${result}

5QI80 Traffic Check DL
    [Arguments]    ${filter_values}
    csv_analysis.prepare_csv_parser    filepath=${log_path}    traffic_type=dl
    ${rows}    csv_analysis.filter_content_by_parameters    filter_parameter=lcid
    ...    filter_value=${filter_values}    parameter=scheduledBytesPerBearer
    Should Not Be Empty    ${rows}
    ${result}    csv_analysis.get_value_list_of_rows
    ...    values=${rows}
    ...    formulae=sum
    Should Be True    ${result}!=${0}
    Log To Console    ${result}

