*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
...   RAN_ST_CB012523-B_001_Cell graceful shutdown when M-Plane connection toward NMS is lost.
...   RAN_ST_CNI-131432_001_Keep cells disabled after M-Plane connection restored
...   Precondition: manual set corresponding AoM parameter:miNrCellAvailability as 5min
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${maxCellDisableTimeWhenNmsLost_case1}    21
${shutdownWindow_case1}    180
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB012523_001_CNI-131432_001_Cell_Gracefull_ShutDown_When_NMS_Link_Lost_And_Restored
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    06.12.2024, yuyan.xu@nokia-sbell.com, draft
    Step 1: Disconnect NMS Link And Check NMS Status
    Step 2: Perform Online parameter Delta Plan And Check BTS Re-Register
    Step 3: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    Step 4: Block NRCell
    Step 5: Recovery NMS Link And Check Cell Disable
    Step 6: Check Feature Counters
    Step 7: Disable Feature And Unblock NRCell
    Log To Console    Scenario2: Cover recovery NMS link during shutdownwindow
    Step 8: Disconnect NMS Link And Check NMS Status
    Step 9: Recovery NMS Link During Shutdownwindow
    Step 10: Check Cell Graceful ShutDown
    Step 11: Disable Feature
    Step 12: Check Feature Counters


Step ${index}: Disconnect NMS Link And Check NMS Status
    Log To Console    Step ${index}: Disconnect NMS Link And Check NMS Status
    ${cells_list}    vdu.get_vdu_cell_id
    ${selected_cell_dic}    Evaluate    random.choice(${cells_list})    modules=random, sys
    ${keys}    Get Dictionary Keys    ${selected_cell_dic}
    Set Test Variable    ${selected_cell}    ${keys[0]}
    ${non_selected_cells}    Create List
    FOR    ${cell}    IN    @{cells_list}
        ${keys}    Get Dictionary Keys    ${selected_cell_dic}
        Append To List    ${non_selected_cells}    ${keys[0]}
    END
    Remove Values From List    ${non_selected_cells}    ${selected_cell}
    Set Test Variable    ${non_selected_cells}
    #Start count
    ${rule1}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule2}    Catenate
    ...     Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...     Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...     Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==1 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Run Keyword If    "${index}"=="1"    Create List    ${rule1}    ELSE    Create List    ${rule2}
    Counter Operation    operation=start_collect_counter    product_type=vdu
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${resetTimer}    Get Time
    Enable CB012523 Feature    ${keys}    ${maxCellDisableTimeWhenNmsLost_case1}    ${shutdownWindow_case1}
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
    ${delta_time}    Subtract Date From Date    ${discon_time}    ${resetTimer}
    Log To Console    ${delta_time}
    Set Test Variable    ${discon_time}
    Set Test Variable    ${resetTimer}
    Should Be True    900<=${delta_time}<=1000

Step ${index}: Perform Online parameter Delta Plan And Check BTS Re-Register
    Log To Console    Step ${index}: Perform Online parameter Delta Plan And Check BTS Re-Register
    #Delta plan
    ##bk-12840   ${btsname_origin}    Online Get VDU Parameter Value    mo_dn=MRBTS-${vDU_id}    para_name=btsName
    @{para_list}    Create List    btsName
    @{value_list}    Create List    MRBTS-${vDU_id}-case1
    @{mo_list}    Create List    MRBTS-${vDU_id}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    Set Test Variable    ${btsname_origin}    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    ##bk-12840   ${param_dic1}    create dictionary    btsName=MRBTS-${vDU_id}-case1
    ##bk-12840   VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}    updated_paras_list=${param_dic1}
    @{para_list}    Create List    btsName
    @{value_list}    Create List    MRBTS-${vDU_id}-case1
    @{mo_list}    Create List    MRBTS-${vDU_id}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    Log To Console    Step ${index}: Perform Online parameter Delta Plan And Check Cell Graceful ShutDown
    #Delta plan after BTS send reRegister
    ${current_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${current_time}    ${resetTimer}
    ${sleep_time}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case1}*60-${delta_time}-${shutdownWindow_case1}-30-30
    ${random_time}    Evaluate    random.randint(30,90)    modules=random, sys    #Cloud shutdown time always delay 60s
    ${sleep_time}    Evaluate    ${sleep_time}+${random_time}
    Sleep    ${sleep_time}
    ##bk-12840    ${param_dic2}    create dictionary    btsName=${btsname_origin}
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}    updated_paras_list=${param_dic2}
    @{para_list}    Create List    btsName
    @{value_list}    Create List    ${btsname_origin}
    @{mo_list}    Create List    MRBTS-${vDU_id}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    #Check Cell shutdown
    vDU Login By Rest
    ${cellState_shutdown}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    administrativeState=Locked
    Wait Until Keyword Succeeds    20min    5s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_shutdown}
    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    #shutdown time will delay 60s on Cloud BTS
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case1}*60-930-60<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case1}*60-930+60+60
    #Check other cells enable
    ${cellState_enable}    Create Dictionary    operationalState=enabled    availabilityStatus=online    administrativeState=Unlocked
    FOR    ${cell}    IN    @{non_selected_cells}
        Check Specified Cell Status On vDU    ${cell}    ${cellState_enable}
    END
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"
    ${k8s_local_file_path}    Run Keyword And Ignore Error    Collect And Download K8s Log In vDU
    ...    container_name=ne3sadapt    pod_name=oamext    duration=60m
    #check re-register time
#    ${k8slog_prints}    Create List
#    ${filter}    Set Variable    reRegisterToNms triggered, isAnyNrtsCellDisableWhenNmsLost: 1
#    ${re-register_msg}    Check K8s Log    ${k8s_local_file_path}    ${k8slog_prints}    ${filter}
#    Log    ${re-register_msg}

Step ${index}: Block NRCell
    Log To Console    Step ${index}: Block NRCell
    Wait Until Keyword Succeeds    3x    15s    Block Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest
    #PR839904&PR842606:after shutdown then block cell, cell will unlock and cellDisabledDueToNmsLoss to false
    ${cellState_blocked}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    blockState=Blocked    administrativeState=Unlocked
    Wait Until Keyword Succeeds    10min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_blocked}

Step ${index}: Recovery NMS Link And Check Cell Disable
    Log To Console    Step ${index}: Recovery NMS Link And Check Cell Disable
    ##bk-12840    ${param_dic}    create dictionary    oamTls=off
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    #PR839904&PR842606:after shutdown then block cell, cell will unlock and cellDisabledDueToNmsLoss to false
    ${cellState_shutdown}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    blockState=Blocked    administrativeState=Unlocked
    Wait Until Keyword Succeeds    20min    15s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_shutdown}
    #Check other cells enable
    ${cellState_enable}    Create Dictionary    operationalState=enabled    availabilityStatus=online    administrativeState=Unlocked
    FOR    ${cell}    IN    @{non_selected_cells}
        Check Specified Cell Status On vDU    ${cell}    ${cellState_enable}
    END
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false"
    #yuki check syslog timer reset
    #${k8s_local_file_path}    Collect And Download K8s Log In vDU    container_name=ne3sadapt    pod_name=oamext    duration=60m

Step ${index}: Check Feature Counters
    Log To Console    Step ${index}: Check Feature Counters
    #Check count Value
    Sleep    300s
    ${value}    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    bts_index=0    cudu_index=0

Step ${index}: Disable Feature And Unblock NRCell
    Log To Console    Step ${index}: Disable Feature And Unblock NRCell
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=false
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840 ...    mo_dn=MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    updated_paras_list=${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    vDU Login By Rest
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"
    Wait Until Keyword Succeeds    3x    15s    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    vDU Login By Rest
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest

Step ${index}: Recovery NMS Link During Shutdownwindow
    Log To Console    Step ${index}: Recovery NMS Link During Shutdownwindow
    ${current_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${current_time}    ${resetTimer}
    ${sleep_time}    Evaluate    ${maxCellDisableTimeWhenNmsLost_case1}*60-${delta_time}-${shutdownWindow_case1}
    ${random_time}    Evaluate    random.randint(60,90)    modules=random, sys    #Cloud shutdown time always delay 60s
    ${sleep_time}    Evaluate    ${sleep_time}+${random_time}
    Sleep    ${sleep_time}
    ##bk-12840    ${param_dic}    create dictionary    oamTls=off
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    mo_dn=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    updated_paras_list=${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Check Cell Graceful ShutDown
    Log To Console    Step ${index}: Check Cell Graceful ShutDown
    #Check Cell shutdown
    vDU Login By Rest
    ${cellState_shutdown}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    administrativeState=Locked
    Wait Until Keyword Succeeds    20min    5s    Check Specified Cell Status On vDU    ${selected_cell}    ${cellState_shutdown}

    ${shutdown_time}    Get Time
    ${delta_time}    Subtract Date From Date    ${shutdown_time}    ${discon_time}
    #shutdown time will delay 60s on Cloud BTS
    Should Be True
    ...    ${maxCellDisableTimeWhenNmsLost_case1}*60-930-30<=${delta_time}<=${maxCellDisableTimeWhenNmsLost_case1}*60-930+60+30
    #Check other cells enable
    ${cellState_enable}    Create Dictionary    operationalState=enabled    availabilityStatus=online    administrativeState=Unlocked
    FOR    ${cell}    IN    @{non_selected_cells}
        Check Specified Cell Status On vDU    ${cell}    ${cellState_enable}
    END
    Sleep    30s
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="true"

Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=false
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840    ...    mo_dn=MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    updated_paras_list=${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Sleep    15s
    vDU Login By Rest
    ${result}    ${cellDisabledDueToNmsLoss}    Run Keyword And Ignore Error    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss
    Should Be True    "${cellDisabledDueToNmsLoss}"=="false" or "${result}"=="FAIL"
    Wait Until Keyword Succeeds    5x    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    vDU Login By Rest

Disable Feature And Recovery NMS Link-bk-12840
    ${plan_id}    ${action_id}   Generate Delta Plan In vDU    DELTA-PLAN-12523_001
    ${param_dic1}    create dictionary    disableCellWhenNmsLost=false
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    ${param_dic1}
    ${param_dic2}    create dictionary    oamTls=off
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    ${param_dic2}
    ${param_dic3}    create dictionary    btsName=${btsname_origin}
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}   ${param_dic3}
    Set Test Variable   ${plan_id}
    Validate Delta Plan By REST In vDU    ${plan_id}
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait until keyword succeeds    300    30s   _Check Activate Delta Plan Status Should Be Expected
    ...    operation_id=${out['id']}    plan_id=${plan_id}    expected_status=success

Disable Feature And Recovery NMS Link
    @{para_list}    Create List    disableCellWhenNmsLost    oamTls    btsName
    @{value_list}    Create List    false    off    ${btsname_origin}
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    MRBTS-${vDU_id}
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
    Log To Console    Case
    Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    Disable Feature And Recovery NMS Link
    Run Keyword If    ${RECOVERY_FLAG}    Run Keyword And Ignore Error    Unblock Cell In vDU    ${selected_cell.split("-")[-1]}
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
    Common Test Teardown For AIC