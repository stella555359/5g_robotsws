*** Settings ***
Documentation
    ...  This test case verifies Tx/Rx failure detection and recovery behavior with different
    ...  nonCritTrxFailRecoveryCtrl settings (Off, SingleAndForcedRec, Multiple).
    ...  Tests recovery behavior on different RMOD types (AHLOA, AHFIG, OBSAI) with different cell technologies.
    ...  RMOD reset before fault triggering is optional: when RMOD_RESET_NEEDED is True, Perform RMOD Reset is executed for each RMOD
    ...  before faults; when False, reset is skipped (faults are triggered without prior reset).
    ...  Verifies that recovery is not performed for RMODs with GSM cells and for faults with MAJOR severity in certain conditions.
    ...  Tests Maintenance Window recovery behavior with multiple RMODs in degraded state.
    ...  STARTUP: Fault must be triggered within 4 minutes after radio detection to avoid runtime reset recovery.
    ...  RUNTIME: Fault must be triggered after 4 minutes from radio detection.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300s  # [in seconds] Timeout for alarm to be reported in WebEM and Netact
${FIRST_CPRI_RMOD}  AHLOA  # First CPRI RMOD type used in test
${SECOND_CPRI_RMOD}  AHFIG  # Second CPRI RMOD type used in test
${RMOD_RESET_NEEDED}  ${FALSE}  # Set to ${TRUE} to perform RMOD reset before faults, ${FALSE} to skip reset
                                # Set to ${TRUE} for branches < 26R1, ${FALSE} for branches >= 26R1
                                # For branches >= 26R1, if triggering faults in startup/runtime is needed, should be set to ${TRUE}

*** Keywords ***
TC__FM__OAM_Exploratory_Tx_Rx_Failure_detection
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30276
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30276 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504

    Step 0: Select And Store All RMODs Information
    Step 1: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Off
    Step 2: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Single
    Step 3: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Multiple


Step 0: Select And Store All RMODs Information
    Log  \nStep 0: Select And Store All RMODs Information  console=true

    IF  '${ENB_BRANCH}'<'SBTS26R1'  Set Test Variable  ${RMOD_RESET_NEEDED}  ${TRUE}
    # TODO: Uncomment this when the test is updated to trigger faults in startup/runtime - and decide which faults should be triggered in runtime
    # ${RUNTIME}  Set Variable If  ${RMOD_RESET_NEEDED}  ${TRUE}  ${FALSE}
    # Set Test Variable  ${RUNTIME}

    Change FMCADM Parameter  actForceUnitAutoReset  true
    ${rmods_list}  Create List

    Log  Selecting ${FIRST_CPRI_RMOD} CPRI RMOD...  console=true
    ${rmod1}  Get CPRI RMOD Info In A Dictionary  rmod_type=${FIRST_CPRI_RMOD}
    Append To List  ${rmods_list}  ${rmod1}
    Set Test Variable  ${RMOD_${FIRST_CPRI_RMOD}_INDEX}  0

    Log  Selecting ${SECOND_CPRI_RMOD} CPRI RMOD with GSM cells...  console=true
    ${rmod2}  Get CPRI RMOD Info In A Dictionary  rmod_type=${SECOND_CPRI_RMOD}  cells_type=GNCEL
    Append To List  ${rmods_list}  ${rmod2}
    Set Test Variable  ${RMOD_${SECOND_CPRI_RMOD}_INDEX}  1

    Log  Selecting OBSAI RMODs...  console=true
    ${obsai_rmods_list}  Get List Of OBSAI RMODs  obsai_rmod_type=FXDB
    ${rmod3}  Get Random OBSAI RMOD Info In A Dictionary  obsai_rmods_list=${obsai_rmods_list}
    Set To Dictionary  ${rmod3}  type=FIRST_OBSAI - FXDB
    Append To List  ${rmods_list}  ${rmod3}
    Set Test Variable  ${RMOD_OBSAI1_INDEX}  2

    ${rmod4}  Get Random OBSAI RMOD Info In A Dictionary  obsai_rmods_list=${obsai_rmods_list}
    Set To Dictionary  ${rmod4}  type=SECOND_OBSAI - FXDB
    Append To List  ${rmods_list}  ${rmod4}
    Set Test Variable  ${RMOD_OBSAI2_INDEX}  3

    Set Test Variable  ${RMODS_LIST}  ${rmods_list}
    Log  Selected RMODs:  console=true
    Log  - First CPRI RMOD (${FIRST_CPRI_RMOD}, index 0): ${rmod1}[dn]  console=true
    Log  - Second CPRI RMOD (${SECOND_CPRI_RMOD}, index 1): ${rmod2}[dn]  console=true
    Log  - First OBSAI RMOD (index 2): ${rmod3}[dn]  console=true
    Log  - Second OBSAI RMOD (index 3): ${rmod4}[dn]  console=true
    Log  Note: side, ip and stored_role will be populated after each RMOD reset  console=true


Step 1: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Off
    Log  \nStep 1: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Off  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Off
    Maintenance Window Cleanup
    Perform Site Reset

    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded
    ...  rmod_index=${RMOD_${FIRST_CPRI_RMOD}_INDEX}  variable_prefix=${FIRST_CPRI_RMOD}_OFF
    Trigger Fault 1911 On RMOD From List With GSM Cells - No Recovery
    ...  rmod_index=${RMOD_${SECOND_CPRI_RMOD}_INDEX}  variable_prefix=${SECOND_CPRI_RMOD}_OFF
    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded  rmod_index=${RMOD_OBSAI1_INDEX}  variable_prefix=OBSAI1_OFF
    Trigger Fault 1908 On RMOD From List - No Recovery  rmod_index=${RMOD_OBSAI2_INDEX}  variable_prefix=OBSAI2_OFF

    Create Maintenance Window
    Verify Maintenance Window Recovery For RMODs With Recovery Counter - Off Mode
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Step 2: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Single
    Log  \nStep 2: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Single  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  SingleAndForcedRec
    Perform Site Reset

    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded
    ...  rmod_index=${RMOD_${FIRST_CPRI_RMOD}_INDEX}  variable_prefix=${FIRST_CPRI_RMOD}_SINGLE
    Trigger Fault 1911 On RMOD From List With GSM Cells - No Recovery
    ...  rmod_index=${RMOD_${SECOND_CPRI_RMOD}_INDEX}  variable_prefix=${SECOND_CPRI_RMOD}_SINGLE
    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded  rmod_index=${RMOD_OBSAI1_INDEX}  variable_prefix=OBSAI1_SINGLE
    Trigger Fault 1908 On RMOD From List - Single Recovery Then No Recovery  rmod_index=${RMOD_OBSAI2_INDEX}  variable_prefix=OBSAI2_SINGLE

    Create Maintenance Window
    Verify Maintenance Window Recovery For RMODs With Recovery Counter  mode=SINGLE
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Step 3: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Multiple
    Log  \nStep 3: Trigger Faults On Multiple RMODs With nonCritTrxFailRecoveryCtrl Set To Multiple  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Multiple
    Perform Site Reset

    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded
    ...  rmod_index=${RMOD_${FIRST_CPRI_RMOD}_INDEX}  variable_prefix=${FIRST_CPRI_RMOD}_MULTIPLE
    Trigger Fault 1911 On RMOD From List With GSM Cells - No Recovery
    ...  rmod_index=${RMOD_${SECOND_CPRI_RMOD}_INDEX}  variable_prefix=${SECOND_CPRI_RMOD}_MULTIPLE
    Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded  rmod_index=${RMOD_OBSAI1_INDEX}  variable_prefix=OBSAI1_MULTIPLE
    Trigger Fault 1908 On RMOD From List - Recovery 3 Times Then Degraded  rmod_index=${RMOD_OBSAI2_INDEX}  variable_prefix=OBSAI2_MULTIPLE

    Create Maintenance Window
    Verify Maintenance Window Recovery For RMODs With Recovery Counter  mode=MULTIPLE
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Trigger Fault 1911 On RMOD From List - Recovery 3 Times Then Degraded
    [Arguments]  ${rmod_index}  ${variable_prefix}

    ${rmod_data}  Get From List  ${RMODS_LIST}  ${rmod_index}
    Log  \nTrigger Fault 1911 On ${rmod_data}[type] RMOD (${rmod_data}[dn]) - Recovery 3 Times Then Degraded (${variable_prefix})  console=true

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${rmod_data}
    Update RMOD Side IP And Stored Role By Serial Number  ${rmod_data}

    IF  '${rmod_data}[type]' in ['${FIRST_CPRI_RMOD}', '${SECOND_CPRI_RMOD}']
        ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
        Repeat Keyword  3x  Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
        ...                                                              rmod_side=${rmod_data}[side]
        ...                                                              rmod_stored_role=${rmod_data}[stored_role]
        ...                                                              rmod_ip=${rmod_data}[ip]
        ...                                                              rmod_user=${rmod_data}[user]
        ...                                                              rmod_password=${rmod_data}[password]
        ...                                                              commands=${commands}
        ...                                                              rmod_dn=${rmod_data}[dn]
        ...                                                              rmod_dn_nms=${rmod_data}[dn_nms]
        ...                                                              rmod_cells=${rmod_data}[cells]
        ...                                                              state=recovered

        ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
        Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911}
        ...                                          rmod_side=${rmod_data}[side]
        ...                                          rmod_stored_role=${rmod_data}[stored_role]
        ...                                          rmod_ip=${rmod_data}[ip]
        ...                                          rmod_user=${rmod_data}[user]
        ...                                          rmod_password=${rmod_data}[password]
        ...                                          commands=${commands}
        ...                                          rmod_dn=${rmod_data}[dn]
        ...                                          rmod_dn_nms=${rmod_data}[dn_nms]
        ...                                          rmod_cells=${rmod_data}[cells]
        ...                                          state=degraded
    ELSE
        ${commands}  Create List  sendFault 1130 3 0 0 0 0 0
        Repeat Keyword  3x  Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
        ...                                                               rmod_ip=${rmod_data}[ip]
        ...                                                               rmod_stored_role=${rmod_data}[stored_role]
        ...                                                               rmod_side=${rmod_data}[side]
        ...                                                               commands=${commands}
        ...                                                               rmod_dn=${rmod_data}[dn]
        ...                                                               rmod_dn_nms=${rmod_data}[dn_nms]
        ...                                                               rmod_cells=${rmod_data}[cells]
        ...                                                               state=recovered

        ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
        Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1911}
        ...                                           rmod_ip=${rmod_data}[ip]
        ...                                           rmod_stored_role=${rmod_data}[stored_role]
        ...                                           rmod_side=${rmod_data}[side]
        ...                                           commands=${commands}
        ...                                           rmod_dn=${rmod_data}[dn]
        ...                                           rmod_dn_nms=${rmod_data}[dn_nms]
        ...                                           rmod_cells=${rmod_data}[cells]
        ...                                           state=degraded
    END

    Set Test Variable  ${${variable_prefix}_TIME_FROM_MAJOR_ALARM}  ${time_from_major_alarm}


Trigger Fault 1911 On RMOD From List With GSM Cells - No Recovery
    [Arguments]  ${rmod_index}  ${variable_prefix}

    ${rmod_data}  Get From List  ${RMODS_LIST}  ${rmod_index}
    Log  \nTrigger Fault 1911 On ${rmod_data}[type] RMOD With GSM Cells (${rmod_data}[dn]) - No Recovery (${variable_prefix})  console=true

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${rmod_data}
    Update RMOD Side IP And Stored Role By Serial Number  ${rmod_data}

    ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
    Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911}
    ...                                          rmod_side=${rmod_data}[side]
    ...                                          rmod_stored_role=${rmod_data}[stored_role]
    ...                                          rmod_ip=${rmod_data}[ip]
    ...                                          rmod_user=${rmod_data}[user]
    ...                                          rmod_password=${rmod_data}[password]
    ...                                          commands=${commands}
    ...                                          rmod_dn=${rmod_data}[dn]
    ...                                          rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                          rmod_cells=${rmod_data}[cells]
    ...                                          state=degraded

    Set Test Variable  ${${variable_prefix}_TIME_FROM_MAJOR_ALARM}  ${time_from_major_alarm}


Trigger Fault 1908 On RMOD From List - No Recovery
    [Arguments]  ${rmod_index}  ${variable_prefix}

    ${rmod_data}  Get From List  ${RMODS_LIST}  ${rmod_index}
    Log  \nTrigger Fault 1908 On ${rmod_data}[type] RMOD (${rmod_data}[dn]) - No Recovery (${variable_prefix})  console=true

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${rmod_data}
    Update RMOD Side IP And Stored Role By Serial Number  ${rmod_data}

    ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${rmod_data}[ip]
    ...                                           rmod_stored_role=${rmod_data}[stored_role]
    ...                                           rmod_side=${rmod_data}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${rmod_data}[dn]
    ...                                           rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                           rmod_cells=${rmod_data}[cells]
    ...                                           state=degraded

    Set Test Variable  ${${variable_prefix}_TIME_FROM_MAJOR_ALARM}  ${time_from_major_alarm}


Trigger Fault 1908 On RMOD From List - Single Recovery Then No Recovery
    [Arguments]  ${rmod_index}  ${variable_prefix}

    ${rmod_data}  Get From List  ${RMODS_LIST}  ${rmod_index}
    Log  \nTrigger Fault 1908 On ${rmod_data}[type] RMOD (${rmod_data}[dn]) - Single Recovery Then No Recovery (${variable_prefix})  console=true

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${rmod_data}
    Update RMOD Side IP And Stored Role By Serial Number  ${rmod_data}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                           rmod_ip=${rmod_data}[ip]
    ...                                           rmod_stored_role=${rmod_data}[stored_role]
    ...                                           rmod_side=${rmod_data}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${rmod_data}[dn]
    ...                                           rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                           rmod_cells=${rmod_data}[cells]
    ...                                           state=recovered

    ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${rmod_data}[ip]
    ...                                           rmod_stored_role=${rmod_data}[stored_role]
    ...                                           rmod_side=${rmod_data}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${rmod_data}[dn]
    ...                                           rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                           rmod_cells=${rmod_data}[cells]
    ...                                           state=degraded

    Set Test Variable  ${${variable_prefix}_TIME_FROM_MAJOR_ALARM}  ${time_from_major_alarm}


Trigger Fault 1908 On RMOD From List - Recovery 3 Times Then Degraded
    [Arguments]  ${rmod_index}  ${variable_prefix}

    ${rmod_data}  Get From List  ${RMODS_LIST}  ${rmod_index}
    Log  \nTrigger Fault 1908 On ${rmod_data}[type] RMOD (${rmod_data}[dn]) - Recovery 3 Times Then Degraded (${variable_prefix})  console=true

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${rmod_data}
    Update RMOD Side IP And Stored Role By Serial Number  ${rmod_data}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Repeat Keyword  3x  Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                                               rmod_ip=${rmod_data}[ip]
    ...                                                               rmod_stored_role=${rmod_data}[stored_role]
    ...                                                               rmod_side=${rmod_data}[side]
    ...                                                               commands=${commands}
    ...                                                               rmod_dn=${rmod_data}[dn]
    ...                                                               rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                                               rmod_cells=${rmod_data}[cells]
    ...                                                               state=recovered

    ${time_from_major_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${rmod_data}[ip]
    ...                                           rmod_stored_role=${rmod_data}[stored_role]
    ...                                           rmod_side=${rmod_data}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${rmod_data}[dn]
    ...                                           rmod_dn_nms=${rmod_data}[dn_nms]
    ...                                           rmod_cells=${rmod_data}[cells]
    ...                                           state=degraded

    Set Test Variable  ${${variable_prefix}_TIME_FROM_MAJOR_ALARM}  ${time_from_major_alarm}


Verify Maintenance Window Recovery For RMODs With Recovery Counter - Off Mode
    Log  \nVerify Maintenance Window Recovery For RMODs With Recovery Counter - Off Mode  console=true

    ${first_cpri_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_${FIRST_CPRI_RMOD}_INDEX}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               object_id=${first_cpri_rmod_data}[dn_nms]
    ...                                                                               time_from=${${FIRST_CPRI_RMOD}_OFF_TIME_FROM_MAJOR_ALARM}
    Log  Fault ${FAULT_1911} reported & cleared from Mantaray for ${FIRST_CPRI_RMOD} RMOD.  console=true
    Assert  RMOD  ${first_cpri_rmod_data}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${first_cpri_rmod_data}[cells]  operationalState=${ENABLED}

    Log  Verifying that ${SECOND_CPRI_RMOD} RMOD did NOT have recovery...  console=true
    ${second_cpri_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_${SECOND_CPRI_RMOD}_INDEX}
    Verify That At Least One Cell Is Degraded  ${second_cpri_rmod_data}[cells]

    ${first_obsai_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_OBSAI1_INDEX}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               object_id=${first_obsai_rmod_data}[dn_nms]
    ...                                                                               time_from=${OBSAI1_OFF_TIME_FROM_MAJOR_ALARM}
    Log  Fault ${FAULT_1911} reported & cleared from Mantaray for OBSAI1 RMOD.  console=true
    Assert  RMOD  ${first_obsai_rmod_data}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${first_obsai_rmod_data}[cells]  operationalState=${ENABLED}

    Log  Verifying that OBSAI2 RMOD (fault 1908 MAJOR) did NOT have recovery...  console=true
    ${second_obsai_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_OBSAI2_INDEX}
    Verify That At Least One Cell Is Degraded  ${second_obsai_rmod_data}[cells]

    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${first_cpri_rmod_partial_dn}  Fetch From Right  ${first_cpri_rmod_data}[dn]  MRBTS_R-1/
    ${first_obsai_rmod_partial_dn}  Fetch From Right  ${first_obsai_rmod_data}[dn]  MRBTS_R-1/
    ${maintenance_result}  Set Variable  ${parameter}[0][parameters][maintenanceWindowResult]
    Should Contain  ${maintenance_result}  MRBTS-${BTS_ID}/${first_cpri_rmod_partial_dn}
    Should Contain  ${maintenance_result}  MRBTS-${BTS_ID}/${first_obsai_rmod_partial_dn}
    Log  maintenanceWindowResult value is: ${maintenance_result}! [OK]  console=true


Verify Maintenance Window Recovery For RMODs With Recovery Counter
    [Arguments]  ${mode}
    Log  \nVerify Maintenance Window Recovery For RMODs With Recovery Counter - ${mode} Mode  console=true

    ${first_cpri_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_${FIRST_CPRI_RMOD}_INDEX}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               object_id=${first_cpri_rmod_data}[dn_nms]
    ...                                                                               time_from=${${FIRST_CPRI_RMOD}_${mode}_TIME_FROM_MAJOR_ALARM}
    Log  Fault ${FAULT_1911} reported & cleared from Mantaray for ${FIRST_CPRI_RMOD} RMOD.  console=true
    Assert  RMOD  ${first_cpri_rmod_data}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${first_cpri_rmod_data}[cells]  operationalState=${ENABLED}

    Log  Verifying that ${SECOND_CPRI_RMOD} RMOD did NOT have recovery...  console=true
    ${second_cpri_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_${SECOND_CPRI_RMOD}_INDEX}
    Verify That At Least One Cell Is Degraded  ${second_cpri_rmod_data}[cells]

    ${first_obsai_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_OBSAI1_INDEX}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               object_id=${first_obsai_rmod_data}[dn_nms]
    ...                                                                               time_from=${OBSAI1_${mode}_TIME_FROM_MAJOR_ALARM}
    Log  Fault ${FAULT_1911} reported & cleared from Mantaray for OBSAI1 RMOD.  console=true
    Assert  RMOD  ${first_obsai_rmod_data}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${first_obsai_rmod_data}[cells]  operationalState=${ENABLED}

    ${second_obsai_rmod_data}  Get From List  ${RMODS_LIST}  ${RMOD_OBSAI2_INDEX}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1908}
    ...                                                                               object_id=${second_obsai_rmod_data}[dn_nms]
    ...                                                                               time_from=${OBSAI2_${mode}_TIME_FROM_MAJOR_ALARM}
    Log  Fault ${FAULT_1908} reported & cleared from Mantaray for OBSAI2 RMOD.  console=true
    Assert  RMOD  ${second_obsai_rmod_data}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${second_obsai_rmod_data}[cells]  operationalState=${ENABLED}

    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${first_cpri_rmod_partial_dn}  Fetch From Right  ${first_cpri_rmod_data}[dn]  MRBTS_R-1/
    ${first_obsai_rmod_partial_dn}  Fetch From Right  ${first_obsai_rmod_data}[dn]  MRBTS_R-1/
    ${second_obsai_rmod_partial_dn}  Fetch From Right  ${second_obsai_rmod_data}[dn]  MRBTS_R-1/
    ${maintenance_result}  Set Variable  ${parameter}[0][parameters][maintenanceWindowResult]
    Should Contain  ${maintenance_result}  MRBTS-${BTS_ID}/${first_cpri_rmod_partial_dn}
    Should Contain  ${maintenance_result}  MRBTS-${BTS_ID}/${first_obsai_rmod_partial_dn}
    Should Contain  ${maintenance_result}  MRBTS-${BTS_ID}/${second_obsai_rmod_partial_dn}
    Log  maintenanceWindowResult value is: ${maintenance_result}! [OK]  console=true


TC Setup
    Common Test Setup  tc_name=FM__OAM_Exploratory_Tx_Rx_Failure_detection
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
