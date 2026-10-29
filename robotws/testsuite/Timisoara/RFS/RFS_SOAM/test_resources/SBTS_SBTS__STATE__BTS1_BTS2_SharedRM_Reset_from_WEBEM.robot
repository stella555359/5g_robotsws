*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM
Variables    tc_variables/sbts_sbts__state__bts1_bts2_shared_rm_reset_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of shared RM reset operations, default value 3
${RM_RESET_TIME_INTERVAL}  480    # Time interval between reset shared RM, default value 480 seconds.
${RM_RESET_WRN_THR}        240    # Time spent between first cell down to last cell up on RM; default value: in accordance with KPI51a specifications
${RM_RESET_MAX_WAIT_TIME}  900    # Maximum waiting time for RM reset to be finished; default value 900 seconds
${CNI_103974}              True   # Flag to enable CNI-103974 behavior related to peer BTS alarms during shared RM reset. Possible values: True
                                  # (new CNI-103974 FID4773 will be checked), False (legacy FID1815_FID10 will be checked). By default: True
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True

*** Keywords ***
TC__SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23003
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for shared RMOD reset from both BTS, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial states and alarms for both BTS
    ...  - get both BTS, FHS and RM info
    ...  - check feature CB007878 status on both BTS, and enable it if needed
    ...  - perform reset shared RMOD operation on BTS1 checking states and alarms
    ...  - perform reset shared RMOD operation on BTS2 checking states and alarms
    ...  Pass criteria: RMOD reset operation works as expected, states and alarms are as expected
    ...
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 10.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23003 -
    ...  [5G][CB007636] New SBTS_SBTS scenario_RFS_SBTS_RF_Share_RM_Reset_from_WEBEM
    ...  - 05.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23480 - [5G][Legacy] Eliminate IM_IP_ADDRESS variable usage in TCs
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24216 - [5G][refactoring] Add generalized implementation of
    ...  "Open new admin session" in TCs: SBTS_SBTS
    ...  - 21.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24666 - [5G] RM_OPERATION_TIME_INTERVAL mechanism update - SBTS_SBTS
    ...  - 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24803 - [5G] KPI51a measurement + verdict SBTS_SBTS
    ...  - 12.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25617 - [5G][CB007437] Adapt
    ...  SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM for CB007437
    ...  - 17.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26162 -
    ...  [5G] LTE_Site_Reset_from_WEBEM_SharedFHS_mixed_OBSAI_CPRI - update for FID10
    ...  - 13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26546 - [5G] Update automated scenarios related to shared RM reset for
    ...  CNI-103974 - 2xSBTS
    ...  - 22.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26774 - [5G][Ignored faults] wrong ignored alarms file for
    ...  SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM
    ...  - 04.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27017 - [5G] Add sleep 10s to avoid cell transitory states for RM_Reset - 2xSBTS
    ...  - 24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27069 - [5G] Include new CNI-103974 mechanism in RM Reset - 2xSBTS
    ...  - after TAT-27087
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27624 -
    ...  [5G] Adapt RM Reset robots to allow exception while CNI-103974 mechanism is used - with TAT-27699
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 18.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28577 -
    ...  [5G] Refactor TCs to use value of scf parameters as read from scf without transforming inside KW: Check Parameter value from SCF -
    ...  actSharedRuIndControl, peerBtsActSharedRuIndControl
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-23003_SBTS_SBTS__STATE__BTS1_BTS2_SharedRM_Reset_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-razvan.roman@nokia.com    AUTHOR-dinu.olariu@nokia.com    PHASE-QT    SW-SBTS22R4

    TC Preconditions
    Step 1: Check initial BTS Master state
    Step 2: Check initial BTS Slave state
    Step 3: Check initial BTS Master alarms
    Step 4: Check initial BTS Slave alarms
    Step 5: Get both BTS, FHS, RM and cells info
    Step 6: Check feature CB007878 status on both BTS
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 7: Perform Reset shared RMOD on BTS1 on iteration ${INDEX}
        Step 8: Sleep to ensure RM_RESET_TIME_INTERVAL after shared RMOD Reset on BTS1
        Step 9: Perform Reset shared RMOD on BTS2 on iteration ${INDEX}
        Step 10: Sleep to ensure RM_RESET_TIME_INTERVAL after shared RMOD Reset on BTS2
        Step 11: Check final BTS Master state
        Step 12: Check final BTS Slave state
        Step 13: Check final BTS Master alarms
        Step 14: Check final BTS Slave alarms
        Step 15: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions
    ${CNI_103974}=  Set Variable  ${CNI_103974.title()}
    Set Test Variable  ${CNI_103974}

    Run Keyword If  '${CNI_103974}' not in ['True','False']  Run Keywords
    ...  Log  Please select a proper value for test argument \${CNI_103974}.  console=True
    ...  AND  Fail  Improper value for argument!

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

Step ${index}: Get both BTS, FHS, RM and cells info
    Log  Step ${index}: Get both BTS, FHS, RM and cells info  console=True
    Get module info on both BTS  RMOD
    Get module info on both BTS  FHS
    Get BTS info on both BTS

    Get shared RMOD CELL dict  Master
    Get BTS CELL list by RAT  Master
    Get shared RMOD CELL dict  Slave
    Get BTS CELL list by RAT  Slave

Step ${index}: Check feature CB007878 status on both BTS
    [Documentation]
    ...  Check feature CB007878 status on both BTS and enable it if needed

    Log  Step ${index}: Check feature CB007878 status on both BTS  console=True
    Set Test Variable  ${Master_CB007878_check}  False
    Set Test Variable  ${Slave_CB007878_check}  False
    Check feature CB007878 status  Master
    Check feature CB007878 status  Slave

Step ${index}: Perform Reset shared RMOD on ${BTS} on iteration ${CYCLE}
    Log  Step ${index}: Perform Reset shared RMOD on ${BTS} on iteration ${CYCLE}  console=True
    ${peer_BTS}=  Set Variable If  '${BTS}' == 'BTS1'  BTS2  BTS1
    ${alias}=  Set Variable If  '${BTS}' == 'BTS1'  Master  Slave
    ${peer_alias}=  Set Variable If  '${BTS}' == 'BTS1'  Slave  Master
    Set Test Variable  ${BTS}
    Set Test Variable  ${peer_BTS}
    Set Test Variable  ${alias}
    Set Test Variable  ${peer_alias}
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
        ${bts_role}=  Set Variable If  '${item}' in ${${alias}_primary_controller_shared_RMOD_list}  primary  secondary
        ${bts_ims}=  Set Variable If  '${bts_role}' == 'primary'  primary  secondary
        ${peer_bts_ims}=  Set Variable If  '${bts_role}' == 'primary'  secondary  primary
        Get Current Date UTC info  start_resetRM
        Perform Reset RMOD  ${item}  ${alias}
        Get Current Date UTC info  end_resetRM
        Run Keyword If  ${${alias}_CELL_RM_failed} > 0
        ...  Get and check KPI51a and KPI51b info from IMS file  ${item}  ${alias}  ${alias}  ${CYCLE}
    END

Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL after shared RMOD Reset on ${BTS}
    Log  Step ${index}: Sleep to ensure RM_RESET_TIME_INTERVAL after shared RMOD Reset on ${BTS}  console=True
    Get Current Time  final
    ${time_elapsed_final}=  DateTime.Subtract Date From Date  ${time_final}  ${time_initial}  number
    ${remained_time}=  BuiltIn.Evaluate  ${RM_RESET_TIME_INTERVAL}-${time_elapsed_final}
    Run Keyword If  ${remained_time} > 0  Run Keywords
    ...  Log  Time interval between Reset RM operations: ${RM_RESET_TIME_INTERVAL} sec -> Wait ${remained_time} sec  console=True
    ...  AND  Sleep  ${remained_time} sec

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get module info on both BTS
    [Arguments]  ${module}
    ${Master_shared_module_list}  ${Slave_shared_module_list}  ${Master_dedicated_module_list}  ${Slave_dedicated_module_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  ${module}  Master  Slave
    Sort List  ${Master_shared_module_list}
    Sort List  ${Slave_shared_module_list}
    Sort List  ${Master_dedicated_module_list}
    Sort List  ${Slave_dedicated_module_list}
    Set Test Variable  ${Master_shared_${module}_list}  ${Master_shared_module_list}
    Set Test Variable  ${Slave_shared_${module}_list}  ${Slave_shared_module_list}
    Set Test Variable  ${Master_dedicated_${module}_list}  ${Master_dedicated_module_list}
    Set Test Variable  ${Slave_dedicated_${module}_list}  ${Slave_dedicated_module_list}

    Run Keyword If  '${module}' == 'RMOD'  Run Keywords
    ...  Get RMOD ID SN dict  Master
    ...  AND  Get RMOD ID SN dict  Slave
    ...  ELSE IF  '${module}' == 'FHS'  Run Keywords
    ...  Get FHS ID SN dict  Master
    ...  AND  Get FHS ID SN dict  Slave
    Set Test Variable  ${Master_${module}_SN_ID_dict}   ${Master_module_SN_ID_dict}
    Set Test Variable  ${Master_${module}_ID_SN_dict}  ${Master_module_ID_SN_dict}
    Set Test Variable  ${Slave_${module}_SN_ID_dict}   ${Slave_module_SN_ID_dict}
    Set Test Variable  ${Slave_${module}_ID_SN_dict}  ${Slave_module_ID_SN_dict}

    Run Keyword If  ${Master_shared_module_list}
    ...  Get shared module info  ${module}
    Run Keyword If  ${Master_dedicated_module_list}
    ...  Get dedicated module info  ${module}  Master
    Run Keyword If  ${Slave_dedicated_module_list}
    ...  Get dedicated module info  ${module}  Slave

Get shared module info
    [Arguments]  ${module}
    FOR  ${Master_module_id}  IN  @{Master_shared_${module}_list}
        ${module_sn}=  Get From Dictionary  ${Master_module_ID_SN_dict}  ${Master_module_id}
        ${Slave_module_id}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${module_sn}
        Log  Shared ${module} with SN ${module_sn}:  console=True
        Log  - BTS1 ${module} id: ${Master_module_id}  console=True
        Log  - BTS2 ${module} id: ${Slave_module_id}  console=True
    END

Get dedicated module info
    [Arguments]  ${module}  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    FOR  ${module_id}  IN  @{${alias}_dedicated_${module}_list}
        ${module_sn}=  Get From Dictionary  ${${alias}_module_ID_SN_dict}  ${module_id}
        Log  Dedicated ${module} with SN ${module_sn}:  console=True
        Log  - ${BTS} ${module} id: ${module_id}  console=True
    END

Get BTS info on both BTS
    Get BTS primary controller shared RMOD list  Master
    Get BTS primary controller shared RMOD list  Slave
    Get BTS secondary controller shared RMOD list  Master
    Get BTS secondary controller shared RMOD list  Slave

    ${BTS_secondary_controller}=  Set Variable If
    ...  ${Master_primary_controller_shared_RMOD_count} == 0  BTS1  ${Slave_primary_controller_shared_RMOD_count} == 0  BTS2  BOTH
    ${BTS_primary_controller}=  Set Variable If  '${BTS_secondary_controller}' == 'BTS1'  BTS2  '${BTS_secondary_controller}' == 'BTS2'  BTS1
    ...  BOTH

    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}

    Log  BTS primary controller role: ${BTS_primary_controller}  console=True
    Log  BTS secondary controller role: ${BTS_secondary_controller}  console=True

Get BTS primary controller shared RMOD list
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=${alias}
    ${BTS_primary_controller_shared_RMOD_list}=  Create List
    FOR  ${item}  IN  @{BTS_primary_controller_RMOD_list}
       Run Keyword If  '${item}' in ${${alias}_shared_RMOD_list}
        ...  Append To List  ${BTS_primary_controller_shared_RMOD_list}  ${item}
    END
    Sort List  ${BTS_primary_controller_shared_RMOD_list}
    Set Test Variable  ${${alias}_primary_controller_shared_RMOD_list}  ${BTS_primary_controller_shared_RMOD_list}
    Log  ${BTS} configured as primary controller for: ${BTS_primary_controller_shared_RMOD_list}  console=True
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
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    Log  Check feature CB007878 status on ${BTS}:  console=True
    ${RMOD_id_actSharedRUIndControl_initial_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
         ${actSharedRUIndControl}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${item}  ${alias}
         Set To Dictionary  ${RMOD_id_actSharedRUIndControl_initial_dict}  ${item}  ${actSharedRUIndControl}
         Log  ${BTS} shared RMOD ${item} feature CB007878 status:  console=True
         Log  - parameter actSharedRUIndControl = ${actSharedRUIndControl}  console=True
         Run Keyword If  '${actSharedRUIndControl}' == 'false'  Run Keywords
         ...  Log  Need to set parameter actSharedRUIndControl = true  console=True
         ...  AND  Set actSharedRUIndControl parameter value  ${item}  true  ${alias}
         ...  ELSE
         ...  Log  Parameter actSharedRUIndControl = true already set, no action needed!  console=True
    END
    Set Test Variable  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${RMOD_id_actSharedRUIndControl_initial_dict}
    Set Test Variable  ${${alias}_CB007878_check}  True

Get shared RMOD CELL dict
    [Arguments]   ${alias}
    ${shared_RMOD_CELL_dict}=  Create Dictionary
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
        ${CELL_list}=  Get Cell Mapping By Module Id  module_id=${item}  connection=${alias}
        Sort List  ${CELL_list}
        Set To Dictionary  ${shared_RMOD_CELL_dict}  ${item}  ${CELL_list}
    END
    Set Test Variable  ${${alias}_shared_RMOD_CELL_dict}  ${shared_RMOD_CELL_dict}

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

Perform Reset RMOD
    [Arguments]  ${RMOD_id}  ${alias}
    ${new_alias}=  Set Variable  resetRMOD
    ${RMOD_state_disabled_check}=  Set Variable
    ...  operationalState=${Disabled_}, availabilityStatus=${NotInstalled_Offline_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable
    ...  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${RMOD_state_disabled}=  Set Variable
    ...  operationalState=Disabled, availabilityStatus=NotInstalled|Offline, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable
    ...  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${RMOD_state_disabled_check}
    Set Test Variable  ${RMOD_state_disabled}
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${RMOD_sn}=  Get From Dictionary  ${${alias}_RMOD_ID_SN_dict}  ${RMOD_id}
    ${RMOD_id_peer}=  Get From Dictionary  ${${peer_alias}_RMOD_SN_ID_dict}  ${RMOD_sn}
    Set Test Variable  ${RMOD_id_peer}
    ${RM_param_check}=  Get Parameters For  class_name=RMOD  id_num=${RMOD_id}  connection=${alias}
    ${RM_EXCEPTION}=  Run Keyword And Return Status  Should Contain  ${RMOD_CNI_103974_exceptions}  ${RM_param_check['productName']}
    Set Test Variable  ${RM_EXCEPTION}
    ${RMOD_L3Protocol_dict}=  Admin Get RMOD L3 Protocol Info  ${alias}
    ${RMOD_L3_Protocol}=  Get From Dictionary  ${RMOD_L3Protocol_dict}  ${RMOD_id}
    Set Test Variable  ${RMOD_L3_Protocol}

    Get shared RMOD all cells from specific RAT  ${RMOD_sn}  ${alias}  ${BTS}
    Get shared RMOD all cells from specific RAT  ${RMOD_sn}  ${peer_alias}  ${peer_BTS}

    Log  Perform "Reset" operation on shared RMOD with SN ${RMOD_sn} from ${BTS}  console=True
    Start new ADMIN instance  alias=${alias}  new_alias=${new_alias}  connection_type=${connection_type_${alias}}
    Get Current Time  initial
    ${reset_info}=  RFS RM Reset  dist_name=${RMOD_id}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${new_alias}  alias=${alias}
    ...  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}

    Log  Check ${BTS} and ${peer_BTS} states and alarms during reset shared RMOD with SN ${RMOD_sn}:  console=True

    Run Keyword If  '${RMOD_L3_Protocol}' == 'CPRI_RP1'
    ...  Check states and alarms during shared CPRI RM reset  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}
    ...  ELSE IF  '${RMOD_L3_Protocol}' in ['ECPRI_MPLANE','RP301_RP1']
    ...  Check states and alarms during shared non CPRI RM reset  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}

    Collect Keyword Result  ${reset_info}  timeout=${RM_RESET_MAX_WAIT_TIME}

    Log  Check ${BTS} and ${peer_BTS} states and alarms after reset shared RMOD with SN ${RMOD_sn}:  console=True

    Log  Check ${BTS} and ${peer_BTS} shared RMOD state:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${BTS} RMOD ${RMOD_id} status:\n - ${RMOD_state_enabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    Log  ${peer_BTS} RMOD ${RMOD_id_peer} status:\n - ${RMOD_state_enabled}   console=True

    Log  Check ${BTS} and ${peer_BTS} cells state:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cell state mapped on shared RMOD  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${RMOD_sn}  ${alias}
    ...  ${BTS}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cell state mapped on shared RMOD  ${CELL_state_enabled_check}  ${CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${RMOD_sn}  ${peer_alias}
    ...  ${peer_BTS}
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    Log  All ${BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${peer_alias}
    Log  All ${peer_BTS} cell(s) status:\n - ${CELL_state_enabled}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Check cells availability status online  ${peer_alias}  ${remained_MAX_WAIT_TIME}

    Log  Check ${BTS} and ${peer_BTS} alarms after reset shared RMOD with SN ${RMOD_sn}:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${BTS} site - expected, ignored and critical alarms checked  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Log  ${peer_BTS} site - expected, ignored and critical alarms checked  console=True

    Sleep  5s

    [Teardown]  Teardown Admin  alias=${new_alias}

Check states and alarms during shared CPRI RM reset
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}

    ${EXPECTED_ALARMS}=  Set Variable If  '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${${peer_alias.upper()}_EXPECTED_ALARMS_1815_10}

    Log  Check BTS ${alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_disabled_check}  timeout=${RM_RESET_MAX_WAIT_TIME}
    ...  connection=${alias}
    Log  BTS ${alias} RMOD with SN ${RMOD_sn} status:\n - ${RMOD_state_disabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    ...  AND  Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RMOD_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}
    ...  connection=${peer_alias}
    ...  AND  Log  BTS ${peer_alias} RMOD with SN ${RMOD_sn} status:\n - ${RMOD_state_disabled}  console=True

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
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on RM  ${alias}
    Run Keyword If  '${CNI_103974}' == 'True'  Run Keywords
    ...  Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    ...  AND  Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_RMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_LTE_CELL_not_RMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_GSM_CELL_not_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${peer_alias}_NR_CELL_not_RMOD_list}
    ...  Check Cell State  NRCEL  ${${peer_alias}_NR_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_LTE_CELL_not_RMOD_list}
    ...  Check Cell State  LNCEL  ${${peer_alias}_LTE_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_not_RMOD_list}
    ...  Check Cell State  WNCEL  ${${peer_alias}_WCDMA_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_GSM_CELL_not_RMOD_list}
    ...  Check Cell State  GNCEL  ${${peer_alias}_GSM_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Log  BTS ${peer_alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

Check states and alarms during shared non CPRI RM reset
    [Arguments]  ${RMOD_sn}  ${RMOD_id}  ${RMOD_id_peer}  ${alias}  ${peer_alias}

    ${EXPECTED_ALARMS}=  Set Variable If  '${RM_L3_Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  ${${peer_alias.upper()}_EXPECTED_ALARMS_4773}  ${${peer_alias.upper()}_EXPECTED_ALARMS_10}

    Log  Check BTS ${alias} and ${peer_alias} shared RMOD with SN ${RMOD_sn} state:  console=True
    Assert  class_name=RMOD  id=${RMOD_id}  parameters=${RMOD_state_disabled_check}  timeout=${RM_RESET_MAX_WAIT_TIME}  connection=${alias}
    Log  BTS ${alias} RMOD with SN ${RMOD_sn} status:\n - ${RMOD_state_disabled}  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${RM_RESET_MAX_WAIT_TIME}
    Assert  class_name=RMOD  id=${RMOD_id_peer}  parameters=${RMOD_state_disabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${peer_alias}
    Log  BTS ${peer_alias} RMOD with SN ${RMOD_sn} status:\n - ${RMOD_state_disabled}   console=True

    Log  Check peer BTS ${peer_alias} alarms:  console=True
    Run Keyword If  '${RM_L3_Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, expected number: 1  console=True
    ...  ELSE  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${peer_alias}  expected_alarms=${EXPECTED_ALARMS}
    ...  ignored_alarms=${${peer_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${RM_L3_Protocol}' != 'RP301_RP1' and '${CNI_103974}' == 'True' and '${RM_EXCEPTION}' != 'True'
    ...  Log  BTS ${peer_alias} "Radio unit reset triggered by peer BTS (4773)" alarm, found number: 1, as expected!  console=True
    ...  ELSE  Log  BTS ${peer_alias} "No connection to unit (10)" alarm, found number: 1, as expected!  console=True
    Log  BTS ${peer_alias} site - expected, ignored and critical alarms checked  console=True

    Log  Check BTS ${alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on RM  ${alias}

    Log  Check BTS ${peer_alias} cells status mapped on shared RM with SN ${RMOD_sn}:  console=True
    Wait Until Keyword Succeeds  30 sec  10 sec  Check cells state mapped on RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${alias}_NR_CELL_not_RMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_LTE_CELL_not_RMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_GSM_CELL_not_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}  ${BTS}
    Log  BTS ${alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${${peer_alias}_NR_CELL_not_RMOD_list}
    ...  Check Cell State  NRCEL  ${${peer_alias}_NR_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_LTE_CELL_not_RMOD_list}
    ...  Check Cell State  LNCEL  ${${peer_alias}_LTE_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_WCDMA_CELL_not_RMOD_list}
    ...  Check Cell State  WNCEL  ${${peer_alias}_WCDMA_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Run Keyword If  ${${peer_alias}_GSM_CELL_not_RMOD_list}
    ...  Check Cell State  GNCEL  ${${peer_alias}_GSM_CELL_not_RMOD_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${peer_alias}
    ...  ${peer_BTS}
    Log  BTS ${peer_alias} cells not mapped on shared RM with SN ${RMOD_sn}:\n - ${CELL_state_enabled}  console=True

Check cells state mapped on RM
    [Arguments]  ${alias}

    ${BTS_ALARM_COUNT_MIMO}=  Set Variable  0
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RMOD_list}  alias=${alias}
    ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Set Variable  ${NR_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RMOD_list}  alias=${alias}
    ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Set Variable  ${LTE_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RMOD_list}  alias=${alias}
    ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Set Variable  ${WCDMA_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RMOD_list}  alias=${alias}
    ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Set Variable  ${GSM_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}
    Set Test Variable  ${${alias}_BTS_ALARM_COUNT_MIMO}  ${BTS_ALARM_COUNT_MIMO}

    Calculate number of disabled cells mapped on shared RM  ${alias}  ${NR_cell_state_failed_list}  ${LTE_cell_state_failed_list}
    ...  ${WCDMA_cell_state_failed_list}  ${GSM_cell_state_failed_list}

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

Get shared RMOD all cells from specific RAT
    [Arguments]  ${RMOD_sn}  ${alias}  ${BTS}
    ${RMOD_id}=  Get From Dictionary  ${${alias}_RMOD_SN_ID_dict}  ${RMOD_sn}
    ${CELL_RMOD_list}=  Get From Dictionary  ${${alias}_shared_RMOD_CELL_dict}  ${RMOD_id}
    ${NR_CELL_RMOD_list}=  Create List
    ${LTE_CELL_RMOD_list}=  Create List
    ${WCDMA_CELL_RMOD_list}=  Create List
    ${GSM_CELL_RMOD_list}=  Create List
    FOR  ${item}  IN  @{${alias}_CELL_list}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_NR_CELL_list}  Append To List  ${NR_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_LTE_CELL_list}  Append To List  ${LTE_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_WCDMA_CELL_list}  Append To List  ${WCDMA_CELL_RMOD_list}  ${item}
        Run Keyword If  '${item}' in ${CELL_RMOD_list} and '${item}' in ${${alias}_GSM_CELL_list}  Append To List  ${GSM_CELL_RMOD_list}  ${item}
    END
    Sort List  ${NR_CELL_RMOD_list}
    Sort List  ${LTE_CELL_RMOD_list}
    Sort List  ${WCDMA_CELL_RMOD_list}
    Sort List  ${GSM_CELL_RMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_RMOD_list}  ${NR_CELL_RMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_RMOD_list}  ${LTE_CELL_RMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RMOD_list}  ${WCDMA_CELL_RMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_RMOD_list}  ${GSM_CELL_RMOD_list}
    Log  ${BTS} cells mapped on shared RMOD with SN ${RMOD_sn}:  console=True
    Run Keyword If  ${NR_CELL_RMOD_list}  Log  - NRCEL: ${NR_CELL_RMOD_list}  console=True
    Run Keyword If  ${LTE_CELL_RMOD_list}  Log  - LNCEL: ${LTE_CELL_RMOD_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RMOD_list}  Log  - WNCEL: ${WCDMA_CELL_RMOD_list}  console=True
    Run Keyword If  ${GSM_CELL_RMOD_list}  Log  - GNCEL: ${GSM_CELL_RMOD_list}  console=True

    ${NR_CELL_not_RMOD_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RMOD_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${WCDMA_CELL_not_RMOD_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RMOD_list}=  Copy List  ${${alias}_GSM_CELL_list}
    FOR  ${item}  IN  @{CELL_RMOD_list}
        Remove Values From List  ${NR_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${LTE_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${WCDMA_CELL_not_RMOD_list}  ${item}
        Remove Values From List  ${GSM_CELL_not_RMOD_list}  ${item}
    END
    Sort List  ${NR_CELL_not_RMOD_list}
    Sort List  ${LTE_CELL_not_RMOD_list}
    Sort List  ${WCDMA_CELL_not_RMOD_list}
    Sort List  ${GSM_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_NR_CELL_not_RMOD_list}  ${NR_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RMOD_list}  ${LTE_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RMOD_list}  ${WCDMA_CELL_not_RMOD_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RMOD_list}  ${GSM_CELL_not_RMOD_list}

Check cell state mapped on shared RMOD
    [Arguments]  ${cell_state_check}  ${cell_state}  ${timeout}  ${RMOD_sn}  ${alias}  ${BTS}

    Run Keyword If  ${${alias}_NR_CELL_RMOD_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_RMOD_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_LTE_CELL_RMOD_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_RMOD_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_WCDMA_CELL_RMOD_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_RMOD_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}  ${BTS}
    Run Keyword If  ${${alias}_GSM_CELL_RMOD_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_RMOD_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}  ${BTS}
    Log  All ${BTS} cell(s) mapped on shared RMOD with SN ${RMOD_sn} status as expected!  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}  ${BTS}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  ${BTS} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Get and check KPI51a and KPI51b info from IMS file
    [Documentation]
    ...  Get and check KPI51a and KPI51b info from IMS file.

    [Arguments]  ${RM_id}  ${alias}  ${BTS_RM_reset}  ${CYCLE}

    ${BTS_label}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    ${BTS_label_RM_reset}=  Set Variable If  '${BTS_RM_reset}' == 'Master'  BTS1  BTS2

    ${RM_param}=  Get Parameters For  class_name=RMOD  id_num=${RM_id}  connection=${alias}

    Log Long String  ***** Get and check ${BTS_label} KPI51a and KPI51b info related to shared RM with SN ${RM_param['serialNumber']} reset from
    ...  ${BTS_label_RM_reset} for iteration ${CYCLE} *****  console=True

    ${kpi_name_delta_dict_kpi51a}=  Get and check KPI info from IMS file
    ...  kpi_names=kpi51a  kpi_thresholds=${RM_RESET_WRN_THR}  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}
    ${kpi_delta_list_kpi51a}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51a}  kpi51a

    ${kpi_name_delta_dict_kpi51b}=  Get KPI info
    ...  kpi_names=kpi51b  alias=${alias}  start_point_timestamp_UTC=${date_timestamp_start_resetRM_UTC}
    ...  end_point_timestamp_UTC=${date_timestamp_end_resetRM_UTC}
    ${kpi_delta_list_kpi51b}=  Get From Dictionary  ${kpi_name_delta_dict_kpi51b}  kpi51b

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${BTS_label}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51a  event_value_1=${kpi_delta_list_kpi51a[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${BTS_label_RM_reset}

    Export KPI Results to File  alias=${alias}  obj_info=RMOD productName_serialNumber  obj=BTS KPI measurement
    ...  obj_type=${RM_param['productName']}_${RM_param['serialNumber']}  obj_id=${BTS_label}
    ...  action_1=RM_Reset  kpi_reported_1=KPI_51b  event_value_1=${kpi_delta_list_kpi51b[0]}  cycle=${CYCLE}  source_info=ims
    ...  add_info_label=BTS RM_reset action  add_info_value=${BTS_label_RM_reset}

Recover initial settings for feature CB007878
    [Arguments]  ${alias}
    ${BTS}=  Set Variable If  '${alias}' == 'Master'  BTS1  BTS2
    Log  Recover initial settings for feature CB007878 on ${BTS}:  console=True
    FOR  ${item}  IN  @{${alias}_shared_RMOD_list}
        ${actSharedRUIndControl_initial}=  Get From Dictionary  ${${alias}_RMOD_id_actSharedRUIndControl_initial_dict}  ${item}
        ${actSharedRUIndControl_final}  ${EMPTY}=  Get actSharedRUIndControl and peerBtsActSharedRUIndControl parameters values   ${item}  ${alias}
        Run Keyword If  '${actSharedRUIndControl_final}' == '${actSharedRUIndControl_initial}'  Continue For Loop
        Set actSharedRUIndControl parameter value  ${item}  ${actSharedRUIndControl_initial}  ${alias}
    END

Particular Teardown
    Run Keyword If  ${Master_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Master
    Run Keyword If  ${Slave_CB007878_check}
    ...  Run Keyword And Continue On Failure  Recover initial settings for feature CB007878  Slave
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
