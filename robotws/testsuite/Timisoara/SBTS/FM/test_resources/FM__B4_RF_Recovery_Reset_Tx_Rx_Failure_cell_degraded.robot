*** Settings ***
Documentation
    ...  This test case verifies fault 1911 recovery sequence and degraded state transition on CPRI RMOD.
    ...  First actForceUnitAutoReset is set to true.
    ...  For SBTS26R1 branch: Tests recovery behavior with nonCritTrxFailRecoveryCtrl set to Off, SingleAndForcedRec, and Multiple.
    ...  Fault 1911 is triggered 3 times (recovery) then once more (degraded with critical severity).
    ...  For other branches: Fault 1911 is triggered 2 times (recovery) then once more (degraded).
    ...  Verifies fault severity, cell degradation states, and recovery behavior.
    ...  STARTUP: Fault must be triggered within 4 minutes after radio detection to avoid runtime reset recovery.
    ...  RUNTIME: Fault must be triggered after 4 minutes from radio detection.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  # Type of RMOD that will be used to send the fault. Should be CPRI.
${ALARM_TIMEOUT}  300s  # [in seconds] Timeout for alarm to be reported in WebEM and Netact
${RMOD_RESET_NEEDED}  ${FALSE}  # Set to ${TRUE} to perform RMOD reset before faults, ${FALSE} to skip reset
                                # Set to ${TRUE} for branches < 26R1, ${FALSE} for branches >= 26R1
                                # For branches >= 26R1, if triggering faults in startup/runtime is needed, should be set to ${TRUE}


*** Keywords ***
TC__FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29451
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  24.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29451 - Initial TAT creation
    ...  29.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29612 - Created radio modules data file and new RMOD connection method
    ...  21.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29737 - Update retrieval method of RMOD credentials
    ...  27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29751 - Update trigger type of faults(runtime/startup)
    ...  11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30311 - Change scenario from 26R1 branch
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30276 - Optimizations: RMOD reset, runtime and reset admin
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504-SR-BA

    Step 1: Trigger 1911 On CPRI RMOD By Branch


Step 1: Trigger 1911 On CPRI RMOD By Branch
    Log  \nStep 1: Trigger 1911 On CPRI RMOD By Branch.  console=true

    IF  '${ENB_BRANCH}'<'SBTS26R1'  Set Test Variable  ${RMOD_RESET_NEEDED}  ${TRUE}
    ${runtime}  Set Variable If  ${RMOD_RESET_NEEDED}  ${TRUE}  ${FALSE}
    Set Test Variable  ${RUNTIME}

    Change FMCADM Parameter  actForceUnitAutoReset  true
    ${rmod_data}  Get CPRI RMOD Info In A Dictionary  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_DATA}

    IF  '${ENB_BRANCH}'>='SBTS26R1'
        Trigger Multiple Faults On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to Off
        Trigger Multiple Faults On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
        Trigger Multiple Faults On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to Multiple
    ELSE
        Trigger Fault 1911 On CPRI RMOD for 3 times
    END


Trigger Multiple Faults On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to ${value}
    Log  \nTrigger multiple faults on CPRI RMOD with nonCritTrxFailRecoveryCtrl set to ${value}...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  ${value}
    Perform Site Reset

    ###################################################################################
    # Single RMOD: 1911(recovery) -> 1911(recovery) -> 1911(recovery) -> 1911(degraded)
    ###################################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
    Repeat Keyword  3x  Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
    ...                                                              rmod_side=${RMOD_DATA}[side]
    ...                                                              rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                                              rmod_ip=${RMOD_DATA}[ip]
    ...                                                              rmod_user=${RMOD_DATA}[user]
    ...                                                              rmod_password=${RMOD_DATA}[password]
    ...                                                              commands=${commands}
    ...                                                              rmod_dn=${RMOD_DATA}[dn]
    ...                                                              rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                                              rmod_cells=${RMOD_DATA}[cells]
    ...                                                              state=recovered
    ...                                                              runtime=${RUNTIME}

    Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911_CRITICAL}
    ...                                          rmod_side=${RMOD_DATA}[side]
    ...                                          rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                          rmod_ip=${RMOD_DATA}[ip]
    ...                                          rmod_user=${RMOD_DATA}[user]
    ...                                          rmod_password=${RMOD_DATA}[password]
    ...                                          commands=${commands}
    ...                                          rmod_dn=${RMOD_DATA}[dn]
    ...                                          rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                          rmod_cells=${RMOD_DATA}[cells]
    ...                                          state=degraded
    ...                                          runtime=${RUNTIME}

    [Teardown]  coam.Reset Admin


Trigger Fault 1911 On CPRI RMOD for 3 times
    Log  \nTrigger fault 1911 on CPRI RMOD for 3 times...  console=true

    Perform Site Reset

    #################################################################
    # Single RMOD: 1911(recovery) -> 1911(recovery) -> 1911(degraded)
    #################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
    Repeat Keyword  2x  Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
    ...                                                              rmod_side=${RMOD_DATA}[side]
    ...                                                              rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                                              rmod_ip=${RMOD_DATA}[ip]
    ...                                                              rmod_user=${RMOD_DATA}[user]
    ...                                                              rmod_password=${RMOD_DATA}[password]
    ...                                                              commands=${commands}
    ...                                                              rmod_dn=${RMOD_DATA}[dn]
    ...                                                              rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                                              rmod_cells=${RMOD_DATA}[cells]
    ...                                                              state=recovered
    ...                                                              runtime=${RUNTIME}

    Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911}
    ...                                          rmod_side=${RMOD_DATA}[side]
    ...                                          rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                          rmod_ip=${RMOD_DATA}[ip]
    ...                                          rmod_user=${RMOD_DATA}[user]
    ...                                          rmod_password=${RMOD_DATA}[password]
    ...                                          commands=${commands}
    ...                                          rmod_dn=${RMOD_DATA}[dn]
    ...                                          rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                          rmod_cells=${RMOD_DATA}[cells]
    ...                                          state=degraded
    ...                                          runtime=${RUNTIME}


TC Setup
    Common Test Setup  tc_name=FM__B4_RF_Recovery_Reset_Tx_Rx_Failure_cell_degraded
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
