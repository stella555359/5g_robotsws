*** Settings ***
Documentation
...   author: Andy
...   contact: fan-andy.yu@nokia-sbell.com
...   this is a robot case about CB007742_TMO
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
@{Ohter_Allow_Alarms}      &{fault_4527}    &{fault_4602}    &{fault_4741}    &{fault_61618}
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


CB007742-SR_22_Handover to 5G-SA non EN-DC case
    [Documentation]    author: Yu Fan-andy
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB007742
    Start Multi Bts Log
    Enable LTE CELL 21
    AT.UE Attach
    Sleep    15s
    Enable NR CELL 4
    Sleep    10s
    Trigger LTE HO to NR
    Sleep    15s
    Check HO type for BTS1

CB007742-SR_27_New PM counter update for handover from LTE to NR without VoLTE
    [Documentation]    author: Yu Fan-andy
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB007742
    # ${rule1}    Catenate
    # ...    Distname: MRBTS-10787/NRBTS-11436;
    # ...    Counter: M8016C75;
    # ...    Counter rule: max(M8016C75)>0;
    # # ${rule2}    Catenate
    # # ...    Distname: MRBTS-1/NRBTS-1;
    # # ...    Counter: M55319C16006;
    # # ...    Counter rule: max(M55319C16006)<81000;
    # # ${rule3}    Catenate
    # # ...    Distname: MRBTS-1/NRBTS-1;
    # # ...    Counter: M55319C16006;
    # # ...    Counter rule: latest(M55319C16006)<=40000;
    # # ${rule4}    Catenate
    # # ...    Distname: MRBTS-1/NRBTS-1;
    # # ...    Counter: M55319C16006;
    # # ...    Counter rule: latest(M55319C16006)>33000;
    # # ${rule5}    Catenate
    # # ...    Distname: MRBTS-1/NRBTS-1;
    # # ...    Counter: M55319C16007;
    # # ...    Counter rule: M55319C16007==0;

    # ${rule_list}    Create List    ${rule1}
    # Counter Operation    operation=start_collect_counter
    # ...    product_type=gnb
    # ...    counter_rule=${rule_list}
    Start Multi Bts Log
    Enable LTE CELL 21
    AT.UE Attach
    Sleep    15s
    Enable NR CELL 4
    Sleep    10s
    Trigger LTE HO to NR
    Sleep    15s
    Check HO type for BTS1
    # Counter Check InterRatHO

*** Keywords ***
Enable LTE CELL 21
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MinValue}

Enable NR CELL 4
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${8}    gnb_id=${0}    value=${PA_MinValue}

Trigger LTE HO to NR
    Log To Console    5G PA Change
    Modify Attenuation For One RRU Of One Site    ru_id=${0}    gnb_id=${0}    value=${PA_MediumValue}

Check HO type for BTS${i}
    Log To Console    EHandoverType_InterRatToNr
    ${ret}    csn.execute
    ...    command=cat ${BTS${i}_LOG_PATH} |grep -a EHandoverType_InterRatToNr | grep -av grep
    ...    connection=BTS${i}_VM
    Should Contain    ${ret}    EHandoverType_InterRatToNr

Counter Check InterRatHO
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb    interval=3
    Log To Console    ${value1}

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
