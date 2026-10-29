*** Settings ***
Documentation       Test case for SyVe_CM_CB012523_003/005
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1041    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}    ${False}
${LocalIpAddr_New}    10.56.201.24
${maxCellDisableTimeWhenNmsLost_case3}    25
${shutdownWindow_case3}    60

*** Keywords ***
SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB012523-B_003_Disable feature after cell is disable due to feature enable
    ...    RAN_ST_CNI-131432_005_Cell is not impact with feature disable when NMS link disconnect
    ...    Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Randomly Select One NRCell And Block NRCell
    ...    - Enable Feature And Disconnect NMS Link
    ...    - Before 5min Unblock NRCell And Check NRCell Shutdown
    ...    - Disable Feature And Check Cell Enable
    ...    - Check Feature Counters
    ...    - Recovery NMS Link
    ...    - Scenario2
    ...    - Randomly Select One NRCell And Block NRCell
    ...    - Enable Feature And Disconnect NMS Link
    ...    - After 5min Unblock NRCell And Check NRCell Shutdown
    ...    - Block NRCell
    ...    - Disable Feature And Check Cell Disable
    ...    - Check Feature Counters
    ...    - Unblock NRCell And Recovery NMS Link
    ...    - Check final alarms status from Netact
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 06.12.2024
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    #Step 1: Check initial BTS state
    #Step 2: Check initial alarms status from WebEM
    #Step 3: Check initial alarms status from Neact
    Step 4: Randomly Select One NRCell And Block NRCell
    Step 5: Enable Feature And Disconnect NMS Link
    Step 6: Before 5min Unblock NRCell And Check NRCell Shutdown
    Step 7: Disable Feature And Check Cell Enable
    Step 8: Check Feature Counters
    Step 9: Recovery NMS Link
    Log To Console    Scenario2
    Step 10: Randomly Select One NRCell And Block NRCell
    Step 11: Enable Feature And Disconnect NMS Link
    Step 12: After 5min Unblock NRCell And Check NRCell Shutdown
    Step 13: Block NRCell
    Step 14: Disable Feature And Check Cell Disable
    Step 15: Unblock NRCell And Recovery NMS Link
    Step 16: Check Feature Counters
    #Step 17: Check final alarms status from Netact
    #Step 18: Check final BTS state
    #Step 19: Check final number and state of Cells and RMs

Step ${index}: Randomly Select One NRCell And Block NRCell
    Log To Console    Step ${index}: Randomly Select One NRCell And Block NRCell
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    ${selected_cell}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    Set Test Variable    ${selected_cell}
    ${NRBTS_DN}    Fetch From Left    ${selected_cell['id']['configuration']}    /NRCELL-
    coam.perform_parameter_recommissioning    ${NRBTS_DN}/NRPMRNL-1   miNrCellAvailability    update    5min
    #Start count
    #25R1 do not plan to fix:PR802735: [CNI-131432] M55601C03001 not update after cell disable reason be clear before timer end up
    ${rule1}    Catenate
    ...    Distname: ${selected_cell['id']['configuration']};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==1 and sum(M55601C01001)>0 and sum(M55601C01002)==2;
    ${rule2}    Catenate
    ...    Distname: ${selected_cell['id']['configuration']};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Run Keyword If    "${index}"=="4"    Create List    ${rule1}    ELSE    Create List    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=enb    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    coam.block_cell    ${selected_cell['id']['configuration']}
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cells_NR_blocked_state}    timeout=60
    Set Test Variable    ${RECOVERY_FLAG}    ${True}


Step ${index}: Enable Feature And Disconnect NMS Link
    Log To Console    Step ${index}: Enable Feature And Disconnect NMS Link
    Set Test Variable    ${mrbts_id}    ${selected_cell['id']['configuration'].split("/")[0].split("-")[-1]}
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${resetTimer}    Get Time
    Set Test Variable    ${resetTimer}
    #${resetTimer_msg}    taf_syslog.Message Should Exist In Syslog File    regexp=CB012523    alias=SMOD1
    #${resetTimer_msg}    taf_syslog.Wait For Message In Syslog File    regexp=CB012523    timeout=60s    alias=SMOD1
    #${resetTimer}    Get Regexp Matches    ${resetTimer_msg}    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}
    #Enable feature
    ${cellDNConfig_list}    Create List    ${selected_cell['id']['configuration']}
    Enable CB012523 Feature    ${cellDNConfig_list}    ${maxCellDisableTimeWhenNmsLost_case3}    ${shutdownWindow_case3}
    ${mPlaneIpv4AddressDN_origin}    ${mPlaneIpv4AddressDN_new}    Disconnect NMS Link By mPlaneIpv4AddressDN    ${LocalIpAddr_New}
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    notConnected
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}
    Set Test Variable    ${mPlaneIpv4AddressDN_origin}
    Set Test Variable    ${mPlaneIpv4AddressDN_new}

Step ${index}: ${When} 5min Unblock NRCell And Check NRCell Shutdown
    Log To Console    Step ${index}: ${When} 5min Unblock NRCell And Check NRCell Shutdown
    ${sleep_time_after}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case3}*60-930-300+120
    ${sleep_time_before}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case3}*60-930-300-120
    ${sleep_time}    Set Variable If    "${When}"=="After"    ${sleep_time_after}    ${sleep_time_before}
    Sleep    ${sleep_time}
    #before 5min need check cell be onair then disable, after 5min always disable
    coam.unblock_cell    ${selected_cell['id']['configuration']}
    ${shutdown_starttime}    Get Time
    ${NRCell_Is_online}    Run Keyword And Return Status
    ...    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cells_NR_expected_state}    timeout=60
    Run Keyword If    "${When}"=="Before"    Should Be True    ${NRCell_Is_online}    ELSE    Should Not Be True    ${NRCell_Is_online}
    #Check Cell shutdown
    ${cell_state_shutdown}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_shutdown}    timeout=1200
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${shutdown_starttime}
    #do not need this checkpoint, because after unblock cell, cell will be locked immediately, will not send shutdown request
    Run keyword And Ignore Error    Run Keyword If    "${When}"=="After"
    ...    Should Be True    ${shutdownWindow_case3}+30-15<=${delta_time}<=${shutdownWindow_case3}+30+15
    sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"

Step ${index}: Disable Feature And Check Cell Enable
    Log To Console    Step ${index}: Disable Feature And Check Cell Enable
    coam.perform_parameter_recommissioning    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    update    false
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"


Step ${index}: Recovery NMS Link
    Log To Console    Step ${index}: Recovery NMS Link
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    300s
    Counter Operation    operation=collect_counter_and_check_rule    product_type=enb    bts_index=0    cudu_index=0

Step ${index}: Block NRCell
    Log To Console    Step ${index}: Block NRCell
    Wait Until Keyword Succeeds    10x    15s    coam.block_cell    ${selected_cell['id']['configuration']}
    #PR839904&PR842606:after shutdown then block cell, cell will unlock and cellDisabledDueToNmsLoss to false
    ${cell_state_blocked}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", blockingState=${_Blocked_}, administrativeState=Unlocked
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_blocked}    timeout=120

Step ${index}: Disable Feature And Check Cell Disable
    Log To Console    Step ${index}: Disable Feature And Check Cell Disable
    coam.perform_parameter_recommissioning    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    update    false
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cells_NR_blocked_state}    timeout=120
    Sleep    15s
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"

Step ${index}: Unblock NRCell And Recovery NMS Link
    Log To Console    Step ${index}: Unblock NRCell And Recovery NMS Link
    coam.unblock_cell    ${selected_cell['id']['configuration']}
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cells_NR_expected_state}    timeout=120
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Disable Feature And Recovery NMS Link-bk
    Log To Console    Step ${index}: Disable Feature And Recovery NMS Link
    Disable Feature And Recovery NMS Link
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    25min    30s    Check SBTS SMOD RMOD Cells Alarms

Disable Feature And Recovery NMS Link
    Log To Console    Disable Feature And Recovery NMS Link
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    coam.append_managed_object_to_delta    ${selected_cell['id']['configuration']}    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    false    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    10 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Wait Until Keyword Succeeds    10x    60s      Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}
    ...    ignored_alarms=${IGNORED_ALARMS}    critical_alarms=${CRITICAL_ALARMS}    unexpected_alarms=@{UNEXPECTED_ALARMS}
    ...    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]    Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

TC Setup
    Log To Console    TC Setup
    Common Test Setup

TC Teardown
    Log To Console    TC Teardown
    Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    Disable Feature And Recovery NMS Link
    Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    coam.unblock_cell    ${selected_cell['id']['configuration']}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown