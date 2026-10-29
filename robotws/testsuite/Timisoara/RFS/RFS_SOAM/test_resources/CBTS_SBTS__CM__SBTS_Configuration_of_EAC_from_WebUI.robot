*** Settings ***
Documentation    TC__CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
Variables    tc_variables/cbts_sbts__cm__sbts_configuration_of_eac_from_webui_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3   # Number of cycles to perform EAC commissioning, default value 3.
${RMOD_SERIAL_NUMBER}  # RMOD serial number where EAC will be commissioned. Mandatory, deafult Empty.

*** Keywords ***
TC__CBTS_SBTS__CM__SBTS_Configuration_of_EAC_from_WebUI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29609
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for Configuration of External Fault Lines via Commissioning Wizard from WebUI
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial all BTS states and alarms
    ...  - check test argument values validity
    ...  - perform EAC commissioning on VDU via Commissioning Wizard, checking states and alarms
    ...  - delete previously commissioned EAC on VDU via Commissioning Wizard, checking states and alarms
    ...  - check final all BTS states and alarms
    ...  Pass criteria: EAC commissioning via Commissioning Wizard works as expected, states and alarms are as expected
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 04.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29609 - [CB012501-CR-B]CB012501_RFS_vRAN_Removal of EAC (External Alarm Control)
    ...  from vDU configuration using dedicated page of Commissionig Wizzard
    ...  - 21.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29969 - [CB015051] rename TCs to shorten scripts and alarm files names
    ...  - 20.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30346 - Fix element is not clickable error

    Set Tags    CA-CM    OWNER-violeta.zanfirescu@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform VDU EAC commissioning via Commissioning Wizard
        Step 4: Check final all BTS states
        Step 5: Check final all BTS alarms
        Step 6: Check final number and state of Cells and RMs
    END
    Step 7: Collect snapshot on demand on VDU

TC Preconditions
    Log  Check test argument values validity  console=True
    Should Not Be Empty  ${RMOD_SERIAL_NUMBER}
    Get and check RM info precondition

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

Step ${index}: Perform VDU EAC commissioning via Commissioning Wizard

    Log  Step ${index}: Perform VDU EAC commissioning via Commissioning Wizard  console=True

    ${eac_VDU_alias_list}=  Split String  ${eac_VDU_alias}  separator=
    ${alias}=  Get From List  ${eac_VDU_alias_list}  0
    ${vdu_alias}=  Get From List  ${eac_VDU_alias_list}  1

    Perform EAC commissioning via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms after EAC commissioning
    Delete EAC via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms after deleting EAC

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Step ${index}: Collect snapshot on demand on VDU

    Log  Step ${index}: Collect snapshot on demand on VDU  console=True

    ${yyyy}  ${mm}  ${dd}  ${hh}  ${min}  ${ss}=  Get Time  format=year,month,day,hour,min,sec
    ${snapshot_and_alarms_dir}=  Set Variable  ${Test Results Dir}/Snapshot__${yyyy}-${mm}-${dd}__${hh}-${min}-${ss}
    ${status}=  Run Keyword And Return Status  OperatingSystem.Directory Should Exist  ${snapshot_and_alarms_dir}
    Run Keyword If  not ${status}  Create Directory  ${snapshot_and_alarms_dir}

    FOR  ${alias}  IN  @{alias_list}

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]'=='CBTS' and '${alias}' in '${eac_VDU_alias}'
        ...  Collect VDU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    END

Get and check RM info precondition
    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${alias}  VDU
        Continue For Loop If  not ${is_vdu_alias}

        ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${RM_found}=  Evaluate  '${RMOD_SERIAL_NUMBER}' in ${RM_sn_list}

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=
        ...  VDU Get RMOD sn id pn interface info  ${alias}
        ${RM_id}=  Get From Dictionary  ${VDU_RMOD_sn_id_dict}  ${RMOD_SERIAL_NUMBER}
        ${RM_pn}=  Get From Dictionary  ${VDU_RMOD_sn_pn_dict}  ${RMOD_SERIAL_NUMBER}

        Set Test Variable  ${RM_id}
        Set Test Variable  ${RM_pn}
        Set Test Variable  ${eac_VDU_alias}  ${alias}
        Exit For Loop If  ${RM_found}

    END

    Run Keyword If  not ${RM_found}  Run Keywords
    ...  Log Long String  Selected value ${RMOD_SERIAL_NUMBER} for test argument \${RMOD_SERIAL_NUMBER} is not valid. Please select a valid value for
    ...  test argument \${RMOD_SERIAL_NUMBER}  level=ERROR
    ...  AND  Fail  Improper value for argument!

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked

    ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
    ...  vdu_connection=${eac_VDU_alias}
    ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${eac_VDU_alias}

    ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
    ${VDU_NR_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

    Set Test Variable  ${VDU_RMOD_ids_list}
    Set Test Variable  ${VDU_NR_CELL_ids_list}

Perform EAC commissioning via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Configure New EAC device  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Configure New EAC device
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}

    Log  *** Configuring new EAC device on ${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id} ***  console=true

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='EAC Settings']
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id}']

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_columns}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//thead/tr/th

    Execute JavaScript  document.querySelector("div.p-datatable-wrapper").scrollLeft = 0

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text   (${table_class})[1]//thead/tr/th[${column}]

        Run Keyword If  '${column_value}' == 'Actions'  Run Keywords
        ...  Add external fault lines for all RMOD ports  table_column=${column}
        ...  AND  Exit For Loop

    END

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text   (${table_class})[1]//thead/tr/th[${column}]

        Run Keyword If  '${column_value}' == 'In use'
        ...  Set In Use and Polarity EAC parameters  table_column=${column}  parameter_name=In use  parameter_value=true
        ...  ELSE IF  '${column_value}' == 'Name'
        ...  Set Name EAC parameter  table_column=${column}  parameter_name=Name
        ...  ELSE IF  '${column_value}' == 'Polarity'
        ...  Set In Use and Polarity EAC parameters  table_column=${column}  parameter_name=Polarity  parameter_value=Normally_closed
        ...  ELSE IF  '${column_value}' == 'Severity'
        ...  Set Severity EAC parameter and calculate alarm number  table_column=${column}  parameter_name=Severity
        ...  ELSE  Continue For Loop

    END

    Log  EAC device was succesfully configured!  console=True

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Activate Plan without VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Add external fault lines for all RMOD ports
    [Arguments]  ${table_column}  ${timeout}=30

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_rows}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//tbody/tr

    Log  Adding ${table_rows} external fault lines by pressing the "+" button  console=True

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        Execute JavaScript  document.querySelector("div.p-datatable-wrapper").scrollLeft = 0

        ${plus_button}=  Set Variable  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]/p-button[1]/button[1]/span[1]

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=${plus_button}

    END

    Sleep  1s  reason=Waiting time to control execution speed

Set In Use and Polarity EAC parameters
    [Arguments]  ${table_column}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_rows}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//tbody/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows} + 1

        Log  "${parameter_name}" parameter for RMOD port ${table_row} EAC_IN-${table_row} will be set to: ${parameter_value}   console=True

        Execute JavaScript  document.querySelector("div.p-datatable-wrapper").scrollLeft = 0

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath= (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //li[@aria-label='${parameter_value}']

        ${updated_parameter_value}=  Get Text  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

    END

    Log  ${parameter_name} parameter succesfully set on all RMOD ports!  console=True
    Sleep  1s  reason=Waiting time to control execution speed

Set Name EAC parameter
    [Arguments]  ${table_column}  ${parameter_name}  ${timeout}=30

    ${parameter_value}=  Set Variable  1
    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_rows}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        Log  "${parameter_name}" parameter for RMOD port ${table_row} EAC_IN-${table_row} will be set to: ${parameter_value}   console=True

        Execute JavaScript  document.querySelector("div.p-datatable-wrapper").scrollLeft = 0

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath= (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]
        Input Text  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]//input[@type='text']  ${parameter_value}

        ${updated_parameter_value}=  Get Value  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]//input[@type='text']

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

        ${parameter_value}=  Evaluate  ${parameter_value} + 1

    END

    Log  ${parameter_name} parameter succesfully set on all RMOD ports!  console=True
    Sleep  1s  reason=Waiting time to control execution speed

Set Severity EAC parameter and calculate alarm number
    [Arguments]  ${table_column}  ${parameter_name}  ${timeout}=30

    ${eac_vdu_alarm_id_severity_dict}=  Create Dictionary
    ${parameter_value}=  Set Variable  Minor

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_rows}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        Log  "${parameter_name}" parameter for RMOD port ${table_row} EAC_IN-${table_row} will be set to: ${parameter_value}   console=True

        Execute JavaScript  document.querySelector("div.p-datatable-wrapper").scrollLeft = 0

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath= (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //li[@aria-label='${parameter_value}']

        ${updated_parameter_value}=  Get Text  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

        ${alarm_id_num}=  Evaluate  ${table_row} - 1
        Set To Dictionary  ${eac_vdu_alarm_id_severity_dict}  ${alarm_id_num}  ${parameter_value}

        ${parameter_value}=  Run Keyword If  '${parameter_value}' == 'Minor'
        ...  Set Variable  Major
        ...  ELSE IF  '${parameter_value}' == 'Major'
        ...  Set Variable  Critical
        ...  ELSE IF  '${parameter_value}' == 'Critical'
        ...  Set Variable  Minor

    END

    Log  ${parameter_name} parameter succesfully set on all RMOD ports!  console=True

    Calculate eac expected alarms  expected_alarms_count=${table_rows}
    Set Test Variable  ${eac_vdu_alarm_id_severity_dict}

Check if parameter was set properly
    [Arguments]  ${parameter_name}  ${parameter_value}  ${updated_parameter_value}

    ${status}=  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${parameter_value}  ${updated_parameter_value}
    Run Keyword If  not ${status}  Run Keywords
    ...  Log  ${parameter_name} parameter was not set properly! Expected/found value: ${parameter_value}/${updated_parameter_value}  level=ERROR
    ...  AND  Fail  ${parameter_name} parameter was not set properly! Expected/found value:  ${parameter_value}/${updated_parameter_value}

Calculate eac expected alarms
    [Arguments]  ${expected_alarms_count}

    ${eac_vdu_expected_alarms_list}=  Create List

    FOR  ${alarm_num}  IN RANGE  ${expected_alarms_count}

        Append To List  ${eac_vdu_expected_alarms_list}  @{${eac_vdu_alias.upper()}_EXPECTED_ALARMS_140${alarm_num}}

    END

    Set Test Variable  ${eac_vdu_expected_alarms_count}  ${expected_alarms_count}
    Set Test Variable  ${eac_vdu_expected_alarms_list}


Check cloud BTS states and alarms after EAC commissioning
    Log  *** Check ${eac_vdu_alias} states and alarms after EAC commissioning ***  console=True

    Log  Check ${eac_vdu_alias} status:  console=True
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} alarms:  console=True

    FOR  ${alarm_num}  IN RANGE  ${eac_vdu_expected_alarms_count}

        ${alarm_severity}=  Get From Dictionary  ${eac_vdu_alarm_id_severity_dict}  ${alarm_num}
        Log Long String  ${eac_vdu_alias} "BASE STATION EXTERNAL ALARM NOTIFICATION (140${alarm_num})" alarm with severity ${alarm_severity},
        ...  expected number: 1  console=True

    END

    Get and Check Alarms CBTS VDU  vdu_alias=${eac_vdu_alias}  expected_alarms=${eac_vdu_expected_alarms_list}
    ...  ignored_alarms=${${eac_vdu_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${eac_vdu_alias.upper()}_CRITICAL_ALARMS}

    FOR  ${alarm_num}  IN RANGE  ${eac_vdu_expected_alarms_count}

        ${alarm_severity}=  Get From Dictionary  ${eac_vdu_alarm_id_severity_dict}  ${alarm_num}
        Log Long String  ${eac_vdu_alias} "BASE STATION EXTERNAL ALARM NOTIFICATION (140${alarm_num})" alarm with severity ${alarm_severity},
        ...  found number: 1, as expected!  console=True

    END

    Log  ${eac_vdu_alias} site - expected, ignored and critical alarms checked  console=True

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

    END
    Log  ${vdu_alias} RMODs status:\n - ${RMOD_state}  console=True

Check CBTS VDU cell state
    [Arguments]  ${VDU_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}  ${CELL_administrative_state_check}
    ...  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}

    END
    Log  ${vdu_alias} cells status:\n - ${CELL_state}  console=True

Delete EAC via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Delete EAC device  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Delete EAC device
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}

    Log  *** Delete previously configured EAC device on ${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id} ***  console=true

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='EAC Settings']
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id}']

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_columns}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//thead/tr/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text   (${table_class})[1]//thead/tr/th[${column}]

        Run Keyword If  '${column_value}' == 'Actions'  Run Keywords
        ...  Delete external fault lines for all RMOD ports  table_column=${column}
        ...  AND  Exit For Loop

    END

    Log  EAC device was succesfully deleted!  console=True

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Activate Plan without VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Delete external fault lines for all RMOD ports
    [Arguments]  ${table_column}  ${timeout}=30

    ${table_class}=  Set Variable  //p-table[@class='p-element ot-scroll-table ng-star-inserted']
    ${table_rows}=  SeleniumLibrary.Get Element Count  (${table_class})[1]//tbody/tr

    Log  Deleting ${table_rows} external fault lines by pressing the "delete" button  console=True

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        ${delete_button}=  Set Variable  (${table_class})[1]//tbody/tr[${table_row}]/td[${table_column}]/p-button[2]/button[1]/span[1]

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=${delete_button}
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//span[normalize-space()='Delete']

    END

    Sleep  1s  reason=Waiting time to control execution speed

Check cloud BTS states and alarms after deleting EAC
    Log  *** Check ${eac_vdu_alias} states and alarms after deleting EAC ***  console=True

    Log  Check ${eac_vdu_alias} status:  console=True
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  5  ${eac_vdu_alias}

    Log  Check ${eac_vdu_alias} alarms:  console=True
    Log  ${eac_vdu_alias} "BASE STATION EXTERNAL ALARM NOTIFICATION (140x)" alarm, expected number: 0  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${eac_vdu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${eac_vdu_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${eac_vdu_alias.upper()}_CRITICAL_ALARMS}
    Log  ${eac_vdu_alias} "BASE STATION EXTERNAL ALARM NOTIFICATION (140x)" alarm, found number: 0, as expected!  console=True
    Log  ${eac_vdu_alias} site - expected, ignored and critical alarms checked  console=True

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown