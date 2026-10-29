*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   this is a robot case about CB008242-FG
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
# ${DEBUGMODE}      ${True}
${PA_MaxValue}    ${60}
${PA_NormalValue}    ${50}
${PA_MediumValue}    ${35}
${PA_MinValue}    ${0}
${ChangePA_MinValue}    ${20}
${PASwap_MIN_Value}    ${10}
${UE_IP}                 10.107.74.42
${MRBTSID}               11688
${NRBTSID}               11688
${spark_iperf_server}      10.108.233.142
&{fault_4527}              faultId=${4527}
&{fault_4602}              faultId=${4602}
&{fault_4741}              faultId=${4741}
&{fault_61618}             faultId=${61618}
&{fault_4001}              faultId=${4001}
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
...    &{fault_4001}
${8242_flag}               actUacAuto
${adminState}              administrativeState
${dist_name}              MRBTS-11688/NRBTS-11688
${dist_nameF1}            MRBTS-11688/NRBTS-11688/NRCELL-1
${MOC_list1}                MRBTS-11221/LNBTS-11221/LNCEL-21/SIB-0
${MOC_list2}                MRBTS-11221/LNBTS-11221/LNCEL-41/SIB-0
*** Test Cases ***
#Upgrade
#    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
#    Run Feature Case
#    [Teardown]    TL Suite Teardown
CB008242-SR_G_04_01 actUacAuto online modification
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008242_caseG4    SWCONFIG_10_5_UTESRAN001T11688
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    AT.UE Attach
    Send And Cap DL Traffic    8.00M
    Sleep    60s
    Check auto UAC for BTS0
#    expected_alarms FaultID7533
    feature flag change commission
    sleep    60s
#    expected_no FaultID7533
    Check no auto UAC for BTS0

CB008242-SR_G_04_01 actUacAuto online modification without BBPooling
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008242_caseG4_1    SWCONFIG_10_5_UTESRAN001T11688
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    AT.UE Attach
    Send And Cap DL Traffic    8.00M
    Sleep    60s
    Check auto UAC for BTS0
#    expected_alarms FaultID7533
    feature flag change commission
    sleep    60s
#    expected_no FaultID7533
    Check no auto UAC for BTS0

CB008242-SR_F_01_01 SgNBAddition rejections due to auto UAC broadcast in SIB1
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB008242_caseF1    SWCONFIG_10_5_UTESRAN001T11688
    lock NR cell
    Sleep    15s
    Initial Pcell PA case3     #low single for Pcell
    Start Multi Bts Log
    AT.UE Attach
    Sleep    15s
    Run Keyword And Ignore Error     Send And Cap DL Traffic    8.00M
    Add SgNB cell PA
    Sleep    10s
    Check EN-DC State for BTS1
    Check no activated auto UAC for BTS0
    Sleep    60s
    Disable LTE cell

*** Keywords ***
Initial Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${PA_NormalValue}

Initial Pcell PA case3
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${ChangePA_MinValue}

Add SgNB cell PA    #only NR cell enable
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${10}    gnb_id=${0}    value=${ChangePA_MinValue}

Add Scell PA    #only NR cell enable
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${7}    gnb_id=${0}    value=${ChangePA_MinValue}
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PASwap_MIN_Value}
    Modify Attenuation For One RRU Of One Site    ru_id=${11}    gnb_id=${0}    value=${ChangePA_MinValue}

feature flag change commission
    Wait Until Keyword Succeeds    3m    1m    COAM_Admin.Login    alias=commission
    ${dict}=    create dictionary    parameterName=${8242_flag}
    ...                              operation=update
    ...                              value=${false}
    @{parameter_list}    Create List    ${dict}
    coam_admin.perform_object_recommissioning
    ...    dist_name=${dist_name}
    ...    parameter_delta_list=${parameter_list}    operation=update    connection=commission
    [Teardown]    COAM_Admin.Logout    connection=commission

lock NR cell
    [Arguments]   ${bts_index}=0
    @{para_list}   Create List   administrativeState
    @{value_list}   Create List   Locked
    @{mo_list}   Create List   MRBTS-11688/NRBTS-11688/NRCELL-1
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}


Check auto UAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a startUacBarringTimer | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    startUacBarringTimer

Check no auto UAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a UAC | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    Stop

Check no activated auto UAC for BTS${i}
    Log To Console    Check start auto uac
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a UAC | grep -av grep
    ...    connection=BTS${i}_VM
    Should Not Contain    ${ret}    startUacBarringTimer

Disable LTE cell
    [Arguments]   ${bts_index}=1
    @{para_list}   Create List   cellBarred
    @{value_list}   Create List   barred
    @{mo_list}   Create List   ${MOC_list1} 	 ${MOC_list2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

expected_alarms FaultID7533
    &{expected_alarms}        Create Dictionary    faultId=7533    faultName=Automatic Unified Access Control Barring is active
    @{expected_list}          Create List     ${expected_alarms}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=gnb    bts_index=0
    ...                          expected_alarms=${expected_list}
    Should Be True       ${res}[flag_expect_alarm]

expected_no FaultID7533
    &{expected_alarms}        Create Dictionary    faultId=7533    faultName=Automatic Unified Access Control Barring is active
    @{expected_list}          Create List     ${expected_alarms}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=gnb    bts_index=0
    ...                          expected_alarms=${expected_list}
    Should Not Be True       ${res}[flag_expect_alarm]

Check ScellToRelease
    Log To Console    Check remoteScellToRelease
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a remoteSCellToAddList | grep -av grep
    Should Contain    ${ret}     "nrCellIdentity":191496195,"sCellIndex":2

Check EN-DC State for BTS${i}
    Log To Console    Check EN-DC State
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a X2AP_SGNB_RECONFIGURATION_COMPLETE | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    X2AP_SGNB_RECONFIGURATION_COMPLETE


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
    [Arguments]    ${tput}=8.00M
    Connect All VM
    # ${ue_ip}    ADB.Get UE IP
    ${dl_server1}    Connect To IperfServer From Appservers
    Start DL traffic By Iperf    time=360    traffic=${tput}    dl_server=${dl_server1}
    ...    DL_port=${5001}
    sleep   1s
    sleep   1s

Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword And Ignore Error    AT.Prepare UE
#    Run Keyword And Ignore Error    AT.reboot UE
#    Run Keyword And Ignore Error    sleep     50s
Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    sleep     5s
    Run Keyword And Ignore Error    Stop UL Traffic
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${5001}
    Run Keyword And Ignore Error    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    Disable LTE cell
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local
