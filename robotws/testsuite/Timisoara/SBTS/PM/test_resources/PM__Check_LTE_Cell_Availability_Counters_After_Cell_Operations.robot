*** Settings ***
Documentation
...  This TC is checking M8020 counters after performing lock, block and delete operations, individually or sequentially on LTE cell.
...  One LTE cell is randomly chosen. According to CELL_OPERATIONS test variable, TC will perform provided operations.
...  After cell lock and block, M8020 counters should be visible on SBTS.
...  After cell deletion, new counters should not be generated.
...  Cell is restored after each operation and the next one starts when cell is enabled.

Resource  ../../common_resources/ca_PM_general.robot


*** Variables ***
${CELL_OPERATIONS}  ${EMPTY}  # Mandatory. Can be one operation or more. E.g: lock or lock, block, delete.
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${FALSE}


*** Keywords ***
TC__PM__Check_LTE_Cell_Availability_Counters_After_Cell_Operations
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26899
    ...
    ...  *******************
    ...  History of changes
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26899 - PM transfer from Wroslaw
    ...  - 03.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28171 - Exclude NB IoT cells
    ...  - 11.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28740 - Refactor TC to work with lock, block and delete cell operations
    ...  - 05.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29189 - Add option for graceful cell shutdown
    ...  - 23.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29605 - Exclude host cells for NB IoT
    ...  - 13.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30519 - Get SCF file with auto configured parameters

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-jakub.kokoszka@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT

    Step0: TC Prerequisites
    Configure Steps According To Cell Operations Provided


Step0: TC Prerequisites
    Should Not Be Empty  ${CELL_OPERATIONS}  Please provide value for CELL_OPERATIONS variable.
    Log  \nTC will perform following operations: ${CELL_OPERATIONS}.  console=true
    ${operations}  Evaluate  """${CELL_OPERATIONS}""".title().replace(" ","")
    ${operations}  Split String  ${operations}  ,
    Set Test Variable  ${OPERATIONS}

    ${lnbts_id}  Admin Get LNBTS ID
    Set Test Variable  ${LNBTS_ID}
    ${not_iot_cells}  Create List
    ${lncel_objects}  coam.Get Managed Objects  LNCEL_L
    FOR  ${lncel_params}  IN  @{lncel_objects}
        Continue For Loop If  '${lncel_params}[parameters][technology]'=='nbIotFdd' or '${lncel_params}[parameters][nbIotLinkedCellId]'!='None'
        Append To List  ${not_iot_cells}  ${lncel_params}[distName]
    END
    ${lncel_r_dn}  Evaluate  random.choice(${not_iot_cells})  random
    Log  Chosen LTE cell: ${lncel_r_dn}.  console=true
    ${lncel_params}  coam.Get Parameters  ${lncel_r_dn}

    Set Initial Number Of LTE Cells And Chosen Cell R DN  ${lncel_params}[lnCelId]
    Set Test Variable  ${LNCEL_DN}  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${lncel_params}[lnCelId]
    Set Test Variable  ${LCR_ID}  ${lncel_params}[lcrId]
    Set Test Variable  ${LNCEL_NAME}  LNCEL-${lncel_params}[lnCelId]

    Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/PMRNL-1  mtCellAvailability  15min
    coam.Get Current Scf File  ${BTS_Files}  scf.xml  with_auto_configured_parameters=${TRUE}  timeout=60

    IF  ${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}
        Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  enableGrflShdn  Enabled
    ELSE
        Set Parameter To New Value  MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}  enableGrflShdn  Disabled
    END

    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.


Configure Steps According To Cell Operations Provided
    ${index}  Set Variable  0
    FOR  ${operation}  IN  @{OPERATIONS}
        ${index}  Evaluate  ${index}+1
        Log  \nStep${index}: ${operation} LTE Cell  console=true
        IF  "${operation}"=="Lock"
            Lock LTE Cell
        ELSE IF  "${operation}"=="Block"
            Block LTE Cell
        ELSE
            Delete LTE Cell
        END

        ${index}  Evaluate  ${index}+1
        Log  \nStep${index}: Check M8020 Counters After ${operation}  console=true
        Check M8020 Counters  condition=after_${operation}_cell

        ${index}  Evaluate  ${index}+1
        Log  \nStep${index}: Restore LTE Cell After ${operation}  console=true
        IF  "${operation}"=="Lock"
            Unlock LTE Cell
        ELSE IF  "${operation}"=="Block"
            Unblock LTE Cell
        ELSE
            Recreate LTE Cell
        END

        ${index}  Evaluate  ${index}+1
        Log  \nStep${index}: Check M8020 Counters When Cell Is Restored After ${operation}  console=true
        Check M8020 Counters  condition=cell_is_restored_after_${operation}
    END


Set Initial Number Of LTE Cells And Chosen Cell R DN
    [Arguments]  ${cell_id}

    ${current_cells_list}  coam.Get Ids For All  LNCEL
    ${current_cells_num}  Evaluate  len(${CURRENT_CELLS_LIST})
    Set Test Variable  ${CELLS_NUM_ON_START}  ${current_cells_num}
    FOR  ${cell_dn}  IN  @{current_cells_list}
        IF  '${cell_id}' in '${cell_dn}'
            Set Test Variable  ${LNCEL_R_DN}  ${cell_dn}
            BREAK
        END
    END


Delete LTE Cell
    ${delta_id}  Set Variable  delete_lte_cell
    coam.Create Delta  ${delta_id}
    coam.Append Managed Object To Delta  ${LNCEL_DN}  delete  ${delta_id}
    coam.Append Managed Object To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-${LCR_ID}  delete  ${delta_id}
    coam.Get Delta  ${delta_id}
    coam.Save Delta  ${BTS_FILES}/delta.json  ${delta_id}
    coam.Perform Delta Recommissioning  ${BTS_FILES}/delta.json  skip_parameter_relation_errors=True
    coam.Remove Delta  ${delta_id}
    Log  Object ${LNCEL_NAME} and corresponding local cell resource with ID ${LCR_ID} have been removed.  console=true
    Log  Resetting site...  console=true
    coam.Reset Site  timeout=600
    Wait Until Keyword Succeeds  30m  1m
    ...  Check All Cells
    Log  Site reset successful.  console=true
    Reset Admin


Recreate LTE Cell
    coam.Perform Commissioning  ${BTS_ID}  ${BTS_FILES}/scf.xml  skip_parameter_relation_errors=True  timeout=600
    Wait Until Keyword Succeeds  30m  1m
    ...  Admin Check All Required State
    Log  BTS is fully operational.  console=true


Lock LTE Cell
    Perform Parameter Recommissioning  ${LNCEL_DN}  administrativeState  update  locked  skip_parameter_relation_errors=${True}
    ...  timeout=300
    Assert  LNCEL  ${LNCEL_R_DN}  administrativeState=${LOCKED}, operationalState=${DISABLED}  timeout=300


Unlock LTE Cell
    Perform Parameter Recommissioning  ${LNCEL_DN}  administrativeState  update  unlocked  skip_parameter_relation_errors=${True}
    ...  timeout=300
    Assert  LNCEL  ${LNCEL_R_DN}  operationalState=${ENABLED}  timeout=300


Block LTE Cell
    coam.Block Cell  dist_name=${LNCEL_R_DN}  timeout=300
    Assert  LNCEL  ${LNCEL_R_DN}  blockingState=${BLOCKED}, operationalState=${DISABLED}  timeout=300


Unblock LTE Cell
    coam.Unblock Cell  dist_name=${LNCEL_R_DN}  timeout=300
    Assert  LNCEL  ${LNCEL_R_DN}  operationalState=${ENABLED}  timeout=300


Check M8020 Counters
    [Arguments]  ${condition}
    Sleep Until New Cycle  15min
    Sleep  1min  TC will wait until counters are fully loaded.

    IF  "${condition}"=="after_Delete_cell"
        Check M8020 To Be Not Generated
    ELSE
        Check M8020 To Be Generated
    END


Check M8020 To Be Not Generated
    ${list_of_counters2}  coam.Get Pm Counters
    ...  M8020C0,M8020C1,M8020C2,M8020C3,M8020C4,M8020C5,M8020C6,M8020C7,M8020C8,M8020C9,M8020C10,M8020C11,M8020C12
    ${counter00}  Get From Dictionary  ${list_of_counters2}  BTS
    ${counter01}  Get From Dictionary  ${counter00}  MRBTS-${BTS_ID}
    ${counter01a}  Get From Dictionary  ${counter01}  LNBTS-${LNBTS_ID}
    ${counter02}  Get Dictionary Keys  ${counter01a}
    List Should Not Contain Value  ${counter02}  ${LNCEL_NAME}  ${LNCEL_NAME} counters are still available after cell deletion.
    Log  ${LNCEL_NAME} counters are not available.  console=true


Check M8020 To Be Generated
    ${list_of_counters}  coam.Get Pm Counters
    ...  M8020C0,M8020C1,M8020C2,M8020C3,M8020C4,M8020C5,M8020C6,M8020C7,M8020C8,M8020C9,M8020C10,M8020C11,M8020C12
    ${counter0}  Get From Dictionary  ${list_of_counters}  BTS
    ${counter1}  Get From Dictionary  ${counter0}  MRBTS-${BTS_ID}
    ${counter1a}  Get From Dictionary  ${counter1}  LNBTS-${LNBTS_ID}
    ${counter2}  Get Dictionary Keys  ${counter1a}
    List Should Contain Value  ${counter2}  ${LNCEL_NAME}
    Log  ${LNCEL_NAME} counters are available.  console=true


Restore LTE Cell
    ${current_cells_list}  coam.Get Ids For All  LNCEL
    ${current_cells_num}  Evaluate  len(${current_cells_list})
    ${cell_is_locked}  Run Keyword And Return Status  Assert  LNCEL  ${LNCEL_R_DN}  administrativeState=${LOCKED}
    ${cell_is_blocked}  Run Keyword And Return Status  Assert  LNCEL  ${LNCEL_R_DN}  blockingState=${BLOCKED}
    IF  ${cell_is_locked}  Unlock LTE Cell
    IF  ${cell_is_blocked}  Unblock LTE Cell
    IF  ${current_cells_num}!=${CELLS_NUM_ON_START}  Recreate LTE Cell


TC Setup
    Common Test Setup  tc_name=PM__Check_LTE_Counters_After_Cell_Operations


TC Teardown
    Run Keyword If Test Failed  Restore LTE Cell
    Common Test Teardown
