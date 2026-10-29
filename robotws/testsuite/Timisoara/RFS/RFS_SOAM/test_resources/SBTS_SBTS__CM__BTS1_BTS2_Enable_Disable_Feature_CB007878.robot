*** Settings ***
Documentation    TC__SBTS_SBTS__CM__BTS1_BTS2_Enable_Disable_Feature_CB007878
Variables    tc_variables/sbts_sbts__cm__bts1_bts2_enable_disable_feature_CB007878_on_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3  # Number of cycles to perform enable/disable feature CB007878 on both BTS, default value 3

*** Keywords ***
TC__SBTS_SBTS__CM__BTS1_BTS2_Enable_Disable_Feature_CB007878
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-22563
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case to perform enable/disable feature CB007878 on both BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get shared RMOD info
    ...  - check feature CB007878 status on both BTS, and disable it if needed
    ...  - enable feature CB007878 on BTS BTS1, checking states and alarms on both BTS
    ...  - enable feature CB007878 on BTS BTS2, checking states and alarms on both BTS
    ...  - disable feature CB007878 on BTS BTS1, checking states and alarms on both BTS
    ...  - disable feature CB007878 on BTS BTS2, checking states and alarms on both BTS
    ...  Pass criteria: enable/disable feature CB007878 on both BTS works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 07.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22563 -
    ...  [5G] SBTS_SBTS: RFS_BTS_LTE-LTE_Recommision_BTS1 Feature activation_then BTS2 Feature activation
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28577 -
    ...  [5G] Refactor TCs to use value of scf parameters as read from scf without transforming inside KW: Check Parameter value from SCF -
    ...  actSharedRuIndControl, peerBtsActSharedRuIndControl
    ...  - 26.03.2025- https://jiradc.ext.net.nokia.com/browse/TAT-28867 - Remove administrative state object in test-cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-22563_SBTS_SBTS__CM__Both_BTS_Enable_Disable_Feature_CB007878.png

    Set Tags    CA-STATE    OWNER-adina.asproiu@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R3

    Step 1: Check initial both BTS state
    Step 2: Check initial both BTS alarms
    Step 3: Get shared RMOD info
    Step 4: Check feature CB007878 status on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Enable feature CB007878 on both BTS
        Step 6: Check after enable feature CB007878 both BTS state
        Step 7: Check after enable feature CB007878 both BTS alarms
        Step 8: Check after enable feature CB007878 number and state of Cells and RMs
        Step 9: Disable feature CB007878 on both BTS
        Step 10: Check final both BTS state
        Step 11: Check final both BTS alarms
        Step 12: Check final number and state of Cells and RMs
    END
    [Teardown]  Particular Teardown

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

Step ${index}: Get shared RMOD info
    [Documentation]
    ...  BTS info are related to shared RMOD

    Log  Step ${index}: Get shared RMOD info  console=True

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

Step ${index}: Check feature CB007878 status on both BTS
    [Documentation]
    ...  Check feature CB007878 status on both BTS and disable it if needed

    Log  Step ${index}: Check feature CB007878 status on both BTS  console=True

    Set Test Variable  ${Master_CB007878_check}  False
    Set Test Variable  ${Slave_CB007878_check}  False
    Check feature CB007878 status  Master
    Check feature CB007878 status  Slave
    Set Test Variable  ${Master_alarm_count}  0
    Set Test Variable  ${Slave_alarm_count}  0

Step ${index}: ${Action} feature CB007878 on both BTS
    [Documentation]
    ...  Enable or disable feature CB007878 on both BTS checking states and alarms on both BTS

    Log  Step ${index}: ${Action} feature CB007878 on both BTS  console=True

    ${value}=  Set Variable If  '${action}' == 'Enable'  true  '${action}' == 'Disable'  false

    Feature CB007878 commissionning on BTS  action=${Action}  alias=Master  peer_alias=Slave  alarm_count=add
    Feature CB007878 commissionning on BTS  action=${Action}  alias=Slave  peer_alias=Master  alarm_count=remove

    Check peerBtsActSharedRUIndControl parameter value on BTS  ${value}  Master
    Check peerBtsActSharedRUIndControl parameter value on BTS  ${value}  Slave

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

Check feature CB007878 status
    [Arguments]  ${alias}

    Log  Check feature CB007878 status on BTS ${alias}:  console=True
    ${RMOD_id_actSharedRUIndControl_initial_dict}=  Create Dictionary

    FOR  ${RM_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}
        Set To Dictionary  ${RMOD_id_actSharedRUIndControl_initial_dict}  ${RM_id}  ${actSharedRUIndControl}

        Run Keyword If  '${actSharedRUIndControl}' == 'true' and '${RM_sn}' in ${${alias}_secondary_controller_shared_RMOD_sn_list}
        ...  Get and delete RMOD administrativeState parameter if needed  ${RM_id}  ${alias}

        Log  BTS ${alias} shared RMOD with SN ${RM_sn} feature CB007878 status:  console=True
        Log  - parameter actSharedRUIndControl = ${actSharedRUIndControl}  console=True
        Run Keyword If  '${actSharedRUIndControl}' == 'true'  Run Keywords
        ...  Log  Need to set parameter actSharedRUIndControl = false  console=True
        ...  AND  Set actSharedRUIndControl parameter value  ${RM_id}  false  ${alias}
        ...  ELSE
        ...  Log  Parameter actSharedRUIndControl = false already set, no action needed!  console=True

    END

    Set Test Variable  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${RMOD_id_actSharedRUIndControl_initial_dict}
    Set Test Variable  ${${alias}_CB007878_check}  True

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

Check peerBtsActSharedRUIndControl parameter value on BTS
    [Arguments]  ${value}  ${alias}

    Log  Check peerBtsActSharedRUIndControl parameter value on BTS ${alias}:  console=True

    FOR  ${RM_sn}  IN  @{${alias}_shared_RMOD_sn_list}

        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${EMPTY}  ${peerBtsActSharedRUIndControl}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}
        Log  BTS ${alias} shared RMOD with SN ${RM_sn} feature CB007878 status:  console=True
        Log  - parameter peerBtsActSharedRUIndControl = ${peerBtsActSharedRUIndControl}  console=True

        Run Keyword If  '${peerBtsActSharedRUIndControl}' == '${value}'
        ...  Log  Parameter peerBtsActSharedRUIndControl = ${peerBtsActSharedRUIndControl}, properly updated!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Parameter peerBtsActSharedRUIndControl = ${peerBtsActSharedRUIndControl}, not properly updated!  level=ERROR
        ...  AND  Fail  Parameter peerBtsActSharedRUIndControl = ${peerBtsActSharedRUIndControl}, not properly updated!

    END

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
