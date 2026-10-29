*** Settings ***
Documentation       Test case for SyVe_CM_CB012523_006
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1041    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}    ${False}
${LocalIpAddr_New}    10.56.201.24
${maxCellDisableTimeWhenNmsLost_case6}    25
${shutdownWindow_case6}    60

*** Keywords ***
SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB012523-B_006_Prevent enable cells with feature enable in case gNB restarts
    ...    Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Randomly Select One NRCell
    ...    - Enable Feature And Disconnect NMS Link
    ...    - Reset SBTS Before Shutdown Request
    ...    - Check NRCell Shutdown
    ...    - Disable Feature And Recovery NMS Link
    ...    - Check Feature Counters
    ...    - Scenario2
    ...    - Enable Feature And Disconnect NMS Link
    ...    - Reset SBTS Before Shutdown Request
    ...    - Recovery NMS Link
    ...    - Check NRCell Shutdown Not Trigger
    ...    - Disable Feature
    ...    - Check Feature Counters
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
    Step 4: Randomly Select One NRCell
    Step 5: Enable Feature And Disconnect NMS Link
    Step 6: Reset SBTS Before Shutdown Request
    Step 7: Check NRCell Shutdown
    Step 8: Disable Feature And Recovery NMS Link
    Step 9: Check Feature Counters
    Log To Console    Scenario2
    Step 10: Enable Feature And Disconnect NMS Link
    Step 11: Reset SBTS Before Shutdown Request
    Step 12: Recovery NMS Link
    Step 13: Check NRCell Shutdown Not Trigger
    Step 14: Disable Feature
    Step 15: Check Feature Counters
    #Step 16: Check final alarms status from Netact
    #Step 17: Check final BTS state
    #Step 18: Check final number and state of Cells and RMs

Step ${index}: Randomly Select One NRCell
    Log To Console    Step ${index}: Randomly Select One NRCell
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    ${selected_cell}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    Set Test Variable    ${selected_cell}
    ${NRBTS_DN}    Fetch From Left    ${selected_cell['id']['configuration']}    /NRCELL-
    coam.perform_parameter_recommissioning    ${NRBTS_DN}/NRPMRNL-1   miNrCellAvailability    update    5min

Step ${index}: Enable Feature And Disconnect NMS Link
    Log To Console    Step ${index}: Enable Feature And Disconnect NMS Link
    Set Test Variable    ${mrbts_id}    ${selected_cell['id']['configuration'].split("/")[0].split("-")[-1]}
    #Start count
    ${rule1}    Catenate
    ...    Distname: ${selected_cell['id']['configuration']};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==1 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule2}    Catenate
    ...    Distname: ${selected_cell['id']['configuration']};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==0 and sum(M55601C03003)==0 and sum(M55601C01001)==0 and sum(M55601C01002)==0;
    ${rule_list}    Run Keyword If    "${index}"=="5"    Create List    ${rule1}    ELSE    Create List    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=enb
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${resetTimer}    Get Time
    Set Test Variable    ${resetTimer}
    #Enable feature On randomly NRCell
    ${cellDNConfig_list}    Create List    ${selected_cell['id']['configuration']}
    Enable CB012523 Feature    ${cellDNConfig_list}    ${maxCellDisableTimeWhenNmsLost_case6}    ${shutdownWindow_case6}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    ${mPlaneIpv4AddressDN_origin}    ${mPlaneIpv4AddressDN_new}    Disconnect NMS Link By mPlaneIpv4AddressDN    ${LocalIpAddr_New}
    Set Test Variable    ${mPlaneIpv4AddressDN_origin}
    Set Test Variable    ${mPlaneIpv4AddressDN_new}
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    notConnected
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}

Step ${index}: Reset SBTS Before Shutdown Request
    Log To Console    Step ${index}: Reset SBTS Before Shutdown Request
    ${delta_time}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case6}*60-930-30-${shutdownWindow_case6}-30-30
    ${sleep_time}    Evaluate    random.randint(0,${delta_time})    modules=random, sys
    Sleep    ${sleep_time}
    coam.reset_site
    #Have confirm with Ne3S, after site reset, need wait 15m30s then will be notConnected again.
    Wait Until Keyword Succeeds    25min    10s    Check SBTS SMOD RMOD Cells Alarms
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    notConnected
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}

Step ${index}: Check NRCell Shutdown
    Log To Console    Step ${index}: Check NRCell Shutdown
    ${cell_state_shutdown}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    Wait Until Keyword Succeeds    3x    30s    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_shutdown}    timeout=1000
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case6}*60-930-30<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case6}*60-930+30
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"


Step ${index}: Disable Feature And Recovery NMS Link
    Log To Console    Step ${index}: Disable Feature And Recovery NMS Link
    Disable Feature And Recovery NMS Link
    ${RECOVERY_FLAG}    Set Variable    ${False}
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"

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

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    300s
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=enb    bts_index=0    cudu_index=0

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
    Sleep    60s

Step ${index}: Check NRCell Shutdown Not Trigger
    Log To Console    Step ${index}: Check NRCell Shutdown Not Trigger
    Sleep    ${maxCellDisableTimeWhenNmsLost_case6}
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cells_NR_expected_state}    timeout=60
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"


Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    coam.perform_parameter_recommissioning    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    update    false
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Check SBTS SMOD RMOD Cells Alarms
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"


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
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

