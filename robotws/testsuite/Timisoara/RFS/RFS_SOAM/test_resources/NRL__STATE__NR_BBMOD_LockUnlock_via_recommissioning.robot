*** Settings ***
Documentation    TC__NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning
Variables    tc_variables/nrl__state__nr_bbmod_lock_unlock_via_recommissioning_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of NR BBMOD Lock/Unlock operations, default value 3
${BTS_PRIMARY_LINK}  # BTS for primary link set before NR BBMOD Lock/Unlock, possible values: empty (no set required),
                     # Master (Master set required) or Slave (Slave set required), default value: empty
${SET_PRIMARY_LINK_TIME}  720  # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}  LANE  # Procedure for setting BTS PRIMARY LINK, possible values: BTS (BTS Reset), LANE (Lock Unlock SFP LANE)
${BBMOD_SN}              # serial nr on wich BBMOD to Lock-Unlock,
                         # possible values: empty (no set required, all NR BBMODs in BTS lock-unlock), BBMOD serial nr (set required)

*** Keywords ***
TC__NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-20825
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR BBMODs Lock/Unlock, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - set if needed primary link on requested technology
    ...  - perform Lock/Unlock on selected BBMOD/all BBMODs on NR Master
    ...  - check reset behavior on NR and LTE based on IMS info as follows:
    ...    - NR site: reset number is 0
    ...    - LTE site: reset number is 0
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: NR BBMODs Lock/Unlock BTS operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.05.2022 -
    ...  https://jiradc.ext.net.nokia.com/browse/TAT-20825 - [5G][MT][CPRI]New NRL scenario NRL__STATE__NR_BBMOD_Lock_Unlock_via_Plan
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 22.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24198 - [5G][Reset Number ims2] Update NRL STATE ... scenarios to take
    ...  reset number from ims2 - P2- part1
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-20825_NRL__STATE__NR_BBMOD_LockUnlock_via_recommissioning.png

    Set Tags    CA-STATE    OWNER-ariel.ciucurita@nokia.com    AUTHOR-ariel.ciucurita@nokia.com    PHASE-CRT    SW-SBTS22R2

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get NR BBMOD list and cells info for both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Set shared Primary Link before NR BBMOD Lock Unlock operation
        Step 5: Lock Unlock NR BBMOD
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check both BTS reset behavior based on IMS info
        Step 9: Check final number and state of Cells and RMs
    END

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

Step ${index}: Get NR BBMOD list and cells info for both BTS
    [Documentation]
    ...  Get NR BBMOD list and cells info for both BTS from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get NR BBMOD list and cells info for both BTS  console=True
    ${NR_BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=Master
    Sort List  ${NR_BBMOD_list}
    ${NR_BBMOD_count}=  Get Length  ${NR_BBMOD_list}
    Run Keyword If  ${NR_BBMOD_count} > 0
    ...  Log  NR BBMOD found: ${NR_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No NR BBMOD are present in runtime view configuration!
    Set Test Variable  ${NR_BBMOD_list}
    Set Test Variable  ${BBMOD_list}  ${NR_BBMOD_list}
    Set Test Variable  ${NR_BBMOD_count}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Master_dedicated_RMOD_list}

    ${NR_RMOD_list}=  Combine Lists  ${Master_shared_RMOD_list}  ${Master_dedicated_RMOD_list}
    Set Test Variable  ${NR_RMOD_list}

    Get NR BBMOD SN dict

    ${NR_CELL_list}=  Get Ids For All  NRCEL  alias=Master
    ${NR_CELL_count}=  Get Length  ${NR_CELL_list}
    Set Test Variable  ${NR_CELL_count}

Step ${index}: Set shared Primary Link before NR BBMOD Lock Unlock operation
    [Documentation]
    ...  Set shared Primary Link if needed

    Log  Step ${index}: Set shared Primary Link before NR BBMOD LockUlnock operation  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Log  ==================================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with existing Primary Link configuration *****  console=True
    ...  AND  Log  ==================================================================================  console=True
    ...  AND  Return From Keyword
    ...  ELSE  Run Keywords
    ...  Log  =============================================================================  console=True
    ...  AND  Log  ***** Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK} *****  console=True
    ...  AND  Log  =============================================================================  console=True
    Run Keyword If  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Set Primary Link status based on linkModeSynchronization  module_type=FHS
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}
    ...  ELSE  Run Keywords
    ...  Log  Please set one of following values for test argument \${BTS_PRIMARY_LINK}: Master or Slave  level=ERROR
    ...  AND  Fail  Improper value for argument!

Step ${index}: Lock Unlock NR BBMOD
    Log  Step ${index}: LockUnlock NR BBMOD  console=True
    Get Current Date UTC info  start
    Run Keyword If  '${BBMOD_SN}' == ''  Lock Unlock All NR BBMOD
    ...  ELSE  Lock Unlock NR BBMOD By SN  ${BBMOD_SN}
    Get Current Date UTC info  end

Step ${index}: Check both BTS reset behavior based on IMS info
    [Documentation]
    ...  RESET info for both NR and LTE is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check both BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS Objects State
    [Arguments]   ${tech}  ${BTS_obj_class}  ${BTS_obj_list}  ${BTS_obj_state_check}  ${BTS_obj_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_obj_list}
        Assert  ${BTS_obj_class}  ${item}  ${BTS_obj_state_check}  timeout=${timeout}  alias=${alias}
        Log  ${tech} ${BTS_obj_class} ${item} status:\n - ${BTS_obj_state}  console=True
    END

Lock Unlock All NR BBMOD
    FOR  ${item}  IN  @{NR_BBMOD_list}
        Lock Unlock NR BBMOD  ${item}
    END

Lock Unlock NR BBMOD By SN
    [Arguments]  ${NR_BBMOD_sn}
    Dictionary should contain key  ${NR_BBMOD_SN_dict}  ${NR_BBMOD_sn}  'no NR BBMOD with given serial nr, BBMOD dic does not contain key'
    ${BBMOD_id}=  Get From Dictionary  ${NR_BBMOD_SN_dict}  ${NR_BBMOD_sn}
    Lock Unlock NR BBMOD  ${BBMOD_id}

Lock Unlock NR BBMOD
    [Arguments]  ${NR_BBMOD_id}
    ${BBMOD_state_locked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Locked_}
    ${BBMOD_state_unlocked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${BBMOD_state_locked}=  Set Variable  operationalState=Enabled, administrativeState=Locked
    ${BBMOD_state_unlocked}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${CELL_BBMOD_list}=  Get Cell Mapping By Module Id  module_id=${NR_BBMOD_id}  connection=Master
    ${CELL_not_BBMOD_list}=  Get Ids For All  class_name=NRCEL  connection=Master
    FOR  ${item}  IN  @{CELL_BBMOD_list}
        Remove Values From List  ${CELL_not_BBMOD_list}  ${item}
    END

    ${NR_BBMOD_SCF_DN}=  Get BBMOD SCF DN  ${NR_BBMOD_id}
    Set Test Variable  ${NR_BBMOD_SCF_DN}

    Log  BBMOD ${NR_BBMOD_id} Lock will be performed via administrativeState parameter recomissioning  console=True
    ${bts_info_id}=  Admin Get BTS ID from SCF  ${master_scf_initial}

    coam.Perform Parameter Recommissioning  dist_name=${NR_BBMOD_SCF_DN}
    ...  parameter=administrativeState  operation=update  value=Locked
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

    Log  Check NR state and alarms after "Lock" operation on NR BBMOD ${NR_BBMOD_id}:  console=True
    Assert  class_name=BBMOD  id=${NR_BBMOD_id}  parameters=${BBMOD_state_locked_check}  timeout=60  connection=Master
    Log  NR BBMOD ${NR_BBMOD_id} status:\n - ${BBMOD_state_locked}  console=True
    Log  Check NR cell(s) status mapped on BBMOD:  console=True
    Check BTS Objects State  NR  NRCEL  ${CELL_BBMOD_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Master
    Log  Check NR cell(s) status not mapped on BBMOD:  console=True
    Check BTS Objects State  NR  NRCEL  ${CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  10  Master
    Log  Check NR RMODs status:  console=True
    Check BTS Objects State  NR  RMOD  ${NR_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  10  Master

    ${NR_CELL_BBMOD_list}=  Get Cell Mapping By Module Id  module_id=${NR_BBMOD_id}  alias=Master
    Set Test Variable  ${NR_CELL_BBMOD_list}
    ${NR_CELL_BBMOD_count}=  Get Length  ${NR_CELL_BBMOD_list}
    Set Test Variable  ${NR_CELL_BBMOD_count}

    Run Keyword If  ${NR_BBMOD_count} == 1 or ${NR_CELL_BBMOD_count} == ${NR_CELL_count}  Run Keywords
    ...  Log  Check NR state for 1 BBMOD instaled  console=True
    ...  AND  Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_}  ${Unblocked_}  600  Master
    ...  AND  Log  NR site - proceduralState: integratedtoran, blockingState: Unblocked  console=True

    Log  Check LTE state and alarms after "Lock" operation on NR BBMOD ${NR_BBMOD_id}:  console=True
    Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=10  connection=Slave
    Log  All LTE BBMOD status:\n - ${BBMOD_state_unlocked}  console=True
    Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=10  connection=Slave
    Log  All LTE cell(s) status:\n - ${CELL_state_enabled}  console=True
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=10  connection=Slave
    Log  All LTE RMODs status:\n - ${RMOD_state_enabled}  console=True

    Log  Check NR and LTE alarms when NR BBMOD ${NR_BBMOD_id} is "Locked":  console=True

    Run Keyword If  ${NR_BBMOD_count} == 1 or ${NR_CELL_BBMOD_count} == ${NR_CELL_count}  Run Keywords
    ...  Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    ...  ELSE
    ...  Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Check LTE alarms
    Log  LTE site - expected, ignored and critical alarms checked  console=True

    Log  BBMOD ${NR_BBMOD_id} Unlock will be performed via administrativeState parameter recomissioning  console=True

    coam.Perform Parameter Recommissioning  dist_name=${NR_BBMOD_SCF_DN}
    ...  parameter=administrativeState  operation=update  value=Unlocked
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

    Log  Check NR state and alarms after "Unlock" operation on BBMOD ${NR_BBMOD_id}:  console=True
    Assert  class_name=BBMOD  id=${NR_BBMOD_id}  parameters=${BBMOD_state_unlocked_check}  timeout=60  connection=Master
    Log  NR BBMOD ${NR_BBMOD_id} status:\n - ${BBMOD_state_unlocked}   console=True
    Assert Every  class_name=NRCEL  parameters=${CELL_state_enabled_check}  timeout=300  connection=Master
    Log  All NR cell(s) status:\n - ${CELL_state_enabled}  console=True
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=10  connection=Master
    Log  All NR RMODs status:\n - ${RMOD_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Log  Check LTE state and alarms after "Unlock" operation on NR BBMOD ${NR_BBMOD_id}:  console=True
    Assert Every  class_name=BBMOD  parameters=${BBMOD_state_unlocked_check}  timeout=10  connection=Slave
    Log  All LTE BBMOD status:\n - ${BBMOD_state_unlocked}  console=True
    Assert Every  class_name=LNCEL  parameters=${CELL_state_enabled_check}  timeout=10  connection=Slave
    Log  All LTE cell(s) status:\n - ${CELL_state_enabled}  console=True
    Assert Every  class_name=RMOD  parameters=${RMOD_state_enabled_check}  timeout=10  connection=Slave
    Log  All LTE RMODs status:\n - ${RMOD_state_enabled}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  NR LTE site - expected, ignored and critical alarms checked  console=True

Get NR BBMOD SN dict
    ${NR_BBMOD_SN_dict}=  Create Dictionary
    ${BBMOD_list}=  Get Ids For All  class_name=BBMOD  connection=Master
    Sort List  ${BBMOD_list}
    FOR  ${item}  IN  @{BBMOD_list}
        ${BBMOD_PARAM_list}=  Get Parameters For  class_name=BBMOD  id_num=${item}  connection=Master
        Set To Dictionary  ${NR_BBMOD_SN_dict}  ${BBMOD_PARAM_list['serialNumber']}  ${BBMOD_PARAM_list['id']}
    END
    Set Test Variable  ${NR_BBMOD_SN_dict}

Get BBMOD SCF DN
    [Documentation]
    ...  KW used to get BBMOD SCF distinguished name

    [Arguments]  ${BBMOD_R_ID}
    ${BTS_info}=  Get Bts Info  alias=Master
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${BBMOD_R_ID}'
    END
    [Return]  ${item['id']['configuration']}

Check LTE alarms
    Run Keyword If  ${NR_BBMOD_count} == 1 or ${NR_CELL_BBMOD_count} == ${NR_CELL_count}  Run Keywords
    ...  Sleep  420s
    ...  AND  Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{SLAVE_EXPECTED_ALARMS}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    ...  ELSE
    ...  Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}

Particular Teardown
    Admin Check If BTS Objects Are Unlocked  class_name=BBMOD  timeout=60  recover_timeout=60  connection=Master
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown