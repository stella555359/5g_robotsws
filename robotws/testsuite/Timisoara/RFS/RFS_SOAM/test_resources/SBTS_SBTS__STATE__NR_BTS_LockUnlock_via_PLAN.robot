*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__NR_BTS_LockUnlock_via_PLAN
Variables    tc_variables/sbts_sbts__state__nr_bts_lock_unlock_via_plan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${BTS_LIST}       ALL   # BTS list on which NRDU Lock/Unlock operation will be performed. Possible values (by default ALL):
                        # - ALL: action will be performed on all BTS (NRDU Lock/Unlock on each BTS until last BTS from TL)
                        # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py) (ex. BTS1, BTS2)
                        # Leave default value for RFSplit
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS PRIMARY LINK, possible values: BTS (BTS Reset),
                                     # LANE (Lock Unlock SFP LANE)
${RMOD_PRIMARY_LINK}  # RMOD primary link set before LTE BBMOD reset, possible values: empty (no set required),
                      # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_TIME}  720  # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${REPEAT_COUNTER}             3          # Number of NRDUs lock/unlock operations via Plan, default value 3
${BTS_administrativeState_lock}  Locked  # BTS administrative state value for NRDU Lock operation
${BTS_administrativeState_unlock}  Unlocked  # BTS administrative state value for NRDU Unlock operation

*** Keywords ***
TC__SBTS_SBTS__STATE__NR_BTS_LockUnlock_via_PLAN
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-20835
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for BTS NRDU Lock/Unlock Site via Plan, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both SBTS
    ...  - set if needed primary CPRI on requested technology
    ...  - perform Lock/Unlock NRDU on BTS via Plan
    ...  - check BTS reset behavior: reset number is 0
    ...  - check final BTS state and alarms
    ...  Pass criteria: BTS NRDUs Lock/Unlock operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-20835 - [5G][MT][CPRI] New NRL scenario NRL__STATE__NR_BTS_Lock_Unlock_via_Plan
    ...  - 14.02.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22640 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NRL part
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 22.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24198 - [5G][Reset Number ims2] Update NRL STATE ... scenarios to take
    ...  reset number from ims2 - P2- part1
    ...  - 22.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24919 -
    ...  [5G][Refactoring Tracker] Use generic BTS KWs (instead specific RAT KWs) for NRL scenarios
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25410 - [5G] [Refactoring Tracker] Use common KW for
    ...  extracting MRBTS, LNBTS, NRBTS id
    ...  - 07.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-21897 - [5G] [Refactoring Tracker] Use common KW for check administrative state
    ...  in recovery phase
    ...  - 21.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25725 - [5G] Use new DSS mechanism in existing TCs - NRL - BTS Block Unblock
    ...  - 11.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25037 - [5G][Refactoring][CNI-84880] NRDU_R object refactoring
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 27.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29571 - Eliminate GNB shutdown recommissioning from TC precondition
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...  - 14.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29968 - Update NRL__STATE__NR_BTS_LockUnlock_via_PLAN (NRDU) for
    ...  SBTS_SBTS configuration
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-20835_NRL__STATE__NR_BTS_LockUnlock_via_PLAN.png

    Set Tags    CA-STATE    OWNER-nicoleta.popescu@nokia.com    AUTHOR-lia.caraiman@nokia.com    PHASE-QT
    ...    SW- SBTS22R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Set NR BTS shutdownNogNBCellTmr parameter value
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Set Shared RMOD Primary Link before NR BTS Lock_Unlock operations
        Step 5: Perform BTS Lock Unlock on all BTS via commissioning
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check all BTS reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  =========================================================  console=True
    Log  BTS label list selected for NRDU Lock/Unlock operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for NRDU Lock/Unlock operation: ${BTS_alias_list}  console=True
    Log  =========================================================  console=True

    ${NR_present}=  Set Variable  ${FALSE}
    ${skipped_BTS_alias_list}=  Create List

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${NR_present}=  Set Variable If  ${NR_CELL_list}  ${TRUE}  ${NR_present}
        Continue For Loop If  ${NR_CELL_list}
        Log  BTS ${alias} has no NR configured! NR Lock/Unlock operation will be skipped for this BTS!  level=WARN
        Append To List  ${skipped_BTS_alias_list}  ${alias}
    END

    Run Keyword If  not ${NR_present}  Fail  TC Preconditions failed! None of the indicated BTSs have NR configured!
    Set Test Variable  ${skipped_BTS_alias_list}

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}

        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}

        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}

    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}

        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}

    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  wait_for_alarm_clear=15 min  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Set NR BTS shutdownNogNBCellTmr parameter value
    Log  Step ${index}: Set NR BTS shutdownNogNBCellTmr parameter value  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${alias}' in ${skipped_BTS_alias_list}
        ${nrbts_dn}  ${shutdownNogNBCellTmr_initial}=  Get shutdownNogNBCellTmr parameter value  ${alias}
        Set Test Variable  ${${alias}_shutdownNogNBCellTmr_initial}  ${shutdownNogNBCellTmr_initial}
        Log  Setting NR BTS shutdownNogNBCellTmr to 1  console=True
        Run Keyword If  ${shutdownNogNBCellTmr_initial}!=1  Set shutdownNogNBCellTmr parameter value  1  ${alias}
        ...  ELSE  Log  NR BTS shutdownNogNBCellTmr parameter already set to 1, commissioning not needed!  console=True
    END

Step ${index}: Set Shared RMOD Primary Link before NR BTS Lock_Unlock operations
    [Documentation]
    ...  Set shared Radio Primary Link if needed

    Log  Step ${index}: Set Shared RMOD Primary Link before NR BTS Lock_Unlock operations  console=True
    Run Keyword If  '${RMOD_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing RMOD Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on RMODs ${RMOD_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    Run Keyword If  '${RMOD_PRIMARY_LINK}' in ['Master','Slave']
    ...  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${RMOD_PRIMARY_LINK}
    ...  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  ELSE  Run Keywords
    ...  Log  Please set one of following values for test argument \${RMOD_PRIMARY_LINK}: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Step ${index}: Perform BTS Lock Unlock on all BTS via commissioning
    [Documentation]
    ...  Perform BTS Lock Unlock on all BTS via commissioning

    Log  Step ${index}: Perform BTS Lock Unlock on all BTS via commissioning  console=True

    Get Current Date UTC info  start

    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${alias}' in ${skipped_BTS_alias_list}
        Perform BTS Lock Unlock on BTS via commissioning  ${alias}
    END

Step ${index}: Check all BTS reset behavior based on IMS info
    [Documentation]
    ...  Final RESET info are compared with initial RESET info for all BTS.
    ...  Reset behavior as expected if reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check all BTS reset behavior based on IMS info  console=True

    Get Current Date UTC info  end

    FOR  ${alias}  IN  @{alias_list}

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
        ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Perform BTS Lock Unlock on BTS via commissioning
    [Arguments]  ${alias}

    Lock NR BTS via commissioning  ${alias}
    Unlock NR BTS via commissioning  ${alias}

Lock NR BTS via commissioning
    [Arguments]  ${alias}

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    Log  NR BTS Lock will be performed via administrativeState parameter recomissioning on BTS ${alias}  console=True
    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRDU-[\\d]+$  scf_path=${${alias.lower()}_scf_initial}  alias=${alias}
    ${nrbts_dn}=  Get From List  ${nrbts_dn_list}  0
    Set Test Variable  ${nrbts_dn}

    Perform Administrative State Recommissioning  obj_scf_dn=${nrbts_dn}  administrativeState=Locked  alias=${alias}
    ...  timeout=60

    Log  Check BTS ${alias} cell(s) states and alarms after lock BTS ${alias}:  console=True
    Wait Until Keyword Succeeds  3 min  3 sec  Check BTS Administrative State  ${Locked_}  ${alias}
    Log  BTS ${alias} site - administrativeState: Locked, operationalState: Enabled, as expected!  console=True

    Assert Every  NRCEL  availabilityStatus=${Dependency_}, operationalState=${Disabled_}  timeout=60
    ...  connection=${alias}
    Log  NR cell(s) - availabilityStatus=Dependency, operationalState=Disabled, as expected!  console=True

    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Set Test Variable  ${LTE_CELL_list}
    Set Test Variable  ${WCDMA_CELL_list}
    Set Test Variable  ${GSM_CELL_list}

    Run Keyword If  ${LTE_CELL_list}
    ...  Assert Every  LNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${WCDMA_CELL_list}
    ...  Assert Every  WNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${GSM_CELL_list}
    ...  Assert Every  GNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${LTE_CELL_list} or ${WCDMA_CELL_list} or ${GSM_CELL_list}
    ...  Log  All other cell(s) (apart from NR) operationalState=Enabled, as expected!  console=True

    ${LTEENB_list}  ${LTEENB_count}=  Get LTEENB list  alias=${alias}

    Run Keyword If  ${LTEENB_count}>0  Check NR X2 alarm  alias=${alias}
    ...  ELSE  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  time=10 min

    Log  NR site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${peer_alias} states after lock BTS ${alias}:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  10  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check BTS ${peer_alias} alarms after lock BTS ${alias}:  console=True
    Check peer BTS alarms  ${peer_alias}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Unlock NR BTS via commissioning
    [Arguments]  ${alias}

    Log  NR BTS Unlock will be performed via administrativeState parameter recomissioning on BTS ${alias}  console=True

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master

    Perform Administrative State Recommissioning  obj_scf_dn=${nrbts_dn}  administrativeState=Unlocked  alias=${alias}
    ...  timeout=60

    Log  Check BTS ${alias} cell(s) states after unlock NR BTS:  console=True
    Wait Until Keyword Succeeds  10 min  3 sec  Check BTS Administrative State  ${Unlocked_}  ${alias}
    Log  BTS ${alias} - administrativeState: Unlocked, as expected!  console=True
    Assert Every  NRCEL  operationalState=${Enabled_}  timeout=600  alias=${alias}
    Log  BTS ${alias} NR cell(s) - operationalState=Enabled, as expected!  console=True
    Run Keyword If  ${LTE_CELL_list}
    ...  Assert Every  LNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${WCDMA_CELL_list}
    ...  Assert Every  WNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${GSM_CELL_list}
    ...  Assert Every  GNCEL  operationalState=${Enabled_}  timeout=60  connection=${alias}
    Run Keyword If  ${LTE_CELL_list} or ${WCDMA_CELL_list} or ${GSM_CELL_list}
    ...  Log  All other cell(s) (apart from NR) operationalState=Enabled, as expected!  console=True
    Log  Check BTS ${peer_alias} states after unlock BTS ${alias} NR BTS:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  10  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check BTS ${peer_alias} alarms after unlock BTS ${alias}:  console=True
    Check peer BTS alarms  ${peer_alias}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check BTS Administrative State
    [Arguments]  ${exp_administrativeState}  ${alias}
    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
    ${BTS_adminstate}=  Check Parameter value from SCF  item_dist_name=${nrbts_dn}  parameter_to_check=administrativeState
    ...  scf_path=${BTS_scf}
    Should match regexp  string=${BTS_adminstate}  pattern=${exp_administrativeState[6:-1]}

Check NR X2 alarm
    [Arguments]  ${alias}

    Log  BTS ${alias} NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    Log  BTS ${alias} NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True

    ${IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DSS}
    ...  ${${alias.upper()}_IGNORED_ALARMS_X2_6327}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS}  ignored_alarms=${IGNORED_ALARMS_FULL}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  time=10 min
    Log  BTS ${alias} NR "No X2 link available (7300)" alarm, found number: 1  console=True
    Log  BTS ${alias} NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1  console=True

Check peer BTS alarms
    [Arguments]  ${alias}
    ${IGNORED_ALARMS_FULL}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_DSS}
    ...  ${${alias.upper()}_IGNORED_ALARMS_X2_6327}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${IGNORED_ALARMS_FULL}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

Recover initial NR BTS shutdownNogNBCellTmr value
    Log  Recovering initial NR BTS shutdownNogNBCellTmr value  console=True
    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${alias}' in ${skipped_BTS_alias_list}
        Set shutdownNogNBCellTmr parameter value  ${${alias}_shutdownNogNBCellTmr_initial}  ${alias}
    END

Particular Teardown
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword And Continue On Failure  Admin Check If BTS Objects Are Unlocked  class_name=BTS  timeout=60  recover_timeout=60
        ...  connection=${alias}
    END
    Check all BTS cells availability status online
    Recover initial NR BTS shutdownNogNBCellTmr value

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
