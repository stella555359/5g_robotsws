*** Settings ***
Documentation    TC__SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
Variables    tc_variables/sbts_sbts__state__rm_reset_when_non_critical_dfe_is_broken_cni_113670_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}          3      # Number of RM reset operations, default value 3
${RM_CONFIGURED_INFO}      ALL    # RM configuration connectivity impacted by RM reset operations: ALL, Shared or Dedicated. By default ALL
${RM_SERIAL_NUMBER_LIST}   ALL    # RM serial number list on which reset operation will be performed.
                                  # Possible values: ALL (operation will be performed on all shared and dedicated RMs) or list of selected
                                  # shared or dedicated RM serial number separated by comma. By default ALL
${GRACEFUL_CELL_SHUTDOWN}  True  # Graceful cell shutdown: True or False; default value: True
${USER_RSI_INFO_COLLECT}     True  # Flag to enable/disable RMOD serial interface logs  collection. By default True


*** Keywords ***
TC__SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27738
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  SBTS-SBTS test case for RM Reset when non critical DFE is broken CNI 113670
    ...
    ...  The main steps performed for the test are:
    ...
    ...  - check initial state and alarms for all BTS
    ...  - get both BTS info for configured items: BTS role (primary/secondary controller per BTS), shared RM info and cells info
    ...  - perform RM reset via serial command as follows:
    ...     - create preventerResetCounter file with value 4
    ...     - perform RM reset from LMI
    ...     - check alarms during RM reset from LMI
    ...     - deactivate DFE on RM from LMI
    ...     - check BTS states and alarms after DFE deactivated on RM from LMI
    ...     - recover RM by performing RM reset from Webem
    ...     - check BTS states and alarms after reset RM
    ...     - remove preventerResetCounter file
    ...  - check final state and alarms for all BTS
    ...
    ...  Pass criteria: Scenario works as expected, states and alarms are as expected
    ...  ***************************
    ...  ***************************
    ...  History of changes for SOAM
    ...  ***************************
    ...  - 02.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27738 - [5G][CNI-113670] New TC
    ...  SBTS_SBTS__STATE_reset_Radio_Module__when_Non-Critical_DFE_is_broken_with CNI-113670
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28126 - [5G] CNI : 131510 - Classical - Part 1 - Graceful cell shutdown
    ...  - 15.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28138 -
    ...  [5G] Adapt SBTS_SBTS__STATE__RM_Reset_when_non_critical_DFE_is_broken_CNI_113670 to work with the new taf.hw.rmod_serial_interface library
    ...  - 18.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27744 - switch to lmi_light RFRL
    ...  - 10.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29015 - Adapt DFE test-cases to "serviceuser" usage instead of "rfsw"

    Set Tags    CA-STATE    OWNER-constantin.diaconu@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-QT    SW-SBTS24R3

    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform RM Reset via serial command for iteration ${INDEX}
        Step 5: Check final all BTS state
        Step 6: Check final all BTS alarms
        Step 7: Check final number and state of Cells and RMs
    END

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

Step ${index}: Get all BTS info for configured items

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${RM_sn_bts-alias_dict}  ${shared_RM_sn_list}  ${dedicated_RM_sn_list}=  Admin Get RM sn bts-alias info dict
    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${all_RM_sn_list}=  Combine Lists   ${shared_RM_sn_list}  ${dedicated_RM_sn_list}
    Set Test Variable  ${all_RM_sn_list}
    Set Test Variable  ${RM_sn_bts-alias_dict}

    Run Keyword If  '${RM_SERIAL_NUMBER_LIST}' != 'ALL'  Check RM serial number list

    FOR  ${alias}  IN  @{alias_list}

        ${BTS_dedicated_RM_sn_list}=  Get dedicated RMOD list   ${dedicated_RM_sn_list}  ${alias}
        ${BTS_primary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}=
        ...  Get BTS controller role shared RM SN list from SCF  ${shared_RM_sn_list}  ${alias}
        Set Test Variable  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  ${BTS_secondary_controller_shared_RM_sn_list}

        Set Test Variable  ${${alias}_BTS_dedicated_RM_sn_list}  ${BTS_dedicated_RM_sn_list}
        ${BTS_all_impacted_RM_sn_list}=  Combine Lists  ${BTS_dedicated_RM_sn_list}  ${BTS_primary_controller_shared_RM_sn_list}
        Set Test Variable  ${${alias}_BTS_all_impacted_RM_sn_list}  ${BTS_all_impacted_RM_sn_list}

        Get BTS CELL list by RAT  ${alias}

    END

    FOR  ${RM_sn}  IN  @{all_RM_sn_list}

        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
        Get RM info  ${RM_sn}  ${RM_bts-alias_list}

    END

Step ${index}: Perform RM Reset via serial command for iteration ${CYCLE}

    Log  Step ${index}: Perform RM Reset via serial command for iteration ${CYCLE}  console=True

    Set Test Variable  ${RM_state_degraded_check}  operationalState=${Enabled_}, availabilityStatus=${Degraded_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_degraded}  operationalState=Enabled, availabilityStatus=Degraded, administrativeState=Unlocked
    Set Test Variable  ${RM_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${RM_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    FOR  ${alias}  IN  @{alias_list}
        Perform RM Reset via serial command  ${alias}
    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Cells state is checked according to operationalState attribute
    ...  Check if number of configured cells and radio modules in SCF are properly mapping on BTS running view.
    ...  Also check RMs operationalState

    [Timeout]  30 min
    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check RM serial number list
    ${RM_SERIAL_NUMBER_LIST_strip}=  Replace String  ${RM_SERIAL_NUMBER_LIST}  ${SPACE}  ${EMPTY}
    ${RM_SERIAL_NUMBER_LIST}=  Split String  ${RM_SERIAL_NUMBER_LIST_strip}  ,
    ${RM_sn_check}=  Set Variable  True
    ${RM_SN_invalide_list}=  Create List
    FOR  ${item}  IN  @{RM_SERIAL_NUMBER_LIST}
        ${RM_sn_check}=  Set Variable If  '${item}' not in ${all_RM_sn_list}  False  ${RM_sn_check}
        Run Keyword If  '${item}' not in ${all_RM_sn_list}  Append To List  ${RM_sn_invalide_list}  ${item}
    END
    Run Keyword If  '${RM_sn_check}' == 'False'  Run Keywords
    ...  Log  Following selected RM serial number values are not valid: ${RM_sn_invalide_list}.  console=True
    ...  AND  Log  Please select values for test argument \${RM_SERIAL_NUMBER_LIST} from configured RM: ${all_RM_sn_list}
    ...  console=True
    ...  AND  Fail  Improper value for argument!
    Set Test Variable  ${all_RM_sn_list}  ${RM_SERIAL_NUMBER_LIST}

Get dedicated RMOD list
    [Arguments]  ${dedicated_RM_sn_list}  ${alias}

    ${BTS_dedicated_RM_sn_list}=  Create List
    FOR  ${RMOD_sn}  IN  @{dedicated_RM_sn_list}
        ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RMOD_sn}
        Run Keyword If  '${alias}' in ${RM_bts-alias_list}
        ...  Append To List  ${BTS_dedicated_RM_sn_list}  ${RMOD_sn}
    END

    [Return]  ${BTS_dedicated_RM_sn_list}

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

Get RM info
    [Arguments]   ${RM_sn}  ${RM_bts-alias_list}
    Log  RM with SN ${RM_sn} info:  console=True
    FOR  ${alias}  IN  @{RM_bts-alias_list}
        ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
        ${BTS_role}=  Set Variable If  '${RM_sn}' in ${${alias}_BTS_primary_controller_shared_RM_sn_list} or ${${alias}_BTS_dedicated_RM_sn_list}
        ...  Primary Controller  '${RM_sn}' in ${${alias}_BTS_secondary_controller_shared_RM_sn_list}  Secondary Controller
        Log  - BTS ${alias} role: ${BTS_role} -> RM id: ${RM_id}  console=True
    END

Perform RM Reset via serial command
    [Arguments]  ${alias}

    ${RM_sn_list}=  Set Variable If
    ...  '${RM_SERIAL_NUMBER_LIST}' == 'ALL' and '${RM_CONFIGURED_INFO}' == 'ALL'  ${${alias}_BTS_all_impacted_RM_sn_list}
    ...  '${RM_SERIAL_NUMBER_LIST}' == 'ALL' and '${RM_CONFIGURED_INFO}' == 'Shared'  ${${alias}_BTS_primary_controller_shared_RM_sn_list}
    ...  '${RM_SERIAL_NUMBER_LIST}' == 'ALL' and '${RM_CONFIGURED_INFO}' == 'Dedicated'   ${${alias}_BTS_dedicated_RM_sn_list}
    ...  '${RM_SERIAL_NUMBER_LIST}' != 'ALL'  ${all_RM_sn_list}

    FOR  ${RM_sn}  IN  @{RM_sn_list}

        ${RM_dedicated_sn_check}=  Run Keyword And Return Status  List Should Contain Value  ${${alias}_BTS_dedicated_RM_sn_list}  ${RM_sn}
        Run Keyword If  ${RM_dedicated_sn_check}  Perform Dedicated RM Reset  ${RM_sn}  ${alias}

        ${RM_shared_sn_check}=  Run Keyword And Return Status
        ...  List Should Contain Value  ${${alias}_BTS_primary_controller_shared_RM_sn_list}  ${RM_sn}
        Run Keyword If  ${RM_shared_sn_check}  Perform Shared RM Reset  ${RM_sn}  ${alias}

    END

Perform Dedicated RM Reset
    [Arguments]  ${RM_sn}  ${alias}

    Log  =======================================================  console=True
    Log  Perform RM Reset on dedicated RM with SN ${RM_sn}  console=True
    Log  =======================================================  console=True

    ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}

    ${rsi_rmod_setup_status}=  Check if RSI setup was successfully perfomed on RM and create preventerResetCounter file  ${RM_sn}  dedicated
    Run Keyword If  '${rsi_rmod_setup_status}' == 'False'  Run Keywords
    ...  Log  RSI setup couldn't be performed on dedicated RM with SN ${RM_sn}. RM reset will be skipped!  console=True
    ...  AND  Return From Keyword

    Log  Get BTS ${alias} cells mapped on dedicated RM with SN ${RM_sn}:  console=True
    Get RM all cells from specific RAT  ${RM_sn}  ${RM_id}  dedicated  ${alias}

    Perform RM reset from LMI  ${RM_sn}  dedicated

    Log  Check BTS ${alias} alarms during reset dedicated RM with SN ${RM_sn}:  console=True
    Check alarms during RM reset from LMI  ${alias}

    Deactivate DFE on RM from LMI  ${RM_sn}  dedicated

    Log  Check BTS ${alias} states and alarms after DFE deactivated on dedicated RM with SN ${RM_sn}:  console=True
    Check BTS states and alarms after DFE deactivated on RM from LMI  ${RM_sn}  ${RM_id}  ${alias}

    Recover RM by performing RM reset from Webem  ${RM_sn}  ${RM_id}  dedicated  ${alias}

    Log  Check BTS ${alias} state and alarms after reset dedicated RM with SN ${RM_sn}:  console=True
    Check BTS states and alarms after reset RM  ${RM_sn}  ${RM_id}  dedicated  ${alias}

    Remove preventerResetCounter file  ${RM_sn}

Perform Shared RM Reset
    [Arguments]  ${RM_sn}  ${alias}

    Log  =======================================================  console=True
    Log  Perform RM Reset on shared RM with SN ${RM_sn}  console=True
    Log  =======================================================  console=True

    ${RM_id}=  Get From Dictionary  ${${alias}_RM_sn_id_dict}  ${RM_sn}
    ${RM_bts-alias_list}=  Get From Dictionary  ${RM_sn_bts-alias_dict}  ${RM_sn}
    ${RM_peer_bts-alias_list}=  Copy List  ${RM_bts-alias_list}
    Remove Values From List  ${RM_peer_bts-alias_list}  ${alias}
    ${peer_alias}=  Get From List  ${RM_peer_bts-alias_list}  0
    ${peer_RM_id}=  Get From Dictionary  ${${peer_alias}_RM_sn_id_dict}  ${RM_sn}

    ${rsi_rmod_setup_status}=  Check if RSI setup was successfully perfomed on RM and create preventerResetCounter file  ${RM_sn}  shared
    Run Keyword If  '${rsi_rmod_setup_status}' == 'False'  Run Keywords
    ...  Log  RSI setup couldn't be performed on shared RM with SN ${RM_sn}. RM reset will be skipped!  console=True
    ...  AND  Run Keyword And Continue On Failure  Fail  RSI setup couldn't be performed on shared RM with SN ${RM_sn}!
    ...  AND  Return From Keyword

    Log  Get BTS ${alias} and BTS ${peer_alias} cells mapped on shared RM with SN ${RM_sn}:  console=True
    Get RM all cells from specific RAT  ${RM_sn}  ${RM_id}  shared  ${alias}
    Get RM all cells from specific RAT  ${RM_sn}  ${peer_RM_id}  shared  ${peer_alias}

    Perform RM reset from LMI  ${RM_sn}  shared

    Log  Check BTS ${alias} and BTS ${peer_alias} alarms during reset shared RM with SN ${RM_sn}:  console=True
    Check alarms during RM reset from LMI  ${alias}
    Check alarms during RM reset from LMI  ${peer_alias}

    Deactivate DFE on RM from LMI  ${RM_sn}  shared

    Log  Check BTS ${alias} and BTS ${peer_alias} states and alarms after DFE deactivated on shared RM with SN ${RM_sn}:  console=True
    Check both BTS states and alarms after DFE deactivated on RM from LMI  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Recover RM by performing RM reset from Webem  ${RM_sn}  ${RM_id}  shared  ${alias}

    Log  Check BTS ${alias} and BTS ${peer_alias} state and alarms after reset shared RM with SN ${RM_sn}:  console=True
    Check BTS states and alarms after reset RM  ${RM_sn}  ${RM_id}  shared  ${alias}
    Check BTS states and alarms after reset RM  ${RM_sn}  ${peer_RM_id}  shared  ${peer_alias}

    Remove preventerResetCounter file  ${RM_sn}

Get RM all cells from specific RAT
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${alias}
    ${CELL_RM_list}=  Get Cell Mapping By Module Id  module_id=${RM_id}  connection=${alias}
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
    ${CELL_RM_list}=  Combine Lists   ${NR_CELL_RM_list}  ${LTE_CELL_RM_list}  ${WCDMA_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_NR_CELL_RM_list}  ${NR_CELL_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_RM_list}  ${LTE_CELL_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_RM_list}  ${WCDMA_CELL_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_RM_list}  ${GSM_CELL_RM_list}
    Set Test Variable  ${${alias}_CELL_RM_list}  ${CELL_RM_list}
    Log  BTS ${alias} cells mapped on ${configured} RM with SN ${RM_sn}:  console=True
    Run Keyword If  ${NR_CELL_RM_list}  Log  - NRCEL: ${${alias}_NR_CELL_RM_list}  console=True
    Run Keyword If  ${LTE_CELL_RM_list}  Log  - LNCEL: ${${alias}_LTE_CELL_RM_list}  console=True
    Run Keyword If  ${WCDMA_CELL_RM_list}  Log  - WNCEL: ${${alias}_WCDMA_CELL_RM_list}  console=True
    Run Keyword If  ${GSM_CELL_RM_list}  Log  - GNCEL: ${${alias}_GSM_CELL_RM_list}  console=True

    ${NR_CELL_not_RM_list}=  Copy List  ${${alias}_NR_CELL_list}
    ${LTE_CELL_not_RM_list}=  Copy List  ${${alias}_LTE_CELL_list}
    ${WCDMA_CELL_not_RM_list}=  Copy List  ${${alias}_WCDMA_CELL_list}
    ${GSM_CELL_not_RM_list}=  Copy List  ${${alias}_GSM_CELL_list}
    FOR  ${item}  IN  @{${alias}_CELL_RM_list}
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
    Set Test Variable  ${${alias}_NR_CELL_not_RM_list}  ${NR_CELL_not_RM_list}
    Set Test Variable  ${${alias}_LTE_CELL_not_RM_list}  ${LTE_CELL_not_RM_list}
    Set Test Variable  ${${alias}_WCDMA_CELL_not_RM_list}  ${WCDMA_CELL_not_RM_list}
    Set Test Variable  ${${alias}_GSM_CELL_not_RM_list}  ${GSM_CELL_not_RM_list}
    Set Test Variable  ${${alias}_CELL_not_RM_list}  ${CELL_not_RM_list}

Check if RSI setup was successfully perfomed on RM and create preventerResetCounter file
    [Arguments]  ${RM_sn}  ${configured}

    Log  Check if RSI setup was successfully perfomed on ${configured} RM with SN ${RM_sn}  console=True
    Run Keyword If  '${RM_sn}' in ${rsi_rmod_setup_list}  Run Keywords
    ...  Log  RSI setup was succesfully performed on ${configured} RM with SN ${RM_sn}!  console=True
    ...  AND  Create preventerResetCounter file  ${RM_sn}
    ...  AND  Return From Keyword  True

    [Return]  False

Create preventerResetCounter file
    [Arguments]  ${RM_sn}

    Log  Creating preventerResetCounter.txt file  console=True

    ${rmod_preventerResetCounter_file}=  Set Variable  sudo echo 4 > /mnt/runtime/preventerResetCounter.txt

    ${rsi_rmod_preventerResetCounter_file_status}  ${rsi_rmod_preventerResetCounter_file_info}=
    ...  RSI Send Command  cmd=${rmod_preventerResetCounter_file}  connection=${RM_sn}

    Run Keyword If  '${rsi_rmod_preventerResetCounter_file_status}' == 'PASS'
    ...  Log  File preventerResetCounter.txt with value 4 was succesfully created!  console=True
    ...  ELSE  Run Keywords
    ...  Log  File preventerResetCounter.txt with value 4 couldn't be created!  console=True
    ...  AND  Fail  File preventerResetCounter.txt with value 4 couldn't be created!

Remove preventerResetCounter file
    [Arguments]  ${RM_sn}

    Log  Removing preventerResetCounter.txt file  console=True
    Start remove preventerResetCounter file  ${RM_sn}

Start remove preventerResetCounter file
    [Arguments]  ${RM_sn}

    ${rmod_preventerResetCounter_file}=  Set Variable  sudo lmi-eth on ; rm /mnt/runtime/preventerResetCounter.txt

    FOR  ${try}  IN RANGE  1  50

        ${rsi_rmod_preventerResetCounter_file_status}  ${rsi_rmod_preventerResetCounter_file_info}=
        ...  RSI Send Command  cmd=${rmod_preventerResetCounter_file}  connection=${RM_sn}

        Run Keyword If  '${rsi_rmod_preventerResetCounter_file_status}' == 'PASS'  Run Keywords
        ...  Log  File preventerResetCounter.txt was succesfully removed!  console=True
        ...  AND  Return From Keyword

        Sleep  10s  reason=Waiting time for prompt to appear

    END

Perform RM reset from LMI
    [Arguments]  ${RM_sn}  ${configured}

    Log  Perform "Reset" operation on ${configured} RM with SN ${RM_sn} from LMI  console=True

#    ${rm_reboot_status}=  Run Keyword And Return Status  RSI Reset RMOD  connection=${RM_sn}
    ${rm_reboot_status}  ${rm_reboot_info}=
    ...  RSI Send Command  cmd=sudo reboot  connection=${RM_sn}

    Run Keyword If  '${rm_reboot_status}' == 'PASS'  Run Keywords
    ...  Log  "Reset" operation on ${configured} RM with SN ${RM_sn} from LMI succesfully performed!  console=True
    ...  AND  Return From Keyword

    Log  "Reset" operation on ${configured} RM with SN ${RM_sn} from LMI failed!  console=True
    Fail  "Reset" operation on ${configured} RM with SN ${RM_sn} from LMI failed!

Check alarms during RM reset from LMI
    [Arguments]  ${alias}

    Log  BTS ${alias} "No connection to unit (10)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=2 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_10}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log Long String  BTS ${alias} "No connection to unit (10)" alarm, found number: 1, as expected!  console=True

Deactivate DFE on RM from LMI
    [Arguments]  ${RM_sn}  ${configured}

    ${command}=  Create Long String
    ...  date; uptime; sudo lmi-eth on;
    ...  sudo nft add table pcitable; export C1=$?;
    ...  sudo nft add chain pcitable pcichain '{ type filter hook input priority 0 ; }'; export C2=$?;
    ...  sudo nft add rule pcitable pcichain ip saddr 192.168.100.5 drop; export C3=$?;
    ...  sudo nft add rule pcitable pcichain ip saddr 192.168.101.5 drop; export C4=$?;
    ...  sudo nft add rule pcitable pcichain ip saddr 192.168.102.5 drop; export C5=$?;
    ...  echo C1=$C1,C2=$C2,C3=$C3,C4=$C4,C5=$C5

    Log  Deactivate DFE on ${configured} RM with SN ${RM_sn} from LMI  console=True
    Deactivate DFE on RM  ${command}  ${RM_sn}  ${configured}

Deactivate DFE on RM
    [Arguments]  ${command}  ${RM_sn}  ${configured}

    FOR  ${try}  IN RANGE  1  50

        ${cmd_status}  ${output_status}=  Execute and Check Expected RSI Command Output  ${command}  C1=0,C2=0,C3=0,C4=0,C5=0  ${RM_sn}
        Run Keyword If  '${cmd_status}' != 'PASS'  Sleep  4  Sending command did not succeed. Sleep 4s and resend command

        Run Keyword If  '${cmd_status}' == 'PASS' and ${output_status}  Run Keywords
        ...  Log  DFE deactivation on ${configured} RM with SN ${RM_sn} succesfully performed!  console=True
        ...  AND  Return From Keyword

    END

    Log  DFE deactivation on ${configured} RM with SN ${RM_sn} failed!  console=True
    Fail  DFE deactivation on ${configured} RM with SN ${RM_sn} failed!

Check BTS states and alarms after DFE deactivated on RM from LMI
    [Arguments]  ${RM_sn}  ${RM_id}  ${alias}

    Assert Alarm Inactive  parameters=faultId=10  timeout=1800  connection=${alias}

    Log  Check BTS ${alias} dedicated RM with SN ${RM_sn} status:  console=True
    Check RM state  ${RM_sn}  ${RM_id}  dedicated  ${RM_state_degraded_check}  ${RM_state_degraded}  60  ${alias}

    Log  Check BTS ${alias} cells state mapped on dedicated RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  120s  10s  Check cells state mapped on RM  ${alias}

    Log  Check BTS ${alias} cells status not mapped on dedicated RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on RM  ${RM_sn}  dedicated  ${alias}

    Log  Check BTS ${alias} alarms:  console=True
    Check alarms after DFE deactivated on RM  ${alias}

Check both BTS states and alarms after DFE deactivated on RM from LMI
    [Arguments]  ${RM_sn}  ${RM_id}  ${peer_RM_id}  ${alias}  ${peer_alias}

    Assert Alarm Inactive  parameters=faultId=10  timeout=1800  connection=${alias}
    Assert Alarm Inactive  parameters=faultId=10  timeout=1800  connection=${peer_alias}

    Log  Check BTS ${alias} shared RM with SN ${RM_sn} status:  console=True
    Check RM state  ${RM_sn}  ${RM_id}  shared  ${RM_state_degraded_check}  ${RM_state_degraded}  60  ${alias}
    Check RM state  ${RM_sn}  ${peer_RM_id}  shared  ${RM_state_degraded_check}  ${RM_state_degraded}  60  ${peer_alias}

    Log  Check BTS ${alias} cells state mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  120s  10s  Check cells state mapped on RM  ${alias}
    Log  Check BTS ${peer_alias} cells state mapped on shared RM with SN ${RM_sn}:  console=True
    Wait Until Keyword Succeeds  120s  10s  Check cells state mapped on RM  ${peer_alias}

    Log  Check BTS ${alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on RM  ${RM_sn}  shared  ${alias}
    Log  Check BTS ${peer_alias} cells status not mapped on shared RM with SN ${RM_sn}:  console=True
    Check cells state not mapped on RM  ${RM_sn}  shared  ${peer_alias}

    Log  Check BTS ${alias} alarms:  console=True
    Check alarms after DFE deactivated on RM  ${alias}
    Log  Check BTS ${peer_alias} alarms:  console=True
    Check alarms after DFE deactivated on RM  ${peer_alias}

Check RM state
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${RM_state_check}  ${RM_state}  ${timeout}  ${alias}

    Assert  class_name=RMOD  id=${RM_id}  parameters=${RM_state_check}  timeout=${timeout}  connection=${alias}
    Log  BTS ${alias} ${configured} RM with SN ${RM_sn} status:\n - ${RM_state}  console=True

Check cells state mapped on RM
    [Arguments]  ${alias}

    ${NR_cell_state_degraded_list}  ${NR_cell_state_failed_list}=  Run Keyword If  ${${alias}_NR_CELL_RM_list}
    ...  Check NR cells state and MIMO alarm  cell_list=${${alias}_NR_CELL_RM_list}  alias=${alias}
    ${LTE_cell_state_degraded_list}  ${LTE_cell_state_failed_list}=  Run Keyword If  ${${alias}_LTE_CELL_RM_list}
    ...  Check LTE cells state and MIMO alarm  cell_list=${${alias}_LTE_CELL_RM_list}  alias=${alias}
    ${WCDMA_cell_state_degraded_list}  ${WCDMA_cell_state_failed_list}=  Run Keyword If  ${${alias}_WCDMA_CELL_RM_list}
    ...  Check WCDMA cells state and MIMO alarm  cell_list=${${alias}_WCDMA_CELL_RM_list}  alias=${alias}
    ${GSM_cell_state_degraded_list}  ${GSM_cell_state_failed_list}=  Run Keyword If  ${${alias}_GSM_CELL_RM_list}
    ...  Check GSM cells state and MIMO alarm  cell_list=${${alias}_GSM_CELL_RM_list}  alias=${alias}

Check cells state not mapped on RM
    [Arguments]  ${RM_sn}  ${configured}  ${alias}

    Run Keyword If  ${${alias}_NR_CELL_not_RM_list}
    ...  Check Cell State  NRCEL  ${${alias}_NR_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_LTE_CELL_not_RM_list}
    ...  Check Cell State  LNCEL  ${${alias}_LTE_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_WCDMA_CELL_not_RM_list}
    ...  Check Cell State  WNCEL  ${${alias}_WCDMA_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Run Keyword If  ${${alias}_GSM_CELL_not_RM_list}
    ...  Check Cell State  GNCEL  ${${alias}_GSM_CELL_not_RM_list}  ${CELL_state_enabled_check}  ${CELL_state_enabled}  5  ${alias}
    Log  BTS ${alias} cells not mapped on ${configured} RM with SN ${RM_sn}:\n - ${CELL_state_enabled}  console=True

Check Cell State
    [Arguments]   ${cell_class_name}  ${cell_list}  ${cell_state_check}  ${cell_state}  ${timeout}  ${alias}
    FOR  ${item}  IN  @{cell_list}
        Assert  class_name=${cell_class_name}  id=${item}  parameters=${cell_state_check}  timeout=${timeout}  connection=${alias}
        Log  BTS ${alias} ${cell_class_name} ${item} status:\n - ${cell_state}  console=True
    END

Check alarms after DFE deactivated on RM
    [Arguments]  ${alias}

    ${ignored_alarms_full}=  Combine Lists  ${${alias.upper()}_IGNORED_ALARMS}  ${${alias.upper()}_IGNORED_ALARMS_AFTER_DFE_DISABLED}
    Log  BTS ${alias} "Radio module hardware failure (2935)" alarm, expected number: 1  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=2 sec  expected_alarms=${${alias.upper()}_EXPECTED_ALARMS_2935}
    ...  ignored_alarms=${ignored_alarms_full}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log Long String  BTS ${alias} "Radio module hardware failure (2935)" alarm, found number: 1, as expected!  console=True

Recover RM by performing RM reset from Webem
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${alias}

    Log  Recover ${configured} RM with SN ${RM_sn} by performing "Reset" operation from BTS ${alias}:  console=True
    coam.Reset Unit  dist_name=${RM_id}  reset_type=Hard  timeout=600  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN}

Check BTS states and alarms after reset RM
    [Arguments]  ${RM_sn}  ${RM_id}  ${configured}  ${alias}

    Log  Check BTS ${alias} RM state:  console=True
    Check RM state  ${RM_sn}  ${RM_id}  ${configured}  ${RM_state_enabled_check}  ${RM_state_enabled}  60  ${alias}

    Log  Check BTS ${alias} cells state:  console=True
    Admin Check all BTS cells expected states  expected_state=${CELL_state_enabled_check}  alias=${alias}
    Log  All BTS ${alias} cell(s) status:\n - ${CELL_state_enabled}  console=True

    Check cells availability status online  ${alias}  60

    Log  Check BTS ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown