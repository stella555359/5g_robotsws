*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
Variables    tc_variables/sbts_sbts__state__secondary_controller_shared_rm_reset_trm_feature_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3      # Number of cycles to perform shared RMOD reset from secondary controller with TRM feature, default value 3
${tempRadioMasterTriggerTime}  2      # Integer value for tempRadioMasterTriggerTime to be commissioned
${tempRadioMasterRecovTime}    2      # Integer value for tempRadioMasterRecovTime to be commissioned
${RM_RESET_TIME_INTERVAL}      480    # Time interval between reset RMOD, default value 480 seconds.
${RM_RESET_MAX_WAIT_TIME}      900    # Maximum waiting time for all cells mapped on impacted shared RM to be enabled after RM reset
${GRACEFUL_CELL_SHUTDOWN}      True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22472
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case to perform shared RMOD reset from secondary controller with TRM feature, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get BTS primary controller and BTS secondary controller role; if primary controller role is shared (a BTS is primary controller for
    ...  some shared RMOD and secondary controller for other shared RMOD), test will perform shared RMOD reset from secondary controller with
    ...  TRM feature accordingly
    ...  - check feature CB007878 status on both BTS, and enable it if needed
    ...  - perform power OFF operation on BTS primary controller
    ...  - check TRM feature on BTS secondary controller
    ...  - perform reset shared RMOD operation on BTS secondary controller checking states and alarms
    ...  - perform power ON operation on BTS primary controller checking states and alarms on both BTS
    ...  - check reset behavior on both BTS based on IMS info:
    ...    - BTS primary controller: reset number is 1
    ...    - BTS secondary controller: reset number is 0
    ...  Pass criteria: shared RMOD reset from secondary controller with TRM feature works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 10.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22472 - [5G] SBTS_SBTS__STATE_BTS's_Common_startup_Check_TRM
    ...  - 24.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23074 -
    ...  [5G] Adapt SBTS_SBTS__STATE_Shared RU reset from Secondary Controller_TRM for CPRI+eCPRI RMOD configuration
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23368 -
    ...  [Cloud][Pilot robotws][PyLibraries] Drop "hran-tools" library KWs used by RFS TCs
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24676 - [5G] Update scenarios to take reset number from ims2 -RM Reset,
    ...  Power off/on - SBTS_SBTS
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24666 - [5G] RM_OPERATION_TIME_INTERVAL mechanism update - SBTS_SBTS
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25415 - [5G][CB007437] SBTS-SBTS new behavior due to CB007437 :
    ...  SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
    ...  - 05.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26460 -
    ...  [5G][CB007184] SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature adapt for CB007184
    ...  - 13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26546 - [5G] Update automated scenarios related to shared RM reset for
    ...  CNI-103974 - 2xSBTS
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26878 - [5G] Correct alarm list names for ignored alarms in
    ...  SBTS_SBTS_SBTS__STATE__Primary_Controller_SharedRM_Reset_from_WEBEM
    ...  - 23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27700 -
    ...  [5G] SBTS_STATE_BTS1_BTS2_Common_Startup_Check_TRM_Feature SBTS_SBTS_STATE_Secondary_Controller_SharedRM_Reset_TRM_Feature TRM tests
    ...  to ignore DSS alarm
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28577 -
    ...  [5G] Refactor TCs to use value of scf parameters as read from scf without transforming inside KW: Check Parameter value from SCF -
    ...  actSharedRuIndControl, peerBtsActSharedRuIndControl
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22472_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature.png

    Set Tags    CA-STATE    OWNER-bogdan.vinereanu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R3

    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Step 5: Get BTS primary controller and BTS secondary controller role
    Step 6: Check feature CB007878 status on both BTS
    Step 7: Check PDU definition and reachability on BTS primary controller
    Step 8: Check TRM feature settings on BTS secondary controller
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Run Keyword If  '${BTS_secondary_controller}' in ['Master','Slave']
        ...  Shared RMOD reset with TRM feature on BTS secondary controller ${BTS_secondary_controller}
        ...  ELSE  Run Keywords
        ...  Shared RMOD reset with TRM feature on BTS secondary controller Master
        ...  AND  Shared RMOD reset with TRM feature on BTS secondary controller Slave
    END
    [Teardown]  Particular Teardown

Step ${index}: Check ${when} BTS ${alias} state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} state  console=True
    Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
    Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True

Step ${index}: Check ${when} BTS ${alias} alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} BTS ${alias} alarms  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Get BTS primary controller and BTS secondary controller role
    Log  Step ${index}: Get primary controller BTS and BTS secondary controller role  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave

    Sort List  ${Master_shared_RMOD_list}
    Sort List  ${Slave_shared_RMOD_list}
    Set Test Variable  ${Master_shared_RMOD_list}
    Set Test Variable  ${Slave_shared_RMOD_list}

    Get BTS primary controller shared RMOD list  Master
    Get BTS primary controller shared RMOD list  Slave
    Get BTS secondary controller shared RMOD list  Master
    Get BTS secondary controller shared RMOD list  Slave

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  Master  ${Slave_primary_controller_shared_RMOD_count} == 0  Slave  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'Master'  Slave  '${BTS_secondary_controller}' == 'Slave'  Master
    ...  BOTH

    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

Step ${index}: Check feature CB007878 status on both BTS
    [Documentation]
    ...  Check feature CB007878 status on both BTS and enable it if needed

    Log  Step ${index}: Check feature CB007878 status on both BTS  console=True
    Set Test Variable  ${Master_CB007878_check}  False
    Set Test Variable  ${Slave_CB007878_check}  False
    Check feature CB007878 status  Master
    Check feature CB007878 status  Slave
    Set Test Variable  ${Master_alarm_count}  0
    Set Test Variable  ${Slave_alarm_count}  0

Step ${index}: Check PDU definition and reachability on BTS primary controller
    [Documentation]
    ...  Helper Keyword used to check PDU definition and reachability

    Log  Step ${index}: Check PDU definition and reachability on BTS primary controller  console=True
    Run Keyword If  '${BTS_primary_controller}' in ['Master','Slave']
    ...  Check PDU definition and reachability  ${BTS_primary_controller}
    ...  ELSE  Run Keywords
    ...  Check PDU definition and reachability  Master
    ...  AND  Check PDU definition and reachability  Slave

Step ${index}: Check TRM feature settings on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings and set if needed new parameter values

    Log  Step ${index}: Check TRM feature settings on BTS secondary controller  console=True
    Run Keyword If  '${BTS_secondary_controller}' in ['Master','Slave']
    ...  Check TRM feature settings  ${BTS_secondary_controller}
    ...  ELSE  Run Keywords
    ...  Check TRM feature settings  Master
    ...  AND  Check TRM feature settings  Slave

Shared RMOD reset with TRM feature on BTS secondary controller ${alias}
    [Documentation]
    ...  Perform Shared RMOD reset with TRM feature on BTS secondary controller

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    Set Test Variable  ${alias}
    Set Test Variable  ${peer_alias}
    Log  =============================================================================  console=True
    Log  Perform shared RMOD reset with TRM feature on BTS secondary controller ${alias}  console=True
    Log  =============================================================================  console=True
    Step 9: Get shared RMOD Primary Link info before power OFF BTS primary controller
    Step 10: Perform power OFF BTS primary controller
    Step 11: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime
    Step 12: Perform shared RMOD reset on BTS secondary controller
    Step 13: Perform power ON BTS primary controller
    Step 14: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime
    Step 15: Check final BTS Master state
    Step 16: Check final BTS Slave state
    Step 17: Check final BTS Master alarms
    Step 18: Check final BTS Slave alarms
    Step 19: Check BTS reset behavior based on IMS info
    Step 20: Check final number and state of Cells and RMs
    Step 21: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD

Step ${index}: Get shared RMOD Primary Link info before power OFF BTS primary controller
    [Documentation]
    ...  Get shared RMOD Primary Link info before power OFF BTS primary controller

    [Timeout]  15 min
    Log  Step ${index}: Get shared RMOD Primary Link info before power OFF BTS primary controller  console=True
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

        Set Test Variable  ${${alias}_PL_CPRI_shared_RMOD_count}  ${BTS_PL_CPRI_shared_RMOD_count}
        Set Test Variable  ${${alias}_PL_ECPRI_shared_RMOD_count}  ${BTS_PL_ECPRI_shared_RMOD_count}
    END

Step ${index}: Perform power ${power} BTS primary controller
    [Documentation]
    ...  Keyword used to power OFF/ON BTS primary controller

    Log  Step ${index}: Perform power ${power} BTS primary controller  console=True
    ${key_fsm}=  Set Variable  ${peer_alias.lower()}_fsm
    Run Keyword If  '${power}' == 'ON'
    ...  Pdu BTS Interface On  ${key_fsm}
    ...  ELSE IF  '${power}' == 'OFF'  Run Keywords
    ...  Get Current Date UTC info  start
    ...  AND  Pdu BTS Interface Off  ${key_fsm}
    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${key_fsm}
    Run Keyword If  '${PDU_port_status}' == '${power.lower()}'
    ...  Log Long String  BTS ${peer_alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  switched ${PDU_port_status}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  BTS ${peer_alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  switched ${PDU_port_status}, not as expected!
    ...  AND  Fail  Operation failed!
    Run Keyword If  '${power}' == 'OFF'  Run Keywords
    ...  Log  Check alarms on BTS secondary controller  console=True
    ...  AND  Check BTS secondary controller alarms
    Run Keyword If  '${power}' == 'ON'  Run Keywords
    ...  Get Current Time  bts_initial
    ...  AND  Log  Power ON BTS ${peer_alias} time is: ${time_bts_initial}  console=True
    ...  AND  Wait for BTS primary controller Startup
    ...  AND  Get Current Date UTC info  end

Step ${index}: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime

    Log  Step ${index}: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime  console=True
    ${SBTS_EXPECTED_ALARMS_4220_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4220}
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}
    Set Test Variable  ${SBTS_EXPECTED_ALARMS_4220_full}
    ${SBTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_X2}

    Log  Wait tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime} min for BTS ${alias} TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterTriggerTime} min

    Log  Check alarms and states on BTS ${alias}  console=True
    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${SBTS_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4220_full}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Step ${index}: Perform shared RMOD reset on BTS secondary controller
    Log  Step ${index}: Perform shared RMOD reset on BTS secondary controller  console=True
    FOR  ${item}  IN  @{${alias}_secondary_controller_shared_RMOD_list}
        Reset RMOD  ${item}
    END

Step ${index}: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime
    [Documentation]
    ...  Keyword is used to check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime

    Log  Step ${index}: Check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime  console=True
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled

    Log  Wait tempRadioMasterRecovTime=${tempRadioMasterRecovTime} min for BTS ${alias} TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterRecovTime} min

    Log  Check alarms and states on BTS ${alias}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    Log  All BTS ${alias} cell(s) - ${CELL_state_enabled}  console=True

    Log  Check alarms and states on BTS ${peer_alias}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${${peer_alias.upper()}_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${IGNORED_ALARMS_full}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${peer_alias}
    Log  All BTS ${peer_alias} cell(s) - ${CELL_state_enabled}  console=True

Step ${index}: Check BTS reset behavior based on IMS info
    [Documentation]
    ...  BTS reset info is checked based on IMS info.
    ...  Reset behavior as expected in following conditions:
    ...   - BTS primary controller: reset number is 1
    ...   - BTS secondary controller: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior based on IMS info  console=True
    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${peer_alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${alias}  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}

Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get BTS primary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=${alias}
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_RMOD_list}
       Run Keyword If  '${item}' in ${${alias}_shared_RMOD_list}
        ...  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_list}  ${BTS_primary_controller_shared_RMOD_list}
    Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_list}  console=True
    ${BTS_primary_controller_shared_RMOD_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_count}  ${BTS_primary_controller_shared_RMOD_count}

Get BTS secondary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS_secondary_controller_shared_RMOD_list}=  Copy List  ${${alias}_shared_RMOD_list}
    FOR  ${item}  IN  @{${alias}_primary_controller_shared_RMOD_list}
        Remove Values From List  ${BTS_secondary_controller_shared_RMOD_list}  ${item}
    END
    Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_list}  ${BTS_secondary_controller_shared_RMOD_list}

Check feature CB007878 status
    [Arguments]  ${alias}
    Log  Check feature CB007878 status on BTS ${alias}:  console=True
    ${RMOD_id_actSharedRUIndControl_initial_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
         ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${item}  ${alias}
         Set To Dictionary  ${RMOD_id_actSharedRUIndControl_initial_dict}  ${item}  ${actSharedRUIndControl}
         Log  BTS ${alias} shared RMOD ${item} feature CB007878 status:  console=True
         Log  - parameter actSharedRUIndControl = ${actSharedRUIndControl}  console=True
         Run Keyword If  '${actSharedRUIndControl}' == 'false'  Run Keywords
         ...  Log  Need to set parameter actSharedRUIndControl = true  console=True
         ...  AND  Set actSharedRUIndControl parameter value  ${item}  true  ${alias}
         ...  ELSE
         ...  Log  Parameter actSharedRUIndControl = true already set, no action needed!  console=True
    END
    Set Test Variable  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${RMOD_id_actSharedRUIndControl_initial_dict}
    Set Test Variable  ${${alias}_CB007878_check}  True

Check PDU definition and reachability
    [Documentation]
    ...  Helper Keyword used to check PDU definition and reachability

    [Arguments]  ${alias}
    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${alias.lower()}_fsm
    Run Keyword if  '${PDU_port_status}' == 'on'
    ...  Log Long String  BTS ${alias} outlet  ${INTERFACES['${alias.lower()}_fsm']['OUTLET']} on ${INTERFACES['${alias.lower()}_fsm']['IP']}
    ...  switched ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log  PDU for BTS ${alias} is either not reachable or not switched on!  level=ERROR
    ...  AND  Fail  PDU for BTS ${alias} is either not reachable or not switched on!

Check TRM feature settings
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings and set if needed new parameter values

    [Arguments]  ${alias}
    Log  Check TRM feature settings on BTS secondary controller ${alias} and set accordingly if needed  console=True
    ${actTempRadioMaster_initial}=  Get Activate Temporary Radio Master Role From Slave BTS  BTS_scf=${${alias.lower()}_scf_initial}  alias=${alias}
    ${tempRadioMasterRecovTime_initial}  ${tempRadioMasterTriggerTime_initial}=
    ...  Get Activate Temporary Radio Master Timers From Slave BTS  BTS_scf=${${alias.lower()}_scf_initial}  alias=${alias}
    Set Test Variable  ${${alias}_actTempRadioMaster_initial}  ${actTempRadioMaster_initial}
    Set Test Variable  ${${alias}_tempRadioMasterTriggerTime_initial}  ${tempRadioMasterTriggerTime_initial}
    Set Test Variable  ${${alias}_tempRadioMasterRecovTime_initial}  ${tempRadioMasterRecovTime_initial}
    Set Activate Temporary Radio Master Role From Slave BTS  BTS_scf=${${alias.lower()}_scf_initial}
    ...  actTempRadioMaster=true  alias=${alias}
    Set Activate Temporary Radio Master Timers On Slave BTS  BTS_scf=${${alias.lower()}_scf_initial}
    ...  tempRadioMasterRecovTime=${tempRadioMasterRecovTime}
    ...  tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime}  alias=${alias}
    Log Long String  Test will be performed with TRM feature settings on BTS secondary controller ${alias}: actTempRadioMaster: true,
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}  console=True

Check BTS secondary controller alarms
    ${SBTS_EXPECTED_ALARMS}=  Create List
    ${SBTS_EXPECTED_ALARMS_10_1815_4773_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_10_1815_4773}
    ...  ${${peer_alias}_PL_CPRI_shared_RMOD_count}
    ${SBTS_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_16}
    ...  ${${peer_alias}_PL_ECPRI_shared_RMOD_count}
    ${SBTS_EXPECTED_ALARMS_10_1815_4773_16_full}=  Combine Lists  ${SBTS_EXPECTED_ALARMS_10_1815_4773_full}  ${SBTS_EXPECTED_ALARMS_16_full}
    ${condition}=  Create Long String  (${${peer_alias}_PL_CPRI_shared_RMOD_count} == 0 and
    ...  ${${peer_alias}_PL_ECPRI_shared_RMOD_count} == 0)
    ${SBTS_EXPECTED_ALARMS}=  Set Variable If  ${condition}  ${SBTS_EXPECTED_ALARMS}  ${SBTS_EXPECTED_ALARMS_10_1815_4773_16_full}
    ${SBTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_X2}

    Run Keyword If  ${${peer_alias}_PL_CPRI_shared_RMOD_count} > 0
    ...  Log Long String  BTS ${alias}  "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815) or Radio unit reset triggered
    ...  by peer BTS (4773)" alarm, expected number:  ${${peer_alias}_PL_CPRI_shared_RMOD_count}  console=True
    Run Keyword If  ${${peer_alias}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log Long String  BTS ${alias}  "Unit synchronization failed (16)" alarm, expected number:
    ...  ${${peer_alias}_PL_ECPRI_shared_RMOD_count}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${SBTS_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${SBTS_EXPECTED_ALARMS}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${peer_alias}_PL_CPRI_shared_RMOD_count} > 0
    ...  Log Long String  BTS ${alias} "No connection to Unit (10)" or "Not able to synchronize baseband bus (1815) or Radio unit reset triggered
    ...  by peer BTS (4773)" alarm, found number:  ${${peer_alias}_PL_CPRI_shared_RMOD_count}, as expected!  console=True
    Run Keyword If  ${${peer_alias}_PL_ECPRI_shared_RMOD_count} > 0
    ...  Log Long String  BTS ${alias} "Unit synchronization failed (16)" alarm, found number:
    ...  ${${peer_alias}_PL_ECPRI_shared_RMOD_count}, as expected!  console=True

Reset RMOD
    [Arguments]  ${RMOD_id}
    ${new_alias}=  Set Variable  resetRMOD
    ${RM_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    ${RM_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RM_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    ${RM_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${RMOD_sn}=  Get From Dictionary  ${${alias}_module_ID_SN_dict}  ${RMOD_id}

    Log  Perform "Reset" operation on shared RMOD with id ${RMOD_id} from BTS secondary controller ${alias}  console=True
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}
    Get Current Time  initial
    ${reset_info}=  RFS RM Reset  dist_name=${RMOD_id}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Sleep  10s

    Log  Check BTS ${alias} state and alarm during reset shared RMOD with id ${RMOD_id}:  console=True
    Log  Check BTS ${alias} shared RMOD with id ${RMOD_id} state:  console=True
    Check shared RM state  ${RMOD_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    Check BTS alarms during shared RM reset  ${alias}

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check BTS ${alias} state and alarm after reset shared RMOD with id ${RMOD_id}:  console=True
    Log  Check BTS ${alias} shared RMOD with id ${RMOD_id} state:  console=True
    Check shared RM state  ${RMOD_id}  ${RM_state_enabled_check}  ${RM_state_enabled}  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    ${SBTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_X2}

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${SBTS_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4220_full}
    ...  ignored_alarms=${IGNORED_ALARMS_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD
    Log  Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD  console=True
    Get Current Time  final
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final}  ${time_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${RM_RESET_TIME_INTERVAL}-${time_elapsed_final}
    Run Keyword If  ${remained_time} > 0  Run Keywords
    ...  Log  Time interval between Reset RMOD operations: ${RM_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec

Wait for BTS primary controller Startup
    Run Keyword If  '${peer_alias}' == 'Master'
    ...  Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    ...  ELSE IF  '${peer_alias}' == 'Slave'
    ...  Wait For Target To Be Reachable TAF  hostname=${SLAVE['SLAVE_TECH_IP_ADDRESS']}  remote_host=${SLAVE['SLAVE_PC_IP_ADDRESS']}  timeout=180
    Sleep  1 min

Check shared RM state
    [Arguments]  ${RMOD_id}  ${RMOD_state_check}  ${RMOD_state}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RMOD ${RMOD_id} status:\n - ${RMOD_state}  console=True

Check BTS alarms during shared RM reset
    [Arguments]  ${alias}

    ${SBTS_IGNORED_ALARMS}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_X2}

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}  console=True
    ${IGNORED_ALARMS_full}=  Combine Lists  ${SBTS_IGNORED_ALARMS}  ${DSS_IGNORED_ALARMS}

    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4220_full}  ignored_alarms=${IGNORED_ALARMS_full}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Log Long String  BTS ${alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${peer_alias}_primary_controller_shared_RMOD_count}, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Recover initial settings for TRM feature
    [Documentation]
    ...  Keyword used to recover initial settings for TRM feature

    [Arguments]  ${alias}
    ${actTempRadioMaster_final}=  Get Activate Temporary Radio Master Role From Slave BTS  alias=${alias}
    Run Keyword If  '${actTempRadioMaster_final}' != '${${alias}_actTempRadioMaster_initial}'
    ...  Set Activate Temporary Radio Master Role From Slave BTS  actTempRadioMaster=${${alias}_actTempRadioMaster_initial}  alias=${alias}
    ${tempRadioMasterRecovTime_final}  ${tempRadioMasterTriggerTime_final}=
    ...  Get Activate Temporary Radio Master Timers From Slave BTS  alias=${alias}
    ${cond_first}=  Set Variable If  '${tempRadioMasterRecovTime_final}' != '${${alias}_tempRadioMasterRecovTime_initial}'  True  False
    ${cond_second}=  Set Variable If  '${tempRadioMasterTriggerTime_final}' != '${${alias}_tempRadioMasterTriggerTime_initial}'  True  False
    Run Keyword If  '${cond_first}' == 'True' or '${cond_second}' == 'True'
    ...  Set Activate Temporary Radio Master Timers On Slave BTS
    ...  tempRadioMasterRecovTime=${${alias}_tempRadioMasterRecovTime_initial}
    ...  tempRadioMasterTriggerTime=${${alias}_tempRadioMasterTriggerTime_initial}  alias=${alias}

Recover initial settings for feature CB007878
    [Arguments]  ${alias}
    Log  Recover initial settings for feature CB007878 on BTS ${alias}:  console=True
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
        ${actSharedRUIndControl_initial}=  Get From Dictionary  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${item}
        ${actSharedRUIndControl_final}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${item}  ${alias}
        Run Keyword If  '${actSharedRUIndControl_final}' == '${actSharedRUIndControl_initial}'  Continue For Loop
        Set actSharedRUIndControl parameter value  ${item}  ${actSharedRUIndControl_initial}  ${alias}
    END

Particular Teardown
    Run Keyword If  '${BTS_primary_controller}' in ['Master','Slave']
    ...  Check if PDU port status is on  ${BTS_primary_controller.lower()}_fsm
    ...  ELSE  Run Keywords
    ...  Check if PDU port status is on  master_fsm
    ...  AND  Check if PDU port status is on  slave_fsm
    Run Keyword If  '${BTS_secondary_controller}' in ['Master','Slave']
    ...  Recover initial settings for TRM feature  ${BTS_secondary_controller}
    ...  ELSE  Run Keywords
    ...  Recover initial settings for TRM feature  Master
    ...  AND  Recover initial settings for TRM feature  Slave
    Run Keyword If  ${Master_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Master
    Run Keyword If  ${Slave_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Slave

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
