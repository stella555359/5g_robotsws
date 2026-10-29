*** Settings ***
Documentation       Test case for SyVe_CM_CB012523_004
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1041    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}

*** Keywords ***
SyVe_CM_CB012523_004_Enable_Feature_When_NMS_Connection_is_Already_Lost
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   New case for RAN_ST_CB012523-B_004_Enable feature when NMS connection is already lost
    ...   and RAN_ST_CNI-131432_002_Cell enabled when operator triggered cell un-lock from WebEM while NMS connection lost
    ...   and the reset scenario of RAN_ST_CNI-131432_004_Prevent cell enabling with status locked after the BTS restart and NMS connection back
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.09.2023 - New Case
    ...  - 19.09.2025 - Update by Xu Yuyan because PR847004 add new requirement:requirement 12711772 "OAM shall disable NRCELL-x once during a single
    ...   NMS connection loss period. If operator changes NRCELL-x.administrativeState to unlocked, OAM shall not lock it again during this NMS
    ...   connection loss period." - Comment Step13/15, and update step12/14

    Set Tags    CM    UI    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_4@internal.nsn.com   Author-lixin.kang@nokia-sbell.com
    LOG    ${TEST_NAME} start.    console=${True}
#    Step 1: Check initial BTS state
#    Step 2: Check initial alarms status from WebEM
#    Step 3: Check initial alarms status from Netact
    Step 4: Enable Measurement And Defined Expected Counter Rule
    Step 5: Make NMS Link Disconnect
    ##---- Scenario1 ----##
    Step 6: Enable Feature When Cell Disable Timer Still Working
    Step 7: Check Cell Forced Gracefull Shutdown After Defined Time
    Step 8: Unlock Cell And Check Status
    Step 9: Disable Feature
    Step 10: Check Counter Value As Expected
    ##---- Scenario2 ----##
    Step 11: Enable Feature When Cell Disable Timer Already Timeout
    #Step 12: Check Cell Forced Gracefull Shutdown Immediately
    Step 12: Check Cell Forced Not Gracefull Shutdown
    #Step 13: Check Counter Value As Expected
    ##---- Scenario3 ----##
    Step 14: Reset Site And Check Cell Status
    #Step 15: Check Counter Value As Expected
    Step 16: Recover Site
#    Step 17: Check final alarms status from WebEM
#    Step 18: Check final alarms status from Netact
#    Step 19: Check final BTS state
#    Step 20: Check final number and state of Cells and RMs

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains
    ...    informations   such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log To Console    Step ${index}: Check ${when} BTS state
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log To Console     Step ${index}: Check ${when} alarms status from WebEM
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log To Console     Step ${index}: Check ${when} alarms status from Netact
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log To Console     Step ${index}: Check final number and state of Cells and RMs
    Final Checks SyVe

Step ${index}: Enable Measurement And Defined Expected Counter Rule
    Log To Console    Step ${index}: Enable Measurement And Defined Expected Counter Rule
    ${nr_cell_list}    coam.Get Ids For All    NRCEL
    ${selected_nrcell_id}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
    Set Test Variable    ${selected_nrcell_id}
    ${selected_cell_list}    Create List    ${selected_nrcell_id}
    Set Test Variable    ${selected_cell_list}
    ${Impacted_Cell_Status}    Create Dictionary
    ...    NRCEL=${cells_NR_locked_state}
    Set Test Variable    ${Impacted_Cell_Status}
    ${Impacted_Cells}    Create Dictionary    NRCEL=${selected_cell_list}
    Set Test Variable    ${Impacted_Cells}
    ${mapping_dic}    Fetch ID Mapping From Admin For Cells    NRBTS    ${selected_nrcell_id}    internal
    Set Test Variable    ${selected_nrcell}    ${mapping_dic['configuration']}
    ${NRBTS_DN}    Fetch From Left    ${selected_nrcell}    /NRCELL-
    Set Test Variable    ${NRBTS_DN}
    coam.perform_parameter_recommissioning    ${NRBTS_DN}/NRPMRNL-1   miNrCellAvailability    update    5min
    ${rule1}    Catenate
    ...    Distname: ${selected_nrcell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule2}    Catenate
    ...    Distname: ${selected_nrcell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==0 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${active_sw_version}    coam.Get SW Version
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    #PR808374 not plan to fix on 25R1
    ${rule_list}    Run Keyword If    "${current_prefix}"=="SBTS25R1"    Create List    ${rule2}    ELSE    Create List    ${rule1}
    #${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=enb    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True

Step ${index}: Make NMS Link Disconnect
    Log To Console    Step ${index}: Make NMS Link Disconnect
    ${maxCellDisableTimeWhenNmsLost}    Get Parameter Value From WebEM    ${NRBTS_DN}    maxCellDisableTimeWhenNmsLost
    ${shutdownWindow}    Get Parameter Value From WebEM    ${NRBTS_DN}    shutdownWindow
    Set Test Variable    ${maxCellDisableTimeWhenNmsLost}
    Set Test Variable    ${shutdownWindow}
    NetAct CM Upload    dist_names=${MRBTS_DN}
    ${last_downloadlink_timer}    Get Time    epoch
    Set Test Variable    ${last_downloadlink_timer}
    ${mPlaneIpv4AddressDN_origin}    ${mPlaneIpv4AddressDN_new}    Disconnect NMS Link By mPlaneIpv4AddressDN    1.1.0.1
    Set Test Variable    ${mPlaneIpv4AddressDN_origin}
    Set Test Variable    ${mPlaneIpv4AddressDN_new}
    Wait Until Keyword Succeeds    20m    10s     Check NMS State    notConnected
    ${not_connect_timer}    Get Time    epoch
    Set Test Variable    ${not_connect_timer}

Step ${index}: Enable Feature When Cell Disable Timer Still Working
    Log To Console    Step ${index}: Enable Feature When Cell Disable Timer Still Working
    coam.perform_parameter_recommissioning    ${selected_nrcell}   disableCellWhenNmsLost    update    true

Step ${index}: Check Cell Forced Gracefull Shutdown After Defined Time
    Log To Console    Step ${index}: Check Cell Forced Gracefull Shudown After Defined Time
    ${shutdown_timer}    Evaluate    ${not_connect_timer} + ${maxCellDisableTimeWhenNmsLost} * 60 - 15.5 * 60
    Wait Until Keyword Succeeds    30m    30s   coam.Assert    NRCEL    ${selected_nrcell_id}    ${cells_NR_locked_state}
    ${actual_shutdown_timer}    Get Time    epoch
    Should Be True    ${actual_shutdown_timer} > ${shutdown_timer} - 30 and ${actual_shutdown_timer} < ${shutdown_timer} + 30
    ${cellDisabledDueToNmsLoss}    Get cellDisabledDueToNmsLoss Value    ${selected_nrcell}
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    true
    Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}

Step ${index}: Unlock Cell And Check Status
    Log To Console    Step ${index}: Unlock Cell And Check Status
    coam.perform_parameter_recommissioning    ${selected_nrcell}   administrativeState    update    Unlocked
    Wait Until Keyword Succeeds    300s    15s    Check SBTS SMOD RMOD Cells Alarms
    ${cellDisabledDueToNmsLoss}    Get cellDisabledDueToNmsLoss Value    ${selected_nrcell}
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false

Step ${index}: Disable Feature
    Log To Console    Step ${index}: Disable Feature
    coam.perform_parameter_recommissioning    ${selected_nrcell}   disableCellWhenNmsLost    update    false

Step ${index}: Enable Feature When Cell Disable Timer Already Timeout
    Log To Console    Step ${index}: Enable Feature When Cell Disable Timer Already Timeout
    ${rule}    Catenate
    ...    Distname: ${selected_nrcell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003,M55601C01001,M55601C01002;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==1 and sum(M55601C03003)==0 and sum(M55601C01001)>0 and sum(M55601C01002)==1;
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=enb    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    coam.perform_parameter_recommissioning    ${selected_nrcell}   disableCellWhenNmsLost    update    true

Step ${index}: Check Cell Forced Not Gracefull Shutdown
#Step ${index}: Check Cell Forced Gracefull Shutdown Immediately
    Log To Console    Step ${index}: Check Cell Forced Not Gracefull Shutdown
    #${enable_feature_timer}    Get Time    epoch
    #${expected_shutdown_timer}    Evaluate    ${enable_feature_timer} + ${shutdownWindow}
    #Wait Until Keyword Succeeds    5m    10s    coam.Assert    NRCEL    ${selected_nrcell_id}    ${cells_NR_locked_state}
    #${actual_shutdown_timer}    Get Time    epoch
    #Should Be True     ${actual_shutdown_timer} > ${expected_shutdown_timer} -30 and ${actual_shutdown_timer} < ${expected_shutdown_timer} + 30
    Sleep    180s
    Wait Until Keyword Succeeds    300s    15s    Check SBTS SMOD RMOD Cells Alarms
    ${cellDisabledDueToNmsLoss}    Get cellDisabledDueToNmsLoss Value    ${selected_nrcell}
    #Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    true
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false
    #Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}

Step ${index}: Reset Site And Check Cell Status
    Log To Console    Step ${index}: Reset Site And Check Cell Status Counter Values As Expected
    ${rule}    Catenate
    ...    Distname: ${selected_nrcell};
    ...    Counter: M55601C03001,M55601C03002,M55601C03003;
    ...    Counter rule: sum(M55601C03001)==1 and sum(M55601C03002)==0 and sum(M55601C03003)==1;
    ${rule_list}    Create List    ${rule}
    Counter Operation    operation=start_collect_counter    product_type=enb    oam_ip=192.168.255.129
    ...    bts_index=0    cudu_index=0    counter_rule=${rule_list}    interval=5    wait_for_next_counter_generate=True
    coam.reset_site
    #Wait Until Keyword Succeeds    5m    10s
    #...    Check All Cells Status As Expected Status    ${Impacted_Cells}    ${Impacted_Cell_Status}
    #coam.Assert    NRCEL    ${selected_nrcell_id}    ${cells_NR_locked_state}
    Wait Until Keyword Succeeds    20m    30s    Check SBTS SMOD RMOD Cells Alarms
    ${cellDisabledDueToNmsLoss}    Get cellDisabledDueToNmsLoss Value    ${selected_nrcell}
    Should Be Equal As Strings    ${cellDisabledDueToNmsLoss}    false    #true

Step ${index}: Check Counter Value As Expected
    Log To Console    Step ${index}: Check Counter Value As Expected
    Sleep    5m
    Counter Operation    operation=collect_counter_and_check_rule    product_type=enb    bts_index=0    cudu_index=0

Step ${index}: Recover Site
    Log To Console    Step ${index}: Recover Site
    Disable Feature And Recovery NMS Link By Delta Recommision

Disable Feature And Recovery NMS Link By Delta Recommision
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${MRBTS_DN.split('-')[-1]}_${time}_recovery
    coam.append_managed_object_to_delta
    ...    ${mPlaneIpv4AddressDN_new}   delete    ${MRBTS_DN.split('-')[-1]}_${time}_recovery
    coam.append_parameter_update_to_delta    MRBTS-${MRBTS_DN.split('-')[-1]}/MNL-1/MNLENT-1/MPLANENW-1
    ...    mPlaneIpv4AddressDN    ${mPlaneIpv4AddressDN_origin}    ${MRBTS_DN.split('-')[-1]}_${time}_recovery
    coam.append_parameter_update_to_delta    ${selected_nrcell}
    ...    disableCellWhenNmsLost    false    ${MRBTS_DN.split('-')[-1]}_${time}_recovery
    ${delta_json}    coam.get_delta    delta_id=${MRBTS_DN.split('-')[-1]}_${time}_recovery
    ${result}    coam.perform_delta_recommissioning    ${delta_json}
    Wait Until Keyword Succeeds    5m    30s    Check SBTS SMOD RMOD Cells Alarms

Get cellDisabledDueToNmsLoss Value
    [Arguments]     ${selected_nrcell}
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${cellDisabledDueToNmsLoss}    L_XML.Get Element Text    ${full_scf}
    ...    .//managedObject[@distName="${selected_nrcell}"]/p[@name="cellDisabledDueToNmsLoss"]
    [Return]    ${cellDisabledDueToNmsLoss}

TC Setup
    Log    TC Setup    console=True
    Common Test Setup
    coam.perform_parameter_recommissioning
    ...    MRBTS-${MRBTS_DN.split('-')[-1]}/MNL-1/MNLENT-1/FEATCADM-1    actTransportConfigFallback    update    false

TC Teardown
    Log    TC Teardown    console=True
    Particular Teardown

Particular Teardown
    Run Keyword And Ignore Error    Disable Feature And Recovery NMS Link By Delta Recommision
    Common Test Teardown