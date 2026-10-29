*** Settings ***
Documentation    TC__SBTS__STATE__RM_Reset_from_WEBEM
Variables    tc_variables/sbts__state__rm_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3     # Number of RM reset operations, default value 3
${HW_RESET_TIME_INTERVAL}  480   # Time interval between reset RM, default value 480 seconds.
${HW_RESET_WRN_THR}        180   # Compared with the time spent between first cell down - last cell up mapped on RM.
                                 # If exceeds HW_RESET_WRN_THR, test verdict passed with restriction and snapshot collected.
                                 # Default value: in accordance with KPI 51 a specifications
${HW_RESET_MAX_WAIT_TIME}  900   # Maximum Wait time for all cells on both BTS to be OnAir after RM reset
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS__STATE__RM_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-21889
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS test case for RM reset operations, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial BTS state and alarms
    ...  - get RM list and associated info
    ...  - perform Reset operation on each RM checking BTS state and alarms
    ...  - check BTS reset behavior based on IMS info: reset number is 0
    ...  - check final BTS state and alarms
    ...  Pass criteria: reset operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.10.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21889 - [5G][RFSPLIT] RFS_SBTS_Radio_Module_Reset_from_WebEM
    ...  - 17.12.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-22334 -
    ...  [5G][RFSPLIT] Update KW Check all RM cells from specific RAT - RFS_SBTS_Radio_Module_Reset_from_WebEM
    ...  - 22.03.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22800
    ...  - [5G][RFSplit]SBTS__STATE__BBMOD_LockUnlock_from_WEBEM fails due to IOT cells
    ...  - 23.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24774 - [5G] Replace Setup Admin KW with Start new ADMIN instance KW - RFSplit
    ...  - 07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24667 - [5G]  RM_OPERATION_TIME_INTERVAL mechanism update - RFSplit
    ...  - 07.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24677 -
    ...  [5G] Update scenarios to take reset number from ims2 -RM Reset, Power off/on - RFSplit
	...  - 07.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24678 -
	...  [5G] KPI51a measurement +TC verdict - RFSplit
	...  - 16.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24903 - [5G] Remove unnecessary code from SBTS__STATE__RM_Reset_from_WEBEM
    ...  - 12.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25667 -
    ...  [5G][RFSplit][CB009245] update "SBTS__STATE__RM_Reset_from_WEBEM" to check chained RMs
    ...  - 31.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25149 -
    ...  [5G][CB007184] [1][1.0] Automated_RFSplit_SBTS__STATE__RM_Reset_from_WEBEM should be aligned with CB007184
    ...  - 11.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26101 - [5G] RFSplit_Radio_Module_Reset and RFSplit_Radio_module_Power_OFF_ON
    ...  are failing sometimes because expected cell state:Enabled because TX/RX channel Online while the cell is in fact Disabled
    ...  - 06.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27820 - [CNI-127210] MIMO Explicit IMS minor expected alarm check in RM Reset TCs
    ...  - 14.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28155 - [CNI-127210][DROP3] EXPECTED 4003 alarm from ADMIN on both CNI and
    ...  without CNI
    ...  - 03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29815 -
    ...  Unify alarm container names between all tests in order to use ${${alias.upper()}}_ALARMS_CNI_127210 ${${alias.upper()}}_ALARMS_NO_CNI_127210
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-21889_SBTS__STATE__RM_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-geraldina.isfan@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-22R1

    Step 1: Check initial BTS state
    Step 2: Check initial BTS alarms
    Step 3: Get RM list and info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Reset RM ${INDEX}
        Step 5: Check final number and state of Cells and RMs
        Step 6: Check BTS reset behavior based on IMS info
        Step 7: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD
    END
    Step 8: Check final BTS state
    Step 9: Check final BTS alarms

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

Step ${index}: Get RM list and info
    [Documentation]
    ...  RM list is get from Admin

    Log  Step ${index}: Get RM list and info  console=True
    ${RM_id_list}=  Get Ids For All  class_name=RMOD  connection=${alias_local}
    Sort List  ${RM_id_list}
    ${RM_count}=  Get Length  ${RM_id_list}
    Set Test Variable  ${RM_id_list}
    Set Test Variable  ${RM_count}

    Get BTS CELL list by RAT  ${alias_local}

    ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias_local}
    Set Test Variable  ${RM_L3Protocol_dict}

    ${BTS_chained_RM_id_dict}  ${BTS_chained_RM_sn_dict}=  Get chained RMOD info dict  ${alias_local}
    Set Test Variable  ${BTS_chained_RM_id_dict}

Step ${index}: Perform Reset RM ${CYCLE}
    Log  Step ${index}: Perform Reset RM  console=True
    FOR  ${item}  IN  @{RM_id_list}
        Get RESET timestamp info  start_resetRM
        Reset RM  ${item}
        Get RESET timestamp info  end_resetRM
        Run Keyword If  ${CELL_RM_failed} > 0
        ...  Get and check KPI51a and KPI51b info from IMS file  ${item}  ${alias_local}  primary  primary  ${CYCLE}
    END

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  Reset behavior is checked based on IMS info.
    ...  Reset behavior as expected if: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias_local}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD
    Log  Step ${index}: Sleep to ensure HW_RESET_TIME_INTERVAL between actions on same RMOD  console=True
    Get Current Time  final_checks
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final_checks}  ${time_start}  number
    ${remained_time}=  BuiltIn.Evaluate  ${HW_RESET_TIME_INTERVAL}-${time_elapsed_final}
    Run Keyword If  ${remained_time} > 0  Run Keywords
    ...  Log  Time interval between Reset RM operations: ${HW_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec

Get BTS CELL list by RAT
    [Arguments]  ${alias}
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}  ${LTE_CELL_IOT_list}=  Admin Get LTE CELL Ids list  ${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${NR_CELL_list}
    Set Test Variable  ${LTE_CELL_list}
    Set Test Variable  ${WCDMA_CELL_list}
    Set Test Variable  ${GSM_CELL_list}
    Set Test Variable  ${CELL_list}

Get RESET timestamp info
    [Arguments]  ${when}
    Get Current Date UTC info  ${when}
    Log  UTC ${when}_point_timestamp: ${date_timestamp_${when}_UTC}  console=True

Reset RM
    [Arguments]  ${RM_id}
    ${RM_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RM_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RM_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RM_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias_local}
    Set Test Variable  ${RM_sn}  ${RM_param['serialNumber']}

    ${chained_RM_id_list}=  Get From Dictionary  ${BTS_chained_RM_id_dict}  ${RM_id}
    ${RM_list}=  Get current RM and chained RM list  ${RM_id}  ${chained_RM_id_list}

    Get RM all cells from specific RAT  ${RM_list}

    ${RM_L3Protocol}=  Get From Dictionary  ${RM_L3Protocol_dict}  ${RM_id}
    ${RM_protocol}=  Set Variable If  '${RM_L3Protocol}' == 'RP301_RP1'  OBSAI  '${RM_L3Protocol}' == 'CPRI_RP1'  CPRI
    ...  '${RM_L3Protocol}' == 'ECPRI_MPLANE'  ECPRI

    Log  Perform "Reset" operation on RM (${RM_protocol}) with SN ${RM_sn} from BTS ${alias_local}:  console=True

    Get Current Time  start
    ${new_alias}=  Set Variable  resetRM
    Start new ADMIN instance  alias=${alias_local}  new_alias=${new_alias}  connection_type=${connection_type_${alias_local}}
    ${reset_info}=  RFS RM Reset  dist_name=${RM_id}  timeout=${HW_RESET_MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias_local}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Get Current Time  initial

    Log  Check BTS ${alias_local} state and alarms during reset RM (${RM_protocol}) with SN ${RM_sn}:  console=True
    Run Keyword If  ${chained_RM_id_list}
    ...  Log  Check BTS ${alias_local} RM with SN ${RM_sn} and chained RM(s) (connected to RM with SN ${RM_sn}) status:  console=True
    ...  ELSE  Log  Check BTS ${alias_local} RM with SN ${RM_sn} status:  console=True
    Check RM status  ${RM_list}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${alias_local}

    Sleep  10s  reason=Avoid cell transitory states

    Run Keyword If  ${chained_RM_id_list}
    ...  Log  Check BTS ${alias_local} cells status mapped on RM with SM ${RM_sn} and chained RM(s) (connected to RM with SN ${RM_sn}):  console=True
    ...  ELSE  Log  Check BTS ${alias_local} cells status mapped on RM with SM ${RM_sn}:  console=True
    Check cells state mapped on RM  ${alias_local}
    Check alarms during RM reset  ${alias_local}
    Check cells state not mapped on RM  ${alias_local}  ${chained_RM_id_list}

    Collect Keyword Result  ${reset_info}  timeout=${HW_RESET_MAX_WAIT_TIME}

    Log  Check BTS ${alias_local} state and alarms after reset RM (${RM_protocol}) with SN ${RM_sn}:  console=True
    Run Keyword If  ${chained_RM_id_list}
    ...  Log  Check BTS ${alias_local} RM with SN ${RM_sn} and chained RM(s) (connected to RM with SN ${RM_sn}) status:  console=True
    ...  ELSE  Log  Check BTS ${alias_local} RM with SN ${RM_sn} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${HW_RESET_MAX_WAIT_TIME}
    Check RM status  ${RM_list}  ${RM_state_enabled_check}  ${RM_state_enabled}  ${alias_local}

    Log  Check BTS ${alias_local} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${HW_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${alias_local}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias_local} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Get and Check Alarms SOAM  alias=${alias_local}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Log  BTS site - expected, ignored and critical alarms checked  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Get current RM and chained RM list
    [Arguments]  ${RM_id}  ${chained_RM_id_list}

    ${RM_list}=  Create List
    Append To List  ${RM_list}  ${RM_id}
    FOR  ${item}  IN  @{chained_RM_id_list}
        Append To List  ${RM_list}  ${item}
    END

    [Return]  ${RM_list}

Get RM all cells from specific RAT
    [Arguments]  ${RM_list}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    ${CELL_RM_list}=  Create List

    FOR  ${RM_id}  IN  @{RM_list}
        ${NR_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}  ${CELL_RMOD_list}=
        ...  Get RM cells mapped on RM from specific RAT  ${RM_id}  ${alias_local}
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

    ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}  ${CELL_not_RM_list}=
    ...  Get RM cells not mapped on RM from specific RAT
    ...  ${CELL_RM_list}

    Set Test Variable  ${NR_CELL_RM_list}
    Set Test Variable  ${LTE_CELL_RM_list}
    Set Test Variable  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${GSM_CELL_RM_list}
    Set Test Variable  ${CELL_RM_list}
    Set Test Variable  ${NR_CELL_not_RM_list}
    Set Test Variable  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${CELL_not_RM_list}

Get RM cells mapped on RM from specific RAT
    [Arguments]  ${RM_id}  ${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
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
    ${CELL_RM_list}=  Combine Lists   ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}

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

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  Cell ${item} status:\n - ${cell_state}  console=True
    END

Check RM status
    [Arguments]   ${RM_id_list}  ${rm_state_check}  ${rm_state}  ${alias}
    FOR  ${item}  IN  @{RM_id_list}
        ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${HW_RESET_MAX_WAIT_TIME}
        Assert  class_name=RMOD  id=${item}  parameters=${rm_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
        Log  RM ${item} status:\n - ${rm_state}  console=True
    END

Check cells state mapped on RM
    [Arguments]  ${alias}
    ${BTS_ALARM_COUNT_MIMO}=  Set Variable  0
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${NR_CELL_RM_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${NR_CELL_RM_list}  alias=${alias}
    ${NR_cell_state_failed_list}=  Run Keyword If  ${NR_CELL_RM_list}
    ...  Set Variable  ${NR_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${LTE_CELL_RM_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${LTE_CELL_RM_list}  alias=${alias}
    ${LTE_cell_state_failed_list}=  Run Keyword If  ${LTE_CELL_RM_list}
    ...  Set Variable  ${LTE_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${WCDMA_CELL_RM_list}  alias=${alias}
    ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${WCDMA_CELL_RM_list}
    ...  Set Variable  ${WCDMA_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${GSM_CELL_RM_list}  alias=${alias}
    ${GSM_cell_state_failed_list}=  Run Keyword If  ${GSM_CELL_RM_list}
    ...  Set Variable  ${GSM_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    Set Test Variable  ${BTS_ALARM_COUNT_MIMO}

    Calculate number of disabled cells mapped on RM  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}  ${WCDMA_cell_state_failed_list}
    ...  ${GSM_cell_state_failed_list}

Check cells state not mapped on RM
    [Arguments]  ${alias}  ${chained_RM_id_list}
    Run Keyword If  ${CELL_not_RM_list} and ${chained_RM_id_list}
    ...  Log  Check BTS ${alias} cells status not mapped on RM with SN ${RM_sn} and chained RM(s) (connected to RM with SN ${RM_sn}):  console=True
    ...  ELSE  Log  Check BTS ${alias} cells status not mapped on RM with SN ${RM_sn}  console=True

    Run Keyword If  ${CELL_not_RM_list}  Run Keywords
    ...  Run Keyword If  ${NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${NR _CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    ...  AND  Run Keyword If  ${LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    ...  AND  Run Keyword If  ${WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}
    ...  AND  Run Keyword If  ${GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  3  ${alias}

Calculate number of disabled cells mapped on RM
    [Arguments]  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}  ${WCDMA_cell_state_failed_list}  ${GSM_cell_state_failed_list}

    ${NR_cell_state_failed_count}=  Get Length  ${NR_cell_state_failed_list}
    ${LTE_cell_state_failed_count}=  Get Length  ${LTE_cell_state_failed_list}
    ${WCDMA_cell_state_failed_count}=  Get Length  ${WCDMA_cell_state_failed_list}
    ${GSM_cell_state_failed_count}=  Get Length  ${GSM_cell_state_failed_list}

    ${condition}=  Create Long String  ${NR_cell_state_failed_count} + ${LTE_cell_state_failed_count} + ${WCDMA_cell_state_failed_count} +
    ...  ${GSM_cell_state_failed_count}
    ${CELL_RM_failed}=  Evaluate  ${condition}

    Set Test Variable  ${CELL_RM_failed}

Check alarms during RM reset
    [Arguments]  ${alias}

    ${SBTS_EXPECTED_ALARMS_4003_full}=  Prepare expected alarms list  ${${alias_local.upper()}_EXPECTED_ALARMS_4003}  ${BTS_ALARM_COUNT_MIMO}

    Log  Check BTS ${alias} alarms during reset RM with SM ${RM_sn}:  console=True
    Run Keyword If  ${BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, expected number:
    ...  ${BTS_ALARM_COUNT_MIMO}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4003_full}
    ...  ignored_alarms=${${alias_local.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias_local.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, found number:
    ...  ${BTS_ALARM_COUNT_MIMO}, as expected!  console=True
    Log  BTS site - expected, ignored and critical alarms checked  console=True

Get and check KPI51a and KPI51b info from IMS file
    [Documentation]
    ...  Get and check KPI51a and KPI51b info from IMS file.

    [Arguments]  ${RM_id}  ${alias}  ${triggered_from}  ${ims_from}  ${CYCLE}

    ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}

    Log Long String  ***** Get and check BTS ${alias} KPI51a and KPI51b info related to RM with SN ${RM_param['serialNumber']} reset
    ...  for iteration ${CYCLE} *****  console=True

    ${kpi_name_delta_dict_kpi51a}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi51a  kpi_thresholds=${HW_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}  triggered_from=${triggered_from}  ims_from=${ims_from}
    ${kpi_delta_list_kpi51a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51a}  kpi51a

    ${kpi_name_delta_dict_kpi51b}=  Get KPI info
    ...  kpi_names=kpi51b  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}  triggered_from=${triggered_from}  ims_from=${ims_from}
    ${kpi_delta_list_kpi51b}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51b}  kpi51b

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${alias}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51a  event_value_1=${kpi_delta_list_kpi51a[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${alias}

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${alias}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51b  event_value_1=${kpi_delta_list_kpi51b[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${alias}

Particular Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
