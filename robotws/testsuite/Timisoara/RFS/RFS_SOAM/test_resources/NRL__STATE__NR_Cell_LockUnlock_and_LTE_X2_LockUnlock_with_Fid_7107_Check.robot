*** Settings ***
Documentation    TC__NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check
Variables    tc_variables/nrl__state__nr_cell_lock_unlock_and_lte_x2_lock_unlock_with_fid_7107_check_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}   3           # Number of NR lock/unlock cells and LTE X2 lock/unlock operations from WEBEM, default value 3
${nsaCellActivationAlarmTimer}    60    # The value that will be set to nsaCellActivationAlarmTimer parameter
${X2_administrativeState_lock}  locked  #  X2 administrative state value for Lock operation
${X2_administrativeState_unlock}  unlocked  # X2 administrative state value for Unlock operation

*** Keywords ***
TC__NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24961
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR NSA CELL lock and unlock and X2 lock and unlock with Fid 7107 check, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - prepare NR cell list
    ...  - perform Lock NR NSA cells
    ...  - perform X2 lock from LTE
    ...  - check X2 alarms on NR
    ...  - perform unlock NR NSA cells
    ...  - check Fid 7107 alarm
    ...  - perform unlock X2 from LTE
    ...  - check final state and alarms for both NR and LTE technologies
    ...
    ...  Pass criteria: lock/unlock operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25410 - [5G] [Refactoring Tracker] Use common KW for
    ...  extracting MRBTS, LNBTS, NRBTS id
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...  - 29.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30419 - Adapt SBTS_SBTS__SWM__RU_SW_Upgrade and other tests impacted by
    ...  CB013031 with TAF-5240
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-24961_NRL__STATE__NR_Cell_LockUnlock_and_LTE_X2_LockUnlock_with_Fid_7107_Check.png

    Set Tags    CA-STATE    OWNER-nicoleta.popescu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SBTS23R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all NR cells
    Step 4: Set nsaCellActivationAlarmTimer parameter value
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Lock all NR cells
        Step 6: Lock LTE X2
        Step 7: Unlock all NR cells
        Step 8: Unlock LTE X2
        Step 9: Check final number and state of Cells and RMs
    END
    Step 10: Restore initial nsaCellActivationAlarmTimer parameter value
    Step 11: Check final all BTS state
    Step 12: Check final all BTS alarms

    [Teardown]  Particular Teardown

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

Step ${index}: Get all NR cells
    Log  Step ${index}: Get all NR cells  console=True
    ${NR_CELL_list}=  Get Ids For All  NRCEL  alias=Master
    Sort List  ${NR_CELL_list}
    ${NR_CELL_count}=  Get Length  ${NR_CELL_list}
    Run Keyword If  ${NR_CELL_count} > 0
    ...  Log  NR cells found: ${NR_CELL_list}  console=True
    ...  ELSE
    ...  Fail  No NR cells are present in runtime view configuration!
    Set Test Variable  ${NR_CELL_list}
    Set Test Variable  ${NR_CELL_count}

    ${LTE_CELL_list}=  Get Ids For All  LNCEL  alias=Slave
    Set Test Variable  ${LTE_CELL_list}

    ${NR_SA_cell_list}  ${NR_NSA_cell_list}=  Get NR Cell Deployment Type list  ${NR_CELL_list}  Master
    ${NR_NSA_cell_count}=  Get Length  ${NR_NSA_cell_list}
    Set Test Variable  ${NR_NSA_cell_list}
    Set Test Variable  ${NR_NSA_cell_count}

    ${BTS_scf_initial}=  Admin Collect scf.xml with timestamp TAF  alias=Master
    Set Test Variable  ${BTS_scf_initial}
    ${nrbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/NRBTS-[\\d]+$  scf_path=${BTS_scf_initial}  alias=Master
    ${nrbts_dn}=  Get From List  ${nrbts_dn_list}  0
    Set Test Variable  ${nrbts_dn}

    ${lnbts_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/LNBTS-[\\d]+$  scf_path=${slave_scf_initial}  alias=Slave
    ${lnbts_dn}=  Get From List  ${lnbts_dn_list}  0
    Set Test Variable  ${lnbts_dn}
    ${LNADJGNB_id_list}=  Get LNADJGNB list  Slave
    Set Test Variable  ${LNADJGNB_id_list}
    ${LNADJGNB_count}=  Get Length  ${LNADJGNB_id_list}
    Set Test Variable  ${LNADJGNB_count}

Step ${index}: Set nsaCellActivationAlarmTimer parameter value
    Log  Step ${index}: Set nsaCellActivationAlarmTimer value to ${nsaCellActivationAlarmTimer}  console=True
    scf.Load Scf  file_path=${BTS_scf_initial}
    ${nsaCellActivationAlarmTimer_initial}=  Get Value From Scf  dist_name=${nrbts_dn}
    ...  p_name=nsaCellActivationAlarmTimer
    Set Test Variable  ${nsaCellActivationAlarmTimer_initial}
    coam.Perform Parameter Recommissioning  dist_name=${nrbts_dn}
    ...  parameter=nsaCellActivationAlarmTimer  operation=update  value=${nsaCellActivationAlarmTimer}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

Step ${index}: Restore initial nsaCellActivationAlarmTimer parameter value
    Log  Step ${index}: Restore initial nsaCellActivationAlarmTimer parameter value  console=True
    Recover initial nsaCellActivationAlarmTimer value

Step ${index}: Lock LTE X2
    [Documentation]
    ...  Lock X2 procedure via Plan is launched on LTE Slave

    Log  Step ${index}: Lock LTE X2  console=True
    Log  LTE X2 Lock will be performed via administrativeState parameter recomissioning  console=True
    Perform lock LTE X2
    Wait Until Keyword Succeeds  3 min  3 sec  Check X2 Link Status  locked  Slave
    Log  X2 link lock operation via Plan successful  console=True
    Log  Check X2 NR alarms after lock LTE X2:  console=True
    Check X2 NR alarms after lock LTE X2

Step ${index}: Unlock LTE X2
    [Documentation]
    ...  Unlock X2 procedure via Plan is launched on LTE Slave.

    Log  Step ${index}: Unlock LTE X2  console=True
    Log  LTE X2 Unlock will be performed via administrativeState parameter recomissioning  console=True
    Perform unlock LTE X2
    Log  Check X2 and LTE cell(s) states after unlock LTE X2:  console=True
    Wait Until Keyword Succeeds  3 min  3 sec  Check X2 Link Status  unlocked  Slave
    Log  X2 link unlock operation via Plan successful  console=True
    Assert Every  LNCEL  operationalState=${Enabled_}  timeout=600  alias=Slave
    Log  LTE cell(s) - operationalState=Enabled, as expected!  console=True
    Log  Check LTE states after unlock LTE X2:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  10  Slave
    Log  LTE site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

Perform ${action} LTE X2
    FOR  ${item}  IN  @{LNADJGNB_id_list}
         coam.Perform Parameter Recommissioning  dist_name=${item}
         ...  parameter=administrativeState  operation=update  value=${X2_administrativeState_${action}}
         ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Slave
    END

Check X2 NR alarms after lock LTE X2
    ${MASTER_EXPECTED_ALARMS_7319_multiplicated}=  Prepare Expected Alarms List  ${MASTER_EXPECTED_ALARMS_7319}  ${LNADJGNB_count}
    ${MASTER_EXPECTED_ALARMS_X2}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_7319_multiplicated}
    Set Test Variable  ${MASTER_EXPECTED_ALARMS_X2}

    Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: ${LNADJGNB_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_X2}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  time=10 min
    Log  NR "No X2 link available (7300)" alarm, found number: 1  console=True
    Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: ${LNADJGNB_count}  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True

Check X2 Administrative State is Unlocked
    ${x2LinkStatus_up}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  3 min  3 sec  Check X2 Link Status  unlocked  Slave
    Run Keyword If  not ${x2LinkStatus_up}  Run Keywords
    ...  Perform unlock LTE X2
    ...  AND  Sleep  60sec
    ...  AND  Log  X2 LTE Unlock indicated  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Lock all NR cells
    Log  Step ${index}: Lock all NR cells  console=True
    ${BTS_param}=  Get Parameters For All  BTS  alias=Master
    Set Test Variable  ${btsId}  ${BTS_param[0].btsId}
    FOR  ${item}  IN  @{NR_NSA_cell_list}
        Perform operation on NR cell via Plan  Lock  ${item}
    END

Step ${index}: Unlock all NR cells
    Log  Step ${index}: Unlock all NR cells  console=True
    FOR  ${item}  IN  @{NR_NSA_cell_list}
        Perform operation on NR cell via Plan  Unlock  ${item}
    END

    Sleep  ${nsaCellActivationAlarmTimer}s
    ${MASTER_EXPECTED_ALARMS_7107_multiplicated}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_7107}  ${NR_NSA_cell_count}
    ${MASTER_EXPECTED_ALARMS_full}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_X2}  ${MASTER_EXPECTED_ALARMS_7107_multiplicated}
    Log Long String  NR "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm, expected number:
    ...  ${NR_NSA_cell_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_full}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}  time=10 min
    Log  NR "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability (7107)" alarm, found number: ${NR_NSA_cell_count}
    ...  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True

Perform operation on NR cell via Plan
    [Documentation]
    ...  Perform operation Lock or Unlock NR cell via PLAN from Admin
    [Arguments]  ${operation}  ${item}
    ${NRCEL_id}=  Set Variable  ${item['id']['internal']}
    ${NRCEL_dn}=  Set Variable  ${item['id']['configuration']}
    ${year}  ${month}  ${day}  ${hour}  ${min}  ${sec}=  Get Time  format=year,month,day,hour,min,sec
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}_${sec}
    ${delta_id}=  Set Variable  ${operation}_Cell_${timestamp}
    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True
    ${administrativeState}=  Evaluate  '${operation}'+'ed'
    Append Parameter Update To Delta  dist_name=${NRCEL_dn}  parameter=administrativeState
    ...  value=${administrativeState}  delta_id=${delta_id}
    Log  Append parameter update to Delta: administrativeState=${administrativeState} for object ${NRCEL_id}  console=True
    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    coam.Perform Delta Recommissioning  alias=Master  delta_file=${delta_file}  skip_parameter_relation_errors=True
    ...  should_activate=True
    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True
    Log  ${operation} operation on NR cell ${NRCEL_id} successfully performed  console=True
    ${cell_state}=  Set Variable If  '${operation}' == 'Lock'  administrativeState=${Locked_}  administrativeState=${Unlocked_}
    Log  Check state and alarms after ${operation} operation on NR cell  console=True
    Assert  NRCEL  ${NRCEL_id}  ${cell_state}  timeout=60  alias=Master
    Log  ${NRCEL_id} - ${cell_state}  console=True

Recover initial nsaCellActivationAlarmTimer value
    Get Current Scf File  local_dir_path=${BTSFiles}/SCF_temp  file_name=SCF_temp.xml  connection=Master  with_auto_configured_parameters=${TRUE}
    scf.Load Scf  ${BTSFiles}/SCF_temp/SCF_temp.xml
    ${nsaCellActivationAlarmTimer_final}=  Get Value From Scf  dist_name=${nrbts_dn}
    ...  p_name=nsaCellActivationAlarmTimer
    Run Keyword If  '${nsaCellActivationAlarmTimer_final}' == '${nsaCellActivationAlarmTimer_initial}'  Return From Keyword
    coam.Perform Parameter Recommissioning  dist_name=${nrbts_dn}
    ...  parameter=nsaCellActivationAlarmTimer  operation=update  value=${nsaCellActivationAlarmTimer_initial}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

Check if NR cells are unlocked
    ${status}=  Run Keyword And Return Status  Assert Every  NRCEL  administrativeState=Unlocked  alias=Master
    Return From Keyword If  ${status}
    ${bts_id}=  Get Id For Current  BTS  timeout=60  alias=Master
    coam.Perform Commissioning  bts_id=${bts_id}  scf_file=${BTS_scf_initial}  skip_parameter_relation_errors=True
    ...  should_activate=True  timeout=600  alias=Master
    Log  NR BTS commissioning indicated  console=True

Particular Teardown
    Run Keyword And Continue On Failure  Check if NR cells are unlocked
    Run Keyword And Continue On Failure  Check X2 Administrative State is Unlocked
    Run Keyword And Continue On Failure  Recover initial nsaCellActivationAlarmTimer value
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
