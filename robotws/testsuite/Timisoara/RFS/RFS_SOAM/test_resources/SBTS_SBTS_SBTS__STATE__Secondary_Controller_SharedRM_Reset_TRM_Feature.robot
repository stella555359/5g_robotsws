*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
Variables    tc_variables/sbts_sbts_sbts__state__secondary_controller_shared_rm_reset_trm_feature_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                3      # Number of shared RM reset operations from secondary controller with TRM feature, default value 3
${SHARED_RM_SERIAL_NUMBER_LIST}  ALL    # Shared RM serial number list on which reset operation will be performed. Possible values: ALL (operation
                                        # will be performed on all shared RM) or list of selected shared RM serial number separated by comma.
                                        # By default ALL.
${tempRadioMasterTriggerTime}    2      # Integer value for tempRadioMasterTriggerTime to be commissioned
${tempRadioMasterRecovTime}      2      # Integer value for tempRadioMasterRecovTime to be commissioned
${RM_RESET_MAX_WAIT_TIME}        900    # Maximum waiting time for all cells mapped on impacted shared RM to be enabled after RM reset
${RM_RESET_TIME_INTERVAL}        480    # Time interval between reset RM, default value 480 seconds.
${GRACEFUL_CELL_SHUTDOWN}        True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23776
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS test case for shared RM reset from BTS secondary controller with TRM feature, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info, RAT cells (per BTS alias)
    ...  - check feature CB007878 status on requested shared RM, and enable it if needed
    ...  - perform power OFF operation on BTS primary controller
    ...  - check TRM feature on BTS secondary controller
    ...  - perform reset shared RM operation on BTS secondary controller checking states and alarms
    ...  - perform power ON operation on BTS primary controller checking states and alarms
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: reset shared RM operation from secondary controller with TRM feature works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 05.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23776 -
    ...  [5G][CB007588]SBTS_SBTS_SBTS_RF_Share_RM_Reset_from_secondaryController_with_TRM_WEBEM_ASOE
    ...  - 13.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24683 - [5G] Ignore alarm FID7107, AID7114 from SBTS_SBTS_SBTS tests
    ...  - 22.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24665 - [5G] RM_OPERATION_TIME_INTERVAL mechanism update - SBTS_SBTS_SBTS
    ...  - 15.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26595 - [5G] Add check for BTS state in TCs with Power on / unlock / unblock /
    ...  commissioning in Particular Teardown
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28577 -
    ...  [5G] Refactor TCs to use value of scf parameters as read from scf without transforming inside KW: Check Parameter value from SCF -
    ...  actSharedRuIndControl, peerBtsActSharedRuIndControl
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23776_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_TRM_Feature.png

    Set Tags    CA-STATE    OWNER-adrian.ierulescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS23R1

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info
    Step 4: Check feature CB007878 status on shared RM from all BTS
    Step 5: Check PDU definition and reachability on BTS primary controller
    Step 6: Check TRM feature settings on BTS secondary controller
    FOR  ${CYCLE}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${CYCLE} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 7: Shared RM reset with TRM feature on BTS secondary controller
        Step 8: Check final all BTS state
        Step 9: Check final all BTS alarms
        Step 10: Check final number and state of Cells and RMs
        Step 11: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD
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
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${SBTS_${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all BTS info
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Run Keyword If  '${SHARED_RM_SERIAL_NUMBER_LIST}' != 'ALL'  Check shared RM serial number list
    Log  ==============================================================  console=True
    Log  Shared RM serial number list selected for power OFF/ON action: ${shared_RM_sn_list}  console=True
    Log  ==============================================================  console=True

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        ${BTS_primary_controller_shared_RM_sn_list_count}=  Get Length  ${BTS_primary_controller_shared_RM_sn_list}
        ${BTS_secondary_controller_shared_RM_sn_list_count}=  Get Length  ${BTS_secondary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list_count}  ${BTS_primary_controller_shared_RM_sn_list_count}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list_count}  ${BTS_secondary_controller_shared_RM_sn_list_count}
    END

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get shared RM info  ${RM_sn}  ${RM_bts-alias_list}
    END

Step ${index}: Check feature CB007878 status on shared RM from all BTS
    [Documentation]
    ...  Check feature CB007878 status on shared RM from all BTS and enable it if needed

    Log  Step ${index}: Check feature CB007878 status on shared RM from all BTS  console=True
    ${RM_sn_actSharedRUIndControl_initial_dict}=  Create Dictionary
    Set Test Variable  ${RM_sn_actSharedRUIndControl_initial_dict}
    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Check feature CB007878 status  ${RM_sn}  ${RM_bts-alias_list}
    END

Step ${index}: Check PDU definition and reachability on BTS primary controller
    [Documentation]
    ...  Check if PDU for RM are defined in config file

    Log  Step ${index}: Check PDU definition and reachability on BTS primary controller  console=True
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  Check PDU port status  ${alias}  on
    END

Step ${index}: Check TRM feature settings on BTS secondary controller
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings and set if needed new parameter values

    Log  Step ${index}: Check TRM feature settings on BTS secondary controller  console=True
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Check TRM feature settings  ${alias}
    END

Step ${index}: Shared RM reset with TRM feature on BTS secondary controller
    [Documentation]
    ...  Shared RM reset with TRM feature on BTS secondary controller

    Log  Step ${index}: Shared RM reset with TRM feature on BTS secondary controller  console=True
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  ${${alias}_BTS_primary_controller_shared_RM_sn_list}
        ...  Shared RM reset with TRM feature on BTS secondary controller  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD
    Log  Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD

    Get Current Time  final_checks
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final_checks}  ${time_start}  number
    ${remained_time}=  BuiltIn.Evaluate  ${RM_RESET_TIME_INTERVAL}-${time_elapsed_final}
    Run Keyword If  ${remained_time}>0  Run Keywords
    ...  Log  Time interval between Reset RM operations: ${RM_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec


Check shared RM serial number list
    ${SHARED_RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${SHARED_RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${SHARED_RM_SERIAL_NUMBER_LIST}=  Split String  ${SHARED_RM_SERIAL_NUMBER_LIST_strip}  ,
    ${shared_RM_sn_check}=  Set Variable  True
    ${shared_RM_SN_invalide_list}=  Create List
    FOR  ${item}  IN  @{SHARED_RM_SERIAL_NUMBER_LIST}
        ${shared_RM_sn_check}=  Set Variable If  '${item}' not in ${shared_RM_sn_list}  False  ${shared_RM_sn_check}
        Run Keyword If  '${item}' not in ${shared_RM_sn_list}  Append To List  ${shared_RM_sn_invalide_list}  ${item}
    END
    Run Keyword If  '${shared_RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected shared RM serial number values are not valid: ${shared_RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${SHARED_RM_SERIAL_NUMBER_LIST} from configured shared RM: ${RM_sn_shared_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${shared_RM_sn_list}  ${SHARED_RM_SERIAL_NUMBER_LIST}

Get shared RM info
    [Arguments]   ${RM_sn}  ${RM_bts-alias_list}
    Log  Shared RM with SN ${RM_sn} info:  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${BTS_role}=  Set Variable If  '${RM_sn}' in ${${alias}_BTS_primary_controller_shared_RM_sn_list}  Primary Controller
        ...  '${RM_sn}' in ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Secondary Controller
        Log  - BTS ${alias} role: ${BTS_role} -> RM id: ${RM_id}  console=True
    END

Check feature CB007878 status
    [Arguments]  ${RM_sn}  ${RM_bts-alias_list}
    Log  Shared RM with SN ${RM_sn} feature CB007878 status info:  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}
        ${actSharedRUIndControl}=  Convert To String  ${actSharedRUIndControl}
        Set To Dictionary  ${RM_sn_actSharedRUIndControl_initial_dict}  ${RM_sn}  ${actSharedRUIndControl}
        Log  - BTS ${alias} parameter actSharedRUIndControl = ${actSharedRUIndControl}  console=True
        Run Keyword If  '${actSharedRUIndControl}' == 'false'  Run Keywords
        ...  Log  Need to set parameter actSharedRUIndControl = true  console=True
        ...  AND  Set actSharedRUIndControl parameter value  ${RM_id}  true  ${alias}
        ...  ELSE
        ...  Log  Parameter actSharedRUIndControl = true already set, no action needed!  console=True
    Set Test Variable  ${${alias}_RM_sn_actSharedRUIndControl_initial_dict}  ${RM_sn_actSharedRUIndControl_initial_dict}
    END

Check PDU port status
    [Arguments]  ${alias}  ${status}

    ${key_fsm}=  Set Variable  ${alias.lower()}_fsm
    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${key_fsm}
    Run Keyword if  '${PDU_port_status}' == '${status}'
    ...  Log Long String  BTS ${alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  switched ${PDU_port_status}  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  BTS ${alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  not switched ${PDU_port_status}!  level=ERROR
    ...  AND  Fail  BTS ${alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']} not switched ${PDU_port_status}!

Check TRM feature settings
    [Documentation]
    ...  Helper Keyword used to check TRM feature settings and set if needed new parameter values

    [Arguments]  ${alias}
    Log  Check TRM feature settings on BTS ${alias} secondary controller and set accordingly if needed  console=True
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
    Log Long String  Test will be performed with TRM feature settings on BTS ${alias} secondary controller: actTempRadioMaster: true,
    ...  tempRadioMasterTriggerTime: ${tempRadioMasterTriggerTime}, tempRadioMasterRecovTime: ${tempRadioMasterRecovTime}  console=True

Shared RM reset with TRM feature on BTS secondary controller
    [Arguments]  ${alias}

    Perform power OFF/ON BTS primary controller  ${alias}  OFF
    FOR  ${RM_sn}  IN  @{${alias}_BTS_primary_controller_shared_RM_sn_list}
        Check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime  ${RM_sn}  ${alias}
    END
    FOR  ${RM_sn}  IN  @{${alias}_BTS_primary_controller_shared_RM_sn_list}
        Perform Shared RM reset on BTS secondary controller  ${RM_sn}  ${alias}
    END
    Perform power OFF/ON BTS primary controller  ${alias}  ON
    FOR  ${RM_sn}  IN  @{${alias}_BTS_primary_controller_shared_RM_sn_list}
        Check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime  ${RM_sn}  ${alias}
    END

Perform power OFF/ON BTS primary controller
    [Documentation]
    ...  Keyword used to power OFF/ON BTS primary controller
    [Arguments]  ${alias}  ${power}

    Run Keyword If  ${${alias}_BTS_primary_controller_shared_RM_sn_list} and '${power}' == 'OFF'
    ...  Power BTS  ${alias}  ${power}
    ...  ELSE IF  ${${alias}_BTS_primary_controller_shared_RM_sn_list} and '${power}' == 'ON'  Run Keywords
    ...  Power BTS  ${alias}  ${power}
    ...  AND  Wait for BTS Startup  ${alias}

Power BTS
    [Documentation]
    ...  Helper Keyword used to power ON/OFF BTS

    [Arguments]  ${alias}  ${power}

    Log  ***** Perform power ${power} BTS ${alias} primary controller *****  console=True

    ${key_fsm}=  Set Variable  ${alias.lower()}_fsm
    Run Keyword If  '${power}' == 'ON'
    ...  Pdu BTS Interface On  ${key_fsm}
    ...  ELSE IF  '${power}' == 'OFF'
    ...  Pdu BTS Interface Off  ${key_fsm}
    ${PDU_port_status}=  Pdu BTS Interface Get Status  ${key_fsm}
    Run Keyword If  '${PDU_port_status}' == '${power.lower()}'
    ...  Log Long String  BTS ${alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  switched ${PDU_port_status}, as expected!  console=True
    ...  ELSE  Run Keywords
    ...  Log Long String  BTS ${alias} outlet ${INTERFACES['${key_fsm}']['OUTLET']} on ${INTERFACES['${key_fsm}']['IP']}
    ...  switched ${PDU_port_status}, not as expected!
    ...  AND  Fail  Operation failed!
    Run Keyword If  '${power}' == 'ON'  Run Keywords
    ...  Get Current Time  bts_initial
    ...  AND  Log  Power ON BTS ${alias} time is: ${time_bts_initial}  console=True

Wait for BTS Startup
    [Documentation]
    ...  Keyword used to wait for BTS Startup
    [Arguments]  ${alias}

    Log  ***** Wait for BTS ${alias} primary controller Startup *****  console=True
    Run Keyword If  '${alias}' == 'Master'
    ...  Wait For Target To Be Reachable TAF  hostname=${MASTER['MASTER_TECH_IP_ADDRESS']}  timeout=180
    ...  ELSE
    ...  Wait For Target To Be Reachable TAF  hostname=${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ...  remote_host=${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]  timeout=180
    Get Current Time  sbts_startup
    Log  Startup BTS ${alias} time is: ${time_sbts_startup}  console=True
    Sleep  1 min

Check TRM feature behavior on BTS secondary controller related to tempRadioMasterTriggerTime
    [Arguments]  ${RM_sn}  ${alias}

    ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
    ${RM_peer_bts-alias_list}=  Copy List  ${RM_bts-alias_list}
    Remove Values From List  ${RM_peer_bts-alias_list}  ${alias}
    ${peer_alias}=  Get From List  ${RM_peer_bts-alias_list}  0

    Log  ***** Check TRM feature behavior on BTS ${peer_alias} secondary controller related to tempRadioMasterTriggerTime *****  console=True

    ${SBTS_EXPECTED_ALARMS_4220_full}=  Prepare expected alarms list  ${SBTS_${peer_alias.upper()}_EXPECTED_ALARMS_4220}
    ...  ${${peer_alias}_BTS_secondary_controller_shared_RM_sn_list_count}
    ${SBTS_IGNORED_ALARMS_FULL}=  Combine Lists  ${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}  ${SBTS_${peer_alias.upper()}_IGNORED_ALARMS_X2}
    Log  Wait tempRadioMasterTriggerTime=${tempRadioMasterTriggerTime} min for BTS ${peer_alias} TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterTriggerTime} min

    Log  Check states and alarms on BTS ${peer_alias}  console=True
    Log Long String  BTS ${peer_alias} "Radio slave has taken temporary radio master role (4220)" alarm, expected number:
    ...  ${${peer_alias}_BTS_secondary_controller_shared_RM_sn_list_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4220_full}
    ...  ignored_alarms=${SBTS_IGNORED_ALARMS_FULL}  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}
    Log Long String  BTS ${peer_alias} "Radio slave has taken temporary radio master role (4220)" alarm, found number:
    ...  ${${peer_alias}_BTS_secondary_controller_shared_RM_sn_list_count}, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Perform Shared RM reset on BTS secondary controller
    [Arguments]  ${RM_sn}  ${alias}

    ${RM_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RM_state_disabled}=  Set Variable
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RM_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RM_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked

    ${RM_primary_controller_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
    ${RM_secondary_controller_bts-alias_list}=  Copy List  ${RM_primary_controller_bts-alias_list}
    Remove Values From List  ${RM_secondary_controller_bts-alias_list}  ${alias}
    ${alias_secondary_controller}=  Get From List  ${RM_secondary_controller_bts-alias_list}  0
    ${RM_id_secondary_controller}=  Get From Dictionary  ${${alias_secondary_controller}_RM_sn_id_dict}  ${RM_sn}

    Log  ***** Perform "Reset" operation on shared RM with SN ${RM_sn} from BTS ${alias_secondary_controller} secondary controller *****  console=True

    ${new_alias}=  Set Variable  ${alias_secondary_controller}_resetRM
    Start new ADMIN instance  alias=${alias_secondary_controller}  new_alias=${new_alias}
    ...  connection_type=${connection_type_${alias_secondary_controller}}

    Get Current Time  start
    ${reset_info}=  RFS RM Reset  dist_name=${RM_id_secondary_controller}  timeout=600  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Sleep  3s

    Log  Check BTS ${alias_secondary_controller} state during reset shared RM with SN ${RM_sn}:  console=True
    Log  Check BTS ${alias_secondary_controller} shared RM status:  console=True
    Assert  class_name=RMOD  id=${RM_id_secondary_controller}  parameters=${RM_state_disabled_check}  timeout=60
    ...  connection=${alias_secondary_controller}
    Log  BTS ${alias_secondary_controller} shared RM with SN ${RM_SN} status:\n - ${RM_state_disabled}  console=True

    Collect Keyword Result  ${reset_info}  timeout=600

    Log  Check BTS ${alias_secondary_controller} state after reset shared RM with SN ${RM_sn}:  console=True
    Log  Check BTS ${alias_secondary_controller} shared RM status:  console=True
    Assert  class_name=RMOD  id=${RM_id_secondary_controller}  parameters=${RM_state_enabled_check}  timeout=360
    ...  connection=${alias_secondary_controller}
    Log  BTS ${alias_secondary_controller} shared RM with SN ${RM_SN} status:\n - ${RM_state_enabled}  console=True

    [Teardown]  Teardown Admin  alias=${new_alias}

Check TRM feature behavior on BTS secondary controller related to tempRadioMasterRecovTime
    [Arguments]  ${RM_sn}  ${alias}

    ${RM_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RM_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked

    ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
    ${RM_peer_bts-alias_list}=  Copy List  ${RM_bts-alias_list}
    Remove Values From List  ${RM_peer_bts-alias_list}  ${alias}
    ${peer_alias}=  Get From List  ${RM_peer_bts-alias_list}  0

    Log  ***** Check TRM feature behavior on BTS ${peer_alias} secondary controller related to tempRadioMasterRecovTime *****  console=True

    Log  Wait tempRadioMasterRecovTime=${tempRadioMasterRecovTime} min for BTS ${peer_alias} TRM feature reactivity  console=True
    Sleep  ${tempRadioMasterRecovTime} min

    Log  Check states and alarms on BTS ${peer_alias}  console=True

    Log  Check BTS ${peer_alias} alarms:  console=True
    Log  BTS ${peer_alias} expected alarm number: 0  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} found alarm number: 0, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${peer_alias} status:  console=True
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  600  ${peer_alias}
    Log  BTS ${peer_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
    Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${peer_alias}
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check the other BTS(s) states and alarms  console=True
    FOR  ${other_alias}  IN  @{alias_list}
        Continue For Loop If  '${other_alias}' == '${peer_alias}'

        Log  Check BTS ${other_alias} status:  console=True
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  180  ${other_alias}
        Log  BTS ${other_alias} site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True
        Admin Check all BTS cells expected states  ${CELL_state_enabled_check}  ${other_alias}
        Log  All BTS ${other_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

        Log  Check BTS ${other_alias} alarms:  console=True
        Log  BTS ${other_alias} expected alarm number: 0  console=True
        Get and Check Alarms SOAM  alias=${other_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_${other_alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${SBTS_${other_alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${other_alias} found alarm number: 0, as expected!  console=True
        Log  BTS ${other_alias} site - expected, ignored and critical alarms checked  console=True
    END

Check if all PDU port status is on
     FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  Check if PDU port status is on  ${alias.lower()}_fsm
     END

Recover initial settings for feature CB007878
    [Arguments]  ${RM_sn}  ${RM_bts-alias_list}
    Log  Recover initial settings for feature CB007878 on shared RM with SN ${RM_sn}  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actSharedRUIndControl_initial}=  Get From Dictionary  ${${alias}_RM_sn_actSharedRUIndControl_initial_dict}  ${RM_sn}
        ${actSharedRUIndControl_final}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}
        ${actSharedRUIndControl_final}=  Convert To String  ${actSharedRUIndControl_final}
        Run Keyword If  '${actSharedRUIndControl_final}' == '${actSharedRUIndControl_initial}'  Continue For Loop
        Set actSharedRUIndControl parameter value  ${item}  ${actSharedRUIndControl_initial}  ${alias}
    END

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

Particular Teardown
    Run Keyword And Continue On Failure  Check if all PDU port status is on
    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  ${RM_sn}  ${RM_bts-alias_list}
    END
    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}
        ...  Run Keyword And Continue On Failure  Recover initial settings for TRM feature  ${alias}
    END
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown