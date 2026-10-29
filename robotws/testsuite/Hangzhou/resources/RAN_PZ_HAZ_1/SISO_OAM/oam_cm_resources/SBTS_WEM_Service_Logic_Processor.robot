*** Settings ***
Documentation
...    Maintainer: I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
...    Common KWs related to UI operation for SBTS cases.
...  ******************
...  History of changes
...  ******************
...  - 19.05.2023 - Xu Yuyan commit to robotws
Resource          SBTS_WEM_Basic_Operations.robot
Library           OperatingSystem
Library           XML    use_lxml=True

*** Variables ***
${ALL_CARRIER_FREQUENCY}    ${EMPTY}
${CARRIER_FREQUENCY_RANGE}    ${EMPTY}
${WINDOW_INDEX_OF_BACKUP_CONFIG}    ${EMPTY}
${EXPECTANT_RATS_STATE}    ${EMPTY}
# Use in "SBTS WEM Get RATs State Duration" and "Status Of RAT Should Be OK".
# RAT in this dictionary shall be check in "Status Of RAT Should Be OK", otherwise shall be ignored.
${WEB_EM_COMMON_TEXT}    {'rd_enable':'Enable management of for future use parameters'}
${RAT_BIT}        00000000
${GNB_CU_TYPE}    SA

*** Keywords ***
SBTS WEM Setup RAT Data
    ${initialised}    Run Keyword And Return Status    Should Not Be Equal As Strings    ${EXPECTANT_RATS_STATE}    ${EMPTY}
    Return From Keyword If    ${initialised}
    ${dic_bit_rat_state}    Create Dictionary    0=On air    1=Not commissioned    2=Commissioned    3=Integrated to RAN    4=Configured
    ${dic_bit_cells_state}    Create Dictionary
    ...    0=All cells enabled    1=No cells available    2=All cells failed    3=Cells partially disabled    4=All cells disabled
    ${rat_list}    Create List    NR    LTE    WCDMA    GSM
    ${EXPECTANT_RATS_STATE}    Create Dictionary
    FOR    ${i}    IN RANGE    0    4
        ${not_need_add}    Run Keyword And Return Status    Dictionary Should Not Contain Key    ${dic_bit_rat_state}    ${RAT_BIT[${i}]}
        Continue For Loop If    ${not_need_add}
        ${dic_tmp}    Create Dictionary    original_rat_state=${dic_bit_rat_state['${RAT_BIT[${i}]}']}
        ...    final_rat_state=${dic_bit_rat_state['${RAT_BIT[${i+4}]}']}    original_cell_state=${dic_bit_cells_state['${RAT_BIT[${i}]}']}
        ...    final_cell_state=${dic_bit_cells_state['${RAT_BIT[${i+4}]}']}
        Set To Dictionary    ${EXPECTANT_RATS_STATE}    ${rat_list[${i}]}    ${dic_tmp}
    END
    LOG    ${EXPECTANT_RATS_STATE}
    Set Test Variable    ${EXPECTANT_RATS_STATE}
    ${GNB_CU_TYPE}    SBTS_WEM_Get_gNbCuType
    Set Test Variable    ${GNB_CU_TYPE}

SBTS WEM Set Detected HW
    [Arguments]    ${setup_value}=true    ${activate}=${True}    ${tree_name}=Current BTS configuration
    SBTS WEM Filt Parameter    validatePlanAgainstDetectedHW
    ${para}    SBTS WEM Get Parameters In PE Table
    ${count}    BuiltIn.Get Length    ${para}
    Should Be Equal As Integers    ${count}    ${1}
    ${para_value}    Set variable    ${para[0]["actual_value"]}
    Return from keyword if    '${para_value}'=='${setup_value}'
    ${object}    Set variable    ${para[0]["object"]}
    SBTS WEM Modify Parameters In PE Table    ${object}    ${para[0]["full_name"]}    ${setup_value}    ${EMPTY}    ${tree_name}
    Return From Keyword If    not ${activate}
    SBTS WEM Validate Plan
    SBTS WEM Activate Plan

SBTS WEM Set Parameters Of One Object
    [Arguments]    ${target_object}    ${parameter_list}    ${tree_name}=Current BTS configuration
    LOG    KW:SBTS WEM Set Parameters Of One Object    console=${True}
    #${parameter} like: {"Activate flexible duplexing gap":["true","false"]}
    ${param_backup_tmp_list}    Create List
    FOR    ${parameter}    IN    @{parameter_list}
        ${param_item}    Get Dictionary Items    ${parameter}
        ${param_name}    Set Variable    ${param_item[0]}
        ${param_value}    Set Variable    ${param_item[1]}
        ${count}    Get Length    ${param_value}
        ${full_name}    Fetch From Left    ${param_name}    (!)
        ${list_lable}    Fetch From Right    ${param_name}    (!)
        ${list_lable}    Set Variable If    '${list_lable}'!='${full_name}'    ${list_lable}    ${None}
        ${full_name_list}    Create List    ${param_name}
        ${current_value}    SBTS WEM Get Parameters Of One Object    ${target_object}    ${full_name_list}    ${tree_name}
        Remove Values From List    ${param_value}    ${current_value['${param_name}']}
        ${count}    Get Length    ${param_value}
        Continue For Loop If    '${count}'=='0'
        ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
        ${param_value_to_set}    Set Variable    ${param_value[${index}]}
        ${is_modified}    SBTS WEM Modify Parameters In PE Table    ${target_object}    ${full_name}    ${param_value_to_set}    ${list_lable}
        Continue For Loop If    '${is_modified}'!='${True}'
        ${cur_val_lst}    Create List    ${current_value["${param_name}"]}
        &{current_param_backup}    Create Dictionary    ${full_name}=${cur_val_lst}
        Append To List    ${param_backup_tmp_list}    ${current_param_backup}
    END
    ${param_backup}    Create Dictionary    ${target_object}=${param_backup_tmp_list}
    [Return]    ${param_backup}

SBTS WEM Check SBTS Has Restarted Successful
    LOG    SBTS WEM Check SBTS Has Restarted Successful    console=${True}
    ${ret}    Wait Until Keyword Succeeds    600s    10    SBTS WEM Status Bar Should Be Loading
    LOG    SBTS is offline.Wait for SBTS online.    console=${True}
    Return From Keyword If    '${ret}' != 'True'    #While KW called in tear down, assertion shall not break off KW. Return forwardly to save time.
    Sleep    180s    #Reduce asserting by Selenium2Library to prevent the crash of ChromeDriver
    #Logon again to prevent account locking
    SBTS WEM Close BTS StartUp View
    ${ret}    Set variable    ${False}
    FOR    ${i}    IN RANGE    0    30
        ${ret}    Run Keyword And Return Status    SBTS WEM Status Bar Should Be Loaded Completed
        Exit For Loop If    ${ret}
        Sleep    20s
    END
    Run Keyword If    not ${ret}    Run Keywords    Selenium2Library.Close Browser
    ...    AND    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}    setup_param=${False}
    ${ret}    SBTS WEM Status Bar Should Be Loaded Completed
    Return From Keyword If    not ${ret}    #While KW called in tear down, assertion shall not break off KW. Return forwardly to save time.
    Sleep    60s    #Reduce asserting by Selenium2Library to prevent the crash of ChromeDriver
    LOG    SBTS is online. Wait for RAT setup.    console=${True}
    SBTS WEM Close BTS StartUp View
    Wait Until Keyword Succeeds    30x    30    Status Of RAT Should Be OK    #Time limit is 120 minutes, otherwise webUI shall logout automatic
    LOG    RAT setup end. SBTS restart finished.    console=${True}

SBTS WEM Check RATs Has Locked Successful
    [Arguments]    ${RAT_list}    ${time_out}=${600}    ${retry_interval}=${1}
    [Timeout]    ${time_out}
    LOG    SBTS WEM Check RATs Has Locked Successful    console=${True}
    Return From Keyword If    "${RAT_list.__len__()}"=="${0}"
    SBTS WEM Open RunTime View
    ${retry}    Evaluate    ${time_out}/${retry_interval}
    ${rats_states}    ${is_finished}    SBTS WEM Get RATs State Duration    ${retry}    ${retry_interval}
    Should Be True    ${is_finished}
    FOR    ${rat}    IN    @{RAT_list}
        ${state_list}    Get From Dictionary    ${rats_states}    ${rat}
        List Should Not Contain Value    ${state_list}    Commissioned
        Remove From Dictionary    ${rats_states}    ${rat}
    END
    ${other_rats}    Get Dictionary Keys    ${rats_states}
    #NR RAT service depend on LTE RAT if gNbCuType is NSA
    ${has_LTE}    Get Count    ${RAT_list}    LTE
    Run Keyword If    '${GNB_CU_TYPE}'=='NSA' and '${has_LTE}' == '${1}'    Remove Values From List    ${other_rats}    NR
    FOR    ${rat}    IN    @{other_rats}
        ${state_list}    Get From Dictionary    ${rats_states}    ${rat}
        List Should Not Contain Value    ${state_list}    Commissioned
        List Should Not Contain Value    ${state_list}    Integrated to RAN
        List Should Not Contain Value    ${state_list}    Configured
    END

SBTS WEM Check RATs Has Reseted Successful
    [Arguments]    ${RAT_list}    ${time_out}=${600}    ${retry_interval}=${0.5}    ${cur_window_index}=${EMPTY}    @{exceptive_RATs}
    [Documentation]    Check if the RATs given are reseted successful.
    ...    Fail if the RATs did not reseted successful.
    ...    Fail if service of any RATs not given has been down during the process of checking.
    LOG    SBTS WEM Check RATs Has Reseted Successful    console=${True}
    Return From Keyword If    "${RAT_list.__len__()}"=="${0}"
    ${retry}    Evaluate    ${time_out}/${retry_interval}
    ${rats_states}    ${is_finished}    SBTS WEM Get RATs State Duration    ${retry}    ${retry_interval}    cur_window_index=${cur_window_index}
    Should Be True    ${is_finished}
    FOR    ${rat}    IN    @{RAT_list}
        ${state_list}    Get From Dictionary    ${rats_states}    ${rat}
        List Should Contain Value    ${state_list}    Commissioned
        Remove From Dictionary    ${rats_states}    ${rat}
    END
    #NR RAT service depend on LTE RAT if gNbCuType is NSA
    ${has_LTE}    Get Count    ${RAT_list}    LTE
    Run Keyword If    '${GNB_CU_TYPE}'=='NSA' and '${has_LTE}' == '${1}'    Append To List    ${exceptive_RATs}    NR
    FOR    ${rat}    IN    @{exceptive_RATs}
        Remove From Dictionary    ${rats_states}    ${rat}
    END
    ${other_rats}    Get Dictionary Keys    ${rats_states}
    FOR    ${rat}    IN    @{other_rats}
        ${state_list}    Get From Dictionary    ${rats_states}    ${rat}
        List Should Not Contain Value    ${state_list}    Commissioned
        List Should Not Contain Value    ${state_list}    Integrated to RAN
        List Should Not Contain Value    ${state_list}    Configured
    END

SBTS WEM Get WCDMA Cell And Mapping Pairs
    ${cell_element_list}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    WNCEL-
    ${cell_list}    Get Dictionary Keys    ${cell_element_list}
    &{ret}    Create Dictionary
    FOR    ${cell}    IN    @{cell_list}
        ${element}    Get From Dictionary    ${cell_element_list}    ${cell}
        Click Element    ${element}
        SBTS WEM Filt Parameter    form_param_name=LCELW object reference
        ${param}    SBTS WEM Get Parameters In PE Table
        ${cell_mapping_full_path}    Set Variable    ${param[0]["actual_value"]}
        ${cell_name}    Fetch From Right    ${cell}    /
        Set To Dictionary    ${ret}    ${cell_name}=${cell_mapping_full_path}
    END
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    [Return]    ${ret}

SBTS WEM BackUp Current Configuration
    [Arguments]    ${sbts_webEM_url}    ${backup_configuration_name}=CM_TA_BACKUP    ${skip_error}=${True}    ${windows_index}=-1
    LOG    BackUp Current Configuration name is ${backup_configuration_name}    console=${True}
    ${new_windows_index}    Run Keyword If    '${windows_index}'=='-1'    SBTS WEM Logon
    ...    ${sbts_webEM_url}    setup_param=${False}    skip_error=${skip_error}
    ${windows_index}    Set Variable If    '${windows_index}'=='-1'    ${new_windows_index}    ${windows_index}
    Set Test Variable    ${WINDOW_INDEX_OF_BACKUP_CONFIG}    ${windows_index}
    ${all_plan_conf_name_list}    SBTS WEM Get Configuration Names    Planned BTS configurations
    ${count}    Count Values In List    ${all_plan_conf_name_list}    ${backup_configuration_name}
    Return From Keyword If    ${count}!=${0}
    SBTS WEM Create Configuration Plan    ${backup_configuration_name}

SBTS WEM Activate Current BTS Configuration
    [Arguments]    ${forced_activate}=${False}    ${download_only}=${False}    ${timeout}=600
    ...    ${wait_until_finish}=${True}    ${reset_list}=${None}
    LOG    SBTS WEM Activate Current BTS Configuration    console=${True}
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    MRBTS    MRBTS
    SBTS WEM Activate Plan    ${forced_activate}    ${download_only}    ${timeout}    ${wait_until_finish}    ${reset_list}

SBTS WEM Activate Planed BTS Configuration
    [Arguments]    ${plan_name}=CM_TA_BACKUP
    LOG    Activate Planed BTS Configuration name is ${plan_name}    console=${True}
    Run Keyword If    "${WINDOW_INDEX_OF_BACKUP_CONFIG}"!=""    Switch Browser    ${WINDOW_INDEX_OF_BACKUP_CONFIG}
    SBTS WEM Re-Logon
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    Planned BTS configurations
    Element Should Be Exist    //global-search//li//span[@aria-label='${plan_name}']
    Click Element    //global-search//li//span[@aria-label='${plan_name}']
    SBTS WEM Set Detected HW    false    ${False}    Planned BTS configurations
    SBTS WEM Validate Plan
    ${is_activating}    Run Keyword And Return Status    SBTS WEM Activate Plan    forced_activate=${True}
    Should Be True    ${is_activating}
    Run Keyword If    '${is_activating}'=='${True}'    SBTS WEM Check SBTS Has Restarted Successful

SBTS WEM Activate Inactive BTS Configuration
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    Inactive BTS configurations
    SBTS WEM Activate Plan
    SBTS WEM Check SBTS Has Restarted Successful

SBTS WEM Check Cell Exist
    [Arguments]    ${cell_name_list}    ${expect}=${True}
    ${cur_cells}    SBTS WEM Get All Cell Name
    FOR    ${cell}    IN    @{cell_name_list}
        ${is_exist}    Run Keyword And Return Status    List Should Contain Value    ${cur_cells}    ${cell}
        Should Be Equal    ${is_exist}    ${expect}
    END

SBTS WEM Check Objects Exist
    [Arguments]    ${object_list}    ${expect}=${True}    ${tree_name}=Current BTS configuration
    FOR    ${obj}    IN    @{object_list}
        ${obj_name}    Fetch From Right    ${obj}    /
        ${dic_obj_element}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    ${obj_name}    ${tree_name}
        Run Keyword If    ${expect}    Dictionary Should Contain Key    ${dic_obj_element}    ${obj}
        Run Keyword If    not ${expect}    Dictionary Should Not Contain Key    ${dic_obj_element}    ${obj}
    END

SBTS WEM Get All Cell Name Of RAT
    [Arguments]    ${RAT}
    ${all_cell_name_list}    SBTS WEM Get All Cell Name
    &{rat_dic}    Evaluate    {"GSM":"GNCEL-","WCDMA":"WNCEL-","LTE":"LNCEL-","NR":"NRCELL-"}
    ${first_name}    Get From Dictionary    ${rat_dic}    ${RAT}
    ${ret_list}    Create List
    FOR    ${cell_name}    IN    @{all_cell_name_list}
        ${is_target}    Run Keyword And Return Status    Should Contain    ${cell_name}    ${first_name}
        Run Keyword If    ${is_target}    Append To List    ${ret_list}    ${cell_name}
    END
    [Return]    ${ret_list}

SBTS WEM Get RATs State Duration
    [Arguments]    ${retry}    ${retry_interval}    ${delay}=${300}    ${cur_window_index}=${EMPTY}
    [Timeout]    14 minutes 30 seconds
    Run Keyword If    "${WINDOW_INDEX_OF_BACKUP_CONFIG}"!="" and "${cur_window_index}"!=""    Switch Browser    ${WINDOW_INDEX_OF_BACKUP_CONFIG}
    SBTS WEM Setup RAT Data
    ${rat_status}    SBTS WEM Get RAT Status
    ${tmp_lte_states_list}    Create List    ${rat_status['LTE']['rat_state']}
    ${tmp_gsm_states_list}    Create List    ${rat_status['GSM']['rat_state']}
    ${tmp_wcdma_states_list}    Create List    ${rat_status['WCDMA']['rat_state']}
    ${tmp_nr_states_list}    Create List    ${rat_status['NR']['rat_state']}
    ${is_changed}    Set Variable    ${False}
    FOR    ${step}    IN RANGE    ${0}    ${delay}
        ${rat_status}    SBTS WEM Get RAT Status
        Sleep    1s
        ${tmp1}    Set Variable    "${rat_status['LTE']['rat_state']}"=="${EXPECTANT_RATS_STATE['LTE']['original_rat_state']}"
        ${tmp2}    Set Variable    "${rat_status['GSM']['rat_state']}"=="${EXPECTANT_RATS_STATE['GSM']['original_rat_state']}"
        ${tmp3}    Set Variable    "${rat_status['WCDMA']['rat_state']}"=="${EXPECTANT_RATS_STATE['WCDMA']['original_rat_state']}"
        ${tmp4}    Set Variable    "${rat_status['NR']['rat_state']}"=="${EXPECTANT_RATS_STATE['NR']['original_rat_state']}"
        Continue For Loop If    ${tmp1} and ${tmp2} and ${tmp3} and ${tmp4}
        ${is_changed}    Set Variable    ${True}
        Append To List    ${tmp_lte_states_list}    ${rat_status['LTE']['rat_state']}
        Append To List    ${tmp_gsm_states_list}    ${rat_status['GSM']['rat_state']}
        Append To List    ${tmp_wcdma_states_list}    ${rat_status['WCDMA']['rat_state']}
        Append To List    ${tmp_nr_states_list}    ${rat_status['NR']['rat_state']}
        Exit For Loop
    END
    LOG    ${tmp_lte_states_list}\n${tmp_gsm_states_list}\n${tmp_wcdma_states_list}\n
    Should Be True    ${is_changed}    All RATs did not change status in ${delay} seconds.
    ${is_finished}    Set Variable    ${False}
    FOR    ${step}    IN RANGE    ${0}    ${retry}
        ${rat_status}    SBTS WEM Get RAT Status
        Append To List    ${tmp_lte_states_list}    ${rat_status['LTE']['rat_state']}
        Append To List    ${tmp_gsm_states_list}    ${rat_status['GSM']['rat_state']}
        Append To List    ${tmp_wcdma_states_list}    ${rat_status['WCDMA']['rat_state']}
        Append To List    ${tmp_nr_states_list}    ${rat_status['NR']['rat_state']}
        Sleep    ${retry_interval}
        ${tmp1}    Set Variable    "${rat_status['LTE']['rat_state']}"!="${EXPECTANT_RATS_STATE['LTE']['final_rat_state']}"
        ${tmp2}    Set Variable    "${rat_status['GSM']['rat_state']}"!="${EXPECTANT_RATS_STATE['GSM']['final_rat_state']}"
        ${tmp3}    Set Variable    "${rat_status['WCDMA']['rat_state']}"!="${EXPECTANT_RATS_STATE['WCDMA']['final_rat_state']}"
        ${tmp4}    Set Variable    "${rat_status['NR']['rat_state']}"!="${EXPECTANT_RATS_STATE['NR']['original_rat_state']}"
        Continue For Loop If    ${tmp1} or ${tmp2} or ${tmp3} or ${tmp4}
        ${is_finished}    Set Variable    ${True}
        Exit For Loop
    END
    ${lte_states_list}    Remove Duplicates    ${tmp_lte_states_list}
    ${gsm_states_list}    Remove Duplicates    ${tmp_gsm_states_list}
    ${wcdma_states_list}    Remove Duplicates    ${tmp_wcdma_states_list}
    ${nr_states_list}    Remove Duplicates    ${tmp_nr_states_list}
    ${rats_states}    Create Dictionary    GSM=${gsm_states_list}    LTE=${lte_states_list}    WCDMA=${wcdma_states_list}    NR=${nr_states_list}
    Run Keyword If    "${WINDOW_INDEX_OF_BACKUP_CONFIG}"!="" and "${cur_window_index}"!=""    Switch Browser    ${cur_window_index}
    ${count}    Selenium2Library.Get Element Count    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button
    Run Keyword If    "${count}"=="${1}"    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button
    [Return]    ${rats_states}    ${is_finished}

SBTS_WEM_Get_gNbCuType
    ${gNbCuType}    Set Variable    SA
    ${has_NRBTS}    Run Keyword And Return Status    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    NRBTS    NRBTS
    Return From Keyword If    not ${has_NRBTS}    ${gNbCuType}
    SBTS WEM Filt Parameter    form_param_name=gNB CU type
    ${p_list}    SBTS WEM Get Parameters In PE Table
    ${gNbCuType}    Set Variable    ${p_list[0]['actual_value']}
    [Return]    ${gNbCuType}

SBTS WEM Get Cell Name Of One Cell
    [Arguments]    ${mo_path}
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${mo_path}    ${mo_path.split('/')[-1]}
    SBTS WEM Filt Parameter    form_param_name=Cell name
    ${param_list}    SBTS WEM Get Parameters In PE Table
    ${cell_name}    Set Variable If    '${param_list.__len__()}'=='1'    ${param_list[0]['actual_value']}    ${mo_path.split('/')[-1]}
    ${cell_name}    Set Variable If    '${cell_name}'=='!DELETE!'    ${mo_path.split('/')[-1]}    ${cell_name}
    [Return]    ${cell_name}

SBTS WEM Find Out NRCELL CellDepType
    SBTS WEM Filt Parameter    toolbar_filter=Cell deployment type    form_abbreviation=cellDepType
    ${list_mo_param}    SBTS WEM Get Parameters In PE Table
    ${sa_nrcell_mo}    Create List
    ${nsa_nrcell_mo}    Create List
    FOR    ${params}    IN    @{list_mo_param}
        ${mo}    Get From Dictionary    ${params}    object
        ${type}    Fetch From Right    ${mo}    /
        ${type}    Fetch From Left    ${type}    -
        Continue For Loop If    '${type}'!='NRCELL'
        ${cellDepType}    Get From Dictionary    ${params}    actual_value
        ${list_pointer}    Set Variable If    '${cellDepType}'=='NSA'    ${nsa_nrcell_mo}    ${sa_nrcell_mo}
        Append To List    ${list_pointer}    ${mo}
    END
    Log List    ${sa_nrcell_mo}
    Log List    ${nsa_nrcell_mo}
    [Return]    ${sa_nrcell_mo}    ${nsa_nrcell_mo}

SBTS WEM Reset Configuration
    [Arguments]    ${ip}=192.168.255.129    ${check_site_id_remove}=${False}    ${check_security_credentials_remove}=${False}
    Log    SBTS WEM Reset Configuration:${ip}    console=${True}
    SBTS WEM Logon    https://${ip}    skip_error=${True}    setup_param=${False}
    Wait Until WebElement Exist    //nav-item[2]    30s    3s
    Click Element    //nav-item[2]/div
    element should be visible    //nav-item[2]/div[@aria-expanded="true"]//*[text()="Configuration Reset"]
    Click Element    //a[@href="#/configuration/configuration-reset"]
    Wait Until WebElement Exist    //ng-view//wf-panel-section//execution-bar//ui-button[@a-text="Execute Reset"]/button
    Element Should Be Enabled With Attribute    //ng-view//wf-panel-section//execution-bar//ui-button[@a-text="Execute Reset"]/button
    Run Keyword If    ${check_site_id_remove}    Click Element
    ...    //ng-view//wf-panel-section//div[contains(@class,"configuration-reset-root")]//span[text()="Check this if site ID should be removed."]
    ${tmp1}    Set Variable    //ng-view//wf-panel-section//div[contains(@class,"configuration-reset-root")]//
    Run Keyword If    ${check_security_credentials_remove}
    ...    Click Element    ${tmp1}span[text()="Check this if security credentials should be removed."]
    Click Button    //ng-view//wf-panel-section//execution-bar//ui-button[@a-text="Execute Reset"]/button
    ${tmp1}    Set Variable    //common-modal//modal-body//p[text()="Performing configuration reset will cause erasing commissioning data
    ${tmp2}    Set Variable    and other important files from file system." or text()="Performing configuration
    Wait Until WebElement Exist    ${tmp1} ${tmp2} reset will cause erasing files from both Primary Core and Secondary Core."]
    Click Button    //common-modal//ui-button[@a-text="Execute"]/button
    ${status}    Run Keyword And Return Status    Wait Until WebElement Exist    //plug-and-play-popup-component    600s    30s
    ${click_pnp_result}    Run Keyword And Return Status    Click Button    //plug-and-play-popup-component//ui-button[@a-text="Cancel"]/button
    SBTS WEM Sync 2rd SMOD
    ${status}    Run Keyword And Return Status    Wait Until WebElement Exist    //plug-and-play-popup-component    60s    5s
    Run Keyword If    ${status}    Click Button    //plug-and-play-popup-component//ui-button[@a-text="Cancel"]/button
    SBTS WEM Check SBTS Is Not Configurated
    [Teardown]    SBTS WEM Download Chrome Console Log

SBTS WEM Sync 2rd SMOD
    [Documentation]    Trigger the synchronization for second SMOD after SBTS configuration reset.
    ...
    ...    It depends on whether the ${SMOD2} variable exists.
    ...
    ...    ${SMOD2} is usually defined in TESTLINE_CONFIG_VARIABLES in file env_config_1.yaml
    ...
    ...    Author: Liu Bin
    ...
    ...    Contact: bin.7.Liu@nokia-sbell.com \
    ${smod2_variable_not_exists}    Run keyword and return status    Variable Should Not Exist    ${SMOD2}
    Return From Keyword If    ${smod2_variable_not_exists}
    ${hw_detected}    Set Variable    ${False}
    FOR    ${i}    IN RANGE    0    30
        ${count}    Selenium2Library.Get Element Count    //common-modal//h4[text()="Additional hardware detected"]
        ${hw_detected}    Set Variable If    '${count}' != '0'    ${True}    ${False}
        Exit For Loop If    ${hw_detected}
        Sleep    60s
        ${count}    Selenium2Library.Get Element Count    //main-view//div[@status-bar]//span[@aria-label="Software version" and text()="---"]
        Continue For Loop If    '${count}' == '0'
        ${count}    Selenium2Library.Get Element Count    //main-view//div[@status-bar]//div[@class="status-bar-menu"]/button[@aria-expanded="false"]
        Run Keyword If    '${count}' == '1'    Click Button
        ...    //main-view//div[@status-bar]//div[@class="status-bar-menu"]/button[@aria-expanded="false"]
        ${orig timeout}    Set Selenium Timeout    3s
        ${is_shown}    Run Keyword And Return Status    Wait Until Element Is Visible
        ...    //main-view//div[@status-bar]//div[contains(@class="status-bar-menu")]/ul//a[@href]
        Set Selenium Timeout    ${orig timeout}
        Continue For Loop If    '${is_shown}'!='${True}'
        ${count}    Selenium2Library.Get Element Count
        ...    //main-view//div[@status-bar]//div[contains(@class="status-bar-menu")]/ul//a[@href]/i[text()=" Connect"]
        Run Keyword If    '${count}' == '1'    Click Button    //main-view//div[@status-bar]//div[contains(@class="status-bar-menu")]/ul//a[@href]
        Sleep    60s
    END
    Should Be True    ${hw_detected}
    LOG    Dual core hardware detected.    console=${True}
    ${status}    Run Keyword And Return Status    Wait Until WebElement Exist    //plug-and-play-popup-component    60s    5s
    Run Keyword If    ${status}    Run Keyword And Return Status    Click Button
    ...    //plug-and-play-popup-component//ui-button[@a-text="Cancel"]/button
    Click Button    //common-modal//ui-button[@a-text="Start sync"]/button
    Wait Until WebElement Exist
    ...    //common-modal//modal-body//span[text()=" Start sync operation was completed. You could stop sync in Site Runtime View if needed."]
    ...    600s    30s
    Click Button    //common-modal//ui-button[@a-text="Close"]/button
    LOG    Sync operation was completed.    console=${True}

SBTS WEM Check SBTS Is Not Configurated
    Wait Until Keyword Succeeds    300s    10s    SBTS WEM Status Bar Should Be Connected
    Element Should Be Exist    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//span[contains(text(),"--")]
    ${tmp1}    Set Variable    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//
    Element Should Be Exist    ${tmp1}div[contains(@class,"status-bar-text-overflow") and contains(text(),"--")]
    ${all_cell}    SBTS WEM Get All Cell Name
    ${cell_count}    Get Length    ${all_cell}
    Should Be Equal As Integers    ${cell_count}    ${0}
    ${rat_status}    SBTS WEM Get RAT Status
    ${all_rat_list}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{all_rat_list}
        Should Be Equal As Strings    ${rat_status['${rat}']['rat_state']}    Not commissioned
    END

SBTS WEM Click Common Text
    [Arguments]    ${key_of_common_text}
    ${tmpStr}    Convert To String    ${WEB_EM_COMMON_TEXT}
    &{key_text}    Evaluate    ${tmpStr}
    SBTS WEM Click Text    ${key_text['${key_of_common_text}']}

SBTS WEM Click Button Or Element
    [Arguments]    ${xpath}    ${retry}=3    ${interval}=1s    ${KW_checker}=${None}    ${param_checker}=${None}
    [Documentation]    When the button or element wished to click is sheltered from notify pops-up of SBTS WebEM,
    ...    this KW will click the notify and retry to click.
    ${count}    Selenium2Library.Get Element Count    ${xpath}
    Should Be Equal As Integers    ${count}    ${1}
    FOR    ${conter}    IN RANGE    ${0}    ${retry}
        ${ret}    Run Keyword And Return Status    Click Element    ${xpath}
        Run Keyword If    not ${ret}    SBTS WEM Click All Notify Messages
        Sleep    1s    #give one second to WebUI to let the notify disappear
        Continue For Loop If    not ${ret}
        ${ret}    Run Keyword If    '${KW_checker}'!='None'    Run Keyword And Return Status    ${KW_checker}    ${param_checker}
        Exit For Loop If    "${ret}"!="False"
        Sleep    ${interval}
    END
    Should Not Be Equal As Strings    ${ret}    ${False}
    [Return]    ${ret}

SBTS WEM Check Cells Has Been Blocked In Time
    [Arguments]    ${name_of_cell_list}    ${time}
    LOG    KW:SBTS WEM Check Cells Has Been Blocked In Time    console=${True}
    FOR    ${full_name}    IN    @{name_of_cell_list}
        ${name}    Fetch From Right    ${full_name}    /
        Remove Values From List    ${name_of_cell_list}    ${full_name}
        Append To List    ${name_of_cell_list}    ${name}
    END
    Sort List    ${name_of_cell_list}
    ${total_blocked_cells}    Create List
    Wait Until Keyword Succeeds    ${time}    1s    SBTS WEM Check Cells Are Blocked    ${total_blocked_cells}    ${name_of_cell_list}
    #Check no other cell has been blocked in 5 seconds
    FOR    ${step}    IN RANGE    0    5
        ${blocked_cell_names}    SBTS WEM Get Name Of All Blocked Cells
        Remove Values From List    ${blocked_cell_names}    @{name_of_cell_list}
        ${count}    Get Length    ${blocked_cell_names}
        Should Be Equal As Integers    ${count}    ${0}
        Sleep    1s
    END
    LOG    KW:Check Cells Has Been Blocked In Time, wait for all cells online    console=${True}
    Wait Until Keyword Succeeds    ${time}    10s    SBTS WEM Check No Cells Are Blocked

SBTS WEM Check No Cells Has Been Blocked In Time
    [Arguments]    ${time}=30
    FOR    ${step}    IN RANGE    0    ${time}
        ${blocked_cell_names}    SBTS WEM Get Name Of All Blocked Cells
        ${count}    Get Length    ${blocked_cell_names}
        Should Be Equal As Integers    ${count}    ${0}
        Sleep    1s
    END

SBTS WEM Check Cells Are Blocked
    [Arguments]    ${total_blocked_cells}    ${name_of_cell_list}
    ${blocked_cell_names}    SBTS WEM Get Name Of All Blocked Cells
    FOR    ${cell_name}    IN    @{blocked_cell_names}
        ${is_not_contained}    List Should Not Contain Value    ${total_blocked_cells}    ${cell_name}
        Append To List    ${total_blocked_cells}    ${cell_name}
    END
    Sort List    ${total_blocked_cells}
    Lists Should Be Equal    ${name_of_cell_list}    ${total_blocked_cells}

SBTS WEM Check No Cells Are Blocked
    ${blocked_cell_names}    SBTS WEM Get Name Of All Blocked Cells
    ${count}    Get Length    ${blocked_cell_names}
    Should Be Equal As Integers    ${count}    ${0}

SBTS WEM Check Cells Status Until One Cell Created
    [Arguments]    ${cell_created_name}    ${expect_online}=${True}    ${timeout}=300
    ${KW}    Set Variable If    ${expect_online}    SBTS WEM Get Name Of All Blocked Cells    SBTS WEM Get Name Of All Unblocked Cells
    ${is_cell_created}    Set Variable    ${False}
    FOR    ${interval}    IN RANGE    ${0}    ${timeout}
        ${list_cell}    Run Keyword    ${KW}
        Remove Values From List    ${list_cell}    ${cell_created_name}
        Should Be Empty    ${list_cell}
        ${list_all_cells}    SBTS WEM Get All Cell Name
        ${count}    Count Values In List    ${list_all_cells}    ${cell_created_name}
        Sleep    1s
        Continue For Loop If    "${count}"!="${1}"
        ${is_cell_created}    Set Variable    ${True}
        Exit For Loop
    END
    Should Be True    ${is_cell_created}

SBTS WEM Check Cells Status Until One Cell Deleted
    [Arguments]    ${cell_deleted_name}    ${expect_online}=${True}    ${timeout}=300
    ${KW}    Set Variable If    ${expect_online}    SBTS WEM Get Name Of All Blocked Cells    SBTS WEM Get Name Of All Unblocked Cells
    ${is_cell_removed}    Set Variable    ${False}
    SBTS WEM Open RunTime View    C
    ${orig_count}    Selenium2Library.Get Element Count
    ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container")]//span[contains(@class,"cell-element-name")]
    FOR    ${interval}    IN RANGE    ${0}    ${timeout}
        ${list_cell}    Run Keyword    ${KW}
        Remove Values From List    ${list_cell}    ${cell_deleted_name}
        Should Be Empty    ${list_cell}
        ${cell_count}    Selenium2Library.Get Element Count
        ...    //ng-view//div[@cell-element]//div[contains(@class,"cell-element-container")]//span[contains(@class,"cell-element-name")]
        Sleep    1s
        Continue For Loop If    "${cell_count}"=="${orig_count}"
        Run Keyword If    ${cell_count}!=${orig_count}-${1}    Exit For Loop
        ${list_all_cells}    Run Keyword If    ${cell_count}==${orig_count}-${1}    SBTS WEM Get All Cell Name
        ${is_cell_removed}    Run Keyword And Return Status    List Should Not Contain Value    ${list_all_cells}    ${cell_deleted_name}
        Exit For Loop
    END
    Should Be True    ${is_cell_removed}

SBTS WEM Check Alarms Should Be Raised
    [Arguments]    ${alarm_id}    ${fault_id}    ${severity}=${EMPTY}    ${alarm_object}=${EMPTY}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    &{expect_alarm}    Create Dictionary    Alarm ID=${alarm_id}    Fault ID=${fault_id}
    Run Keyword If    "${severity}"!=""    Set To Dictionary    ${expect_alarm}    Severity    ${severity}
    Run Keyword If    "${alarm_object}"!=""    Set To Dictionary    ${expect_alarm}    Configuration alarming object    ${alarm_object}
    Alarm List Should Contains Special Alarm    ${alarms}    ${expect_alarm}
    [Return]    ${alarms}

SBTS WEM Check Mediator Connected
    [Arguments]    ${is_FlatSOAM}
    ${mediator_name}    ${mediator_status}    ${mediator_diode_class}    SBTS WEM Get Mediator Infor
    ${status_str}    Set Variable If    ${is_FlatSOAM}    Not secured    Connected
    ${name_str}    Set Variable If    ${is_FlatSOAM}    NMS    BTS MED
    Should Be Equal As Strings    ${mediator_status}    ${status_str}
    Should Contain    ${mediator_diode_class}    green-diode
    Should Contain    ${mediator_name}    ${name_str}

SBTS WEM Wait Until Alarm Raised
    [Arguments]    ${dic_expect_alarm}    ${timeout}=180s    ${interval}=10s
    SBTS WEM Open Alarm Management
    ${alarms}    Wait Until Keyword Succeeds    ${timeout}    ${interval}    SBTS WEB Check Current Alarm Should Raised    ${dic_expect_alarm}
    [Return]    ${alarms}

SBTS WEB Check Current Alarm Should Raised
    [Arguments]    ${dic_expect_alarm}
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Alarm List Should Contains Special Alarm    ${alarms}    ${dic_expect_alarm}
    [Return]    ${alarms}

SBTS WEM Check TRX Number
    [Arguments]    ${expected_onair_TRX_num}    ${expected_total_TRX_num}    ${GSM_cell_name_filter}=GNCEL-
    [Documentation]    Check the TRX status of GNCEL in page "Runtime View"->"Cells".
    ...    Cells with names containing ${GSM_cell_name_filter} will be checked
    ...
    ...    *INPUT*
    ...    | Input Parameters | Man. | Description |
    ...    | expected_onair_TRX_num | yes | meaning as naming |
    ...    | expected_total_TRX_num | yes | meaning as naming |
    ...    | GSM_cell_name_filter | no | meaning as naming |
    ...
    ...    *Example*
    ...    | SBTS WEM Check TRX Number | 1 | 3 |
    ...    | SBTS WEM Check TRX Number | 2 | 3 | GNCEL-1 |
    ...    | SBTS WEM Check TRX Number | 3 | 3 | cell_name |
    SBTS WEM Open RunTime View    C
    Wait Until Page Contains    TRX status:    10
    ${elemetns}    Get WebElements
    ...    //div[@cells-view]//span[contains(@ui-tooltip,"${GSM_cell_name_filter}")]/../..//span[contains(text(),"TRX status:")]
    FOR    ${element}    IN    @{elemetns}
        ${text}    Get Text    ${element}
        ${is_not_TRX}    Run Keyword And Return Status    Should not Contain    ${text}    TRX status:
        Continue For Loop If    ${is_not_TRX}
        ${TRX_status}    Set Variable    ${text.split(':')[-1]}
        ${onair_TRX}    Set Variable    ${TRX_status.split('/')[0].strip()}
        ${tatal_TRX}    Set Variable    ${TRX_status.split('/')[1].strip()}
        should be equal as integers    ${onair_TRX}    ${expected_onair_TRX_num}
        should be equal as integers    ${tatal_TRX}    ${expected_total_TRX_num}
    END

Check RATs Service Is Down
    [Arguments]    ${RATs_list}    ${tmp_list}
    ${rat_status}    SBTS WEM Get RAT Status
    ${all_rat_list}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{all_rat_list}
        Continue For Loop If    "${rat_status['${rat}']['cell_state']}"!="All cells failed" and "'rat_status['rat_state']" != "Commissioned"
        Append To List    ${tmp_list}    ${rat}
        ${list}    Remove Duplicates    ${tmp_list}
        Set Test Variable    ${tmp_list}    ${list}
    END
    Sort List    ${RATs_list}
    Sort List    ${tmp_list}
    Lists Should Be Equal    ${RATs_list}    ${tmp_list}

Check RATs Service Is Lock
    [Arguments]    ${RATs_list}    ${tmp_list}
    ${rat_status}    SBTS WEM Get RAT Status
    ${all_rat_list}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{all_rat_list}
        Continue For Loop If    "${rat_status['${rat}']['cell_state']}"!="All cells failed" and "'rat_status['rat_state']" != "Commissioned"
        Append To List    ${tmp_list}    ${rat}
        ${list}    Remove Duplicates    ${tmp_list}
        Set Test Variable    ${tmp_list}    ${list}
    END
    Sort List    ${RATs_list}
    Sort List    ${tmp_list}
    Lists Should Be Equal    ${RATs_list}    ${tmp_list}

Check RATs Service Is Setup
    [Arguments]    ${RATs_list}    ${tmp_list}
    ${rat_status}    SBTS WEM Get RAT Status
    ${all_rat_list}    Get Dictionary Keys    ${rat_status}
    ${is_target_rat_ok}    Set Variable    ${True}
    FOR    ${rat}    IN    @{all_rat_list}
        ${is_ok}    Run Keyword And Return Status    Should Be Equal As Strings    ${rat_status['${rat}']['cell_state']}    All cells enabled
        Run Keyword If    not ${is_ok}    Append To List    ${tmp_list}    ${rat}
        ${tmp_list}    Remove Duplicates    ${tmp_list}
        ${is_not_target_rat}    Run Keyword And Return Status    List Should Not Contain Value    ${RATs_list}    ${rat}
        Continue For Loop If    ${is_not_target_rat}
        ${is_target_rat_ok}    Evaluate    ${is_ok} and ${is_target_rat_ok}
    END
    Should Be True    ${is_target_rat_ok}
    Remove Values From List    ${tmp_list}    @{RATs_list}
    ${count}    Get Length    ${tmp_list}
    Should Be Equal As Integers    ${count}    ${0}

SBTS WEM Load Json File
    [Arguments]    ${file_path}
    ${file_content}    OperatingSystem.Get File    ${file_path}
    ${data}    Evaluate    ${file_content}
    [Return]    ${data}

Get All Carrier Freq
    ${data}    SBTS WEM Get LTE And WCDMA Carriers Infor
    ${dic}    SBTS WEM Get GSM Cell Radio Frequency
    ${cells}    Get Dictionary Keys    ${dic}
    FOR    ${cell}    IN    @{cells}
        Set To Dictionary    ${data}    ${cell}=${dic['${cell}']}
    END
    Set Test Variable    ${ALL_CARRIER_FREQUENCY}    ${data}

Get Carrier Frequency Range
    ${param_list}    Create List    Product name
    ${param_dic}    SBTS WEM Get Parameters Of One Object    RMOD_R-    ${param_list}
    ${CarrierFrequencyDescription}    SBTS WEM Load Json File    StaticData/CarrierFrequencyDescription/CarrierFrequencyDescription.json
    ${tmp}    Get From Dictionary    ${CarrierFrequencyDescription}    ${param_dic['Product name']}
    Set Test Variable    ${CARRIER_FREQUENCY_RANGE}    ${tmp}

Get GSM Cell Freq
    [Arguments]    ${cell}
    ${freq_info}    Get From Dictionary    ${ALL_CARRIER_FREQUENCY}    ${cell}
    ${count}    Get Length    ${freq_info}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${DL_freq_str}    Set Variable    ${freq_info[${index}]['Downlink freq']}
    ${tmp_list}    Split String    ${DL_freq_str}
    ${DL_freq}    Set Variable    ${tmp_list[0]}
    ${UL_freq_str}    Set Variable    ${freq_info[${index}]['Uplink freq']}
    ${tmp_list}    Split String    ${UL_freq_str}
    ${UL_freq}    Set Variable    ${tmp_list[0]}
    [Return]    ${DL_freq}    ${UL_freq}

Get LTE Cell Freq
    [Arguments]    ${cell}
    ${freq_info}    Get From Dictionary    ${ALL_CARRIER_FREQUENCY}    ${cell}
    ${ul}    Split String    ${freq_info["FREQ_UL"]}
    ${dl}    Split String    ${freq_info["FREQ_DL"]}
    ${freq_UL}    Set Variable    ${ul[0]}
    ${freq_DL}    Set Variable    ${dl[0]}
    [Return]    ${freq_DL}    ${freq_UL}

Get WCDMA Cell Freq
    [Arguments]    ${cell}
    ${freq_info}    Get From Dictionary    ${ALL_CARRIER_FREQUENCY}    ${cell}
    ${ul}    Split String    ${freq_info["FREQ_UL"]}
    ${dl}    Split String    ${freq_info["FREQ_DL"]}
    ${freq_UL}    Set Variable    ${ul[0]}
    ${freq_DL}    Set Variable    ${dl[0]}
    [Return]    ${freq_DL}    ${freq_UL}

Should Has No Configuration Error
    ${hardware_error}    SBTS WEM Get Configuration Errors    HE
    ${definition_error}    SBTS WEM Get Configuration Errors    DE
    ${relation_error}    SBTS WEM Get Configuration Errors    RE
    ${count}    Get Length    ${hardware_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${definition_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${relation_error}
    Should Be Equal As Integers    ${count}    ${0}

Status Of RAT Should Be OK
    SBTS WEM Setup RAT Data
    ${rat_status}    SBTS WEM Get RAT Status
    Run Keyword If    "${GNB_CU_TYPE}"!="SA" and "${EXPECTANT_RATS_STATE['LTE']['final_rat_state']}"!="On air"
    ...    Pop From Dictionary    ${rat_status}    NR    #5G RAT stauts depends on 4G RAT if NSA
    ${rats}    Get Dictionary Keys    ${rat_status}
    FOR    ${rat}    IN    @{rats}
        Should Be Equal As Strings    ${rat_status['${rat}']['rat_state']}    ${EXPECTANT_RATS_STATE['${rat}']['final_rat_state']}
        Should Be Equal As Strings    ${rat_status['${rat}']['cell_state']}    ${EXPECTANT_RATS_STATE['${rat}']['final_cell_state']}
    END

Recover Backup Object
    [Arguments]    ${object_path}    ${params_backup}    ${params_in_adding_popup_page}=${None}
    ${object_params}    Get From Dictionary    ${params_backup}    ${object_path}
    ${type_list}    Split String    ${object_path}    /
    ${object_type}    Fetch From Left    ${type_list[-1]}    -
    ${is_runtime_object}    Run Keyword And Return Status    Should End With    ${object_type}    _R
    Return From Keyword If    ${is_runtime_object}
    ${object_id}    Fetch From Right    ${object_path}    -
    ${parent_path}    Fetch From Left    ${object_path}    /${object_type}-
    ${parent_name}    Fetch From Right    ${parent_path}    /
    ${param1}    Create List    Object class:    selectedlist    ${object_type}
    ${param2}    Create List    Id:    textbox    ${object_id}
    ${tmp_params}    Create List    ${param1}    ${param2}
    ${params}    Set Variable If    ${params_in_adding_popup_page}!=${None}    ${params_in_adding_popup_page}    ${tmp_params}
    ${created_object_path}    SBTS WEM Add Object On Navigation Panell Under Pramater Editor    ${parent_path}    ${parent_name}    ${params}
    Return From Keyword If    '${created_object_path}'==''
    FOR    ${cell_param}    IN    @{object_params}
        ${full_param_name}    Get From Dictionary    ${cell_param}    full_name
        SBTS WEM Filt Parameter    form_param_name=${full_param_name}
        ${cur_params}    SBTS WEM Get Parameters In PE Table
        Should Not Be Equal As Integers    ${cur_params.__len__()}    ${0}
        ${value}    Get From Dictionary    ${cell_param}    actual_value
        Continue For Loop If    '${value}'=='${cur_params[0]["actual_value"]}'
        ${ret}    SBTS WEM Modify Parameters In PE table    ${created_object_path}    ${full_param_name}    ${value}
        Should Be True    ${ret}
        Sleep    1s
    END

Get One LTE Cell For Copy
    [Arguments]    ${source_cell_path}
    ${found}    Set Variable    ${False}
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    LNCEL_FDD-
    ${type1_object_path_list}    Get Dictionary Keys    ${elements}
    FOR    ${path}    IN    @{type1_object_path_list}
        ${is_type}    Run Keyword And Return Status    Should Contain    ${path}    ${source_cell_path}
        Run Keyword If    ${is_type}    Remove Values From List    ${type1_object_path_list}    ${path}
        ${found}    Set Variable If    ${is_type}    ${is_type}    ${found}
    END
    ${ret}    Run Keyword If    ${found}    Fetch From Left    ${type1_object_path_list[0]}    /LNCEL_FDD-
    Return From Keyword If    ${found}    ${ret}
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    NBIOT_FDD-
    ${type2_object_path_list}    Get Dictionary Keys    ${elements}
    FOR    ${path}    IN    @{type2_object_path_list}
        ${is_type}    Run Keyword And Return Status    Should Contain    ${path}    ${source_cell_path}
        Run Keyword If    ${is_type}    Remove Values From List    ${type2_object_path_list}    ${path}
        ${found}    Set Variable If    ${is_type}    ${is_type}    ${found}
    END
    ${ret}    Run Keyword If    ${found}    Fetch From Left    ${type2_object_path_list[0]}    /NBIOT_FDD-
    Return From Keyword If    ${found}    ${ret}
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    LNCEL_TDD-
    ${type3_object_path_list}    Get Dictionary Keys    ${elements}
    FOR    ${path}    IN    @{type3_object_path_list}
        ${is_type}    Run Keyword And Return Status    Should Contain    ${path}    ${source_cell_path}
        Run Keyword If    ${is_type}    Remove Values From List    ${type3_object_path_list}    ${path}
        ${found}    Set Variable If    ${is_type}    ${is_type}    ${found}
    END
    ${ret}    Run Keyword If    ${found}    Fetch From Left    ${type3_object_path_list[0]}    /LNCEL_TDD-
    Return From Keyword If    ${found}    ${ret}
    [Return]    ${ret}

Alarm List Should Contains Special Alarm
    [Arguments]    ${alarm_list}    ${expect_alarm}
    ${is_contained}    Set Variable    ${False}
    FOR    ${alarm}    IN    @{alarm_list}
        ${is_contained}    Run Keyword And Return Status    Dictionary Should Contain Sub Dictionary    ${alarm}    ${expect_alarm}
        Exit For Loop If    ${is_contained}
    END
    Should Be True    ${is_contained}

Should Only Has Sector Configuration Error Or Not
    ${hardware_error}    SBTS WEM Get Configuration Errors    HE
    ${definition_error}    SBTS WEM Get Configuration Errors    DE
    ${relation_error}    SBTS WEM Get Configuration Errors    RE
    ${count}    Get Length    ${hardware_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${definition_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${relation_error}
    Return From Keyword If    ${count}==${0}
    #some environment has no error if VSWR is not set or this deleted cell constitute a sector itself
    Should Be Equal As Integers    ${count}    ${1}
    ${errs}    Get From Dictionary    ${relation_error}    parameter-validation-errors
    FOR    ${err}    IN    @{errs}
        Should Contain    ${err['Error description']}    .distname and CHANNEL.direction equal to TX
        #it is required that there exist MOs CHANNEL-* having parameter/field CHANNEL.antlDN is equal to distinguished name (DN) of
    END

Wait Until WebElement Exist
    [Arguments]    ${xpath}    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Be Exist    ${xpath}

Wait Until WebElement Not Exist
    [Arguments]    ${xpath}    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Not Be Exist    ${xpath}

Wait Until WebElement Enabled With Attribute
    [Arguments]    ${xpath}    ${att_name}=disabled    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Be Enabled With Attribute    ${xpath}    ${att_name}

Wait Until WebElement Disabled With Attribute
    [Arguments]    ${xpath}    ${att_name}=disabled    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Be Disabled With Attribute    ${xpath}    ${att_name}

Filt Alarm From Alarm List
    [Arguments]    ${alarm_list}    ${key}    ${val}
    FOR    ${alm}    IN    @{alarm_list}
        ${a_val}    Get From Dictionary    ${alm}    ${key}
        Run Keyword If    "${a_val}"=="${val}"    Remove Values From List    ${alarm_list}    ${alm}
    END
    [Return]    ${alarm_list}

Get Objects By Condition
    [Arguments]    ${condition_str}
    [Documentation]    ${condition_str} should be given as MO_Type[attribute expression].
    ...    for SBTS, just give as SBTS
    ...    for RAT, just give one of WCDMA,LTE,GSM
    ...    for only the cell which parameters of is modify, just give an empty string like ""
    ...    attribute type:
    ...    1.parameter and value, parameter_name = value
    ...    2.sub-MO_Type, the child MO_type, /sub-MO_Type
    ...    expression syntax:
    ...    1.multiple attribute assembled by logical instruction characters: and
    ...    2.euqal, using character "=" for exact matching parameter
    ...    3.not euqal, using character "!=" for exact matching parameter
    ...    4.contain, using character "~" for fuzzy matching parameter, the type of parameter must be string
    ...    5.not contain, using character "!~" for exact matching parameter, the type of parameter must be string
    ...    6.larger then, using character ">" for exact matching parameter, the type of parameter must be integer
    ...    7.smaller then, using character "<" for exact matching parameter, the type of parameter must be integer
    ...
    ...    example:
    ...    "MRBTS/LNBTS/LNCEL[/LNCEL_FDD]" could get all LTE cells containing sub-MO LNCEL_FDD
    ...    "MRBTS/LNBTS/LNCEL[\LNCEL_FDD]" could get all LTE cells not containing sub-MO LNCEL_FDD
    ...    "MRBTS/LNBTS/LNCEL[/LNCEL_FDD and pa = value and pc > 2]" could get all LTE cells containing sub-MO LNCEL_FDD and parameter
    ...    'pa' is 'value' and parameter 'pc' larger than 2
    ...    "" could get the cell which parameter of was modify
    ...    "WCDMA" could get the WCDMA RAT
    ${object_list}    Create List
    Return From Keyword If    '${condition_str}'==''    ${object_list}
    ${object_list}    Get Special Object By Condition    ${condition_str}
    ${count}    Get Length    ${object_list}
    Return From Keyword If    ${count}!=${0}    ${object_list}
    ${object_class}    Fetch From Left    ${condition_str}    [
    ${object_type}    Fetch From Right    ${object_class}    /
    ${object_element}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    ${object_type}-
    ${object_list}    Get Dictionary Keys    ${object_element}
    ${condition}    Remove String    ${condition_str}    ${object_class}
    ${condition}    Fetch From Right    ${condition}    [
    ${condition}    Fetch From Left    ${condition}    ]
    FOR    ${obj}    IN    @{object_list}
        ${obj_type}    Fetch From Right    ${obj}    /
        ${obj_type}    Fetch From Left    ${obj_type}    -
        Run Keyword If    '${obj_type}'!='${object_type}'    Remove Values From List    ${object_list}    ${obj}
    END
    Return From Keyword If    '${condition}'==''    ${object_list}
    ${sub_condition_list}    Split String    ${condition}    \ and\
    ${sub_object_condition_list}    Create List
    FOR    ${sub_condition}    IN    @{sub_condition_list}
        ${oper_char}    Get Regexp Matches    ${sub_condition}    =|!=|~|!~|>|<
        ${length}    Get Length    ${oper_char}
        Continue For Loop If    ${length}!=${0}
        Append To List    ${sub_object_condition_list}    ${sub_condition}
        Remove Values From List    ${sub_condition_list}    ${sub_condition}
    END
    FOR    ${object}    IN    @{object_list}
        ${sub_object_list}    SBTS WEM Get Sub-objects On Navigation Panel Under Pramater Editor    ${object}
        Remove Object From List If Not Match Sub-Object Condition    ${sub_object_condition_list}    ${sub_object_list}
        ...    ${object_list}    ${object}
    END
    ${param_name_list}    Create List
    FOR    ${param_condition}    IN    @{sub_condition_list}
        ${oper}    Get Regexp Matches    ${param_condition}    =|!=|~|!~|>|<
        ${name}    Fetch From Left    ${param_condition}    ${oper[0]}
        Append To List    ${param_name_list}    ${name.strip()}
    END
    FOR    ${object}    IN    @{object_list}
       ${param_dic}    SBTS WEM Get Parameters Of One Object    ${object}    ${param_name_list}
        Remove Object From List If Not Match Parameter Condition    ${sub_condition_list}    ${param_dic}    ${object_list}    ${object}
    END
    LOG    ${object_list}
    [Return]    ${object_list}

Check the mapping relationship between NCF and SBTS
    [Arguments]    ${NCF_File}
    SBTS WEM Re-Logon
    ${test_data}    Load Json File    ${Json_File}
    ${keys}    Get Dictionary Keys    ${test_data}
    FOR    ${keys}    IN    @{keys}
        #get the SBTS Para information
        ${filter}    Fetch from left    ${test_data["${keys}"]}    /
        ${input_para}    Fetch from right    ${test_data["${keys}"]}    /
        ${SBTS_para_value}    Get the parameter value from Web UI    ${filter}    ${input_para}
        #get the NCF para information
        ${dist_name}    Fetch from left    ${keys}    /
        ${NCF_para}    Fetch from right    ${keys}    /
        ${NCF_File_para_value}    Get Element Text    ${NCF_File}    cmData/managedObject[@distName="${dist_name}"]/p[@name="${NCF_para}"]
        Should Be Equal As Strings    ${SBTS_para_value}    ${NCF_File_para_value}
    END
