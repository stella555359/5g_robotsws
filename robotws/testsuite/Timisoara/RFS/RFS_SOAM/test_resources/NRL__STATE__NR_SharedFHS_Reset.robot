*** Settings ***
Documentation    TC__NRL__STATE__NR_SharedFHS_Reset
Variables    tc_variables/nrl__state__nr_sharedfhs_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3     # Number of NR shared FHS reset operations, default value 3

*** Keywords ***
TC__NRL__STATE__NR_SharedFHS_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21624
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR shared FHS reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - prepare shared FHS list and related RMOD and cells info for both BTS
    ...  - perform Reset operation on each NR shared FHS checking state and alarms for both BTS
    ...  - check final state and alarms for both both BTS
    ...  Pass criteria: Reset FHS operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 16.08.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21624
    ...  - [5G]New test case for SharedFHS: NRL__STATE_NR__SharedFHS_reset_one_by_one
    ...  - 03.09.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21804 - [5G] Refactoring due to stateInfo changes: NRL
    ...  - 08.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21992 - [5G]Enhancement on NRL with Shared FHS scenarios
    ...  - 03.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22077 - [5G] Please update TC name from
    ...  NRL__STATE__NR_Shared_FHS_Reset to NRL__STATE__NR_SharedFHS_Reset
    ...  - 03.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22103 - [5G] Please update NRL__STATE__NR_SharedFHS_Reset chained RF's
    ...  to be treated
    ...  - 06.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21775 - [5G][Legacy][RFSplit] Test NRL Common Part (hran_ta)
    ...  - 20.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23217 - [5G] NRL__STATE__NR_SharedFHS_Reset update FID10 check on NR
    ...  - 02.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23886 - [5G][TC review][NRL] Remove Cells "AdministrativeState" check in all
    ...  NRL robots
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24699 - [5G][Reset Number ims2] Update NRL__STATE__NR_SharedFHS_Reset scenario
    ...  to take reset number from ims2 - P2 - SharedFHS
    ...  - 28.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24779 - [5G] Replace Setup Admin KW with Start new ADMIN instance KW - NRL,
    ...  shared FHS
    ...  - 06.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24940 - [5G][Refactoring Tracker][CNI 82119] Refactor FHS state check based on
    ...  admin instead of admin-infomodel - NRL, sharedFHS
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29018 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files - NRL TCs
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21624_NRL__STATE__NR_Shared_FHS_Reset.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS21B

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get shared FHS info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform NR Reset shared FHS operation
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check both BTS reset behavior
        Step 8: Check final number and state of Cells and RMs
    END

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

Step ${index}: Get shared FHS info
    [Documentation]
    ...  BTS info are related to shared FHS, RMOD and cells

    [Timeout]  5 min
    Log  Step ${index}: Get shared FHS info  console=True

    ${Master_shared_FHS_list}  ${Slave_shared_FHS_list}  ${Master_dedicated_FHS_list}  ${Slave_dedicated_FHS_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  FHS  Master  Slave
    Sort List  ${Master_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_list}
    Set Test Variable  ${Slave_shared_FHS_list}
    ${Master_shared_FHS_count}=  Get Length  ${Master_shared_FHS_list}
    Set Test Variable  ${Master_shared_FHS_count}

    Get FHS ID SN dict  Master
    Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_FHS_SN_ID_dict}  ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_FHS_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_FHS_SN_ID_dict}  ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_FHS_ID_SN_dict}  ${Slave_module_ID_SN_dict}
    Run Keyword If  ${Master_shared_FHS_count} == 0  Run Keywords
    ...  Log  No shared FHS on NR BTS!  console=True
    ...  AND  Fail  No shared FHS on NR BTS!

    FOR  ${Master_FHS_id}  IN  @{Master_shared_FHS_list}
        ${FHS_SN}=  Get From Dictionary  ${Master_FHS_ID_SN_dict}  ${Master_FHS_id}
        ${Slave_FHS_id}=  Get From Dictionary  ${Slave_FHS_SN_ID_dict}  ${FHS_SN}
        Log  Shared FHS with SN ${FHS_SN}:  console=True
        Log  - NR FHS: ${Master_FHS_id}  console=True
        Log  - LTE FHS: ${Slave_FHS_id}  console=True
    END

    ${Master_shared_FHS_RMOD_dict}=  Get shared FHS RMOD dict  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_RMOD_dict}=  Get shared FHS RMOD dict  ${Slave_shared_FHS_list}  Slave
    Set Test Variable  ${Master_shared_FHS_RMOD_dict}
    Set Test Variable  ${Slave_shared_FHS_RMOD_dict}

    ${Master_shared_FHS_CELL_dict}=  Get shared FHS CELL dict  ${Master_shared_FHS_list}  Master
    ${Slave_shared_FHS_CELL_dict}=  Get shared FHS CELL dict  ${Slave_shared_FHS_list}  Slave
    Set Test Variable  ${Master_shared_FHS_CELL_dict}
    Set Test Variable  ${Slave_shared_FHS_CELL_dict}

Step ${index}: Perform NR Reset shared FHS operation
    [Documentation]
    ...  Perform NR Reset shared FHS operation

    Log  Step ${index}: Perform NR Reset shared FHS operation  console=True
    Get RESET timestamp info  start
    FOR  ${item}  IN  @{Master_shared_FHS_list}
        Reset NR shared FHS  ${item}
    END

Step ${index}: Check both BTS reset behavior
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - NR site: reset number is 0
    ...  - LTE site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check both BTS reset behavior  console=True
    Get RESET timestamp info  end
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

Get shared FHS RMOD dict
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_RMOD_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        Set To Dictionary  ${shared_FHS_RMOD_dict}  ${item}  ${RMOD_list}
    END
    [Return]  ${shared_FHS_RMOD_dict}

Get RMOD Mapping By FHS Id
    [Arguments]   ${FHS_id}  ${alias}
    ${RMOD_list}=  Create List
    ${CABLINK_list}=  Get Parameters For All  class_name=CABLINK  connection=${alias}
    FOR  ${item}  IN  @{CABLINK_list}
        ${CABLINK_id}=  Get From Dictionary  ${item}  id
        ${firstEndpointDN_FHS_R}=  Run Keyword And Return Status  Should Contain  ${item.firstEndpointDN}  FHS_R
        ${secondEndpointDN_RMOD_R}=  Run Keyword And Return Status  Should Contain  ${item.secondEndpointDN}  RMOD_R
        Run Keyword If  ${firstEndpointDN_FHS_R} and ${secondEndpointDN_RMOD_R}
        ...  Run Keyword If  '${item.firstEndpointDN}' == '${FHS_id}'
        ...  Append To List  ${RMOD_list}  ${item.secondEndpointDN}
    END
    ${RMOD_list}=  Remove Duplicates  ${RMOD_list}
    [Return]  ${RMOD_list}

Get shared FHS CELL dict
    [Arguments]  ${FHS_list}  ${alias}
    ${shared_FHS_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{FHS_list}
        ${RMOD_list}=  Get RMOD Mapping By FHS Id  ${item}  ${alias}
        ${CELL_list}=  Get CELL Mapping By RMOD Id  ${RMOD_list}  ${alias}
        Set To Dictionary  ${shared_FHS_CELL_dict}  ${item}  ${CELL_list}
    END
    [Return]  ${shared_FHS_CELL_dict}

Get CELL Mapping By RMOD Id
    [Arguments]   ${RMOD_list}  ${alias}
    ${CELL_list}=  Create List
    FOR  ${item}  IN  @{RMOD_list}
        ${RMOD_CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Append To List  ${CELL_list}  @{RMOD_CELL_list}
    END
    ${CELL_list}=  Remove Duplicates  ${CELL_list}
    [Return]  ${CELL_list}

Reset NR shared FHS
    [Arguments]  ${NR_FHS_id}
    ${NR_FHS_id_list}=  Create List
    Append To List  ${NR_FHS_id_list}  ${NR_FHS_id}
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${FHS_SN}=  Get From Dictionary  ${Master_FHS_ID_SN_dict}  ${NR_FHS_id}
    ${LTE_FHS_id}=  Get From Dictionary  ${Slave_FHS_SN_ID_dict}  ${FHS_SN}
    ${LTE_FHS_id_list}=  Create List
    Append To List  ${LTE_FHS_id_list}  ${LTE_FHS_id}
    ${NR_shared_FHS_RMOD_list}=  Get From Dictionary  ${Master_shared_FHS_RMOD_dict}  ${NR_FHS_id}
    ${LTE_shared_FHS_RMOD_list}=  Get From Dictionary  ${Slave_shared_FHS_RMOD_dict}  ${LTE_FHS_id}

    ${LTE_Chained_RMOD_list}=  Create List
    FOR  ${item}  IN  @{LTE_shared_FHS_RMOD_list}
        ${LTE_Chained_RMOD_list_temp}=  Get chained RMOD from Cablink  ${item}  Slave
        Run Keyword If  not ${LTE_Chained_RMOD_list_temp}  Continue For Loop
        ${LTE_Chained_RMOD_list}=  Combine Lists  ${LTE_Chained_RMOD_list}  ${LTE_Chained_RMOD_list_temp}
    END
    ${LTE_Chained_RMOD_list}=  Remove Duplicates  ${LTE_Chained_RMOD_list}
    Set Test Variable  ${LTE_Chained_RMOD_list}
    ${LTE_Chained_RMOD_count}=  Get Length  ${LTE_Chained_RMOD_list}
    ${LTE_impacted_RMOD_list}=  Combine Lists  ${LTE_shared_FHS_RMOD_list}  ${LTE_Chained_RMOD_list}

    ${NR_shared_FHS_RMOD_count}=  Get Length  ${NR_shared_FHS_RMOD_list}
    ${NR_shared_FHS_CELL_list}=  Get From Dictionary  ${Master_shared_FHS_CELL_dict}  ${NR_FHS_id}
    ${LTE_shared_FHS_CELL_list}=  Get From Dictionary  ${Slave_shared_FHS_CELL_dict}  ${LTE_FHS_id}

    ${NR_ALARMS_10_count}=  Set Variable  ${NR_shared_FHS_RMOD_count}
    ${MASTER_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${MASTER_EXPECTED_ALARMS_10}  ${NR_ALARMS_10_count}
    ${LTE_ALARMS_10_count}=  Evaluate  ${NR_shared_FHS_RMOD_count} + ${LTE_Chained_RMOD_count} + 1
    ${SLAVE_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10}  ${LTE_ALARMS_10_count}

    Log  Perform "Reset" operation from NR BTS on shared FHS with SN ${FHS_SN}  console=True

    ${new_alias}=  Set Variable  resetFHS
    Start new ADMIN instance  alias=Master  new_alias=${new_alias}  connection_type=${connection_type_Master}
    ${reset_info}=  Run Keyword In Background  Reset Unit  dist_name=${NR_FHS_id}  reset_type=Hard  timeout=600  connection=${new_alias}
    Sleep  5s

    Log  Check NR and LTE state during reset shared FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${NR_FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  Master
    Log  NR FHS ${NR_FHS_id} status as expected  console=True
    Check BTS Item State  NR  RMOD  ${NR_shared_FHS_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  Master
    Log  All NR shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  NR  NRCEL  ${NR_shared_FHS_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Master
    Log  All NR cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${LTE_FHS_id_list}  ${Disabled_}  Disabled
    ...  ${NotInstalled_}  NotInstalled  ${Unlocked_}  Unlocked  Slave
    Log  LTE FHS ${LTE_FHS_id} status as expected  console=True
    Check BTS Item State  LTE  RMOD  ${LTE_impacted_RMOD_list}  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}  60  Slave
    Log  All LTE shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  LTE  LNCEL  ${LTE_shared_FHS_CELL_list}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  60  Slave
    Log  All LTE cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    Log  Check NR and LTE alarms during reset shared FHS with SN ${FHS_SN}  console=True
    Log  NR BTS "No connection to Unit (10)" alarm, expected number: ${NR_ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${MASTER_EXPECTED_ALARMS_10_full}  ignored_alarms=${MASTER_IGNORED_ALARMS}
    ...  critical_alarms=${MASTER_CRITICAL_ALARMS}
    Log  NR BTS "No connection to Unit (10)" alarm, found number: ${NR_ALARMS_10_count}, as expected!  console=True
    Log  NR site - expected, ignored and critical alarms checked  console=True
    Log  LTE BTS "No connection to Unit (10)" alarm, expected number: ${LTE_ALARMS_10_count}  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${SLAVE_IGNORED_ALARMS}  critical_alarms=${SLAVE_CRITICAL_ALARMS}
    Log  LTE BTS "No connection to Unit (10)" alarm, found number: ${LTE_ALARMS_10_count}, as expected!  console=True
    Log  LTE site - expected, ignored and critical alarms checked  console=True

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check NR and LTE state after reset shared FHS with SN ${FHS_SN}  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${NR_FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  Master
    Log  NR shared FHS ${NR_FHS_id} status as expected  console=True
    Check BTS Item State  NR  RMOD  ${NR_shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Master
    Log  All NR shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  NR  NRCEL  ${NR_shared_FHS_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  300  Master
    Log  All NR cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Wait Until Keyword Succeeds  300 sec  10 sec  Admin Check FHS list state  ${LTE_FHS_id_list}  ${Enabled_}  Enabled
    ...  ${Online_}  Online|None  ${Unlocked_}  Unlocked  Slave
    Log  LTE shared FHS ${LTE_FHS_id} status as expected  console=True
    Check BTS Item State  LTE  RMOD  ${LTE_shared_FHS_RMOD_list}  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  180  Slave
    Log  All LTE shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True
    Check BTS Item State  LTE  LNCEL  ${LTE_shared_FHS_CELL_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  180  Slave
    Log  All LTE cell{s} mapped on shared RMOD(s) connected to shared FHS with SN ${FHS_SN} status as expected  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Check BTS Item State
    [Arguments]   ${tech}  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${BTS_item_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${tech} ${BTS_item_class} ${item} status:\n - ${BTS_item_state}  console=True
    END

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
