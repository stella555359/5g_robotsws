*** Settings ***
Documentation
    ...  Verification of operability function for cell block/unblock scenario

Resource  ../../common_resources/ca_KPI_general.robot


*** Variables ***
${CELL_ID}  ${EMPTY}  # Cell distName to be blocked, default are all cells.


*** Keywords ***
TC__KPI__Cell_block_unblock
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21230
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...
    ...  15.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21230 - New TC
    ...  05.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21658 - 5G Support for cells
    ...  20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22066 - Adapt KPI TCs for CNI-61110
    ...  24.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22721 - Remove Log all TX Power
    ...  22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22843 - Adjust delta results to be collected from single runs
    ...  17.05.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23143 - Monitor TRX status for computing KPIs for GSM cells
    ...  17.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23297 - Remove usageState check for 5G cells
    ...  10.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23848 - Migrate from hran_ims to oam_kpi_calculations
    ...  10.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24073 - Log delta to console
    ...  11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24107 - Save delta in json file after every TC
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24133 - Remove Cells state verification keyword
    ...  18.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24130 - Refactor TC with best practices
    ...  05.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24210 - Move Costum Test Teardown implementation to TC Teardown
    ...  30.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24589 - Improve kpi17b calculation for GSM cells
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  24.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30323 - Drop ute_admin_infomodel usage from KPI test cases
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-4069.png#

    Set Tags  CA-KPI  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-george.chincea@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf  PHASE-CRT  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923  FEATURE-RP001486_RP000923
    ...  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923  SW-SBTS17  SW-SBTS18  SW-SBTS19  SW-SBTS20  SW-SBTS21  SW-SBTS22

    TC Preconditions
    Step 1: Cells State Verification Before Cells Block
    Step 2: Cells block operation is trigerred via ADMIN API. Blocked cells states are verified.
    Step 3: Check Active Alarms
    Step 4: Cells unblock operation is trigerred via ADMIN API. Unblocked cells states are verified.


TC Preconditions
    Log  ${\n}TC Preconditions: Set variables and Select cells for testing  console=true
    ${blocked_cells}  Create List
    Set Test Variable  ${BLOCKED_CELLS}
    Select Cells For Testing


Step 1: Cells State Verification Before Cells Block
    Log  ${\n}Step 1: Cell state verification before cell block  console=true
    FOR  ${cell}  IN  @{CELLS_LIST}
        ${cell_type}  Get Regexp Matches  ${cell}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell}  blockingState=${UNBLOCKED}, operationalState=${ENABLED}  timeout=300
    END


Step 2: Cells Block Operation Is Trigerred Via ADMIN API. Blocked Cells States Are Verified.
    Log  ${\n}Step 2: Cell block operation is trigerred via ADMIN API. Blocked cells states are verified.  console=true
    Block Cell
    Sleep  20s


Step 3: Check Active Alarms
    Log  ${\n}Step 3: Check active alarms  console=true
    Check Active Alarms


Step 4: Cells Unblock Operation Is Trigerred Via ADMIN API. Unblocked Cells States Are Verified.
    Log  ${\n}Step 4: Cell unblock operation is trigerred via ADMIN API. Unblocked cells states are verified.  console=true
    Unblock Cell
    IF  ${BLOCKED_CELLS}  Fail  Unblock was not succesfull on all cells


Select Cells For Testing
    Log  ${\n}Select cells for testing  console=true
    ${all_cells}  Get All Cells Distname
    IF  '${CELL_ID}'=='${EMPTY}'
        Set Test Variable  ${CELLS_LIST}  ${all_cells}
        Log  All cells will be tested  console=true
    ELSE
        Set Test Variable  @{CELLS_LIST}  ${CELL_ID}
        Log  Cell ${CELL_ID} will be tested  console=true
    END


Get All Cells Distname
    ${nrcel}  Get Ids For All  NRCEL
    ${lncel}  Admin Get IDs For All LTE Cells
    ${wncel}  Get Ids For All  WNCEL
    ${gncel}  Get Ids For All  GNCEL
    ${cells_list}  Evaluate  [cell_dn for cell_dn in ${nrcel}+${lncel}+${wncel}+${gncel} if 'RUNTIME_VIEW' in cell_dn]
    Set Test Variable  ${CELLS_LIST}

    RETURN  ${CELLS_LIST}


Block Cell
    FOR  ${cell}  IN  @{CELLS_LIST}
        Log  Block cell ${cell}  console=true
        ${block_status}  Run Keyword And Return Status
        ...  coam.Block Cell  dist_name=${cell}  timeout=300
        IF  ${block_status}
            Append To List  ${BLOCKED_CELLS}  ${cell}
            Log  Block ${cell} passed  console=true
        ELSE
            Set Test Failed  Block ${cell} failed
        END
        ${cell_type}  Get Regexp Matches  ${cell}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell}  blockingState=${BLOCKED}, operationalState=${DISABLED}  timeout=300
    END
    IF  ${BLOCKED_CELLS}
        Log  Block was performed successfully on cells  console=true
    ELSE
        Fail  Block was not succesfull on any cell
    END


Unblock Cell
    Set Test Variable  @{CELLS_TO_CHECK_AFTER_UNBLOCK}  @{BLOCKED_CELLS}
    FOR  ${cell}  IN  @{BLOCKED_CELLS}
        Log  Unblock cell ${cell}  console=true
        ${unblock_status}  Run Keyword And Return Status
        ...  coam.Unblock Cell  dist_name=${cell}  timeout=240
        IF  ${unblock_status}
            Remove Values From List  ${BLOCKED_CELLS}  ${cell}
            Log  Unblock ${cell} passed  console=true
        ELSE
            Set Test Restriction  Unblock ${cell} failed
        END
        ${cell_type}  Get Regexp Matches  ${cell}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell}  blockingState=${UNBLOCKED}, operationalState=${ENABLED}  timeout=120
        Wait Until Keyword Succeeds  300  30  Check If Cell Is Not Degraded  ${cell_type}[0]  ${cell}
    END


Create Alarms Patterns
    Log  Creating alarms patterns  console=true
    ${iot_cells_map}  Admin Get LTE CELL IOT Mapping List
    ${expected_affected_cells}  Evaluate
    ...  [iot for (lte, iot) in ${iot_cells_map}.items() if (lte in ${BLOCKED_CELLS} and iot!='None') ] + ${BLOCKED_CELLS}
    ${expected_alarms}  Create List
    ${affected_cells_list}  Create List

    FOR  ${cell}  IN  @{expected_affected_cells}
        ${regex_pattern}  Get Alarm Pattern  ${cell}
        ${expected_alarm}  Create Dictionary  configObjectName=${regex_pattern}
        ${exist_in_list}  Run Keyword And Return Status
        ...  List Should Contain Value  ${affected_cells_list}  ${regex_pattern}
        IF  ${exist_in_list}==${FALSE}
            Append To List  ${affected_cells_list}  ${regex_pattern}
            Append To List  ${expected_alarms}  ${expected_alarm}
        END
    END

    ${critical_alarm}  Create Dictionary  faultId=49
    ${critical_alarms}  Create List  ${critical_alarm}
    Set Test Variable  ${EXPECTED_ALARMS}
    Set Test Variable  ${CRITICAL_ALARMS}


Check Active Alarms
    Create Alarms Patterns
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${EXPECTED_ALARMS}  critical_patterns=${CRITICAL_ALARMS}
    IF  ${status}
        Log  Unit blocked (0049) is active for every blocked Cells  console=true
    ELSE
        Set Test Failed  Unit blocked (0049) is not active for every blocked Cells
    END


Get Alarm Pattern
    [Arguments]  ${cell}

    ${is_runtime_object}  Run Keyword And Return Status
    ...  Should Match Regexp  ${cell}  .*/RUNTIME_VIEW-.*
    IF  ${is_runtime_object}
        ${alarm_pattern}  _Get Alarm Pattern For Runtime Object  ${cell}
    ELSE
        ${alarm_pattern}  _Get Alarm Pattern For Scf Object  ${cell}
    END

    RETURN  ${alarm_pattern}


_Get Alarm Pattern For Scf Object
    [Arguments]  ${cell}

    ${_}  ${scf_dn_split}  Split String From Right  ${cell}  SCF-1\/
    ${m}  Get Regexp Matches  ${scf_dn_split}  MRBTS_A-(\\d*)\\/LNBTS_A-(\\d*)\\/LNCEL_A-(\\d*)  1  2  3
    ${regex_pattern}  Set Variable  MRBTS-${m[0][0]}/LNBTS-${m[0][1]}/LNCEL-${m[0][2]}

    RETURN  ${regex_pattern}


_Get Alarm Pattern For Runtime Object
    [Arguments]  ${cell}

    ${cell_class_name}  Get Regexp Matches  ${cell}  [A-Z]{2}CEL
    ${ref}  Get Parameters For  ${cell_class_name}[0]  ${cell}/REF-1
    ${m}  Get Regexp Matches  ${ref.id}  (\\w)(NCEL_|RCELL_)\\w(-\\d*)  1  2  3
    ${technology}  Set Variable  ${m[0][0]}
    ${id}  Set Variable  ${m[0][2]}
    ${regex_pattern}  Set Variable  ${technology}(N|R)?(BTS|CEL|CELL)(_R)?(-)?${id}

    RETURN  ${regex_pattern}


Recover Blocked Cells
    Log  ${\n}Trying to unblock all blocked cells  console=true
    FOR  ${cell}  IN  @{BLOCKED_CELLS}
        Log  Trying to unblock cell ${cell} after fail  console=true
        ${block_status}  Run Keyword And Return Status
        ...  coam.Unblock Cell  dist_name=${cell}
        IF  ${block_status}
            Log  Unblock ${cell} passed  console=true
        ELSE
            Log  Unblock ${cell} failed  console=true
        END
    END


Admin Get LTE CELL IOT Mapping List
    [Documentation]
    ...  Helper keyword providing LTE cells information related to IOT mapping
    ...  KW is returning a dictionary described as beneath:
    ...  - key: LTE cell DN
    ...  - value: LTE IOT cell DN (if IOT activated) or None (if IOT not activated)
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter                 | Description           |
    ...  | LTE_cell_IOT_mapping_dict | Dictionary of LTE cells mapping IOT feature |
    [Arguments]  ${alias}=default

    ${lte_cell_ids}  ${lte_iot_cell_ids}  Admin Get LTE CELL Ids List  ${alias}
    Sort List  ${lte_cell_ids}
    ${lte_cell_iot_mapping_dict}  Create Dictionary
    FOR  ${item}  IN  @{lte_cell_ids}
        ${cell_param_list}  coam.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${key_exist}  Run Keyword And Return Status
        ...  Get From Dictionary  ${cell_param_list}  nbIoTMode
        ${value}  Set Variable If  '${key_exist}' == 'False'  None  '${cell_param_list['nbIoTMode']}' == 'disabled'  None
        ...  '${cell_param_list['nbIoTMode']}' != 'disabled'  ${cell_param_list['nbIoTCell']['distName']}
        Set To Dictionary  ${lte_cell_iot_mapping_dict}  ${item}  ${value}
    END

    RETURN  ${lte_cell_iot_mapping_dict}


Admin Get LTE CELL Ids List
    [Documentation]
    ...  Helper keyword providing LTE cells Ids for FDD+TDD and IOT (inband, guardband and standalone) technologies .
    ...  KW is returning two lists for FDD+TDD and IOT cells Ids
    ...
    ...  *AUTHOR*
    ...  dinu.olariu@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter | Man. | Default | Description             |
    ...  | alias     | No   | default | alias of admin instance |
    ...
    ...  *RETURN*
    ...  | Parameter             | Description               |
    ...  | LTE_CELL_IDS_LIST     | List of FDD+TDD cells Ids |
    ...  | LTE_IOT_CELL_IDS_LIST | List of IOT cells Ids     |
    [Arguments]  ${alias}=default

    ${cell_id_list}  coam.Get Ids For All  LNCEL  alias=${alias}
    Sort List  ${cell_id_list}
    ${lte_cell_ids_list}  Create List
    ${lte_iot_cell_ids_list}  Create List
    FOR  ${item}  IN  @{cell_id_list}
        ${cell_param_list}  coam.Get Parameters For  LNCEL  ${item}  alias=${alias}
        ${cell_technology_found}  Run Keyword And Return Status
        ...  Variable Should Exist  ${cell_param_list['technology']}
        ${cell_cell_technology_found}  Run Keyword And Return Status
        ...  Variable Should Exist  ${cell_param_list['nbIoTCell']['cellTechnology']}
        ${cell_nb_io_t_mode_found}  Run Keyword And Return Status
        ...  Variable Should Exist  ${cell_param_list['nbIoTMode']}
        IF  ${cell_technology_found}
            IF  '${cell_param_list['technology']}'=='FDD' or '${cell_param_list['technology']}'=='TDD'
                Append To List  ${lte_cell_ids_list}  ${cell_param_list['id']}
            END
        END
        IF  ${cell_cell_technology_found}
            IF  '${cell_param_list['nbIoTCell']['cellTechnology']}'=='NB-IoT-FDD'
                Append To List  ${lte_iot_cell_ids_list}  ${cell_param_list['nbIoTCell']['distName']}
            END
        END
        IF  ${cell_technology_found} and ${cell_nb_io_t_mode_found}
            IF  '${cell_param_list['technology']}'=='NB-IoT-FDD' and '${cell_param_list['nbIoTMode']}'=='standalone'
                Append To List  ${lte_iot_cell_ids_list}  ${cell_param_list['id']}
            END
        END
    END
    Sort List  ${lte_cell_ids_list}
    Sort List  ${lte_iot_cell_ids_list}

    RETURN  ${lte_cell_ids_list}  ${lte_iot_cell_ids_list}


TC Setup
    Set Log Level  INFO
    Set Test Variable  ${DISABLE_WATCHDOG}  ${TRUE}
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=KPI__Cell_block_unblock


TC Teardown
    ${exists}  Run Keyword And Return Status
    ...  Variable Should Exist  ${BLOCKED_CELLS}
    IF  ${exists}
        Run Keyword If Test Failed  Recover Blocked Cells
    END
    Common Test Teardown
    FOR  ${cell_dn}  IN  @{CELLS_LIST}
        ${kpi17a}  Calculate Kpi17a  ${BTS_FILES}/IM/InfoModel_log.ims2  dist_name=${cell_dn}
        ${kpi17b}  Calculate Kpi17b  ${BTS_FILES}/IM/InfoModel_log.ims2  dist_name=${cell_dn}
        ${cell_id}  Fetch From Right  ${cell_dn}  /
        ${cell_id}  Remove String  ${cell_id}  _R
        Log  ${cell_id}:  console=true
        Log Delta In Seconds  ${kpi17a}[kpi17a][-1][delta]  kpi17a
        Log Delta In Seconds  ${kpi17b}[kpi17b][-1][delta]  kpi17b
    END
    Save Delta Results  kpi17a
    Save Delta Results  kpi17b
    Set Log Level  TRACE
