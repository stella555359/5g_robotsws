*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
...   RAN_ST_CB012523-B_003_Disable feature after cell is disable due to feature enable
...   RAN_ST_CNI-131432_005_Cell is not impact with feature disable when NMS link disconnect
...   Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${maxCellDisableTimeWhenNmsLost_case3}    25
${shutdownWindow_case3}    60
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB012523_003_005_Enable_Cells_That_Has_Been_Disabled
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    02.09.2024, yuyan.xu@nokia-sbell.com, draft
    Step 1: Randomly Select One NRCell And Block NRCell
    Step 2: Enable Feature And Disconnect NMS Link
    Step 3: Before 5min Unblock NRCell And Check NRCell Shutdown
    Step 4: Disable Feature And Check Cell Enable
    Step 6: Recovery NMS Link
    Step 5: Check Feature Counters
    Log To Console    Scenario2
    Step 7: Randomly Select One NRCell And Block NRCell
    Step 8: Enable Feature And Disconnect NMS Link
    Step 9: After 5min Unblock NRCell And Check NRCell Shutdown
    Step 10: Block NRCell
    Step 11: Disable Feature And Check Cell Disable
    Step 12: Unblock NRCell And Recovery NMS Link
    Step 13: Check Feature Counters


Step ${index}: Randomly Select One NRCell And Block NRCell
    Log To Console    Step ${index}: Randomly Select One NRCell And Block NRCell
    vDU Login By Rest
    ${cells_list}    vdu.get_vdu_cell_id
    ${selected_cell_dic}    Evaluate    random.choice(${cells_list})    modules=random, sys
    ${keys}    Get Dictionary Keys    ${selected_cell_dic}
    Set Test Variable    ${selected_cell}    ${keys[0]}
    #Start count
    ${rule1}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==1 and sum(M55601C01001)>0 and sum(M55601C01002)==2;
    ${rule2}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Run Keyword If    "${index}"=="1"    Create List    ${rule1}    ELSE    Create List    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    #block cell
    Wait Until Keyword Succeeds    3x    15s    Block Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest
    Set Test Variable    ${RECOVERY_FLAG}    ${True}

Step ${index}: Enable Feature And Disconnect NMS Link
    Log To Console    Step ${index}: Enable Feature And Disconnect NMS Link
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${resetTimer}    Get Time
    Set Test Variable    ${resetTimer}
    ${cells_list}     Create List    ${selected_cell}
    Enable CB012523 Feature    ${cells_list}    ${maxCellDisableTimeWhenNmsLost_case3}    ${shutdownWindow_case3}
    #Disconnect NMS link
    ##bk-12840    ${param_dic}    create dictionary    oamTls=forced
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    forced
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    N/A
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}


Step ${index}: ${When} 5min Unblock NRCell And Check NRCell Shutdown
    Log To Console    Step ${index}: ${When} 5min Unblock NRCell And Check NRCell Shutdown
    ${sleep_time_after}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case3}*60-930-300+60
    ${sleep_time_before}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case3}*60-930-300-120
    ${sleep_time}    Set Variable If    "${When}"=="After"    ${sleep_time_after}    ${sleep_time_before}
    Sleep    ${sleep_time}
    #before 5min need check cell be onair then disable, after 5min always disable
    Wait Until Keyword Succeeds    10x    5s    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest
    ${shutdown_starttime}    Get Time
    ${cellState_online}    Create Dictionary
    ...    operationalState=enabled    availabilityStatus=on line    administrativeState=Unlocked
    ${NRCell_Is_online}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    10s
    ...    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_online}
    Run Keyword If    "${When}"=="Before"    Should Be True    ${NRCell_Is_online}    ELSE    Should Not Be True    ${NRCell_Is_online}
    #Check Cell shutdown
    ${cellState_shutdown}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line     administrativeState=Locked
    Wait Until Keyword Succeeds    30min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_shutdown}
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${shutdown_starttime}
    #do not need this checkpoint, because after unblock cell, cell will be locked immediately, will not send shutdown request
    run keyword and ignore error    Run Keyword If    "${When}"=="After"
    ...    Should Be True    ${shutdownWindow_case3}+30-30<=${delta_time}<=${shutdownWindow_case3}+30+30
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"

Step ${index}: Disable Feature And Check Cell Enable
    Log To Console    Step ${index}: Disable Feature And Check Cell Enable
    ${cells_list}     Create List    ${selected_cell}
    Disable CB012523 Feature    ${cells_list}
    vDU Login By Rest
    ${cellState_online}    Create Dictionary
    ...    operationalState=enabled    availabilityStatus=on line    administrativeState=Unlocked
    Wait Until Keyword Succeeds    10min    10s
    ...    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_online}
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"
    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest

Step ${index}: Recovery NMS Link
    Log To Console    Step ${index}: Recovery NMS Link
    ##bk-12840    ${param_dic}    create dictionary    oamTls=off
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}

Step ${index}: Block NRCell
    Log To Console    Step ${index}: Block NRCell
    Wait Until Keyword Succeeds    3x    15s    Block Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest
    #PR839904&PR842606:after shutdown then block cell, cell will unlock and cellDisabledDueToNmsLoss to false
    ${cellState_blocked}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    blockState=Blocked    administrativeState=Unlocked
    Wait Until Keyword Succeeds    10min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_blocked}

Step ${index}: Disable Feature And Check Cell Disable
    Log To Console    Step ${index}: Disable Feature And Check Cell Disable
    ${cells_list}     Create List    ${selected_cell}
    Disable CB012523 Feature    ${cells_list}
    vDU Login By Rest
    ${cellState}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line     administrativeState=Unlocked    blockState=Blocked
    Wait Until Keyword Succeeds    20min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState}
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"

Step ${index}: Unblock NRCell And Recovery NMS Link
    Log To Console    Step ${index}: Unblock NRCell And Recovery NMS Link
    Wait Until Keyword Succeeds    3x    15s    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    ##bk-12840    ${param_dic}    create dictionary    oamTls=off
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    300s
    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    bts_index=0    cudu_index=0

Disable Feature And Recovery NMS Link-bk-12840
    ${plan_id}    ${action_id}   Generate Delta Plan In vDU    DELTA-PLAN-12523_001
    ${param_dic1}    create dictionary    disableCellWhenNmsLost=false
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    ${param_dic1}
    ${param_dic2}    create dictionary    oamTls=off
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    ${param_dic2}
    Set Test Variable   ${plan_id}
    Validate Delta Plan By REST In vDU    ${plan_id}
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait until keyword succeeds    300    30s   _Check Activate Delta Plan Status Should Be Expected
    ...    operation_id=${out['id']}    plan_id=${plan_id}    expected_status=success
    #unblock _cell
    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest

Disable Feature And Recovery NMS Link
    @{para_list}    Create List    oamTls    disableCellWhenNmsLost
    @{value_list}    Create List    off    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    #unblock _cell
    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest

Disable CB012523 Feature-bk-12840
    [Arguments]    ${cellIds_list}    ${maxCellDisableTimeWhenNmsLost_case3}=30    ${shutdownWindow_case3}=180    ${alias}=default
    [Documentation]    Disable CB012523 Feature
    ...    Author: yuyan xu
    Log To Console    Disable CB012523 Feature
    log    ${alias}
    ${plan_id}    ${action_id}   Generate Delta Plan In vDU    DELTA-PLAN-12523_001
    ${param_dic1}    create dictionary    disableCellWhenNmsLost=false
    ${param_dic2}    create dictionary
    ...    maxCellDisableTimeWhenNmsLost=${maxCellDisableTimeWhenNmsLost_case3}    shutdownWindow=${shutdownWindow_case3}
    FOR    ${cell_id}    IN    @{cellIds_list}
        Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${cell_id}    ${param_dic1}
    END
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   ${param_dic2}
    Set Test Variable   ${plan_id}
    Validate Delta Plan By REST In vDU    ${plan_id}
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait until keyword succeeds    300    30s   _Check Activate Delta Plan Status Should Be Expected
    ...    operation_id=${out['id']}    plan_id=${plan_id}    expected_status=success

Disable CB012523 Feature
    [Arguments]    ${cellIds_list}    ${maxCellDisableTimeWhenNmsLost_case3}=30    ${shutdownWindow_case3}=180    ${alias}=default
    [Documentation]    Disable CB012523 Feature
    ...    Author: yuyan xu
    Log To Console    Disable CB012523 Feature
    log    ${alias}
    @{para_list}    Create List    maxCellDisableTimeWhenNmsLost    shutdownWindow
    @{value_list}    Create List    ${maxCellDisableTimeWhenNmsLost_case3}    ${shutdownWindow_case3}
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}
    FOR    ${cell_id}    IN    @{cellIds_list}
        Append To List    ${para_list}    disableCellWhenNmsLost
        Append To List    ${value_list}    false
        Append To List    ${mo_list}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${cell_id}
    END
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    vDU Login By Rest
    Setup NetAct    ${NETACT}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    Disable Feature And Recovery NMS Link
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
    Common Test Teardown For AIC