*** Settings ***
Documentation
    ...  This test case verifies OBSAI RMOD fault handling and recovery behavior with different nonCritTrxFailRecoveryCtrl parameter settings.
    ...  For branches >= 26R1: Tests faults 1908 and 1920 on multiple RMODs with recovery control set to Off, SingleAndForcedRec, and Multiple.
    ...  For branches < 26R1: Tests fault 1911 sequence (degraded -> recovery -> degraded) on a single RMOD.
    ...  The test verifies fault severity, cell degradation states, operational state transitions, and recovery behavior for each configuration.
    ...  STARTUP: Fault must be triggered within 4 minutes after radio detection to avoid runtime reset recovery.
    ...  RUNTIME: Fault must be triggered after 4 minutes from radio detection.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to be reported in WebEM and Mantaray
${RMOD_RESET_NEEDED}  ${FALSE}  # Set to ${TRUE} to perform RMOD reset before faults, ${FALSE} to skip reset
                                # Set to ${TRUE} for branches < 26R1, ${FALSE} for branches >= 26R1
                                # For branches >= 26R1, if triggering faults in startup/runtime is needed, should be set to ${TRUE}


*** Keywords ***
TC__FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29293
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29293 - Initial TAT creation
    ...  01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29749 - Update trigger type of faults(runtime/startup)
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30271 - Change scenario from 26R1 branch onwards
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30276 - Optimizations: RMOD reset, runtime and reset admin
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504

    Step 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch


Step 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch
    Log  \nStep 1: Trigger Multiple Faults On OBSAI RMOD(s) By Branch  console=true

    IF  '${ENB_BRANCH}'<'SBTS26R1'  Set Test Variable  ${RMOD_RESET_NEEDED}  ${TRUE}
    ${runtime}  Set Variable If  ${RMOD_RESET_NEEDED}  ${TRUE}  ${FALSE}
    Set Test Variable  ${RUNTIME}

    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    ${obsai_rmods_list}  Get List Of OBSAI RMODs  cells_type=NRCEL
    ${rmod_data}  Get Random OBSAI RMOD Info In A Dictionary  ${obsai_rmods_list}
    Set Test Variable  ${RMOD_DATA}

    IF  '${ENB_BRANCH}'>='SBTS26R1'
        ${second_rmod_data}  Get Random OBSAI RMOD Info In A Dictionary  ${OBSAI_RMODS_LIST}
        Set Test Variable  ${SECOND_RMOD_DATA}
        Trigger Multiple Faults On OBSAI RMOD with nonCritTrxFailRecoveryCtrl set to Off
        Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
        Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple
    ELSE
        Perform Site Reset
        Trigger Fault 1911 On OBSAI RMOD multiple times - RMOD Degraded Scenario
    END


Trigger Fault 1911 On OBSAI RMOD multiple times - RMOD Degraded Scenario
    Log  \nTrigger Fault 1911 On OBSAI RMOD multiple times...  console=true

    #################################################################
    # Single RMOD: 1911(degraded) -> 1911(recovery) -> 1911(degraded)
    #################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  sendFault 1130 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1911}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded

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

    [Teardown]  coam.Reset Admin


Trigger Multiple Faults On OBSAI RMOD with nonCritTrxFailRecoveryCtrl set to Off
    Log  \nTrigger multiple faults on OBSAI RMOD with nonCritTrxFailRecoveryCtrl set to Off...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Off
    Perform Site Reset

    ############################
    # First RMOD: 1908(degraded)
    ############################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded

    #############################
    # Second RMOD: 1920(degraded)
    #############################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${SECOND_RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${SECOND_RMOD_DATA}

    ${commands}  Create List  sendFault 1124 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded

    [Teardown]  coam.Reset Admin


Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
    Log  \nTrigger multiple faults on OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  SingleAndForcedRec
    Perform Site Reset

    ###############################################
    # First RMOD: 1908(recovery) -> 1908(degraded)
    ###############################################

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

    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded


    #################################################################
    # Second RMOD: 1908(recovery) -> 1920(recovery) -> 1908(degraded)
    #################################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${SECOND_RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${SECOND_RMOD_DATA}

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908_RADIO_AUTO_RST}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=recovered

    ${commands}  Create List  sendFault 1124 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920_RADIO_AUTO_RST}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=recovered

    ${commands}  Create List  sendFault 1115 1 0 0 0 0 0
    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded

    [Teardown]  coam.Reset Admin


Trigger Multiple Faults On OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple
    Log  \nTrigger multiple faults on OBSAI RMODs with nonCritTrxFailRecoveryCtrl set to Multiple...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  Multiple
    Perform Site Reset

    ###############################################
    # First RMOD: 3x 1908(recovery), 1908(degraded)
    ###############################################

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

    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1908}
    ...                                           rmod_ip=${RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                           rmod_side=${RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${RMOD_DATA}[cells]
    ...                                           state=degraded

    ################################################
    # Second RMOD: 3x 1920(recovery), 1920(degraded)
    ################################################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${SECOND_RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${SECOND_RMOD_DATA}

    ${commands}  Create List  sendFault 1124 1 0 0 0 0 0
    Repeat Keyword  3x  Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920_RADIO_AUTO_RST}
    ...                                                               rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                                               rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                                               rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                                               commands=${commands}
    ...                                                               rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                                               rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                                               rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                                               state=recovered

    Trigger Fault On OBSAI RMOD And Verify State  fault_dictionary=${FAULT_1920}
    ...                                           rmod_ip=${SECOND_RMOD_DATA}[ip]
    ...                                           rmod_stored_role=${SECOND_RMOD_DATA}[stored_role]
    ...                                           rmod_side=${SECOND_RMOD_DATA}[side]
    ...                                           commands=${commands}
    ...                                           rmod_dn=${SECOND_RMOD_DATA}[dn]
    ...                                           rmod_dn_nms=${SECOND_RMOD_DATA}[dn_nms]
    ...                                           rmod_cells=${SECOND_RMOD_DATA}[cells]
    ...                                           state=degraded

    [Teardown]  coam.Reset Admin


TC Setup
    Common Test Setup  tc_name=FM__A2_Cell_Setup_with_Failed_Tx_Rx_in_Degraded_State
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
