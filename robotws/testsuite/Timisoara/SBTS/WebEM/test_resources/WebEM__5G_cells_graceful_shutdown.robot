*** Settings ***
Documentation
    ...  This test case is created to check gracefully shutdown of the NR cells.
    ...  Verify if all cells on SBTS are working and NR cells administrativeState status to be unlocked.
    ...  Parameter actGrflShdn will be set to true.
    ...  Parameter administrativeState will be set to Shutting Down and verify if NR cells administrativeState status
    ...  is changed to shutting down and after that cells become locked.
    ...  Parameter administrativeState will be set to Unlocked and verify if NR cells administrativeState status
    ...  is changed to unlocked.
    ...  Parameter actGrflShdn will be set to initial value.
    ...  Verify if all cells on SBTS are working.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600  # Time for SBTS to recover, default value is 600s
${LOCKED_TIMEOUT}  300  # Time for cells to be locked, default value is 300s


*** Keywords ***
TC__WebEM__5G_cells_graceful_shutdown
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21262
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.04.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21262 - Initial TAT creation
    ...  - 20.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 08.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24623 - Refactor the TC with Perform Parameter Recommissioning KW
    ...  - 21.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28793 - Replace infomodel checks with taf

    Set Tags  CA-WebEM  OWNER-emina.stefanovici@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1:Verify Cells On SBTS
    Step2:Change Parameter ActGrflShdn To Be true
    Step3:Change Parameter AdministrativeState To Shutting Down
    Step4:Change Parameter AdministrativeState To Unlocked
    Step5:Change Parameter ActGrflShdn To Be false
    Step6:Verify All Cells


Step1:Verify Cells On SBTS
    Log  Step1:Verify cells on SBTS  console=true
    Log  Verify if NR cells exist  console=true
    IF  ${SCF_COUNT_NR}
        Log  NR cells exist![OK]  console=true
    ELSE
        Fail  NR cells doesn't exist![NOK]
    END
    Check All Cells
    Check NR Cells  ${UNLOCKED}


Step${index}:Change Parameter ActGrflShdn To Be ${value}
    Log  Step${index}:Change parameter actGrflShdn to be ${value}  console=true
    ${nrbts_dn}  Get Id For Current  NRBTS
    ${nrbts_id}  Fetch From Right  ${nrbts_dn}  NRBTS_R-
    Set Test Variable  ${NRBTS_ID}
    ${act_grfl_shdn_status}  Run Keyword And Return Status
    ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  actGrflShdn  update  ${value}  skip_parameter_relation_errors=true
    IF  ${act_grfl_shdn_status}
        Log  Parameter actGrflShdn is set to ${value}![OK]  console=true
    ELSE
        Fail  Parameter actGrflShdn is not set to ${value}![NOK]
    END


Step3:Change Parameter AdministrativeState To Shutting Down
    Log  Step3:Change parameter administrativeState to Shutting Down  console=true
    ${nrcel_ids}  coam.Get Ids For All  NRCEL
    ${cells_id_list}  Create List
    FOR  ${cell}  IN  @{nrcel_ids}
        ${cell_id}  Fetch From Right  ${cell}  -
        Append To List  ${cells_id_list}  ${cell_id}
    END
    Sort List  ${cells_id_list}
    Set Test Variable  ${CELLS_ID_LIST}
    ${length_cell_id_list}  Get Length  ${CELLS_ID_LIST}
    Set Test Variable  ${LENGTH_CELL_ID_LIST}
    FOR  ${index}  IN RANGE  0  ${LENGTH_CELL_ID_LIST}
        ${administrative_state_status}  Run Keyword And Return Status
        ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELLS_ID_LIST}[${index}]
        ...  administrativeState
        ...  update
        ...  Shutting Down
        ...  skip_parameter_relation_errors=true
        IF  ${administrative_state_status}
            Log  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is set to Shutting Down![OK]  console=true
        ELSE
            Fail  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is not set to Shutting Down![NOK]
        END
        Verify AdministrativeState Value  ${CELLS_ID_LIST}[${index}]  ${SHUTTING_DOWN}
    END
    Log  Wait for all NR cells to be Locked!  console=true
    ${status_cells_locked}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${LOCKED_TIMEOUT}  10
    ...  Check NR Cells  ${LOCKED}
    IF  ${status_cells_locked}
        Log  All cells are locked!  console=true
    ELSE
        Set Test Restriction  Cells are different than expected [NOK]
    END


Step4:Change Parameter AdministrativeState To Unlocked
    Log  Step4:Change parameter administrativeState to Unlocked  console=true
    FOR  ${index}  IN RANGE  0  ${LENGTH_CELL_ID_LIST}
        ${status}  Run Keyword And Return Status
        ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELLS_ID_LIST}[${index}]
        ...  administrativeState
        ...  update
        ...  Unlocked
        ...  skip_parameter_relation_errors=true
        IF  ${status}
            Log  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is set to Unlocked![OK]  console=true
        ELSE
            Fail  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is not set to Unlocked![NOK]
        END
        Verify AdministrativeState Value  ${CELLS_ID_LIST}[${index}]  ${UNLOCKED}
    END
    Log  Wait for all NR cells to be Unlocked!  console=true
    ${status_cells_unlocked}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check NR Cells  ${UNLOCKED}
    IF  ${status_cells_unlocked}
        Log  All cells are unlocked!  console=true
    ELSE
        Fail  Cells are different than expected![NOK]
    END


Step6:Verify All Cells
    Log  Step6:Verify all cells  console=true
    ${status_cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status_cells}
        Log  All cells are onAir!  console=true
    ELSE
        Fail  Cells are different than expected![NOK]
    END


Check NR Cells
    [Arguments]  ${administrative_state}

    Assert Every  NRCEL  administrativeState=${administrative_state}  timeout=60


Verify AdministrativeState Value
    [Arguments]  ${cell_id}  ${value}

    FOR  ${cell_dn}  IN  @{ALL_AVAILABLE_CELLS}
        ${status}  Run Keyword And Return Status  Should End With  ${cell_dn}  NRCELL_R-${cell_id}
        IF  ${status}==${FALSE}  CONTINUE
        Assert  NRCEL  ${cell_dn}  administrativeState=${value}  timeout=300
        Log  Value of administrativeState for NRCELL-${cell_id} is ${value}!  console=true
    END


Restore AdministrativeState Parameter
    FOR  ${index}  IN RANGE  0  ${LENGTH_CELL_ID_LIST}
        ${status}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
        ...  Perform Parameter Recommissioning  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${CELLS_ID_LIST}[${index}]
        ...  administrativeState
        ...  update
        ...  Unlocked
        ...  skip_parameter_relation_errors=true
        IF  ${status}
            Log  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is set to Unlocked![OK]  console=true
        ELSE
            Fail  Parameter administrativeState for NRCELL-${CELLS_ID_LIST}[${index}] is not set to Unlocked![NOK]
        END
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check NR Cells  ${UNLOCKED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


TC Setup
    Common Test Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore AdministrativeState Parameter
    Common Test Teardown
