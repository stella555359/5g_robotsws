*** Settings ***
Documentation
...   author: Sijia Zhang
...   contact: sijia.zhang@nokia-sbell.com
...   this is a robot case about CB012474-IWK03
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
#${DEBUGMODE}      ${True}
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
${dist_name1}             MRBTS-11688/NRBTS-11688/NRCELL-1
${dist_name2}             MRBTS-11688/NRBTS-11688/LTEENB-\\d+
${MOC_list1}                MRBTS-11221/LNBTS-11221/LNCEL-21/SIB-0
${MOC_list2}                MRBTS-11221/LNBTS-11221/LNCEL-41/SIB-0
${MOC_list3}              MRBTS-11221/LNBTS-11221/LNCEL-21
${Redirect From NR to LTE1}      Trigger the rrcReleaseWithRedirectProcedure for voice fallback
${Redirect From NR to LTE2}      measurementType\:B1Redirection
${Redirect From NR to LTE3}      Setup B1 Redirect Measurement
*** Test Cases ***
CB012474_20_Reattempt of EN-DC Configuration Update procedure with X2 link becoming temporarily unavailable while reattempt timer is running
    [Documentation]    author:Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB012474
    ${rule1}    Catenate
    ...    Distname: MRBTS-11688/NRBTS-11688;
    ...    Counter: M55110C00040;
    ...    Counter rule: max(M55110C00040)>0;
    Start Multi Bts Log
    @{cell_list}=    Create List    1    6
    Change Commission To Lock cell    @{cell_list}
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-11221/LNBTS-11221    bts_index=1
    sleep    3s
    Change Commission To Unlock cell    @{cell_list}
    sleep    60s
    check the alarm 7101 raised
    sleep    3s
    Set x2LinkLock locked in 5G
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-11221/LNBTS-11221    bts_index=1
    sleep    3s
    Set x2LinkLock unlocked in 5G
    sleep    600s
    Check the alarm 7101 cancel

CB012474_21_Multi-frequency band cells which impacts EN-DC Configuration Update procedure and hence interact with 5GC001416
    [Documentation]    author:Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CB012474
    # ${rule1}    Catenate
    # ...    Distname: MRBTS-11688/NRBTS-11688;
    # ...    Counter: M55110C00040;
    # ...    Counter rule: max(M55110C00040)>0;
    # ${rule_list}    Create List    ${rule1}
    # Counter Operation    operation=start_collect_counter
    # ...    product_type=gnb
    # ...    counter_rule=${rule_list}
    Start Multi Bts Log
    @{cell_list}=    Create List    1    6
    Change Commission To Lock cell    @{cell_list}
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-11221/LNBTS-11221    bts_index=1
    sleep    3s
    Change Commission To Unlock cell    @{cell_list}
    sleep    360s
    Set nrConnectModeProfileDN in gNB    dist_name1=MRBTS-11688/NRBTS-11688/NRCELL-1   bts_index=0
    sleep    30s
    check the alarm 7101 raised
    check the alarm 7506 raised
    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-11221/LNBTS-11221    bts_index=1
    sleep    600s
    Check the alarm 7101 cancel
    sleep    3s
    Check the alarm 7506 cancel
    #expected_alarms FaultID7101
    # Counter Check ENDCRATTEMPT

CNI-128069_CB012118_FIM_Robustness_and_Exploratory
    [Documentation]    author: Zhang Sijia
    [Tags]    10_5_UTESRAN001T11688    SCF_10_5_UTESRAN001T11688_CNI128069    SWCONFIG_10_5_UTESRAN001T11688
    Initial Pcell PA     #low single for Pcell
    Start Multi Bts Log
    Run Keyword And Ignore Error    Start Capture Emil Log By VM dcap    bts_index=${0}     product_type=gnb
    Enable LTE cell
    Lock LTE cell
    AT.UE Attach
    Sleep    1s
    Send And Cap DL Traffic    20.00M
    Sleep    4s
    UnLock LTE cell
    Sleep    60s
    AT Operation    start_call    ue_index=0  number=6688
    Sleep    10s
    Check Redirect From NR to LTE    ${Redirect From NR to LTE1}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE2}
    Check Redirect From NR to LTE    ${Redirect From NR to LTE3}
    AT Operation    stop_call    ue_index=0
    Sleep    30s


*** Keywords ***
Initial Pcell PA
    Log To Console    Attach UE To ENB
    Modify Attenuation For One RRU Of One Site    ru_id=${6}    gnb_id=${0}    value=${ChangePA_MinValue}

Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}
    Run Keyword And Ignore Error    AT.Prepare UE
#    Run Keyword And Ignore Error    AT.reboot UE
#    Run Keyword And Ignore Error    sleep     50s
Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${5001}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    Run Keyword And Ignore Error    Stop Emil Log Collection    bts_index=${0}    product_type=gnb
    Run Keyword And Ignore Error    Disable LTE cell
    Run Keyword And Ignore Error    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-11221/LNBTS-11221    bts_index=1
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local

Send And Cap DL Traffic
    [Arguments]    ${tput}=50.00M
    Connect All VM
    ${ueip}=    AT Operation    get    ue_index=0  item=ueip    intf_name=ims
    gnb_tool.prepare_gnb_tool
    ${dl_server1}    Connect To IperfServer From Appservers
    ${ueip}    Start DL traffic By Iperf    time=6000    traffic=${tput}    dl_server=${dl_server1}
    ...    DL_port=${5001}

Change Commission To Lock cell
    [Arguments]    @{cell_list}
    FOR   ${cell_i}    IN    @{cell_list}
        BTS Operation    operation=cell_lock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-${cell_i}    need_verify=yes
    END

Change Commission To Unlock cell
    [Arguments]    @{cell_list}
    FOR   ${cell_i}    IN    @{cell_list}
        BTS Operation    operation=cell_unlock    product_type=gnb    bts_index=0
        ...    distname_id=NRCELL-${cell_i}    need_verify=${False}
    END

check the alarm 7101 raised
    Log To Console    Check EPSFB result
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Activated alarm" | grep -av grep
    Should Contain    ${ret}     7101

Check the alarm 7101 cancel
    Log To Console    Check EPSFB result
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Deactivated alarm" | grep -av grep
    Should Contain    ${ret}     7101

check the alarm 7506 raised
    Log To Console    Check EPSFB result
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Activated alarm" | grep -av grep
    Should Contain    ${ret}     7506
Check the alarm 7506 cancel
    Log To Console    Check EPSFB result
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "Deactivated alarm" | grep -av grep
    Should Contain    ${ret}     7506

Check EPSFB result
    Log To Console    Check EPSFB result
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "ActiveProcedure reset from rrcReleaseWithRedirect" | grep -av grep
    Should Contain    ${ret}     status: Completed

Check Redirect From NR to LTE
    [Arguments]    ${Redirect_From_NR_to_LTE}
    Log To Console    Redirect From NR to LTE
    ${ret}    OperatingSystem.Run
    ...    command=cat ${BTS0_LOG_PATH} |grep -a "${Redirect_From_NR_to_LTE}" | grep -av grep
    Should Contain    ${ret}    ${Redirect_From_NR_to_LTE}

Disable LTE cell
    [Arguments]   ${bts_index}=1
    @{para_list}   Create List   cellBarred
    @{value_list}   Create List   barred
    @{mo_list}   Create List   ${MOC_list1} 	 ${MOC_list2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Enable LTE cell
    [Arguments]   ${bts_index}=1
    @{para_list}   Create List   cellBarred
    @{value_list}   Create List   notBarred
    @{mo_list}   Create List   ${MOC_list1} 	 ${MOC_list2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Lock LTE cell
    [Arguments]   ${bts_index}=1
    @{para_list}   Create List   administrativeState
    @{value_list}   Create List   locked
    @{mo_list}   Create List   ${MOC_list3}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

UnLock LTE cell
    [Arguments]   ${bts_index}=1
    @{para_list}   Create List   administrativeState
    @{value_list}   Create List   unlocked
    @{mo_list}   Create List   ${MOC_list3}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Set x2LinkLock locked in 5G
    [Documentation]    author:Sijia
    [Arguments]   ${bts_index}=0
    @{para_list}   Create List   x2LinkLock
    @{value_list}   Create List   locked
    @{mo_list}   Create List   ${dist_name2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Set x2LinkLock unlocked in 5G
    [Documentation]    author:Sijia
    [Arguments]   ${bts_index}=0
    @{para_list}   Create List   x2LinkLock
    @{value_list}   Create List   unlocked
    @{mo_list}   Create List   ${dist_name2}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Set maxParallelIncX2SetupOrECUOvl0 0 in LTE
    [Documentation]    author:andy
    [Arguments]    ${dist_name}    ${bts_index}=1
    @{para_list}   Create List   maxParallelIncX2SetupOrECUOvl0
    @{value_list}   Create List   0
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}
Set maxParallelIncX2SetupOrECUOvl0 10 in LTE
    [Documentation]    author:andy
    [Arguments]    ${dist_name}    ${bts_index}=1
    @{para_list}   Create List   maxParallelIncX2SetupOrECUOvl0
    @{value_list}   Create List   10
    @{mo_list}   Create List   ${dist_name}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Set nrConnectModeProfileDN in gNB
    [Documentation]    author:Sijia
    [Arguments]    ${dist_name1}    ${bts_index}=0
    @{para_list}   Create List   nrConnectModeProfileDN
    @{value_list}   Create List   NRCONNECTMODE_PROFILE-1
    @{mo_list}   Create List   ${dist_name1}
    ${out}   Parameter Operation    operation=parameter_update   product_type=gnb   para_list=${para_list}
    ...      value_list=${value_list}   mo_list=${mo_list}    bts_index=${bts_index}
    Log To Console    paramter update result: ${out}

Counter Check ENDCRATTEMPT
    ${value1}    Counter Operation    operation=collect_counter_and_check_rule
    ...    product_type=gnb    interval=3
    Log To Console    ${value1}


expected_alarms FaultID7101
    &{expected_alarms}        Create Dictionary    faultId=7101    faultName=gNB CpCell configuration update failure
    @{expected_list}          Create List     ${expected_alarms}
    ${res}    Alarm Operation    operation=check_active_alarms    product_type=gnb    bts_index=0
    ...                          expected_alarms=${expected_list}
    Should Be True       ${res}[flag_expect_alarm]
