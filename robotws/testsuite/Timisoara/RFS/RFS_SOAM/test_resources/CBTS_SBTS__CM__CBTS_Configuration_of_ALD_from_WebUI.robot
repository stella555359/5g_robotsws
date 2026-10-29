*** Settings ***
Documentation    TC__CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
Variables    tc_variables/cbts_sbts__cm__cbts_configuration_of_ald_from_webui_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}  3                          # Number of cycles to perform MHA & RET & Passive device commissioning, default value 3.
${RMOD_SERIAL_NUMBER}                         # RMOD serial number where MHA & RET are phisically connected. Mandatory, deafult Empty.
${MHA_SERIAL_NUMBER}                          # MHA serial number. Mandatory, deafult Empty.
${RET_SERIAL_NUMBER}                          # RET serial number. Mandatory, deafult Empty.
${RET_PRODUCT_CODE}                           # RET product code. Mandatory, deafult Empty.
${MHA_PRODUCT_CODE}                           # MHA product code. Mandatory, deafult Empty.
${MHA_TYPE}  Nokia                            # MHA Type. Possible Values: Any value written exactly as it is displayed in WebEM; ex: WMDH (471443A),
                                              # default Nokia.
${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA1}  # RMOD ANT port number for MHA LNA-1 Amplified antenna line. Mandatory, deafult Empty. (ex: ANT1)
${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA2}  # RMOD ANT port number for MHA LNA-2 Amplified antenna line. Mandatory in case you have 2 LNAs
                                              # (ex for Nokia MHA), deafult Empty. (ex: ANT1)
${RMOD_ANT_PORT_MHA_HDLC}                     # RMOD ANT port number for MHA HDLC communication. Mandatory, deafult Empty. (ex: ANT1)
${RMOD_ANT_PORT_MHA_DC_POWER}                 # RMOD ANT port number for MHA DC power source. Mandatory, deafult Empty. (ex: ANT1)
${RMOD_ANT_PORT_DC_VOLTAGE_LEVEL}             # RMOD ANT port number for DC voltage level. Mandatory, deafult Empty. (ex: ANT1)
${BTS_MAX_WAIT_TIME}  900                     # Maximum time to wait for BTS OnAir, default value 900.

*** Keywords ***
TC__CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29069
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for Commissioning new MHA, RET and Passive Device via Commissioning Wizard, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check test argument values validity
    ...  - perform MHA and Passive Device commissioning on VDU via Commissioning Wizard
    ...  - perform RET commissioning on VDU via Commissioning Wizard
    ...  - perform VDU commissioning with initial SCF
    ...  Pass criteria: MHA, RET and Passive Device commissioning via Commissioning Wizard works as expected, states and alarms are as expected
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 20.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29069 - [CBTS]CB12501-CR-D Comissioning Wizard -
    ...  Add ALD and RET into configuration
    ...  - 08.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29611 - Adding MHA_TYPE values options to
    ...  [1]CBTS_SBTS__CM__Configuration_of_Antenna_Line_Devices_via_Commissioning_Wizard_from_WebUI
    ...  - 21.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29969 - [CB015051] rename TCs to shorten scripts and alarm files names
    ...  - 28.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29995 - Add Product code for the MHA commissioning
    ...  - 16.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30630 - CBTS_SBTS__CM__CBTS_Configuration_of_ALD_from_WebUI failes with
    ...  Keyword 'Click Element' failed after retrying for 30 seconds.
    ...

    Set Tags    CA-CM    OWNER-cosmin.florea@nokia.com@nokia.com    AUTHOR-anca.tatar@nokia.com    PHASE-CRT    SW-SBTS25R3

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Set Test Variable  ${INDEX}
        Step 3: Perform VDU MHA ALD commissioning via Commissioning Wizard
        Step 4: Perform VDU Passive Device commissioning via Commissioning Wizard
        Step 5: Perform VDU RET ALD commissioning via Commissioning Wizard
        Step 6: Check after VDU MHA and RET commissioning all BTS states
        Step 7: Check after VDU MHA and RET commissioning all BTS alarms
        Step 8: Perform VDU Commissioning with initial SCF
        Step 9: Check final all BTS states
        Step 10: Check final all BTS alarms
        Step 11: Check final number and state of Cells and RMs
    END
    Step 12: Collect snapshot on demand on VDU

TC Preconditions
    Log  Check test argument values validity  console=True
    Mandatory input parameters should not be empty
    Get and check RM info precondition
    Get and check MHA Info
    Get and check RET Info
    Get and check Passive Device Info

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

Step ${index}: Perform VDU MHA ALD commissioning via Commissioning Wizard

    Log  Step ${index}: Perform VDU MHA ALD commissioning via Commissioning Wizard  console=True

    ${MHA_type_list_one_LNA}=  Create List  IMF (E14V00P31)  WHMA (CS72995.02)  WHMA (CS72995.03)  Other
    ${ald_VDU_alias_list}=  Split String  ${ald_VDU_alias}  separator=
    ${alias}=  Get From List  ${ald_VDU_alias_list}  0
    ${vdu_alias}=  Get From List  ${ald_VDU_alias_list}  1

    Check HDLC communication and DC Power Source before commissioning  ald_antenna_port=${RMOD_ANT_PORT_DC_VOLTAGE_LEVEL}
    ...  alias=${alias}  vdu_alias=${vdu_alias}
    Perform MHA ALD commissioning via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Run Keyword If  '${MHA_TYPE}' in ${MHA_type_list_one_LNA}
    ...  Check cloud BTS states and alarms after MHA/RET ALD commissioning  ald_type=MHA  alarm_num=1
    ...  ELSE  Check cloud BTS states and alarms after MHA/RET ALD commissioning  ald_type=MHA  alarm_num=2
    Activate DC power source on RMOD  ald_antenna_port=${RMOD_ANT_PORT_DC_VOLTAGE_LEVEL}  dc_voltage_value=AUTO  alias=${alias}
    ...  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms after activate DC power source on RMOD
    Check MHA widget  alias=${alias}  vdu_alias=${vdu_alias}
    Check that MHA parameters are not empty

Step ${index}: Perform VDU Passive Device commissioning via Commissioning Wizard

    Log  Step ${index}: Perform VDU Passive Device commissioning via Commissioning Wizard  console=True

    ${ald_VDU_alias_list}=  Split String  ${ald_VDU_alias}  separator=
    ${alias}=  Get From List  ${ald_VDU_alias_list}  0
    ${vdu_alias}=  Get From List  ${ald_VDU_alias_list}  1

    Perform Passive Device commissioning via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms  vdu_alias=${ald_VDU_alias}

Step ${index}: Perform VDU RET ALD commissioning via Commissioning Wizard

    Log  Step ${index}: Perform VDU RET ALD commissioning via Commissioning Wizard  console=True

    ${ald_VDU_alias_list}=  Split String  ${ald_VDU_alias}  separator=
    ${alias}=  Get From List  ${ald_VDU_alias_list}  0
    ${vdu_alias}=  Get From List  ${ald_VDU_alias_list}  1

    Perform RET ALD commissioning via Commissioning Wizard  alias=${alias}  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms after MHA/RET ALD commissioning  ald_type=RET  alarm_num=1
    Activate DC power source on RMOD  ald_antenna_port=RET  dc_voltage_value=true  alias=${alias}  vdu_alias=${vdu_alias}
    Check cloud BTS states and alarms after activate DC power source on RMOD
    Check RET widget  alias=${alias}  vdu_alias=${vdu_alias}
    Check that RET parameters are not empty

Step ${index}: Perform VDU Commissioning with initial SCF

    Log  Step ${index}: Perform VDU Commissioning with initial SCF  console=True

    Log  Perform VDU Commissioning on ${ald_VDU_alias}  console=True
    Log  Commissioning will be performed using ${${ald_VDU_alias.lower()}_scf_initial}  console=True

    VDU Perform Commissioning  scf_file=${${ald_VDU_alias.lower()}_scf_initial}  vdu_connection=${ald_VDU_alias}

    Wait For Target To Be Not Reachable TAF  hostname=${${ald_VDU_alias.lower()}_vdu_host}  timeout=300

    Sleep  20s

    Log  *** Check ${ald_VDU_alias} status and alarms after VDU Commissioning operation on ${ald_VDU_alias} ***  console=True
    Wait For Target To Be Reachable TAF  hostname=${${ald_VDU_alias.lower()}_vdu_host}  timeout=300

    Check cloud BTS states and alarms  vdu_alias=${ald_VDU_alias}

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

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]'=='CBTS' and '${alias}' in '${ald_VDU_alias}'
        ...  Collect VDU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    END

Mandatory input parameters should not be empty

    ${MHA_type_list_one_LNA}=  Create List  IMF (E14V00P31)  WHMA (CS72995.02)  WHMA (CS72995.03)  Other

    Should Not Be Empty  ${RMOD_SERIAL_NUMBER}
    Should Not Be Empty  ${RMOD_ANT_PORT_MHA_HDLC}
    Should Not Be Empty  ${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA1}
    Run Keyword If  '${MHA_TYPE}' not in ${MHA_type_list_one_LNA}  Should Not Be Empty  ${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA2}
    Should Not Be Empty  ${RMOD_ANT_PORT_MHA_DC_POWER}
    Should Not Be Empty  ${RMOD_ANT_PORT_DC_VOLTAGE_LEVEL}
    Should Not Be Empty  ${MHA_SERIAL_NUMBER}
    Should Not Be Empty  ${RET_SERIAL_NUMBER}
    Should Not Be Empty  ${RET_PRODUCT_CODE}

Get and check RM info precondition
    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    ${BTS_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}

    ${all_BTS_controller_role_RMOD_sn_list}=  Get all BTS controller role for configured RMOD from SCF

    FOR  ${alias}  IN  @{BTS_alias_list}

        ${is_vdu_alias}=  Run Keyword And Return Status  Should Contain  ${alias}  VDU
        Continue For Loop If  not ${is_vdu_alias}

        ${RM_sn_list}=  Get From Dictionary  ${BTS_alias_RMOD_sn_dict}  ${alias}
        ${BTS_controller_RMOD_sn_list}=  Get From Dictionary  ${all_BTS_controller_role_RMOD_sn_list}  ${alias}
        ${BTS_primary_controller_RMOD_sn_list}=  Get From Dictionary  ${BTS_controller_RMOD_sn_list}  BTS_primary_controller_RMOD_sn_list

        ${condition}=  Create Long String  ('${RMOD_SERIAL_NUMBER}' in ${RM_sn_list}) and ('${RMOD_SERIAL_NUMBER}' in ${shared_RMOD_sn_list})
        ...  and  ('${RMOD_SERIAL_NUMBER}' in ${BTS_primary_controller_RMOD_sn_list})
        ${RM_found}=  Evaluate  ${condition}

        ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=
        ...  VDU Get RMOD sn id pn interface info  ${alias}
        ${RM_id}=  Get From Dictionary  ${VDU_RMOD_sn_id_dict}  ${RMOD_SERIAL_NUMBER}
        ${RM_pn}=  Get From Dictionary  ${VDU_RMOD_sn_pn_dict}  ${RMOD_SERIAL_NUMBER}

        Set Test Variable  ${RM_id}
        Set Test Variable  ${RM_pn}
        Set Test Variable  ${ald_VDU_alias}  ${alias}
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
    Set Test Variable  ${CBTS_VDU_ALD_state_enabled}  Operational state=Enabled, Availability status=Online

    ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
    ...  vdu_connection=${ald_VDU_alias}
    ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${ald_VDU_alias}

    ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
    ${VDU_NR_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

    Set Test Variable  ${VDU_RMOD_ids_list}
    Set Test Variable  ${VDU_NR_CELL_ids_list}

Get and check MHA Info

    ${mha_ald_info}=  VDU Get MHA Information  vdu_connection=${ald_VDU_alias}

    Return From Keyword If  ${mha_ald_info} == @{EMPTY}

    FOR  ${mha_info}  IN  @{mha_ald_info}

        ${ald_dict}=  Get From Dictionary  ${mha_info}  ald
        ${serial_number}=  Get From Dictionary  ${ald_dict}  serial_number

        Run Keyword If  '${serial_number}' == '${MHA_SERIAL_NUMBER}'  Run Keywords
        ...  Log  MHA ALD with SN ${MHA_SERIAL_NUMBER} already commissioned!  level=ERROR
        ...  AND  Fail  MHA ALD with SN ${MHA_SERIAL_NUMBER} already commissioned!

    END

Get and check RET Info
    ${ret_ald_info}=  VDU Get RET Information  vdu_connection=${ald_VDU_alias}

    Return From Keyword If  ${ret_ald_info} == @{EMPTY}

    FOR  ${ret_info}  IN  @{ret_ald_info}

        ${ald_dict}=  Get From Dictionary  ${ret_info}  ald
        ${serial_number}=  Get From Dictionary  ${ald_dict}  serial_number

        Run Keyword If  '${serial_number}' == '${RET_SERIAL_NUMBER}'  Run Keywords
        ...  Log  RET ALD with SN ${RET_SERIAL_NUMBER} already commissioned!  level=ERROR
        ...  AND  Fail  RET ALD with SN ${RET_SERIAL_NUMBER} already commissioned!

    END

Get and check Passive Device Info
    ${BTS_SCF_PASSDEV_list}=  Get All Dist Names By Pattern from SCF  pattern=/PASSDEV-[\\d]+$  scf_path=${${ald_VDU_alias.lower()}_scf_initial}
    ...  alias=${ald_VDU_alias}
    ${passdev_status}=  Run Keyword And Return Status  Should Be Empty  ${BTS_SCF_PASSDEV_list}
    Run Keyword If  '${passdev_status}' == 'False'  Run Keywords
    ...  Log  Passive Device already commissioned!  level=ERROR
    ...  AND  Fail  Passive Device already commissioned!

Perform MHA ALD commissioning via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Add New MHA ALD device  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Add New MHA ALD device
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}

    Log  *** Adding new MHA ALD device wity type: ${MHA_TYPE} ***  console=true
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  //*[@id="nolinked-alds"]/div/div[2]/button/span[1]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Mouse Over  xpath=//span[@class="p-menuitem-text ng-star-inserted" and text()="MHA"]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[@class="p-menuitem-text ng-star-inserted" and text()="${MHA_TYPE}"]
    Log  ${MHA_TYPE} MHA ALD succesfully created!  console=true

    Sleep  1s  reason=Waiting time to control execution speed

    Set MHA/RET Control Protocol

    Set MHA/RET Controlling Port  ant_port=${RMOD_ANT_PORT_MHA_HDLC}

    Set MHA/RET Product Code  parameter_value=${MHA_PRODUCT_CODE}

    Configure MHA LNA

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Perform Activate Plan with VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Edit single-select parameter name and planned value table
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  *** ${parameter_name} will be set to: ${parameter_value} ***   console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='${parameter_value}']
    ${updated_parameter_value}=  Get Text  xpath=//span[contains(.,'${parameter_value}')]

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Fill parameter value in table
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]
    Wait Until Element Is Visible  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]//input
    Clear Element Text  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]//input
    Input Text  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]//input   ${parameter_value}
    Press Keys   xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]//input   TAB
    ${updated_parameter_value}=    Get Value    xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]//input

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Set MHA/RET Control Protocol

    ${parameter_name}=  Set Variable  Control protocol
    ${parameter_value}=  Set Variable  AISG 2.0

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${parameter_name}' != '${row_parameter_name}'

        Edit single-select parameter name and planned value table  table_row=${table_row}  parameter_name=${parameter_name}
        ...  parameter_value=${parameter_value}

        Exit For Loop

    END

Set MHA/RET Controlling Port
    [Arguments]  ${ant_port}

    ${parameter_name}=  Set Variable  Controlling port
    ${parameter_value}=  Set Variable  RMOD-${RM_id} (${RM_pn})/${ant_port}

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${parameter_name}' != '${row_parameter_name}'

        Edit single-select parameter name and planned value table  table_row=${table_row}  parameter_name=${parameter_name}
        ...  parameter_value=${parameter_value}

        Exit For Loop

     END

Set MHA/RET Product Code
    [Arguments]  ${parameter_value}

    ${parameter_name}=  Set Variable  Product code

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${row_parameter_name}' != '${parameter_name}'

        Fill parameter value in table    table_row=${table_row}  parameter_name=${parameter_name}
        ...  parameter_value=${parameter_value}

        Exit For Loop

     END

Configure MHA LNA
    [Arguments]  ${timeout}=30

    Log  *** Start configuring LNA-1 ***  console=True
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li/div/button/span
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  //div[@aria-label='LNA-1']
    Configure Amplified Antenna Line and DC Power Sources for LNA  amplified_antenna_line_port=${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA1}
    Log  LNA-1 was succesfully configured!  console=True

    ${status}=  Run Keyword And Return Status   Wait Until Keyword Succeeds  5  1
    ...  Click Element  //div[@aria-label='LNA-2']
    Return From Keyword If  '${status}' == 'False'

    Log  *** Start configuring LNA-2 ***  console=True
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  //div[@aria-label='LNA-2']
    Configure Amplified Antenna Line and DC Power Sources for LNA  amplified_antenna_line_port=${RMOD_ANT_PORT_MHA_AMPLIFIED_ANT_LINE_LNA2}
    Log  LNA-2 was succesfully configured!  console=True

Configure Amplified Antenna Line and DC Power Sources for LNA
    [Arguments]  ${amplified_antenna_line_port}

    ${amplified_antenna_line_parameter_value}=  Set Variable  RMOD-${RM_id} (${RM_pn})/${amplified_antenna_line_port}
    ${dc_power_sources_parameter_value}=  Set Variable  RMOD-${RM_id} (${RM_pn})/${RMOD_ANT_PORT_MHA_DC_POWER}

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Run Keyword If  '${row_parameter_name}' == 'Amplified antenna line'
        ...  Edit multi-select parameter name and planned value table  table_row=${table_row}  parameter_name=Amplified antenna line
        ...  parameter_value=${amplified_antenna_line_parameter_value}
        ...  ELSE IF  '${row_parameter_name}' == 'DC power sources'
        ...  Edit multi-select parameter name and planned value table  table_row=${table_row}  parameter_name=DC power sources
        ...  parameter_value=${dc_power_sources_parameter_value}

    END

Edit multi-select parameter name and planned value table
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='${parameter_value}']
    ${updated_parameter_value}=  Get Text  xpath=//span[contains(.,'${parameter_value}')]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Configure Passive Device
    [Arguments]  ${timeout}=30

    Log  *** Start Configure Passive Device ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Configure Passive Device')]

    Sleep  1s  reason=Waiting time to control execution speed
    ${panel_id}=  SeleniumLibrary.Get Element Attribute
    ...  //div[contains(@id,'-titlebar') and .//div[contains(text(),'Passive device list')]]  id
    ${btn_xpath}=  Set Variable  xpath=//div[@id='${panel_id}']/div[2]/p-button/button/span

    Wait Until Element Is Visible  ${btn_xpath}  30s

    Wait Until Keyword Succeeds  ${timeout}  5
    ...  Click Element  ${btn_xpath}

    Sleep  1s  reason=Waiting time to control execution speed

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Run Keyword If  '${parameter_name}' == 'DC source for MHA'
        ...  Edit multi-select parameter name and planned value table  table_row=${table_row}  parameter_name=DC source for MHA
        ...  parameter_value=ALD-1/LNA-1
        ...  ELSE IF  '${parameter_name}' == 'Inventory unit type'
        ...  Set Inventory unit type  table_row=${table_row}  parameter_name=Inventory unit type  parameter_value=1
        ...  ELSE IF  '${parameter_name}' == 'Vendor name'
        ...  Set Vendor name  table_row=${table_row}  parameter_name=Vendor name  parameter_value=1

    END

    Log  Passive Device succesfully configured!  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[contains(.,'Close')]

    Sleep  1s  reason=Waiting time to control execution speed

Set Inventory unit type
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]
    Input Text  xpath=(//input[@type='text'])[9]  ${parameter_value}
    ${updated_parameter_value}=  Get Value  xpath=(//input[@type='text'])[9]

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Set Vendor name
    [Arguments]  ${table_row}  ${parameter_name}  ${parameter_value}  ${timeout}=30

    Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[2]
    Input Text  xpath=(//input[@type='text'])[14]  ${parameter_value}
    ${updated_parameter_value}=  Get Value  xpath=(//input[@type='text'])[14]

    Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
    ...  updated_parameter_value=${updated_parameter_value}

    Sleep  1s  reason=Waiting time to control execution speed

Check if parameter was set properly
    [Arguments]  ${parameter_name}  ${parameter_value}  ${updated_parameter_value}

    ${status}=  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${parameter_value}  ${updated_parameter_value}
    Run Keyword If  ${status}
    ...  Log  ${parameter_name} succesfully set!  console=True
    ...  ELSE  Run Keywords
    ...  Log  ${parameter_name} was not set properly! Expected/found value: ${parameter_value}/${updated_parameter_value}  level=ERROR
    ...  AND  Fail  ${parameter_name} was not set properly! Expected/found value:  ${parameter_value}/${updated_parameter_value}

Check cloud BTS states and alarms after MHA/RET ALD commissioning
    [Arguments]  ${ald_type}  ${alarm_num}

    Log  *** Check ${ald_VDU_alias} states and alarms after ${ald_type} ALD commissioning ***  console=True

    ${FID4141_count}=  Set Variable  ${alarm_num}
    ${VDU_EXPECTED_ALARMS_4141_full}=  Prepare expected alarms list  ${${ald_VDU_alias.upper()}_EXPECTED_ALARMS_4141}
    ...  ${FID4141_count}

    ${timeout}=  Set Variable If  '${ald_type}' == 'MHA'  ${BTS_MAX_WAIT_TIME}  5

    Log  Check ${ald_VDU_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  ${timeout}  ${ald_VDU_alias}

    Log  Check ${ald_VDU_alias} alarms:  console=True
    Log Long String  ${ald_VDU_alias} "DC voltage administratively disabled (4141)" alarm, expected number:
    ...  ${FID4141_count}  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${ald_VDU_alias}  expected_alarms=${VDU_EXPECTED_ALARMS_4141_full}
    ...  ignored_alarms=${${ald_VDU_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${ald_VDU_alias.upper()}_CRITICAL_ALARMS}
    Log Long String  ${ald_VDU_alias} "DC voltage administratively disabled (4141)" alarm, found number:
    ...  ${FID4141_count}, as expected!  console=True
    Log  ${ald_VDU_alias} site - expected, ignored and critical alarms checked  console=True

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

Check CBTS VDU MHAs state
    [Arguments]  ${MHA_operational_state_check}  ${MHA_availability_status_check}  ${MHA_state}  ${timeout}  ${vdu_alias}

    Log  Check ${vdu_alias} MHAs status:  console=True

    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check MHAs Expected Status  operational_state=${MHA_operational_state_check}
    ...  availability_status=${MHA_availability_status_check}  vdu_connection=${vdu_alias}

    Log  ${vdu_alias} MHAs status:\n - ${MHA_state}  console=True

Check CBTS VDU RETs state
    [Arguments]  ${RET_operational_state_check}  ${RET_availability_status_check}  ${RET_state}  ${timeout}  ${vdu_alias}

    Log  Check ${vdu_alias} RETs status:  console=True

    Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check RETs Expected Status  operational_state=${RET_operational_state_check}
    ...  availability_status=${RET_availability_status_check}  vdu_connection=${vdu_alias}

    Log  ${vdu_alias} RETs status:\n - ${RET_state}  console=True

Activate DC power source on RMOD
    [Arguments]  ${ald_antenna_port}  ${dc_voltage_value}  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    ${status}=  Run Keyword And Return Status  Wait Until Keyword Succeeds  15  3  Click Element  ${VDU_DASHBOARD}
    Run Keyword If  '${status}' == 'False'  Close Start-up View From VDU WebEM
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Activate DC power source  alias=${alias}  vdu_alias=${vdu_alias}  ald_antenna_port=${ald_antenna_port}  dc_voltage_value=${dc_voltage_value}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Check HDLC communication and DC Power Source before commissioning
    [Arguments]  ${alias}  ${vdu_alias}  ${ald_antenna_port}  ${timeout}=30

    Log  Check HDLC communication and DC Power Source before commissioning  console=True

    Set Test Variable  ${change_performed}  ${FALSE}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='Radio Module Settings']
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id}']

    ${table_columns}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//thead/tr/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//thead/tr/th[${column}]

        Run Keyword If  '${column_value}' == 'HDLC communication'  Run Keywords
        ...  Get and Set ALD HDLC communication before MHA commissioning  hdlc_communication_column=${column}  ald_antenna_port=${ald_antenna_port}
        ...  parameter_value=false
        ...  AND  Continue For Loop

        Run Keyword If  '${column_value}' == 'DC voltage level'
        ...  Get and Set ALD DC Voltage Level before MHA commissioning  dc_voltage_level_column=${column}  ald_antenna_port=${ald_antenna_port}
        ...  parameter_value=OFF

    END

    Return From Keyword If  not ${change_performed}

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Activate Plan without VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Activate DC power source
    [Arguments]  ${alias}  ${vdu_alias}  ${ald_antenna_port}  ${dc_voltage_value}  ${timeout}=30

    Log  *** Activate DC power source on ${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id} ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='Radio Module Settings']
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='${RM_pn} RMOD-${RM_id}/RMOD_R-${RM_id}']

    ${table_columns}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//thead/tr/th

    FOR  ${column}  IN RANGE  1  ${table_columns}+1

        ${column_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//thead/tr/th[${column}]

        Run Keyword If  '${column_value}' == 'DC voltage level'  Run Keywords
        ...  Set ALD DC voltage level  dc_voltage_level_column=${column}  ald_antenna_port=${ald_antenna_port}  parameter_value=${dc_voltage_value}
        ...  AND  Exit For Loop
    END

    Log  HDLC communication was succesfully activated!  console=True

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Activate Plan without VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Set ALD DC voltage level
    [Arguments]  ${dc_voltage_level_column}  ${ald_antenna_port}  ${parameter_value}  ${timeout}=30

    ${table_rows}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//tbody/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        ${antenna_port}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${antenna_port}' != '${ald_antenna_port}'

        ${parameter_name}=  Set Variable  DC voltage level

        Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${dc_voltage_level_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //li[@aria-label='${parameter_value}']
        ${updated_parameter_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${dc_voltage_level_column}]

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

        Exit For Loop

    END

    Sleep  1s  reason=Waiting time to control execution speed

Get and Set ALD HDLC communication before MHA commissioning
    [Arguments]    ${hdlc_communication_column}  ${ald_antenna_port}  ${parameter_value}

    Log  Get and Set HDLC communication before MHA commissioning  console=True

    ${table_rows}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//tbody/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        ${antenna_port}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${antenna_port}' != '${ald_antenna_port}'

        ${parameter_name}=  Set Variable  HDLC communication

        Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

        ${current_value}=  Get Text  xpath=//p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${hdlc_communication_column}]

        Run Keyword If  "${current_value}"=="${parameter_value}"  Run Keywords
        ...  Log  HDLC communication already set to ${parameter_value} for antenna port ${ald_antenna_port}  console=True
        ...  AND  Continue For Loop

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${hdlc_communication_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //li[@aria-label='${parameter_value}']
        ${updated_parameter_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${hdlc_communication_column}]

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

        Set Test Variable  ${change_performed}  ${TRUE}

    END

Get and Set ALD DC Voltage Level before MHA commissioning
    [Arguments]    ${dc_voltage_level_column}  ${ald_antenna_port}  ${parameter_value}

    Log  Get and Set ALD DC Voltage Level before MHA commissioning  console=True

    ${table_rows}=  SeleniumLibrary.Get Element Count  //p-table[@class='p-element ot-scroll-table']//tbody/tr

    FOR  ${table_row}  IN RANGE   1  ${table_rows}+1

        ${antenna_port}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${antenna_port}' != '${ald_antenna_port}'

        ${parameter_name}=  Set Variable  DC voltage level

        Log  *** ${parameter_name} will be set to: ${parameter_value} ***  console=True

        ${current_value}=  Get Text  xpath=//p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${dc_voltage_level_column}]

        Run Keyword If  "${current_value}"=="${parameter_value}"  Run Keywords
        ...  Log  DC Voltage Level already set to ${parameter_value} for antenna port ${ald_antenna_port}  console=True
        ...  AND  Continue For Loop

        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  xpath=//p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${dc_voltage_level_column}]
        Wait Until Keyword Succeeds  ${timeout}  3
        ...  Click Element  //li[@aria-label='${parameter_value}']
        ${updated_parameter_value}=  Get Text  //p-table[@class='p-element ot-scroll-table']//tbody/tr[${table_row}]/td[${dc_voltage_level_column}]

        Check if parameter was set properly  parameter_name=${parameter_name}  parameter_value=${parameter_value}
        ...  updated_parameter_value=${updated_parameter_value}

        Set Test Variable  ${change_performed}  ${TRUE}

    END

Perform Passive Device commissioning via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Add New Passive Device  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Add New Passive Device
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li[@aria-label='Antenna Line Devices MHA']

    Configure Passive Device

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Perform Activate Plan with VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Perform RET ALD commissioning via Commissioning Wizard
    [Arguments]  ${alias}  ${vdu_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}
    Add New RET ALD device  alias=${alias}  vdu_alias=${vdu_alias}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Add New RET ALD device
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    Switch Browser  ${alias}_${vdu_alias}

    Log  *** Adding new RET ALD device: ***  console=true
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  //*[@id="nolinked-alds"]/div/div[2]/button/span[1]
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//span[@class="p-menuitem-text ng-star-inserted" and text()="RET"]
    Log  RET ALD succesfully created!  console=true

    Sleep  1s  reason=Waiting time to control execution speed

    Set MHA/RET Control Protocol

    Set MHA/RET Controlling Port  ant_port=RET

    Set RET DC Power Sources

    Set MHA/RET Product code  parameter_value=${RET_PRODUCT_CODE}

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    Configure RET RETU-1

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Activate Plan without VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

Set RET DC Power Sources

    ${parameter_name}=  Set Variable  DC power sources
    ${parameter_value}=  Set Variable  RMOD-${RM_id} (${RM_pn})/RET

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${parameter_name}' != '${row_parameter_name}'

        Edit single-select parameter name and planned value table  table_row=${table_row}  parameter_name=${parameter_name}
        ...  parameter_value=${parameter_value}

        Exit For Loop

    END

Configure RET RETU-1
    [Arguments]  ${timeout}=30

    Log  *** Start configuring RETU-1 ***  console=True
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li/div/button/span
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='RETU-1']

    ${parameter_name}=  Set Variable  List of Associated antenna lines
    ${parameter_value}=  Set Variable  RMOD-${RM_id} (${RM_pn})/ANT1

    ${table_rows}=  SeleniumLibrary.Get Element Count  (//table[@class='ng-star-inserted'])[1]//tbody/tr

    FOR  ${table_row}  IN RANGE  1  ${table_rows}+1

        ${row_parameter_name}=  Get Text  (//table[@class='ng-star-inserted'])[1]//tbody/tr[${table_row}]/td[1]

        Continue For Loop If  '${row_parameter_name}' != '#1'

        Edit single-select parameter name and planned value table  table_row=${table_row}  parameter_name=${parameter_name}
        ...  parameter_value=${parameter_value}

        Exit For Loop

    END

    Log  RETU-1 was succesfully configured!  console=True

Check cloud BTS states and alarms after activate DC power source on RMOD

    Log  *** Check ${ald_vdu_alias} states and alarms after activate DC power source on RMOD ***  console=True

    Log  Check ${ald_vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  5  ${ald_vdu_alias}

    Log  Check ${ald_vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${ald_vdu_alias}

    Log  Check ${ald_vdu_alias} alarms:  console=True
    Log  ${ald_vdu_alias} "DC voltage administratively disabled (4141)" alarm, expected number: 0  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${ald_vdu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${ald_vdu_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${ald_vdu_alias.upper()}_CRITICAL_ALARMS}
    Log  ${ald_vdu_alias} "DC voltage administratively disabled (4141)" alarm, found number: 0, as expected!  console=True
    Log  ${ald_vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check cloud BTS states and alarms
    [Arguments]  ${vdu_alias}

    Log  Check ${vdu_alias} status:  console=True
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${vdu_alias}

    Log  Check ${vdu_alias} alarms:  console=True
    Get and Check Alarms CBTS VDU  vdu_alias=${vdu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${vdu_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${vdu_alias.upper()}_CRITICAL_ALARMS}
    Log  ${vdu_alias} site - expected, ignored and critical alarms checked  console=True

Check CBTS VDU cell state
    [Arguments]  ${VDU_CELL_ids}  ${CELL_operational_state_check}  ${CELL_availability_status_check}  ${CELL_administrative_state_check}
    ...  ${CELL_blocking_state_check}  ${CELL_state}  ${timeout}  ${vdu_alias}

    FOR  ${item}  IN  @{VDU_CELL_ids}

        Wait Until Keyword Succeeds  ${timeout}s  1s  VDU Check Cell Expected Status  cell_id=${item}
        ...  operational_state=${CELL_operational_state_check}  availability_status=${CELL_availability_status_check}
        ...  administrative_state==${CELL_administrative_state_check}  blocking_state=${CELL_blocking_state_check}  vdu_connection=${vdu_alias}

    END
    Log  ${vdu_alias} cells status:\n - ${CELL_state}  console=True

Check MHA/RET widget
    [Arguments]  ${ald_type}  ${timeout}=30

    Log  *** Check that ${ald_type} widget is present in WebEM Site View ***  console=True

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  ${VDU_SITE_VIEW}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=(//span[normalize-space()='${ald_type}'])[1]

    Wait Until Element Is Visible  (//span[normalize-space()='Reset ALD (SW)'])[1]  30s

    Log  ${ald_type} widget is present in WebEM Site View!  console=True

Check RET widget
    [Arguments]  ${alias}  ${vdu_alias}

    Check CBTS VDU RETs state  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_VDU_ALD_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${ald_VDU_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    Check MHA/RET widget  ald_type=RET

    Capture BTS Page Screenshot  screenshot_name=run_${INDEX}_RET_fully_commissioned

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Check MHA widget
    [Arguments]  ${alias}  ${vdu_alias}

    Check CBTS VDU MHAs state  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_VDU_ALD_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${ald_VDU_alias}

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    Check MHA/RET widget  ald_type=MHA

    Capture BTS Page Screenshot  screenshot_name=run_${INDEX}_MHA_fully_commissioned

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Check that MHA parameters are not empty

    Log  *** Check that MHA parameters are not empty ***  console=True

    Sleep  60s  reason=Waiting time to make sure ALDs are on line
    ${mha_ald_info}=  VDU Get MHA Information  vdu_connection=${ald_VDU_alias}

    FOR  ${mha_info}  IN  @{mha_ald_info}

        ${ald_dict}=  Get From Dictionary  ${mha_info}  ald

        ${aisg_protocol_version}=  Get From Dictionary  ${ald_dict}  aisg_protocol_version
        ${availability_status}=  Get From Dictionary  ${ald_dict}  availability_status
        ${control_ports}=  Get From Dictionary  ${ald_dict}  control_ports
        ${control_protocol}=  Get From Dictionary  ${ald_dict}  control_protocol
        ${dist_names}=  Get From Dictionary  ${ald_dict}  dist_names
        ${id}=  Get From Dictionary  ${ald_dict}  id
        ${mha_type}=  Get From Dictionary  ${ald_dict}  mha_type
        ${operational_state}=  Get From Dictionary  ${ald_dict}  operational_state
        ${product_code}=  Get From Dictionary  ${ald_dict}  product_code
        ${release_id3_gpp}=  Get From Dictionary  ${ald_dict}  release_id3_gpp
        ${serial_number}=  Get From Dictionary  ${ald_dict}  serial_number
        ${software_version}=  Get From Dictionary  ${ald_dict}  software_version
        ${vendor_code}=  Get From Dictionary  ${ald_dict}  vendor_code

        Log  aisg_protocol_version: ${aisg_protocol_version}  console=True
        Log  availability_status: ${availability_status}  console=True
        Log  control_ports: ${control_ports}  console=True
        Log  control_protocol: ${control_protocol}  console=True
        Log  dist_names: ${dist_names}  console=True
        Log  id: ${id}  console=True
        Log  mha_type: ${mha_type}  console=True
        Log  operational_state: ${operational_state}  console=True
        Log  product_code: ${product_code}  console=True
        Log  release_id3_gpp: ${release_id3_gpp}  console=True
        Log  serial_number: ${serial_number}  console=True
        Log  software_version: ${software_version}  console=True
        Log  vendor_code: ${vendor_code}  console=True

    END

Check that RET parameters are not empty

    Log  *** Check that RET parameters are not empty ***  console=True

    ${ret_ald_info}=  VDU Get RET Information  vdu_connection=${ald_vdu_alias}

    FOR  ${ret_info}  IN  @{ret_ald_info}

        ${ald_dict}=  Get From Dictionary  ${ret_info}  ald

        ${aisg_protocol_version}=  Get From Dictionary  ${ald_dict}  aisg_protocol_version
        ${availability_status}=  Get From Dictionary  ${ald_dict}  availability_status
        ${control_ports}=  Get From Dictionary  ${ald_dict}  control_ports
        ${control_protocol}=  Get From Dictionary  ${ald_dict}  control_protocol
        ${dc_power_sources}=  Get From Dictionary  ${ald_dict}  dc_power_sources
        ${dist_names}=  Get From Dictionary  ${ald_dict}  dist_names
        ${id}=  Get From Dictionary  ${ald_dict}  id
        ${operational_state}=  Get From Dictionary  ${ald_dict}  operational_state
        ${product_code}=  Get From Dictionary  ${ald_dict}  product_code
        ${release_id3_gpp}=  Get From Dictionary  ${ald_dict}  release_id3_gpp
        ${serial_number}=  Get From Dictionary  ${ald_dict}  serial_number
        ${software_version}=  Get From Dictionary  ${ald_dict}  software_version
        ${vendor_code}=  Get From Dictionary  ${ald_dict}  vendor_code

        Log  aisg_protocol_version: ${aisg_protocol_version}  console=True
        Log  availability_status: ${availability_status}  console=True
        Log  control_ports: ${control_ports}  console=True
        Log  control_protocol: ${control_protocol}  console=True
        Log  dc_power_sources: ${dc_power_sources}  console=True
        Log  dist_names: ${dist_names}  console=True
        Log  id: ${id}  console=True
        Log  operational_state: ${operational_state}  console=True
        Log  product_code: ${product_code}  console=True
        Log  release_id3_gpp: ${release_id3_gpp}  console=True
        Log  serial_number: ${serial_number}  console=True
        Log  software_version: ${software_version}  console=True
        Log  vendor_code: ${vendor_code}  console=True

    END

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
