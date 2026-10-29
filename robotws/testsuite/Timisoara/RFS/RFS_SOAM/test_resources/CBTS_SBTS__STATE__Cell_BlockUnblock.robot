*** Settings ***
Documentation    TC__CBTS_SBTS__STATE__Cell_BlockUnblock
Variables    tc_variables/cbts_sbts__state__cell_blockunblock_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}              3     # Number of Block/Unblock Cell operations, default value 3
${BTS_LIST}                    ALL   # Specify on which BTS, Block/Unblock Cell operation will be performed. Possible values (by default ALL):
                                     # - ALL: action will be performed on all BTS
                                     # - list of selected BTS separated by comma labeled as BTSx (x is test_pc number in init.py); for CBTS_SBTS
                                     #   configuration, BTS1 refers to CBTS (cloud BTS) and BTS2 refers to SBTS (classical BTS)
${SBTS_RAT_LIST}               ALL   # Only for classical BTS. RAT list on which Block/Unblock Cell operation will be performed.
                                     # Possible values (by default ALL):
                                     # - ALL: action will be performed on all configured RAT cells on BTS
                                     # - list of selected RAT separated by comma, possible values: NR, LTE, WCDMA, GSM (ex. NR, LTE)
${LTE_IOT_check}               True  # Only for classical BTS if RAT LTE is requested. Specify in case of configured LTE IOT cells if their status
                                     # will be checked (True) or skipped (False) after block host LTE cell. By default True
${NR_CELL_BLOCK_WRN_THR}       10    # Time (secs) spent from cell block command sent to cell down.
                                     # Default value: in accordance with KPI17a specifications
${NR_CELL_UNBLOCK_WRN_THR}     10    # Time (secs) spent from cell unblock command sent to cell up.
                                     # Default value: in accordance with KPI17b specifications
${LTE_CELL_BLOCK_WRN_THR}      10    # Time (secs) spent from cell block command sent to cell down.
                                     # Default value: in accordance with KPI17a specifications
${LTE_CELL_UNBLOCK_WRN_THR}    10    # Time (secs) spent from cell unblock command sent to cell up.
                                     # Default value: in accordance with KPI17b specifications
${WCDMA_CELL_BLOCK_WRN_THR}    10    # Time (secs) spent from cell block command sent to cell down.
                                     # Default value: in accordance with KPI17a specifications
${WCDMA_CELL_UNBLOCK_WRN_THR}  10    # Time (secs) spent from cell unblock command sent to cell up.
                                     # Default value: in accordance with KPI17b specifications
${GSM_CELL_BLOCK_WRN_THR}      130   # Time (secs) spent from cell block command sent to cell down.
                                     # Default value: in accordance with KPI17a specifications
${GSM_CELL_UNBLOCK_WRN_THR}    10    # Time (secs) spent from cell unblock command sent to cell up.
                                     # Default value: in accordance with KPI17b specifications
${CELL_BLOCK_MAX_WAIT_TIME}    200   # Maximum waiting time for cell to be blocked; default value 200 seconds
${CELL_UNBLOCK_MAX_WAIT_TIME}  200   # Maximum waiting time for cell to be unblocked; default value 200 seconds

*** Keywords ***
TC__CBTS_SBTS__STATE__Cell_BlockUnblock
     [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27367
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS-SBTS test case for Block/Unblock Cell, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for all BTS
    ...  - get all BTS cells info
    ...  - perform Block/Unblock cells on requested BTS and RAT cells checking states and alarms as described beneath:
    ...    - if ${BTS_LIST} = ALL, block/unblock cell operations will be performed on all BTS
    ...    - if ${BTS_LIST} != ALL, block/unblock cell operations will be performed on requested BTS
    ...    - if ${RAT_LIST} = ALL, block/unblock cell operations will be performed on all configured RAT cells
    ...    - if ${RAT_LIST} != ALL, block/unblock cell operations will be performed on requested RAT cells on BTS
    ...  - check for SBTS KPI17a and KPI17b info from IMS file
    ...  - check final state and alarms for for all BTS
    ...  Pass criteria: Block/Unblock Cell operation works as expected; states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27367 - [CBTS] P1 - CB008388 New Cloud-Classical scenario for Cell Block/Unblock
    ...  - 06.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27611 - Use cell id info instead cell config dn for automated scenario
    ...  CBTS_SBTS__STATE__CBTS_Block_Unblock_Cell_SBTS_Block_Unblock_Cell
    ...  - 12.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27890 - [CBTS] Add ${tech_preset_list} in TC Setup for CBTS_SBTS tests
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28015 - [CBTS] CBTS_SBTS__STATE__Cell_BlockUnblock test failed due to IOT cell
    ...  - 27.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29295 - Variable '${Master_active_SW_version_initial}' not found when created
    ...  kpi and due to this TCs are failing
    ...

    Set Tags    CA-STATE    OWNER-daniel-cristinel.hauca@nokia.com   AUTHOR-dinu.olariu@nokia.com    PHASE-CRT    SW-CBTS24R3,SBTS24R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    Step 3: Get all BTS cells info
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Perform Block/Unblock Cell on cloud BTS for iteration ${INDEX}
        Step 5: Perform Block/Unblock Cell on classical BTS for iteration ${INDEX}
        Step 6: Check final all BTS states
        Step 7: Check final all BTS alarms
        Step 8: Check final number and state of Cells and RMs
    END

    [Teardown]  Particular Teardown

TC Preconditions

    ${BTS_alias_label_dict}  ${BTS_label_alias_dict}=  Get BTS alias label info dict
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_label_dict}  False
    ${BTS_label_list}=  Get Dictionary Values  ${BTS_alias_label_dict}  False
    Set Test Variable  ${BTS_alias_list}
    Set Test Variable  ${BTS_label_list}

    Run Keyword If  '${BTS_LIST}' != 'ALL'  Check BTS list  ${BTS_label_alias_dict}  ${BTS_label_list}
    Log  =========================================================  console=True
    Log  BTS label list selected for Block/Unblock Cell operation: ${BTS_label_list}  console=True
    Log  BTS alias list selected for Block/Unblock Cell operation: ${BTS_alias_list}  console=True
    Log  =========================================================  console=True

    FOR  ${alias}  IN  @{alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'

        Check SBTS RAT list  ${alias}

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

Step ${index}: Get all BTS cells info
    Log  Step ${index}: Get all BTS cells info  console=True

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Get SBTS Cell info  ${alias}

    END

Step ${index}: Perform Block/Unblock Cell on cloud BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Block/Unblock Cell on cloud BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'
        Log  ***** Perform Block/Unblock Cell on ${alias} BTS *****  console=True

        Perform Block Unblock CBTS VDU cells  ${alias}  ${CYCLE}

    END

Step ${index}: Perform Block/Unblock Cell on classical BTS for iteration ${CYCLE}
    Log  Step ${index}: Perform Block/Unblock Cell on classical BTS for iteration ${CYCLE}  console=True

    FOR  ${alias}  IN  @{BTS_alias_list}

        Continue For Loop If  '${${alias.upper()}}[${alias.upper()}_TECH]' not in ['NR', 'LTE', 'SBTS']
        Log  ***** Perform Block/Unblock Cell on ${alias} BTS *****  console=True

        Perform Block Unblock SBTS cells  ${alias}  ${CYCLE}

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

Check SBTS RAT list
    [Arguments]  ${alias}
    ${SBTS_RAT_configured_list}=  Get BTS RAT info  ${alias}
    Set Test Variable  ${${alias}_SBTS_RAT_list}  ${SBTS_RAT_configured_list}
    Return From Keyword If  '${SBTS_RAT_LIST}' == 'ALL'

    ${SBTS_RAT_LIST_strip}=  Replace String  ${SBTS_RAT_LIST}  ${SPACE}  ${EMPTY}
    ${SBTS_RAT_LIST}=  Split String  ${SBTS_RAT_LIST_strip}  ,
    ${SBTS_RAT_check}=  Set Variable  True
    ${SBTS_RAT_invalid_list}=  Create List
    ${SBTS_RAT_request_list}=  Create List

    FOR  ${item}  IN  @{SBTS_RAT_LIST}

        ${SBTS_RAT_check}=  Set Variable If  '${item}' not in ${SBTS_RAT_configured_list}  False  ${SBTS_RAT_check}

        Run Keyword If  '${item}' not in ${SBTS_RAT_configured_list}
        ...  Append To List  ${SBTS_RAT_invalid_list}  ${item}
        ...  ELSE
        ...  Append To List  ${SBTS_RAT_request_list}  ${item}

    END

    Run Keyword If  '${SBTS_RAT_check}' == 'False'  Run Keywords
    ...  Log Long String  Following selected RATs for ${alias} BTS are not valid: ${SBTS_RAT_invalid_list}. Please select values for test argument
    ...  \${SBTS_RAT_LIST} from configured RATs: ${SBTS_RAT_configured_list} or let default value: ALL  console=True
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${${alias}_SBTS_RAT_list}  ${SBTS_RAT_request_list}

Get BTS RAT info
    [Arguments]  ${alias}
    ${RAT_configured_list}=  Create List
    ${NR_CELL_list}=  Get Ids For All  class_name=NRCEL  connection=${alias}
    Run Keyword If  ${NR_CELL_list}  Append To List  ${RAT_configured_list}  NR
    ${LTE_CELL_list}=  Get Ids For All  class_name=LNCEL  connection=${alias}
    Run Keyword If  ${LTE_CELL_list}  Append To List  ${RAT_configured_list}  LTE
    ${WCDMA_CELL_list}=  Get Ids For All  class_name=WNCEL  connection=${alias}
    Run Keyword If  ${WCDMA_CELL_list}  Append To List  ${RAT_configured_list}  WCDMA
    ${GSM_CELL_list}=  Get Ids For All  class_name=GNCEL  connection=${alias}
    Run Keyword If  ${GSM_CELL_list}  Append To List  ${RAT_configured_list}  GSM

    [Return]  ${RAT_configured_list}

Get SBTS Cell info
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
    Set Test Variable  ${${alias}_WCDMA_CELL_list}  ${WCDMA_CELL_list}
    Set Test Variable  ${${alias}_GSM_CELL_list}  ${GSM_CELL_list}
    Set Test Variable  ${${alias}_LTE_cell_IOT_mapping_dict}  ${LTE_cell_IOT_mapping_dict}

Perform Block Unblock CBTS VDU cells
    [Arguments]  ${alias}  ${CYCLE}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}

        ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${vdu_alias}
        ${VDU_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

        Block Unblock CBTS VDU cells  ${VDU_CELL_ids_list}  ${vdu_alias}  ${CYCLE}

    END

Block Unblock CBTS VDU cells
    [Arguments]  ${VDU_CELL_ids_list}  ${vdu_alias}  ${CYCLE}

    FOR  ${item}  IN  @{VDU_CELL_ids_list}

        Block CBTS VDU cell  ${item}  ${vdu_alias}

        Unblock CBTS VDU cell  ${item}  ${vdu_alias}

        Get and check KPI17a and KPI17b info from events  ${item}  NR  ${vdu_alias}  ${CYCLE}

    END

Block CBTS VDU cell
    [Arguments]  ${cell_id}  ${vdu_alias}

    ${CELL_state_blocked}=  Set Variable
    ...  Operational state=Disabled, Availability status=Offline, Administrative state=Unlocked, Blocking state=Blocked
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _
    ${BTS_cell_list_exempted}=  Create List  ${cell_id}
    ${BTS_cell_info_exempted}=  Create Dictionary  ${vdu_alias}=${BTS_cell_list_exempted}

    Log  Perform "Block Cell" operation on NR cell ${cell_id} from ${vdu_alias}   console=True

    Get Current Time  vdu_block_cell_start

    VDU Block Cell  cell_id=${cell_id}  timeout=${CELL_BLOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after "Block Cell" operation on NR cell ${cell_id}  console=True

    Wait Until Keyword Succeeds  ${CELL_BLOCK_MAX_WAIT_TIME}s  1s  VDU Check Cell Expected Status  cell_id=${cell_id}
    ...  operational_state=${CBTS_Disabled_}  availability_status=${CBTS_Offline_}  administrative_state==${CBTS_Unlocked_}
    ...  blocking_state=${CBTS_Blocked_}  vdu_connection=${vdu_alias}
    Log  NR cell ${cell_id} status:\n - ${CELL_state_blocked}  console=True

    Get Current Time  vdu_block_cell_end

    Log  ${vdu_alias} "Cell blocked (0049)" alarm, expected number: 1  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=${${vdu_alias_alarm.upper()}_EXPECTED_ALARMS}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} "Cell blocked (0049)" alarm, expected number: 1  console=True
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

    ${vdu_cell_kpi_17a}=  DateTime.Subtract Date From Date  ${time_vdu_block_cell_end}  ${time_vdu_block_cell_start}  number
    Set Test Variable  ${vdu_cell_kpi_17a}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all cloud/classical BTS other cells are not impacted by "Block Cell" operation on NR cell ${cell_id} from ${vdu_alias}  console=True
    Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{BTS_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unblock CBTS VDU cell
    [Arguments]  ${cell_id}  ${vdu_alias}

    ${CELL_state_unblocked}=  Set Variable
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked
    ${vdu_alias_alarm}=  Replace String  ${vdu_alias}  ${SPACE}  _

    Log  Perform "Unblock Cell" operation on NR cell ${cell_id} from ${vdu_alias}   console=True

    Get Current Time  vdu_unblock_cell_start

    VDU Unblock Cell  cell_id=${cell_id}  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}  vdu_connection=${vdu_alias}

    Log  Check ${vdu_alias} state and alarms after "Unblock Cell" operation on NR cell ${cell_id}  console=True

    Wait Until Keyword Succeeds  ${CELL_UNBLOCK_MAX_WAIT_TIME}s  1s  VDU Check Cell Expected Status  cell_id=${cell_id}
    ...  operational_state=${CBTS_Enabled_}  availability_status=${CBTS_Online_}  administrative_state==${CBTS_Unlocked_}
    ...  blocking_state=${CBTS_Unblocked_}  vdu_connection=${vdu_alias}
    Log  NR cell ${cell_id} status:\n - ${CELL_state_unblocked}  console=True

    Get Current Time  vdu_unblock_cell_end

    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias_alarm.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias_alarm.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

    ${vdu_cell_kpi_17b}=  DateTime.Subtract Date From Date  ${time_vdu_unblock_cell_end}  ${time_vdu_unblock_cell_start}  number
    Set Test Variable  ${vdu_cell_kpi_17b}

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all cloud/classical BTS other cells are not impacted by "Unblock Cell" operation on NR cell ${cell_id} from ${vdu_alias}  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Perform Block Unblock SBTS cells
    [Arguments]  ${alias}  ${CYCLE}

    FOR  ${item}  IN  @{${alias}_SBTS_RAT_list}

        Block Unblock SBTS RAT cells  ${item}  ${alias}  ${CYCLE}

    END

Block Unblock SBTS RAT cells
    [Arguments]  ${rat}  ${alias}  ${CYCLE}

    FOR  ${item}  IN  @{${alias}_${rat}_CELL_list}

        Get Current Date UTC info  start

        Block SBTS cell  ${item}  ${rat}  ${alias}

        Unblock SBTS cell  ${item}  ${rat}  ${alias}

        Get Current Date UTC info  end

        Get and check KPI17a and KPI17b info from IMS file  ${item}  ${rat}  ${alias}  ${CYCLE}

    END

Block SBTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${CELL_state_blocked_check}=  Set Variable  operationalState=${Disabled_}, availabilityStatus=${Offline_}, blockingState=${Blocked_}
    ${CELL_state_blocked}=  Set Variable  operationalState=Disabled, availabilityStatus=Offline, blockingState=Blocked
    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL  '${rat}' == 'WCDMA'  WNCEL  '${rat}' == 'GSM'  GNCEL

    ${cell_IOT_id}=  Run Keyword If  '${rat}' == 'LTE'  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}
    ${BTS_cell_list_exempted}=  Run Keyword If  '${rat}' == 'LTE' and '${cell_IOT_id}' != 'None'  Create List  ${cell_id}  ${cell_IOT_id}
    ...  ELSE
    ...  Create List  ${cell_id}
    ${BTS_cell_info_exempted}=  Create Dictionary  ${alias}=${BTS_cell_list_exempted}

    Log  Perform "Block Cell" operation on ${rat} cell ${cell_id} from ${alias} BTS   console=True

    coam.Block Cell  dist_name=${cell_id}  timeout=${CELL_BLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} BTS state and alarms after "Block Cell" operation on ${rat} cell ${cell_id}    console=True

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${CELL_state_blocked_check}  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  connection=${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${CELL_state_blocked}  console=True
    Run Keyword If  '${cell_IOT_id}' != 'None' and '${LTE_IOT_check}' == 'True'  Run Keywords
    ...  Assert  class_name=${cell_class_name}  id=${cell_IOT_id}  parameters=${CELL_state_blocked_check}  timeout=${CELL_BLOCK_MAX_WAIT_TIME}
    ...  connection=${alias}
    ...  AND  Log  ${rat} cell IOT ${cell_IOT_id} status:\n - ${CELL_state_blocked}  console=True

    ${SBTS_alarm_count}=  Run Keyword If  '${rat}' == 'LTE'  Count number of SBTS LTE alarms  ${cell_id}  ${alias}
    ...  ELSE
    ...  Set Variable  1
    ${SBTS_EXPECTED_ALARMS_49_full}=  Prepare expected alarms list  ${${alias.upper()}_EXPECTED_ALARMS_49}  ${SBTS_alarm_count}

    Log  ${alias} BTS "Cell Blocked (49)" alarm, expected number: ${SBTS_alarm_count}  console=True
    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=${SBTS_EXPECTED_ALARMS_49_full}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS "Cell Blocked (49)" alarm, found number: ${SBTS_alarm_count}, as expected  console=True
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all cloud/classical BTS other cells are not impacted by "Block Cell" operation on ${rat} cell ${cell_id} from ${alias} BTS
    ...  console=True
    Run Keyword If  '${rat}' == 'NR'
    ...  Check BTS cells are enabled online with exceptions  NR_cell_info_exempted=&{BTS_cell_info_exempted}  timeout=3
    ...  ELSE IF  '${rat}' == 'LTE'
    ...  Check BTS cells are enabled online with exceptions  LTE_cell_info_exempted=&{BTS_cell_info_exempted}  timeout=3
    ...  ELSE IF  '${rat}' == 'WCDMA'
    ...  Check BTS cells are enabled online with exceptions  WCDMA_cell_info_exempted=&{BTS_cell_info_exempted}  timeout=3
    ...  ELSE IF  '${rat}' == 'GSM'
    ...  Check BTS cells are enabled online with exceptions  GSM_cell_info_exempted=&{BTS_cell_info_exempted}  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Unblock SBTS cell
    [Arguments]  ${cell_id}  ${rat}  ${alias}

    ${CELL_state_unblocked_check}=  Set Variable  operationalState=${Enabled_}, blockingState=${Unblocked_}
    ${CELL_state_unblocked}=  Set Variable  operationalState=Enabled, blockingState=Unblocked
    ${cell_class_name}=  Set Variable If  '${rat}' == 'NR'  NRCEL  '${rat}' == 'LTE'  LNCEL  '${rat}' == 'WCDMA'  WNCEL  '${rat}' == 'GSM'  GNCEL

    ${cell_IOT_id}=  Run Keyword If  '${rat}' == 'LTE'  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}

    Log  Perform "Unblock Cell" operation on ${rat} cell ${cell_id} from ${alias} BTS   console=True

    coam.Unblock Cell  dist_name=${cell_id}  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}  connection=${alias}

    Log  Check ${alias} BTS state and alarms after "Unblock Cell" operation on ${rat} cell ${cell_id}  console=True

    Assert  class_name=${cell_class_name}  id=${cell_id}  parameters=${CELL_state_unblocked_check}  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  connection=${alias}
    Wait Until Keyword Succeeds  60s  3s  Check cell is enabled online  ${cell_id}  ${cell_class_name}  ${alias}
    Log  ${rat} cell ${cell_id} status:\n - ${CELL_state_unblocked}  console=True
    Run Keyword If  '${cell_IOT_id}' != 'None' and '${LTE_IOT_check}' == 'True'  Run Keywords
    ...  Assert  class_name=${cell_class_name}  id=${cell_IOT_id}  parameters=${CELL_state_unblocked_check}  timeout=${CELL_UNBLOCK_MAX_WAIT_TIME}
    ...  connection=${alias}
    ...  AND  Log  ${rat} cell IOT ${cell_IOT_id} status:\n - ${CELL_state_unblocked}  console=True

    Get and Check Alarms SOAM  alias=${alias}  poll_interval=5s  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}
    Log  ${alias} BTS site - expected, ignored and critical alarms checked  console=True

    Sleep  5s  reason=Waiting time before check no impact on other cells

    Log  Check all cloud/classical BTS other cells are not impacted by "Unblock Cell" operation on ${rat} cell ${cell_id} from ${alias} BTS
    ...  console=True
    Check BTS cells are enabled online with exceptions  timeout=3
    Log  All cloud/classical BTS other cells status is OK.  console=True

Check cell is enabled online
    [Arguments]  ${cell_id}  ${cell_class_name}  ${alias}
    ${cell_status_enabled_degraded_check}=  Set Variable  operationalState=${Enabled_}, availabilityStatus=${Degraded_}
    ${cell_status_enabled_degraded_found}=  Run Keyword And Return Status  Assert  class_name=${cell_class_name}  id=${cell_id}
    ...  parameters=${cell_status_enabled_degraded_check}  timeout=3  connection=${alias}
    Should Be Equal As Strings  ${cell_status_enabled_degraded_found}  False

Count number of SBTS LTE alarms
    [Arguments]  ${cell_id}  ${alias}

    ${value}=  Get From Dictionary  ${${alias}_LTE_cell_IOT_mapping_dict}  ${cell_id}
    ${LTE_alarm_count}=  Run Keyword If  '${value}' == 'None'  Set Variable  1
    ...  ELSE
    ...  Set Variable  2

    [Return]  ${LTE_alarm_count}

Get and check KPI17a and KPI17b info from events
    [Arguments]  ${cell_id}  ${rat}  ${vdu_alias}  ${CYCLE}

    Log  Get and check KPI17a and KPI17b info for cell ${cell_id} from ${vdu_alias} events  console=True

    ${obj_type}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL

    Export KPI Results to File  alias=${vdu_alias}  obj=CELL  obj_type=${obj_type}  obj_id=${vdu_alias} ${cell_id}  action_1=Block Cell
    ...  action_2=Unblock Cell  kpi_reported_1=KPI_17a  kpi_reported_2=KPI_17b  event_value_1=${vdu_cell_kpi_17a}  event_value_2=${vdu_cell_kpi_17b}
    ...  cycle=${CYCLE}  source_info=events

    Check and set KPI verdict  kpi17a  ${vdu_cell_kpi_17a}  ${${rat}_CELL_BLOCK_WRN_THR}
    Check and set KPI verdict  kpi17b  ${vdu_cell_kpi_17b}  ${${rat}_CELL_UNBLOCK_WRN_THR}

Get and check KPI17a and KPI17b info from IMS file
    [Arguments]  ${cell_id}  ${rat}  ${alias}  ${CYCLE}

    ${cell_label}=  Fetch From Right  ${cell_id}  /

    Log  Get and check KPI17a and KPI17b info for cell ${cell_label} from ${alias} BTS IMS file  console=True

    ${kpi_name_delta_dict}=  Get and check KPI info from IMS file  kpi_names=kpi17a, kpi17b
    ...  kpi_thresholds=${${rat}_CELL_BLOCK_WRN_THR}, ${${rat}_CELL_UNBLOCK_WRN_THR}  alias=${alias}  cell_dist_name=${cell_id}
    ...  start_point_timestamp_UTC=${date_timestamp_start_UTC}  end_point_timestamp_UTC=${date_timestamp_end_UTC}
    ${kpi_delta_list_17a}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi17a
    ${kpi_delta_list_17b}=  Get From Dictionary  ${kpi_name_delta_dict}  kpi17b

    ${obj_type}=  Set Variable If  '${rat}'=='NR'  NRCEL  '${rat}'=='LTE'  LNCEL  '${rat}'=='WCDMA'  WNCEL  '${rat}'=='GSM'  GNCEL

    Export KPI Results to File  alias=${alias}  obj=CELL  obj_type=${obj_type}  obj_id=${alias} ${cell_label}  action_1=Block Cell
    ...  action_2=Unblock Cell  kpi_reported_1=KPI_17a  kpi_reported_2=KPI_17b  event_value_1=${kpi_delta_list_17a[0]}
    ...  event_value_2=${kpi_delta_list_17b[0]}  cycle=${CYCLE}  source_info=ims

Check if all BTS cells are unblocked

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' == 'CBTS'
        ...  Check if CBTS VDU cells are unblocked  ${alias}
        ...  ELSE IF  '${${alias.upper()}}[${alias.upper()}_TECH]' in ['NR', 'LTE', 'SBTS']
        ...  Admin Check if BTS cells are unblocked  ${alias}

    END

Particular Teardown
    Run Keyword And Continue On Failure  Check if all BTS cells are unblocked
    Export KPI results to File Global  kpi_log_file_name=KpiTimeInfo

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
