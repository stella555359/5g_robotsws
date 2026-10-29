*** Settings ***
Documentation
...   author: Andy
...   contact: fan-andy.yu@nokia-sbell.com
...   this is a robot case about CB012474
Resource          ../Resources/common_resource.robot
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CDRT
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_CA_ASIL_ABIP2_AZHM_AHEGB-ASILR_ABIP2_AZHL_AHEGB
...                     SBTS00
# ...                     STATE_SW_UPLOADED
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
*** Variables ***
${PA_MaxValue}           ${120}
${PA_MinValue}           ${0}
&{fault_7300}              faultId=${7300}
&{fault_7311}              faultId=${7311}
&{fault_62003}              faultId=${62003}
&{fault_6331}              faultId=${6331}
@{Ohter_Allow_Alarms}      &{fault_7311}    &{fault_7300}    &{fault_62003}    &{fault_6331}
#${DEBUG_MODE}    ${TRUE}


*** Test Cases ***
Upgrade
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Run Feature Case
    [Teardown]    TL Suite Teardown

CB012474_04_Successful reattempt of EN-DC Configuration Update procedure and completion of cell addition upon reattempt timer expiry
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012474
    ${rule1}    Catenate
    ...    Distname: MRBTS-10787/NRBTS-11436;
    ...    Counter: M55110C00040;
    ...    Counter rule: max(M55110C00040)>0;
    # ${rule2}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: max(M55319C16006)<81000;
    # ${rule3}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)<=40000;
    # ${rule4}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)>33000;
    # ${rule5}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16007;
    # ...    Counter rule: M55319C16007==0;

    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Start Multi Bts Log
    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    10s
    @{cell_list}=    Create List    11    111
    Change Commission To Lock cell    @{cell_list}
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    3s
    Change Commission To Unlock cell    @{cell_list}
    sleep    600s
    #expected_alarms FaultID7101
    Counter Check ENDCRATTEMPT


CB012474_16_Successful reattempt of EN-DC Configuration Update procedure with subsequent cell reconfiguration while reattempt timer is running
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012474
    ${rule1}    Catenate
    ...    Distname: MRBTS-10787/NRBTS-11436;
    ...    Counter: M55110C00040;
    ...    Counter rule: max(M55110C00040)>0;
    # ${rule2}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: max(M55319C16006)<81000;
    # ${rule3}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)<=40000;
    # ${rule4}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)>33000;
    # ${rule5}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16007;
    # ...    Counter rule: M55319C16007==0;

    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Start Multi Bts Log
    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    10s
    @{cell_list}=    Create List    11    111
    Change Commission To Lock cell    @{cell_list}
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    3s
    Change Commission To Unlock cell    @{cell_list}
    sleep    600s
    #expected_alarms FaultID7101
    Counter Check ENDCRATTEMPT

CB012474_03_CB012474 new counter update check
    [Documentation]    author:Andy
    [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012474
    ${rule1}    Catenate
    ...    Distname: MRBTS-10787/NRBTS-11436;
    ...    Counter: M55110C00040;
    ...    Counter rule: max(M55110C00040)>0;
    # ${rule2}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: max(M55319C16006)<81000;
    # ${rule3}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)<=40000;
    # ${rule4}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16006;
    # ...    Counter rule: latest(M55319C16006)>33000;
    # ${rule5}    Catenate
    # ...    Distname: MRBTS-1/NRBTS-1;
    # ...    Counter: M55319C16007;
    # ...    Counter rule: M55319C16007==0;

    ${rule_list}    Create List    ${rule1}
    Counter Operation    operation=start_collect_counter
    ...    product_type=gnb
    ...    counter_rule=${rule_list}

    Start Multi Bts Log
    Set maxParallelIncX2SetupOrECUOvl0 10 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    10s
    @{cell_list}=    Create List    11    111
    Change Commission To Lock cell    @{cell_list}
    sleep    3s
    Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
    sleep    3s
    Change Commission To Unlock cell    @{cell_list}
    sleep    600s
    #expected_alarms FaultID7101
    Counter Check ENDCRATTEMPT

# CB012474_02_CB012474 impacted legacy counter check
#     [Documentation]    author:Andy
#     [Tags]    10_5_UTESRAN001T10787    SCF_10_5_UTESRAN001T10787_CB012474
#     ${rule1}    Catenate
#     ...    Distname: MRBTS-10787/NRBTS-11436;
#     ...    Counter: M55110C00040;
#     ...    Counter rule: max(M55110C00040)>0;
#     ${rule2}    Catenate
#     ...    Distname: MRBTS-10787/NRBTS-11436;
#     ...    Counter: M55110C00015;
#     ...    Counter rule: max(M55110C00015)>0;
#     ${rule3}    Catenate
#     ...    Distname: MRBTS-10787/NRBTS-11436;
#     ...    Counter: M55110C00021;
#     ...    Counter rule: latest(M55110C00021)>0;
#     # ${rule4}    Catenate
#     # ...    Distname: MRBTS-1/NRBTS-1;
#     # ...    Counter: M55319C16006;
#     # ...    Counter rule: latest(M55319C16006)>33000;
#     # ${rule5}    Catenate
#     # ...    Distname: MRBTS-1/NRBTS-1;
#     # ...    Counter: M55319C16007;
#     # ...    Counter rule: M55319C16007==0;

#     ${rule_list}    Create List    ${rule1}
#     Counter Operation    operation=start_collect_counter
#     ...    product_type=gnb
#     ...    counter_rule=${rule_list}

#     Start Multi Bts Log
#     @{cell_list}=    Create List    11    111
#     Change Commission To Lock cell    @{cell_list}
#     sleep    3s
#     Set maxParallelIncX2SetupOrECUOvl0 0 in LTE   dist_name=MRBTS-10788/LNBTS-10788    bts_index=1
#     sleep    3s
#     Change Commission To Unlock cell    @{cell_list}
#     sleep    300s
#     #expected_alarms FaultID7101
#     Counter Check ENDCRATTEMPT

*** Keywords ***
Case Setup
    Log To Console    Case Setup
    Log To Console    Set PA to max
    Init Attenuation All Max    max_value=${PA_MaxValue}

Case Teardown
    Log To Console    Case Teardown
    Run Keyword And Ignore Error    Stop DL traffic and check the TP on EPC    DL_port=${tl.appserver.port}
    Run Keyword And Ignore Error    Stop All Bts Log
    Run Keyword And Ignore Error    AT.UE Detach
    # Run Keyword And Ignore Error    Commission Golden SCF For All GNB
    Run Keyword And Ignore Error    Disconnect All VM

Stop All Bts Log
    Stop All BTSLog And Download to Local



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
    @{value_list}   Create List   0
    @{mo_list}   Create List   ${dist_name}
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