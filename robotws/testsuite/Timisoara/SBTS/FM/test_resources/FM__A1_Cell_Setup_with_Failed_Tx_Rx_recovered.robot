*** Settings ***
Documentation
    ...  This test case verifies fault 1911 recovery behavior on CPRI RMOD with LTE and/or NR cells.
    ...  First actForceUnitAutoReset is set to true.
    ...  For SBTS26R1 branch: Tests recovery behavior with nonCritTrxFailRecoveryCtrl set to Off, SingleAndForcedRec, and Multiple.
    ...  Fault 1911 is triggered and recovery state is verified.
    ...  For other branches: Fault 1911 is triggered and degraded state is verified.
    ...  STARTUP: Fault must be triggered within 4 minutes after radio detection to avoid runtime reset recovery.
    ...  RUNTIME: Fault must be triggered after 4 minutes from radio detection.
    ...  Verifies fault appearance and cell states. Performs site reset at the end.


Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  # Type of RMOD that will be used to send the fault. Should be CPRI.
${ALARM_TIMEOUT}  300s  # [in seconds] Timeout for alarm to be reported in WebEM and Netact
${RMOD_RESET_NEEDED}  ${FALSE}  # Set to ${TRUE} to perform RMOD reset before faults, ${FALSE} to skip reset
                                # Set to ${TRUE} for branches < 26R1, ${FALSE} for branches >= 26R1
                                # For branches >= 26R1, if triggering faults in startup/runtime is needed, should be set to ${TRUE}


*** Keywords ***
TC__FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29294
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29294 - Initial TAT creation
    ...  27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29748 - Change RMOD credentials retrieval method
    ...  and trigger type of fault(runtime/startup)
    ...  11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30270 - Change scenario from 26R1 branch
    ...  30.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30457 - Add [Teardown] to reset admin and skip RMOD disabled verification
    ...  02.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30276 - Optimizations: RMOD reset, runtime and reset admin
    ...  *******************

    Set Tags  CA-FM  OWNER-vincentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504

    Step 1: Trigger 1911 On CPRI RMOD By Branch


Step 1: Trigger 1911 On CPRI RMOD By Branch
    Log  \nStep 1: Trigger 1911 On CPRI RMOD By Branch.  console=true

    Change FMCADM Parameter  actForceUnitAutoReset  true
    IF  '${ENB_BRANCH}'<'SBTS26R1'  Set Test Variable  ${RMOD_RESET_NEEDED}  ${TRUE}

    Change FMCADM Parameter  actForceUnitAutoReset  true
    ${RMOD_DATA}  Get CPRI RMOD Info By LTE Or NR Cells In Dictionary  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_DATA}  ${RMOD_DATA}

    IF  '${ENB_BRANCH}'>='SBTS26R1'
        Trigger 1911 Fault On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to Off
        Trigger 1911 Fault On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to SingleAndForcedRec
        Trigger 1911 Fault On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to Multiple
    ELSE
        Trigger Fault 1911 On CPRI RMOD - RMOD Degraded Scenario
    END


Trigger 1911 Fault On CPRI RMOD with nonCritTrxFailRecoveryCtrl set to ${value}
    Log  \nTrigger multiple faults on CPRI RMOD with nonCritTrxFailRecoveryCtrl set to ${value}...  console=true

    Change FMCADM Parameter  nonCritTrxFailRecoveryCtrl  ${value}
    Perform Site Reset

    #############################
    # Single RMOD: 1911(recovery)
    #############################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
    Trigger Fault On CPRI RMOD And Verify State  fault_dictionary=${FAULT_1911_RADIO_AUTO_RST}
    ...                                          rmod_side=${RMOD_DATA}[side]
    ...                                          rmod_stored_role=${RMOD_DATA}[stored_role]
    ...                                          rmod_ip=${RMOD_DATA}[ip]
    ...                                          rmod_user=${RMOD_DATA}[user]
    ...                                          rmod_password=${RMOD_DATA}[password]
    ...                                          commands=${commands}
    ...                                          rmod_dn=${RMOD_DATA}[dn]
    ...                                          rmod_dn_nms=${RMOD_DATA}[dn_nms]
    ...                                          rmod_cells=${RMOD_DATA}[cells]
    ...                                          state=recovered

    [Teardown]    coam.Reset Admin


Trigger Fault 1911 On CPRI RMOD - RMOD Degraded Scenario
    Log  Trigger Fault 1911 On CPRI RMOD --> RMOD Degraded  console=true

    Perform Site Reset

    #############################
    # Single RMOD: 1911(degraded)
    #############################

    IF  ${RMOD_RESET_NEEDED}  Perform RMOD Reset  ${RMOD_DATA}
    Update RMOD Side IP And Stored Role By Serial Number  ${RMOD_DATA}

    ${commands}  Create List  devmem 0xFF988114 32 0x0  devmem 0xFF990114 32 0x0
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

    [Teardown]    coam.Reset Admin


Get CPRI RMOD Info By LTE Or NR Cells In Dictionary
    [Documentation]
    ...  Returns a dictionary with CPRI RMOD info (dn, dn_nms, sn, cells, user, password).
    ...  Does not include ip, side, stored_role - use Update RMOD Side IP And Stored Role By Serial Number
    ...  after each RMOD reset/Site Reset to add them.
    [Arguments]  ${rmod_type}

    ${rmod_dn}  ${rmod_sn}  ${rmod_cells}  Get RMOD DN, SN, And Cells List By LTE Or NR Cells  ${rmod_type}
    ${sw_line}  Get SW Line For Specific RMOD  ${rmod_dn}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${rmod_type}
    ${rmod_dn_nms}  Get Regexp Matches  ${rmod_dn}  /EQM_R.*
    ${rmod_dn_nms}  Catenate  SEPARATOR=  PLMN-PLMN/  MRBTS-${BTS_ID}  ${rmod_dn_nms}[0]
    ${rmod_dictionary}  Create Dictionary  dn=${rmod_dn}
    ...                                    dn_nms=${rmod_dn_nms}
    ...                                    sn=${rmod_sn}
    ...                                    cells=${rmod_cells}
    ...                                    user=${rmod_user}
    ...                                    password=${rmod_password}
    RETURN  ${rmod_dictionary}


Get RMOD DN, SN, And Cells List By LTE Or NR Cells
    [Arguments]  ${rmod_type}

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        IF  '${rmod_type}' not in '${rmod}[productName]'  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id]
        ${nr_cells_rmod}  ${status_nr_cells_rmod}  Verify Cells Technology On RMOD  ${rmod_cells}  NRCEL
        ${lte_cells_rmod}  ${status_lte_cells_rmod}  Verify Cells Technology On RMOD  ${rmod_cells}  LNCEL
        IF  not (${status_nr_cells_rmod} or ${status_lte_cells_rmod})  CONTINUE
        ${rmod_cells}  Combine Lists  ${nr_cells_rmod}  ${lte_cells_rmod}
        RETURN  ${rmod}[id]  ${rmod}[serialNumber]  ${rmod_cells}
    END
    Fail  No CPRI RMOD with LTE and NR cells found on SBTS.


TC Setup
    Common Test Setup  tc_name=FM__A1_Cell_Setup_with_Failed_Tx_Rx_recovered
    Setup NetAct


TC Teardown
    Perform Site Reset
    Teardown NetAct
    Common Test Teardown
