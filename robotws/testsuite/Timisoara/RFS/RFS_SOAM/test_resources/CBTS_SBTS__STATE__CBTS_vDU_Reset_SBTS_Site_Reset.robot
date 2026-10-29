*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
Variables    tc_variables/cbts_sbts__state__cbts_vdu_reset_sbts_site_reset_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}        3         # Number of Reset VDU (cloud BTS) or Reset Site (classical BTS) operations, default value 3
${BTS_LIST}              ALL       # Specify on which BTS, Reset VDU/Site operation will be performed. Possible values (by default ALL):
                                   # - ALL: action will be performed on all BTS
                                   # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py); for CBTS_SBTS
                                   #   configuration, BTS1 refers to CBTS (cloud BTS) and BTS2 refers to SBTS (classical BTS)
${BTS1_RESET_WRN_THR}    600       # Time (secs) spent between first cell down to last cell up on BTS1
                                   # Default value: in accordance with KPI1a specifications
${BTS2_RESET_WRN_THR}    600       # Time (secs) spent between first cell down to last cell up on BTS2
                                   # Default value: in accordance with KPI1a specifications
${BTS_MAX_WAIT_TIME}     900       # Maximum time to wait for BTS OnAir after reset (by default 900)
${FHGW_CONNECT}          False     # Specify if FHGW is connected on CBTS. Possible values (by default False, no FHGW): True or False
${SWCONFIG_CHANGE_FLAG}  False     # Only for classical BTS. Enable/disable HWF flags change in swconfig.txt file.
                                   # Possible values (by default False): True or False
${SWCONFIG_FLAG_ACTION}  add       # Only for classical BTS. Valid only if ${SWCONFIG_CHANGE_FLAG} set to True. Action that should be done with the
                                   # list of HWF flags in swconfig.txt. Possible values (by default add): add or remove
                                   # - add: check requested HWF flags from swconfig.txt file and set if needed on 0 -> HWF will not be took into use
                                   # - remove: check requested HWF flags from swconfig.txt file and remove if set on 0 -> HWF will be took into use
${SWCONFIG_FLAG_LIST}    0x4F0214  # List of HWF flags that will be added/removed in swconfig.txt. User provides the flags with spaces between them.
                                   # Possible values (by default 0x4F0214):
                                   # - 0x190030 (OAM_DBG_EnableHwfLoading) till SBTS00_ENB_9999_211214_000014 or on maintenance branches till
                                   # SBTS22R1
                                   # - 0x4F0214 (ERadLteHas_BB_PERIPHERIES_EnableHwfLoading) from SBTS00_ENB_9999_211214_000014
                                   # For current SW trunk, flag 0x4F0214 should be used
${GRACEFUL_CELL_SHUTDOWN_SBTS}  True  # Graceful Cell Shutdown SBTS: True or False; default value: True
${GRACEFUL_CELL_SHUTDOWN_CBTS}  True  # Graceful Cell Shutdown CBTS: True or False; default value: True

*** Keywords ***
TC__CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27178
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for Reset VDU/Site, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS info for configured items: RMOD sharing info
    ...  - perform Reset VDU/Site on requested BTS checking states and alarms as described beneath:
    ...    - if ${BTS_LIST} = ALL, Reset VDU/Site operations will be performed on all cloud/classical BTS
    ...    - if ${BTS_LIST} != ALL, Reset VDU/Site operations will be performed on requested cloud/classical BTS
    ...  - check for classical BTS KPI1a info from IMS file
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Reset VDU/Site operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 28.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27178 - [CBTS] P0 - CB008388 New Cloud-Classical scenario for VDU/Site reset
    ...  - 22.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27760 - Align BTS list Hardware File Teardown with requested list
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27890 - [CBTS] Add ${tech_preset_list} in TC Setup for CBTS_SBTS tests
    ...  - 22.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27951 -
    ...  [CBTS][CLOUD_CLASSICAL][CB008388] Align SCF info regarding linkModeSynchronization from SCF with latest taf.config.scf version
    ...  - 04.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28133 - [5G] CNI : 131510 - CBTS_SBTS - SBTS Part 1 - Graceful cell shutdown
    ...  - 15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28175 - [5G] CNI : 131510 - CBTS_SBTS - CBTS Part 2 - Graceful cell shutdown
    ...  - 27.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29295 -
    ...  Variable '${Master_active_SW_version_initial}' not found when created kpi and due to this TCs are failing
    ...  - 12.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29684 -
    ...  CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset during VDU reset does not find FID 10 on SBTS due to waiting for VDU ping to be lost
    ...  - 22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29760 -
    ...  [CBTS] Adapt CBTS_SBTS__STATE__CBTS_vDU_Reset_SBTS_Site_Reset to work with only 1 CBTS configured
    ...

    Set Tags    CA-STATE    OWNER-daniel-cristinel.hauca@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    Configure Hardware File
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS info for configured items
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Reset VDU operation on cloud BTS for iteration ${INDEX}
        Step 5: Perform Reset Site operation on classical BTS for iteration ${INDEX}
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    Set Test Variable  ${BTS_alias_label_dict}
    Set Test Variable  ${BTS_label_alias_dict}
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  ====================================================  console=True
    Log  BTS label list selected for Reset VDU/Site operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for Reset VDU/Site operation: ${BTS_alias_list}  console=True
    Log  ====================================================  console=True

Configure Hardware File
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        Set HWF Flags  swconfig_flag_action=${SWCONFIG_FLAG_ACTION}  swconfig_flag_list=${SWCONFIG_FLAG_LIST}  alias=${alias}
    END

Step ${index}: Check ${when} all BTS states
    [Documentation]
    ...  BTS states is checked as follows:
    ...  - CBTS CU - Operational State: Enabled
    ...  - CBTS VDUs - Operational State: OnAir
    ...  - SBTS RAT - Procedural State: OnAir
    ...  - SBTS BTS - Procedural State: OnAir, Blocking State: Unblocked

    Log  Step ${index}: Check ${when} all BTS states  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} state *****  console=True
        ...  AND  Check CBTS CU VDU Operational State  alias=${alias}  timeout=600
        ...  AND  Log  ${alias} BTS site - CU Operational State: Enabled, VDUs Operational State: OnAir  console=True
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} state *****  console=True
        ...  AND  Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        ...  AND  Admin Check BTS Procedural and Blocking states  exp_pro_state=${OnAir_}  exp_blk_state=${Unblocked_}  timeout=600  alias=${alias}
        ...  AND  Log  ${alias} BTS site - Procedural State: OnAir, Blocking State: Unblocked  console=True

    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  BTS alarms are compared with values from expected, ignored and critical alarms lists.

    Log  Step ${index}: Check ${when} all BTS alarms  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'  Run Keywords
        ...  Log  ***** Check ${when} cloud BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms CBTS  alias=${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']  Run Keywords
        ...  Log  ***** Check ${when} classical BTS ${alias} alarms *****  console=True
        ...  AND  Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}

        Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    END

Step ${index}: Get all BTS info for configured items
    [Documentation]
    ...  Get all BTS info about following items:
    ...  - dictionary containing structure: {'BTS_alias': '<RMOD_serial_number_list>'}
    ...  - dictionary containing structure: {'RMOD_serial_number': '<BTS_alias_list>'}
    ...  - list of shared RMOD serial number
    ...  - list of dedicated RMOD serial number

    Log  Step ${index}: Get all BTS info for configured items  console=True

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    Set Test Variable  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${RMOD_sn_BTS_alias_dict}
    Set Test Variable  ${shared_RMOD_sn_list}
    Set Test Variable  ${dedicated_RMOD_sn_list}

    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    ${BTS_all_alias_count}=  Get Length  ${BTS_all_alias_list}
    Set Test Variable  ${BTS_all_alias_list}
    Set Test Variable  ${BTS_all_alias_count}

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    Set Test Variable  ${SBTS_RMOD_state_enabled_check}  operationalState=${Enabled_}, administrativeState=${Unlocked_}
    Set Test Variable  ${SBTS_RMOD_state_enabled}  operationalState=Enabled, administrativeState=Unlocked
    Set Test Variable  ${SBTS_CELL_state_enabled_check}  operationalState=${Enabled_}, blockingState=${Unblocked_}
    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

Step ${index}: Perform Reset VDU operation on cloud BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Reset VDU operation on cloud BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        Log  ***** Perform Reset VDU on ${alias} BTS *****  console=True

        Perform CBTS Reset VDU  ${alias}  ${CYCLE}

    END

Step ${index}: Perform Reset Site operation on classical BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Reset Site operation on classical BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' not in ['NR', 'LTE', 'SBTS']
        Log  ***** Perform Reset Site on ${alias} BTS *****  console=True

        ${condition}=  Set Variable  '${FHGW_CONNECT}' == 'False' and ${BTS_all_alias_count} > 1
        ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Run Keyword If  ${condition}
        ...  Get all BTS shared RMOD synchronisation impact due to reset operation  ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${alias}
        Run Keyword If  ${condition}  Set Test Variable  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}
        Perform SBTS Reset Site  ${alias}
        Check all classical BTS reset behavior based on IMS info  ${alias}
        Get and check KPI1a info from IMS file  ${alias}  ${CYCLE}

    END

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Check BTS list
    [Arguments]  ${BTS_label_alias_dict}  ${BTS_label_list}

    ${BTS_LIST_strip}=  Replace String  ${BTS_LIST}  ${SPACE}  ${EMPTY}
    ${BTS_LIST}=  Split String  ${BTS_LIST_strip}  ,
    ${BTS_check}=  Set Variable  True
    ${BTS_invalid_label_list}=  Create List
    ${BTS_request_label_list}=  Create List
    ${BTS_request_alias_list}=  Create List

    FOR  ${item}  IN  @{BTS_LIST}

        ${BTS_check}=  Set Variable If  '${item}' not in ${BTS_label_list}  False  ${BTS_check}

        Run Keyword If  '${item}' not in ${BTS_label_list}
        ...  Append To List  ${BTS_invalid_label_list}  ${item}
        ...  ELSE
        ...  Append To List  ${BTS_request_label_list}  ${item}

    END

    Run Keyword If  '${BTS_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected BTS are not valid: ${BTS_invalid_label_list}. Please select values for test argument \${BTS_LIST} from
    ...  configured BTS: ${BTS_label_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    FOR  ${item}  IN  @{BTS_request_label_list}

        ${BTS_request_alias}=  Get From Dictionary  ${BTS_label_alias_dict}  ${item}
        Append To List  ${BTS_request_alias_list}  ${BTS_request_alias}

    END

    Set Test Variable  ${BTS_label_list}  ${BTS_request_label_list}
    Set Test Variable  ${BTS_alias_list}  ${BTS_request_alias_list}

Perform CBTS Reset VDU
    [Arguments]  ${alias}  ${CYCLE}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${condition}=  Set Variable  '${FHGW_CONNECT}' == 'False' and ${BTS_all_alias_count} > 1
        ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Run Keyword If  ${condition}
        ...  Get all BTS shared RMOD synchronisation impact due to reset operation  ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${vdu_alias}
        Run Keyword If  ${condition}  Set Test Variable  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}
        Perform Reset VDU  ${vdu_alias}  ${alias}  ${CYCLE}

    END

Perform Reset VDU
    [Arguments]  ${vdu_alias}  ${alias}  ${CYCLE}

    ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
    ...  vdu_connection=${vdu_alias}
    ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
    Set Test Variable  ${${vdu_alias}_VDU_RMOD_ids_list}  ${VDU_RMOD_ids_list}
    ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${vdu_alias}
    ${VDU_NR_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}
    Set Test Variable  ${${vdu_alias}_VDU_NR_CELL_ids_list}  ${VDU_NR_CELL_ids_list}

    Log  Perform "Reset VDU" operation on ${vdu_alias}   console=True

    Get Current Time  initial
    VDU Reset VDU  timeout=${BTS_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN_CBTS}

    Run Keyword If  '${FHGW_CONNECT}' == 'False' and ${BTS_all_alias_count} > 1  Run Keywords
    ...  Log  Check other BTS alarms during "Reset VDU" operation on ${vdu_alias}  console=True
    ...  AND  Check other BTS alarms during reset operation  reset_BTS_alias=${vdu_alias}
    ...  ELSE IF  '${FHGW_CONNECT}' == 'True' and ${BTS_all_alias_count} > 1
    ...  Log  Check other BTS alarms during "Reset Site" operation on ${vdu_alias} BTS will be skipped due to connected FHGW  console=True

    Log  Check ${vdu_alias} status and alarms after "Reset VDU" operation on ${vdu_alias}  console=True
    Wait For Target To Be Reachable TAF  hostname=${${vdu_alias.lower()}_vdu_host}  timeout=300
    Check cloud BTS states and alarms after reset VDU  vdu_alias=${vdu_alias}

    Run Keyword If  ${BTS_all_alias_count} > 1  Run Keywords
    ...  Log  Check other BTS status and alarms after "Reset VDU" operation on ${vdu_alias}  console=True
    ...  AND  Check other BTS states and alarms after reset operation  reset_BTS_alias=${alias}

    ${vdu_kpi_1a}=  DateTime.Subtract Date From Date  ${time_final}  ${time_initial}  number
    Set Test Variable  ${vdu_kpi_1a}

    Get and check KPI1a info from events  ${vdu_alias}  ${alias}  ${CYCLE}

Perform SBTS Reset Site
    [Arguments]  ${alias}

    Set Test Variable  ${SBTS_CELL_state_enabled}  operationalState=Enabled, blockingState=Unblocked

    ${hostname_ip}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_TECH_IP_ADDRESS]
    ${remote_host_ip}=  Set Variable If  '${alias}' == 'Master'  None  ${${alias.upper()}}[${alias.upper()}_PC_IP_ADDRESS]

    Get Current Date UTC info  initial
    Get Current Time  initial
    Log  Perform "Reset Site" operation on ${alias} BTS  console=True
    RFS Site Reset  connection=${alias}  graceful_cell_shutdown=${GRACEFUL_CELL_SHUTDOWN_SBTS}
    Wait For Target To Be Not Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300

    Run Keyword If  '${FHGW_CONNECT}' == 'False' and ${BTS_all_alias_count} > 1  Run Keywords
    ...  Log  Check other BTS alarms during "Reset Site" operation on ${alias} BTS  console=True
    ...  AND  Check other BTS alarms during reset operation  reset_BTS_alias=${alias}
    ...  ELSE IF  '${FHGW_CONNECT}' == 'True' and ${BTS_all_alias_count} > 1
    ...  Log  Check other BTS alarms during "Reset Site" operation on ${alias} BTS will be skipped due to connected FHGW  console=True

    Log  Check ${alias} BTS status and alarms after "Reset Site" operation on ${alias} BTS  console=True
    Wait For Target To Be Reachable TAF  hostname=${hostname_ip}  remote_host=${remote_host_ip}  timeout=300
    Check classical BTS states and alarms after reset Site  ${alias}

    Run Keyword If  ${BTS_all_alias_count} > 1  Run Keywords
    ...  Log  Check other BTS status and alarms after "Reset Site" operation on ${alias} BTS  console=True
    ...  AND  Check other BTS states and alarms after reset operation  reset_BTS_alias=${alias}

    Get Current Date UTC info  final

Check other BTS alarms during reset operation
    [Arguments]  ${reset_BTS_alias}

    FOR  ${other_alias}  IN  @{BTS_all_alias_list}

        Continue For Loop If  '${other_alias}' == '${reset_BTS_alias}'

        Run Keyword If  '${other_alias}' in ${alias_list}
        ...  Check other classical BTS alarms during reset operation  reset_BTS_alias=${reset_BTS_alias}  peer_BTS_alias=${other_alias}
        ...  ELSE
        ...  Check other cloud BTS alarms during reset operation  reset_BTS_alias=${reset_BTS_alias}  peer_BTS_alias=${other_alias}

    END

Check other cloud BTS alarms during reset operation
    [Arguments]  ${reset_BTS_alias}  ${peer_BTS_alias}

    ${peer_BTS_alias_alarm}=  Replace String  ${peer_BTS_alias}  ${SPACE}  _

    ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Get From Dictionary  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${reset_BTS_alias}
    ${shared_RMOD_sn_SYNC_loss_dict}=  Get From Dictionary  ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${peer_BTS_alias}
    ${CPRI_shared_RMOD_sn_SYNC_loss_list}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_loss_dict}  CPRI_shared_RMOD_sn_SYNC_loss
    ${ECPRI_shared_RMOD_sn_SYNC_loss_list}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_loss_dict}  ECPRI_shared_RMOD_sn_SYNC_loss
    ${CPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${CPRI_shared_RMOD_sn_SYNC_loss_list}
    ${ECPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}

    ${VDU_EXPECTED_ALARMS_10_full}=  Prepare expected alarms list  ${${peer_BTS_alias_alarm.upper()}_EXPECTED_ALARMS_10}
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}
    ${VDU_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_BTS_alias_alarm.upper()}_EXPECTED_ALARMS_16}
    ...  ${ECPRI_shared_RMOD_sn_SYNC_loss_count}
    ${VDU_EXPECTED_ALARMS_full}=  Combine Lists  ${VDU_EXPECTED_ALARMS_10_full}  ${VDU_EXPECTED_ALARMS_16_full}

    Log  Check ${peer_BTS_alias} alarms:  console=True
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "No connection to Unit (10)" alarm, expected number: ${CPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "Unit synchronization failed (16)" alarm, expected number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${peer_BTS_alias}  poll_interval=5s  expected_alarms=@{VDU_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${peer_BTS_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_BTS_alias_alarm.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "No connection to Unit (10)" alarm, found number: ${CPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "Unit synchronization failed (16)" alarm, found number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!
    ...  console=True
    Log  ${peer_BTS_alias} site - expected, ignored and critical alarms checked  console=True

Check other classical BTS alarms during reset operation
    [Arguments]  ${reset_BTS_alias}  ${peer_BTS_alias}

    ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}=  Get From Dictionary  ${all_BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${reset_BTS_alias}
    ${shared_RMOD_sn_SYNC_loss_dict}=  Get From Dictionary  ${BTS_peer_alias_shared_RMOD_sn_SYNC_loss_dict}  ${peer_BTS_alias}
    ${CPRI_shared_RMOD_sn_SYNC_loss_list}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_loss_dict}  CPRI_shared_RMOD_sn_SYNC_loss
    ${ECPRI_shared_RMOD_sn_SYNC_loss_list}=  Get From Dictionary  ${shared_RMOD_sn_SYNC_loss_dict}  ECPRI_shared_RMOD_sn_SYNC_loss
    ${CPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${CPRI_shared_RMOD_sn_SYNC_loss_list}
    ${ECPRI_shared_RMOD_sn_SYNC_loss_count}=  Get Length  ${ECPRI_shared_RMOD_sn_SYNC_loss_list}

    ${SBTS_EXPECTED_ALARMS_10_1815_full}=  Prepare expected alarms list  ${${peer_BTS_alias.upper()}_EXPECTED_ALARMS_10_1815}
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}
    ${SBTS_EXPECTED_ALARMS_16_full}=  Prepare expected alarms list  ${${peer_BTS_alias.upper()}_EXPECTED_ALARMS_16}
    ...  ${ECPRI_shared_RMOD_sn_SYNC_loss_count}
    ${SBTS_EXPECTED_ALARMS_full}=  Combine Lists  ${SBTS_EXPECTED_ALARMS_10_1815_full}  ${SBTS_EXPECTED_ALARMS_16_full}

    Log  Check ${peer_BTS_alias} alarms:  console=True
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log Long String  ${peer_BTS_alias} "Not able to synchronize baseband bus (1815) or No connection to Unit (10)" alarm, expected number:
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "Unit synchronization failed (16)" alarm, expected number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}  console=True
    Get and Check Alarms SOAM  alias=${peer_BTS_alias}  poll_interval=5s  expected_alarms=@{SBTS_EXPECTED_ALARMS_full}
    ...  ignored_alarms=${${peer_BTS_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${peer_BTS_alias.upper()}_CRITICAL_ALARMS}
    Run Keyword If  ${CPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log Long String  ${peer_BTS_alias} "Not able to synchronize baseband bus (1815) or No connection to Unit (10)" alarm, found number:
    ...  ${CPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!  console=True
    Run Keyword If  ${ECPRI_shared_RMOD_sn_SYNC_loss_count} > 0
    ...  Log  ${peer_BTS_alias} "Unit synchronization failed (16)" alarm, found number: ${ECPRI_shared_RMOD_sn_SYNC_loss_count}, as expected!
    ...  console=True
    Log  ${peer_BTS_alias} site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms after reset VDU
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check CBTS VDU RMOD state  ${${vdu_alias}_VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} cells status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check CBTS VDU cell state  ${${vdu_alias}_VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  ${remained_MAX_WAIT_TIME}  ${vdu_alias}

    Get Current Time  final

    Log  Check ${vdu_alias} alarms:  console=True
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check CBTS VDU state
    [Arguments]  ${VDU_operational_state_check}  ${VDU_state_check}  ${timeout}  ${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check VDU Expected Status  operational_state=${VDU_operational_state_check}
    ...  vdu_connection=${vdu_alias}
    Log  ${vdu_alias} status:\n - ${VDU_state_check}  console=True

Check CBTS VDU RMOD state
    [Arguments]  ${VDU_RMOD_ids}  ${RMOD_operational_state_check}  ${RMOD_availability_status_check}  ${RMOD_administrative_state_check}
    ...  ${RMOD_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_RMOD_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RMOD Expected Status  rmod_id=${item}
        ...  operational_state=${RMOD_operational_state_check}  availability_status=${RMOD_availability_status_check}
        ...  administrative_state==${RMOD_administrative_state_check}  vdu_connection=${vdu_alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}

    END
    Log  ${vdu_alias} RMODs status:\n - ${RMOD_state}  console=True

Check CBTS VDU cell state
    [Arguments]  ${VDU_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}  ${CELL_administrative_state_check}
    ...  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}
        ${timeout}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}

    END
    Log  ${vdu_alias} cells status:\n - ${CELL_state}  console=True

Check classical BTS states and alarms after reset Site
    [Arguments]  ${alias}

    Log  Check ${alias} BTS status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  ${remained_MAX_WAIT_TIME}  ${alias}
    Log  ${alias} BTS site - proceduralState: OnAir, blockingState: Unblocked, as expected!  console=True

    Log  Check ${alias} BTS RMODs status:  console=True
    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Assert Every  class_name=RMOD  parameters=${SBTS_RMOD_state_enabled_check}  timeout=${remained_MAX_WAIT_TIME}  connection=${alias}
    Log  ${alias} BTS RMODs status:\n - ${SBTS_RMOD_state_enabled}  console=True

    ${remained_MAX_WAIT_TIME}=  Get elapsed time  ${time_initial}  ${BTS_MAX_WAIT_TIME}
    Check cells availability status online  ${alias}  ${remained_MAX_WAIT_TIME}
    Log  ${alias} BTS cells status:\n - operationalState=Enabled, availabilityStatus=Online, blockingState=Unblocked  console=True

    Log  Check ${alias} BTS alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
    ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

Check other BTS states and alarms after reset operation
    [Arguments]  ${reset_BTS_alias}

    FOR  ${other_alias}  IN  @{BTS_all_alias_list}

        Continue For Loop If  '${other_alias}' == '${reset_BTS_alias}'

        Run Keyword If  '${other_alias}' in ${alias_list}
        ...  Check other classical BTS states and alarms after reset operation  alias=${other_alias}
        ...  ELSE
        ...  Check other cloud BTS states and alarms after reset operation  alias=${other_alias}

    END

Check other cloud BTS states and alarms after reset operation
    [Arguments]  ${alias}

    ${alias_alarm}=  Replace String  ${alias}  ${SPACE}  _

    Log  Check ${alias} alarms:  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check other classical BTS states and alarms after reset operation
    [Arguments]  ${alias}

    Log  Check ${alias} alarms:  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} site - expected, ignored and critical alarms checked  console=True

Check all classical BTS reset behavior based on IMS info
    [Documentation]
    ...  Classical BTS RESET info is checked based on IMS info. Reset behavior as expected if:
    ...  - classical BTS ${alias} site: 1
    ...  - other classical BTS(s) site: reset number is 0
    ...  Otherwise, reset behavior not as expected, then errors are added to report and failed.
    [Arguments]  ${alias}

    Log  Check all classical BTS reset behavior based on IMS info  console=True

    Get and check BTS RESET info from IMS file  expected_reset_number=1  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    FOR  ${other_alias}  IN  @{alias_list}

        Continue For Loop If  '${other_alias}' == '${alias}' or '${${other_alias.upper()}}[${other_alias.upper()}_TECH]' == 'CBTS'

        Get and check BTS RESET info from IMS file  expected_reset_number=0  alias=${other_alias}
        ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}

    END

Get and check KPI1a info from events
    [Arguments]  ${vdu_alias}  ${alias}  ${CYCLE}

    Log  Get and check KPI1a info related to reset CBTS ${vdu_alias} for iteration ${CYCLE}  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    Export KPI Results to File  alias=${vdu_alias}  obj=BTS  obj_type=CBTS VDU  obj_id=${vdu_alias}  action_1=Reset_VDU  kpi_reported_1=KPI_1a
    ...  event_value_1=${vdu_kpi_1a}  cycle=${CYCLE}  source_info=events

    Check and set KPI verdict  kpi1a  ${vdu_kpi_1a}  ${${label}_RESET_WRN_THR}

Get and check KPI1a info from IMS file
    [Arguments]  ${alias}  ${CYCLE}

    Log  Get and check KPI1a info related to reset SBTS ${alias} for iteration ${CYCLE}  console=True
    ${label}=  Get From Dictionary  ${BTS_alias_label_dict}  ${alias}
    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi1a  kpi_thresholds=${${label}_RESET_WRN_THR}  alias=${alias}
    ...  start_point_timestamp_UTC=${date_timestamp_initial_UTC}  end_point_timestamp_UTC=${date_timestamp_final_UTC}
    ${kpi_delta_list}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi1a

    Export KPI Results to File  alias=${alias}  obj=BTS  obj_type=SBTS  obj_id=${alias}  action_1=Reset_Site  kpi_reported_1=KPI_1a
    ...  event_value_1=${kpi_delta_list[0]}  cycle=${CYCLE}  source_info=ims

Hardware File Teardown
    Return From Keyword If  '${SWCONFIG_CHANGE_FLAG}' == 'False'
    FOR  ${alias}  IN  @{BTS_alias_list}
        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        Recover HWF Flags  alias=${alias}
    END

Particular Teardown
    Hardware File Teardown
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
