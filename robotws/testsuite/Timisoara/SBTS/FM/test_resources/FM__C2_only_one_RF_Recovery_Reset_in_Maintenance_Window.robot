*** Settings ***
Documentation
    ...  This test case verifies RF recovery reset functionality within a maintenance window on OBSAI RMOD(s)
    ...  with different nonCritTrxFailRecoveryCtrl parameter settings.
    ...  The test validates that only one RF recovery reset is performed per maintenance window, even when multiple faults occur.
    ...  First, actForceUnitAutoReset is set to true to enable automatic unit reset functionality.
    ...  For branches < 26R1: All faults are triggered in runtime.
    ...  For branches >= 26R1: Tests faults 1907, 1910, 1911, 1908, and 1920 with recovery control set to Off, SingleAndForcedRec, and Multiple.
    ...  For branches < 26R1: Tests faults 1907, 1910, and 1911. First, each fault triggers RMOD recovery
    ...  (1907 on port 1, 1911 on port 3, 1910 on port 2).
    ...  Then, all three faults are triggered again (1910 adds port 1), resulting in degraded state with Major severity alarms.
    ...  Maintenance window is activated, and RF recovery reset is performed. The maintenance window result
    ...  is verified to confirm only one recovery reset occurred.
    ...  STARTUP: Fault must be triggered within 4 minutes after radio detection to avoid runtime reset recovery.
    ...  RUNTIME: Fault must be triggered after 4 minutes from radio detection.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM and Netact
${RMOD_RESET_NEEDED}  ${FALSE}  # Set to ${TRUE} to perform RMOD reset before faults, ${FALSE} to skip reset
                                # Set to ${TRUE} for branches < 26R1, ${FALSE} for branches >= 26R1
                                # For branches >= 26R1, if triggering faults in startup/runtime is needed, should be set to ${TRUE}

*** Keywords ***
TC__FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29448
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29448 - Initial TAT creation
    ...  01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29753 - Update trigger type of faults(runtime/startup)
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30274 - Change scenario from 26R1 branch onwards
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30276 - Optimizations: RMOD reset, runtime and reset admin
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504-SR-C

    Step 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch


Step 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch
    Log  \nStep 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch  console=true

    IF  '${ENB_BRANCH}'<'SBTS26R1'  Set Test Variable  ${RMOD_RESET_NEEDED}  ${TRUE}
    ${runtime}  Set Variable If  ${RMOD_RESET_NEEDED}  ${TRUE}  ${FALSE}
    Set Test Variable  ${RUNTIME}

    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    Maintenance Window Cleanup
    ${rmods_list}  Get List Of OBSAI RMODs
    ${rmod_data}  Get Random OBSAI RMOD Info In A Dictionary  ${rmods_list}
    Set Test Variable  ${RMOD_DATA}

    IF  '${ENB_BRANCH}'>='SBTS26R1'
        ${second_rmod_data}  Get Random OBSAI RMOD Info In A Dictionary  ${OBSAI_RMODS_LIST}
        Set Test Variable  ${SECOND_RMOD_DATA}
        Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Off
        Perform Site Reset
        Trigger Multiple Faults On OBSAI RMOD In Runtime
        Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
        Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple
    ELSE
        Perform Site Reset
        Trigger Multiple Faults On OBSAI RMOD In Runtime
    END


Trigger Multiple Faults On OBSAI RMOD In Runtime
    Log  \nTrigger Multiple Faults On OBSAI RMOD In Runtime...  console=true

    #######################################################################################################################
    # Single RMOD: 1907(recovery) -> 1911(recovery) -> 1910(recovery) -> 1907(degraded) -> 1911(degraded) -> 1910(degraded)
    #######################################################################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  sendFault 1153 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1907_RADIO_AUTO_RST}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1130 3 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1128 2 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1910_RADIO_AUTO_RST}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${time_from_major_alarms}  Get Current Date  time_zone=UTC  result_format=datetime
    ${commands}  Create List  sendFault 1153 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1130 3 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1911}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    Set To Dictionary  ${FAULT_1910}  alarm_id=7116  alarm_name=BASE STATION SERVICE PROBLEM  severity=Major
    ${commands}  Create List  sendFault 1128 1 0 0 0 0 0  sendFault 1128 2 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1910}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    Create Maintenance Window
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR} reported & cleared from Netact.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1911} reported & cleared from Netact.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1910}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1910} reported & cleared from Netact.  console=true
    Assert  RMOD  ${RMOD_DATA}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_DATA}[cells]  operationalState=${ENABLED}

    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${rmod_partial_dn}  Fetch From Right  ${RMOD_DATA}[dn]  MRBTS_R-1/
    Should Be Equal As Strings  ${parameter}[0][parameters][maintenanceWindowResult]  Radio recovery reset:MRBTS-${BTS_ID}/${rmod_partial_dn}
    Log  maintenanceWindowResult value is: ${parameter}[0][parameters][maintenanceWindowResult]! [OK]  console=true
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
    Log  \nTrigger multiple faults on OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  SingleAndForcedRec
    Perform Site Reset

    ##############################################
    # First RMOD: 1908(recovery) -> 1908(degraded)
    ##############################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${time_from_major_alarms}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    coam.Reset Admin

    #################################################################
    # Second RMOD: 1920(recovery) -> 1908(recovery) -> 1920(degraded)
    #################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${SECOND_RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${SECOND_RMOD_DATA}

    ${commands}  Create List  sendFault 1124 3 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920_RADIO_AUTO_RST}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1115 3 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=recovered
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1124 3 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    Create Maintenance Window
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1908}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1908} reported & cleared from Netact.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1920}
    ...                                                                               object_id=${SECOND_RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1920} reported & cleared from Netact.  console=true
    Assert  RMOD  ${RMOD_DATA}[dn]  operationalState=${ENABLED}  timeout=600s
    Assert  RMOD  ${SECOND_RMOD_DATA}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_DATA}[cells]  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${SECOND_RMOD_DATA}[cells]  operationalState=${ENABLED}
    Check Maintenance Window Result For 2 RMODs  ${RMOD_DATA}[dn]  ${SECOND_RMOD_DATA}[dn]
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple
    Log  \nTrigger multiple faults on OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Multiple
    Perform Site Reset

    ###################################################################
    # First RMOD: 3x 1908(recovery) -> 1908(degraded) -> 1920(degraded)
    ###################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Repeat Keyword  3x  Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                                               rmod_ip=${RMOD_DATA}[ip]
    ...                                                               rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                                               rmod_side=${RMOD_DATA}[side]
    ...                                                               commands=${commands}
    ...                                                               rmod_dn=${RMOD_DATA}[dn]
    ...                                                               rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                                               rmod_cells=${RMOD_DATA}[cells]
    ...                                                               state=recovered
    ...                                                               runtime=${RUNTIME}

    ${time_from_major_alarms}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1124 2 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    coam.Reset Admin

    ####################################################################
    # Second RMOD: 3x 1920(recovery) -> 1920(degraded) -> 1908(degraded)
    ####################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${SECOND_RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${SECOND_RMOD_DATA}

    ${commands}  Create List  sendFault 1124 3 0 0 0 0 0
    Repeat Keyword  3x  Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920_RADIO_AUTO_RST}
    ...                                                               rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                                               rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                                               rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                                               commands=${commands}
    ...                                                               rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                                               rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                                               rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                                               state=recovered
    ...                                                               runtime=${RUNTIME}

    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    ${commands}  Create List  sendFault 1115 2 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded
    ...                                           runtime=${RUNTIME}

    Create Maintenance Window
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1908}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1908} reported & cleared from Netact.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1920}
    ...                                                                               object_id=${RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1920} reported & cleared from Netact.  console=true

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1920}
    ...                                                                               object_id=${SECOND_RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1920} reported & cleared from Netact.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1908}
    ...                                                                               object_id=${SECOND_RMOD_DATA}[dn_nms]
    ...                                                                               time_from=${time_from_major_alarms}
    Log  Fault ${FAULT_1908} reported & cleared from Netact.  console=true
    Assert  RMOD  ${RMOD_DATA}[dn]  operationalState=${ENABLED}  timeout=600s
    Assert  RMOD  ${SECOND_RMOD_DATA}[dn]  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_DATA}[cells]  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${SECOND_RMOD_DATA}[cells]  operationalState=${ENABLED}
    Check Maintenance Window Result For 2 RMODs  ${RMOD_DATA}[dn]  ${SECOND_RMOD_DATA}[dn]
    Delete Maintenance Window

    [Teardown]  coam.Reset Admin


Check Maintenance Window Result For 2 RMODs
    [Arguments]  ${first_rmod_dn}  ${second_rmod_dn}

    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${first_rmod_partial_dn}  Fetch From Right  ${first_rmod_dn}  MRBTS_R-1/
    ${second_rmod_partial_dn}  Fetch From Right  ${second_rmod_dn}  MRBTS_R-1/
    ${first_rmod_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${parameter}[0][parameters][maintenanceWindowResult]
    ...                              Radio recovery reset:MRBTS-${BTS_ID}/${first_rmod_partial_dn},MRBTS-${BTS_ID}/${second_rmod_partial_dn}
    ${second_rmod_status}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${parameter}[0][parameters][maintenanceWindowResult]
    ...                              Radio recovery reset:MRBTS-${BTS_ID}/${second_rmod_partial_dn},MRBTS-${BTS_ID}/${first_rmod_partial_dn}
    IF  not(${first_rmod_status} or ${second_rmod_status})
        Log  maintenanceWindowResult value is: ${parameter}[0][parameters][maintenanceWindowResult]! [FAILED]  console=true
        Fail  maintenanceWindowResult value is not as expected.
    ELSE
        Log  maintenanceWindowResult value is: ${parameter}[0][parameters][maintenanceWindowResult]! [OK]  console=true
    END


TC Setup
    Common Test Setup  tc_name=FM__C2_only_one_RF_Recovery_Reset_in_Maintenance_Window
    Setup NetAct


TC Teardown
    Maintenance Window Cleanup
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
