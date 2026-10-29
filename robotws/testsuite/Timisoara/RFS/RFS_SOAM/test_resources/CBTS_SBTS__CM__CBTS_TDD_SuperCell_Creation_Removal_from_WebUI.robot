*** Settings ***
Documentation    TC__CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
Variables    tc_variables/cbts_sbts__cm__cbts_tdd_supercell_creation_removal_from_webui_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}    3     # Number of cycles to perform Creation and Removal of TDD Supercell commissioning,
                           # default value 3.
${NR_CELL_ID}              # Cell ID of CBTS NR TDD Cell which will be converted into Supercell
${BTS_MAX_WAIT_TIME}  900  # Maximum time to wait for BTS OnAir, default value 900.

*** Keywords ***
TC__CBTS_SBTS__CM__CBTS_TDD_SuperCell_Creation_Removal_from_WebUI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29767
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CBTS_SBTS test case for Creation and Removal of Supercell via Commissioning Wizard from WebUI
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial all BTS states and alarms
    ...  - check test argument values validity
    ...  - perform Supercell creation on VDU via Commissioning Wizard, checking states and alarms
    ...  - delete previously created Supercell on VDU via Commissioning Wizard, checking states and alarms
    ...  - check final all BTS states and alarms
    ...  Pass criteria: Creation And Removal of Supercell on VDU via Commissioning Wizard works as expected, states and alarms are as expected
    ...  ***************************
    ...  History of changes
    ...  ***************************
    ...  - 09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29767 - [CB012501-CR-H]CB012501_RFS_vRAN_Creation_Removal of TDD SuperCell
    ...  from vDU configuration using dedicated page of Commissionig Wizard - FB2520
    ...  - 12.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30111 - Increase timeout for check vDU cell state

    Set Tags    CA-CM    OWNER-cosmin.florea@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-CRT    SW-SBTS26R1

    TC Preconditions
    Step 1: Check initial all BTS states
    Step 2: Check initial all BTS alarms
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 3: Perform Supercell Creation Removal via Commissioning Wizard
        Step 4: Check final all BTS states
        Step 5: Check final all BTS alarms
        Step 6: Check final number and state of Cells and RMs
    END
    Step 7: Collect snapshot on demand on VDU

    [Teardown]  Particular Teardown

TC Preconditions
    Log  Check test argument values validity  console=True
    Should Not Be Empty  ${NR_CELL_ID}
    Get and check cell info precondition

Get and check cell info precondition

    Set Test Variable  ${cell_ID_found}  ${FALSE}
    Set Test Variable  ${supercell_vdu_alias}  ${NONE}
    Set Test Variable  ${supercell_alias}  ${NONE}

    ${BTS_alias_RMOD_sn_dict}  ${RMOD_sn_BTS_alias_dict}  ${shared_RMOD_sn_list}  ${dedicated_RMOD_sn_list}=  Get all BTS RMOD sharing info
    ${BTS_all_alias_list}=  Get Dictionary Keys  ${BTS_alias_RMOD_sn_dict}
    Set Test Variable  ${BTS_all_alias_list}

    FOR  ${alias}  IN  @{alias_list}
        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]' != 'CBTS'  Continue For Loop
        Check desired NR cell ID presence on vDU  ${alias}
        Exit For Loop If  ${cell_ID_found}
    END

    Run Keyword If  not ${cell_ID_found}  Fail  Desired NR Cell ID ${NR_CELL_ID} not found!

    Set Test Variable  ${CBTS_VDU_state_onair}  Operational state=OnAir
    Set Test Variable  ${CBTS_VDU_RMOD_state_enabled}  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked
    Set Test Variable  ${CBTS_VDU_CELL_state_enabled}
    ...  Operational state=Enabled, Availability status=Online, Administrative state=Unlocked, Blocking state=Unblocked

    ${VDU_RMOD_sn_id_dict}  ${VDU_RMOD_id_sn_dict}  ${VDU_RMOD_sn_pn_dict}  ${VDU_RMOD_sn_interface_dict}=  VDU Get RMOD sn id pn interface info
    ...  vdu_connection=${supercell_vdu_alias}
    ${VDU_CELL_id_config_dn_dict}=  VDU Get Cells id config info  vdu_connection=${supercell_vdu_alias}

    ${VDU_RMOD_ids_list}=  Get Dictionary Keys  ${VDU_RMOD_id_sn_dict}
    ${VDU_NR_CELL_ids_list}=  Get Dictionary Keys  ${VDU_CELL_id_config_dn_dict}

    Set Test Variable  ${VDU_RMOD_ids_list}
    Set Test Variable  ${VDU_NR_CELL_ids_list}

Check desired NR cell ID presence on vDU
    [Arguments]  ${alias}

    ${vdu_list}=  Set Variable  ${${alias.upper()}}[${alias.upper()}_VDU]

    FOR  ${index}  ${vdu_info}  IN ENUMERATE  @{vdu_list}

        ${vdu_alias}=  Set Variable  ${alias} VDU${index+1}
        ${VDU_CELL_info}=  vdu.Get Vdu Cells Status  vdu_connection=${vdu_alias}
        ${desired_NR_cell_found}  ${cell_scf_dn}=  Check vdu cells list contains desired cell  ${VDU_CELL_info}  ${vdu_alias}
        Run Keyword If  ${desired_NR_cell_found}  Run Keywords
        ...  Set Test Variable  ${supercell_vdu_alias}  ${vdu_alias}
        ...  AND  Set Test Variable  ${supercell_alias}  ${alias}
        ...  AND  Set Test Variable  ${cell_SCF_dn}
        ...  AND  Set Test Variable  ${cell_ID_found}  ${desired_NR_cell_found}
    END

Check vdu cells list contains desired cell
    [Arguments]  ${VDU_CELL_info}  ${vdu_alias}

    ${desired_NR_cell_found}=  Set Variable  ${FALSE}
    ${VDU_CELL_info_len}=  Get Length  ${VDU_CELL_info}
    FOR  ${index}  IN RANGE  0  ${VDU_CELL_info_len}
        ${current_cell_id}=  Get From Dictionary   ${VDU_CELL_info[${index}]}  id
        ${technology}=  Get From Dictionary   ${VDU_CELL_info[${index}]}  technology
        ${dist_names}=  Get From Dictionary   ${VDU_CELL_info[${index}]}  dist_names
        ${cell_scf_dn}=  Get From Dictionary   ${dist_names}  config

        Continue For Loop If  "${current_cell_id}"!="${NR_CELL_ID}"
        ${desired_NR_cell_found}=  Set Variable  ${TRUE}
        Run Keyword If  "${technology}"!="TDD"
        ...  Fail  TC Preconditions failed! Provided NR Cell ID: ${NR_CELL_ID} found but it is not a TDD cell!
        ${actSuperCell_value}=  Check actSuperCell value on NR Cell  ${vdu_alias}  ${cell_scf_dn}
        Run Keyword If  "${actSuperCell_value.lower()}"!="false"
        ...  Fail  TC Preconditions failed! Provided NR Cell ID: ${NR_CELL_ID} found but actSuperCell value=${actSuperCell_value}, not False!
        Exit For Loop If  ${desired_NR_cell_found}
    END

    [Return]  ${desired_NR_cell_found}  ${cell_scf_dn}

Check actSuperCell value on NR Cell
    [Arguments]  ${alias}  ${cell_scf_dn}

    ${BTS_SCF_path_file_info}=  Set Variable  ${${alias.lower()}_scf_initial}
    ${actSuperCel_info_dict}  ${EMPTY}=  Get Object Attributes Values From Scf  scf_path=${BTS_SCF_path_file_info}
    ...  dist_name=${cell_scf_dn}  p_name=actSuperCell

    ${actSuperCel_count}=  Get Length  ${actSuperCel_info_dict}
    ${actSuperCell_value}=  Run Keyword If  ${actSuperCel_count} > 0
    ...  Get From Dictionary  ${actSuperCel_info_dict}  actSuperCell
    ...  ELSE  Set Variable  NA

    [Return]  ${actSuperCell_value}

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

Step ${index}: Perform Supercell Creation Removal via Commissioning Wizard

    Log  Step ${index}: Perform Supercell Creation Removal via Commissioning Wizard  console=True

    ${supercell_VDU_alias_list}=  Split String  ${supercell_VDU_alias}  separator=
    ${alias}=  Get From List  ${supercell_VDU_alias_list}  0
    ${vdu_alias}=  Get From List  ${supercell_VDU_alias_list}  1

    VDU WebEM Commissioning Wizard Perform Supercell Creation  ${alias}  ${vdu_alias}
    Check cloud BTS states and alarms after supercell commissioning
    VDU WebEM Site View Check Cell Details  alias=${alias}  vdu_alias=${vdu_alias}  supercell_activated=True
    VDU WebEM Commissioning Wizard Perform Supercell Removal  ${alias}  ${vdu_alias}
    Check cloud BTS states and alarms after supercell commissioning
    VDU WebEM Site View Check Cell Details  alias=${alias}  vdu_alias=${vdu_alias}  supercell_activated=False

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

        Run Keyword If  '${${alias.upper()}}[${alias.upper()}_TECH]'=='CBTS' and '${alias}' in '${supercell_VDU_alias}'
        ...  Collect VDU Snapshot  folder_path=${snapshot_and_alarms_dir}  alias=${alias}

    END

VDU WebEM Commissioning Wizard Perform Supercell Creation
    [Arguments]  ${alias}  ${vdu_alias}

    Log  Start Performing Supercell Creation from Commissioning Wizard - NR cell ${NR_CELL_ID} on BTS ${alias}  console=True

    Set Test Variable  ${VDU_SUPERCELL_CONFIG}  False
    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}
    Set Test Variable  ${tbody_class}  //tbody[@class='p-element p-treetable-tbody']
    Set Test Variable  ${vdu_cw_nr_cell_and_cell_mapping}  //li[@aria-label='NR Cell and Cell Mapping']
    Set Test Variable  ${vdu_cw_add_channel_group_btn}  //p-button/button/span[text()="Add Channel Group"]
    Set Test Variable  ${vdu_cw_channel_group_1}  //p-accordiontab[.//span[normalize-space(.)="CHANNELGROUP-1"]]
    Set Test Variable  ${vdu_cw_channel_group_2}  //p-accordiontab[.//span[normalize-space(.)="CHANNELGROUP-2"]]

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Commissioning Wizard Set Activate Super Cell  desired_value=true

    VDU WebEM Commissioning Wizard Add Second Channel Group for Cell

    VDU WebEM Perform Save Commissioning Wizard Changes  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  1s  reason=Waiting time to control execution speed

    Set Test Variable  ${VDU_SUPERCELL_CONFIG}  True

    VDU WebEM Perform Activate Plan with VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  20s

    Log  Supercell Activation commissioning finished. Waiting for BTS to be reachable.  console=True

    Wait For Target To Be Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

VDU WebEM Commissioning Wizard Perform Supercell Removal
    [Arguments]  ${alias}  ${vdu_alias}

    Log  Start Performing Supercell Removal from Commissioning Wizard - NR cell ${NR_CELL_ID} on BTS ${alias}  console=True

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}
    Set Test Variable  ${tbody_class}  //tbody[@class='p-element p-treetable-tbody']
    Set Test Variable  ${vdu_cw_nr_cell_and_cell_mapping}  //li[@aria-label='NR Cell and Cell Mapping']
    Set Test Variable  ${vdu_cw_add_channel_group_btn}  //p-button/button/span[text()="Add Channel Group"]
    Set Test Variable  ${vdu_cw_channel_group_1}  //p-accordiontab[.//span[normalize-space(.)="CHANNELGROUP-1"]]
    Set Test Variable  ${vdu_cw_channel_group_2}  //p-accordiontab[.//span[normalize-space(.)="CHANNELGROUP-2"]]

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Open Commissioning Wizard Menu  alias=${alias}  vdu_alias=${vdu_alias}

    VDU WebEM Commissioning Wizard Set Activate Super Cell  desired_value=false

    VDU WebEM Commissioning Wizard Delete Second Channel Group for Cell

    VDU WebEM Perform Save Commissioning Wizard Changes  ${alias}  ${vdu_alias}

    VDU WebEM Parameter Editor Set numberOfTransmittedSsBlocks to 1 beam  ${alias}  ${vdu_alias}

    VDU WebEM Perform Validate Plan  alias=${alias}  vdu_alias=${vdu_alias}

    Set Test Variable  ${VDU_SUPERCELL_CONFIG}  False

    VDU WebEM Perform Activate Plan with VDU reset  alias=${alias}  vdu_alias=${vdu_alias}

    Sleep  20s

    Log  Supercell Removal commissioning finished. Waiting for BTS to be reachable  console=True

    Wait For Target To Be Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

VDU WebEM Commissioning Wizard Set Activate Super Cell
    [Arguments]  ${desired_value}  ${timeout}=30

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_cw_nr_cell_and_cell_mapping}
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//div[@aria-label='TDD NRCELL-${NR_CELL_ID}/${NR_CELL_ID}']

    ${table_rows}=  SeleniumLibrary.Get Element Count  (${tbody_class})[1]/tr

    ${activate_supercell_row_found}=  Set Variable  ${None}

    FOR  ${tbody_row}  IN RANGE  1  ${table_rows}+1
        ${column_value}=  Get Text   (${tbody_class})[1]/tr[${tbody_row}]/td[1]/div/div/div/div/span
        ${activate_supercell_row_found}=  Set Variable If  '${column_value}'=='Activate super cell'  ${tbody_row}  ${activate_supercell_row_found}
        Exit For Loop If  ${activate_supercell_row_found}
    END

    Run Keyword If  '${activate_supercell_row_found}'=='${None}'
    ...  Fail  Commissioning Wizard Field Activate Super Cell Not Found for desired cell ${NR_CELL_ID}!

        Set Test Variable  ${vdu_cw_activate_supercell_dropdown_btn}
    ...  (${tbody_class})[1]/tr[${activate_supercell_row_found}]/td[2]/cem-parameter-input/cem-dropdown-input/div/p-dropdown/div/span[1]

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_cw_activate_supercell_dropdown_btn}

    Wait Until Element Is Visible    xpath=//p-dropdownitem/li[normalize-space(.)="${desired_value}"]  5s

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element    xpath=//p-dropdownitem/li[normalize-space(.)="${desired_value}"]

VDU WebEM Commissioning Wizard Add Second Channel Group for Cell
    [Arguments]  ${timeout}=30

    Scroll Element Into View  xpath=${vdu_cw_add_channel_group_btn}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_cw_add_channel_group_btn}

    Wait Until Element Is Visible  xpath= ${vdu_cw_channel_group_2}  5s

    ${text}=  Get Text  (//tbody[@class='p-element p-datatable-tbody ng-star-inserted'])[2]/tr/td[1]

    ${CHANNELGROUP1_tbody}=  Set Variable
    ...  xpath= ${vdu_cw_channel_group_1}//blocks-non-mimo-cell-mapping-settings/p-table/div/div/table/tbody
    ${CHANNELGROUP2_tbody}=  Set Variable
    ...  xpath= ${vdu_cw_channel_group_2}//blocks-non-mimo-cell-mapping-settings/p-table/div/div/table/tbody

    ${CHANNELGROUP1_mapping_dict}=  Create Dictionary
    ${table_rows}=  SeleniumLibrary.Get Element Count  ${CHANNELGROUP1_tbody}/tr

    FOR  ${tbody_row}  IN RANGE  1  ${table_rows}+1
        ${RMOD_name}=  Get Text   ${CHANNELGROUP1_tbody}/tr[${tbody_row}]/td[1]
        ${antennas}=  SeleniumLibrary.Get Element Count  ${CHANNELGROUP1_tbody}/tr[${tbody_row}]/td
        ${antenna_mapping_list}=  Create List
        FOR  ${antenna}  IN RANGE  2  ${antennas}+1
            ${antenna_settings}=  Get Text  ${CHANNELGROUP1_tbody}/tr[${tbody_row}]/td[${antenna}]
            Append To List  ${antenna_mapping_list}  ${antenna_settings}
        END
        Set To Dictionary  ${CHANNELGROUP1_mapping_dict}  ${RMOD_name}=${antenna_mapping_list}
    END

    ${table_rows}=  SeleniumLibrary.Get Element Count  ${CHANNELGROUP2_tbody}/tr

    FOR  ${tbody_row}  IN RANGE  1  ${table_rows}+1
        ${RMOD_name}=  Get Text   ${CHANNELGROUP2_tbody}/tr[${tbody_row}]/td[1]
        ${antenna_list_CHANNELGROUP1}=  Get From Dictionary  ${CHANNELGROUP1_mapping_dict}  ${RMOD_name}
        ${antenna_list_CHANNELGROUP1_len}=  Get Length  ${antenna_list_CHANNELGROUP1}
        FOR  ${index}  IN RANGE  0  ${antenna_list_CHANNELGROUP1_len}
            ${CHANNELGROUP1_antena_setting}=  Get From List  ${antenna_list_CHANNELGROUP1}  ${index}
            Continue For Loop If  '${CHANNELGROUP1_antena_setting}'=='TXRX'
            ${value_to_change}=  Set Variable If  '${CHANNELGROUP1_antena_setting}'=='TX'  RX
            ...  '${CHANNELGROUP1_antena_setting}'=='RX'  TX
            ...  TXRX
            ${ant_number}=  Evaluate  ${index}+2
            ${ant_number}=  Convert To Integer  ${ant_number}
            Execute JavaScript  document.querySelectorAll("div.p-datatable-wrapper")[1].scrollLeft = 0
            Execute JavaScript    var wrapper = document.querySelectorAll("div.p-datatable-wrapper")[1];
            ...    var step = wrapper.scrollWidth / ${antenna_list_CHANNELGROUP1_len};
            ...    wrapper.scrollLeft = step * ${index}
            Wait Until Keyword Succeeds  ${timeout}  3
            ...  Click Element  ${CHANNELGROUP2_tbody}/tr[${tbody_row}]/td[${ant_number}]/p-dropdown/div//span
            Wait Until Element Is Visible  xpath=//li/span[normalize-space(.)="${value_to_change}"]
            Wait Until Keyword Succeeds  ${timeout}  3
            ...  Click Element  xpath=//li/span[normalize-space(.)="${value_to_change}"]
        END
    END

VDU WebEM Commissioning Wizard Delete Second Channel Group for Cell
    [Arguments]  ${timeout}=30

    ${CHANNELGROUP2_delete_btn}=  Set Variable
    ...  ${vdu_cw_channel_group_2}//div/div[1]/a/div/p-button

    Wait Until Element Is Visible  ${CHANNELGROUP2_delete_btn}  5s

    Scroll Element Into View  ${vdu_cw_channel_group_2}//div/div[1]/a/div/p-button

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element    xpath=${CHANNELGROUP2_delete_btn}

VDU WebEM Parameter Editor Set numberOfTransmittedSsBlocks to 1 beam
    [Arguments]  ${alias}  ${vdu_alias}  ${timeout}=30

    ${bts_alias}=  Set Variable  ${alias} ${vdu_alias}
    Log  Set numberOfTransmittedSsBlocks to 1 beam on BTS ${bts_alias}  console=True

    VDU WebEM Open Parameter Editor Menu  ${alias}  ${vdu_alias}

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//input[@placeholder='Search with enter']
    Input Text  xpath=//input[@placeholder='Search with enter']  numberOfTransmittedSsBlocks
    Press Keys  xpath=//input[@placeholder='Search with enter']  RETURN

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//cem-dropdown-input/div/p-dropdown/div/div[2]/span

    Wait Until Element Is Visible  xpath=//li/span[normalize-space(.)="1 beam"]  5s

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=//li/span[normalize-space(.)="1 beam"]

    VDU WebEM Perform Save Parameter Editor Changes  ${alias}  ${vdu_alias}

VDU WebEM Site View Check Cell Details
    [Arguments]  ${alias}  ${vdu_alias}  ${supercell_activated}  ${timeout}=30

    Log  Checking Cell Details from Site View after performing supercell=${supercell_activated}  console=True

    VDU WebEM Setup  alias=${alias}  vdu_alias=${vdu_alias}
    VDU WebEM Open Site View Menu  alias=${alias}  vdu_alias=${vdu_alias}

    ${vdu_sv_cell_title}=  Set Variable  //vdu-site-view-vdu-cell-tile[@data-vducell-id='${NR_CELL_ID}']
    ${vdu_sv_details_btn}=  Set Variable  //webem-details-panel-toggle-button/button
    ${vdu_sv_cell_properties_xpath}=  Set Variable  //ui-webem-details-section[@title='Cell properties']//ui-webem-detail-data-row-with-actions-menu
    ${vdu_sv_cell_states_xpath}=  Set Variable  //ui-webem-details-section[@title='Cell states']/div/div[2]/ui-webem-detail-data-row
    ${vdu_sv_L1_subcell_list_xpath}=  Set Variable  //ui-webem-details-section-text[@title="L1 subcell list"]
    ${vdu_sv_antenna_ports_tx_xpath}=  Set Variable  //ui-webem-details-section[@title='TX channels']
    ${vdu_sv_antenna_ports_rx_xpath}=  Set Variable  //ui-webem-details-section[@title='RX channels']

    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_sv_cell_title}

    Wait Until Element Is Visible  ${vdu_sv_details_btn}  5s
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_sv_details_btn}

    Wait Until Element Is Visible  ${vdu_sv_cell_properties_xpath}  5s
    Wait Until Keyword Succeeds  ${timeout}  3
    ...  Click Element  xpath=${vdu_sv_cell_properties_xpath}
    ${table_rows}=  SeleniumLibrary.Get Element Count  ${vdu_sv_cell_properties_xpath}

    Log  =========== Cell Properties Read From Site View Details:  console=True

    FOR  ${row}  IN RANGE  1  ${table_rows}+1
        ${column_1_text}=  Get Text   (${vdu_sv_cell_properties_xpath})[${row}]/div/div[1]/span
        ${column_2_text}=  Get Text   (${vdu_sv_cell_properties_xpath})[${row}]/div/div[2]/span
        Log  --- ${column_1_text} ${column_2_text}  console=True
        Run Keyword If  '${column_1_text}'=='Activate super cell:' and '${column_2_text}'!='${supercell_activated}'
        ...  Fail  Failed at element checking Cell Properties: ${column_1_text} ${column_2_text}!
        Run Keyword If  '${supercell_activated}'=='True' and '${column_1_text}'=='Number of subcells for super cell:' and '${column_2_text}'=='-'
        ...  Fail  Failed at element checking Cell Properties: ${column_1_text} ${column_2_text}!
    END

    Log  =========== L1 subcell list From Site View Details:  console=True

    ${L1_subcell_list_text}=  Get Text   ${vdu_sv_L1_subcell_list_xpath}/div/div[1]
    ${table_rows}=  SeleniumLibrary.Get Element Count  ${vdu_sv_L1_subcell_list_xpath}/div/div[2]/div

    Run Keyword If   ${table_rows}<2 and '${supercell_activated}'==True
    ...  Fail  Subcells list error: ${vdu_sv_L1_subcell_list_xpath} ${table_rows}!

    FOR  ${row}  IN RANGE  1  ${table_rows}+1
        ${L1_subcell_list_text}=  Get Text   ${vdu_sv_L1_subcell_list_xpath}/div/div[2]/div[${row}]
        Log  --- ${L1_subcell_list_text}  console=True
    END

    Log  =========== Antenna ports from Site View Details:  console=True

    ${table_rows}=  SeleniumLibrary.Get Element Count  ${vdu_sv_antenna_ports_tx_xpath}
    ${Tx_channels_text1}=  Get Text   ${vdu_sv_antenna_ports_tx_xpath}/div/div[1]
    ${Tx_channels_text2}=  Get Text   ${vdu_sv_antenna_ports_tx_xpath}/div/div[2]/ul/li
    Run Keyword If  '${Tx_channels_text2}'=='-'
    ...  Fail  Antenna ports listing error: ${Tx_channels_text1} ${Tx_channels_text2}!
    Log  --- ${Tx_channels_text1} ${Tx_channels_text2}  console=True

    ${table_rows}=  SeleniumLibrary.Get Element Count  ${vdu_sv_antenna_ports_rx_xpath}
    ${Rx_channels_text1}=  Get Text   ${vdu_sv_antenna_ports_rx_xpath}/div/div[1]
    ${Rx_channels_text2}=  Get Text   ${vdu_sv_antenna_ports_rx_xpath}/div/div[2]/ul/li
    Run Keyword If  '${Rx_channels_text2}'=='-'
    ...  Fail  Antenna ports listing error: ${Rx_channels_text1} ${Rx_channels_text2}!
    Log  --- ${Rx_channels_text1} ${Rx_channels_text2}  console=True

    Log  =========== Cell states from Site View Details:  console=True

    ${expected_states}=  Create Dictionary  Operational state:=Enabled  Availability status:=On line  Administrative state:=Unlocked
    ...  Procedural status:=Configured  Blocking state:=Unblocked  Energy saving state:=AnythingButHyphen  Cell Barred:=AnythingButHyphen

    ${table_rows}=  SeleniumLibrary.Get Element Count  ${vdu_sv_cell_states_xpath}
    FOR   ${row}  IN RANGE  1  ${table_rows}+1
        ${state_text_key}=  Get Text  (${vdu_sv_cell_states_xpath})[${row}]/div/div[1]
        ${state_text_value}=  Get Text  (${vdu_sv_cell_states_xpath})[${row}]/div/div[2]
        ${expected_state}=  Get From Dictionary  ${expected_states}  ${state_text_key}
        Run Keyword If  '${expected_state}'=='AnythingButHyphen' and '${state_text_value}'=='-'
        ...  Fail  Unexpected cell state read from Site View Details: ${state_text_key} ${state_text_value}!
        ...  ELSE IF  '${expected_state}'!='AnythingButHyphen' and '${state_text_value}'!='${expected_state}'
        ...  Fail  Unexpected cell state read from Site View Details: ${state_text_key} ${state_text_value}!
        ...  ELSE  Log  --- ${state_text_key} ${state_text_value}  console=True
    END

    [Teardown]  VDU WebEM Teardown  alias=${alias}  vdu_alias=${vdu_alias}

Check cloud BTS states and alarms after supercell commissioning
    Log  *** Check ${supercell_vdu_alias} states and alarms after supercell commissioning ***  console=True

    Log  Check ${supercell_vdu_alias} status:  console=True
    Check CBTS VDU state  ${CBTS_OnAir_}  ${CBTS_VDU_state_onair}  ${BTS_MAX_WAIT_TIME}  ${supercell_vdu_alias}

    Log  Check ${supercell_vdu_alias} RMODs status:  console=True
    Check CBTS VDU RMOD state  ${VDU_RMOD_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_VDU_RMOD_state_enabled}
    ...  ${BTS_MAX_WAIT_TIME}  ${supercell_vdu_alias}

    Log  Check ${supercell_vdu_alias} cells status:  console=True
    Check CBTS VDU cell state  ${VDU_NR_CELL_ids_list}  ${CBTS_Enabled_}  ${CBTS_Online_}  ${CBTS_Unlocked_}  ${CBTS_Unblocked_}
    ...  ${CBTS_VDU_CELL_state_enabled}  ${BTS_MAX_WAIT_TIME}  ${supercell_vdu_alias}

    Log  Check ${supercell_vdu_alias} alarms:  console=True

    Get and Check Alarms CBTS VDU  vdu_alias=${supercell_vdu_alias}  expected_alarms=@{EMPTY}
    ...  ignored_alarms=${${supercell_vdu_alias.upper()}_IGNORED_ALARMS}  critical_alarms=${${supercell_vdu_alias.upper()}_CRITICAL_ALARMS}

    Log  ${supercell_vdu_alias} site - expected, ignored and critical alarms checked  console=True

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

Restore cloud BTS initial SCF
    FOR  ${bts_alias}  IN  @{BTS_all_alias_list}
        ${is_supercell_vdu_alias}=  Run Keyword And Return Status  Should Be Equal  ${bts_alias}  ${supercell_vdu_alias}
        Continue For Loop If  not ${is_supercell_vdu_alias}
        Log  Restore BTS ${bts_alias} initial SCF configuration  console=True
        VDU Perform Commissioning  scf_file=${${bts_alias.lower()}_scf_initial}  vdu_connection=${bts_alias}
        Wait For Target To Be Not Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300
        Sleep  20s  reason=Waiting time after commissioning action
        Wait For Target To Be Reachable TAF  hostname=${${bts_alias.lower()}_vdu_host}  timeout=300
    END

Particular Teardown

    Run Keyword If  '${VDU_SUPERCELL_CONFIG}' == 'True'
    ...  Restore cloud BTS initial SCF

TC Setup
    ${tech_preset_list}=  Create List  CBTS  SBTS  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}  infomodelSetup=${FALSE}

TC Teardown
    Common Test Teardown
