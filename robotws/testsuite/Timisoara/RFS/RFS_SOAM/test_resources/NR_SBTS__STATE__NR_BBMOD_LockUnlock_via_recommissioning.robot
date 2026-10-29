*** Settings ***
Documentation    TC__NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
Variables    tc_variables/nr_sbts__state_nr_bbmod_lockunlock_via_recommissioning.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                    3         # Number of NR Recommissioning operations, default value 3
${BTS_PRIMARY_LINK}                            # BTS primary link set before NR Recommissioning, possible values: empty (no set required),
                                               # Master (Master set required) or Slave (Slave set required); default value: empty
${SET_PRIMARY_LINK_TIME}             720       # Maximum time in seconds to wait for Primary Link set on ${BTS_PRIMARY_LINK}, default value: 720
${SET_PRIMARY_LINK_PROCEDURE}        LANE      # Procedure for setting BTS_PRIMARY_LINK, possible values: BTS (BTS Reset),LANE (Lock Unlock SFP LANE)
${BBMOD_administrativeState_lock}    Locked    # BBMOD administrative state value for Lock operation
${BBMOD_administrativeState_unlock}  Unlocked  # BBMOD administrative state value for Unlock operation

*** Keywords ***
TC__NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-19189
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for NR_BBMOD_LockUnlock_via_recommissioning, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - set if needed primary CPRI on requested technology
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - get NR BBMODs list
    ...  - Perform Lock-Unlock operation on found BBMOD via parameter recomissioning
    ...  - Check BBMOD state, cells state and BTS expected alarms are present
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: Lock-Unlock operation performed via parameter recommissioning was successfull, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.03.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19189 -
    ...  [NR][P17]Create new automated test NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    ...  - 23.07.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19956 -
    ...  Refactor tests using "Set RMOD CPRI Primary Status" to provide Master/Slave argument to KW instead of NR/LTE
    ...  - 13.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20237 - Add CPRI primary link check functionality for new TDD RU AWHHF/D
    ...  - 14.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20319 - [Refactoring] Optimize Repeat_Counter loop in test cases - NR-SBTS
    ...  - 09.12.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20400 -
    ...  [5G] Enhancement/modification should be done for NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    ...  - 23.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20865 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NR_SBTS
    ...  - 12.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21303 - [Legacy][taf.sbts.oam.coam.admin] Udate & test TC NR_SBTS
    ...  - 14.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NR_SBTS
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 20.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22362 - [5G][PrimaryLink] [P4] NR_SBTS__STATE__ TCs refactor to use
    ...  'hran_general.Set Primary Link status based on linkModeSynchronization'
    ...  - 18.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23135 - [5G] NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning
    ...  need to be updated
    ...  - 03.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23925 - [5G][TC review][NR-SBTS] Remove Cells "AdministrativeState" check in
    ...  all NR-SBTS robots
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-19189_NR_SBTS__STATE__NR_BBMOD_LockUnlock_via_recommissioning.png

    Set Tags    CA-CM    OWNER-geraldina.isfan@nokia.com    AUTHOR-adelina.ivan@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Primary Link TC Parameter Check
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get NR BBMODs list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Set Shared RMOD Primary Link before NR BBMOD Lock-Unlock operation
        Step 4: Perform Lock-Unlock operation on found BBMODS
    END
    Step 5: Check final all BTS state
    Step 6: Check final all BTS alarms
    Step 7: Check final number and state of Cells and RMs

    [Teardown]    Particular Teardown

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

Step ${index}: Get NR BBMODs list
    [Documentation]
    ...  NR BBMODs list is created

    [Timeout]  15 min
    Log  Step ${index}: Get NR BBMODs list  console=True
    ${NR_BBMOD_list}=  Get Ids For All  BBMOD  alias=Master
    Sort List  ${NR_BBMOD_list}
    ${NR_BBMOD_count}=  Get Length  ${NR_BBMOD_list}
    Run Keyword If  ${NR_BBMOD_count} > 0
    ...  Log  NR BBMOD found: ${NR_BBMOD_list}  console=True
    ...  ELSE
    ...  Fail  No NR BBMOD are present in runtime view configuration!

    Set Test Variable  ${NR_BBMOD_list}

Step ${index}: Perform Lock-Unlock operation on found BBMODS
    [Documentation]
    ...  Lock-Unlock operation on BBMODs is performed one-by-one

    [Timeout]  20 min
    Log  Step ${index}: Perform Lock-Unlock operation on found BBMODS  console=True
    FOR  ${item}  IN  @{NR_BBMOD_list}
        Lock NR BBMOD  ${item}
        Unlock NR BBMOD  ${item}
    END

Set Shared RMOD Primary Link before NR BBMOD Lock-Unlock operation
    [Documentation]
    ...  Set shared RMOD Primary Link if needed

    Run Keyword If  '${BTS_PRIMARY_LINK}' == ''  Run Keywords
    ...  Highlight Log  Test action will be performed with existing Primary Link configuration
    ...  AND  Return From Keyword
    ...  ELSE IF  '${BTS_PRIMARY_LINK}' in ['Master','Slave']  Run Keywords
    ...  Highlight Log  Test action will be performed with Primary Link set on BTS ${BTS_PRIMARY_LINK}
    ...  AND  Set Primary Link status based on linkModeSynchronization  module_type=RMOD
    ...  procedure_for_Primary_Link_set=${SET_PRIMARY_LINK_PROCEDURE}  alias=${BTS_PRIMARY_LINK}  wait_for_Primary_Link_set=${SET_PRIMARY_LINK_TIME}

Get BBMOD SCF DN
    [Documentation]
    ...  KW used to get BBMOD SCF distinguished name

    [Arguments]  ${BBMOD_R_ID}
    ${BTS_info}=  Get Bts Info  alias=Master
    FOR  ${item}  IN  @{BTS_info['basebandModules']}
        Exit For Loop If  '${item['id']['internal']}' == '${BBMOD_R_ID}'
    END
    [Return]  ${item['id']['configuration']}

Lock NR BBMOD
    [Arguments]  ${NR_BBMOD_id}
    ${BBMOD_state_locked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Locked_}
    ${CELL_state_dependency_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Dependency_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${BBMOD_state_locked}=  Set Variable  operationalState=Enabled, administrativeState=Locked
    ${CELL_state_dependency}=  Set Variable  operationalState=Disabled, availabilityStatus=Dependency
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${BBMOD_param}=  Get Parameters For  class_name=BBMOD  id_num=${NR_BBMOD_id}  alias=Master
    Set Test Variable  ${NR_BBMOD_sn}  ${BBMOD_param['serialNumber']}
    ${NR_BBMOD_SCF_DN}=  Get BBMOD SCF DN  ${NR_BBMOD_id}
    Set Test Variable  ${NR_BBMOD_SCF_DN}

    Log  "Lock" operation on BBMOD ${NR_BBMOD_id} with SN ${NR_BBMOD_sn} will be performed via administrativeState parameter recomissioning
    ...  console=True
    ${bts_info_id}=  Admin Get BTS ID from SCF  ${master_scf_initial}
    Set Test Variable  ${bts_info_id}
    ${NR_CELL_list}=  Get Ids For All  NRCEL  alias=Master
    Sort List  ${NR_CELL_list}
    ${NR_CELL_count}=  Get Length  ${NR_CELL_list}

    ${NR_CELL_BBMOD_list}=  Get Cell Mapping By Module Id  module_id=${NR_BBMOD_id}  alias=Master
    Set Test Variable  ${NR_CELL_BBMOD_list}
    ${NR_CELL_BBMOD_count}=  Get Length  ${NR_CELL_BBMOD_list}
    Run Keyword If  ${NR_CELL_BBMOD_count}==0
    ...  Log  There are no cells mapped on ${NR_BBMOD_id}  console=True
    ...  ELSE  Log  NR Cells mapped to ${NR_BBMOD_id}: ${NR_CELL_BBMOD_list}  console=True
    Set Test Variable  ${NR_CELL_not_BBMOD_list}  ${NR_CELL_list}
    FOR  ${item}  IN  @{NR_CELL_BBMOD_list}
        Remove Values From List  ${NR_CELL_not_BBMOD_list}  ${item}
    END

    coam.Perform Parameter Recommissioning  dist_name=${NR_BBMOD_SCF_DN}  parameter=administrativeState  operation=update
    ...  value=${BBMOD_administrativeState_lock}  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

    Log  Check NR BBMOD state and alarms after "Lock" operation  console=True
    Assert  BBMOD  ${NR_BBMOD_id}  ${BBMOD_state_locked_check}  timeout=180  alias=Master
    Log  NR BBMOD - ${BBMOD_state_locked}, operationalState=Enabled  console=True
    Run Keyword If  ${NR_CELL_BBMOD_count}==${NR_CELL_count}
    ...  Get and Check Alarms SOAM  alias=Master  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    ...  ELSE  Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Run Keyword If  ${NR_CELL_not_BBMOD_list}  Run Keywords
    ...  Check Cells State  NRCEL  ${NR_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  3  Master
    ...  AND  Log  All NR cells not processed by ${NR_BBMOD_id}: ${CELL_state_enabled}  console=True
    Run Keyword If  ${NR_CELL_BBMOD_count}>0  Run Keywords
    ...  Check Cells State  NRCEL  ${NR_CELL_BBMOD_list}  ${CELL_state_dependency_check}  60  Master
    ...  AND  Log  All NR cells processed by ${NR_BBMOD_id}: ${CELL_state_dependency}  console=True

Unlock NR BBMOD
    [Arguments]  ${NR_BBMOD_id}
    ${BBMOD_state_unlocked_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${BBMOD_state_unlocked}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Log  "Unlock" operation on BBMOD ${NR_BBMOD_id} with SN ${NR_BBMOD_sn} will be performed via administrativeState parameter recomissioning
    ...  console=True

    coam.Perform Parameter Recommissioning  dist_name=${NR_BBMOD_SCF_DN}  parameter=administrativeState  operation=update
    ...  value=${BBMOD_administrativeState_unlock}  skip_parameter_relation_errors=True  should_activate=True  timeout=900  alias=Master

    Log  Check NR BBMOD state and alarms after "Unlock" operation  console=True
    Assert  BBMOD  ${NR_BBMOD_id}  ${BBMOD_state_unlocked_check}  timeout=360  alias=Master
    Log  NR BBMOD - ${BBMOD_state_unlocked}  console=True

    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Run Keyword If  ${NR_CELL_not_BBMOD_list}  Run Keywords
    ...  Check Cells State  NRCEL  ${NR_CELL_not_BBMOD_list}  ${CELL_state_enabled_check}  3  Master
    ...  AND  Log  All NR cells not processed by ${NR_BBMOD_id} : ${CELL_state_enabled}  console=True
    Check Cells State  NRCEL  ${NR_CELL_BBMOD_list}  ${CELL_state_enabled_check}  60  Master
    Log  All NR cells processed by ${NR_BBMOD_id} : ${CELL_state_enabled}  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check Cells State
    [Arguments]  ${CELL_class}  ${CELL_list}  ${states}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{CELL_list}
        Assert  ${CELL_class}  ${item}  ${states}  timeout=${timeout}  alias=${alias}
    END

Particular Teardown
    Admin Check If BTS Objects Are Unlocked  class_name=BBMOD  timeout=60  recover_timeout=60  connection=Master
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
