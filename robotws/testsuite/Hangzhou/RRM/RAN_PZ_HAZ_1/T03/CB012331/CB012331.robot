*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   this is a robot case about CB012118
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIO2_AHFIB2_AHLOB2_AEHC_AQQL
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
#    ${DEBUGMODE}      ${True}
${PA_MaxValue}           ${60}
${PA_MinValue}           ${0}
${PA_60}          ${60}
${PA_50}          ${50}
${PA_35}          ${35}
${PA_0}           ${0}
${PA_30}          ${30}
${PA_25}          ${25}
${PA_10}          ${10}
${PA_15}          ${15}
${UE_IP}                 10.107.74.42
${MRBTSID}               11688
${NRBTSID}               11688
${spark_iperf_server}      10.56.198.156
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
&{fault_4001}              faultId=${4001}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_4001}

*** Test Cases ***
#Upgrade
#    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#    Run Feature Case
#    [Teardown]    TL Suite Teardown
CB012331-SR_06_01 Inter-PLMN CA with Measurement based Scell change in 4CC
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB012331    SWCONFIG_10_5_UTESRAN001T11688
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    Sleep    10s
    Add Scell PA
    Sleep    3s
    Start UL Traffic
    Send And Cap DL Traffic    1200.00M
    Sleep    3s
    Change Pcell PA to add FDD Scell
    Sleep    40s
    Check PCI range 4    #PCI in allowedCellsToAddModList
    Check useWhiteCellList320 as false
    Check FDDSCellToAddList
    Change Pcell PA to add TDD Scell
    Sleep    5s
    Check PCI range 5    #PCI not in allowedCellsToAddModList
    Check useWhiteCellList512 as true
    Check useWhiteCellList640 as false
    Check TDDSCellToAddList
    Stop All Bts Log
    AT.UE Detach
    Sleep    17 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Latest PM File Of case2 counters    starttime=${start_time}    endtime=${end_time}

CB012331-SR_05_01 Inter-PLMN CA with Measurement based Scell swap 4CC
    [Documentation]    author: Zhang Sijia    ...interaction with LTE5003
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB012331
    Initial Pcell PA case3     #low single for Pcell
    Start Multi Bts Log
    ${start_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    ${start_time}    Subtract Time From Date    ${start_time}    10 minutes
    AT.UE Attach
    Add Scell PA
    Sleep    3s
    Start UL Traffic
    Send And Cap DL Traffic    1200.00M
    Sleep    15s
    Check PCI range 4
    Check PCI range 5
    Check useWhiteCellList512 as true
    Check useWhiteCellList320 as false
    Check useWhiteCellList640 as false
    Check TDDSCellToAddList
    Check FDDSCellToAddList
    TDD Scell Swap
    Sleep    20s
    Wait Until Keyword Succeeds    8x    4min    Check TDDSCellSwap
    Check useWhiteCellList40 as false
    Check PCI range 2
    Stop All Bts Log
    AT.UE Detach
    Sleep    17 min    reason=wait for counter ready
    ${end_time}    Get Current Date    time_zone=UTC    result_format=%Y-%m-%d %H:%M:%S
    Check Latest PM File Of case3 counters    starttime=${start_time}    endtime=${end_time}

*** Keywords ***
Initial Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_30}

Initial Pcell PA case3
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_0}

Add Scell PA    #only NR cell enable
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${7}    gnb_id=${0}    value=${PA_30}
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_10}
    Modify Attenuation For One RRU Of One Site    ru_id=${11}    gnb_id=${0}    value=${PA_30}

Change Pcell PA to add FDD Scell
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_15}

Change Pcell PA to add TDD Scell
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_MinValue}

TDD Scell Swap
    Log To Console    Attach UE To GNB
    Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${PA_0}

Change case3 PA    #only LTE cell enable
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${2}    gnb_id=${0}    value=${PA_50}

Check PCI range 2
    Log To Console    Check PCI range2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "createAllowedCellsToAddModList" | grep -av grep
    Should Not Contain    ${ret}     \>2<

Check PCI range 4
    Log To Console    Check PCI range4
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "createAllowedCellsToAddModList" | grep -av grep
    Should Contain    ${ret}     \>4<

Check PCI range 5
    Log To Console    Check PCI range5
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "createAllowedCellsToAddModList" | grep -av grep
    Should Contain    ${ret}     \>5<

Check useWhiteCellList40 as false
    Log To Console    Check useWhiteCellList40 exist
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a '"40 ms", "reportOnLeave' | grep -av grep
    Should Not Contain    ${ret}     "useWhiteCellList": true

Check useWhiteCellList512 as true
    Log To Console    Check useWhiteCellList512ms exist
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a '512 ms", "reportOnLeave' | grep -av grep
    Should Not Contain    ${ret}     "useWhiteCellList": false

Check useWhiteCellList320 as false
    Log To Console    Check useWhiteCellList320ms not exist
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -e '320 ms", "reportOnLeave' | grep -av grep
    Should Not Contain    ${ret}     "useWhiteCellList": true

Check useWhiteCellList640 as false
    Log To Console    Check useWhiteCellList640ms not exist
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -e '640 ms", "reportOnLeave' | grep -av grep
    Should Not Contain    ${ret}     "useWhiteCellList": true

Check FDDSCellToAddList
    Log To Console    Check FDDScelladdition
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'Increase Ca Relation for pcell' | grep -av grep
    Should Contain    ${ret}     191496195

Check TDDSCellToAddList
    Log To Console    Check TDDScelladdition
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a 'Increase Ca Relation for pcell' | grep -av grep
    Should Contain    ${ret}     191496194

Check TDDSCellSwap
    Log To Console    Check TDDSCellSwap to cell 2
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "CandidateScellParams's PCI in MR" | grep -av grep
    Should Contain    ${ret}     191496197

Check ScellToRelease
    Log To Console    Check remoteScellToRelease
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a remoteSCellToAddList | grep -av grep
    Should Contain    ${ret}     "nrCellIdentity":191496195,"sCellIndex":2

Check Latest PM File Of case2 counters
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55118C06506    M55118C06507
    COAM_Admin.Login    bts_host=10.106.230.21
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-1
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55118C06506]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M55118C06507]
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}>=${1}

Check Latest PM File Of case3 counters
    [Arguments]    ${starttime}    ${endtime}
    ${counters}    Create List    M55118C10501    M55118C10502
    COAM_Admin.Login    bts_host=10.106.230.21
    ${value1}    Get Pm Counters Of Period    counters=${counters}
    ...    start_time=${start_time}
    ...    end_time=${end_time}
    ...    cell_id=NRCELL-1
    Log to console    ${value1}
    ${sum_1_val}    Summary Counter Value of dictionary    ${value1}[M55118C10501]
    ${sum_2_val}    Summary Counter Value of dictionary    ${value1}[M55118C10502]
    Should be true    ${sum_1_val}>=${1}
    Should be true    ${sum_2_val}>=${1}

Summary Counter Value of dictionary
    [Arguments]     ${time_value}
    ${S}    Set Variable
    ${value_list}    Get dictionary Values   ${time_value}
    FOR    ${i}    IN    @{value_list}
        ${value}    Convert To Integer     ${i}
        ${S}     evaluate     ${S}+${value}
    END
    [Return]    ${S}

Start UL Traffic
    [Arguments]    ${tput}=50M    ${tport}=5001    ${server_ip}=${spark_iperf_server}
    Connect All VM
    ADB.Start Traffic    tput_type=UL
    ...    server_ip=${server_ip}
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0
    ...    client_iperf_path=/data/iperf
    ...    tput_port=${tport}
    ...    tput_value=${tput}
    ...    tput_time=300s
    #Sleep    90s

Stop UL Traffic
    Connect All VM
    ADB.Stop Traffic     tput_type=UL
    ...    iperf_port=50002
    ...    server_connection=BTS0_VM
    ...    client_connection=cpc_0

Send And Cap DL Traffic
    [Arguments]    ${tput}=500.00M
    Connect All VM
    # ${ue_ip}    ADB.Get UE IP
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=360    traffic=${tput}    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep   2s

Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_60}
    Run Keyword And Ignore Error    AT.Prepare UE
#    Run Keyword And Ignore Error    AT.reboot UE
#    Run Keyword And Ignore Error    sleep     50s
Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    sleep     5s
    Run Keyword And Ignore Error    Stop UL Traffic
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${5001}
    Run Keyword And Ignore Error    Init Attenuation All Max    max_value=${PA_60}
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local
