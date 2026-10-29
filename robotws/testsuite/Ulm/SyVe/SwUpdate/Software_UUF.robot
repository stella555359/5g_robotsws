*** Settings ***
Documentation    Suite description

Library    OperatingSystem

Resource   ../../resources/Common/testline.robot
Resource   ../../resources/Common/log_collection.robot
Resource   ../../resources/Common/btslog.robot
Resource   ../../resources/Common/snapshot.robot
Resource   ../../resources/Common/commissioning.robot
Resource   ../../resources/Common/connect.robot
Resource   ../../resources/Common/gnb.robot
Resource   ../../resources/Common/tcpdump.robot
Resource   ../../resources/Common/bip_trace.robot
Resource   ../resources/installation.robot
Resource   ../resources/enb.robot
Resource    taf/rfrl/bts/robot/gnb.robot

*** Variables ***
${ENB_NODES}      None
${GNB_NODES}      None
${fault_name}               SSH enabled
@{allowed_alarms}=    SSH enabled
...                   Ethernet port security is disabled
...                   R&D Service Port enabled
...                   LMP access via port 443
...                   Service account root access is enabled

*** Test Cases ***
Check_eNB_gNB_UUF
    [Documentation]    Automatic Check for UUF for eNBs and gNBs
    [Tags]             sw_uuf
    [Setup]            Create test suite result base directory
    Start the following logs
    ${enb_num}=    Get length    ${tl.enbs}
    ${gnb_num}=    Get length    ${tl.gnbs}
    Set Test variable    ${enb_num}
    Set Test variable    ${gnb_num}
    @{ENB_NODE_LIST}=    Split String   ${ENB_NODES}    ,
    @{GNB_NODE_LIST}=    Split String   ${GNB_NODES}    ,
    Set Test variable    @{ENB_NODE_LIST}
    Set Test variable    @{GNB_NODE_LIST}
    FOR   ${gnb_node_name}   IN    @{GNB_NODE_LIST}
        ${gnb_id}=    Fetch from right   ${gnb_node_name}   -
        IF    '${gnb_node_name}'!=''    Verify gNB UUF    gnb_id=${gnb_id}
        Log to console    \ngNB-${gnb_id} UUF Check is successfully Done
    END
    [Teardown]    Run Keywords
                  ...    Stop the following logs
                  ...    AND    Save all Logs and Teardown TL


*** Keywords ***
Verify eNB UUF
    [Arguments]    ${enb_id}=0
    Verify eNB Has Hanging Resources    enb_id=${enb_id}    raise_exception=False    du_id=${0}
    Verify eNB Sync Status    enb_id=${enb_id}    sync_source=1pps/ToD from external GNSS receiver    timeout=60    du_id=${0}
    Verify Alarm is Active on eNB    alarm_id    enb_id=${enb_id}    du_id=${0}
    Verify validation error active on eNB    enb_id=${enb_id}    du_id=${0}

Verify gNB UUF
    [Arguments]    ${gnb_id}=0
    Start watching alarms    allowed_alarms=@{allowed_alarms}    gnb_id=${gnb_id}    du_id=${0}
    Watch Active Alarms and Collect Logs on Unexpected Alarm    trigger_alarms=${None}    gnb_id=${gnb_id}    du_id=${0}
    Verify Alarm is Active on gNB    fault_name=${fault_name}    gnb_id=${gnb_id}    du_id=${0}
    ${allowed_alarams_flag}=    Run Keyword And Ignore Error    Verify Allowed Alarms on gNB
    ...    allowed_alarms=@{allowed_alarms}    gnb_id=${gnb_id}    du_id=${0}
    IF    '${allowed_alarams_flag}[0]'=='FAIL'    Log to console      ${\n}${allowed_alarams_flag}[1]
    Run keyword and ignore error    Verify gNB Sync Status    gnb_id=${gnb_id}
    ...    sync_source=1pps/ToD from Sync Hub Master    timeout=60    du_id=${0}
     # Verify validation error active on gNB should return False as there should be no validation errors on GNB
    Run Keyword And Expect Error     ValidationErrorNotActive: Validation error is not active
    ...    Verify validation error active on gNB    gnb_id=${gnb_id}    du_id=${0}
    Verify All Radio Module Status    gnb_id=${gnb_id}   bts_state=online    du_id=${0}
    Wait until X2 Link Status is Available  gnb_id=${gnb_id}  lteEnbId_Idx=${0}
    Verify Setup Of All Cells    gnb_id=${gnb_id}    du_id=${0}
    Stop watching alarms    gnb_id=${gnb_id}    du_id=${0}

Start the following logs
    bip_trace.Start BIP Traces
    Kill fsyslog process
    btslog.Start Btslog

Kill fsyslog process
    OperatingSystem.Run    pkill fsyslog

Stop the following logs
    bip_trace.Stop BIP Traces
    btslog.Stop Btslog

Save all Logs and Teardown TL
    Collect configs from gNBs
    Collect gNB snapshot    gnb_id=${0}
    connect.Disconnect all available ssh connections

Collect gNB snapshot
    [Arguments]    ${gnb_id}
    ${resultSuiteLogDir}=    testline.Get test suite log directory
    snapshot.Collect snapshot from gNB    target_dir=${resultSuiteLogDir}    gnb_id=${gnb_id}

Collect configs from gNBs
    ${resultSuiteConfigDir}=    testline.Get test suite config directory
    log_collection.Save DU configs from all gNBs    resultConfigsDir=${resultSuiteConfigDir}

