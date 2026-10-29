*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.51_Snapshot_Collection
...  AUTHORS:       jakub.hirny@nokia.com
...  MAINTAINER:    VRF_WRO3_T02
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform multiple snapshot collections in a row
...  EDA Action Task For 05057438 - New TC with multiple snapshot collections - https://jiradc.ext.net.nokia.com/browse/RDI-29872
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  18.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-29518 - Test creation
...  *******************
...  VRF_WRO3_T02 TEMPLATE

*** Variables ***
${SNAPSHOT_TYPE}                    Snapshot    #possible values Snapshot or SCREL
${DEFAULT_COLLECTION_ITERATIONS}    10

*** Keywords ***
SM.51_Snapshot_Collection
    SM.51_Snapshot_Collection.Test_Step:0 Test Preparation
    SM.51_Snapshot_Collection.Test_Step:1 Perform Collection
    SM.51_Snapshot_Collection.Test_Step:2 Check BTS

SM.51_Snapshot_Collection.Test_Step:0 Test Preparation
    Log To Console  \n========================================
    Log To Console  Step: 0 Test Preparation
    Log to console  ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Check If NLWG Cells Are OnAir
    SCF Backup

SM.51_Snapshot_Collection.Test_Step:1 Perform Collection
    Log To Console  \n========================================
    Log To Console  Step: 1 Perform Snapshot Collection
    Log To Console  ========================================
    ${SNAPSHOT_COLLECTION_ITERATIONS}  Convert To Integer  ${SNAPSHOT_COLLECTION_ITERATIONS}
    ${destination_path}  Set Variable  ${RESULTS}/${ITERATION_INDEX}
    ${failed_collection}  Create List
    FOR  ${collection_iteration}  IN RANGE  1  ${SNAPSHOT_COLLECTION_ITERATIONS+1}
        Wait Until Keyword Succeeds  40x  30s  Ensure Snapshot Collection Is Not Ongoing  collection_type=${SNAPSHOT_TYPE}
        Log To Console  Performing ${SNAPSHOT_TYPE} Collection ${collection_iteration}/${SNAPSHOT_COLLECTION_ITERATIONS}...
        ${snapshot_file_name}  Set Variable  ${ITERATION_INDEX}_${collection_iteration}_${SNAPSHOT_TYPE}_mrbts-${MRBTS_ID}.zip
        ${collection_status}  ${collection_message}  IF  '${SNAPSHOT_TYPE.upper()}'!='SCREL'  Run Keyword And Ignore Error
        ...                                              Collect Snapshot     target_file_name=${destination_path}/${snapshot_file_name}  timeout=1500
        ...                                        ELSE  Run Keyword And Ignore Error
        ...                                              Collect Local SCREL  target_file_name=${destination_path}/${snapshot_file_name}  timeout=600
        IF  '${collection_status}'=='PASS'  OperatingSystem.Remove File  ${destination_path}/${snapshot_file_name}
        ...                           ELSE  Append To List  ${failed_collection}  ${snapshot_file_name}: ${collection_message}

        Log To Console  Performing ims2 Collection ${collection_iteration}/${SNAPSHOT_COLLECTION_ITERATIONS}...
        ${ims_file_name}       Set Variable  ${ITERATION_INDEX}_${collection_iteration}_ims2_mrbts-${MRBTS_ID}.ims2
        ${ims_collection_status}  ${ims_collection_message}  Run Keyword And Ignore Error
        ...                                                  Collect Im Snapshot  target_file_name=${destination_path}/${ims_file_name}
        IF  '${collection_status}'=='FAIL' and '${ims_collection_status}'=='PASS'  CONTINUE
        ...                           ELSE IF  '${ims_collection_status}'=='FAIL'  Append To List  ${failed_collection}
        ...                                                                                        ${ims_file_name}: ${ims_collection_message}
        ...                           ELSE                                         OperatingSystem.Remove File  ${destination_path}/${ims_file_name}
    END
    IF  ${failed_collection}!=[]  Fail  msg=Failed collection: ${failed_collection}

SM.51_Snapshot_Collection.Test_Step:2 Check BTS
    Log To Console  \n========================================
    Log To Console  Step: 2 Check BTS
    Log To Console  ========================================
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.51_Snapshot_Collection.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY

SM.51_Snapshot_Collection.Test Case Setup
    ${SNAPSHOT_COLLECTION_ITERATIONS}  Get Variable Value  ${SNAPSHOT_COLLECTION_ITERATIONS}
    Run Keyword If  ${SNAPSHOT_COLLECTION_ITERATIONS} == None  Run Keywords
    ...             Set Suite Variable  ${SNAPSHOT_COLLECTION_ITERATIONS}  ${DEFAULT_COLLECTION_ITERATIONS}
    ...        AND  Log  Variable SNAPSHOT_COLLECTION_ITERATIONS was not set... setting it to '${DEFAULT_COLLECTION_ITERATIONS}'  WARN

# Test Related Keywords
Get Snapshot Collection State
    [Arguments]  ${collection_type}=Snapshot
    [Documentation]  Supported collection types: Snapshot/SCREL
    ${collection_type}  Evaluate  '${collection_type}'.upper()
    ${TRBLCADM_R_params}  admin.Get Managed Objects  TRBLCADM_R
    ${state_to_check}  Set Variable If  '${collection_type}'=='SCREL'  sysCriticalEventLogState  diagSnapState
    [Return]  ${TRBLCADM_R_params}[0][parameters][${state_to_check}]

Ensure Snapshot Collection Is Not Ongoing
    [Arguments]  ${collection_type}=Snapshot
    [Documentation]  Supported collection types: Snapshot/SCREL
    ${collection_state}  Get Snapshot Collection State  collection_type=${collection_type}
    ${collection_state}  Convert to String  ${collection_state}
    Should Not Contain Any  ${collection_state}  ongoing  requested  ignore_case=True
