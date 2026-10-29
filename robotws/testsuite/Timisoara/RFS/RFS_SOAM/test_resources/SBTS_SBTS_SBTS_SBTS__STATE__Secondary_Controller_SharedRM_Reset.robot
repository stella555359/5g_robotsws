*** Settings ***
Documentation    TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
Variables    tc_variables/sbts_sbts_sbts_sbts__state__secondary_controller_sharedrm_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}                3      # Number of shared RM reset operations, default value 3
${SHARED_RM_SERIAL_NUMBER_LIST}  ALL    # Shared RM serial number list on which reset operation will be performed. Possible values: ALL (operation
                                        # will be performed on all shared RM) or list of selected shared RM serial number separated by comma.
                                        # By default: ALL
${RM_RESET_MAX_WAIT_TIME}        900    # Maximum waiting time for all cells mapped on impacted shared RM to be enabled after RM reset
${RM_RESET_TIME_INTERVAL}        480    # Time interval between reset RM, default value 480 seconds.
${RM_RESET_WRN_THR}              180    # Time spent between first cell down to last cell up on RM; default value: in accordance with KPI51a
                                        # specifications.
${CNI_103974}                    True   # Flag to enable CNI-103974 behavior related to peer BTS alarms during shared RM reset. Possible values: True
                                        # (new CNI-103974 FID4773 will be checked), False (legacy FID1815_FID10 will be checked). By default: True
${GRACEFUL_CELL_SHUTDOWN}        True   # Graceful cell shutdown: True or False; default value: True
${LTE_IOT_check}                 True   # Specify in case of configured LTE IOT cells if their status will be checked (True) or skipped (False)
                                        # due to RM Reset. By default True

*** Keywords ***
TC__SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26607
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS-SBTS-SBTS test case for shared RM reset from BTS secondary controller, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info, RAT cells (per BTS alias)
    ...  - check feature CB007878 status on requested shared RM, and enable it if needed
    ...  - perform reset shared RM operation on BTS secondary controller checking states and alarms
    ...  - check final state and alarms for all BTS
    ...  Pass criteria: reset shared RM operation works as expected; states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 04.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26607 - [5G][CNI-103974]RF_Share_RM_reset_from_secondary_controller
    ...  - 04.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27015 - [5G] Add sleep 10s to avoid cell transitory states for RM_Reset - 4xSBTS
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27071 - [5G] [P0]Include new CNI-103974 mechanism in RM Reset - 4x SBTS -
    ...  after TAT-27087
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27068 - [5G] Include new CNI-103974 mechanism in RM Reset - 3xSBTS -
    ...  after TAT-27087
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27066 - [5G] Include new CNI-103974 mechanism in RM Reset - NRL - after TAT-27087
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27624 -
    ...  [5G] Adapt RM Reset robots to allow exception while CNI-103974 mechanism is used - with TAT-27699
    ...  - 06.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27820 - [CNI-127210] MIMO Explicit IMS minor expected alarm check in RM Reset TCs
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 14.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28155 - [CNI-127210][DROP3] EXPECTED 4003 alarm from ADMIN on both CNI and
    ...  without CNI
    ...  - 16.12.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28520 - NRL__STATE__Secondary_Controller_SharedRM_Reset fails (due to IoT cell)
    ...  / please skip check of IoT cell status
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28577 -
    ...  [5G] Refactor TCs to use value of scf parameters as read from scf without transforming inside KW: Check Parameter value from SCF -
    ...  actSharedRuIndControl, peerBtsActSharedRuIndControl
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-26607_SBTS_SBTS_SBTS_SBTS__STATE__Secondary_Controller_SharedRM_Reset_CNI_103974.png

    Set Tags    CA-STATE    OWNER-dan.popescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R1

    TC Preconditions
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    Step 4: Check feature CB007878 status on shared RM from all BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 5: Perform Reset shared RM from BTS secondary controller for iteration ${INDEX}
        Step 6: Check final all BTS state
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
        Step 9: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RM
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${CNI_103974}=  Set Variable  ${CNI_103974.title()}
    Set Test Variable  ${CNI_103974}

    Run Keyword If  '${CNI_103974}' not in ['True','False']  Run Keywords
    ...  Log  Please select a proper value for test argument \${CNI_103974}.  console=True
    ...  AND  Fail  Improper value for argument!

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
    ...  - list of shared RM serial number configured on BTS primary controller (per BTS alias)
    ...  - list of shared RM serial number configured on BTS secondary controller (per BTS alias)
    ...  - list of RAT cells (per BTS alias)

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    Set Test Variable  ${RM_sn_bts-alias_dict}
    Set Test Variable  ${shared_RM_sn_list}
    Run Keyword If  '${SHARED_RM_SERIAL_NUMBER_LIST}' != 'ALL'  Check shared RM serial number list
    Log  =======================================================  console=True
    Log  Shared RM serial number list selected for RESET action: ${shared_RM_sn_list}  console=True
    Log  =======================================================  console=True

    FOR  ${alias}  IN  @{alias_list}
        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}

        Get BTS CELL list by RAT  ${alias}

        ${RM_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
        Set Test Variable  ${${alias}_RM_L3Protocol_dict}  ${RM_L3Protocol_dict}
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

Step ${index}: Perform Reset shared RM from BTS secondary controller for iteration ${CYCLE}
    Log  Step ${index}: Perform Reset shared RM from BTS secondary controller  console=True

    Set Test Variable  ${RM_state_disabled_check}
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_disabled}
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${CELL_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    Set Test Variable  ${CELL_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded
    Set Test Variable  ${CELL_state_disabled_check}  operationalState=${Disabled_}, availabilityStatus=${Failed_Offline_}
    Set Test Variable  ${CELL_state_disabled}  operationalState=Disabled, availabilityStatus=Failed|Offline, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}
        Perform Reset shared RM  ${alias}  ${CYCLE}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RM
    Log  Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL between actions on same RM

    Get Current Time  final_checks
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final_checks}  ${time_rm_reset}  number
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

Get BTS CELL list by RAT
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
    Set Test Variable  ${${alias}_LTE_IOT_CELL_list}  ${LTE_IOT_CELL_ID_LIST}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL_list}  ${LTE_IOT_SA_CELL_ID_LIST}
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Perform Reset shared RM
    [Arguments]  ${alias}  ${CYCLE}
    ${new_alias}=  Set Variable  ${alias}_resetRM

    Run Keyword If  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}
    ...  connection_type=${connection_type_${alias}}

    FOR  ${RM_sn}  IN  @{${alias}_BTS_secondary_controller_shared_RM_sn_list}
        Reset shared RM  ${RM_sn}  ${alias}  ${new_alias}  ${CYCLE}
    END

    [Teardown]  Run Keyword If  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Teardown Admin  alias=${new_alias}

Reset shared RM
    [Arguments]  ${RM_sn}  ${alias}  ${new_alias}  ${CYCLE}

    Log  =======================================================  console=True
    Log  Perform Shared RM Reset ${RM_sn} from BTS ${alias}  console=True
    Log  =======================================================  console=True

    ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
    ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
    ${RM_peer_bts-alias_list}=  Copy List  ${RM_bts-alias_list}
    Remove Values From List  ${RM_peer_bts-alias_list}  ${alias}
    ${peer_alias}=  Get From List  ${RM_peer_bts-alias_list}  0
    ${peer_RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_sn}
    ${RM_param_check}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}
    Set Test Variable  ${RM_param_check}
    Log  Get BTS ${alias} and BTS ${peer_alias} cells mapped on shared RM with SN ${RM_sn}:  console=True
    Get shared RM all cells from specific RAT  ${RM_sn}  ${RM_id}  ${alias}
    Get shared RM all cells from specific RAT  ${RM_sn}  ${peer_RM_id}  ${peer_alias}
    ${RM_L3Protocol}=  Get From Dictionary  ${${alias}_RM_L3Protocol_dict}  ${RM_id}
    Set Test Variable  ${RM_L3Protocol}
    ${RM_protocol}=  Set Variable If  '${RM_L3Protocol}' == 'RP301_RP1'  OBSAI  '${RM_L3Protocol}' == 'CPRI_RP1'  CPRI
    ...  '${RM_L3Protocol}' == 'ECPRI_MPLANE'  ECPRI
    Log  Perform "Reset" operation on shared RM (${RM_protocol}) with SN ${RM_sn} from BTS ${alias}:  console=True

    Get Current Time  rm_reset
    Get Current Date UTC info  start_resetRM
    ${reset_info}=  RFS RM Reset  dist_name=${RM_id}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}
    Get Current Time  initial

    Log  Check BTS ${alias} and BTS ${peer_alias} state and alarms during reset shared RM (${RM_protocol}) with SN ${RM_sn}:  console=True
    Run Keyword If  '${RM_L3Protocol}' == 'CPRI_RP1'
    ...  Check both BTS states and alarms during reset shared RM CPRI  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}
    ...  ELSE IF  '${RM_L3Protocol}' == 'ECPRI_MPLANE'
    ...  Check both BTS states and alarms during reset shared RM ECPRI  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}
    ...  ELSE IF  '${RM_L3Protocol}' == 'RP301_RP1'
    ...  Check both BTS states and alarms during reset shared RM OBSAI  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Collect Keyword Result  ${reset_info}  timeout=${RM_RESET_MAX_WAIT_TIME}

    Log  Check BTS ${alias} and BTS ${peer_alias} state and alarms after reset shared RM (${RM_protocol}) with SN ${RM_sn}:  console=True
    Check both BTS states and alarms after reset shared RM  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Get Current Date UTC info  end_resetRM

    Run Keyword If  ${${alias}_CELL_RM_failed} > 0
    ...  Get and check KPI51a and KPI51b info from IMS file  ${RM_id}  ${alias}  ${alias}  ${CYCLE}

Get shared RM all cells from specific RAT
    [Arguments]  ${RM_sn}  ${RM_id}  ${alias}

    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}

    ${NR_CELL_RM_list}=  Create List
    ${LTE_CELL_RM_list}=  Create List
    ${LTE_IOT_CELL_RM_list}=  Create List
    ${LTE_IOT_SA_CELL_RM_list}=  Create List
    ${WCDMA_CELL_RM_list}=  Create List
    ${GSM_CELL_RM_list}=  Create List

    FOR  ${item}  IN  @{CELL_RM_list}

        Run Keyword If  '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${${alias}_LTE_IOT_CELL_list}  Append To List  ${LTE_IOT_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${${alias}_LTE_IOT_SA_CELL_list}  Append To List  ${LTE_IOT_SA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RM_list}  ${item}
        Run Keyword If  '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RM_list}  ${item}

    END

    Sort List  ${NR_CELL_RM_list}
    Sort List  ${LTE_CELL_RM_list}
    Sort List  ${LTE_IOT_CELL_RM_list}
    Sort List  ${LTE_IOT_SA_CELL_RM_list}
    Sort List  ${WCDMA_CELL_RM_list}
    Sort List  ${GSM_CELL_RM_list}

    FOR  ${item}  IN  @{LTE_CELL_RM_list}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Append To List  ${LTE_IOT_CELL_RM_list}  ${LTE_IOT_CELL_id}

    END

    ${LTE_IOT_CELL_RM_list}=  Remove Duplicates  ${LTE_IOT_CELL_RM_list}
    Sort List  ${LTE_IOT_CELL_RM_list}

    ${LTE_CELL_RM_full_list}=  Combine Lists   ${LTE_CELL_RM_list}  ${LTE_IOT_CELL_RM_list}  ${LTE_IOT_SA_CELL_RM_list}
    ${CELL_RM_list}=  Combine Lists   ${NR_CELL_RM_list}  ${LTE_CELL_RM_full_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}

    Set Test Variable  ${${alias}_NR_CELL_RM_list}  ${NR_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_list}  ${LTE_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_RM_list}  ${LTE_IOT_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL_RM_list}  ${LTE_IOT_SA_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_full_list}  ${LTE_CELL_RM_full_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RM_list}  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_CELL_RM_list}  ${CELL_RM_list}

    Log  BTS ${alias} cells mapped on shared RM with SN ${RM_sn}:  console=True
    Run Keyword If  ${NR_CELL_RM_list}  Log  - NRCEL: ${${alias}_NR_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_CELL_RM_list}  Log  - LNCEL: ${${alias}_LTE_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_IOT_CELL_RM_list}  Log  - LNCEL IOT: ${${alias}_LTE_IOT_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_IOT_SA_CELL_RM_list}  Log  - LNCEL IOT SA: ${${alias}_LTE_IOT_SA_CELL_RM_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RM_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_RM_list}  console=True
    Run Keyword If  ${GSM_CELL_RM_list}  Log  - GNCEL: ${${alias}_GSM_CELL_RM_list}  console=True

    ${NR_CELL_not_RM_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${LTE_IOT_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_IOT_CELL_list}
    ${LTE_IOT_SA_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_IOT_SA_CELL_list}
    ${WCDMA_CELL_not_RM_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RM_list}=  Copy List  ${${alias}_GSM_CELL_list}

    FOR  ${item}  IN  @{CELL_RM_list}

        Remove Values From List  ${NR_CELL_not_RM_list}  ${item}
        Remove Values From List  ${LTE_CELL_not_RM_list}  ${item}
        Remove Values From List  ${LTE_IOT_CELL_not_RM_list}  ${item}
        Remove Values From List  ${LTE_IOT_SA_CELL_not_RM_list}  ${item}
        Remove Values From List  ${WCDMA_CELL_not_RM_list}  ${item}
        Remove Values From List  ${GSM_CELL_not_RM_list}  ${item}

    END

    Sort List  ${NR_CELL_not_RM_list}
    Sort List  ${LTE_CELL_not_RM_list}
    Sort List  ${LTE_IOT_CELL_not_RM_list}
    Sort List  ${LTE_IOT_SA_CELL_not_RM_list}
    Sort List  ${WCDMA_CELL_not_RM_list}
    Sort List  ${GSM_CELL_not_RM_list}

    ${CELL_not_RM_list}=  Combine Lists  ${NR_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}  ${LTE_IOT_CELL_not_RM_list}  ${LTE_IOT_SA_CELL_not_RM_list}
    ...  ${WCDMA_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}

    Set Test Variable  ${${alias}_NR_CELL_not_RM_list}  ${NR_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_IOT_CELL_not_RM_list}  ${LTE_IOT_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_IOT_SA_CELL_not_RM_list}  ${LTE_IOT_SA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${${alias}_CELL_not_RM_list}  ${CELL_not_RM_list}

Check both BTS states and alarms during reset shared RM CPRI
    [Arguments]  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} shared RM with SN ${RM_sn} status:  console=True
    Check shared RM state  ${RM_sn}  ${RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${alias}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} shared RM with SN ${RM_sn} state:  console=True
    ...  AND  Check shared RM state  ${RM_sn}  ${peer_RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${peer_alias}

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${alias}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    ...  AND  Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${alias}  ${RM_sn}
    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${peer_alias}  ${RM_sn}

    Log  Check BTS ${alias} alarms:  console=True
    Check BTS alarms during shared RM reset  ${alias}
    Log  Check BTS ${peer_alias} alarms:  console=True
    Check peer BTS alarms during shared RM reset  ${peer_alias}

Check both BTS states and alarms during reset shared RM ECPRI
    [Arguments]  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} and ${peer_alias} shared RM with SN ${RM_sn} state:  console=True
    Check shared RM state  ${RM_sn}  ${RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${alias}
    Check shared RM state  ${RM_sn}  ${peer_RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${peer_alias}

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${alias}
    Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${alias}  ${RM_sn}
    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${peer_alias}  ${RM_sn}

    Log  Check BTS ${alias} alarms:  console=True
    Check BTS alarms during shared RM reset  ${alias}
    Log  Check BTS ${peer_alias} alarms:  console=True
    Check peer BTS alarms during shared RM reset  ${peer_alias}

Check both BTS states and alarms during reset shared RM OBSAI
    [Arguments]  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} and ${peer_alias} shared RM with SN ${RM_sn} state:  console=True
    Check shared RM state  ${RM_sn}  ${RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${alias}
    Check shared RM state  ${RM_sn}  ${peer_RM_id}  ${RM_state_disabled_check}  ${RM_state_disabled}  ${peer_alias}

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${alias}
    Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  30s  10s  Check cells state mapped on shared RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${alias}  ${RM_sn}
    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on shared RM  ${peer_alias}  ${RM_sn}

    Log  Check BTS ${alias} alarms:  console=True
    Check BTS alarms during shared RM reset  ${alias}
    Log  Check BTS ${peer_alias} alarms:  console=True
    Check peer BTS alarms during shared RM reset  ${peer_alias}

Check both BTS states and alarms after reset shared RM
    [Arguments]  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Log  Check BTS ${alias} and ${peer_alias} shared RM with SN ${RM_sn} state:  console=True
    Check shared RM state  ${RM_sn}  ${RM_id}  ${RM_state_enabled_check}  ${RM_state_enabled}  ${alias}
    Check shared RM state  ${RM_sn}  ${peer_RM_id}  ${RM_state_enabled_check}  ${RM_state_enabled}  ${peer_alias}

    Log  Check BTS ${alias} and ${peer_alias} cells state:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${peer_alias}  ${remained_MAX_WAIT_TIME}
    Log  All BTS ${peer_alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${alias} and ${peer_alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

Check shared RM state
    [Arguments]  ${RM_sn}  ${RM_id}  ${RM_state_check}  ${RM_state}  ${alias}

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} shared RM with SN ${RM_sn} status:\n - ${RM_state}  console=True

Check cells state mapped on shared RM
    [Arguments]  ${alias}

    ${BTS_ALARM_COUNT_MIMO}=  Set Variable  0
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RM_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RM_list}  alias=${alias}
    ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RM_list}
    ...  Set Variable  ${NR_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RM_full_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RM_full_list}  alias=${alias}
    ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RM_full_list}
    ...  Set Variable  ${LTE_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RM_list}  alias=${alias}
    ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}
    ...  Set Variable  ${WCDMA_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RM_list}  alias=${alias}
    ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RM_list}
    ...  Set Variable  ${GSM_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    Set Test Variable  ${${alias}_BTS_ALARM_COUNT_MIMO}  ${BTS_ALARM_COUNT_MIMO}

    Calculate number of disabled cells mapped on shared RM  ${alias}  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}
    ...  ${WCDMA_cell_state_failed_list}  ${GSM_cell_state_failed_list}

    Return From Keyword If  not ${${alias}_LTE_IOT_CELL_RM_list} and not ${${alias}_LTE_IOT_SA_CELL_RM_list}
    Return From Keyword If  '${LTE_IOT_check}' != 'True'

    FOR  ${item}  IN  @{LTE_cell_state_degraded_list}

        Run Keyword If  '${item}' in ${${alias}_LTE_IOT_SA_CELL_RM_list}  Run Keywords
        ...  Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_degraded_check}  connection=${alias}
        ...  AND  Log  ${alias} LNCEL ${item} status:\n - ${CELL_state_degraded}  console=True
        ...  AND  Continue For Loop

        ${LTE_IOT_CELL_check}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  not ${LTE_IOT_CELL_check}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_CELL_id}  parameters=${CELL_state_degraded_check}  connection=${alias}
        ...  AND  Log  ${alias} LNCEL ${LTE_IOT_CELL_id} status:\n - ${CELL_state_degraded}  console=True

    END

    FOR  ${item}  IN  @{LTE_cell_state_failed_list}

        Run Keyword If  '${item}' in ${${alias}_LTE_IOT_SA_CELL_RM_list}  Run Keywords
        ...  Assert  class_name=LNCEL  id=${item}  parameters=${CELL_state_disabled_check}  connection=${alias}
        ...  AND  Log  ${alias} LNCEL ${item} status:\n - ${CELL_state_disabled}  console=True
        ...  AND  Continue For Loop

        ${LTE_IOT_CELL_check}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Continue For Loop If  not ${LTE_IOT_CELL_check}

        ${LTE_IOT_CELL_id}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${item}
        Run Keyword If  '${LTE_IOT_CELL_id}' != 'None'  Run Keywords
        ...  Assert  class_name=LNCEL  id=${LTE_IOT_CELL_id}  parameters=${CELL_state_disabled_check}  connection=${alias}
        ...  AND  Log  ${alias} LNCEL ${LTE_IOT_CELL_id} status:\n - ${CELL_state_disabled}  console=True
    END

Calculate number of disabled cells mapped on shared RM
    [Arguments]  ${alias}  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}  ${WCDMA_cell_state_failed_list}
    ...  ${GSM_cell_state_failed_list}

    ${NR_cell_state_failed_count}=  Get Length  ${NR_cell_state_failed_list}
    ${LTE_cell_state_failed_count}=  Get Length  ${LTE_cell_state_failed_list}
    ${WCDMA_cell_state_failed_count}=  Get Length  ${WCDMA_cell_state_failed_list}
    ${GSM_cell_state_failed_count}=  Get Length  ${GSM_cell_state_failed_list}

    ${condition}=  Create Long String  ${NR_cell_state_failed_count} + ${LTE_cell_state_failed_count} + ${WCDMA_cell_state_failed_count} +
    ...  ${GSM_cell_state_failed_count}
    ${CELL_RM_failed}=  Evaluate  ${condition}

    Set Test Variable  ${${alias}_CELL_RM_failed}  ${CELL_RM_failed}

Check cells state not mapped on shared RM
    [Arguments]  ${alias}  ${RM_sn}

    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_IOT_CELL_not_RM_list} and '${LTE_IOT_check}' == 'True'
    ...  Check Cell State  LNCEL  ${${alias}_LTE_IOT_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_IOT_SA_CELL_not_RM_list} and '${LTE_IOT_check}' == 'True'
    ...  Check Cell State  LNCEL  ${${alias}_LTE_IOT_SA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RM_sn}:\n - ${CELL_state_enabled}  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check BTS alarms during shared RM reset
    [Arguments]  ${alias}

    ${EXPECTED_ALARMS_4003}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4003}  ${${alias}_BTS_ALARM_COUNT_MIMO}

    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, expected number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${EXPECTED_ALARMS_4003}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, found number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}, as expected!  console=True

Check peer BTS alarms during shared RM reset
    [Arguments]  ${alias}

    ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_CNI_103974_exceptions}  ${RM_param_check['productName']}

    ${EXPECTED_ALARMS}=  Set Variable If
    ...  '${RM_L3Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'  ${${alias.upper()}_EXPECTED_ALARMS_4773}
    ...  '${RM_L3Protocol}' == 'CPRI_RP1'  ${${alias.upper()}_EXPECTED_ALARMS_1815_10}
    ...  '${RM_L3Protocol}' == 'ECPRI_MPLANE'  ${${alias.upper()}_EXPECTED_ALARMS_10}
    ...  '${RM_L3Protocol}' == 'RP301_RP1'  ${${alias.upper()}_EXPECTED_ALARMS_10}
    ${EXPECTED_ALARMS_4003}=  Run Keyword If  '${CNI_103974}' == 'True' or '${RM_L3Protocol}' != 'CPRI_RP1'
    ...  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_4003}  ${${alias}_BTS_ALARM_COUNT_MIMO}
    ...  ELSE  Create List
    ${EXPECTED_ALARMS_full}=  Combine Lists  ${EXPECTED_ALARMS}  ${EXPECTED_ALARMS_4003}

    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0 and ('${CNI_103974}' == 'True' or '${RM_L3Protocol}' != 'CPRI_RP1')
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, expected number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}  console=True
    Run Keyword If  '${RM_L3Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: 1  console=True
    ...  ELSE IF  '${RM_L3Protocol}' == 'CPRI_RP1'
    ...  Log  BTS ${alias} "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, expected number: 1  console=True
    ...  ELSE  Log  BTS ${alias} "No connection to unit (10)" alarm, expected number: 1  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5 sec  expected_alarms=${EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

    Run Keyword If  ${${alias}_BTS_ALARM_COUNT_MIMO} > 0 and ('${CNI_103974}' == 'True' or '${RM_L3Protocol}' != 'CPRI_RP1')
    ...  Log Long String  BTS ${alias} "Transmission path failure (4003)" or "Tx Failure Turn Mimo Off (4003)" alarm, found number:
    ...  ${${alias}_BTS_ALARM_COUNT_MIMO}, as expected!  console=True
    Run Keyword If  '${RM_L3Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: 1, as expected!  console=True
    ...  ELSE IF  '${RM_L3Protocol}' == 'CPRI_RP1'
    ...  Log Long String  BTS ${alias} "Not able to synchronize baseband bus (1815) or No connection to unit (10)" alarm, found number: 1,
    ...  as expected!  console=True
    ...  ELSE  Log  BTS ${alias} "No connection to unit (10)" alarm, found number: 1, as expected!  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Get and check KPI51a and KPI51b info from IMS file
    [Documentation]
    ...  Get and check KPI51a and KPI51b info from IMS file.

    [Arguments]  ${RM_id}  ${alias}  ${BTS_RM_reset}  ${CYCLE}

    ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}

    Log Long String  ***** Get and check BTS ${alias} KPI51a and KPI51b info related to shared RM with SN ${RM_param['serialNumber']} reset from
    ...  BTS ${BTS_RM_reset} for iteration ${CYCLE} *****  console=True

    ${kpi_name_delta_dict_kpi51a}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi51a  kpi_thresholds=${RM_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}
    ${kpi_delta_list_kpi51a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51a}  kpi51a

    ${kpi_name_delta_dict_kpi51b}=  Get KPI info
    ...  kpi_names=kpi51b  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}
    ${kpi_delta_list_kpi51b}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51b}  kpi51b

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${alias}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51a  event_value_1=${kpi_delta_list_kpi51a[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${BTS_RM_reset}

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${alias}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51b  event_value_1=${kpi_delta_list_kpi51b[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${BTS_RM_reset}

Recover initial settings for feature CB007878
    [Arguments]  ${RM_sn}  ${RM_bts-alias_list}
    Log  Recover initial settings for feature CB007878 on shared RM with SN ${RM_sn}  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${actSharedRUIndControl_initial}=  Get From Dictionary  ${${alias}_RM_sn_actSharedRUIndControl_initial_dict}  ${RM_sn}
        ${actSharedRUIndControl_final}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${RM_id}  ${alias}
        ${actSharedRUIndControl_final}=  Convert To String  ${actSharedRUIndControl_final}
        Run Keyword If  '${actSharedRUIndControl_final}' == '${actSharedRUIndControl_initial}'  Continue For Loop
        Set actSharedRUIndControl parameter value  ${RM_id}  ${actSharedRUIndControl_initial}  ${alias}
    END

Particular Teardown
    FOR  ${RM_sn}  IN  @{shared_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  ${RM_sn}  ${RM_bts-alias_list}
    END
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo
    Check all BTS cells availability status online

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown