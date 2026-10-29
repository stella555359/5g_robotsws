*** Settings ***
Documentation    TC__SBTS__STATE__RM_Power_Off_On
Variables    tc_variables/sbts__state__rm_power_off_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3           # Number of RM power OFF/ON operations, default value 3
${OPERATION_ORDER}         ONE_BY_ONE  # Power OFF/ON operation order; possible values ONE_BY_ONE (power OFF each RM then power ON it) or
                                       # ALL (power OFF all RM then power ON them); default ONE_BY_ONE
${HW_RESET_TIME_INTERVAL}  480         # Time interval between reset RM, default value 480 seconds.
${HW_POWER_ON_WRN_THR}     240         # Compared with the time spent between RM power ON and last cell up.
                                       # If exceeds HW_RESET_TIME_INTERVAL, test verdict passed with restriction and snapshot collected.
                                       # Default value: in accordance with KPI 54 specifications
${HW_POWER_MAX_WAIT_TIME}  900         # Maximum Wait time for all cells on SBTS to be OnAir after RM power on

*** Keywords ***
TC__SBTS__STATE__RM_Power_Off_On
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21893
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for RM power OFF/ON operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get RM list and associated info
    ...  - perform power OFF/ON operations on each RM checking BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  - check final BTS state and alarms
    ...  Pass criteria: RM power OFF/ON operations work as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 15.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21893 - [5G][RFSplit] RFS_BTS__STATE__Radio_Module_Power_off_on
    ...  - 16.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22606 - [5G][RFSplit] SBTS__STATE__RM_Power_OFF_ON increasing time after power on
    ...  acording with KPI54a
    ...  - 23.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22650 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - SBTS part
    ...  - 22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22800
    ...  - [5G][RFSplit]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM fails due to IOT cells
    ...  - 07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24667 - [5G]  RM_OPERATION_TIME_INTERVAL mechanism update - RFSplit
    ...  - 07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24677 -
    ...  [5G] Update scenarios to take reset number from ims2 -RM Reset, Power off/on - RFSplit
    ...  - 08.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24679 -
    ...  [5G] KPI54a measurement +KPI54a TC verdict - RFSplit
    ...  - 14.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25422 - [5G] Test NR_SBTS__STATE__NR_RM_Power_Off_On should be improved regarding
    ...  KpiTimeInfo file to reffer to RM_Power_On duration instead of RM_Reset duration
    ...  - 31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25025 -
    ...  [5G][CB007184] Automated_RFSplit_SBTS__STATE__Radio_module_Power_OFF_ON is failed on cell state check after power off RMOD
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26101 - [5G] RFSplit_Radio_Module_Reset and RFSplit_Radio_module_Power_OFF_ON
    ...  are failing sometimes because expected cell state:Enabled because TX/RX channel Online while the cell is in fact Disabled
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 14.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27410 - [5G] [Infomodel] - P1 - Eliminate usage of KW Infomodel "Get baseband
    ...  pool allocation mode info" in test-cases - after TAT-27401
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27819 - [CNI-127210][Part 1] MIMO remove EXPECTED minor alarm from SBTS_* TCs
    ...  - 14.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27956 - [REFACTORING][ALARMS] Remove legacy SOAM alarms in Test_Cases and
    ...  Alarm Files NR_SBTS & SBTS_SBTS
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21893_SBTS__STATE__RM_Power_Off_On.png

    Set Tags    CA-STATE    OWNER-sorin.saulescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get initial baseband pool allocation mode info
    Step 4: Get RM list and info
    Step 5: Check PDU definition and reachability
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Perform Power OFF/ON RM ${INDEX}
        Step 7: Check final number and state of Cells and RMs
        Step 8: Check BTS reset behavior based on IMS info
        Step 9: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD
    END
    Step 10: Check final BTS state
    Step 11: Check final BTS alarms

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} BTS state
    [Documentation]
    ...  BTS state is checked according to Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias_local}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${alias_local}
    Log  BTS site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists. BTS alarms are get from Admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS alarms  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get initial baseband pool allocation mode info
    [Documentation]
    ...  Get initial baseband pool allocation mode info

    Log  Step ${index}: Get initial baseband pool allocation mode info   console=True
    Get baseband pool allocation mode info from SCF  alias=${alias_local}

Step ${index}: Get RM list and info
    [Documentation]
    ...  RM list is get from Admin

    [Timeout]  5 min
    Log  Step ${index}: Get RM list and info  console=True
    ${RM_list}=  Get Ids For All  class_name=RMOD  connection=${alias_local}
    Sort List  ${RM_list}
    ${RM_ID_SN_dict}=  Get RM ID SN dict  ${RM_list}
    Set Test Variable  ${RM_ID_SN_dict}
    Run Keyword If  ${RM_list}
    ...  Log  BTS RM info:  console=True
    ...  ELSE
    ...  Fail  No BTS RM available in runtime view!
    FOR  ${item}  IN  @{RM_list}
        ${RM_SN}=  Get From Dictionary  ${RM_ID_SN_dict}  ${item}
        Log  - RM ID ${item}: SN ${RM_SN}  console=True
    END
    Set Test Variable  ${RM_list}
    ${RM_count}=  Get Length  ${RM_list}
    Set Test Variable  ${RM_count}

    ${RM_CELL_dict}=  Get RM CELL mapping info dict  ${RM_list}
    Set Test Variable  ${RM_CELL_dict}

    Get BTS CELL list by RAT

    ${BTS_chained_RM_id_dict}  ${BTS_chained_RM_sn_dict}=  Get chained RMOD info dict  ${alias_local}
    Set Test Variable  ${BTS_chained_RM_id_dict}

Step ${index}: Check PDU definition and reachability
    [Documentation]
    ...  Check if PDU for RM are defined in interfaces.yaml

    Log  Step ${index}: Check PDU definition and reachability  console=True
    FOR  ${item}  IN  @{RM_list}
        ${RM_SN}=  Get From Dictionary  ${RM_ID_SN_dict}  ${item}
        Check PDU port status  RMOD_${RM_SN}  on
    END

Step ${index}: Perform Power OFF/ON RM ${CYCLE}
    Log  Step ${index}: Perform Power OFF/ON RM  console=True
    Set Test Variable  ${RM_powered_off}  0
    Get RESET timestamp info  start
    Run Keyword If  '${OPERATION_ORDER.upper()}' == 'ONE_BY_ONE'
    ...  Power OFF/ON one by one  ${CYCLE}
    ...  ELSE IF  '${OPERATION_ORDER.upper()}' == 'ALL'  Run Keywords
    ...  Power OFF all RM  AND  Power ON all RM  ${CYCLE}

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  Reset behavior is checked based on IMS info.
    ...  Reset behavior as expected if: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias_local}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks
    Get RESET timestamp info  end

Step ${index}: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD
    Log  Step ${index}: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD  console=True
    Get Current Time  final_checks
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final_checks}  ${time_start}  number
    ${remained_time}=  BuiltIn.Evaluate  ${HW_RESET_TIME_INTERVAL}-${time_elapsed_final}
    Run Keyword If  ${remained_time}>0  Run Keywords
    ...  Log  Time interval between RM HW Reset operations: ${HW_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec

Get BTS CELL list by RAT
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias_local}
    ${LTE_CELL_list}  ${LTE_CELL_IOT_list}=  Admin Get LTE CELL Ids list  ${alias_local}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias_local}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias_local}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${NR_CELL_list}
    Set Test Variable  ${LTE_CELL_list}
    Set Test Variable  ${WCDMA_CELL_list}
    Set Test Variable  ${GSM_CELL_list}
    Set Test Variable  ${CELL_list}
    ${CELL_count}=  Get Length  ${CELL_list}
    Set Test Variable  ${CELL_count}

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Get RM ID SN dict
    [Arguments]   ${RM_list}
    ${RM_ID_SN_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RM_list}
        ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${item}  connection=${alias_local}
        Set To Dictionary  ${RM_ID_SN_dict}  ${RM_param['id']}  ${RM_param['serialNumber']}
    END
    [Return]  ${RM_ID_SN_dict}

Get RM CELL mapping info dict
    [Arguments]   ${RM_list}
    ${RM_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{RM_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias_local}
        Sort List  ${CELL_list}
        Set To Dictionary  ${RM_CELL_dict}  ${item}  ${CELL_list}
    END
    [Return]  ${RM_CELL_dict}

Power OFF/ON one by one
    [Arguments]  ${CYCLE}
    Log  ***** Power OFF/ON one by one *****  console=True
    FOR  ${item}  IN  @{RM_list}
        Perform power OFF RM  ${item}
        Perform power ON RM  ${item}  ${CYCLE}
    END

Power OFF all RM
    Log  ***** Power OFF all RM *****  console=True
    FOR  ${item}  IN  @{RM_list}
        Perform power OFF RM  ${item}
    END

Power ON all RM
    [Arguments]  ${CYCLE}
    Log  ***** Power ON all RM *****  console=True
    FOR  ${item}  IN  @{RM_list}
        Perform power ON RM  ${item}  ${CYCLE}
    END

Perform power OFF RM
    [Arguments]  ${RM_ID}
    ${RM_state_powered_off_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RM_state_powered_off}=  Set Variable
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline_, administrativeState=Unlocked
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}, blockingState=${Unblocked_}
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked
    ${RM_SN}=  Get From Dictionary  ${RM_ID_SN_dict}  ${RM_ID}

    ${chained_RM_id_list}=  Get From Dictionary  ${BTS_chained_RM_id_dict}  ${RM_id}
    ${RM_list_final}=  Get current RM and chained RM list  ${RM_ID}  ${chained_RM_id_list}
    ${RM_list_count}=  Get Length  ${RM_list_final}
    Set Test Variable  ${chained_RM_id_list}
    Set Test Variable  ${RM_list_final}
    Run Keyword If  '${OPERATION_ORDER}' == 'ONE_BY_ONE'  Get RM all cells from specific RAT  ${RM_list_final}

    Log  Perform power OFF RM ${RM_ID} with SN ${RM_SN}:  console=True
    Get Current Time  start
    Get RESET timestamp info  start
    Pdu BTS Interface Off  RMOD_${RM_SN}
    Check PDU port status  RMOD_${RM_SN}  off
    Sleep  5s

    Run Keyword If  ${chained_RM_id_list} and '${OPERATION_ORDER}' == 'ONE_BY_ONE'
    ...  Log  Check RM and chained RM(s) (connected to RM with SN ${RM_SN}) state after power OFF RM with SN ${RM_SN}:  console=True
    ...  ELSE  Log  Check RM state after power OFF RM with SN ${RM_SN}:  console=True
    Run Keyword If  '${OPERATION_ORDER}' == 'ONE_BY_ONE'
    ...  Check RM list status  ${RM_list_final}  ${time_start}  ${RM_state_powered_off_check}  ${RM_state_powered_off}  ${alias_local}
    ...  ELSE IF  '${OPERATION_ORDER}' == 'ALL'
    ...  Check RM status  ${RM_ID}  ${time_start}  ${RM_state_powered_off_check}  ${RM_state_powered_off}  ${alias_local}

    ${RM_powered_off}=  Evaluate  ${RM_powered_off} + 1
    Set Test Variable  ${RM_powered_off}
    Run Keyword If  '${OPERATION_ORDER}' == 'ALL' and ${RM_count} > ${RM_powered_off}
    ...  Return From Keyword
    ...  ELSE IF  '${OPERATION_ORDER}' == 'ALL' and ${RM_count} == ${RM_powered_off}  Run Keywords
    ...  Check BTS state and alarm after power all RM  OFF  ${time_start}  ${CELL_state_disabled_check}  ${CELL_state_disabled}  ${alias_local}
    ...  AND  Return From Keyword

    Run Keyword If  ${chained_RM_id_list}
    ...  Log Long String  Check cell(s) status mapped on RM and chained RM(s) (connected to RM with SN ${RM_SN}) after power OFF RM with SN
    ...  ${RM_SN}:  console=True
    ...  ELSE  Log  Check cell(s) status mapped on RM after power OFF RM with SN ${RM_SN}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on RM  ${alias_local}

    Log  Check BTS alarms after power OFF RM with SN ${RM_SN}:  console=True
    ${BTS_ALARM_COUNT_10}=  Set Variable  ${RM_list_count}
    ${SBTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_10}  ${BTS_ALARM_COUNT_10}
    ${SBTS_IGNORED_ALARMS_full}=  Combine Lists  ${${alias_local.upper()}_IGNORED_ALARMS_4003}  ${${alias_local.upper()}_IGNORED_ALARMS}

    Log  BTS "No connection to Unit (10)" alarm, expected number: ${BTS_ALARM_COUNT_10}  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${SBTS_EXPECTED_ALARMS_10_full}  ignored_alarms=${SBTS_IGNORED_ALARMS_full}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS "No connection to Unit (10)" alarm, found number: ${BTS_ALARM_COUNT_10}, as expected!  console=True
    Log  BTS site - expected, ignored and critical alarms checked  console=True

    Check cells state not mapped on RM  ${RM_SN}

Perform power ON RM
    [Arguments]  ${RM_ID}  ${CYCLE}
    Set Test Variable  ${RM_state_powered_on_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_powered_on}  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${RM_SN}=  Get From Dictionary  ${RM_ID_SN_dict}  ${RM_ID}

    Log  Perform power ON RM ${RM_ID} with SN ${RM_SN}:  console=True
    Get Current Time  sbts_initial
    Pdu BTS Interface On  RMOD_${RM_SN}
    Check PDU port status  RMOD_${RM_SN}  on
    Get RESET timestamp info  start_powerON
    Sleep  5s

    ${RM_powered_off}=  Evaluate  ${RM_powered_off} - 1
    Set Test Variable  ${RM_powered_off}

    Run Keyword If  '${OPERATION_ORDER}' == 'ALL' and ${RM_powered_off} > 0  Return From Keyword

    Run Keyword If  ${chained_RM_id_list} and '${OPERATION_ORDER}' == 'ONE_BY_ONE'
    ...  Log  Check RM and chained RM(s) (connected to RM with SN ${RM_SN}) state after power ON RM with SN ${RM_SN}:  console=True
    ...  ELSE IF  '${OPERATION_ORDER}' == 'ONE_BY_ONE'
    ...  Log  Check RM state after power ON RM with SN ${RM_SN}:  console=True
    Run Keyword If  '${OPERATION_ORDER}' == 'ONE_BY_ONE'
    ...  Check RM list status  ${RM_list_final}  ${time_sbts_initial}  ${RM_state_powered_on_check}  ${RM_state_powered_on}  ${alias_local}

    Run Keyword If  '${OPERATION_ORDER}' == 'ALL' and ${RM_powered_off} == 0  Run Keywords
    ...  Check BTS state and alarm after power all RM  ON  ${time_sbts_initial}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${alias_local}
    ...  AND  Return From Keyword

    ${remained_MAX_WAIT_TIME}=  Get elapsed time   ${time_sbts_initial}  ${HW_POWER_MAX_WAIT_TIME}
    Check cells availability status online  ${alias_local}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias_local} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS alarms after power ON RM with SN ${RM_SN}:  console=True
    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

    Get RESET timestamp info  end_powerON
    Get and check KPI54a info from IMS file  ${RM_ID}  ${alias_local}  ${CYCLE}

Get current RM and chained RM list
    [Arguments]  ${RM_id}  ${chained_RM_id_list}

    ${RMOD_list}=  Create List
    Append To List  ${RMOD_list}  ${RM_id}
    FOR  ${item}  IN  @{chained_RM_id_list}
        Append To List  ${RMOD_list}  ${item}
    END

    [Return]  ${RMOD_list}

Get RM all cells from specific RAT
    [Arguments]  ${RMOD_list}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    ${CELL_RM_list}=  Create List
    ${CELL_RM_count}=  Set Variable  0

    FOR  ${RM_id}  IN  @{RMOD_list}
        ${NR_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}  ${CELL_RMOD_list}=
        ...  Get RM cells mapped on RM from specific RAT  ${RM_id}
        ${NR_CELL_RM_list}=  Combine Lists  ${NR_CELL_RM_list}  ${NR_CELL_RMOD_list}
        ${LTE_CELL_RM_list}=  Combine Lists  ${LTE_CELL_RM_list}  ${LTE_CELL_RMOD_list}
        ${WCDMA_CELL_RM_list}=  Combine Lists  ${WCDMA_CELL_RM_list}  ${WCDMA_CELL_RMOD_list}
        ${GSM_CELL_RM_list}=  Combine Lists  ${GSM_CELL_RM_list}  ${GSM_CELL_RMOD_list}
        ${CELL_RM_list}=  Combine Lists  ${CELL_RM_list}  ${CELL_RMOD_list}
    END

    ${NR_CELL_RM_list}=  Remove Duplicates  ${NR_CELL_RM_list}
    ${LTE_CELL_RM_list}=  Remove Duplicates  ${LTE_CELL_RM_list}
    ${WCDMA_CELL_RM_list}=  Remove Duplicates  ${WCDMA_CELL_RM_list}
    ${GSM_CELL_RM_list}=  Remove Duplicates  ${GSM_CELL_RM_list}
    ${CELL_RM_list}=  Remove Duplicates  ${CELL_RM_list}
    ${CELL_RM_count}=  Get Length  ${CELL_RM_list}

    ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}  ${CELL_not_RM_list}=
    ...  Get RM cells not mapped on RM from specific RAT
    ...  ${CELL_RM_list}

    Set Test Variable  ${NR_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_list}
    Set Test Variable  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${GSM_CELL_RM_list}
    Set Test Variable  ${CELL_RM_list}
    Set Test Variable  ${CELL_RM_count}
    Set Test Variable  ${NR_CELL_not_RM_list}
    Set Test Variable  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${CELL_not_RM_list}

Get RM cells mapped on RM from specific RAT
    [Arguments]  ${RM_id}
    ${CELL_RM_list}=  Get From Dictionary  ${RM_CELL_dict}  ${RM_ID}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{CELL_list}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${NR_CELL_list}  Append To List  ${NR_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${LTE_CELL_list}  Append To List  ${LTE_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${GSM_CELL_list}  Append To List  ${GSM_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}

    [Return]  ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}  ${CELL_RM_list}

Get RM cells not mapped on RM from specific RAT
    [Arguments]  ${CELL_RM_list}

    ${NR_CELL_not_RM_list}=  Copy List  ${NR_CELL_list}
    ${LTE_CELL_not_RM_list}=  Copy List  ${LTE_CELL_list}
    ${WCDMA_CELL_not_RM_list}=  Copy List  ${WCDMA_CELL_list}
    ${GSM_CELL_not_RM_list}=  Copy List  ${GSM_CELL_list}
    FOR  ${item}  IN  @{CELL_RM_list}
        Remove Values From List  ${NR_CELL_not_RM_list}  ${item}
        Remove Values From List  ${LTE_CELL_not_RM_list}  ${item}
        Remove Values From List  ${WCDMA_CELL_not_RM_list}  ${item}
        Remove Values From List  ${GSM_CELL_not_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_not_RM_list}
    Sort List  ${LTE_CELL_not_RM_list}
    Sort List  ${WCDMA_CELL_not_RM_list}
    Sort List  ${GSM_CELL_not_RM_list}
    ${CELL_not_RM_list}=  Combine Lists  ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}

    [Return]  ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}  ${CELL_not_RM_list}

Check RM list status
    [Arguments]   ${RM_id_list}  ${reference_time}  ${rm_state_check}  ${rm_state}  ${alias}
    FOR  ${item}  IN  @{RM_id_list}
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
        Assert  class_name=RMOD  id=${item}  parameters=${rm_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
        Log  RM ${item} status:\n - ${rm_state}  console=True
    END

Check RM status
    [Arguments]   ${RM_id}  ${reference_time}  ${rm_state_check}  ${rm_state}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RM_id}  parameters=${rm_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  RM ${RM_id} status:\n - ${rm_state}  console=True

Check BTS state and alarm after power all RM
    [Arguments]  ${operation}  ${reference_time}  ${cell_state_check}  ${cell_state}  ${alias}

    Run Keyword If  '${operation}' == 'ON'  Run Keywords
    ...  Log  Check RM(s) state after power ON all RM:  console=True
    ...  AND  Check RM list status  ${RM_list}  ${reference_time}  ${RM_state_powered_on_check}  ${RM_state_powered_on}  ${alias_local}

    Log  Check cell(s) state after power ${operation} all RM:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
    Run Keyword If  ${NR_CELL_list}
    ...  Check Cell State  NRCEL  ${NR_CELL_list}  ${cell_state_check}  ${cell_state}  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
    Run Keyword If  ${LTE_CELL_list}
    ...  Check Cell State  LNCEL  ${LTE_CELL_list}  ${cell_state_check}  ${cell_state}  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
    Run Keyword If  ${WCDMA_CELL_list}
    ...  Check Cell State  WNCEL  ${WCDMA_CELL_list}  ${cell_state_check}  ${cell_state}  ${remained_MAX_WAIT_TIME}  ${alias}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${reference_time}  ${HW_POWER_MAX_WAIT_TIME}
    Run Keyword If  ${GSM_CELL_list}
    ...  Check Cell State  GNCEL  ${GSM_CELL_list}  ${cell_state_check}  ${cell_state}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  Check BTS alarm after power ${operation} all RM:  console=True
    ${BTS_ALARM_COUNT_10}=  Set Variable  ${RM_count}
    ${SBTS_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_10}  ${BTS_ALARM_COUNT_10}

    Run Keyword If  '${operation}' == 'OFF'  Run Keywords
    ...  Log  BTS "No connection to Unit (10)" alarm, expected number: ${BTS_ALARM_COUNT_10}  console=True
    ...  AND  Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=${SBTS_EXPECTED_ALARMS_10_full}
    ...  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    ...  AND  Log  BTS "No connection to Unit (10)" alarm, found number: ${BTS_ALARM_COUNT_10}, as expected!  console=True
    ...  ELSE IF  '${operation}' == 'ON'
    ...  Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias_local}
        Log  ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check PDU port status
    [Arguments]  ${item}  ${status}
    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${item}
    Run Keyword if  '${PDU_port_status}' == '${status}'
    ...  Log  ${item} outlet ${INTERFACES['${item}']['OUTLET']} on ${INTERFACES['${item}']['IP']} switched ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${item} outlet ${INTERFACES['${item}']['OUTLET']} on ${INTERFACES['${item}']['IP']} not switched ${PDU_port_status}!  level=ERROR
    ...  AND  Fail  ${item} outlet ${INTERFACES['${item}']['OUTLET']} on ${INTERFACES['${item}']['IP']} not switched ${PDU_port_status}!

Check if all PDU port status is on
     FOR  ${item}  IN  @{RM_list}
        ${RM_SN}=  Get From Dictionary  ${RM_ID_SN_dict}  ${item}
        Check if PDU port status is on  RMOD_${RM_SN}  120
    END

Check cells state mapped on RM
    [Arguments]  ${alias}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${NR_CELL_RM_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${NR_CELL_RM_list}  alias=${alias}

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${LTE_CELL_RM_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${LTE_CELL_RM_list}  alias=${alias}

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${WCDMA_CELL_RM_list}  alias=${alias}

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${GSM_CELL_RM_list}  alias=${alias}

Check cells state not mapped on RM
    [Arguments]  ${RM_SN}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    Run Keyword If  ${CELL_not_RM_list} and ${chained_RM_id_list}
    ...  Log  Check BTS cells status not mapped on RM with SN ${RM_SN} and chained RM(s) (connected to RM with SN ${RM_SN}):  console=True
    ...  ELSE  Log  Check BTS cells status not mapped on RM with SN ${RM_SN}:  console=True

    Run Keyword If  ${CELL_not_RM_list}  Run Keywords
    ...  Run Keyword If  ${NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${NR _CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias_local}
    ...  AND  Run Keyword If  ${LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias_local}
    ...  AND  Run Keyword If  ${WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias_local}
    ...  AND  Run Keyword If  ${GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias_local}

Get and check KPI54a info from IMS file
    [Documentation]
    ...  Get and check KPI54a info from IMS file.

    [Arguments]  ${RM_id}  ${alias}  ${CYCLE}

    ${RM_label}=  Fetch From Right  ${RM_id}  /
    ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}

    Log Long String  ***** Get and check BTS ${alias} KPI54a info related to Power ON RM with SN ${RM_param['serialNumber']}
    ...  for iteration ${CYCLE} *****  console=True

    ${kpi_name_delta_dict_kpi54a}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi54a  kpi_thresholds=${HW_POWER_ON_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_powerON_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_powerON_UTC}
    ${kpi_delta_list_kpi54a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi54a}  kpi54a

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${alias}
    ...  action_1=RM_Power_On  kpi_reported_1=KPI_54a  event_value_1=${kpi_delta_list_kpi54a[0]}  cycle=${CYCLE}  source_info=ims

Particular Teardown
    Run Keyword And Continue On Failure  Check if all PDU port status is on
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
