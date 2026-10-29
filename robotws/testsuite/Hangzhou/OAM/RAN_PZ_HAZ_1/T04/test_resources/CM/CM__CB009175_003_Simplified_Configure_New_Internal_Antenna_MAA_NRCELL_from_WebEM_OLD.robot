*** Settings ***
Documentation       Test suite for RAN_ST_CB009175_003
...                 Author: Kang Lixin
...                 Contact: lixin.kang@nokia-sbell.com
Resource          ../../resources/hran_frame_taf_oam.robot

*** Variables ***
${CELL_NAME}      ${EMPTY}
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
@{IGNORE_ALARM_FILTER_STRING}    {'Fault ID':'61649'}    { 'Fault ID':'6286'}    {'Fault ID':'6450'}    { 'Fault ID':'61524'}
    ...    { 'Fault ID':'61074'}    { 'Fault ID':'4655'}    { 'Fault ID':'61652'}
    ...   { 'Fault ID':'4654'}    {'Fault ID':'2403','Alarm ID': '7115'}
@{MMA_RMOD_PREFIX}    AE    AQ
${nrCellType_ui}   4DL4UL
&{mandatory_cell_param_to_update_ui}    Activate super cell=false    Activate Beamforming=true    Activate external antenna beamforming=false
&{specific_nrbts_param_to_update_ui}    Activate ANR for EN-DC with resolution of unknown cells=false
...    Activate robust header compression=false
...    Activate ANR for SA with resolution of unknown E-UTRA cells=false
...    Activate ANR for SA with resolution of unknown cells based on inter frequency UE measurements=false
...    Activate normal voice call fallback to LTE=false
${RECOVERY_FLAG}           ${False}

*** Keywords ***
CM__CB009175_003_Simplified_Configure_New_Internal_Antenna_MAA_NRCELL_from_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:
    ...   RAN_ST_CB009175_003_CM_Configure new internal antenna MAA NRCELL Channel Groups and Channels using Simplified method from WebEM
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 17.08.2023 - Commit to robotws
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: TC Preparation
    Step 2: Create MAA NRCELL Use Simplified Method
    Step 3: Provision Plan From PE
    Step 4: Check BTS Onair After New NRCELL Added
    Step 5: Check Cell Should Be Exist
    Step 6: Check Channels and Channel Groups Auto Created
    Step 7: Check RF Diagnostic Test Result
    Step 8: Check No Alarm Should Be Raised

SetUp
    Log To Console    SetUp
    Common Test Setup SBTS
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}
    SBTS WEM BackUp Current Configuration    https://${MPLANE_IP}    skip_error=${True}    windows_index=${win_index}
    Status Of RAT Should Be OK
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Global Variable    ${ALARMS_BEFORE_TEST}    ${alarms}
    ${filter_list}    Create List
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}

TearDown
    Log To Console    TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Run Keyword If    ${RECOVERY_FLAG}    SBTS WEM Activate Planed BTS Configuration
    Common Test Teardown SBTS
    [Teardown]    Close All Browsers

Step ${index}: TC Preparation
    Log To Console    Step ${index}: TC Preparation
    Remove One NR Cell By PE
    Validate And Activate Plan
    ${cells}    SBTS WEM Get Cells Name And Path    NR
    Dictionary Should Not Contain Key    ${cells}    ${CELL_NAME.split('/')[-1]}
    Set Test Variable    ${RECOVERY_FLAG}   ${True}

Remove One NR Cell By PE
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    ${RMOD_list}    coam.Get Parameters For All    RMOD
    ${MMA_RF_list}    Create List
    FOR    ${rmod}    IN    @{RMOD_list}
        ${productName}    Set Variable    ${rmod['productName']}
        ${is_support_maa}    Check RMOD Supoort mMimo    ${productName}
        Run Keyword If    ${is_support_maa}    Append To List    ${MMA_RF_list}     ${rmod['id']}
    END
    ${rmod_cells_mapping}     Get Relationship Between RMODs And Cells
    ${all_maa_nrcell_id_list}    Create List
    FOR    ${rmod}    IN    @{MMA_RF_list}
        ${cell_list}    Set Variable    ${rmod_cells_mapping['${rmod}']['activeNrCellsList']}
        ${all_maa_nrcell_id_list}    Combine Lists    ${all_maa_nrcell_id_list}    ${cell_list}
    END
    ${selected_nrcell_inter_id}    Evaluate    random.choice(${all_maa_nrcell_id_list})    modules=random, sys
    ${cell_mapping}    Fetch ID Mapping From Admin For Cells    NRBTS    ${selected_nrcell_inter_id}    internal
    Set Test Variable    ${CELL_NAME}    ${cell_mapping['configuration']}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${CELL_NAME}    ${CELL_NAME.split('/')[-1]}
    ${full_object_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${CELL_NAME}    ${CELL_NAME.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=Local cell resource ID
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Should Be Equal As Integers    ${parameters.__len__()}    ${1}
    ${lCelnrId}    Set Variable    ${parameters[0]['actual_value']}
    ${full_object_path}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    LCELNR-${lCelnrId}    LCELNR-${lCelnrId}
    Set Test Variable    ${CELL_MAPPING_OBJECT_PATH}    ${full_object_path}
    ${MOs}    Get Objects By Condition    MRBTS/NRBTS/NRCELLGRP[List of NR cells assigned to cell group(!)#1=${lCelnrId}]
    Set Test Variable    ${CELL_GROUP_MO_PATH}    ${MOs[0]}
    ${cell_group_id}    Set Variable    ${CELL_GROUP_MO_PATH.split('/')[-1].split('-')[-1]}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${CELL_MAPPING_OBJECT_PATH}    ${CELL_MAPPING_OBJECT_PATH.split('/')[-1]}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${CELL_GROUP_MO_PATH}    ${CELL_GROUP_MO_PATH.split('/')[-1]}
    ${nrdu}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    NRDU-    NRDU-
    SBTS WEM Filt Parameter    form_param_name=Reference to cell group
    ${parameters}    SBTS WEM Get Parameters In PE Table
    ${sub_item_name}    Set Variable
    FOR    ${param}    IN    @{parameters}
        ${sub_item_name}    Set Variable If    "${cell_group_id}"=="${param['actual_value']}"    ${param['list_lable']}    ${EMPTY}
        Exit For Loop If    "${cell_group_id}"=="${param['actual_value']}"
    END
    Run Keyword If    '${sub_item_name}'==''    Fail    Cannot find the Reference to cell group
    ${succeed}    SBTS WEM Click Action In PE Table    ${nrdu}    Reference to cell group    Remove Element    ${sub_item_name}
    Should Be True    ${succeed}
    ${params}    Get Dictionary Keys   ${specific_nrbts_param_to_update_ui}
    ${NRBTS_NAME}    Remove String    ${CELL_NAME}    /${CELL_NAME.split('/')[-1]}
    FOR    ${param}    IN    @{params}
        SBTS WEM Modify Parameters In PE Table    ${NRBTS_NAME}    ${param}    ${specific_nrbts_param_to_update_ui['${param}']}
    END

Step ${index}: Provision Plan From PE
    Log To Console    Step ${index}: Provision Plan From PE
    Validate And Activate Plan

Step ${index}: Create MAA NRCELL Use Simplified Method
    LOG    Step ${index}: Create MAA NRCELL Use Simplified Method   console=${True}
    FOR    ${MO}    IN    ${CELL_NAME}    ${CELL_MAPPING_OBJECT_PATH}    ${CELL_GROUP_MO_PATH}
        ${class}    Set Variable    ${MO.split('/')[-1].split('-')[0]}
        ${object_id}    Set Variable    ${MO.split('/')[-1].split('-')[1]}
        ${parent_path}    Set Variable    ${MO.split('/${class}')[0]}
        ${parent_name}    Set Variable    ${parent_path.split('/')[-1]}
        ${param1}    Create List    Object class:    selectedlist    ${class}
        ${param2}    Create List    Load default values:    checkbox    ${False}
        ${param3}    Create List    Plan to copy from:    selectedlist    CM_TA_BACKUP
        ${param4}    Create List    Copy from:    selectedlist    ${MO}
        ${param5}    Create List    Including subobjects:    checkbox    ${True}
        ${param6}    Create List    ID:    textbox    ${object_id}
        ${params}    Create List    ${param1}    ${param2}    ${param3}    ${param4}    ${param5}    ${param6}
        ${created_object_path}    SBTS WEM Add Object On Navigation Panell Under Pramater Editor    ${parent_path}    ${parent_name}    ${params}
    END
    ${sub_obj}    SBTS WEM Get Sub-objects On Navigation Panel Under Pramater Editor    ${CELL_MAPPING_OBJECT_PATH.split('/')[-1]}
    ${new_add_channel_list}    Create List
    ${new_add_channelgroup_list}    Create List
    FOR    ${obj}    IN    @{sub_obj}
        ${obj_type}    Set Variable    ${obj.split('/')[-1]}
        Run Keyword If    '${obj_type.split("-")[0]}'=='CHANNELGROUP'    Append To List    ${new_add_channelgroup_list}    ${obj}
        Run Keyword If    '${obj_type.split("-")[0]}'=='CHANNEL'    Append To List    ${new_add_channel_list}    ${obj}
    END
    Sort List    ${new_add_channelgroup_list}
    Sort List    ${new_add_channel_list}
    Remove Values From List    ${new_add_channelgroup_list}    ${new_add_channelgroup_list[0]}
    Remove Values From List    ${new_add_channel_list}    ${new_add_channel_list[0]}
    Set Test Variable    ${new_add_channelgroup_list}
    Set Test Variable    ${new_add_channel_list}
    ${auto_create_obj}    Combine Lists   ${new_add_channelgroup_list}    ${new_add_channel_list}
    FOR    ${obj}    IN    @{auto_create_obj}
        SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${obj}    ${obj.split('/')[-1]}
    END
    ${cell_group_id}    Set Variable    ${CELL_GROUP_MO_PATH.split('/')[-1].split('-')[-1]}
    SBTS WEM Set New Add Sub-Item In PE    NRDU-    Reference to cell group    ${cell_group_id}
    SBTS WEM Modify Parameters In PE Table    ${CELL_NAME}    Local cell resource ID    ${CELL_NAME.split('-')[-1].strip()}
    ${param_name}    Get Dictionary Keys    ${mandatory_cell_param_to_update_ui}
    FOR    ${name}    IN    @{param_name}
        SBTS WEM Modify Parameters In PE Table    ${CELL_NAME}    ${name}    ${mandatory_cell_param_to_update_ui['${name}']}
    END
    SBTS WEM Modify Parameters In PE Table    ${CELL_MAPPING_OBJECT_PATH}    Activate simplified MAA NRCELL channel config    true
    Set Test Variable    ${auto_create_obj}

Step ${index}: Check No Alarm Should Be Raised
    LOG    Step ${index}: Check No Alarm Should Be Raised    console=${True}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Global Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Step ${index}: Check Cell Should Be Exist
    log    Step ${index}: Check Cell Should Be Exist    console=${True}
    ${cells}    SBTS WEM Get Cells Name And Path    NR
    Dictionary Should Contain Key    ${cells}    ${CELL_NAME.split('/')[-1]}

Step ${index}: Check BTS Onair After New NRCELL Added
    [Documentation]    RATs status should keep on air during the setup of new NR cell
    Log To Console    Step ${index}: Check BTS Onair After New NRCELL Added
    Wait Until Keyword Succeeds    30x    5s    Check RAT And Cells Status Should be OK

Step ${index}: Check Channels and Channel Groups Auto Created
    Log To Console    Step ${index}: Check Channels and Channel Groups Auto Created
    Selenium Login
    ${nrcell_name}    Fetch From Right    ${selected_maa_nrcell}    /
    ${TX_num}    ${RX_num}    Get MAA Cell TRX Num From Detailed Site View Via Selenium    ${nrcell_name}
    ${type}    Set Variable    ${nrCellType_ui.replace('DL','-').replace('UL','').split('-')}
    Should Be Equal As Integers    ${TX_num}    ${type[0]}
    Should Be Equal As Integers    ${RX_num}    ${type[-1]}
    Selenium Logout

Step ${index}: Check RF Diagnostic Test Result
    Log To Console    Step ${index}: Check RF Diagnostic Test Result
    Run RF Diagnostic Test    ${CELL_NAME.split('/')[-1].split('-')[-1]}    NR
    Get And Check RF Diagnostic Test Result 5G

Check RAT And Cells Status Should be OK
    ${rat_status}    SBTS WEM Get RAT Status
    ${rats}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{rats}
        Should Be Equal As Strings    On air    ${rat_status['${rat}']['rat_state']}
        Should Be Equal As Strings    All cells enabled    ${rat_status['${rat}']['cell_state']}
    END

Check RMOD Supoort mMimo
    [Arguments]     ${rmod_pro_name}
    FOR    ${prefix}    IN    @{MMA_RMOD_PREFIX}
        ${is_support}    Run Keyword And Return Status    Should Start With    ${rmod_pro_name}    ${prefix}
        Return From Keyword If    ${is_support}    True
    END
    [Return]     False

Validate And Activate Plan
    SBTS WEM Validate Plan
    Should Only Has Sector Configuration Error Or Not
    SBTS WEM Activate Current BTS Configuration