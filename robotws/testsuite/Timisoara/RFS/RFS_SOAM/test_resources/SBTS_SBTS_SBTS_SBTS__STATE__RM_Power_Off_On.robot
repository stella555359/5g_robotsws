*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
Variables    tc_variables/sbts_sbts_sbts_sbts__state__rm_power_off_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                              3      # Number of power OFF/ON RMOD operations, default value 3
${RMOD_SERIAL_NUMBER_LIST}                     ALL    # RMOD serial number list on which power OFF/ON operations will be performed.
                                                      # Possible values (by default ALL):
                                                      # - ALL: action will be performed on all RMOD
                                                      # - list of selected RMOD serial number separated by comma.
${RMOD_SHARING_INFO}                           ALL    # RMOD sharing info: shared and/or dedicated RMOD for power OFF/ON operations.
                                                      # Possible values (by default ALL):
                                                      # - ALL: action will be performed on shared and dedicated RMOD
                                                      # - shared: action will be performed only on shared RMOD
                                                      # - dedicated: action will be performed only on dedicated RMOD
${RMOD_POWER_ON_WRN_THR}                       240    # Compared with the time spent between RMOD power ON and last cell up.
                                                      # Default value: in accordance with KPI 54a specifications
${RMOD_POWER_MAX_WAIT_TIME}                    900    # Maximum waiting time for action to be completed
${RMOD_RESET_TIME_INTERVAL}                    480    # Time interval between reset RMOD (due to power OFF/ON), default value 480 seconds.
${LTE_IOT_check}                               True   # Specify in case of configured LTE IOT cells if their status will be checked (True) or skipped
                                                      # (False) after RMOD power off operation. By default True
${CB005763_CHECK}                              False  # Specify if feature CB005763 behavior (fault info) should be checked (True) or skipped (False).
                                                      # By default False
${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}          # RMOD serial number list exempted from CB005763 feature (e.g. rel3, CPRI-IR( FZ*..))

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26598
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for power OFF/ON RMOD operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - perform power OFF RMOD checking states and alarms on all BTS
    ...  - perform power ON RMOD checking states and alarms on all BTS
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: Power OFF/ON RMOD operations works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26598 -
    ...  [5G][CB010914/CB008502] UpdateSBTS_SBTS_SBTS_SBTS__STATE__RM_Power_Off_On scenario for NR_NR _configuration
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27819 - [CNI-127210][Part 1] MIMO remove EXPECTED minor alarm from SBTS_* TCs
    ...  - 06.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29155 -
    ...  [CB005763] Verify FID4774 and "RU power loss" after SBTS_SBTS__STATE__RM_Power_Off_On
    ...  - 23.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28980 - Generic test for RM power OFF/ON
    ...  - 01.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29501 - RM_power_off_on extend time for cell state check after action
    ...

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com    AUTHOR-horea.olar@nokia.com    PHASE-QT    SW-SBTS24R2

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Get initial baseband pool allocation mode info
    Step 5: Check PDU definition and reachability
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform power OFF/ON RMOD for iteration ${CYCLE}
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check BTS reset behavior based on IMS info
        Step 10: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}
    ${RMOD_all_sn_list}=  Get Dictionary Keys  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${RMOD_all_sn_list}

    Run Keyword If  '${RMOD_SERIAL_NUMBER_LIST}' != 'ALL'  Check RMOD serial number list

    Log  =========================================================  console=True
    Log  RMOD serial number list selected for power OFF/ON action: ${RMOD_all_sn_list}  console=True
    Log  =========================================================  console=True

    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}=  Check CB005763 exempted RMOD list
    Set Test Variable  ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True

    FOR  ${alias}  IN  @{alias_list}

        Log  ***** Check ${when} BTS ${alias} state *****  console=True

        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
        Get and Check ALD state info  alias=${alias}

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

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller and BTS secondary controller (per BTS alias)
    ...  - list of dedicated RM serial number (per BTS alias)
    ...  - list of RAT cells (per RMOD)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF
    Set Test Variable  ${all_BTS_controller_role_RMOD_sn_list}

    FOR  ${alias}  IN  @{alias_list}

        Get BTS Cell info  ${alias}

    END

    Get all BTS chained RMOD info

    Set Test Variable  ${RMOD_state_powered_off_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_powered_off}  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_powered_on_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RMOD_state_powered_on}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_enabled_degraded_check}
    ...  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled_degraded}  operationalState=Enabled, availabilityStatus=Degraded, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_offline_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled_offline}  operationalState=Disabled, availabilityStatus=Offline, blockingState=Unblocked
    Set Test Variable  ${CELL_state_disabled_failed_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_disabled_failed}  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked

Step ${index}: Get initial baseband pool allocation mode info
    [Documentation]
    ...  Get initial baseband pool allocation mode info

    Log  Step ${index}: Get initial baseband pool allocation mode info   console=True

    FOR  ${alias}  IN  @{alias_list}

        Get baseband pool allocation mode info from SCF  alias=${alias}

    END

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Check PDU definition and reachability

    Log  Step ${index}: Check PDU definition and reachability  console=True

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        Check PDU port status  RMOD_${RMOD_sn}  on

    END

Step ${index}: Perform power OFF/ON RMOD for iteration ${CYCLE}
    [Documentation]
    ...  Perform power OFF/ON RMOD

    Log  Step ${index}: Perform power OFF/ON RMOD for iteration ${CYCLE}  console=True

    Set Test Variable  ${CYCLE}
    Get Current Time  start

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        Check safe time for RMOD operations  ${RMOD_sn}

        Get RMOD info from all BTS  ${RMOD_sn}

        Power OFF RMOD  ${RMOD_sn}

        Power ON RMOD  ${RMOD_sn}

        Get and check KPI54a info  ${RMOD_sn}

    END

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS RESET info is checked based on IMS info. Reset behavior as expected if no BTS reset occurs.
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True

    Get Current Time  final

    FOR  ${alias}  IN  @{alias_list}

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  start_point_timestamp_UTC=${time_start}
        ...  end_point_timestamp_UTC=${time_final}  remove_ims_file=False

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RMOD serial number list
    ${RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SERIAL_NUMBER_LIST}=  Split String  ${RMOD_SERIAL_NUMBER_LIST_strip}  ,
    ${RMOD_sn_check}=  Set Variable  True
    ${RMOD_sn_invalid_list}=  Create List

    FOR  ${item}  IN  @{RMOD_SERIAL_NUMBER_LIST}

        ${RMOD_sn_check}=  Set Variable If  '${item}' not in ${RMOD_all_sn_list}  False  ${RMOD_sn_check}
        Run Keyword If  '${item}' not in ${RMOD_all_sn_list}  Append To List  ${RMOD_sn_invalid_list}  ${item}

    END

    Run Keyword If  '${RMOD_sn_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RMOD serial number values are not valid: ${RMOD_sn_invalid_list}. Please select values for test
    ...  argument \${RMOD_SERIAL_NUMBER_LIST} from configured RMOD: ${RMOD_all_sn_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${RMOD_all_sn_list}  ${RMOD_SERIAL_NUMBER_LIST}
    Sort List  ${RMOD_all_sn_list}

Get all BTS chained RMOD info

    ${all_BTS_chained_RMOD_id_dict}=  Create Dictionary
    ${all_BTS_chained_RMOD_sn_dict}=  Create Dictionary

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_chained_RMOD_id_dict}  ${BTS_chained_RMOD_sn_dict}=  Get chained RMOD info dict  ${alias}

        Set To Dictionary  ${all_BTS_chained_RMOD_id_dict}  ${alias}  ${BTS_chained_RMOD_id_dict}
        Set To Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}  ${BTS_chained_RMOD_sn_dict}

    END

    Set Test Variable  ${all_BTS_chained_RMOD_id_dict}
    Set Test Variable  ${all_BTS_chained_RMOD_sn_dict}

Get BTS Cell info
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Sort List  ${NR_CELL_list}
    Sort List  ${LTE_CELL_list}
    Sort List  ${WCDMA_CELL_list}
    Sort List  ${GSM_CELL_list}
    ${LTE_HOST_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}=  Admin Get LTE HOST and IOT Cell(s) Id list
    ...  CELL_list=${LTE_CELL_list}  alias=${alias}
    ${LTE_cell_IOT_mapping_dict}=  Run Keyword If  ${LTE_CELL_list}  Admin Get LTE CELL IOT mapping list  alias=${alias}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_HOST_CELL_ID_LIST}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_ID_LIST}  ${LTE_IOT_CELL_ID_LIST}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL_ID_LIST}  ${LTE_IOT_SA_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Check CB005763 exempted RMOD list
    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_isEmpty}=  Set Variable If  '${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}' == ''  ${TRUE}  ${FALSE}

    Return From Keyword If  ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_isEmpty}  @{EMPTY}

    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_strip}=  Replace String  ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}=  Split String  ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST_strip}  ,

    [Return]  ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

Check PDU port status
    [Arguments]  ${item}  ${status}

    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
    Run Keyword if  '${PDU_port_status}' == '${status}'
    ...  Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!  level=ERROR
    ...  AND  Fail  ${item} PDU info: IP=${INTERFACES['${item}']['IP']}, PORT=${INTERFACES['${item}']['OUTLET']} switched ${PDU_port_status}!

Get RMOD info from all BTS
    [Arguments]  ${RMOD_sn}

    ${sharing_info}=  Set Variable If  '${RMOD_sn}' in ${shared_RMOD_sn_list}  shared  '${RMOD_sn}' in ${dedicated_RMOD_sn_list}  dedicated
    Set Test Variable  ${${RMOD_sn}_sharing_info}  ${sharing_info}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Get RMOD info from BTS  ${RMOD_sn}  ${alias}

        ${BTS_chained_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}
        ${BTS_chained_RMOD_sn_list}=  Get From Dictionary  ${BTS_chained_RMOD_sn_dict}  ${RMOD_sn}
        Get chained RMOD info from BTS  ${BTS_chained_RMOD_sn_list}  ${alias}

    END

Get chained RMOD info from BTS
    [Arguments]  ${BTS_chained_RMOD_sn_list}  ${alias}

    FOR  ${RMOD_sn}  IN  @{BTS_chained_RMOD_sn_list}

        Get RMOD info from BTS  ${RMOD_sn}  ${alias}

    END

Check safe time for RMOD operations
    [Arguments]  ${RMOD_sn}

    ${RMOD_time_power_on}=  Get Variable Value  ${${RMOD_sn}_time_power_on}  ${EMPTY}
    Return From Keyword If  '${RMOD_time_power_on}' == '${EMPTY}'

    Get Current Time  current
    ${time_elapsed}=  DateTime.Subtract Date From Date  ${time_current}  ${RMOD_time_power_on}  number
    ${waiting_time}=  BuiltIn.Evaluate  ${RMOD_RESET_TIME_INTERVAL} - ${time_elapsed}
    Run Keyword If  ${waiting_time} > 0  Run Keywords
    ...  Log Long String  Check safe time interval between RMOD_${RMOD_sn} operations (due to RMOD reset): ${RMOD_RESET_TIME_INTERVAL} sec -> Wait
    ...  ${waiting_time} sec  console=True
    ...  AND  Sleep  ${waiting_time} sec

Get RMOD info from BTS
    [Arguments]  ${RMOD_sn}  ${alias}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_sn_id_dict}  ${RMOD_sn}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_id}  ${RMOD_id}
    ${RMOD_pn}=  Get From Dictionary  ${${alias}_RMOD_sn_pn_dict}  ${RMOD_sn}
    Set Test Variable  ${${RMOD_sn}_RMOD_pn}  ${RMOD_pn}

    ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
    ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
    ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
    ${RMOD_id_LTE_IOT_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_CELL_ids_dict
    ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_IOT_SA_CELL_ids_dict
    ${RMOD_id_WCDMA_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_WCDMA_CELL_ids_dict
    ${RMOD_id_GSM_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_GSM_CELL_ids_dict
    ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_IOT_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_LTE_IOT_SA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_IOT_SA_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_WCDMA_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_WCDMA_CELL_ids_dict}  ${RMOD_id}
    ${RMOD_GSM_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_GSM_CELL_ids_dict}  ${RMOD_id}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_LTE_IOT_CELL_ids_list}  ${RMOD_LTE_IOT_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_LTE_IOT_SA_CELL_ids_list}  ${RMOD_LTE_IOT_SA_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  ${RMOD_WCDMA_CELL_ids_list}
    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  ${RMOD_GSM_CELL_ids_list}

Power OFF RMOD
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Log  ***** Perform power OFF operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} *****  console=True
    Get Current Time  power_off
    Pdu BTS Interface Off  RMOD_${RMOD_sn}
    Sleep  10 s
    Check PDU port status  RMOD_${RMOD_sn}  off

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Log  Check BTS ${alias} state and alarms after power OFF operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn}
        ...  console=True

        Log  Check BTS ${alias} ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_off}  ${RMOD_POWER_MAX_WAIT_TIME}
        Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_powered_off_check}  ${RMOD_state_powered_off}  ${remained_MAX_WAIT_TIME}  ${alias}

        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_off}  ${RMOD_POWER_MAX_WAIT_TIME}
        Check BTS chained RMOD state  ${RMOD_sn}  ${RMOD_state_powered_off_check}  ${RMOD_state_powered_off}  ${remained_MAX_WAIT_TIME}  ${alias}

        Log  Check BTS ${alias} cells status mapped on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn}:  console=True
        Wait Until Keyword Succeeds  60s  10s  Check cells state mapped on RMOD  ${RMOD_sn}  ${alias}

        Check cells state mapped on chained RMOD  ${RMOD_sn}  ${alias}

        Log  Check BTS ${alias} alarms:  console=True
        Check alarms after power OFF RMOD  ${RMOD_sn}  ${alias}

    END

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log Long String  Check all BTS other cells are not impacted by power OFF operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with
    ...  SN ${RMOD_sn} and chained RMODs  console=True

    ${NR_cell_info_exempted}=  Create Dictionary
    ${LTE_cell_info_exempted}=  Create Dictionary
    ${WCDMA_cell_info_exempted}=  Create Dictionary
    ${GSM_cell_info_exempted}=  Create Dictionary

    Get impacted RMOD exempted cells info  ${RMOD_sn}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
    ...  ${GSM_cell_info_exempted}

    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{NR_cell_info_exempted}
    ...  LTE_cell_info_exempted=&{LTE_cell_info_exempted}  WCDMA_cell_info_exempted=&{WCDMA_cell_info_exempted}
    ...  GSM_cell_info_exempted=&{GSM_cell_info_exempted}  timeout=3
    Log  All BTS other cells status is OK.  console=True

Power ON RMOD
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Log  ***** Perform power ON operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} *****  console=True
    Get Current Time  power_on
    Set Test Variable  ${${RMOD_sn}_time_power_on}  ${time_power_on}
    Pdu BTS Interface On  RMOD_${RMOD_sn}
    Sleep  10 s
    Check PDU port status  RMOD_${RMOD_sn}  on

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Log  Check BTS ${alias} state and alarms after power ON operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn}
        ...  console=True

        Log  Check BTS ${alias} ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} status:  console=True
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
        Check BTS RMOD state  ${RMOD_sn}  ${RMOD_state_powered_on_check}  ${RMOD_state_powered_on}  ${remained_MAX_WAIT_TIME}  ${alias}

        Log  Check BTS ${alias} cells mapped on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} status:  console=True
        Check BTS RMOD cell state  ${RMOD_sn}  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
        ...  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  ${CELL_state_enabled_check}
        ...  ${CELL_state_enabled}  ${alias}

        Log  Check BTS ${alias} alarms:  console=True
        Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=@{EMPTY}
        ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    END

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all BTS other cells are not impacted by power ON operation on ${${RMOD_sn}_sharing_info} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn}
    ...  console=True
    Check BTS cells are enabled online with exceptions   timeout=3
    Log  All BTS other cells status is OK.  console=True

Get and check KPI54a info
    [Arguments]  ${RMOD_sn}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Get Current Time  end

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Get and check KPI54a info from IMS file  ${RMOD_sn}  ${alias}

    END

Get RMOD exempted LTE cells info
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_LTE_IOT_CELL_ids_list}=  Create List

    FOR  ${LTE_CELL_id}  IN  @{${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_CELL_id}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${BTS_LTE_IOT_CELL_ids_list}  ${LTE_IOT_CELL_id}

    END

    ${BTS_LTE_CELL_ids_exempted_list}=  Combine Lists  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}  ${BTS_LTE_IOT_CELL_ids_list}
    ...  ${${alias}_${RMOD_sn}_RMOD_LTE_IOT_SA_CELL_ids_list}

    Set Test Variable  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_exempted_list}  ${BTS_LTE_CELL_ids_exempted_list}

Check BTS RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    Assert  class_name=RMOD  id=${${alias}_${RMOD_sn}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} status:\n - ${RMOD_state}  console=True

Check BTS chained RMOD state
    [Arguments]  ${RMOD_sn}  ${RMOD_state_check}  ${RMOD_state}  ${timeout}  ${alias}

    ${BTS_chained_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}
    ${BTS_chained_RMOD_sn_list}=  Get From Dictionary  ${BTS_chained_RMOD_sn_dict}  ${RMOD_sn}

    FOR  ${item}  IN  @{BTS_chained_RMOD_sn_list}

        Log  Check BTS ${alias} chained RMOD ${${item}_RMOD_pn} with SN ${item} status:  console=True

        Assert  class_name=RMOD  id=${${alias}_${item}_RMOD_id}  parameters=${RMOD_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} RMOD ${${item}_RMOD_pn} with SN ${item} status:\n - ${RMOD_state}  console=True

    END

Check cells state mapped on chained RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_chained_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}
    ${BTS_chained_RMOD_sn_list}=  Get From Dictionary  ${BTS_chained_RMOD_sn_dict}  ${RMOD_sn}

    FOR  ${item}  IN  @{BTS_chained_RMOD_sn_list}

        Log  Check BTS ${alias} cells status mapped on chained RMOD ${${item}_RMOD_pn} with SN ${RMOD_sn}:  console=True
        Wait Until Keyword Succeeds  60s  10s  Check cells state mapped on RMOD  ${item}  ${alias}

    END

Check cells state mapped on RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}  alias=${alias}

    Return From Keyword If  '${LTE_IOT_check}' != 'True'

    FOR  ${item}  IN  @{${alias}_${RMOD_sn}_RMOD_LTE_IOT_SA_CELL_ids_list}

        Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_disabled_failed_check}  connection=${alias}
        Log  ${alias} LNCEL ${item} status:\n - ${CELL_state_disabled_failed}  console=True

    END

    FOR  ${item}  IN  @{${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_list}

        ${LTE_IOT_CELL_check}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  not ${LTE_IOT_CELL_check}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  '${LTE_IOT_CELL_id}' == 'None'

        ${LTE_CELL_info}=  Assert  class_name=LNCEL  id=${item}  connection=${alias}
        ${LTE_CELL_operationalState}=  Get From Dictionary  ${LTE_CELL_info}  operationalState
        ${LTE_IOT_CELL_state_check}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${CELL_state_disabled_offline_check}
        ...  ${CELL_state_enabled_degraded_check}
        ${LTE_IOT_CELL_state}=  Set Variable If  '${LTE_CELL_operationalState}' == 'disabled'  ${CELL_state_disabled_offline}
        ...  ${CELL_state_enabled_degraded}

        Assert  class_name=LNCEL  id=${LTE_IOT_CELL_id}  parameters=${LTE_IOT_CELL_state_check}  connection=${alias}
        Log  ${alias} LNCEL ${LTE_IOT_CELL_id} status:\n - ${LTE_IOT_CELL_state}  console=True

    END

Check BTS RMOD cell state
    [Arguments]  ${RMOD_sn}  ${RMOD_NR_CELL_ids}  ${RMOD_LTE_CELL_ids}  ${RMOD_WCDMA_CELL_ids}  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}
    ...  ${CELL_state}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  NRCEL  ${RMOD_NR_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  LNCEL  ${RMOD_LTE_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  WNCEL  ${RMOD_WCDMA_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_power_on}  ${RMOD_POWER_MAX_WAIT_TIME}
    Check RMOD cells are enabled online  GNCEL  ${RMOD_GSM_NR_CELL_ids}  ${CELL_state_check}  ${alias}  ${remained_MAX_WAIT_TIME}

    Log  BTS ${alias} cells mapped on RMOD ${${RMOD_sn}_RMOD_pn} with SN ${RMOD_sn} status:\n - ${CELL_state}  console=True

Check RMOD cells are enabled online
    [Arguments]  ${CELL_class_name}  ${RMOD_cell_list}  ${CELL_state_check}  ${alias}  ${timeout}

    FOR  ${item}  IN  @{RMOD_cell_list}

       Assert  class_name=${CELL_class_name}  id=${item}  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
       Wait Until Keyword Succeeds  120s  1s  Check cell is enabled online  ${CELL_class_name}  ${item}  ${CELL_state_enabled_degraded_check}
       ...  ${alias}  1

    END

Check cell is enabled online
    [Arguments]  ${CELL_class_name}  ${CELL_id}  ${CELL_state_check}  ${alias}  ${timeout}

    ${CELL_status_enabled_degraded_check}=  Run Keyword And Return Status  Assert  class_name=${CELL_class_name}  id=${CELL_id}
    ...  parameters=${CELL_state_check}  timeout=${timeout}  connection=${alias}
    Should Be Equal  ${CELL_status_enabled_degraded_check}  ${False}

Check alarms after power OFF RMOD
    [Arguments]  ${RMOD_sn}  ${alias}

    ${BTS_chained_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}
    ${BTS_chained_RMOD_sn_list}=  Get From Dictionary  ${BTS_chained_RMOD_sn_dict}  ${RMOD_sn}
    ${BTS_chained_RMOD_sn_count}=  Get Length  ${BTS_chained_RMOD_sn_list}
    ${RMOD_FID10_count}=  Evaluate  ${BTS_chained_RMOD_sn_count} + 1
    ${BTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10}  ${RMOD_FID10_count}

    ${BTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS_4003}  ${${alias.upper()}_IGNORED_ALARMS}
    Log  BTS ${alias} "No connection to unit (10)" alarm, expected number: ${RMOD_FID10_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${BTS_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${BTS_IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} "No connection to unit (10)" alarm, found number: ${RMOD_FID10_count}, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Return From Keyword If  '${CB005763_CHECK}' != 'True' or '${RMOD_sn}' in ${CB005763_EXEMPTED_RMOD_SERIAL_NUMBER_LIST}

    ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
    ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list

    Return From Keyword If  '${RMOD_sn}' not in ${BTS_primary_controller_RMOD_sn_list}

    Log  Check BTS ${alias} (as primary controller) feature CB005763 behaviour:  console=True

    ${alarm_status}=  Run Keyword And Return Status  Assert Alarm Active  parameters=faultId=10, supplAlarmInfo=regex".*RU power loss.*"  timeout=60
    ...  connection=${alias}
    Run Keyword If  not ${alarm_status}  Run Keywords
    ...  Log  BTS ${alias} check feature CB005763 behavior failed, not found specific field "Supplementary alarm information" info: "RU power loss"!
    ...  level=ERROR
    ...  AND  Fail  BTS ${alias} check feature CB005763 behavior failed!

    Get and check detailed RD Fault from IMS  alias=${alias}  start_timestamp=${time_power_off}  expected_rd_faults=${IMS_EXPECTED_ALARMS_4774}

    Log  BTS ${alias} check feature CB005763 behaviour passed:  console=True
    Log  - found "No connection to unit (10)" alarm specific field "Supplementary alarm information" info: "RU power loss", as expected!  console=True
    Log  - found IMS fault 4774, as expected!  console=True

Get impacted RMOD exempted cells info
    [Arguments]  ${RMOD_sn}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}  ${GSM_cell_info_exempted}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    Get RMOD exempted cells info  ${RMOD_sn}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
    ...  ${GSM_cell_info_exempted}

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        ${BTS_chained_RMOD_sn_dict}=  Get From Dictionary  ${all_BTS_chained_RMOD_sn_dict}  ${alias}
        ${BTS_chained_RMOD_sn_list}=  Get From Dictionary  ${BTS_chained_RMOD_sn_dict}  ${RMOD_sn}

        Get chained RMOD exempted cells info  ${BTS_chained_RMOD_sn_list}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}
        ...  ${WCDMA_cell_info_exempted}  ${GSM_cell_info_exempted}

    END

Get chained RMOD exempted cells info
    [Arguments]  ${BTS_chained_RMOD_sn_list}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
    ...  ${GSM_cell_info_exempted}

    FOR  ${item}  IN  @{BTS_chained_RMOD_sn_list}

        Get RMOD exempted cells info  ${item}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}
        ...  ${GSM_cell_info_exempted}

    END

Get RMOD exempted cells info
    [Arguments]  ${RMOD_sn}  ${NR_cell_info_exempted}  ${LTE_cell_info_exempted}  ${WCDMA_cell_info_exempted}  ${GSM_cell_info_exempted}

    ${RMOD_BTS_alias_list}=  Get From Dictionary  ${RMOD_sn_BTS_alias_dict}  ${RMOD_sn}

    FOR  ${alias}  IN  @{RMOD_BTS_alias_list}

        Set To Dictionary  ${NR_cell_info_exempted}  ${alias}=${${alias}_${RMOD_sn}_RMOD_NR_CELL_ids_list}
        Get RMOD exempted LTE cells info  ${RMOD_sn}  ${alias}
        Set To Dictionary  ${LTE_cell_info_exempted}  ${alias}=${${alias}_${RMOD_sn}_RMOD_LTE_CELL_ids_exempted_list}
        Set To Dictionary  ${WCDMA_cell_info_exempted}  ${alias}=${${alias}_${RMOD_sn}_RMOD_WCDMA_CELL_ids_list}
        Set To Dictionary  ${GSM_cell_info_exempted}  ${alias}=${${alias}_${RMOD_sn}_RMOD_GSM_CELL_ids_list}

    END

Get and check KPI54a info from IMS file
    [Documentation]
    ...  Get and check KPI54a info from IMS file.
    [Arguments]  ${RMOD_sn}  ${alias}

    Log  Get and check KPI54a info from IMS file on BTS ${alias}  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi54a  kpi_thresholds=${RMOD_POWER_ON_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${time_power_on}  end_point_timestamp_UTC=${time_end}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi54a

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${${RMOD_sn}_RMOD_pn}_${RMOD_sn}  obj_id=${alias}  action_1=RMOD_Power_On  kpi_reported_1=KPI_54a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Check if all PDU port status is on

    FOR  ${RMOD_sn}  IN  @{RMOD_all_sn_list}

        Check if PDU port status is on  RMOD_${RMOD_sn}  120

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all PDU port status is on
    Export KPI Results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
