*** Settings ***
Documentation
...    Author: Yang Mengli
...    Contact: mengli.yang@nokia-sbell.com
...    Common KWs related to Classicalbts.
...    Some common operation is put in this file
...    Case proccess is put to case file
...    Please do not modify the file without notification to author

Library           Selenium2Library
Library           FCT_Excel.py



*** Keywords ***
Download FCE Modules For Current SW
    [Documentation]    Helper keyword for downloading fce and fct for current software build
    ...    Author:
    ...    Contact:
    ${active_sw_version}    coam.Get SW Version    connection=COAM
    Set Test Variable    ${active_sw_version}
    ${current_prefix}    Set Variable    ${active_sw_version.split('_')[0].strip()}
    ${current_release}    Set Variable If   "${current_prefix}" == "${Trunk_Prefix}"    SBTS00    ${current_prefix}
    ${version_num}    Fetch From Right     ${active_sw_version}    _ENB_
    ${current_version}    Set Variable    ${current_release}_ENB_${version_num}
    ${fce_worker}    ${fct_files}    Download FCE And FCT    target_version=${current_version}
    ...    target_download_path=${TEST_LOG_DIRECTORY}/TestFiles    release_name=${current_release}   clean_folder=${FALSE}
    [Return]     ${fce_worker}    ${fct_files}

Download FCE And FCT
    [Arguments]    ${target_version}    ${target_download_path}=/home/ute/Downloads    ${release_name}=SBTS00    ${clean_folder}=${TRUE}
    [Documentation]    Helper keyword for downloading fce and fct
    ...    Author:
    ...    Contact:
    ...    *INPUT*
    ...
    ...    | Parameter | Mandatory | Description |
    ...    | target_version | Yes | e.g. SBTS00_ENB_9999_230608_000013 |
    ...    | target_download_path | Yes | the path you want to save in local vm |
    ...    | release_name | Yes | default is: SBTS00 |
    ${download_command}    Set Variable    sudo wget --progress=dot:giga -T 600 -t 2
    ${download_source_path}    Set Variable
    ...    https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/${release_name}
    ${status}    Run Keyword And Return Status    OperatingSystem.Directory Should Exist    ${target_download_path}
    Run Keyword If    ${status}    OperatingSystem.Create Directory    ${target_download_path}
    ${remove_files_cmd}    Set Variable    sudo rm -rf ${target_download_path}/*
    Run Keyword If    ${clean_folder}    OperatingSystem.Run    ${remove_files_cmd}
    ${fce_worker}    Set Variable    ${target_version}_fce-worker.zip
    ${fct_files}    Set Variable    ${target_version}_fct-files.zip
    Log To Console    \nStart Download FCE For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fce_worker} -O ${target_download_path}/${fce_worker}
    Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCE For ${target_version}...........
    Log To Console    \nStart Download FCT For ${target_version}...........
    ${output}    Wait Until Keyword Succeeds    5m    5s    OperatingSystem.Run
    ...    ${download_command} ${download_source_path}/${target_version}/${fct_files} -O ${target_download_path}/${fct_files}
    Should Contain    ${output}    100%
    Log To Console    \nComplete Download FCT For ${target_version}...........
    OperatingSystem.File Should Exist    ${target_download_path}/${fce_worker}
    OperatingSystem.File Should Exist    ${target_download_path}/${fct_files}
    [Return]     ${fce_worker}    ${fct_files}

SBTS WEM Open Configuration Manager
    [Arguments]    ${target_tab}=PE
    [Documentation]    Go to configuration manager page. Should Logon SBTS WEM before.
    ...    ${target_tab} should be one key of dictionary:{'PE':'parameters-editor','CW':'commissioning',
    ...    'DE':'definition-errors','RE':'relation-errors','HE':'hardware-errors'}
    [Timeout]    2 minutes
    ${main_view_title}    SBTS WEM Get Current Main View Title
    Return From Keyword If    '${main_view_title}'=='Configuration Management' and '${target_tab}'=='None'
    ${target_tab}    Set Variable If    '${target_tab}' == 'None'    PE    ${target_tab}
    ${tmp1}    Set Variable    {'PE':'parameters-editor','CA':'configuration-automation','CW':'commissioning','DE':'definition-errors',
    ${tmp2}    Set Variable    'RE':'relation-errors','HE':'hardware-errors'}
    &{url_dic}    Evaluate    ${tmp1}${tmp2}
    ${tab_url}    Set Variable    ${url_dic['${target_tab}']}
    ${is_tab_right}    Run Keyword And Return Status    SBTS WEM Location Should Contain    ${tab_url}
    Return From Keyword If    ${is_tab_right}
    Wait Until WebElement Exist    //nav-item[2]    30s    3s
    Click Element    //nav-item[2]/div
    Mouse Over    //main-view//app-header/div[contains(@class,"app-name")]
    element should be visible    //nav-item[2]/div[@aria-expanded="true"]//*[text()="Configuration Management"]
    Mouse Over    //nav-item[2]/div[@aria-expanded="true"]//*[text()="Configuration Management"]
    ${tmp1}    Set Variable    {'PE':'//nav-item[2]//a[@href="#/configuration/parameters-editor"]',
    ${tmp2}    Set Variable    'CA':'//nav-item[2]//a[@href="#/configuration/configuration-automation"]',
    ${tmp3}    Set Variable    'CW':'//nav-item[2]//a[@href="#/configuration/commissioning"]',
    ${tmp4}    Set Variable    'DE':'//nav-item[2]//a[@href="#/configuration/definition-errors"]',
    ${tmp5}    Set Variable    'RE':'//nav-item[2]//a[@href="#/configuration/relation-errors"]',
    ${tmp6}    Set Variable    'HE':'//nav-item[2]//a[@href="#/configuration/hardware-errors"]'}
    &{tab_dic}    Evaluate    ${tmp1}${tmp2}${tmp3}${tmp4}${tmp5}${tmp6}
    ${tab_xpath}    Set Variable    ${tab_dic['${target_tab}']}
    Click Element    ${tab_xpath}
    sleep    3s    #wait for Validation Errors in Configuration
    ${is_warning}    Run Keyword And Return Status    Element Should Be Exist
    ...    //validation-errors-modal/ui-modal[@a-title="Validation Errors in Configuration"]
    Run Keyword If    ${is_warning}    Click Button
    ...    //validation-errors-modal/ui-modal[@a-title="Validation Errors in Configuration"]//ui-footer//button

SBTS WEM Get Current Main View Title
    [Timeout]    1 minute
    Wait Until Keyword Succeeds    10s    1s    Element Should Be Exist
    ...    //ng-view//span | //ng-view//ui-view-panel//wf-panel-header/div[contains(@class,"ui-view-panel-header-title")]
    ${element}    Get WebElement
    ...    //ng-view//span | //ng-view//ui-view-panel//wf-panel-header/div[contains(@class,"ui-view-panel-header-title")]
    ${main_view_title}    Get Text    ${element}
    [Return]    ${main_view_title}

SBTS WEM Select Plan On CA
    [Arguments]     ${plan_name}
	SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span[text()="${plan_name}"]


SBTS WEM Select Object On CA
    [Arguments]    ${object_name}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...   //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span[text()="${object_name}"]
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
	${selected_object_instance}    Selenium2Library.Get Text    //p-multiselect//div[2]/div
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
		${item}    Selenium2Library.Get Text    ${element}
		${selected_value}    Selenium2Library.Get Text
    ...    //div[@blockpanelcontent]//label[text()="${item}"]/..//p-dropdown//span[contains(@class,"p-dropdown-label")]
		Set To Dictionary    ${dic_param_value}    ${item}    ${selected_value}
    END
    [Return]    ${selected_object_instance}    ${dic_param_value}

Compare Additional Param Support Version With Current SW From Tag
    [Arguments]     ${tag}
    [Documentation]    Keyword used to deal with specific parameter that has tag (rel<=xx) or (rel >=xx). Compare current software
    ...    version and the version in tag. Return the actual comparation result
    ${current_release}    Set Variable    ${active_sw_version.split('_')[0].strip().replace('SBTS','')}
    ${cur_rel_y_num}    Set Variable    ${current_release.split('R')[0]}
    ${cur_rel_q_num}    Set Variable    ${current_release.split('R')[1]}
    ${formatted_tag}    Set Variable    ${tag.replace('(rel','').replace(')','').strip()}
    ${tag_release}    Should Match Regexp     ${formatted_tag}    \\w+
    ${tag_symbol}    Remove String    ${formatted_tag}    ${tag_release}
    ${tag_rel_y_num}    Set Variable    ${tag_release.split('R')[0]}
    ${tag_rel_q_num}    Set Variable    ${tag_release.split('R')[1]}
    ${compare_result}     Run Keyword If    ${cur_rel_y_num}==${tag_rel_y_num}
    ...    Run Keyword And Return Status    Should Be True    ${cur_rel_q_num} ${tag_symbol} ${tag_rel_q_num}
    ...    ELSE    Run Keyword And Return Status    Should Be True    ${cur_rel_y_num} ${tag_symbol} ${tag_rel_y_num}
    [Return]     ${compare_result}

SBTS WEM Get Parameters Of One Object
    [Arguments]    ${object}    ${parameter_full_name_list}    ${tree_name}=Current BTS configuration
    ${filter}    Fetch From Right    ${object}    /
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    Run Keyword If    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${filter}    ${tree_name}
    &{target_param_dic}    Create Dictionary
    FOR    ${parameter_full_name}    IN    @{parameter_full_name_list}
        ${full_name}    Fetch From Left    ${parameter_full_name}    (!)
        ${list_lable}    Fetch From Right    ${parameter_full_name}    (!)
        ${list_lable}    Set Variable If    '${list_lable}'!='${parameter_full_name}'    ${list_lable}    ${None}
        SBTS WEM Filt Parameter    form_param_name=${full_name}
        ${param_list}    SBTS WEM Get Parameters In PE Table
        Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${full_name}    ${list_lable}    ${param_list}
        Continue For Loop
        ${count}    Get Length    ${param_list}
        Run Keyword If    '${count}'!='${0}'    Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${full_name}    ${list_lable}
        ...    ${param_list}
        Continue For Loop If    '${count}'!='${0}'
        #Try to get parameter by Abbreviation again
        ${param_full_name_corrected}    SBTS WEM Get Parameter Name By Abbreviation    ${object}    ${parameter_full_name}
        SBTS WEM Filt Parameter    form_param_name=${param_full_name_corrected}
        ${param_list}    SBTS WEM Get Parameters In PE Table
        Set Parameter To Dictionary Matching By Name    ${target_param_dic}    ${param_full_name_corrected}    ${list_lable}    ${param_list}
    END
    [Return]    ${target_param_dic}

SBTS WEM Modify Parameters In PE Table
    [Arguments]    ${object}    ${param_name}    ${value}    ${sub_item_name}=${EMPTY}    ${tree_name}=Current BTS configuration
    [Documentation]    ${object} should be full path of object
    ...    ${param_name} should be full name of parameter
    ...    ${sub_item_name} should be the sub-item name of ${param_name}
    ...    if the input type is select list, ${value} should be the label text which need to be selected.
    ...    if the ${value} is !DELETE! , the parameter shall be deleted.
    ${is_delete}    Run Keyword And Return Status    Should Be Equal As Strings    ${value}    !DELETE!
    ${succeed}    Run Keyword If    ${is_delete}    SBTS WEM Click Action In PE Table    ${object}    ${param_name}    Delete parameter
    ...    ${sub_item_name}    ${tree_name}
    Return From Keyword If    ${is_delete}    ${succeed}
    ${succeed}    Set Variable    ${False}
    SBTS WEM Open Configuration Manager    PE
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    ${object_name}    Fetch From Right    ${object}    /
    Run Keyword If    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${object_name}    ${tree_name}
    Wait Until WebElement Exist    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    20s    2s
    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    ${param_name}
    Sleep    3s    Give seconds to WebUI for responding...
    ${row_x_path}    Set Variable
    ...    //parameters-editor-table-body/table//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    Return From Keyword If    '${row_count}'=='0'    ${succeed}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
        ${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
        ${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        ${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
        ${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
        ${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
        Continue For Loop If    '${full_name}'!='${param_name}'
        Continue For Loop If    '${sub_item_name}'!='' and '${sub_item_name}'!='${list_lable}'
        ${input_count}    Selenium2Library.Get Element Count
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//input
        ${select_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//select
        ${listbutton_count}    Selenium2Library.Get Element Count
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//wf-dropdown//button
        Continue For Loop If    '${input_count}'=='0' and '${select_count}'=='0' and '${listbutton_count}'=='0'
        ${planned_value_elements}    Set Variable If    '${input_count}'=='1'
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//input
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//select
        ${planned_value_elements}    Set Variable If    '${listbutton_count}'=='1'
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//wf-dropdown//button    ${planned_value_elements}
        ${att_disabled}    Selenium2Library.Get Element Attribute    ${planned_value_elements}    disabled
        ${succeed}    Set Variable If    '${att_disabled}'=='disabled' or '${att_disabled}'=='true'    ${True}    ${False}
        Continue For Loop If    '${att_disabled}'=='disabled' or '${att_disabled}'=='true'
        Run Keyword If    '${select_count}'=='1'    Select From List By Label    ${planned_value_elements}    ${value}
        ${succeed}    Set Variable If    '${select_count}'=='1'    ${True}    ${False}
        Exit For Loop If    ${succeed}
        Run Keyword If    '${listbutton_count}'=='1'    Select PE Table ButtonList By Value
        ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]//parameter-input//button    ${value}
        ${succeed}    Set Variable If    '${listbutton_count}'=='1'    ${True}    ${False}
        Exit For Loop If    ${succeed}
        Clear Element Text    ${planned_value_elements}
        Input Text    ${planned_value_elements}    ${value}
        Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
        ${succeed}    Set Variable    ${True}
    END
    [Return]    ${succeed}

SBTS WEM Status Bar Should Be Loaded Completed
    ${ret}    Set Variable    ${False}
    ${connection_status}    Get Text    //main-view//div[@status-bar]//connection-status
    Should Be Equal As Strings    ${connection_status}    Online
    Element Should Not Be Exist
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//span[contains(text(),"--")]
    ${tmp1}    Set Variable
    ...    //main-view//div[@status-bar]//div[contains(@class,"status-bar-bts-element")]//
    ${tmp2}    Set Variable   div[contains(@class,"status-bar-text-overflow") and contains(text(),"--")]
    Element Should Not Be Exist    ${tmp1}${tmp2}
    ${ret}    Set Variable    ${True}
    [Return]    ${ret}

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

Handle Insecure Warning From Chrome
    ${is_insecure}    Run Keyword And Return Status    Wait Until WebElement Exist    //body[contains(@class,"ssl")]
    Return From Keyword If    '${is_insecure}'!='${True}'
    ${is_hiden}    Selenium2Library.Get Element Attribute    //body//div[@id="details"]    class
    Run Keyword If    "hidden"=="${is_hiden}"    Click Button    id:details-button
    Wait Until Page Contains Element    //body//div[@id="details" and @class!="hidden"]//p[@id="final-paragraph"]/a[@id="proceed-link"]    5s
    Click Element    //body//div[@id="details" and @class!="hidden"]//p[@id="final-paragraph"]/a[@id="proceed-link"]
    Wait Until Page Contains Element    id:login-username    30s

SBTS WEM Expand Navigation Panel
    [Documentation]    Expand Navigation Panel on SBTS WEM, no-matter under which main-menu. Should logon SBTS WEM before this step.
    [Timeout]    1 minute
    ${is_expanded}    Run Keyword And Return Status    Element Should Not Be Exist    //ui-button[contains(@class,"gs-open-button")]
    Return From Keyword If    ${is_expanded}
    Comment    Wait Until WebElement Exist    //main-view[@class="ng-isolate-scope"]//div[@class="main-view"]
    Wait Until Element Is Visible    //global-search    10s
    Click Button    //ui-button[contains(@class,"gs-open-button")]/button
    ${object_tree_not_exist}    Run Keyword And Return Status    Element Should Not Be Exist
    ...    //global-search//wf-panel-section//li[contains(@class,'uib-tab nav-item ng-isolate-scope') and @heading="Objects"]
    Return From Keyword If    ${object_tree_not_exist}
    Wait Until Element Is Enabled
    ...    //global-search//wf-panel-section//li[contains(@class,'uib-tab nav-item ng-isolate-scope') and @heading="Objects"]    10s
    Click Element    //global-search//wf-panel-section//li[@heading="Objects"]/a
    Element Should Be Exist    //global-search//wf-panel-section//li[contains(@class,'active') and @heading="Objects"]

Element Should Not Be Exist
    [Arguments]    ${Xpath}
    ${count}    Selenium2Library.Get Element Count    ${Xpath}
    Should Be Equal As Integers    ${count}    ${0}

SBTS WEM Click Action In PE Table
    [Arguments]    ${object}    ${param_name}    ${action_name}    ${sub_item_name}=${EMPTY}    ${tree_name}=Current BTS configuration
    [Documentation]    ${object} should be full path of object
    ...    ${param_name} should be full name of parameter
    ...    ${action_name} should be the title of action button
    ...    ${sub_item_name} should be the sub-item name of ${param_name}
    ${succeed}    Set Variable    ${False}
    ${is_object_selected}    Run Keyword And Return Status    Wait Until Page Contains Element
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small    10s
    ${object_name}    Fetch From Right    ${object}    /
    Run Keyword If    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${object_name}    ${tree_name}
    Wait Until WebElement Exist    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    20s    2s
    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input    ${param_name}
    ${row_x_path}    Set Variable
    ...    //parameters-editor-table-body/table//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    Return From Keyword If    '${row_count}'=='0'    ${succeed}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
		${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
		${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
		${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
		${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
		${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
		Continue For Loop If    '${full_name}'!='${param_name}'
		Continue For Loop If    '${sub_item_name}'!='' and '${sub_item_name}'!='${list_lable}'
		${button_count}    Selenium2Library.Get Element Count
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
		Continue For Loop If    '${button_count}' == '0'
		${is_active}    Run Keyword And Return Status    Element Should Be Enabled
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
		Continue For Loop If    not ${is_active}
		Click Button    ${row_x_path}\[${row_index}\]/td[contains(@class,"parameter-action-buttons-cell")]//button[@ui-tooltip="${action_name}"]
		${succeed}    Set Variable    ${True}
    END
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    [Return]    ${succeed}

SBTS WEM Logon
    [Arguments]    ${url}    ${setup_param}=${True}    ${setup_value}=true    ${mode}=headless    ${browser}=chrome    ${skip_error}=${False}
    ...    ${user}=Nemuadmin    ${pwd}=nemuuser    ${open_new_window}=${True}    ${enable_fullscreen_mode}=${False}
    [Documentation]    Open Browser and logon SBTS WEM
    Log To Console    ${setup_param}
    Log To Console    ${setup_value}
    Log To Console    ${enable_fullscreen_mode}
    [Timeout]    10 minutes
    ${window_index}    SBTS WEM Accessing    ${url}    ${mode}    ${browser}    ${user}    ${pwd}
    ...    ${open_new_window}
    Wait Until Keyword Succeeds    60    5    SBTS WEM Status Bar Should Be Loaded Completed
    ${except_warning}    Run Keyword And Return Status    Wait Until WebElement Exist    //div[@uib-modal-transclude]    30s    3s
    Run Keyword If    '${skip_error}'=='False' and '${except_warning}'=='True'    Fail
    ${tmp1}    Set Variable    //div[@uib-modal-transclude]//button[contains(text(),"Confirm") or
    ${tmp2}    Set Variable    contains(text(),"Continue") or contains(text(),"OK") or contains(text(),"Yes")]
    ${btn_element}    Run Keyword If    ${except_warning}    Get WebElement    ${tmp1} ${tmp2}
    Run Keyword If    ${except_warning}    Click Button    ${btn_element}
#    Run Keyword If    ${setup_param}    SBTS WEM Set Detected HW    ${setup_value}
#    #Set WebEM session time out to max value
#    SBTS WEM Filt Parameter    webEMSessionLogoutTimer
#    ${para}    SBTS WEM Get Parameters In PE Table
#    ${count}    BuiltIn.Get Length    ${para}
#    Should Be Equal As Integers    ${count}    ${1}
#    ${para_value}    Set variable    ${para[0]["actual_value"]}
#    Run Keyword If    '${para[0]["actual_value"]}'!='${7200}'    SBTS WEM Modify Parameters In PE Table
#    ...    ${para[0]["object"]}    ${para[0]["full_name"]}    7200
#    SBTS WEM Validate Plan
#    Run Keyword If    '${para[0]["actual_value"]}'!='${7200}'    SBTS WEM Activate Plan
#    SBTS WEM Set WEM Lock Time    120
#    #add for BOAM_ET CB005809
#    Run Keyword If    ${enable_fullscreen_mode}    Run Keywords    Turn On Fullscreen Mode
#    ...    AND    Turn Off Fullscreen Mode
    [Return]    ${window_index}

Turn On Fullscreen Mode
    Element Should Be Visible    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    Click Element    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    ${check_fullscreen}    Execute Javascript    return document.fullscreen
    Should Be Equal    ${check_fullscreen}    ${True}
    Element Should Be Visible    //main-view//div[contains(@class,"ui-icon-svg ui-icon-normal-screen")]

Turn Off Fullscreen Mode
    Element Should Be Visible    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    Click Element    //*[@id="main-view"]/div/div[1]/app-header/div[2]/fullscreen-toggle/div/div/span/ui-icon/div
    ${check_fullscreen}    Execute Javascript    return document.fullscreen
    Should Be Equal    ${check_fullscreen}    ${False}
    Element Should Be Visible    //main-view//div[contains(@class,"ui-icon-svg ui-icon-full-screen")]


#SBTS WEM Set WEM Lock Time
#    [Arguments]    ${time_to_lock}=15
#    [Timeout]    2 minutes
#    SBTS WEM Open Option    Settings
#    Wait Until WebElement Exist
#    ...    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
#    Clear Element Text
#    ...    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
#    Input Text    //ng-view//wf-panel-section//settings//general-settings-tab//div[contains(@class,"screen-lock-interval")]//ui-text-input//input
#    ...    ${time_to_lock}
#    ${is_enable}    Run Keyword And Return Status    Element Should Be Enabled With Attribute
#    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button
#    Run Keyword If    ${is_enable}    SBTS WEM Click Button Or Element
#    ...    //ng-view//wf-panel-section//settings//execution-bar//ui-button[@a-text="Apply"]/button

SBTS WEM Logout
    FOR    ${time_step}    IN RANGE    ${0}    ${5}
		Sleep    3s
		Wait Until WebElement Exist    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
		${is_button_show}    Run Keyword And Return Status    Element Should Be Visible
    ...    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]//ui-button[@a-text="Logout"]/button
		Run Keyword If    ${is_button_show}    SBTS WEM Click Button Or Element
    ...    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]
		${is_succeed}    Run Keyword And Return Status    SBTS WEM Click Button Or Element
    ...    //main-view//app-header//div[@class="right-side"]//user-account-management/nav-item/div[@role="menu"]//ui-button[@a-text="Logout"]/button
		Exit For Loop If    ${is_succeed}
    END
    Run Keyword And Return Status    Wait Until Keyword Succeeds    5x    2s    Handle Insecure Warning From Chrome
    Wait Until Page Contains Element    id:login-username    10s

Select PE Table ButtonList By Value
    [Arguments]    ${button_xpath}    ${value}
    Comment    Click Button    ${button_xpath}
    SBTS WEM Click Button Or Element    ${button_xpath}
    ${count}    Selenium2Library.Get Element Count    ${button_xpath}/../ul[@aria-hidden="false"]/wf-dropdown-item/li/a/span[text()="${value}"]
    Run Keyword If    "${count}"=="${0}"    Click Button    ${button_xpath}
    #Some list shall show tips while first click, click it twice to make list shown
    Click Element    ${button_xpath}/../ul[@aria-hidden="false"]/wf-dropdown-item/li/a/span[text()="${value}"]

SBTS WEM Location Should Contain
    [Arguments]    ${expect}
    ${location}    Get Location
    Should Contain    ${location}    ${expect}

Check Button Status Before Install FCE
    ${dic_button_states}    Get Button States On CA Page
    Should Be True    ${dic_button_states['install_fce_states']}
    Should Be True    ${dic_button_states['select_plan_states']}
    Should Not Be True    ${dic_button_states['install_fct_states']}
    Should Not Be True    ${dic_button_states['select_feature_states']}
    Should Be Empty     ${dic_button_states['list_FCE_features']}

Get Button States On CA Page
    ${empty_list}    Create List
    ${dic_button_states}    Create Dictionary    select_feature_states=${false}    list_FCE_features=${empty_list}
    ${install_fce_states}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Enabled   //ot-upload[@id="install-fce"]//input
    ${install_fct_states}    Run Keyword And Return Status    Selenium2Library.Element Should Be Enabled    //ot-upload[@id="install-fct"]//input
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="selectPlan"]/div[contains(@class,"p-dropdown")]    class
    ${select_plan_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    install_fce_states=${install_fce_states}    install_fct_states=${install_fct_states}
    ...    select_plan_states=${select_plan_states}
    ${not_install_FCE}    Run Keyword And Return Status    Should Not Be True    ${install_fct_states}
    Return From Keyword If    ${not_install_FCE}    ${dic_button_states}
    ${atr}    Selenium2Library.Get Element Attribute    //p-dropdown[@id="feature"]/div[contains(@class,"p-dropdown")]    class
    ${select_feature_states}    Run Keyword And Return Status    Should Not Contain    ${atr}    p-disabled
    Set To Dictionary    ${dic_button_states}    select_feature_states=${select_feature_states}
    ${list_FCE_features}    Get FCE Feature List
    Set To Dictionary    ${dic_button_states}    list_FCE_features=${list_FCE_features}
    [Return]    ${dic_button_states}

Install FCE From WebEM CA
    [Arguments]      ${fce_path}
    ${msg}    Set Variable
    SBTS WEM Open Configuration Manager    CA
    Selenium2Library.Choose File    //span[contains(text(),'Install FCE')]/../input    ${fce_path}
    ${is_fail}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    //div[@role="dialog"]//span[contains(text(),"FCE installation failed")]    10s
    Return From Keyword If    '${is_fail}'=='False'    ${msg}
    ${msg}    Selenium2Library.Get Text    //div[@role="dialog"]//div[contains(@class,"p-dialog-content")]/blocks-installed-dialog/div
    Wait Element Visible And Click    //div[@role="dialog"]//div[contains(@class,"p-dialog-footer")]//button/span[contains(text(),'OK')]
    [Return]    ${msg}

Element Should Be Exist
    [Arguments]    ${Xpath}
    ${count}    Selenium2Library.Get Element Count    ${Xpath}
    Should Not Be Equal As Integers    ${count}    ${0}

Element Should Be Enabled With Attribute
    [Arguments]    ${xpath}    ${att_name}=disabled
    ${is_enabled}    Selenium2Library.Get Element Attribute    ${xpath}    ${att_name}
    Should Be True    "${is_enabled}"=="None"

SBTS WEM Select Feature On CA
    [Arguments]    ${feature_name}
    SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //p-dropdown[@id="feature"]//div[@role="button"]
    Wait Element Visible And Click    //p-dropdown[@id="feature"]//p-dropdownitem/li/span[text()="${feature_name}"]
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    ${objects}    Create List
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem/li/span
    FOR    ${element}    IN    @{elements}
		${item}    Selenium2Library.Get Text    ${element}
		Append To List    ${objects}    ${item}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    [Return]    ${objects}

Get Feature List From WebEM CA
    SBTS WEM Open Configuration Manager    CA
    Wait Element Visible And Click    //span[contains(text(),'<Select feature>')]
    ${es}    Selenium2Library.Get WebElements    //span[contains(text(),'<Select feature>')]/..//p-dropdownitem/li/span
    ${list_FCE_features}    Create List
    FOR    ${e}    IN    @{es}
		${item}    Selenium2Library.Get Text    ${e}
		Append To List    ${list_FCE_features}    ${item}
    END
    Collapse Dropdown List    //p-dropdown[@id="feature"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_FCE_features}

Wait Element Visible And Click
    [Arguments]    ${locator}    ${time_out}=20s
    Wait Until Element Is Visible    ${locator}    ${time_out}
    Wait Until Keyword Succeeds    10s    2s    Click Element    ${locator}

Collapse Dropdown List
    [Arguments]    ${xpath}
    ${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${xpath}
    Run Keyword If    ${is_expanded}    Selenium2Library.Click Element    ${xpath}
    Wait Until Element Is Not Visible    ${xpath}    3s

Get Plan Options From WebEM CA
    SBTS WEM Open Configuration Manager    CA
    ${current_plan}    Selenium2Library.Get Text    //p-dropdown[@id="selectPlan"]//div/span[contains(@class,"p-dropdown-label")]
    Wait Element Visible And Click    //p-dropdown[@id="selectPlan"]//div[@role="button"]
    ${plan_options}    Selenium2Library.Get WebElements    //p-dropdown[@id="selectPlan"]//p-dropdownitem/li/span
    ${list_plan}    Create List
    FOR    ${item}    IN    @{plan_options}
		${plan}    Selenium2Library.Get Text    ${item}
		Append To List    ${list_plan}    ${plan}
    END
    Collapse Dropdown List    //p-dropdown[@id="selectPlan"]//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_plan}    ${current_plan}

SBTS WEM Calculate On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Calculate"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

Get FCT Caculate Result
    Wait Until Element Is Visible    //blocks-configuration-automation-results/p-table[1]    30s
    Wait Until Element Is Visible    //blocks-configuration-automation-results/p-table[@id="nonNiddParameterTable"]
    ## Validation results
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-results/ot-instruction/div/div
    ${validate_th_list}    ${validation_result}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results/p-table[1]
    ## Additional (non-NIDD) output parameters
    ${addoutput_th_list}    ${add_output_param}    Get FCT Operation Result From GUI Table
    ...    //blocks-configuration-automation-results/p-table[@id="nonNiddParameterTable"]
    [Return]    ${result}    ${validate_th_list}    ${validation_result}    #${addoutput_th_list}    ${add_output_param}

Get FCT Operation Result From GUI Table
    [Documentation]    Help for getting different FCT operation result from html table element
    [Arguments]     ${xpath_table}
	${thead}    Selenium2Library.Get WebElements    ${xpath_table}//tr/th
    ${table_head_list}    Create List
    FOR    ${th}    IN    @{thead}
		${item}    Selenium2Library.Get Text    ${th}
		Append To List    ${table_head_list}    ${item}
    END
    ${tbody_tr}    Selenium2Library.Get WebElements    ${xpath_table}//tbody//tr
    ${row_count}    Get Length    ${tbody_tr}
    ${table_content}    Create List
    FOR    ${index}    IN RANGE    ${1}    ${row_count}+1
		${td_list}    Selenium2Library.Get WebElements    ${xpath_table}//tr[${index}]/td
		${column_dic_onerow}    Generate Column Dictionary For Row    ${table_head_list}    ${td_list}
		Append To List    ${table_content}    ${column_dic_onerow}
    END
    [Return]    ${table_head_list}    ${table_content}

Generate Column Dictionary For Row
    [Arguments]    ${table_head_list}    ${one_row_colunms}
    ${row_value}    Create Dictionary
    ${key_num}    Get Length    ${table_head_list}
    ${colunm_num}    Get Length    ${one_row_colunms}
    ${value}    Run Keyword If    '${key_num}'!='${colunm_num}' and '${colunm_num}'=='${1}'    Selenium2Library.Get Text    ${one_row_colunms[0]}
    Return From Keyword If    '${key_num}'!='${colunm_num}' and '${colunm_num}'=='${1}'    ${value}
    FOR    ${index}    IN RANGE    ${0}    ${key_num}
		${value}    Selenium2Library.Get Text    ${one_row_colunms[${index}]}
		Set To Dictionary    ${row_value}    ${table_head_list[${index}]}=${value}
    END
    [Return]    ${row_value}

SBTS WEM Apply All On CA
    Wait Element Visible And Click    //blocks-configuration-automation-apply//button/span[text()="Apply All"]
    Wait Until Element Is Visible    //blocks-configuration-automation-apply//ot-instruction//span
    ${result}    Selenium2Library.Get Text    //blocks-configuration-automation-apply//ot-instruction//span
    [Return]     ${result}

SBTS WEM Audit On CA Page And Get Results
    Wait Element Visible And Click    //cem-operation-button//button/span[text()="Audit"]
    ${result}    ${table_head_list}    ${validation_result}    Get FCT Caculate Result
    [Return]    ${result}    ${table_head_list}    ${validation_result}

SBTS WEM Save Audit Report On CA
    [Arguments]    ${target_path}
    ${output_before}    OperatingSystem.Run    sudo ls -l Audit_report_*csv
    ${files_before}    Split To Lines    ${output_before}
    Wait Element Visible And Click    //div[contains(@class,'cem-block-panel-header')]/span[text()='Results']/..//span[text()='Save Audit Report']
    Sleep    5s
    ${output_after}    OperatingSystem.Run    sudo ls -l Audit_report_*csv
    ${files_after}    Split To Lines    ${output_after}
    Remove Values From List    ${files_after}    @{files_before}
    ${file_count}    Get Length    ${files_after}
    Should Be Equal As Integers    ${file_count}    1
    ${file_list}    Split String    ${files_after[0]}
    ${audit_report_filename}    Set Variable    ${file_list[-1]}
    ${audit_report_size}    Get File Size    ${audit_report_filename}
    Should Be True    ${audit_report_size}>0
    Copy File    ${audit_report_filename}    ${target_path}
    [Return]    ${audit_report_filename}

Compare And Apply Success And Check Result On CA
    Wait Element Visible And Click     //blocks-configuration-automation-apply//button/span[text()='Compare And Apply']
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//div[contains(@class,"ot-dialog-title") and text()=' Compare And Apply']
    Element Should Not Be Exist    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    Wait Element Visible And Click    //ot-dialog[@id='compareAndApply']//button/span[text()="Apply All"]
    Sleep    5s
    Wait Until Element Is Visible    //ot-dialog[@id='compareAndApply']//p-button[@disabled='true']//span[text()="Apply All"]
    ${apply_result}    Selenium2Library.Get Text
    ...    //ot-dialog[@id='compareAndApply']//div[@class="cem-operation-button"]//span[text()="Apply All"]/../../..//div/span
    Should Be Equal As Strings    ${apply_result}    Success
    ${count_row}    Selenium2Library.Get Element Count
    ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr
    FOR    ${r}    IN RANGE    ${1}    ${count_row}
		${cur_val}    Selenium2Library.Get Text
    ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[2]
		${recomm_val}   Selenium2Library.Get Text
    ...    //ot-dialog[@id='compareAndApply']//div[contains(@class,"p-treetable-scrollable-body")]//tr[${r}]/td[3]
		Should Be Equal As Strings    ${cur_val.strip()}    ${recomm_val.strip()}
    END
    Wait Element Visible And Click    //ot-dialog[@id='compareAndApply']//div[contains(@class,'p-dialog-footer')]//span[text()='Close']

SBTS WEM Validate Plan
    [Arguments]    ${timeout}=60s
    Log To Console    ${timeout}
    LOG    SBTS WEM Validate Plan    console=${True}
    SBTS WEM Open Configuration Manager    PE
    Wait Until WebElement Exist    //ng-view//revalidate-action-button    30s    3s
    Wait Until Keyword Succeeds    30s    5s    Element Should Be Enabled With Attribute    //ng-view//revalidate-action-button
    Click Button    //ng-view//revalidate-action-button//button
    Wait Until WebElement Exist    //loading-screen//div[@id="loading-screen" and @aria-hidden="false"]    3s    1s
    Wait Until WebElement Exist    //loading-screen//div[@id="loading-screen" and @aria-hidden="true"]

SBTS WEM Activate Plan
    [Arguments]    ${forced_activate}=${False}    ${download_only}=${False}    ${timeout}=600    ${wait_until_finish}=${True}
    ...    ${reset_list}=${None}
    LOG    SBTS WEM Activate Plan    console=${True}
    SBTS WEM Open Configuration Manager    ${None}
    Wait Until WebElement Exist    //ng-view//deploy-action-button    10s    1s
    ${warning_msg}    Set Variable
    ${is_enabled}    Selenium2Library.Get Element Attribute    //ng-view//deploy-action-button//button    disabled
    ${tips}    Selenium2Library.Get Element Attribute    //ng-view//deploy-action-button//ui-button    a-title
    Should Be True    "${is_enabled}"=="None"    ${tips}
    Return From Keyword If    "${is_enabled}"!="None"    ${tips}
    #While KW called in tear down, assertion shall not break off KW. Return forwardly to save time.
    Click Button    //ng-view//deploy-action-button//button
    Wait Until WebElement Exist    //deploy-plan-modal-component    10s    1s
    ${is_pass}    ${input}    Run Keyword And Ignore Error    Get WebElements    //deploy-plan-modal-component//label
    Run Keyword If    ${download_only}    Select Checkbox    ${input[0]}
    ${count}    Get Length    ${input}
    ${is_pass}    Set Variable If    ${count} > 0    PASS    FAIL
    ${is_forced_enable}    Evaluate    ${count} > 1
    Run Keyword If    ${forced_activate} and ${is_forced_enable}    Select Checkbox    ${input[1]}
    ${is_enabled}    Run Keyword And Return Status    Element Should Be Enabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    Should Be True    ${is_enabled}    Excute button is not enabled
    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button    #click excute button to start activation
    ${tex}    Run Keyword If    ${is_forced_enable}    Get Text    //deploy-plan-modal-component//label[1]
    Run Keyword If    "${is_pass}"=="PASS"    Wait Until Keyword Succeeds    30x    1s    Element Should Be Disabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    Run Keyword If    ${reset_list}    Wait Until Element Is Enabled
    ...    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button    90s
    ${warning_msg}    Run Keyword If    ${reset_list}    Get Text
    ...    //deploy-plan-modal-component//div[@class="feedback-section"]//i[contains(@class,"icon-warning")]/../span
    Run Keyword If    ${reset_list}    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Execute"]//button
    #Double check while delta commission will cause any reset.
    Return From Keyword If    not ${wait_until_finish}    ${warning_msg}
    Wait Until Keyword Succeeds    ${timeout}    10s    Element Should Contain    //deploy-plan-modal-component//div[@class="feedback-section"]
    ...    Operation finished successfully
    SBTS WEM Close BTS StartUp View    3s
    Comment    Click Button    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button    #click close button to close pop-up window
    SBTS WEM Click Button Or Element    //deploy-plan-modal-component//ui-button[@a-text="Close"]//button
    ...    KW_checker=Wait Until WebElement Not Exist    param_checker=//deploy-plan-modal-component
    [Return]    ${warning_msg}

Wait Until WebElement Not Exist
    [Arguments]    ${xpath}    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Not Be Exist    ${xpath}


SBTS WEM Close BTS StartUp View
    [Arguments]    ${timeout}=60s
    ${is_pop}    Run Keyword And Return Status    Wait Until WebElement Exist
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button    ${timeout}    1s
    Run Keyword If    ${is_pop}    SBTS WEM Click Button Or Element
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button    3    3s    Wait Until WebElement Not Exist
    ...    //ui-modal[@a-title="BTS Start-up View"]//ui-button[@a-text="Close"]/button


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

SBTS WEM Click All Notify Messages
    [Documentation]    Click all the notify pops-up of SBTS WebEM at the moment this KW is called.
    ${count}    Selenium2Library.Get Element Count    //div[contains(@class,"notifyjs-corner")]//i[contains(@class,"notify-icon")]
    Return From Keyword If    "${count}"=="0"
    ${elements}    Get WebElements    //div[contains(@class,"notifyjs-corner")]//i[contains(@class,"notify-icon")]
    ${ret}    Set Variable    ${True}
    FOR    ${elemet}    IN    @{elements}
		Run Keyword And Return Status    Click Element    ${elemet}
    END
    [Return]    ${ret}

Check If Object Selected On Navigation Panel Under Pramater Editor
    [Arguments]    ${object}
    ${is_object_selected}    Run Keyword And Return Status    Wait Until WebElement Exist
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small    10s    1s
    ${selected_object}    Run Keyword If    ${is_object_selected}    Get Text
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    ${is_object_selected}    Run Keyword And Return Status    Should Be Equal As Strings    ${selected_object}    ${object}
    [Return]    ${is_object_selected}

SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    [Arguments]    ${object_path}    ${filter}    ${tree_name}=Current BTS configuration
    # ${object_path} is fuzzy matching, can be part of the whole object path
    SBTS WEM Open Configuration Manager    PE
    ${elements}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    ${filter}    ${tree_name}
    ${key}    Set Variable    ${EMPTY}
    ${bool}    Run Keyword And Return Status    Dictionary Should Contain Key    ${elements}    ${object_path}
    ${key}    Set Variable If    ${bool}    ${object_path}    ${EMPTY}
    ${keys}    Get Dictionary Keys    ${elements}
    FOR    ${k}    IN    @{keys}
        Exit For Loop If    ${bool}
        ${bool}    Run Keyword And Return Status    Should Contain    ${k}    ${object_path}
        ${key}    Set Variable If    ${bool}    ${k}    ${EMPTY}
    END
    ${object}    Get From Dictionary    ${elements}    ${key}
    Call Method    ${object}    click
    ${full_object_path}    Set Variable    ${key}
    Wait Until WebElement Exist    //global-search//li[contains(@class,"active")]//ui-button    10s    1s
    [Return]    ${full_object_path}

SBTS WEM Filt Object On Navigation Panel Under Pramater Editor
    [Arguments]    ${filter}    ${tree_name}=Current BTS configuration
    [Documentation]    Filt objet on Navigation Panel under paramter editor in Configuration Manager. Should logon SBTS WEM before.
    ...    Return dictionary with object path as key and webelement as value of objects.
    Should Not Be Equal As Strings    ${filter.strip()}    ${EMPTY}
    &{titles_elements}    create Dictionary
    SBTS WEM Open Configuration Manager    PE
    SBTS WEM Expand Navigation Panel
    wait until keyword succeeds    30    3s    element should be visible    //pe-global-search-filter//input
    Clear Element Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    Clear Element Text    //pe-global-search-filter//input
    input text    //pe-global-search-filter//input    ${filter}
    Sleep    3s    #give seconds to WebEM for responding
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor    ${tree_name}
    ${count}    Selenium2Library.Get Element Count    //global-search//li//span[contains(@aria-label,'${filter}')]
    Return From Keyword If    '${count}'=='0'    ${titles_elements}
    ${object_list}    Get Webelements    //global-search//li//span[contains(@aria-label,'${filter}')]
    FOR    ${object}    IN    @{object_list}
		Call Method    ${object}    click
		wait until keyword succeeds    3x    1s    element should be visible
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
		${object_path}    Get Text
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
		Set To Dictionary    ${titles_elements}    ${object_path}=${object}
    END
    [Return]    ${titles_elements}


SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    [Arguments]    ${tree_name}=Current BTS configuration
    [Documentation]    ${tree_name} can be one of "Current BTS configuration",
    ...    "Planned BTS configurations" and "Inactive BTS configurations" which can be visble under object tab.
    SBTS WEM Open Configuration Manager    PE
    SBTS WEM Expand Navigation Panel
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
    ${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")]
    ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
    FOR    ${index}    IN RANGE    1    ${count}+1
		${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
		${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")]
		${tmp3}    Set Variable    [${index}]//div[@class="ui-expandable-panel-header"]
		${is_enable}    Selenium2Library.Get Element Attribute    ${tmp1}${tmp2}${tmp3}    aria-disabled
		Continue For Loop If    '${is_enable}'=='true'
		${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]
		${tmp2}    Set Variable    /div[contains(@class,"tree-list-grouping-renderer")][${index}]//ui-expandable-panel-header
		${title}    Get Text    ${tmp1}${tmp2}
		${ret}    Set Variable If    '${title}'=='${tree_name}'    ${True}    ${False}
		${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]
		${tmp2}    Set Variable    /div[contains(@class,"tree-list-grouping-renderer")][${index}]//div[contains(@class,"ui-expandable-panel-body")]
		${is_expanded}    Run Keyword And Return Status    Element Should Be Visible    ${tmp1}${tmp2}
		Continue For Loop If    '${ret}'=='${is_expanded}'
		${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//
		${tmp2}    Set Variable    div[@class="tree-list-body"]/div[contains(@class,"tree-list-grouping-renderer")][${index}]//
		${tmp3}    Set Variable    div[@class="ui-expandable-panel-header"]//ui-expandable-panel-header
		Click Element    ${tmp1}${tmp2}${tmp3}
    END
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]/
    ${tmp2}    Set Variable    div[contains(@class,"tree-list-grouping-renderer")]//div[contains(@class,"ui-expandable-panel-body")]
    ${count}    Selenium2Library.Get Element Count    ${tmp1}${tmp2}
    ${tmp1}    Set Variable    //global-search//global-search-tab-content/pe-global-search-objects//div[@class="tree-list-body"]/
    ${tmp2}    Set Variable    div[contains(@class,"tree-list-grouping-renderer")]//div[contains(@class,"ui-expandable-panel-body")]
    Run Keyword If    "${count}"!="${0}"    Click Element    ${tmp1}${tmp2}


SBTS WEM Filt Parameter
    [Arguments]    ${toolbar_filter}=${None}    ${form_param_name}=${None}    ${form_abbreviation}=${None}
    ...    ${form_status_option}=default    ${form_status_show}=default
    [Documentation]    ${form_status_option} should be one of 'all','mandatoryOnly','optionalOnly'
    SBTS WEM Open Configuration Manager
    Wait Until WebElement Exist    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input    30s    3s
    Clear Element Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    Sleep    2s
    Run Keyword If    '${toolbar_filter}' == 'None'    Input Text    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input
    ...    ${toolbar_filter}
    Press Keys    //ng-view//pe-toolbar//ui-text-input[@a-type="search"]//input    ${\n}    #press ENTER of keyboard
    ${is_parameter_tatble_load}    Run Keyword And Return Status    Wait Until Page Contains Element    //parameters-editor-table-header    10s
    Return From Keyword If    not ${is_parameter_tatble_load}
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    Run Keyword If    '${form_param_name}' == 'None'    Input Text    //parameters-editor-table-header//th[@class="pe-full-name-cell"]/input
    ...    ${form_param_name}
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input
    Run Keyword If    '${form_abbreviation}' == 'None'    Input Text
    ...    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input    ${form_abbreviation}
    Run Keyword If    '${form_status_option}'=='default'    Run Keywords    Click Button
    ...    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    ...    AND    Click Element    //input[@type='radio' and @name='pe-filter-radio' and @value='${form_status_option}']/..
    ...    AND    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    Return From Keyword If    '${form_status_show}'=='default'
    ${len}    Get Length    ${form_status_show}
    Should Be Equal As Integers    ${4}    ${len}    form_status_show should a be 4 bit binary string or 'default' but was '${form_status_show}'
    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    Run Keyword If    '${form_status_show[0]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-modified']/..
    Run Keyword If    '${form_status_show[1]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-invalid']/..
    Run Keyword If    '${form_status_show[2]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-existing']/..
    Run Keyword If    '${form_status_show[3]}'=='1'    Click Element    //input[@type='checkbox' and @id='pe-filter-non-existing']/..
    Click Button    //parameters-editor-table-header//th[@class="pe-info-cell"]//button[@class="table-parameter-search"]
    [Teardown]    Sleep    1s    # Give a second to the WebUI for responding

SBTS WEM Get Parameters In PE Table
    [Documentation]    Should filter parameter or select object before calling this keyword
    @{parameters}    Create List
    ${table_x_path}    Set Variable    //parameters-editor-table-body/table
    ${is_table_exist}    Run Keyword And Return Status    Wait Until WebElement Exist    ${table_x_path}    20s    1s
    Return From Keyword If    not ${is_table_exist}    ${parameters}
    ${row_x_path}    Set Variable    ${table_x_path}//tbody/tr[contains(@class,"row-existing") or contains(@class,"row-non-existing")]
    ${row_count}    Selenium2Library.Get Element Count    ${row_x_path}
    ${full_name}    Set Variable
    FOR    ${row_index}    IN RANGE    1    ${row_count}+1
		${attribute_class}    Selenium2Library.Get Element Attribute    ${row_x_path}\[${row_index}\]    class
		${is_param_not_configured}    Run Keyword And Return Status    Should Contain    ${attribute_class}    row-non-existing
		${col_full_name_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]
		${col_list_lable_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
		${actual_value_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-actual-value-cell")]
		${abbreviation_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-abbreviation-cell")]
		${object_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]/div
		${plan_value_count}    Selenium2Library.Get Element Count    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]
		${cur_full_name}    Run Keyword If    '${col_full_name_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]//highlighter
		${full_name}    Set Variable If    '${cur_full_name}'=='None'    ${full_name}    ${cur_full_name}
		${list_lable}    Run Keyword If    '${col_list_lable_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-list-label-cell")]
		${abbreviation}    Run Keyword If    '${abbreviation_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-abbreviation-cell")]//highlighter/span
		${actual_value}    Run Keyword If    '${actual_value_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-actual-value-cell")]//highlighter/span
		${actual_value}    Set Variable If    ${is_param_not_configured}    !DELETE!    ${actual_value}
		${object}    Run Keyword If    '${object_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-full-name-cell")]/div
		${plan_value}    Run Keyword If    '${plan_value_count}'=='1'    Get Text
    ...    ${row_x_path}\[${row_index}\]/td[contains(@class,"pe-value-cell")]
		&{parameter}    Create Dictionary
		Set To Dictionary    ${parameter}    full_name    ${full_name}
		Set To Dictionary    ${parameter}    list_lable    ${list_lable}
		Set To Dictionary    ${parameter}    abbreviation    ${abbreviation}
		Set To Dictionary    ${parameter}    actual_value    ${actual_value}
		Set To Dictionary    ${parameter}    object    ${object}
		Set To Dictionary    ${parameter}    plan_value    ${plan_value}
		Append To List    ${parameters}    ${parameter}
    END
    ${object_count}    Selenium2Library.Get Element Count
    ...    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    Return From Keyword If    '${object_count}'=='0'    ${parameters}
    ${object}    Get Text    //ng-view//wf-panel-section//parameters-editor//div[contains(@class,"pe-middle-panel-header-inner-margin")]//small
    FOR    ${param}    IN    @{parameters}
		Set To Dictionary    ${param}    object    ${object}
    END
    [Return]    ${parameters}


SBTS WEM Accessing
    [Arguments]    ${url}    ${mode}=headless    ${browser}=chrome    ${user}=Nemuadmin    ${pwd}=nemuuser    ${open_new_window}=${True}
    ${options}    Run Keyword If    "${open_new_window}"=="${True}"    Chrome Set Headless Mode    ${mode}
    Comment    Run Keyword If    "${IS_VIRTAUL_DISPLAYED}"=="${True}" and "${open_new_window}"=="${True}"    Start Virtual Display
    ${window_index}    Run Keyword If    "${open_new_window}"=="${True}"    open browser    ${url}    ${browser}    options=${options}
    Selenium2Library.Set Window Size    1600    1200
    Wait Until Keyword Succeeds    5x    2s    Handle Insecure Warning From Chrome
    Wait Until Page Contains Element    id:login-username
    ${is_option_expanded}    Run Keyword And Return Status    Element Should Be Visible    id:Port
    Run Keyword If    ${is_option_expanded}    Click Element    //span[text()="Options"]
    Run Keyword If    ${is_option_expanded}    Wait Until Element Is Visible    id:Port
    Clear Element Text    id:login-username
    Input Text    id:login-username    ${user}
    Input Text    id:login-password    ${pwd}
    Clear Element Text    id:Port
    Input Text    id:Port    443
    Click Button    //button/span[text()="Login"]/../../button
    [Return]    ${window_index}

Chrome Set Headless Mode
    [Arguments]    ${mode}=headless
    Return From Keyword If    '${mode}'!='headless'    ${None}
    ${chrome_options}    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --headless
    Call Method    ${chrome_options}    add_argument    --disable-gpu
    Call Method    ${chrome_options}    add_argument    --no-sandbox
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome_options}    add_argument    --disable-setuid-sandbox
    Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
    Comment    ${options}    Call Method    ${chrome_options}    to_capabilities
    [Return]    ${chrome_options}

Set Parameter To Dictionary Matching By Name
    [Arguments]    ${target_param_dic}    ${full_name}    ${list_lable}    ${param_list}
    FOR    ${param_dic}    IN    @{param_list}
        ${is_match}    Evaluate    "${param_dic['full_name']}"=="${full_name}" and "${param_dic['list_lable']}"=="${list_lable}"
        ${name}    Set Variable If    '${param_dic['list_lable']}'=='None'
        ...    ${param_dic['full_name']}    ${param_dic['full_name']}(!)${param_dic['list_lable']}
        Run Keyword If    ${is_match}    Set To Dictionary    ${target_param_dic}    ${name}=${param_dic['actual_value']}
        Exit For Loop If    ${is_match}
    END

SBTS WEM Get Parameter Name By Abbreviation
    [Arguments]    ${object}    ${abbreviation_name}    ${tree_name}=Current BTS configuration
    ${filter}    Fetch From Right    ${object}    /
    ${is_object_selected}    Check If Object Selected On Navigation Panel Under Pramater Editor    ${object}
    Run Keyword If    ${is_object_selected}    SBTS WEM Select Object On Navigation Panel Under Pramater Editor
    ...    ${object}    ${filter}    ${tree_name}
    SBTS WEM Filt Parameter    form_abbreviation=${abbreviation_name}
    ${param_list}    SBTS WEM Get Parameters In PE Table
    ${count}    Get Length    ${param_list}
    Should Be Equal As Integers    ${count}    ${1}    More then one or none parameter is mapped by ${abbreviation_name} of ${object}
    ${parameter_name}    Set Variable    ${param_list[0]['full_name']}
    [Return]    ${parameter_name}

Wait Until WebElement Exist
    [Arguments]    ${xpath}    ${timeout}=60s    ${interval}=5s
    Wait Until Keyword Succeeds    ${timeout}    ${interval}    Element Should Be Exist    ${xpath}

Get All Additional Param Value And Object Instance
    [Arguments]    ${object_name}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button"]
    Wait Element Visible And Click
    ...    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//p-dropdownitem//span[text()="${object_name}"]
    ${dic_param_value}    Create Dictionary
    ${elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[contains(@class,"p-element")]
    FOR    ${element}    IN    @{elements}
        ${param}    Selenium2Library.Get Text    ${element}
        ${has_tag}    ${tag}    Run Keyword And Ignore Error
        ...    Should Match Regexp    ${param}    \\(rel \\>=\\w+\\)|\\(rel \\<=\\w+\\)|\\(rel \\<\\w+\\)|\\(rel \\>\\w+\\)|\\(rel \\=\\w+\\)
        ${compare_result}    Run Keyword If    '${has_tag}'=='PASS'
        ...    Compare Additional Param Support Version With Current SW From Tag     ${tag}
        Continue For Loop If    '${has_tag}'=='PASS' and '${compare_result}'!='True'
        ${list_value}    Get Values Of Param On AC    ${param}
        Set To Dictionary    ${dic_param_value}    ${param}    ${list_value}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
	Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-multiselect//span
	${sub_obj_list}    Create List
    ${elements}    Selenium2Library.Get WebElements    //p-multiselectitem
    FOR    ${element}    IN    @{elements}
		${obj}    Selenium2Library.Get Text    ${element}
		Append To List    ${sub_obj_list}    ${obj}
    END
    Selenium2Library.Click Element    //div[@blockpanelcontent]//label[text()="Objects:"]/..//p-multiselect//span
    [Return]    ${sub_obj_list}    ${dic_param_value}

Get Values Of Param On AC
    [Arguments]    ${param}
    Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
    Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${value_elements}    Selenium2Library.Get WebElements    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
    ${list_value}    Create List
    FOR    ${element}    IN    @{value_elements}
		${value}    Selenium2Library.Get Text    ${element}
		Append To List    ${list_value}    ${value}
    END
    Collapse Dropdown List    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button" and @aria-expanded="true"]
    [Return]    ${list_value}

Set Param Value Of Feature Object
    [Arguments]     ${dic_value_to_set}
    ${params}    Get Dictionary Keys    ${dic_value_to_set}
    FOR    ${param}    IN    @{params}
		${value_to_set}    Get From Dictionary    ${dic_value_to_set}    ${param}
		Wait Element Visible And Click    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//div[@role="button"]
		Wait Until Element Is Visible    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span
		Run Keyword If    '${value_to_set}'!=''    Selenium2Library.Click Element
    ...    //div[@blockpanelcontent]//label[text()="${param}"]/..//p-dropdown//p-dropdownitem//span[text()="${value_to_set}"]
    END


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