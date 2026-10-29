*** Settings ***
Documentation       Test case for SyVe_CM_CB012523_001
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1041    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${RECOVERY_FLAG}    ${False}
${LocalIpAddr_New}    10.56.201.22
${maxCellDisableTimeWhenNmsLost_case1}    21
${shutdownWindow_case1}    180

*** Keywords ***
SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Documentation]
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    RAN_ST_CB012523-B_001_Cell graceful shutdown when M-Plane connection toward NMS is lost.
    ...    RAN_ST_CNI-131432_001_Keep cells disabled after M-Plane connection restored
    ...    Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
    ...    The main steps performed for the test are:
    ...
    ...    - Check initial BTS state
    ...    - Check initial alarms status from WebEM
    ...    - Check initial alarms status from Netact
    ...    - Randomly Select One NRCell
    ...    - Disconnect NMS Link And Check NMS Status
    ...    - Perform Online parameter Delta Plan And Check BTS Re-Register
    ...    - Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    ...    - Configure Failure NRCell
    ...    - Recovery NMS Link And Check Cell Disable
    ...    - Check Feature Counters
    ...    - Disable Feature And Configure Recovery NRCell
    ...    - Scenario2: Cover recovery NMS link during shutdownwindow
    ...    - Disconnect NMS Link And Check NMS Status
    ...    - Recovery NMS Link During Shutdownwindow
    ...    - Check Cell Graceful ShutDown
    ...    - Check Feature Counters
    ...    - Disable Feature
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
    #Step 3: Check initial alarms status from Netact
    Step 4: Randomly Select One NRCell
    Step 5: Disconnect NMS Link And Check NMS Status
    Step 6: Perform Online parameter Delta Plan And Check BTS Re-Register
    Step 7: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    Step 8: Configure Failure NRCell
    Step 9: Recovery NMS Link And Check Cell Disable
    Step 10: Check Feature Counters
    Step 11: Disable Feature And Configure Recovery NRCell
    Log To Console    Scenario2: Cover recovery NMS link during shutdownwindow
    Step 12: Disconnect NMS Link And Check NMS Status
    Step 13: Recovery NMS Link During Shutdownwindow
    Step 14: Check Cell Graceful ShutDown
    Step 15: Check Feature Counters
    Step 16: Disable Feature
    #Step 17: Check final alarms status from Netact
    #Step 18: Check final BTS state
    #Step 19: Check final number and state of Cells and RMs

Step ${index}: Randomly Select One NRCell
    Log To Console    Step ${index}: Randomly Select One NRCell
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    ${selected_cell}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    Set Test Variable    ${selected_cell}
    Set Test Variable    ${mrbts_id}    ${selected_cell['id']['configuration'].split("/")[0].split("-")[-1]}
    ${NRBTS_DN}    Fetch From Left    ${selected_cell}    /NRCELL-
    coam.perform_parameter_recommissioning    ${NRBTS_DN}/NRPMRNL-1   miNrCellAvailability    update    5min

Step ${index}: Disconnect NMS Link And Check NMS Status
    Log To Console    Step ${index}: Disconnect NMS Link And Check NMS Status
    #Start count
    ${rule}    Catenate
    ...    Distname: ${selected_cell['id']['configuration']};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=enb
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${mrbts_id}
    ${resetTimer}    Get Time
    Set Test Variable    ${resetTimer}
    #Enable feature On randomly NRCell
    ${cellDNConfig_list}    Create List    ${selected_cell['id']['configuration']}
    Enable CB012523 Feature    ${cellDNConfig_list}    ${maxCellDisableTimeWhenNmsLost_case1}    ${shutdownWindow_case1}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    ${mPlaneIpv4AddressDN_origin}    ${mPlaneIpv4AddressDN_new}    Disconnect NMS Link By mPlaneIpv4AddressDN    ${LocalIpAddr_New}
    ${lastlink_time}    Get Time
    Set Test Variable    ${mPlaneIpv4AddressDN_origin}
    Set Test Variable    ${mPlaneIpv4AddressDN_new}
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    notConnected
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}
    Set Test Variable    ${lastlink_time}
    ${delta_time}    Subtract Date From Date    ${discon_time}    ${lastlink_time}
    Log To Console    ${delta_time}
    Should Be True    900<=${delta_time}<=1000


Step ${index}: Perform Online parameter Delta Plan And Check BTS Re-Register
    Log To Console    Step ${index}: Perform Online parameter Delta Plan And Check BTS Re-Register
    #Delta plan
    ${btsname_origin}    Get Parameter Value From WebEM    MRBTS-${mrbts_id}    btsName
    Set Test Variable    ${btsname_origin}
    coam.perform_parameter_recommissioning    MRBTS-${mrbts_id}    btsName    update    ${mrbts_id}_case1
    #check syslog for re-register
    ${reregister_msg}    taf_syslog.Wait For Message In Syslog File    regexp=reRegisterToNms triggered    timeout=780s    alias=SMOD1
    ${reregister_time}    Get Regexp Matches    ${reregister_msg}    \\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}
    ${delta_time}    Subtract Date From Date    ${reregister_time[0].replace('T', '')}    ${resetTimer}
    ${deltaTime_expected}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case1}*60-30-${shutdownWindow_case1}-30
    Should Be True    ${deltaTime_expected}-30<=${delta_time}<=${deltaTime_expected}+120

Step ${index}: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    Log To Console    Step ${index}: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    #Delta plan
    coam.perform_parameter_recommissioning    MRBTS-${mrbts_id}    btsName    update    ${btsname_origin}
    #Check Cell shutdown
    ${cell_state_shutdown}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_shutdown}    timeout=1200
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    #check other cells enable
    ${Impacted_Cell_Status}    Create Dictionary
    ...    NRCEL=operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    ${selected_cell_list}    Create List    ${selected_cell['id']['internal']}
    ${Impacted_Cells}    Create Dictionary    NRCEL=${selected_cell_list}
    Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case1}*60-930-30<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case1}*60-930+30
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"
    #no needed
#    ${alarm_existed}    Run Keyword And Return Status    coam.assert_alarm_active    faultId=4261    timeout=300s
#    Should Not Be True    ${alarm_existed}

Step ${index}: Configure Failure NRCell
    Log To Console    Step ${index}: Configure Failure NRCell
    ${paramValue_origin}    Get Parameter Value From WebEM    ${selected_cell['id']["configuration"]}    gscnOrSsPbchArfcn
    Set Test Variable    ${paramValue_origin}
    coam.Perform Parameter Recommissioning    ${selected_cell['id']["configuration"]}
    ...    gscnOrSsPbchArfcn    update    ${${paramValue_origin}+500}
    ${cell_state_failed}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", blockingState=${_Unblocked_}, administrativeState=Locked
    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_failed}    timeout=300

Step ${index}: Recovery NMS Link And Check Cell Disable
    Log To Console    Step ${index}: Recovery NMS Link And Check Cell Disable
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}
    #check shutdown cell disable and other cells enable
    ${Impacted_Cell_Status}    Create Dictionary
    ...    NRCEL=operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    ${selected_cell_list}    Create List    ${selected_cell['id']['internal']}
    ${Impacted_Cells}    Create Dictionary    NRCEL=${selected_cell_list}
    Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    300s
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=enb    bts_index=0    cudu_index=0

Step ${index}: Disable Feature And Configure Recovery NRCell
    Log To Console    Step ${index}: Disable Feature And Configure Recovery NRCell
    coam.perform_parameter_recommissioning    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    update    false
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    #yuki manual test：update this param，trigger SD,then disable feature, reset cell,rat, reset bts to recovery cell,cause sw rollback mayabe PR798345
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"
    coam.Perform Parameter Recommissioning    ${selected_cell['id']["configuration"]}
    ...    gscnOrSsPbchArfcn    update    ${paramValue_origin}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    coam.reset_site
    Sleep    300s
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: Check Cell Graceful ShutDown
    Log To Console    Step ${index}: Check Cell Graceful ShutDown
    ${cell_state_shutdown}    Set Variable
    ...    operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    Wait Until Keyword Succeeds    3x    30s    coam.assert    NRCEL    ${selected_cell['id']['internal']}    ${cell_state_shutdown}    timeout=1000
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    #check other cells enable
    ${Impacted_Cell_Status}    Create Dictionary
    ...    NRCEL=operationalState=${_Disabled_}, availabilityStatus="${_Offline_}", administrativeState=Locked
    ${selected_cell_list}    Create List    ${selected_cell['id']['internal']}
    ${Impacted_Cells}    Create Dictionary    NRCEL=${selected_cell_list}
    Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case1}*60-930-60<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case1}*60-930+60
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From WebEM
    ...    ${selected_cell['id']['configuration']}    cellDisabledDueToNmsLoss    export_type=configurationAndRuntimeObjects
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"


Step ${index}: Recovery NMS Link During Shutdownwindow
    Log To Console    Step ${index}: Recovery NMS Link During Shutdownwindow
    ${current_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${current_time}    ${lastlink_time}
    ${sleep_time}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case1}*60-${delta_time}
    ${random_time}    Evaluate    random.randint(0,60)    modules=random, sys
    ${sleep_time}    Evaluate    ${sleep_time}+${random_time}
    Sleep    ${sleep_time}
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}


Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    coam.perform_parameter_recommissioning    ${selected_cell['id']['configuration']}    disableCellWhenNmsLost    update    false
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    10min    30s    Check SBTS SMOD RMOD Cells Alarms
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
    #Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    Disable Feature And Recovery NMS Link
    Run Keyword If    ${RECOVERY_FLAG}    coam.Perform Commissioning
    ...    ${mrbts_id}    ${BTS_scf_initial}    skip_parameter_relation_errors=true    timeout=600
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown

Disable Feature And Recovery NMS Link
    Log To Console    Disable Feature And Recovery NMS Link
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    Run Keyword And Ignore Error    coam.append_managed_object_to_delta    ${mPlaneIpv4AddressDN_new}    delete    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1    update    ${mrbts_id}_${time}
    Run Keyword And Ignore Error    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_ID}_${time}
    coam.append_managed_object_to_delta    ${selected_cell['id']['configuration']}    update    ${mrbts_id}_${time}
    Run Keyword And Ignore Error    coam.append_parameter_update_to_delta    ${selected_cell['id']['configuration']}
    ...    disableCellWhenNmsLost    false    ${MRBTS_ID}_${time}
    Run Keyword And Ignore Error    coam.append_parameter_update_to_delta    ${selected_cell['id']['configuration']}
    ...    gscnOrSsPbchArfcn    ${paramValue_origin}    ${MRBTS_ID}_${time}
    coam.append_managed_object_to_delta    MRBTS-${mrbts_id}    update    ${mrbts_id}_${time}
    Run Keyword And Ignore Error    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}    btsName    ${btsname_origin}    ${mrbts_id}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}

