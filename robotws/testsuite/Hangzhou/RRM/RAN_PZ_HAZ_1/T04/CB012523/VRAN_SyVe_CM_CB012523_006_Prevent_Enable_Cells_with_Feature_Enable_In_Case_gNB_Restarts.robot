*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
...   RAN_ST_CB012523-B_006_Prevent enable cells with feature enable in case gNB restarts
...   Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${maxCellDisableTimeWhenNmsLost_case6}    25
${shutdownWindow_case6}    60
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB012523_006_Prevent_Enable_Cells_with_Feature_Enable_In_Case_gNB_Restarts
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    26.09.2024, yuyan.xu@nokia-sbell.com, draft
    Step 1: Randomly Select One NRCell
    Step 2: Enable Feature And Disconnect NMS Link
    Step 3: Reset SBTS Before Shutdown Request
    Step 4: Check NRCell Shutdown
    Step 5: Disable Feature And Recovery NMS Link
    Step 6: Check Feature Counters
    Log To Console    Scenario2
    Step 7: Enable Feature And Disconnect NMS Link
    Step 8: Reset SBTS Before Shutdown Request
    Step 9: Recovery NMS Link
    Step 10: Check NRCell Shutdown Not Trigger
    Step 11: Disable Feature
    Step 12: Check Feature Counters


Step ${index}: Randomly Select One NRCell
    Log To Console    Step ${index}: Randomly Select One NRCell
    ${cells_list}    vdu.get_vdu_cell_id
    ${selected_cell_dic}    Evaluate    random.choice(${cells_list})    modules=random, sys
    ${keys}    Get Dictionary Keys    ${selected_cell_dic}
    Set Test Variable    ${selected_cell}    ${keys[0]}

Step ${index}: Enable Feature And Disconnect NMS Link
    Log To Console    Step ${index}: Enable Feature And Disconnect NMS Link
    #Start count
    ${rule1}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: 2>=sum(M55601C03001)>=1 and sum(M55601C03002)==1 and sum(M55601C03003)==1 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule2}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: 2>=sum(M55601C03001)>=1 and sum(M55601C03002)==0 and sum(M55601C03003)==0 and sum(M55601C01001)==0 and sum(M55601C01002)==0;
    ${rule_list}    Run Keyword If    "${index}"=="2"    Create List    ${rule1}    ELSE    Create List    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${resetTimer}    Get Time
    Set Test Variable    ${resetTimer}
    ${cells_list}     Create List    ${selected_cell}
    Enable CB012523 Feature    ${cells_list}    ${maxCellDisableTimeWhenNmsLost_case6}    ${shutdownWindow_case6}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
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

Step ${index}: Reset SBTS Before Shutdown Request
    Log To Console    Step ${index}: Reset SBTS Before Shutdown Request
    ${delta_time}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case6}*60-930-30-${shutdownWindow_case6}-30-30
    #${sleep_time}    Evaluate    random.randint(0,${delta_time})    modules=random, sys
    Sleep    ${delta_time}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10x    10s    vdu.reset_vdu
    #Have confirm with Ne3S, after site reset, need wait 15m30s then will be notConnected again.
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    2s    Check NMS State    N/A
    ${discon_time}    Get Time
    Set Test Variable    ${discon_time}

Step ${index}: Check NRCell Shutdown
    Log To Console    Step ${index}: Check NRCell Shutdown
    #Check Cell shutdown
    ${cellState_shutdown}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line     administrativeState=Locked
    Wait Until Keyword Succeeds    20min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_shutdown}
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    #shutdown time will delay 60s on Cloud BTS
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case6}*60-930-30<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case6}*60-930+60+30
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"

Step ${index}: Disable Feature And Recovery NMS Link
    Log To Console    Step ${index}: Disable Feature And Recovery NMS Link
    Disable Feature And Recovery NMS Link
    Sleep    30s
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"
    ${RECOVERY_FLAG}    Set Variable    ${False}
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest

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

Disable Feature And Recovery NMS Link
    @{para_list}    Create List    disableCellWhenNmsLost    oamTls
    @{value_list}    Create List    false    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    600s
    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    bts_index=0    cudu_index=0


Step ${index}: Recovery NMS Link
    Log To Console    Step ${index}: Recovery NMS Link
    Sleep    90s
    ##bk-12840    ${param_dic}    create dictionary    oamTls=off
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Sleep    60s

Step ${index}: Check NRCell Shutdown Not Trigger
    Log To Console    Step ${index}: Check NRCell Shutdown Not Trigger
    Sleep    ${maxCellDisableTimeWhenNmsLost_case6}
    ${cellState_online}    Create Dictionary
    ...    operationalState=enabled    availabilityStatus=on line    administrativeState=Unlocked
    ${NRCell_Is_online}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5min    10s
    ...    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_online}
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"

Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    ##bk-12840    ${param_dic}    create dictionary    disableCellWhenNmsLost=false
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840  ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    updated_paras_list=${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${RECOVERY_FLAG}    Set Variable    ${False}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"

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

