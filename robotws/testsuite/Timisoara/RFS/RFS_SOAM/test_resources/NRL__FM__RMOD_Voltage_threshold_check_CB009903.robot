*** Settings ***
Documentation    TC__NRL__FM__RMOD_Voltage_threshold_check_CB009903
Variables    tc_variables/nrl__fm__rmod_voltage_threshold_check_CB009903_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                               # Number of test operations, default value 3
${RMOD_SN_LIST}                                    # Shared RMODs serial numbers list used for alarm check. List elements are separated by comma
                                                   # (e.g. YK203400063, LK203400080)
${PSU_HOST_IP}                                     # Host IP of PSU for establishing connection. Example: 10.255.5.158
${PSU_PORT}  1                                     # Port of PSU for establishing connection. Default value: 1
${PSU_TYPE}  PSU                                   # Type of PSU. Default value: PSU
${THRESHOLD_VOLTAGE_LEVEL}  LOW                    # Requested threshold voltage level to be set: LOW (check FID 2920, FID 4680)
                                                   # or HIGH (check FID 2919, FID 4680) by default LOW
${alVoltUnstableThreshold}  3                      # BTS threshold for RMOD input voltage unstable alarm, default value 3
${alVoltLowThreshold}  -116                        # BTS threshold for RMOD input voltage too low alarm, default value -116% of nominal 50V
${alVoltHighThreshold}  114                        # BTS threshold for RMOD input voltage too high alarm, default value 114 of nominal 50V
${alVoltLowThresholdMinor}  -112                   # BTS threshold for RMOD input voltage too low alarm, default value -112% of nominal 50V
${alVoltHighThresholdMinor}  107                   # BTS threshold for RMOD input voltage too high alarm, default value 107% of nominal 50V
${PSU_VoltageLow}  37                              # PSU voltage for low threshold set; default value 37
${PSU_VoltageHigh}  59                             # PSU voltage for high threshold set; default value 59
${PSU_VoltageLowMinor}  38                         # PSU voltage for low threshold set; default value 38
${PSU_VoltageHighMinor}  58                        # PSU voltage for high threshold set; default value 58

*** Keywords ***
TC__NRL__FM__RMOD_Voltage_threshold_check_CB009903
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23533
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-LTE test case for raise/clear alarms due to RMOD voltage threshold change, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both BTS
    ...  - get and check RMOD and cell info
    ...  - check BTS voltage threshold settings for RMODs on BTS primary controller
    ...  - check PSU settings
    ...  - set PSU voltage checking both BTS state and alarms
    ...  - check final state and alarms for both BTS
    ...  - check reset behavior on both BTS based on info from IMS file as follows:
    ...    - BTS Master site: reset number is 0
    ...    - BTS Slave site: reset number is 0
    ...  Pass criteria: raise/clear alarms due to RMOD voltage threshold change works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26981 -
    ...  [5G] Actual robot NRL__STATE__FID_2919_or_FID_2920_reported_and_cleared_by_FID_4680 needs enhancements based on CB009903
    ...  - 13.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28850 - Enhance NRL__FM__RMOD_Voltage_threshold_check_CB009903 to work
    ...  when 2 RUs are connected to the same PSU
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29822 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NRL
    ...

    Set Tags    CA-STATE    OWNER-ariel.ciucurita@nokia.com    AUTHOR-ariel.ciucurita@nokia.com    PHASE-QT    SW-SBTS24

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get and check RMOD and cell info
    Step 4: Check BTS voltage threshold settings for RMODs
    Step 5: Check PSU settings
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER} + 1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 6: Set PSU voltage checking both BTS state and alarms
        Step 7: Check final all BTS state
        Step 8: Check final all BTS alarms
        Step 9: Check BTS reset behavior
        Step 10: Check final number and state of Cells and RMs
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

Step ${index}: Get and check RMOD and cell info
    [Documentation]
    ...  Get and check RMOD and cell info

    Log  Step ${index}: Get and check RMOD and cell info  console=True
    ${Master_shared_RMOD_list}  ${Slave_shared_RMOD_list}  ${Master_dedicated_RMOD_list}  ${Slave_dedicated_RMOD_list}=
    ...  Admin Get shared and dedicated module list for Master and Slave  RMOD  Master  Slave

    Get RMOD ID SN dict  Master
    Get RMOD ID SN dict  Slave
    ${Master_RMOD_SN_list}=  Get Dictionary Keys  ${Master_module_SN_ID_dict}
    ${Slave_RMOD_SN_list}=  Get Dictionary Keys  ${Slave_module_SN_ID_dict}
    ${Shared_RMOD_SN_list}=  Create List
    FOR  ${item}  IN  @{Master_RMOD_SN_list}
        Run Keyword If  '${item}' in ${Slave_RMOD_SN_list}
        ...  Append To List  ${Shared_RMOD_SN_list}  ${item}
    END

    ${RMOD_SN_LIST_strip}=  Replace String  ${RMOD_SN_LIST}  ${SPACE}  ${EMPTY}
    ${RMOD_SN_LIST}=  Split String  ${RMOD_SN_LIST_strip}  ,
    Set Test Variable  ${RMOD_SN_LIST}

    ${Master_RMOD_ID_LIST}=  Create List
    ${Slave_RMOD_ID_LIST}=  Create List

    FOR  ${RMOD_SN}  IN  @{RMOD_SN_LIST}
        Run Keyword If  '${RMOD_SN}' == '' or '${RMOD_SN}' not in ${Shared_RMOD_SN_list}  Run Keywords
        ...  Log  Improper RMOD SN ${RMOD_SN} found in argument RMOD_SN_LIST \${RMOD_SN_LIST}. Accepted value(s): ${Shared_RMOD_SN_list}  level=ERROR
        ...  AND  Fail  Improper RMOD SN ${RMOD_SN} found in argument RMOD_SN_LIST \${RMOD_SN_LIST}

        ${Master_RMOD_ID}=  Get From Dictionary  ${Master_module_SN_ID_dict}  ${RMOD_SN}
        ${Slave_RMOD_ID}=  Get From Dictionary  ${Slave_module_SN_ID_dict}  ${RMOD_SN}
        Append To List   ${Master_RMOD_ID_LIST}  ${Master_RMOD_ID}
        Append To List   ${Slave_RMOD_ID_LIST}  ${Slave_RMOD_ID}
        Log  Shared RMOD with SN ${RMOD_SN} info:  console=True
        Log  - Master RMOD id: ${Master_RMOD_ID}  console=True
        Log  - Slave RMOD id: ${Slave_RMOD_ID}  console=True
    END

    Set Test Variable  ${Master_RMOD_ID_LIST}
    Set Test Variable  ${Slave_RMOD_ID_LIST}

    ${Master_BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=Master
    ${Slave_BTS_primary_controller_RMOD_list}=  Get RMOD radioMaster info  alias=Slave
    ${BTS_primary_controller}=  Set Variable If
    ...  '${Master_RMOD_ID}' in ${Master_BTS_primary_controller_RMOD_list}  Master
    ...  '${Slave_RMOD_ID}' in ${Slave_BTS_primary_controller_RMOD_list}  Slave
    ${BTS_secondary_controller}=  Set Variable If  '${BTS_primary_controller}' == 'Master'  Slave  Master
    Set Test Variable  ${BTS_primary_controller}
    Set Test Variable  ${BTS_secondary_controller}
    Log  - BTS primary controller role: ${BTS_primary_controller}  console=True

    ${RMOD_Id_RMOD_SCF_dn_dict}=  Create Dictionary
    ${Primary_Controller_RMOD_Id_CELL_list_dict}=  Create Dictionary
    ${Secondary_Controller_RMOD_Id_CELL_list_dict}=  Create Dictionary

    Set Test Variable    ${RMOD_Id_RMOD_SCF_dn_dict}
    Set Test Variable    ${Primary_Controller_RMOD_Id_CELL_list_dict}
    Set Test Variable    ${Secondary_Controller_RMOD_Id_CELL_list_dict}

    FOR  ${RMOD_id}  ${RMOD_id_SC}  IN ZIP  ${${BTS_primary_controller}_RMOD_ID_LIST}  ${${BTS_secondary_controller}_RMOD_ID_LIST}
        ${RMOD_SCF_DN}=  Get RMOD SCF distinguished name  ${RMOD_id}  ${BTS_primary_controller}
        Set To Dictionary  ${RMOD_Id_RMOD_SCF_dn_dict}  ${RMOD_id}=${RMOD_SCF_DN}
        Log  - ${BTS_primary_controller} RMOD ${RMOD_id} SCF dn: ${RMOD_SCF_DN}  console=True

        ${RMOD_CELL_list_PC}=  Get Cell Mapping By Module Id  module_id=${RMOD_id}  connection=${BTS_primary_controller}
        Set To Dictionary  ${Primary_Controller_RMOD_Id_CELL_list_dict}  ${RMOD_id}=${RMOD_CELL_list_PC}

        ${RMOD_CELL_list_SC}=  Get Cell Mapping By Module Id  module_id=${RMOD_id_SC}  connection=${BTS_secondary_controller}
        Set To Dictionary  ${Secondary_Controller_RMOD_Id_CELL_list_dict}  ${RMOD_id_SC}=${RMOD_CELL_list_SC}

        Log  - ${BTS_primary_controller} mapped cell list: ${RMOD_CELL_list_PC}  console=True
        Log  - ${BTS_secondary_controller} mapped cell list: ${RMOD_CELL_list_SC}  console=True
    END

    ${all_BTS_RMOD_id_CELL_ids_info}=  Get all BTS Cells mapped on RMOD info
    Set Test Variable  ${all_BTS_RMOD_id_CELL_ids_info}

    ${BTS_alias_list}=  Create List  ${BTS_primary_controller}  ${BTS_secondary_controller}

    FOR  ${alias}  IN  @{BTS_alias_list}
        ${BTS_RMOD_id_CELL_ids_info}=  Get From Dictionary  ${all_BTS_RMOD_id_CELL_ids_info}  ${alias}
        ${RMOD_id_NR_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_NR_CELL_ids_dict
        ${RMOD_id_LTE_CELL_ids_dict}=  Get From Dictionary  ${BTS_RMOD_id_CELL_ids_info}  RMOD_id_LTE_CELL_ids_dict
        ${RMOD_NR_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_NR_CELL_ids_dict}  ${${alias}_RMOD_id}
        ${RMOD_LTE_CELL_ids_list}=  Get From Dictionary  ${RMOD_id_LTE_CELL_ids_dict}  ${${alias}_RMOD_id}
        Set Test Variable  ${${alias}_RMOD_NR_CELL_ids_list}  ${RMOD_NR_CELL_ids_list}
        Set Test Variable  ${${alias}_RMOD_LTE_CELL_ids_list}  ${RMOD_LTE_CELL_ids_list}
    END

Step ${index}: Check BTS voltage threshold settings for RMODs
    [Documentation]
    ...  Check BTS voltage threshold settings for RMODs

    Log  Step ${index}: Check BTS voltage threshold settings for RMODs  console=True
    ${PSU_Voltage}=  Set Variable If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'  ${PSU_VoltageLow}
    ...  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'  ${PSU_VoltageHigh}
    ${PSU_VoltageMinor}=  Set Variable If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'  ${PSU_VoltageLowMinor}
    ...  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'  ${PSU_VoltageHighMinor}
    Run Keyword If  ${PSU_Voltage} <= 35 or ${PSU_Voltage} >= 61  Run Keywords
    ...  Log  VoltageNotInRange: Voltage ${PSU_Voltage} is not in the supported range: 36-60  level=ERROR
    ...  AND  Fail  VoltageNotInRange: Voltage ${PSU_Voltage} is not in the supported range: 36-60
    Run Keyword If  ${PSU_VoltageMinor} <= 35 or ${PSU_VoltageMinor} >= 61  Run Keywords
    ...  Log  VoltageNotInRange: Voltage ${PSU_VoltageMinor} is not in the supported range: 36-60  level=ERROR
    ...  AND  Fail  VoltageNotInRange: Voltage ${PSU_VoltageMinor} is not in the supported range: 36-60
    Set Test Variable  ${PSU_Voltage}
    Set Test Variable  ${PSU_VoltageMinor}

    ${all_voltage_info_initial_dict}=  Create Dictionary

    Set Test Variable  ${SCF_alVoltLowThreshold}  ${alVoltLowThreshold}
    Set Test Variable  ${SCF_alVoltHighThreshold}  ${alVoltHighThreshold}
    Set Test Variable  ${SCF_alVoltLowThresholdMinor}  ${alVoltLowThresholdMinor}
    Set Test Variable  ${SCF_alVoltHighThresholdMinor}  ${alVoltHighThresholdMinor}

    FOR  ${RMOD_ID}  IN  @{${BTS_primary_controller}_RMOD_ID_LIST}

        Log  BTS ${BTS_primary_controller} RMOD ${RMOD_ID}  console=True

        ${SCF_alVoltLowThreshold_initial}  ${SCF_alVoltHighThreshold_initial}  ${SCF_alVoltLowThresholdMinor_initial}
        ...  ${SCF_alVoltHighThresholdMinor_initial}  ${SCF_alVoltUnstableThreshold_initial}=  Get RMOD Input Voltage Threshold parameter info
        ...  ${RMOD_ID}  ${BTS_primary_controller}

        ${RMOD_voltage_info_initial_dict}=  Create Dictionary
        Set To Dictionary  ${RMOD_voltage_info_initial_dict}
        ...  alVoltLowThreshold_initial=${SCF_alVoltLowThreshold_initial}
        ...  alVoltHighThreshold_initial=${SCF_alVoltHighThreshold_initial}
        ...  alVoltLowThresholdMinor_initial=${SCF_alVoltLowThresholdMinor_initial}
        ...  alVoltHighThresholdMinor_initial=${SCF_alVoltHighThresholdMinor_initial}
        ...  alVoltUnstableThreshold_initial=${SCF_alVoltUnstableThreshold_initial}

        Set To Dictionary  ${all_voltage_info_initial_dict}  ${RMOD_ID}=${RMOD_voltage_info_initial_dict}

        Log  Initial BTS voltage threshold settings RMOD ${RMOD_ID} on BTS ${BTS_primary_controller}:  console=True
        Run Keyword If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'
        ...  Log  - parameter alVoltLowThreshold = ${SCF_alVoltLowThreshold_initial}  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'
        ...  Log  - parameter alVoltHighThreshold = ${SCF_alVoltHighThreshold_initial}  console=True
        Run Keyword If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'
        ...  Log  - parameter alVoltLowThresholdMinor = ${SCF_alVoltLowThresholdMinor_initial}  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'
        ...  Log  - parameter alVoltHighThresholdMinor = ${SCF_alVoltHighThresholdMinor_initial}  console=True
        Log  - parameter alVoltUnstableThreshold = ${SCF_alVoltUnstableThreshold_initial}  console=True

        ${RMOD_SCF_DN}=  Get From Dictionary  ${RMOD_Id_RMOD_SCF_dn_dict}  ${RMOD_ID}

        Run Keyword If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW' and '${SCF_alVoltLowThreshold_initial}' == '${SCF_alVoltLowThreshold}'
        ...  Log  Parameter alVoltLowThreshold = ${alVoltLowThreshold} already set, no action needed!  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'  Run Keywords
        ...  Log  Need to set parameter alVoltLowThreshold = ${alVoltLowThreshold}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltLowThreshold  BTS_scf_param_value=${SCF_alVoltLowThreshold}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH' and '${SCF_alVoltHighThreshold_initial}' == '${SCF_alVoltHighThreshold}'
        ...  Log  Parameter alVoltHighThreshold = ${alVoltHighThreshold} already set, no action needed!  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'  Run Keywords
        ...  Log  Need to set parameter alVoltHighThreshold = ${alVoltHighThreshold}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltHighThreshold  BTS_scf_param_value=${SCF_alVoltHighThreshold}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}

        Run Keyword If  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW' and '${SCF_alVoltLowThresholdMinor_initial}' == '${SCF_alVoltLowThresholdMinor}'
        ...  Log  Parameter alVoltLowThresholdMinor = ${alVoltLowThresholdMinor} already set, no action needed!  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW'  Run Keywords
        ...  Log  Need to set parameter alVoltLowThresholdMinor = ${alVoltLowThresholdMinor}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltLowThresholdMinor  BTS_scf_param_value=${SCF_alVoltLowThresholdMinor}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH' and '${SCF_alVoltHighThresholdMinor_initial}' == '${SCF_alVoltHighThresholdMinor}'
        ...  Log  Parameter alVoltHighThresholdMinor = ${alVoltHighThresholdMinor} already set, no action needed!  console=True
        ...  ELSE IF  '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH'  Run Keywords
        ...  Log  Need to set parameter alVoltHighThresholdMinor = ${alVoltHighThresholdMinor}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltHighThresholdMinor  BTS_scf_param_value=${SCF_alVoltHighThresholdMinor}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}

        Run Keyword If  '${SCF_alVoltUnstableThreshold_initial}' == '${alVoltUnstableThreshold}'
        ...  Log  Parameter alVoltUnstableThreshold = ${alVoltUnstableThreshold} already set, no action needed!  console=True
        ...  ELSE  Run Keywords
        ...  Log  Need to set parameter alVoltUnstableThreshold = ${alVoltUnstableThreshold}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltUnstableThreshold  BTS_scf_param_value=${alVoltUnstableThreshold}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}

    END

    Set Test Variable  ${all_voltage_info_initial_dict}

Step ${index}: Check PSU settings
    [Documentation]
    ...  Check PSU settings

    Log  Step ${index}: Check PSU settings  console=True
    pdu.setup_pdu  model=${PSU_TYPE}  host=${PSU_HOST_IP}  alias=PSU_alias
    ${PSU_voltage_initial}=  pdu.get_voltage  pdu_device=PSU_alias
    Log  PSU voltage initial value for RMODs ${RMOD_SN_LIST}: ${PSU_voltage_initial}  console=true
    Set Test Variable  ${PSU_voltage_initial}
    pdu.teardown_pdu  pdu_device=PSU_alias

Step ${index}: Set PSU voltage checking both BTS state and alarms
    [Documentation]
    ...  Set PSU voltage checking both BTS state and alarms

    Log  Step ${index}: Set PSU voltage checking both BTS state and alarms  console=True

    Get Current Date UTC info  start_set_PSU_voltage

    ${RMOD_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, administrativeState=${Unlocked_}
    ${RMOD_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    ${CELL_state_disabled_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Failed_}, blockingState=${Unblocked_}
    ${CELL_state_enabled_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${RMOD_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, administrativeState=Unlocked
    ${RMOD_state_enabled}=  Set Variable  operationalState=Enabled, administrativeState=Unlocked
    ${CELL_state_disabled}=  Set Variable  operationalState=Disabled, availabilityStatus=Failed, blockingState=Unblocked
    ${CELL_state_enabled}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    Set Test Variable  ${RMOD_state_disabled_check}
    Set Test Variable  ${RMOD_state_enabled_check}
    Set Test Variable  ${CELL_state_disabled_check}
    Set Test Variable  ${CELL_state_enabled_check}
    Set Test Variable  ${RMOD_state_disabled}
    Set Test Variable  ${RMOD_state_enabled}
    Set Test Variable  ${CELL_state_disabled}
    Set Test Variable  ${CELL_state_enabled}

    Log  Start PSU set operation until reach the configured threshold: ${alVoltUnstableThreshold}  console=True

    ${operation_numbers}=  Evaluate  ${alVoltUnstableThreshold}*2

    FOR  ${INDEX}  IN RANGE  1  ${operation_numbers} + 1

        Log  ***** Start PSU set operation number: ${INDEX} of ${operation_numbers} *****  console=True

        ${Fault_id}=  Set Variable If  (${INDEX} < ${operation_numbers} and '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW')  2920
        ...  (${INDEX} < ${operation_numbers} and '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH')  2919
        ...  ${INDEX} == ${operation_numbers}  4680
        ${Fault_name}=  Set Variable If  (${INDEX} < ${operation_numbers} and '${THRESHOLD_VOLTAGE_LEVEL}' == 'LOW')  RU input voltage Low
        ...  (${INDEX} < ${operation_numbers} and '${THRESHOLD_VOLTAGE_LEVEL}' == 'HIGH')  RU input voltage High
        ...  ${INDEX} == ${operation_numbers}  RU input voltage unstable

        Run keyword if  ${INDEX%2} == 0
        ...  PSU set operation  ${PSU_Voltage}
        ...  ELSE  PSU set operation  ${PSU_VoltageMinor}
        Check BTS alarm  ${Fault_id}  ${Fault_name}  ${BTS_primary_controller}
        Run keyword if  ${INDEX%2} == 0
        ...  Check RMOD and cell status  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}
        ...  ${CELL_state_disabled}  ${BTS_primary_controller}
        ...  ELSE  Check RMOD and cell status  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}
        ...  ${CELL_state_enabled}  ${BTS_primary_controller}
        Run keyword if  ${INDEX%2} == 0
        ...  Check BTS alarm  ${Fault_id}  ${Fault_name}  ${BTS_secondary_controller}
        ...  ELSE  Check BTS alarm  ${EMPTY}  ${EMPTY}  ${BTS_secondary_controller}
        Run keyword if  ${INDEX%2} == 0
        ...  Check RMOD and cell status  ${RMOD_state_disabled_check}  ${RMOD_state_disabled}
        ...  ${CELL_state_disabled}  ${BTS_secondary_controller}
        ...  ELSE  Check RMOD and cell status  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}
        ...  ${CELL_state_enabled}  ${BTS_secondary_controller}
        PSU set operation  50
        Run keyword if  (${INDEX%2} == 0 and ${INDEX} < ${operation_numbers})
        ...  Sleep  300s
        ...  ELSE  Sleep  30s

        Run Keyword If  ${INDEX} == ${operation_numbers}  Run Keywords
        ...  Log  Perform "Reset" operation on shared RMODs with SNs ${RMOD_SN_LIST} from BTS ${BTS_primary_controller}  console=True
        ...  AND  Reset Impacted Radio Units  ${BTS_primary_controller}
        Check BTS alarm  ${EMPTY}  ${EMPTY}  ${BTS_primary_controller}
        Check RMOD and cell status  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${CELL_state_enabled}
        ...  ${BTS_primary_controller}
        Check BTS alarm  ${EMPTY}  ${EMPTY}  ${BTS_secondary_controller}
        Check RMOD and cell status  ${RMOD_state_enabled_check}  ${RMOD_state_enabled}  ${CELL_state_enabled}
        ...  ${BTS_secondary_controller}

    END

Step ${index}: Check BTS reset behavior
    [Documentation]
    ...  BTS reset info is checked based on IMS info.
    ...  Reset behavior as expected in following conditions:
    ...  - BTS Master site: reset number is 0
    ...  - BTS Slave site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.

    Log  Step ${index}: Check BTS reset behavior  console=True

    Get Current Date UTC info  end_set_PSU_voltage

    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Master  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_set_PSU_voltage_UTC}  end_point_timestamp_UTC=${date_timestamp_end_set_PSU_voltage_UTC}
    Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=Slave  remove_ims_file=False
    ...  start_point_timestamp_UTC=${date_timestamp_start_set_PSU_voltage_UTC}  end_point_timestamp_UTC=${date_timestamp_end_set_PSU_voltage_UTC}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

PSU set operation
    [Arguments]  ${PSU_Voltage}
    Log  Set PSU voltage: ${PSU_Voltage}  console=True
    Get Current Time  set_PSU
    Log  Set PSU timestamp: ${time_set_PSU}  console=True
    pdu.setup_pdu  model=${PSU_TYPE}  host=${PSU_HOST_IP}  alias=PSU_alias
    ${PSU_PORT_int}=  Convert To Integer  ${PSU_PORT}
    pdu.set_voltage  port=${PSU_PORT_int}  voltage=${PSU_Voltage}  pdu_device=PSU_alias
    Sleep  10sec
    ${PSU_voltage_set}=  pdu.get_voltage  pdu_device=PSU_alias
    Log  PSU voltage after change: ${PSU_voltage_set}  console=true
    Set Test Variable  ${PSU_PORT_int}
    pdu.teardown_pdu  pdu_device=PSU_alias

Check BTS alarm
    [Arguments]  ${Fault_id}  ${Fault_name}  ${alias}

    Log  Check BTS ${alias} alarm  console=True

    ${nb_of_alarms}=  Get Length   ${${alias}__RMOD_ID_LIST}
    ${EXPECTED_ALARMS}=  Create List
    ${EXPECTED_ALARMS}=  Set Variable If  '${Fault_id}' != '${EMPTY}'  ${${alias.upper()}_EXPECTED_ALARMS_${Fault_id}}  ${EXPECTED_ALARMS}
    ${EXPECTED_ALARMS}=  Prepare expected alarms list  ${EXPECTED_ALARMS}  ${nb_of_alarms}

    Run Keyword If  '${Fault_name}' != '${EMPTY}'
    ...  Log  BTS ${alias} "${Fault_name} (${Fault_id})" alarm, expected number: ${nb_of_alarms}  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=${EXPECTED_ALARMS}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  '${Fault_name}' != '${EMPTY}'
    ...  Log  BTS ${alias} "${Fault_name} (${Fault_id})" alarm, found number: ${nb_of_alarms}, as expected  console=True
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

Check RMOD and cell status
    [Arguments]  ${RMOD_state_check}  ${RMOD_state}  ${CELL_state}  ${alias}
    ${TECH}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH]
    ${CELL_class}=  Set Variable If  '${TECH}' == 'NR'  NRCEL  '${TECH}' == 'LTE'  LNCEL

    Log  Check BTS ${alias} state  console=True

    ${RMOD_ID_list}=  Create List
    Append To List  ${RMOD_ID_list}  @{${alias}_RMOD_ID_LIST}
    Check BTS Item State  RMOD  ${RMOD_ID_list}  ${RMOD_state_check}  300  ${alias}
    Log  BTS ${alias} shared impated RMODs status:\n - ${RMOD_state}, as expected.  console=True

    Check cells state mapped on RMODs  ${alias}
    Log  BTS ${alias} impacted cell(s) status:\n - ${CELL_state}, as expected.  console=True

Check BTS Item State
    [Arguments]  ${BTS_item_class}  ${BTS_item_list}  ${BTS_item_state_check}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{BTS_item_list}
        Assert  class_name=${BTS_item_class}  id=${item}  parameters=${BTS_item_state_check}  timeout=${timeout}  connection=${alias}
    END

Check cells state mapped on RMODs
    [Arguments]  ${alias}

    ${BTS_ALARM_COUNT_MIMO}=  Set Variable  0
    ${ALARM_COUNT_MIMO}=  Set Variable  0

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_RMOD_NR_CELL_ids_list}  alias=${alias}
    ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_NR_CELL_ids_list}
    ...  Set Variable  ${NR_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    ${ALARM_COUNT_MIMO}=  Set Variable  0
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_RMOD_LTE_CELL_ids_list}  alias=${alias}
    ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_RMOD_LTE_CELL_ids_list}
    ...  Set Variable  ${LTE_cell_state_failed_list}
    ...  ELSE  Create List
    ${BTS_ALARM_COUNT_MIMO}=  Evaluate  ${BTS_ALARM_COUNT_MIMO} + ${ALARM_COUNT_MIMO}

    Set Test Variable  ${${alias}_RMOD_NR_cell_state_failed_list}  ${NR_cell_state_failed_list}
    Set Test Variable  ${${alias}_RMOD_LTE_cell_state_failed_list}  ${LTE_cell_state_failed_list}

Recover initial settings for BTS
    [Documentation]
    ...  Recover initial settings for BTS

    FOR  ${RMOD_Id}  IN  @{${BTS_primary_controller}_RMOD_ID_LIST}

        ${RMOD_voltage_info_initial}=  Get From Dictionary  ${all_voltage_info_initial_dict}  ${RMOD_Id}
        ${RMOD_SCF_DN}=  Get From Dictionary  ${RMOD_Id_RMOD_SCF_dn_dict}  ${RMOD_ID}

        ${SCF_alVoltLowThreshold_initial}=  Get From Dictionary  ${RMOD_voltage_info_initial}  alVoltLowThreshold_initial
        ${SCF_alVoltHighThreshold_initial}=  Get From Dictionary  ${RMOD_voltage_info_initial}  alVoltHighThreshold_initial
        ${SCF_alVoltLowThresholdMinor_initial}=  Get From Dictionary  ${RMOD_voltage_info_initial}  alVoltLowThresholdMinor_initial
        ${SCF_alVoltHighThresholdMinor_initial}=  Get From Dictionary  ${RMOD_voltage_info_initial}  alVoltHighThresholdMinor_initial
        ${SCF_alVoltUnstableThreshold_initial}=  Get From Dictionary  ${RMOD_voltage_info_initial}  alVoltUnstableThreshold_initial

        ${SCF_alVoltLowThreshold_final}  ${SCF_alVoltHighThreshold_final}  ${SCF_alVoltHighThresholdMinor_final}  ${SCF_alVoltLowThresholdMinor_final}
        ...    ${SCF_alVoltUnstableThreshold_final}=  Get RMOD Input Voltage Threshold parameter info
        ...  ${RMOD_Id}  ${BTS_primary_controller}
        Run Keyword If  '${SCF_alVoltLowThreshold_final}' != '${SCF_alVoltLowThreshold_initial}'  Run Keywords
        ...  Log  Need to set parameter alVoltLowThreshold = ${SCF_alVoltLowThreshold_initial}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltLowThreshold  BTS_scf_param_value=${SCF_alVoltLowThreshold_initial}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        Run Keyword If  '${SCF_alVoltHighThreshold_final}' != '${SCF_alVoltHighThreshold_initial}'  Run Keywords
        ...  Log  Need to set parameter alVoltHighThreshold = ${SCF_alVoltHighThreshold_initial}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltHighThreshold  BTS_scf_param_value=${SCF_alVoltHighThreshold_initial}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        Run Keyword If  '${SCF_alVoltLowThresholdMinor_final}' != '${SCF_alVoltLowThresholdMinor_initial}'  Run Keywords
        ...  Log  Need to set parameter alVoltLowThresholdMinor = ${SCF_alVoltLowThresholdMinor_initial}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltLowThresholdMinor  BTS_scf_param_value=${SCF_alVoltLowThresholdMinor_initial}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        Run Keyword If  '${SCF_alVoltHighThresholdMinor_final}' != '${SCF_alVoltHighThresholdMinor_initial}'  Run Keywords
        ...  Log  Need to set parameter alVoltHighThresholdMinor = ${SCF_alVoltHighThresholdMinor_initial}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltHighThresholdMinor  BTS_scf_param_value=${SCF_alVoltHighThresholdMinor_initial}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
        Run Keyword If  '${SCF_alVoltUnstableThreshold_final}' != '${SCF_alVoltUnstableThreshold_initial}'  Run Keywords
        ...  Log  Need to set parameter alVoltUnstableThreshold = ${SCF_alVoltUnstableThreshold_initial}  console=True
        ...  AND  Admin Perform BTS SCF Parameter Recommissioning for specific DN  BTS_scf_distName=${RMOD_SCF_DN}
        ...  BTS_scf_param_name=alVoltUnstableThreshold  BTS_scf_param_value=${SCF_alVoltUnstableThreshold_initial}  BTS_scf_operation=update
        ...  alias=${BTS_primary_controller}
    END

Recover initial settings for PSU
    [Documentation]
    ...  Recover initial settings for PSU

    ${PSU_voltage_final}=  pdu.get_voltage  pdu_device=PSU_alias
    Run Keyword If  '${PSU_voltage_final}' != '${PSU_voltage_initial}'  Run Keywords
    ...  pdu.setup_pdu  model=${PSU_TYPE}  host=${PSU_HOST_IP}  alias=PSU_alias
    ...  AND  pdu.set_voltage  port=${PSU_PORT_int}  voltage=50  pdu_device=PSU_alias
    ...  AND  Log  Set PSU voltage value 50 indicated  console=True
    ...  AND  Log  Wait 3 seconds for PSU reactivity  console=True
    ...  AND  Sleep  3sec
    ...  AND  pdu.teardown_pdu  pdu_device=PSU_alias

Reset Impacted Radio Units
    [Arguments]  ${alias}

    FOR  ${RMOD_Id}  IN  @{${alias}_RMOD_ID_LIST}
        coam.Reset Unit  dist_name=${RMOD_Id}  reset_type=Hard  timeout=600   connection=${alias}
    END

Particular Teardown
    Recover initial settings for PSU
    Recover initial settings for BTS

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
