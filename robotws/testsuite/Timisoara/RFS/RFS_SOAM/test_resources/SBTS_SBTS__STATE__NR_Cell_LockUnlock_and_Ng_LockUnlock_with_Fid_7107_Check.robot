*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
Variables    tc_variables/sbts_sbts__state__nr_cel_lock_unlock_and_ng_lock_unlock_with_fid_7107_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                   3         # Number of lock/unlock NR SA cells and lock/unlock SERVEDAMF Ng links operations, default value 3
${saCellActivationAlarmTimer}       60        # The value that will be set to saCellActivationAlarmTimer parameter, default value 60
${Cell_administrativeState_lock}    Locked    # Cell administrative state value for Lock operation, default value Locked
${Cell_administrativeState_unlock}  Unlocked  # Cell administrative state value for Unlock operation, default value Unlocked
${Ng_administrativeState_lock}      Locked    # Ng administrative state value for Lock operation, default value Locked
${Ng_administrativeState_unlock}    Unlocked  # Ng administrative state value for Unlock operation, default value Unlocked

*** Keywords ***
TC__SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24706
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for lock/unlock NR SA cells and lock/unlock SERVEDAMF Ng links with Fid 7107 check, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - TC preconditions: check at least one BTS is configured with NR SA cells and SERVEDAMF Ng links
    ...  - check initial state and alarms for both BTS
    ...  - perform on each BTS configured with NR SA cells and SERVEDAMF Ng links following operations:
    ...    - lock all NR SA cells
    ...    - lock all SERVEDAMF Ng links
    ...    - unlock all NR SA cells
    ...    - check FID 7107 alarm
    ...    - unlock all SERVEDAMF Ng links
    ...  - check final state and alarms for both BTS
    ...
    ...  Pass criteria: lock/unlock operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-24706 - [5G][CB007582] SBTS_SBTS NR_SA_Cell_lock_unlock_by_commissioning_FID7107
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25410 - [5G] [Refactoring Tracker] Use common KW for
    ...  extracting MRBTS, LNBTS, NRBTS id
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 26.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27949 - [5G] Adapt
    ...  SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check to work on NRL configuration where 5G BTS is in SA mode
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-24706_SBTS_SBTS__STATE__NR_Cell_LockUnlock_and_Ng_LockUnlock_with_Fid_7107_Check.png

    Set Tags    CA-STATE    OWNER-nicoleta.popescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SBTS23R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Check saCellActivationAlarmTimer parameter value
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform NR SA cells and SERVEDAMF Ng links operations
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_operation_list}=  Create List

    FOR  ${alias}  IN  @{alias_list}

        ${NR_cell_id_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
        ${NR_SA_cell_id_list}  ${NR_NSA_cell_id_list}=  Get NR Cell Deployment Type list  ${NR_cell_id_list}  ${alias}
        ${NR_SA_cell_count}=  Get Length  ${NR_SA_cell_id_list}
        Set Test Variable  ${${alias}_NR_SA_cell_id_list}  ${NR_SA_cell_id_list}
        Set Test Variable  ${${alias}_NR_SA_cell_count}  ${NR_SA_cell_count}

        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp
        ${SERVEDAMF_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/SERVEDAMF-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        Sort List  ${SERVEDAMF_dn_list}
        ${SERVEDAMF_count}=  Get Length  ${SERVEDAMF_dn_list}
        Set Test Variable  ${${alias}_SERVEDAMF_dn_list}  ${SERVEDAMF_dn_list}
        Set Test Variable  ${${alias}_SERVEDAMF_count}  ${SERVEDAMF_count}

        Run Keyword If  ${NR_SA_cell_count} > 0 and ${SERVEDAMF_count} > 0  Append To List  ${BTS_operation_list}  ${alias}

    END

    ${BTS_operation_count}=  Get Length  ${BTS_operation_list}
    Run Keyword If  ${BTS_operation_count} == 0  Run Keywords
        ...  Log  No BTS configured with NR SA cells and SERVEDAMF Ng links!  console=True
        ...  AND  Fail  No BTS configured with NR SA cells and SERVEDAMF Ng links!

    Set Test Variable  ${BTS_operation_list}

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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Check saCellActivationAlarmTimer parameter value
    Log  Step ${index}: Check saCellActivationAlarmTimer parameter value  console=True

    FOR  ${alias}  IN  @{BTS_operation_list}

        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp
        ${NRBTS_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
        ${NRBTS_dn}=  Get From List  ${NRBTS_dn_list}  0
        ${saCellActivationAlarmTimer_info}=  Check Parameter Value from SCF  item_dist_name=${NRBTS_dn}
        ...  parameter_to_check=saCellActivationAlarmTimer  scf_path=${BTS_scf}

        Set Test Variable  ${${alias}_saCellActivationAlarmTimer_initial}  ${saCellActivationAlarmTimer_info}

        Run Keyword If  ${saCellActivationAlarmTimer_info} == ${saCellActivationAlarmTimer}  Run Keywords
        ...  Log  Parameter saCellActivationAlarmTimer = ${saCellActivationAlarmTimer_info} already set, no action needed!  console=True
        ...  AND  Continue For Loop

        coam.Perform Parameter Recommissioning  dist_name=${NRBTS_dn}  parameter=saCellActivationAlarmTimer  operation=update
        ...  value=${saCellActivationAlarmTimer}  skip_parameter_relation_errors=True  should_activate=True  timeout=300  alias=${alias}

        ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp
        ${saCellActivationAlarmTimer_info}=  Check Parameter Value from SCF  item_dist_name=${NRBTS_dn}
        ...  parameter_to_check=saCellActivationAlarmTimer  scf_path=${BTS_scf}

        Run Keyword If  ${saCellActivationAlarmTimer_info} == ${saCellActivationAlarmTimer}
        ...  Log  Parameter saCellActivationAlarmTimer = ${saCellActivationAlarmTimer_info}, successfully commissioned!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Parameter saCellActivationAlarmTimer = ${saCellActivationAlarmTimer_info}, not properly commissioned!  level=ERROR
        ...  AND  Fail  Parameter saCellActivationAlarmTimer = ${saCellActivationAlarmTimer_info}, not properly commissioned!

    END

Step ${index}: Perform NR SA cells and SERVEDAMF Ng links operations
    [Documentation]
    ...  Operations will be performed only on BTS configured with both NR SA cells and SERVEDAMF Ng links items

    FOR  ${alias}  IN  @{BTS_operation_list}

        Log  Step ${index}: ***** Perform NR SA cells and SERVEDAMF Ng links operations on ${alias} BTS *****  console=True
        Lock all NR SA cells  ${alias}
        Lock all SERVEDAMF Ng links  ${alias}
        Unlock all NR SA cells  ${alias}
        Check BTS alarms  ${alias}
        Unlock all SERVEDAMF Ng links  ${alias}
        Check all BTS cells availability status online

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Lock all NR SA cells
    [Documentation]
    ...  Perform Lock all NR SA cells configured on BTS by recommissioning from Admin
    [Arguments]  ${alias}

    Log  Lock all NR SA cells configured on ${alias} BTS  console=True

    FOR  ${item}  IN  @{${alias}_NR_SA_cell_id_list}

        Perform operation on NR SA cell by recommissioning  Lock  ${item}  ${alias}

    END

    Log  Check ${alias} BTS alarms after Lock operation on all NR SA cells  console=True

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Lock all SERVEDAMF Ng links
    [Documentation]
    ...  Perform Lock SERVEDAMF Ng links configured on BTS by recommissioning from Admin
    [Arguments]  ${alias}

    Log  Lock SERVEDAMF Ng links configured on ${alias} BTS  console=True

    FOR  ${item}  IN  @{${alias}_SERVEDAMF_dn_list}

         Perform operation on SERVEDAMF Ng link by recommissioning  Lock  ${item}  ${alias}

    END

Unlock all NR SA cells
    [Documentation]
    ...  Perform Unlock all NR SA cells configured on BTS by recommissioning from Admin
    [Arguments]  ${alias}

    Log  Unlock all NR SA cells configured on ${alias} BTS  console=True

    FOR  ${item}  IN  @{${alias}_NR_SA_cell_id_list}

        Perform operation on NR SA cell by recommissioning  Unlock  ${item}  ${alias}

    END

Check BTS alarms
    [Documentation]
    ...  Check BTS alarms after unlock all NR SA cells with SERVEDAMF Ng links still locked
    [Arguments]  ${alias}

    Log  Check ${alias} BTS alarms after Unlock operation on all NR SA cells with SERVEDAMF Ng links still locked  console=True
    Log  Wait for saCellActivationAlarmTimer to expire: ${saCellActivationAlarmTimer}s  console=True

    Sleep  ${saCellActivationAlarmTimer}s
    ${SBTS_EXPECTED_ALARMS}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_7107}  ${${alias}_NR_SA_cell_count}
    Log Long String  ${alias} SBTS "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm, expected
    ...  number: ${${alias}_NR_SA_cell_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  time=10 min
    Log Long String  ${alias} SBTS "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm, found
    ...  number: ${${alias}_NR_SA_cell_count}  console=True
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Unlock all SERVEDAMF Ng links
    [Documentation]
    ...  Perform Unlock SERVEDAMF Ng links configured on BTS by recommissioning from Admin
    [Arguments]  ${alias}

    Log  Unlock SERVEDAMF Ng links configured on ${alias} BTS  console=True

    FOR  ${item}  IN  @{${alias}_SERVEDAMF_dn_list}

         Perform operation on SERVEDAMF Ng link by recommissioning  Unlock  ${item}  ${alias}

    END

Perform operation on NR SA cell by recommissioning
    [Documentation]
    ...  Perform operation Lock or Unlock NR SA cell by recommissioning from Admin
    [Arguments]  ${operation}  ${cell_info}  ${alias}

    ${cell_dn_administrativeState}=  Set Variable If  '${operation}' == 'Lock'  ${Cell_administrativeState_lock}
    ...  '${operation}' == 'Unlock'  ${Cell_administrativeState_unlock}
    ${cell_id_status_check}=  Set Variable If  '${operation}' == 'Lock'
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, administrativeState=${Locked_}, blockingState=${Unblocked_}
    ...  '${operation}' == 'Unlock'
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, administrativeState=${Unlocked_}, blockingState=${Unblocked_}
    ${cell_id_status}=  Set Variable If  '${operation}' == 'Lock'
    ...  operationalState=Disabled, availabilityStatus=Offline, administrativeState=Locked, blockingState=Unblocked
    ...  '${operation}' == 'Unlock'
    ...  operationalState=Disabled, availabilityStatus=Offline, administrativeState=Unlocked, blockingState=Unblocked

    ${cell_id}=  Set Variable  ${cell_info['id']['internal']}
    ${cell_dn}=  Set Variable  ${cell_info['id']['configuration']}

    Log  Perform ${operation} operation on NR SA cell ${cell_id} from ${alias} BTS by recommissioning  console=True

    coam.Perform Parameter Recommissioning  dist_name=${cell_dn}  parameter=administrativeState  operation=update
    ...  value=${cell_dn_administrativeState}  skip_parameter_relation_errors=True  should_activate=True  timeout=60  alias=${alias}

    Assert  class_name=NRCEL  id=${cell_id}  parameters=${cell_id_status_check}  timeout=300  connection=${alias}
    Log  ${alias} BTS cell ${cell_id} status:\n - ${cell_id_status}  console=True
    Log  ${operation} operation on NR SA cell ${cell_id} from ${alias} BTS successfully performed  console=True

Perform operation on SERVEDAMF Ng link by recommissioning
    [Documentation]
    ...  Perform operation Lock or Unlock SERVEDAMF Ng link by recommissioning
    [Arguments]  ${operation}  ${SERVEDAMF_dn}  ${alias}

    ${SERVEDAMF_dn_administrativeState}=  Set Variable If  '${operation}' == 'Lock'  ${Ng_administrativeState_lock}
    ...  '${operation}' == 'Unlock'  ${Ng_administrativeState_unlock}

    Log  Perform ${operation} operation SERVEDAMF Ng link ${SERVEDAMF_dn} from ${alias} BTS by recommissioning  console=True

    coam.Perform Parameter Recommissioning  dist_name=${SERVEDAMF_dn}  parameter=administrativeState  operation=update
    ...  value=${SERVEDAMF_dn_administrativeState}  skip_parameter_relation_errors=True  should_activate=True  timeout=300  alias=${alias}

    Wait Until Keyword Succeeds  3 min  5 sec  Check SERVEDAMF Ng link status  ${SERVEDAMF_dn}  ${SERVEDAMF_dn_administrativeState}  ${alias}
    Log  SERVEDAMF Ng link ${SERVEDAMF_dn} status:\n - administrativeState=${SERVEDAMF_dn_administrativeState}  console=True
    Log  ${operation} operation on SERVEDAMF Ng link ${SERVEDAMF_dn} from ${alias} BTS successfully performed  console=True

Check SERVEDAMF Ng link status
    [Arguments]  ${SERVEDAMF_dn}  ${exp_administrativeState}  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp

    ${administrativeState_info}=  Check Parameter Value from SCF  item_dist_name=${SERVEDAMF_dn}  parameter_to_check=administrativeState
    ...  scf_path=${BTS_scf}

    Should Be Equal As Strings  ${administrativeState_info}  ${exp_administrativeState}

Recover initial saCellActivationAlarmTimer value

    FOR  ${alias}  IN  @{BTS_operation_list}

        Recover initial saCellActivationAlarmTimer value on BTS  ${alias}

    END

Recover initial saCellActivationAlarmTimer value on BTS
    [Arguments]  ${alias}

    ${BTS_scf}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}  folder_path=${BTSFiles}/SCF_temp
    ${NRBTS_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${BTS_scf}  alias=${alias}
    ${NRBTS_dn}=  Get From List  ${NRBTS_dn_list}  0
    ${saCellActivationAlarmTimer_info}=  Check Parameter Value from SCF  item_dist_name=${NRBTS_dn}  parameter_to_check=saCellActivationAlarmTimer
    ...  scf_path=${BTS_scf}

    Run Keyword If  ${saCellActivationAlarmTimer_info} != ${${alias}_saCellActivationAlarmTimer_initial}
    ...  coam.Perform Parameter Recommissioning  dist_name=${NRBTS_dn}  parameter=saCellActivationAlarmTimer  operation=update
    ...  value=${${alias}_saCellActivationAlarmTimer_initial}  skip_parameter_relation_errors=True  should_activate=True  timeout=300  alias=${alias}

Check if NR cells are unlocked

    FOR  ${alias}  IN  @{BTS_operation_list}

        Admin Check If BTS Objects Are Unlocked  class_name=NRCEL  timeout=60  recover_timeout=10  connection=${alias}

    END

Check if SERVEDAMF Ng links are unlocked
    [Arguments]  ${timeout}=300  ${recover_timeout}=10

    FOR  ${alias}  IN  @{BTS_operation_list}

        Check if SERVEDAMF Ng links are unlocked on BTS  ${timeout}  ${recover_timeout}  ${alias}

    END

Check if SERVEDAMF Ng links are unlocked on BTS
    [Arguments]  ${timeout}  ${recover_timeout}  ${alias}

    FOR  ${item}  IN  @{${alias}_SERVEDAMF_dn_list}

         ${Ng_link_status}=  Run Keyword And Return Status  Check SERVEDAMF Ng link status  ${item}  Unlocked  ${alias}

         Continue For Loop If  ${Ng_link_status}

         coam.Perform Parameter Recommissioning  dist_name=${item}  parameter=administrativeState  operation=update  value=Unlocked
         ...  skip_parameter_relation_errors=True  should_activate=True  timeout=${timeout}  alias=${alias}
         Sleep  ${recover_timeout}s  Wait for SERVEDAMF Ng link recovery
         Log  SERVEDAMF Ng link unlock recovery indicated  console=True

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if NR cells are unlocked
    Run Keyword And Continue On Failure  Check if SERVEDAMF Ng links are unlocked
    Run Keyword And Continue On Failure  Recover initial saCellActivationAlarmTimer value
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
