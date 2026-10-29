*** Settings ***
Documentation    TC__NRL__STATE__NR_SM_Power_Off_On_CBRS
Variables    tc_variables/nrl__state__nr_sm_power_off_on_CBRS_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}     3     # Number of NR SMs Power Off/On operations, default value 3

*** Keywords ***
TC__NRL__STATE__NR_SM_Power_Off_On_CBRS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25727
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for NR SMs Power Off/On with CBRS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and LTE technologies
    ...  - perform Power Off operation on NR SMs
    ...  - check alarms on LTE BTS during NR BTS powered off
    ...  - perform Power On operation on NR SMs
    ...  - check FID6826 alarm on NR BTS
    ...  - check final state and alarms for both NR and LTE technologies
    ...  Pass criteria: NR SMs Power Off/On operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25727 - [5G][CB008278] NRL__STATE__NR_SM_Power_Off_On test cases update for CBRS
    ...  configuration
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29018 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files - NRL TCs
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-25727_NRL__STATE__NR_SM_Power_Off_On_CBRS.png

    Set Tags    CA-STATE    OWNER-adrian.chisim@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS24R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all RMOD info
    Step 4: Check if CBRS is configured
    Step 5: Check PDU definition and reachability
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Power OFF NR BTS
        Step 7: Check LTE BTS alarms
        Step 8: Power ON NR BTS
        Step 9: Check NR BTS alarms
        Step 10: Check final all BTS state
        Step 11: Check final all BTS alarms
        Step 12: Check final number and state of Cells and RMs
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

Step ${index}: Get all RMOD info
    Log  Step ${index}: Get all RMOD info  console=True
    ${Master_shared_RM_list}  ${Slave_shared_RM_list}  ${Master_dedicated_RM_list}  ${Slave_dedicated_RM_list}=
    ...  Admin Get Shared And Dedicated RM List for Master and Slave  Master  Slave
    Sort List  ${Master_shared_RM_list}
    Sort List  ${Slave_shared_RM_list}
    ${shared_RMOD_count}=  Get Length  ${Master_shared_RM_list}
    Set Test Variable  ${shared_RMOD_count}

Step ${index}: Check if CBRS is configured
    Log  Step ${index}: Check if CBRS is configured  console=True

    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=Master  export_type=configurationAndRuntimeObjects
    ${NR_cell_ids}=  Get Ids For All  NRCEL  connection=Master

    FOR  ${item}  IN  @{NR_cell_ids}
        ${NR_CELL_dn}=  Get CELL SCF runtime distinguished name  ${item}  Master
        ${freqBandIndicatorNR_value}=  Check Parameter value from SCF  item_dist_name=${NR_CELL_dn}  parameter_to_check=freqBandIndicatorNR
        ...  scf_path=${BTS_scf}
        Run Keyword If  '${freqBandIndicatorNR_value}' != '48'  Run Keywords
        ...  Log  Value of freqBandIndicatorNR for ${item} is not as expected (${freqBandIndicatorNR_value} vs. 48). CBRS is not properly configured
        ...  console=True
        ...  AND  Fail  CBRS is not properly configured
    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Keyword used to check if BTS SMs PDU are defined, can be reached and their status is on

    Log  Step ${index}: Check PDU definition and reachability  console=True
    ${Master_SM_PDU_if_name_list}=  Check BTS SMs PDU info definition  Master
    Set Test Variable  ${Master_SM_PDU_if_name_list}
    ${status}=  Check BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  on
    Run Keyword If  ${status}
    ...  Log  BTS Master SMs PDU port status as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for BTS Master SMs is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for BTS Master SMs is either not reachable or not switched on!

Get shared RMOD Primary Link before NR BTS Power OFF
    ${all_BTS_PL_shared_RM_info}=  Get PL shared RM info on all BTS
    FOR  ${alias}  IN  @{alias_list}
        ${BTS_PL_shared_RM_info}=  Get From Dictionary  ${all_BTS_PL_shared_RM_info}  ${alias}

        ${BTS_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_CPRI_shared_RM_id_list
        ${BTS_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_ECPRI_shared_RM_id_list
        ${BTS_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_PL_OBSAI_shared_RM_id_list

        ${BTS_non_PL_CPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_CPRI_shared_RM_id_list
        ${BTS_non_PL_ECPRI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_ECPRI_shared_RM_id_list
        ${BTS_non_PL_OBSAI_shared_RMOD_list}=  Get From Dictionary  ${BTS_PL_shared_RM_info}  BTS_non_PL_OBSAI_shared_RM_id_list

        ${BTS_PL_CPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_CPRI_shared_RMOD_list}
        ${BTS_PL_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_PL_ECPRI_shared_RMOD_list}
        ${BTS_PL_OBSAI_shared_RMOD_count}=  Get Length  ${BTS_PL_OBSAI_shared_RMOD_list}

        Log  CPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_CPRI_shared_RMOD_count}  console=True
        Log  ECPRI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_ECPRI_shared_RMOD_count}  console=True
        Log  OBSAI Shared RMOD count with Primary Link configured on ${alias} BTS: ${BTS_PL_OBSAI_shared_RMOD_count}  console=True

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_list}  ${BTS_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_list}  ${BTS_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_list}  ${BTS_PL_OBSAI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_CPRI_shared_RMOD_list}  ${BTS_non_PL_CPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_ECPRI_shared_RMOD_list}  ${BTS_non_PL_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_non_PL_OBSAI_shared_RMOD_list}  ${BTS_non_PL_OBSAI_shared_RMOD_list}

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}  ${BTS_PL_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_OBSAI_shared_RMOD_count}  ${BTS_PL_OBSAI_shared_RMOD_count}

        ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}=
        ...  Get excepted and not excepted RMOD lists  ${BTS_non_PL_ECPRI_shared_RMOD_list}  ${RMOD_ECPRI_fid16_exceptions}  ${alias}
        ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}
        ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}=  Get Length  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_BTS_non_PL_excepted_ECPRI_shared_RMOD_list}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_list}
        Set Test Variable  ${${alias}_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}  ${BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_BTS_non_PL_excepted_ECPRI_shared_RMOD_count}  ${BTS_non_PL_excepted_ECPRI_shared_RMOD_count}
    END

Step ${index}: Power ${power} NR BTS
    Log  Step ${index}: Power ${power} NR BTS  console=True
    Run Keyword If  '${power}' == 'OFF'  Run Keywords
    ...  Get shared RMOD Primary Link before NR BTS Power OFF
    ...  AND  Get LTE Cell Count
    ${status}=  Set BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  ${power}
    Run Keyword If  ${status}
    ...  Log  BTS Master SMs PDU port status ${power}, as expected  console=True
    ...  ELSE  Run Keywords
    ...  Log  Set BTS Master SMs PDU port status ${power} failed!  level=ERROR
    ...  AND  Fail  Set Master SMs PDU port status ${power} failed!

    Run Keyword If  '${power}' == 'ON'  Admin Check BTS Procedural and Blocking states  ${IntegratedToRan_Configured_}  ${Unblocked_}  600  Master

Step ${index}: Check LTE BTS alarms
    Log  Step ${index}: Check LTE BTS alarms  console=True
    ${Master_PL_CPRI_OBSAI_shared_RMOD_count}=  Evaluate  ${Master_PL_CPRI_shared_RMOD_count} + ${Master_PL_OBSAI_shared_RMOD_count}
    ${LTE_non_PL_CPRI_OBSAI_shared_RM_CELL_count}=  Evaluate  ${LTE_non_PL_CPRI_shared_RM_CELL_count} + ${LTE_non_PL_OBSAI_shared_RM_CELL_count}
    ${FID10_1815_count}=  Set Variable  ${Master_PL_CPRI_OBSAI_shared_RMOD_count}
    ${FID16_count}=  Set Variable If  ${Slave_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count}
    ${SLAVE_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_10_1815}  ${FID10_1815_count}
    ${SLAVE_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${SLAVE_EXPECTED_ALARMS_16}  ${FID16_count}
    ${SLAVE_EXPECTED_ALARMS_10_16_1815_full}=  Combine Lists  ${SLAVE_EXPECTED_ALARMS_10_1815_full}  ${SLAVE_EXPECTED_ALARMS_16_full}
    ${SLAVE_EXPECTED_ALARMS}=  Set Variable If  (${Master_PL_CPRI_OBSAI_shared_RMOD_count} == 0 and ${Master_PL_ECPRI_shared_RMOD_count} == 0)
    ...  @{EMPTY}  ${SLAVE_EXPECTED_ALARMS_10_16_1815_full}
    ${SLAVE_IGNORED_ALARMS_full}=  Combine Lists  ${SLAVE_IGNORED_ALARMS_DURING_POWER_OFF}  ${SLAVE_IGNORED_ALARMS}

    Run Keyword If  ${Master_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log Long String  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  expected number: ${FID10_1815_count}  console=True

    Run Keyword If  ${Slave_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count} > 0
    ...  Log  LTE "Unit synchronization failed (16)" alarm, expected number: ${FID16_count}  console=True

    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SLAVE_EXPECTED_ALARMS}  ignored_alarms=${SLAVE_IGNORED_ALARMS_full}
    ...  critical_alarms=${SLAVE_CRITICAL_ALARMS}

    Run Keyword If  ${Master_PL_CPRI_OBSAI_shared_RMOD_count} > 0
    ...  Log Long String  LTE "Not able to synchronize baseband bus (1815)" or "No connection to unit (10)" alarm,
    ...  found number: ${FID10_1815_count}, as expected!  console=True
    Run Keyword If  ${Slave_BTS_non_PL_not_excepted_ECPRI_shared_RMOD_count} > 0
    ...  Log  LTE "Unit synchronization failed (16)" alarm, found number: ${FID16_count}, as expected!
    ...  console=True

    Log  LTE site - expected, ignored and critical alarms checked  console=True

Step ${index}: Check NR BTS alarms
    Log  Step ${index}: Check NR BTS alarms  console=True
    Log  NR BTS "SAS Registration Failure (6826)" alarm, expected number: ${shared_RMOD_count}  console=True
    ${NR_EXPECTED_ALARMS_6826_FULL}=  Prepare Expected Alarms List  ${NR_EXPECTED_ALARMS_6826}  ${shared_RMOD_count}
    Get and Check Alarms SOAM  alias=Master  expected_alarms=${NR_EXPECTED_ALARMS_6826_FULL}
    ...  ignored_alarms=${NR_IGNORED_ALARMS}  critical_alarms=${NR_CRITICAL_ALARMS}
    Log  NR BTS "SAS Registration Failure (6826)" alarm, found number: ${shared_RMOD_count}, as expected!  console=True

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get cells mapped on shared RM
    [Arguments]  ${shared_RM_list}  ${alias}
    ${shared_RM_CELL_list}=  Create List
    FOR  ${item}  IN  @{shared_RM_list}
        ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${item}  alias=${alias}
        Append To List  ${shared_RM_CELL_list}  @{CELL_RM_list}
    END
    ${shared_RM_CELL_list}=  Remove Duplicates  ${shared_RM_CELL_list}
    ${shared_RM_CELL_count}=  Get Length  ${shared_RM_CELL_list}
    [Return]  ${shared_RM_CELL_list}  ${shared_RM_CELL_count}

Get LTE Cell Count
    ${LTE_non_PL_CPRI_shared_RM_CELL_list}  ${LTE_non_PL_CPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Slave_non_PL_CPRI_shared_RMOD_list}  Slave
    ${LTE_non_PL_ECPRI_shared_RM_CELL_list}  ${LTE_non_PL_ECPRI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Slave_non_PL_ECPRI_shared_RMOD_list}  Slave
    ${LTE_non_PL_OBSAI_shared_RM_CELL_list}  ${LTE_non_PL_OBSAI_shared_RM_CELL_count}=  Get cells mapped on shared RM
    ...  ${Slave_non_PL_OBSAI_shared_RMOD_list}  Slave
    ${LTE_non_PL_shared_RM_CELL_list}=  Combine Lists  ${LTE_non_PL_CPRI_shared_RM_CELL_list}  ${LTE_non_PL_ECPRI_shared_RM_CELL_list}
    ...  ${LTE_non_PL_OBSAI_shared_RM_CELL_list}
    Set Test Variable  ${LTE_non_PL_CPRI_shared_RM_CELL_count}
    Set Test Variable  ${LTE_non_PL_ECPRI_shared_RM_CELL_count}
    Set Test Variable  ${LTE_non_PL_OBSAI_shared_RM_CELL_count}
    Set Test Variable  ${LTE_non_PL_shared_RM_CELL_list}

Particular Teardown
    Recover BTS SMs PDU port status  ${Master_SM_PDU_if_name_list}  on  Master
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
