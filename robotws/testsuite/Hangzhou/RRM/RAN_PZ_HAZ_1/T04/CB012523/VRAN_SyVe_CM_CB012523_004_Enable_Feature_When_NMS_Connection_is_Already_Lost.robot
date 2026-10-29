*** Settings ***
Documentation       Test suite for SyVe_CM_CB012523_004
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Library           ../Resources/python/FCT_Excel.py

*** Variables ***
&{cellState_shutdown_status}    operationalState=disabled    availabilityStatus=off line    administrativeState=Locked
&{cellState_expected_status}    operationalState=enabled    administrativeState=Unlocked

*** Keywords ***
VRAN_SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    22.07.2023, lixin.kang@nokia-sbell.com, draft
    ...  - 22.09.2025 - Update by Xu Yuyan because PR847004 add new requirement:requirement 12711772 "OAM shall disable NRCELL-x once during a single
    ...   NMS connection loss period. If operator changes NRCELL-x.administrativeState to unlocked, OAM shall not lock it again during this NMS
    ...   connection loss period." - Comment Step10/12, and update step9/11

    Log To Console    ${TEST_NAME} start.
    Step 1: Enable Measurement And Defined Expected Counter Rule
    Step 2: Make NMS Link Disconnect
    ##---- Scenario1 ----##
    Step 3: Enable Feature When Cell Disable Timer Still Working
    Step 4: Check Cell Forced Gracefull Shutdown After Defined Time
    Step 5: Unlock Cell And Check Status
    Step 6: Disable Feature
    Step 7: Check Counter Value As Expected
    ##---- Scenario2 ----##
    Step 8: Enable Feature When Cell Disable Timer Already Timeout
    #Step 9: Check Cell Forced Gracefull Shutdown Immediately
    Step 9: Check Cell Forced Not Gracefull Shutdown
    #Step 10: Check Counter Value As Expected
    ##---- Scenario3 ----##
    Step 11: Reset Site And Check Cell Status
    #Step 12: Check Counter Value As Expected

Step ${index}: Enable Measurement And Defined Expected Counter Rule
    Log To Console    Step ${index}: Enable Measurement And Defined Expected Counter Rule
    ${cells_list}    vdu.get_vdu_cell_id
    ${selected_cell_dic}    Evaluate    random.choice(${cells_list})    modules=random, sys
    ${keys}    Get Dictionary Keys    ${selected_cell_dic}
    Set Test Variable    ${selected_cell_list}    ${keys}
    Set Test Variable    ${selected_cell}    ${keys[0]}
    ${other_cells}    Create List
    FOR    ${cell}    IN    @{cells_list}
        ${keys}    Get Dictionary Keys    ${cell}
        Append To List    ${other_cells}    ${keys[0]}
    END
    Remove Values From List    ${other_cells}    ${selected_cell}
    Set Test Variable    ${other_cells}
    ##bk-12840    ${param_dic}    Create Dictionary    miNrCellAvailability=5min
    ##bk-12840  Run Keyword And Ignore Error    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840  ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRPMRNL-1    ${param_dic}
    @{para_list}    Create List    miNrCellAvailability
    @{value_list}    Create List    5min
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRPMRNL-1
    ${out}    Run Keyword And Ignore Error    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    ${rule}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=vdu    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True

Step ${index}: Make NMS Link Disconnect
    Log To Console    Step ${index}: Make NMS Link Disconnect
    ##bk-12840    ${maxCellDisableTimeWhenNmsLost}     Get Parameter Value From vDU
    ##bk-12840  ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}   maxCellDisableTimeWhenNmsLost    false
    ##bk-12840    ${shutdownWindow}    Get Parameter Value From vDU    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}     shutdownWindow    false
    @{para_list}    Create List    maxCellDisableTimeWhenNmsLost    shutdownWindow
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}
    ${out}    Parameter Operation    operation=parameter_value_check    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}
    ${maxCellDisableTimeWhenNmsLost}    Set Variable    ${out["${mo_list[0]}"]["${para_list[0]}"]}
    ${shutdownWindow}    Set Variable    ${out["${mo_list[1]}"]["${para_list[1]}"]}
    Set Test Variable    ${maxCellDisableTimeWhenNmsLost}
    Set Test Variable    ${shutdownWindow}
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ${last_downloadlink_timer}    Get Time    epoch
    Set Test Variable    ${last_downloadlink_timer}
    ##bk-12840    ${param_dic}    Create Dictionary    oamTls=forced
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1     ${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    forced
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    16m    10s     Check NMS State    N/A
    ${not_connect_timer}    Get Time    epoch
    Set Test Variable    ${not_connect_timer}

Step ${index}: Enable Feature When Cell Disable Timer Still Working
    Log To Console    Step ${index}: Enable Feature When Cell Disable Timer Still Working
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=true
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}     ${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Check Cell Forced Gracefull Shutdown After Defined Time
    Log To Console    Step ${index}: Check Cell Forced Gracefull Shudown After Defined Time
    # different form classic bts, there will be 60s buffer time between nrts and ne3s, add 30s buffer in code
    ${shutdown_timer}    Evaluate    ${not_connect_timer} + 30 + ${maxCellDisableTimeWhenNmsLost} * 60 - 15.5 * 60
    vDU Login By Rest
    Wait Until Keyword Succeeds    30m    30s     Check Specified Cell Status On vDU   ${selected_cell}    ${cellState_shutdown_status}
    ${actual_shutdown_timer}    Get Time    epoch
    Should Be True    ${actual_shutdown_timer} > ${shutdown_timer} - 60 and ${actual_shutdown_timer} < ${shutdown_timer} + 60
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss    true
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    true
    Check Other NRCells OnAir

Step ${index}: Unlock Cell And Check Status
    Log To Console    Step ${index}: Unlock Cell And Check Status
    ##bk-12840  ${param_dic}    Create Dictionary    administrativeState=Unlocked
    ##bk-12840  VDU Online Modify Parameters By Delta Plan REST    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}     ${param_dic}
    @{para_list}    Create List    administrativeState
    @{value_list}    Create List    Unlocked
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    2m    10s    vDU Check All Cells Status Should Be Onair
    vDU Login By Rest
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss    true
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false

Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=false
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}     ${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Enable Feature When Cell Disable Timer Already Timeout
    Log To Console    Step ${index}: Enable Feature When Cell Disable Timer Already Timeout
    ${rule}    Catenate
    ...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=vdu    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=true
    ##bk-12840    VDU Online Modify Parameters By Delta Plan REST    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}     ${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Check Cell Forced Not Gracefull Shutdown
#Step ${index}: Check Cell Forced Gracefull Shutdown Immediately
    Log To Console    Step ${index}: Check Cell Forced Not Gracefull Shutdown
    #${enable_feature_timer}    Get Time    epoch
    #vDU Login By Rest
    #Wait Until Keyword Succeeds    5m    10s     Check Specified Cell Status On vDU   ${selected_cell}    ${cellState_shutdown_status}
    #${actual_shutdown_timer}    Get Time    epoch
    #${shutdown_time}    Subtract Date From Date    ${actual_shutdown_timer}    ${enable_feature_timer}
    #Should Be True     ${shutdown_time} > ${shutdownWindow} -30 and ${shutdown_time} < ${shutdownWindow} + 45
    #${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU
    #...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss    true
    #Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    true
    #Check Other NRCells OnAir
    vDU Login By Rest
    Wait Until Keyword Succeeds    2m    10s    vDU Check All Cells Status Should Be Onair
    vDU Login By Rest
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss    true
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false

Step ${index}: Disable Feature And Recovery NMS Link-bk-12840
    Log To Console    Step ${index}: Disable Feature And Recovery NMS Link
    ${plan_id}    ${action_id}   Generate Delta Plan In vDU    DELTA-PLAN-12523_004
    ${param_dic1}    Create Dictionary    disableCellWhenNmsLost=false
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    ${param_dic1}
    ${param_dic2}    Create Dictionary    oamTls=off
    Update Parameter By Delta Plan In vDU    ${plan_id}     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    ${param_dic2}
    Set Test Variable   ${plan_id}
    Validate Delta Plan By REST In vDU    ${plan_id}
    ${out}    vdu.activate_delta_plan    delta_plan_id=${plan_id}
    ${rtn}    Wait Until Keyword Succeeds     5m   30s   _Check Activate Delta Plan Status Should Be Expected
    ...    operation_id=${out['id']}    plan_id=${plan_id}    expected_status=success
    Wait Until Keyword Succeeds    5m    10s     Check NMS State    Succeeded

Step ${index}: Disable Feature And Recovery NMS Link
    Log To Console    Step ${index}: Disable Feature And Recovery NMS Link
    @{para_list}    Create List    disableCellWhenNmsLost    oamTls
    @{value_list}    Create List    false    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}

Step ${index}: Check Counter Value As Expected
    Log To Console    Step ${index}: Check Counter Value As Expected
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=vdu    bts_index=0    cudu_index=0

Step ${index}: Reset Site And Check Cell Status
    Log To Console    Step ${index}: Reset Site And Check Cell Status Counter Values As Expected
    #${rule}    Catenate
    #...    Distname: MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell};
    #...    Counter: M55601C03001,M55601C03002,M55601C03003;
    #...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==0 and sum(M55601C03003)==1;
    #${rule_list}    Create List    ${rule}
    #Counter Operation    operation=start_collect_counter    product_type=vdu    oam_ip=192.168.255.129
    #...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    #Reset vDU With Check Cell On Air
    #Wait Until Keyword Succeeds    10m    60s     Check Other NRCells OnAir
    #vDU Login By Rest
    #Wait Until Keyword Succeeds    5m    60s     Check Specified Cell Status On vDU   ${selected_cell}    ${cellState_shutdown_status}
    Reset vDU With Check Cell On Air    ${True}
    vDU Login By Rest
    ${cellDisabledDueToNmsLoss}    Get Parameter Value From vDU
    ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}    cellDisabledDueToNmsLoss    true
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false    #true

Check Other NRCells OnAir
    FOR    ${cell}    IN    @{other_cells}
        Check Specified Cell Status On vDU    ${cell}    ${cellState_expected_status}
    END

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    vDU Login By Rest
    ${oamtls}    Get Parameter Value From vDU    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    oamTls
    ##bk-12840    ${param_dic}    Create Dictionary    oamTls=off
    ##bk-12840    Run Keyword If    '${oamtls}'=='forced'    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840    ...    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1    ${param_dic}
    @{para_list}    Create List    oamTls
    @{value_list}    Create List    off
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
    ${out}    Run Keyword If    '${oamtls}'=='forced'
    ...    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    ${disableCellWhenNmsLost}    Get Parameter Value From vDU   MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}  disableCellWhenNmsLost
    ##bk-12840    ${param_dic}    Create Dictionary    disableCellWhenNmsLost=false
    ##bk-12840    Run Keyword If    '${disableCellWhenNmsLost}'=='true'    VDU Online Modify Parameters By Delta Plan REST
    ##bk-12840 ...    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}   ${param_dic}
    @{para_list}    Create List    disableCellWhenNmsLost
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/${selected_cell}
    ${out}    Run Keyword If    '${disableCellWhenNmsLost}'=='true'
    ...    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    300s    15s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct
    SSHLibrary.Close All Connections