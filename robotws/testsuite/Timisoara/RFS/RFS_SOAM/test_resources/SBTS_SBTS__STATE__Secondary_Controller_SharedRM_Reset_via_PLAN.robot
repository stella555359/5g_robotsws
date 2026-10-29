*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN
Variables    tc_variables/sbts_sbts__state__secondary_controller_shared_rm_reset_via_plan_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of cycles to perform shared RMOD reset from secondary controller via plan, default value 3
${RM_RESET_TIME_INTERVAL}  480  # Time interval between reset RMOD, default value 480 seconds.
${RM_RESET_MAX_WAIT_TIME}  900  # Maximum waiting time for RM reset to be finished; default value 900 seconds
${CNI_103974}             True  # Flag to enable CNI-103974 behavior related to peer BTS alarms during shared RM reset. Possible values: True
                                # (new CNI-103974 FID4773 will be checked), False (legacy FID1815_FID10 will be checked). By default: True

*** Keywords ***
TC__SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22493
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case to perform shared RMOD reset from secondary controller via plan, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get BTS primary controller and BTS secondary controller role; if primary controller role is shared (a BTS is primary controller for
    ...  some shared RMOD and secondary controller for other shared RMOD), test will perform shared RMOD reset from secondary controller
    ...  - get initial feature CB007878 status on both BTS
    ...  - disable feature CB007878 status on both BTS if needed
    ...  - enable feature CB007878 status only on BTS secondary controller checking states and alarms
    ...  - perform reset shared RMOD via plan (failure case) on BTS secondary controller checking states and alarms
    ...  - enable feature CB007878 status on BTS primary controller checking states and alarms
    ...  - perform reset shared RMOD via plan (success case) on BTS secondary controller checking states and alarms
    ...  Pass criteria: shared RMOD reset via plan from secondary controller works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 21.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22493 -
    ...  [5G] SBTS_SBTS__STATE_check_FID4689_and_reset_RMOD_from_secondary_BTS_using_delta_plan
    ...  - 19.07.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23287 - [5G] Adapt
    ...  SBTS_SBTS__STATE_check_FID4689_and_reset_RMOD_from_secondary_BTS_using_delta_plan to new behaviour
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24666 - [5G] RM_OPERATION_TIME_INTERVAL mechanism update - SBTS_SBTS
    ...  - 11.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25623 - [5G][CB007437] Adapt
    ...  SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN for CB007437
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26546 - [5G] Update automated scenarios related to shared RM reset for
    ...  CNI-103974 - 2xSBTS
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26878 - [5G] Correct alarm list names for ignored alarms in
    ...  SBTS_SBTS_SBTS__STATE__Primary_Controller_SharedRM_Reset_from_WEBEM
    ...  - 04.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27017 - [5G] Add sleep 10s to avoid cell transitory states for RM_Reset - 2xSBTS
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27069 - [5G] Include new CNI-103974 mechanism in RM Reset - 2xSBTS
    ...  - after TAT-27087
    ...  - 13.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27469 - [5G] NRL__STATE__NR_RM_Reset_from_WEBEM fails when CNI_103974 flag is
    ...  set to False
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27624 -
    ...  [5G] Adapt RM Reset robots to allow exception while CNI-103974 mechanism is used - with TAT-27699
    ...  - 26.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28867 - Remove administrative state object in test-cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22493_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_via_PLAN.png

    Set Tags    CA-STATE    OWNER-ruxandra-alice.savescu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R3

    TC Preconditions
    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get both BTS info for configured items
    Step 4: Check initial feature CB007878 info on both BTS
    Step 5: Check BTS SCF object CMD info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Run Keyword If  '${BTS_secondary_controller}' in ['Master','Slave']
        ...  Shared RMOD reset via plan on BTS secondary controller ${BTS_secondary_controller}
        ...  ELSE  Run Keywords
        ...  Shared RMOD reset via plan on BTS secondary controller Master
        ...  AND  Shared RMOD reset via plan on BTS secondary controller Slave
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${CNI_103974}=  Set Variable  ${CNI_103974.title()}
    Set Test Variable  ${CNI_103974}

    Run Keyword If  '${CNI_103974}' not in ['True','False']  Run Keywords
    ...  Log  Please select a proper value for test argument \${CNI_103974}.  console=True
    ...  AND  Fail  Improper value for argument!

Step ${index}: Check ${when} both BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} both BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from admin

    [Timeout]  15 min
    Log  Step ${index}: Check ${when} both BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get both BTS info for configured items
    Log  Step ${index}: Get both BTS info for configured items  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_primary_controller_shared_RMOD_sn_list}  ${BTS_secondary_controller_shared_RMOD_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}

        ${BTS_primary_controller_shared_RMOD_count}=  Get Length  ${BTS_primary_controller_shared_RMOD_sn_list}
        Set Test Variable  ${${alias}_primary_controller_shared_RMOD_count}  ${BTS_primary_controller_shared_RMOD_count}
        Set Test Variable  ${${alias}_primary_controller_shared_RMOD_sn_list}  ${BTS_primary_controller_shared_RMOD_sn_list}
        Set Test Variable  ${${alias}_secondary_controller_shared_RMOD_sn_list}  ${BTS_secondary_controller_shared_RMOD_sn_list}

        Log  BTS ${alias} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_sn_list}  console=True
        Log  BTS ${alias} configured as secondary controller for: ${BTS_secondary_controller_shared_RMOD_sn_list}  console=True

        ${shared_RMOD_sn_list}=  Combine Lists  ${BTS_primary_controller_shared_RMOD_sn_list}  ${BTS_secondary_controller_shared_RMOD_sn_list}
        Set Test Variable  ${${alias}_shared_RMOD_sn_list}  ${shared_RMOD_sn_list}

        Get shared RM CELL dict  ${alias}
        Get BTS CELL list by RAT  ${alias}

        ${BTS_param}=  Get Parameters For All  class_name=BTS  connection=${alias}
        Set Test Variable  ${${alias}_btsId}  ${BTS_param[0].btsId}

    END

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  Master  ${Slave_primary_controller_shared_RMOD_count} == 0  Slave  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'Master'  Slave  '${BTS_secondary_controller}' == 'Slave'  Master
    ...  BOTH

    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}

        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get shared RM info  ${RM_sn}  ${RM_bts-alias_list}

    END

Step ${index}: Check initial feature CB007878 info on both BTS
    [Documentation]
    ...  Check initial feature CB007878 status on both BTS

    Log  Step ${index}: Check initial feature CB007878 status on both BTS  console=True
    Check initial feature CB007878 status  Master
    Check initial feature CB007878 status  Slave
    Set Test Variable  ${Master_alarm_count}  0
    Set Test Variable  ${Slave_alarm_count}  0
    Set Test Variable  ${Master_CB007878_check}  False
    Set Test Variable  ${Slave_CB007878_check}  False

Step ${index}: Disable feature CB007878 status on both BTS
    [Documentation]
    ...  Disable feature CB007878 status on both BTS

    Log  Step ${index}: Disable feature CB007878 status on both BTS  console=True
    Feature CB007878 commissionning on BTS  action=Disable  alias=Master  peer_alias=Slave  alarm_count=add
    Feature CB007878 commissionning on BTS  action=Disable  alias=Slave  peer_alias=Master  alarm_count=remove

Step ${index}: Check BTS SCF object CMD info
    [Documentation]
    ...  Check BTS SCF object CMD info

    Log  Step ${index}: Check BTS SCF object CMD info  console=True
    Run Keyword If  '${BTS_secondary_controller}' in ['Master','Slave']
    ...  Create BTS SCF object CMD via plan  ${BTS_secondary_controller}
    ...  ELSE  Run Keywords
    ...  Create BTS SCF object CMD via plan  Master
    ...  AND  Create BTS SCF object CMD via plan  Slave

Shared RMOD reset via plan on BTS secondary controller ${alias}
    [Documentation]
    ...  Perform Shared RMOD reset via plan on BTS secondary controller

    ${peer_alias}=  Set Variable If  '${alias}' == 'Master'  Slave  Master
    Set Test Variable  ${BTS_secondary_controller}  ${alias}
    Set Test Variable  ${BTS_primary_controller}  ${peer_alias}
    Log  =====================================================================  console=True
    Log  Perform shared RMOD reset via plan on BTS secondary controller ${BTS_secondary_controller}  console=True
    Log  =====================================================================  console=True
    Step 6: Disable feature CB007878 status on both BTS
    Step 7: Enable feature CB007878 on BTS secondary controller
    Step 8: Check shared RMOD reset via plan on BTS secondary controller - failure case
    Step 9: Enable feature CB007878 on BTS primary controller
    Step 10: Check shared RMOD reset via plan on BTS secondary controller - success case
    Step 11: Check final both BTS state
    Step 12: Check final both BTS alarms
    Step 13: Check final number and state of Cells and RMs
    Step 14: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD

Step ${index}: Enable feature CB007878 on BTS ${role} controller
    [Documentation]
    ...  Enable feature CB007878 on BTS primary or secondary controller checking states and alarms on both BTS

    Log  Step ${index}: Enable feature CB007878 on BTS ${role} controller  console=True

    Run Keyword If  '${role}' == 'secondary'
    ...  Feature CB007878 commissionning on BTS  action=Enable  alias=${BTS_secondary_controller}  peer_alias=${BTS_primary_controller}
    ...  alarm_count=add
    ...  ELSE IF  '${role}' == 'primary'
    ...  Feature CB007878 commissionning on BTS  action=Enable  alias=${BTS_primary_controller}  peer_alias=${BTS_secondary_controller}
    ...  alarm_count=remove

Step ${index}: Check shared RMOD reset via plan on BTS secondary controller - ${result} case
    [Documentation]
    ...  Check shared RMOD reset via plan on BTS secondary controller - failure or success case

    Log  Step ${index}: Check shared RMOD reset via plan on BTS secondary controller - ${result} case  console=True

    Set Test Variable  ${HWRESETREQ_id}  0
    ${HWRESETREQ_dn_list}=  Get HWRESETREQ dn list  alias=${BTS_secondary_controller}
    Run Keyword If  ${HWRESETREQ_dn_list}  Remove BTS HWRESETREQ objects  ${BTS_secondary_controller}

    Set Test Variable  ${RM_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_disabled}  operationalState=Disabled, availabilityStatus=NotInstalled, administrativeState=Unlocked
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    FOR  ${RMOD_sn}  IN  @{${BTS_secondary_controller}_secondary_controller_shared_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${BTS_secondary_controller}_RM_sn_id_dict}  ${RMOD_sn}
        ${HWRESETREQ_id}=  Evaluate  ${HWRESETREQ_id} + 1
        ${targetHwResetUDN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${BTS_secondary_controller}

        Run Keyword If  '${result}' == 'failure'
        ...  Reset RMOD via PLAN - failure case  RMOD_sn=${RMOD_sn}  RMOD_id=${RMOD_id}  HWRESETREQ_id=${HWRESETREQ_id}
        ...  targetHwResetUDN=${targetHwResetUDN}  alias=${BTS_secondary_controller}
        ...  ELSE IF  '${result}' == 'success'
        ...  Reset RMOD via PLAN - success case  RMOD_sn=${RMOD_sn}  RMOD_id=${RMOD_id}  HWRESETREQ_id=${HWRESETREQ_id}
        ...  targetHwResetUDN=${targetHwResetUDN}  alias=${BTS_secondary_controller}

    END

Step ${index}: Check ${when} number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check ${when} number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get shared RM info
    [Arguments]   ${RM_sn}  ${RM_bts-alias_list}

    Log  Shared RM with SN ${RM_sn} info:  console=True

    FOR  ${alias}  IN  @{RM_bts-alias_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${BTS_role}=  Set Variable If  '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list}  Primary Controller
        ...  '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list}  Secondary Controller
        Log  - BTS ${alias} role: ${BTS_role} -> RM id: ${RM_id}  console=True

    END

Get HWRESETREQ dn list
    [Arguments]    ${alias}

    ${scf_path}=  Admin Collect scf.xml with timestamp TAF  alias=${alias}
	${HWRESETREQ_dn_list}=  Get All Dist Names By Pattern from SCF  pattern=/HWRESETREQ-[\\d]+$  scf_path=${scf_path}  alias=${alias}

    [Return]    ${HWRESETREQ_dn_list}

Check initial feature CB007878 status
    [Arguments]  ${alias}

    Log  Check initial feature CB007878 status on BTS ${alias}:  console=True

    ${RMOD_id_actSharedRUIndControl_initial_dict}=  Create Dictionary

    FOR  ${RMOD_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RMOD_sn}
        ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RMOD_id}  ${alias}
        Set To Dictionary  ${RMOD_id_actSharedRUIndControl_initial_dict}  ${RMOD_id}  ${actSharedRUIndControl}
        Log  BTS ${alias} shared RMOD with SN ${RMOD_sn} feature CB007878 status:  console=True
        Log  - parameter actSharedRUIndControl = ${actSharedRUIndControl}  console=True

        Run Keyword If  '${actSharedRUIndControl}' == 'false'  Run Keywords
        ...  Log  Need to set parameter actSharedRUIndControl = true  console=True
        ...  AND  Set actSharedRUIndControl parameter value  ${RMOD_id}  true  ${alias}
        ...  ELSE
        ...  Log  Parameter actSharedRUIndControl = true already set, no action needed!  console=True

    END

    Set Test Variable  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${RMOD_id_actSharedRUIndControl_initial_dict}

Feature CB007878 commissionning on BTS
    [Documentation]
    ...  Enable or disable feature CB007878 on BTS Master or Slave checking states and alarms on both BTS

    [Arguments]  ${action}  ${alias}  ${peer_alias}  ${alarm_count}

    Log  ${action} feature CB007878 on BTS ${alias}  console=True

    ${value}=  Set Variable If  '${action}' == 'Enable'  true  '${action}' == 'Disable'  false

    FOR  ${RM_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        Log  ${action} feature CB007878 on shared RMOD with SN ${RM_sn} from BTS ${alias}  console=True

        Run Keyword If  '${action}' == 'Disable' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list}
        ...  Get and delete RMOD administrativeState parameter if needed  ${RM_id}  ${alias}

        Set actSharedRUIndControl parameter value  ${RM_id}  ${value}  ${alias}
        Set Test Variable  ${${alias}_CB007878_check}  True

        ${BTS_alarm_count}=  Run Keyword If  '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list}
        ...  Evaluate  ${${alias}_alarm_count} + 0
        ...  ELSE IF  '${action}' == 'Disable' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'add'
        ...  Evaluate  ${${alias}_alarm_count} + 0
        ...  ELSE IF  '${action}' == 'Enable' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'add'
        ...  Evaluate  ${${alias}_alarm_count} + 1
        ...  ELSE IF  '${action}' == 'Disable' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list} and '${alarm_count}'=='remove'
        ...  Evaluate  ${${alias}_alarm_count} - 1
        ...  ELSE IF  '${action}' == 'Enable' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'remove'
        ...  Evaluate  ${${alias}_alarm_count} - 0

        ${peer_BTS_alarm_count}=  Run Keyword If  ${${alias}_secondary_controller_shared_RMOD_sn_list}
        ...  Evaluate  ${${peer_alias}_alarm_count} + 0
        ...  ELSE IF  '${action}' == 'Disable' and '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'add'
        ...  Evaluate  ${${peer_alias}_alarm_count} + 1
        ...  ELSE IF  '${action}' == 'Enable' and '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'add'
        ...  Evaluate  ${${peer_alias}_alarm_count} + 0
        ...  ELSE IF  '${action}' == 'Disable' and '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'remove'
        ...  Evaluate  ${${peer_alias}_alarm_count} - 0
        ...  ELSE IF  '${action}' == 'Enable' and '${RM_sn}' in ${${alias}_primary_controller_shared_RMOD_sn_list} and '${alarm_count}' == 'remove'
        ...  Evaluate  ${${peer_alias}_alarm_count} - 1

        Set Test Variable  ${${alias}_alarm_count}  ${BTS_alarm_count}
        Set Test Variable  ${${peer_alias}_alarm_count}  ${peer_BTS_alarm_count}

        Check alarms on BTS  ${alias}
        Check alarms on BTS  ${peer_alias}

    END

Get and delete RMOD administrativeState parameter if needed
    [Arguments]    ${RMOD_id}  ${alias}

    ${RMOD_dn}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${alias}
    ${BTS_scf}=  rfs_admin.Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${administrativeState_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_scf}  dist_name=${RMOD_dn}
    ...  p_name=administrativeState

    ${status}  ${administrativeState}=  Run Keyword And Ignore Error
    ...  Get From Dictionary  ${administrativeState_info_dict}  administrativeState

    Run Keyword If  '${status}' == 'PASS'
    ...  coam.Perform Parameter Recommissioning  dist_name=${RMOD_dn}  parameter=administrativeState  operation=delete  value=none
    ...  skip_parameter_relation_errors=False  should_activate=True  connection=${alias}

Check alarms on BTS
    [Arguments]  ${alias}

    ${SBTS_EXPECTED_ALARMS_4689_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4689}
    ...  ${${alias}_alarm_count}

    Log Long String  BTS ${alias}  "Shared RU independent control unaligned between BTSs (4689)" alarm, expected number:
    ...  ${${alias}_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${SBTS_EXPECTED_ALARMS_4689_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log Long String  BTS ${alias} "Shared RU independent control unaligned between BTSs (4689)" alarm, found number:
    ...  ${${alias}_alarm_count}, as expected!  console=True

Remove BTS HWRESETREQ objects
    [Documentation]
    ...  Remove object(s) HWRESETREQ from Admin IM

    [Arguments]  ${alias}
    ${HWRESETREQ_dn_list}=  Get HWRESETREQ dn list  alias=${BTS_secondary_controller}
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id} =  Set Variable  Remove_HWRESETREQ_${timestamp}

    Create Delta  delta_id=${delta_id}
    FOR  ${HWRESETREQ_dn}  IN  @{HWRESETREQ_dn_list}
        Append Managed Object To Delta  dist_name=${HWRESETREQ_dn}  operation=delete  delta_id=${delta_id}
    END
    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    coam.Perform Delta Recommissioning  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True  alias=${alias}
    Remove Delta  delta_id=${delta_id}

Reset RMOD via PLAN - failure case
    [Documentation]
    ...  Reset RMOD via PLAN from Admin - failure case

    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${HWRESETREQ_id}  ${targetHwResetUDN}  ${alias}

    ${RMOD_id_peer}=  Get From Dictionary  ${${BTS_primary_controller}_RM_sn_id_dict}  ${RMOD_sn}
    ${RM_param_check}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}
    ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_CNI_103974_exceptions}  ${RM_param_check['productName']}
    Set Test Variable  ${RM_EXCEPTION}
    Log  Perform Reset shared RMOD with SN ${RMOD_sn} by recommissioning from BTS ${alias} secondary controller:  console=True

    ${HWRESETREQ_dn}=  Set Variable  MRBTS-${${alias}_btsId}/MNL-1/CMD-1/HWRESETREQ-${HWRESETREQ_id}
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_HWRESETREQ_${timestamp}

    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    Append Managed Object To Delta  dist_name=${HWRESETREQ_dn}  operation=create  delta_id=${delta_id}
    Log  Object ${HWRESETREQ_dn} appended to file ${delta_id}  console=True

    Append Parameter Update To Delta  dist_name=${HWRESETREQ_dn}  parameter=targetHwResetUDN
    ...  value=${targetHwResetUDN}  delta_id=${delta_id}
    Log  Parameter targetHwResetUDN=${targetHwResetUDN} appended to file ${delta_id}  console=True

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    ${msg}=  Run Keyword And Expect Error  *  coam.Perform Delta Recommissioning  delta_file=${delta_file}  skip_parameter_relation_errors=True
    ...  should_activate=True  connection=${alias}
    Should Contain  ${msg}
    ...  Shared RF module can't be reset via HWRESETREQ, because RMOD.actSharedRUIndControl or RMOD_R.peerActSharedRUIndControl is set to False
    Sleep  10s

    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} state and alarm after recommissioning (no RMOD reset):  console=True
    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} shared RMOD state:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RM_state_enabled_check}  timeout=10  connection=${BTS_secondary_controller}
    Log  BTS ${BTS_secondary_controller} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_enabled}  console=True
    Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RM_state_enabled_check}  timeout=10  connection=${BTS_primary_controller}
    Log  BTS ${BTS_primary_controller} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_enabled}   console=True

    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${BTS_secondary_controller}
    Log  All BTS ${BTS_secondary_controller} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${BTS_primary_controller}
    Log  All BTS ${BTS_primary_controller} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} alarm:  console=True
    Check alarms on BTS  Master
    Check alarms on BTS  Slave

    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

    Log  Reset shared RMOD with SN ${RMOD_sn} via plan result: failure, as expected  console=True

Reset RMOD via PLAN - success case
    [Documentation]
    ...  Reset RMOD via PLAN from Admin - success case

    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${HWRESETREQ_id}  ${targetHwResetUDN}  ${alias}

    ${RMOD_id_peer}=  Get From Dictionary  ${${BTS_primary_controller}_RM_sn_id_dict}  ${RMOD_sn}
    ${RM_param_check}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}
    ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_EXCEPTION_CNI_103974_list}  ${RM_param_check['productName']}
    Set Test Variable  ${RM_EXCEPTION}
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_L3_Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_id}
    Set Test Variable  ${RMOD_L3_Protocol}
    Get shared RM all cells from specific RAT  ${RMOD_sn}  ${BTS_secondary_controller}
    Get shared RM all cells from specific RAT  ${RMOD_sn}  ${BTS_primary_controller}

    Log  Perform Reset shared RMOD with SN ${RMOD_sn} by recommissioning from BTS ${alias} secondary controller:  console=True

    ${HWRESETREQ_dn}=  Set Variable  MRBTS-${${alias}_btsId}/MNL-1/CMD-1/HWRESETREQ-${HWRESETREQ_id}
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_HWRESETREQ_${timestamp}

    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    Append Managed Object To Delta  dist_name=${HWRESETREQ_dn}  operation=create  delta_id=${delta_id}
    Log  Object ${HWRESETREQ_dn} appended to file ${delta_id}  console=True

    Append Parameter Update To Delta  dist_name=${HWRESETREQ_dn}  parameter=targetHwResetUDN
    ...  value=${targetHwResetUDN}  delta_id=${delta_id}
    Log  Parameter targetHwResetUDN=${targetHwResetUDN} appended to file ${delta_id}  console=True

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    Get Current Time  initial
    coam.Perform Delta Recommissioning  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    Sleep  10s

    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} state and alarm after recommissioning (during RMOD reset):  console=True
    Run Keyword If  '${RMOD_L3_Protocol}' == 'CPRI_RP1'
    ...  Check states and alarms during shared CPRI RM reset  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${BTS_secondary_controller}
    ...  ${BTS_primary_controller}
    ...  ELSE IF  '${RMOD_L3_Protocol}' in ['ECPRI_MPLANE','RP301_RP1']
    ...  Check states and alarms during shared non CPRI RM reset  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${BTS_secondary_controller}
    ...  ${BTS_primary_controller}

    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} state and alarm after recommissioning (after RMOD reset):
    ...  console=True
    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} shared RMOD state:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RM_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${BTS_secondary_controller}
    Log  BTS ${BTS_secondary_controller} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RM_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${BTS_primary_controller}
    Log  BTS ${BTS_primary_controller} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_enabled}   console=True

    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${BTS_secondary_controller}
    Log  All BTS ${BTS_secondary_controller} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${BTS_primary_controller}
    Log  All BTS ${BTS_primary_controller} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${BTS_secondary_controller} and ${BTS_primary_controller} alarm:  console=True
    Get and Check Alarms SOAM  alias=${BTS_secondary_controller}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${BTS_secondary_controller.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${BTS_secondary_controller.upper()}_CRITICAL_ALARMS}
    Log  BTS ${BTS_secondary_controller} site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=${BTS_primary_controller}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${BTS_primary_controller.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${BTS_primary_controller.upper()}_CRITICAL_ALARMS}
    Log  BTS ${BTS_primary_controller} site - expected, ignored and critical alarms checked  console=True

    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

    Check BTS SCF object HWRESETRES and parameter hwResetResult info  ${HWRESETREQ_dn}  success  ${alias}
    Log  Reset shared RMOD with SN ${RMOD_sn} via plan result: success, as expected  console=True

Check states and alarms during shared CPRI RM reset
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}

    ${EXPECTED_ALARMS}=  Set Variable If  '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${${peer_alias.upper()}_EXPECTED_ALARMS_10_1815}

    Log  Check BTS ${alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RM_state_disabled_check}  timeout=${RM_RESET_MAX_WAIT_TIME}
    ...  connection=${alias}
    Log  BTS ${alias} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_disabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    ...  AND  Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RM_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${peer_alias}
    ...  AND  Log  BTS ${peer_alias} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_disabled}  console=True

    Log  Check peer BTS ${peer_alias} alarms:  console=True
    Run Keyword If  '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: 1  console=True
    ...  ELSE
    ...  Log  BTS ${peer_alias} "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${EXPECTED_ALARMS}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: 1, as expected!  console=True
    ...  ELSE
    ...  Log Long String  BTS ${peer_alias} "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, found number: 1,
    ...  as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${alias}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    ...  AND  Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${peer_alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${peer_alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${peer_alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${peer_alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${peer_alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Log  BTS ${peer_alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

Check states and alarms during shared non CPRI RM reset
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}

    ${EXPECTED_ALARMS}=  Set Variable If
    ...  '${RMOD_L3_Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}

    Log  Check BTS ${alias} and ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RM_state_disabled_check}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_disabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RM_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    Log  BTS ${peer_alias} RMOD with SN ${RMOD_sn} status:\n - ${RM_state_disabled}   console=True

    Log  Check peer BTS ${peer_alias} alarms:  console=True
    Run Keyword If  '${RM_L3Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: 1  console=True
    ...  ELSE  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${EXPECTED_ALARMS}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${RM_L3Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: 1, as expected!  console=True
    ...  ELSE  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, found number: 1, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${alias}

    Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on shared RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${peer_alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${peer_alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${peer_alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${peer_alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Run Keyword If  ${${peer_alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${peer_alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    Log  BTS ${peer_alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

Check cells state mapped on shared RM
    [Arguments]  ${alias}

    Run Keyword If  ${${alias}_NR_CELL_RM_list}  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RM_list}  alias=${alias}
    Run Keyword If  ${${alias}_LTE_CELL_RM_list}  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RM_list}  alias=${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RM_list}  alias=${alias}
    Run Keyword If  ${${alias}_GSM_CELL_RM_list}  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RM_list}  alias=${alias}

Get shared RM CELL dict
    [Arguments]   ${alias}

    ${shared_RM_CELL_id_dict}=  Create Dictionary

    FOR  ${RMOD_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RMOD_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RMOD_sn}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${alias}
        Sort List  ${CELL_list}
        Set To Dictionary  ${shared_RM_CELL_id_dict}  ${RMOD_id}  ${CELL_list}

    END

    Set Test Variable  ${${alias}_shared_RMOD_CELL_id_dict}  ${shared_RM_CELL_id_dict}

Get BTS CELL list by RAT
    [Arguments]  ${alias}

    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    ${CELL_list}=  Combine Lists   ${NR_CELL_list}  ${LTE_CELL_list}  ${WCDMA_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_NR_CELL_list}  ${NR_CELL_list}
    Set Test Variable  ${${alias}_LTE_CELL_list}  ${LTE_CELL_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_CELL_list}  ${CELL_list}

Get shared RM all cells from specific RAT
    [Arguments]  ${RM_sn}  ${alias}
    ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
    ${CELL_RM_list}=  Get From Dictionary  ${${alias}_shared_RMOD_CELL_id_dict}  ${RM_id}
    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RM_list} and '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RM_list}  ${item}
    END
    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_NR_CELL_RM_list}  ${NR_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_list}  ${LTE_CELL_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RM_list}  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_RM_list}  ${GSM_CELL_RM_list}

    Log  BTS ${alias} cells mapped on shared RM with SN ${RM_sn}:  console=True
    Run Keyword If  ${NR_CELL_RM_list}  Log  - NRCEL: ${NR_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_CELL_RM_list}  Log  - LNCEL: ${LTE_CELL_RM_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RM_list}  Log  - WNCEL: ${WCDMA_CELL_RM_list}  console=True
    Run Keyword If  ${GSM_CELL_RM_list}  Log  - GNCEL: ${GSM_CELL_RM_list}  console=True

    ${NR_CELL_not_RM_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${WCDMA_CELL_not_RM_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RM_list}=  Copy List  ${${alias}_GSM_CELL_list}
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
    Set Test Variable  ${${alias}_NR_CELL_not_RM_list}  ${NR_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD
    Log  Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RMOD  console=True

    Get Current Time  final
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final}  ${time_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${RM_RESET_TIME_INTERVAL}-${time_elapsed_final}

    Run Keyword If  ${remained_time} > 0  Run Keywords
    ...  Log  Time interval between Reset RMOD operations: ${RM_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec

Create BTS SCF object CMD via plan
    [Documentation]
    ...  Create BTS SCF object CMD via plan. If object already exists, return from KW

    [Arguments]  ${alias}
    ${Obj_dn}=  Set Variable  MRBTS-${${alias}_btsId}/MNL-1/CMD-1
    Log  Create BTS SCF object CMD via plan on BTS ${alias}:  console=True
    ${BTS_scf}=   Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${Obj_exists}=  Run Keyword And Return Status  Element Should Exist  ${BTS_scf_xml}  .//managedObject[@distName="${Obj_dn}"]
    Run Keyword If  ${Obj_exists}  Run Keywords
    ...  Log  BTS SCF object CMD already created: ${Obj_dn}, no action needed  console=True
    ...  AND  Return From Keyword
    ${year}  ${month}  ${day}  ${hour}  ${min}=  Get Time  format=year,month,day,hour,min
    ${timestamp}=  Set Variable  ${year}_${month}_${day}_${hour}_${min}
    ${delta_id}=  Set Variable  Create_Obj_${timestamp}

    Create Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} created  console=True

    Append Managed Object To Delta  dist_name=${Obj_dn}  operation=create  delta_id=${delta_id}
    Log  Object ${Obj_dn} appended to file ${delta_id}  console=True

    ${delta_file}=  coam.Get Delta  delta_id=${delta_id}
    Log  Perform Delta Recommissioning JSON file ${delta_id}  console=True
    coam.Perform Delta Recommissioning  delta_file=${delta_file}  skip_parameter_relation_errors=True  should_activate=True  connection=${alias}
    Sleep  10s

    Remove Delta  delta_id=${delta_id}
    Log  Delta Recommissioning JSON file ${delta_id} removed  console=True

    ${BTS_scf}=   Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${Obj_exists}=  Run Keyword And Return Status  Element Should Exist  ${BTS_scf_xml}  .//managedObject[@distName="${Obj_dn}"]
    Run Keyword If  ${Obj_exists}
    ...  Log  BTS SCF object CMD created: ${Obj_dn}   console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS SCF object CMD doesn't exist!  level=ERROR
    ...  AND  Fail  BTS SCF object CMD doesn't exist!  console=True

Check BTS SCF object HWRESETRES and parameter hwResetResult info
    [Documentation]
    ...  Check BTS SCF object HWRESETRES and parameter hwResetResult info.

    [Arguments]  ${HWRESETREQ_dn}  ${expected_hwResetResult}  ${alias}
    Log  Check BTS SCF object HWRESETRES and parameter hwResetResult info on BTS ${alias}:  console=True
    ${BTS_scf}=   Admin Collect scf.xml with timestamp TAF  alias=${alias}  export_type=configurationAndRuntimeObjects
    ${BTS_scf_xml}=  Parse xml  ${BTS_scf}
    ${HWRESETRES_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}  .//managedObject[@distName="${HWRESETREQ_dn}/HWRESETRES-1"]
    Run Keyword If  ${HWRESETRES_exists}
    ...  Log  BTS SCF object HWRESETRES created: ${HWRESETREQ_dn}/HWRESETRES-1  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS SCF object HWRESETRES doesn't exist!  level=ERROR
    ...  AND  Fail  BTS SCF object HWRESETRES doesn't exist!  console=True
    ${hwResetResult_exists}=  Run Keyword And Return Status
    ...  Element Should Exist  ${BTS_scf_xml}  .//managedObject[@distName="${HWRESETREQ_dn}/HWRESETRES-1"]/p[@name="hwResetResult"]
    Run Keyword If  not ${hwResetResult_exists}  Run Keywords
    ...  Log  BTS SCF parameter hwResetResult doesn't exist!  level=ERROR
    ...  AND  Fail  BTS SCF parameter hwResetResult doesn't exist!  console=True
    ${hwResetResult}=  Get Element Text  ${BTS_scf_xml}  .//managedObject[@distName="${HWRESETREQ_dn}/HWRESETRES-1"]/p[@name="hwResetResult"]
    Run Keyword If  '${hwResetResult}' == '${expected_hwResetResult}'
    ...  Log  BTS SCF parameter hwResetResult value: ${hwResetResult}  console=True
    ...  ELSE  Run Keywords
    ...  Log  BTS SCF parameter hwResetResult value: ${hwResetResult}  level=ERROR
    ...  AND  Fail  BTS SCF parameter hwResetResult value: ${hwResetResult}  console=True

Recover initial settings for feature CB007878
    [Arguments]  ${alias}

    Log  Recover initial settings for feature CB007878 on BTS ${alias}:  console=True

    FOR  ${RM_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actSharedRUIndControl_initial}=  Get From Dictionary  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${RM_id}
        ${actSharedRUIndControl_final}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}

        Run Keyword If  '${actSharedRUIndControl_final}' == '${actSharedRUIndControl_initial}'  Continue For Loop

        Set actSharedRUIndControl parameter value  ${RM_id}  ${actSharedRUIndControl_initial}  ${alias}

    END

Particular Teardown
    Run Keyword If  ${Master_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Master
    Run Keyword If  ${Slave_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Slave

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
