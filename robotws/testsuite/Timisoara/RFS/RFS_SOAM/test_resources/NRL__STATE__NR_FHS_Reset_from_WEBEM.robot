*** Settings ***
Documentation    TC__NRL__STATE__NR_FHS_Reset_from_WEBEM
Variables    tc_variables/nrl__state__nr_fhs_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of NR FHS reset operations, default value 3
${RESET_TYPE}  Hard  # Reset type: Soft, Hard or Warm, default value Hard

*** Keywords ***
TC__NRL__STATE__NR_FHS_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-20473
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR RM reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - prepare NR FHS list and related mapping info
    ...  - perform Reset operation on each NR FHS checking state and alarms for both NR and LTE
    ...    technologies
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.12.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20473 -
    ...  [5G] [Nr OBSAI] Create new automated test NRL__STATE__FHS_reset__one_by_one_from_WEBEM
    ...  - 18.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20864 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NRL
    ...  - 09.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21298 - [5G] Add mixed OBSAI/CPRI configs on NRL__STATE__NR_FHS_Reset_from_WEBEM
    ...  - 10.06.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21402 - [Legacy] taf.sbts.oam.coam.admin refactoring for
    ...  unit_reset_cp -> reset_unit
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 31.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22474 -
    ...  [5G] [DSS Refactoring] Implement common procedure for DSS alarms in NRL tests
    ...  - 22.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22474 - [5G] Please update NR expected alarm list
    ...  in NRL__STATE__FHS_reset__one_by_one_from_WEBEM
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 01.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24780 -
    ...  [5G] Replace Setup Admin KW with Start new ADMIN instance KW - NRL, dedicated FHS
    ...  - 03.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24700 - [5G][Reset Number ims2] Update NRL__STATE__NR_FHS_Reset_from_WEBEM
    ...  scenario to take reset number from ims2 - P2 - dedicated FHS
    ...  - 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24915 - [5G] NRL_STATE_LTE_BBMOD_reset_SharedFHS_mixed_OBSAI_CPRI is
    ...  failed due to wrong connection_type values
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 17.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27116 -
    ...  [5G] Use new DSS mechanism in existing TCs - NRL - NRL__STATE__NR_FHS_Reset_from_WEBEM
    ...  - 22.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27537 - Test adaptation following common test setup variable removal
    ...  - 02.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27823 - [CNI-127210] [Part 2] DSS LTE EXPECTED alarms check removal NR_* TCs
    ...  - after DSS discussion is concluded
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-20473_NRL__STATE__NR_FHS_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-5G20,SBTS20

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get NR FHS list
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Reset NR FHS
        Step 5: Check NR and LTE reset behavior based on IMS info
        Step 6: Check final number and state of Cells and RMs
    END
    Step 7: Check initial all BTS state
    Step 8: Check initial all BTS alarms

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

Step ${index}: Get NR FHS list
    [Documentation]
    ...  NR FHS list is get from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get NR FHS list  console=True
    ${NR_FHS_list}=  Admin Get FHS Ids  alias=Master
    ${NR_FHS_count}=  Get Length  ${NR_FHS_list}
    Run Keyword If  ${NR_FHS_count} > 0
    ...  Log  NR FHS found: ${NR_FHS_list}  console=True
    ...  ELSE
    ...  Fail  No NR FHS are present in runtime view configuration!
    Set Test Variable  ${NR_FHS_list}
    Set Test Variable  ${NR_FHS_count}

    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    Set Test Variable  ${Master_shared_RMOD_list}

    ${NR_RMOD_list}=  Get Ids For All  RMOD  alias=Master
    Sort List  ${NR_RMOD_list}
    Set Test Variable  ${NR_RMOD_list}
    ${LTE_RMOD_list}=  Get Ids For All  RMOD  alias=Slave
    Sort List  ${LTE_RMOD_list}
    Set Test Variable  ${LTE_RMOD_list}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=Master
    Set Test Variable  ${NR_CELL_list}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=Slave
    Set Test Variable  ${LTE_CELL_list}

    Get RM SN dict  NR  Master
    Get RM SN dict  LTE  Slave

    ${Master_shared_RMOD_CELL_list}=  Create List
    FOR  ${item}  IN  @{Master_shared_RMOD_list}
        ${Master_CELL_RMOD_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${Master_shared_RMOD_CELL_list}  @{Master_CELL_RMOD_list}
    END
    ${Master_shared_RMOD_CELL_list}=  Remove Duplicates  ${Master_shared_RMOD_CELL_list}
    Set Test Variable  ${Master_shared_RMOD_CELL_list}

Step ${index}: Reset NR FHS
    Log  Step ${index}: Reset NR FHS  console=True
    FOR  ${item}  IN  @{NR_FHS_list}
        Get Current Date UTC info  start
        Reset NR FHS  ${item}
        Get Current Date UTC info  end
    END

Step ${index}: Check NR and LTE reset behavior based on IMS info
    [Documentation]
    ...  RESET info is taken from IMS file both NR and LTE. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check NR and LTE reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get RM SN dict
    [Arguments]  ${tech}  ${alias}
    ${RM_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${tech}_RMOD_list}
        ${RM_PARAM_list}=  Get Parameters For  RMOD  ${item}  alias=${alias}
        Run Keyword If  '${tech}' == 'NR'
        ...  Set To Dictionary  ${RM_SN_dict}  ${RM_PARAM_list['id']}  ${RM_PARAM_list['serialNumber']}
        ...  ELSE IF  '${tech}' == 'LTE'
        ...  Set To Dictionary  ${RM_SN_dict}  ${RM_PARAM_list['serialNumber']}  ${RM_PARAM_list['id']}
    END
    Set Test Variable  ${${tech}_RM_SN_dict}  ${RM_SN_dict}

Get shared LTE RM with NR FHS RM list
    [Arguments]  ${NR_FHS_RMOD_list}
    ${LTE_FHS_RMOD_shared_list}=  Create List
    FOR  ${item}  IN  @{NR_FHS_RMOD_list}
        Continue For Loop If  '${item}' not in ${Master_shared_RMOD_list}
        ${RM_SN}=  Get From Dictionary  ${NR_RM_SN_dict}  ${item}
        ${LTE_RM_id}=  Get From Dictionary  ${LTE_RM_SN_dict}  ${RM_SN}
        Append To List  ${LTE_FHS_RMOD_shared_list}  ${LTE_RM_id}
    END
    [Return]  ${LTE_FHS_RMOD_shared_list}

Reset NR FHS
    [Arguments]  ${FHS_id}
    ${FHS_id_list}=  Create List
    Append To List  ${FHS_id_list}  ${FHS_id}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_degraded}=  Set Variable  operationalState=Enabled, availabilityStatus=Degraded, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Set Test Variable  ${LTE_alarm_count}  0
    ${NR_FHS_RMOD_list}=  Get RMOD Mapping By FHS Id  ${FHS_id}  Master
    ${NR_FHS_RMOD_count}=  Get Length  ${NR_FHS_RMOD_list}
    ${NR_FHS_CELL_list}=  Get CELL Mapping By FHS Id  ${NR_FHS_RMOD_list}
    ${NR_not_FHS_RMOD_list}=  Copy List  ${NR_RMOD_list}
    FOR  ${item}  IN  @{NR_FHS_RMOD_list}
        Remove Values From List  ${NR_not_FHS_RMOD_list}  ${item}
    END
    ${NR_not_FHS_RMOD_count}=  Get Length  ${NR_not_FHS_RMOD_list}
    ${LTE_FHS_RMOD_shared_list}=  Get shared LTE RM with NR FHS RM list  ${NR_FHS_RMOD_list}
    ${LTE_not_FHS_RMOD_list}=  Copy List  ${LTE_RMOD_list}
    FOR  ${item}  IN  @{LTE_FHS_RMOD_shared_list}
        Remove Values From List  ${LTE_not_FHS_RMOD_list}  ${item}
    END

    Log  Perform "Reset" operation on NR FHS ${FHS_id} from WebEM  console=True
    ${new_alias}=  Set Variable  resetFHS
    Start new ADMIN instance  alias=Master  new_alias=${new_alias}  connection_type=${connection_type_Master}
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${FHS_id}  reset_type=${RESET_TYPE}  timeout=600  connection=${new_alias}
    Sleep  10s

    Log  Check NR and LTE state during reset NR FHS ${FHS_id}:  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Disabled_}  Disabled  ${NotInstalled_}
    ...  NotInstalled  ${Unlocked_}  Unlocked  Master
    Log  NR FHS ${FHS_id} status as expected  console=True

    Run Keyword If  ${NR_not_FHS_RMOD_list}  Run Keywords
    ...  Check BTS Item State  NR  RMOD  ${NR_not_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Master
    ...  AND  Log  All NR RMOD(s) not connected to NR FHS ${FHS_id} status as expected  console=True
    Run Keyword If  ${NR_FHS_RMOD_list}  Run Keywords
    ...  Check BTS Item State  NR  RMOD  ${NR_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  Master
    ...  AND  Log  All NR RMOD(s) connected to NR FHS ${FHS_id} status as expected  console=True
    Check NR cells state and MIMO alarm  antenna=external  alias=Master
    Log  All NR cell(s) status as expected  console=True

    Run Keyword If  ${LTE_not_FHS_RMOD_list}  Run Keywords
    ...  Check BTS Item State  LTE  RMOD  ${LTE_not_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Slave
    ...  AND  Log  All LTE RMOD(s) not shared with NR FHS ${FHS_id} status as expected  console=True  console=True
    Run Keyword If  ${LTE_FHS_RMOD_shared_list}  Run Keywords
    ...  Check BTS Item State  LTE  RMOD  ${LTE_FHS_RMOD_shared_list}  ${RMOD_state_degraded_check}  ${RMOD_state_degraded}  60  Slave
    ...  AND  Log  All LTE RMOD(s) shared with NR FHS ${FHS_id} status as expected  console=True  console=True
    Check BTS Item State  LTE  LNCEL  ${LTE_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  Slave
    Log  All LTE cell(s) status as expected  console=True

    Log  Check NR and LTE alarms during reset NR FHS ${FHS_id}:  console=True
    ${MASTER_EXPECTED_ALARMS_10_FULL}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10}  ${NR_FHS_RMOD_count}
    ${MASTER_EXPECTED_ALARMS_FULL}=  Combine Lists  ${MASTER_EXPECTED_ALARMS_7300}  ${MASTER_EXPECTED_ALARMS_7319}  ${MASTER_EXPECTED_ALARMS_10_FULL}
    Run Keyword If  ${NR_FHS_count} == 1 and ${NR_not_FHS_RMOD_count} == 0  Run Keywords
    ...  Log  NR "No X2 link available (7300)" alarm, expected number: 1  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, expected number: 1  console=True
    ...  AND  Log  NR "No connection to unit (10)" alarm, expected number: ${NR_FHS_RMOD_count}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_FULL}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    ...  AND  Log  NR "No X2 link available (7300)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR "No X2 link available for a specific LTEENB (7319)" alarm, found number: 1, as expected!  console=True
    ...  AND  Log  NR "No connection to unit (10)" alarm, found number: ${NR_FHS_RMOD_count}  console=True
    ...  ELSE
    ...  Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_10_FULL}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    ${SLAVE_IGNORED_ALARMS_FULL}=  Combine Lists  ${SLAVE_IGNORED_ALARMS_DSS}  ${SLAVE_IGNORED_ALARMS}
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS_FULL}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True
    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check NR and LTE state after reset NR FHS ${FHS_id}:  console=True
    Wait Until Keyword Succeeds  180 sec  10 sec  Admin Check FHS list state  ${FHS_id_list}  ${Enabled_}  Enabled  ${Online_}  Online|None
    ...  ${Unlocked_}  Unlocked  Master
    Log  NR FHS ${FHS_id} status as expected  console=True

    Check BTS Item State  NR  RMOD  ${NR_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Master
    Log  All NR RMOD(s) status as expected  console=True
    Check BTS Item State  NR  NRCEL  ${NR_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  Master
    Log  All NR cell(s) status as expected  console=True

    Check BTS Item State  LTE  RMOD  ${LTE_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  5  Slave
    Log  All LTE RMOD(s) status as expected  console=True
    Check BTS Item State  LTE  LNCEL  ${LTE_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  Slave
    Log  All LTE cell(s) status as expected  console=True

    Log  Check NR and LTE alarms after reset NR FHS ${FHS_id}:  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR site - expected, ignored and critical alarms checked  console=True

    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SLAVE_IGNORED_ALARMS}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE site - expected, ignored and critical alarms checked  console=True
    [Teardown]  Teardown Admin  alias=${new_alias}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${FHS_RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  CABLINK  alias=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        Run Keyword If  '${firstEndpointDN_FHS_R}' and '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${FHS_RMOD_list}  ${item.secondEndpointDN}
    END
    [Return]  ${FHS_RMOD_list}

Get CELL Mapping By FHS Id
    [Arguments]   ${NR_FHS_RMOD_list}
    ${NR_FHS_CELL_list}=  Create List
    FOR  ${item}  IN  @{NR_FHS_RMOD_list}
        ${NR_FHS_RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=Master
        Append To List  ${NR_FHS_CELL_list}  @{NR_FHS_RMOD_CELL_list}
    END
    ${NR_FHS_CELL_list}=  Remove Duplicates  ${NR_FHS_CELL_list}
    [Return]  ${NR_FHS_CELL_list}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
