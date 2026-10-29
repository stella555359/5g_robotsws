*** Settings ***
Documentation
...   Robot resource to handle webUi interaction.
...   author: Abderrahmane NEZROUK
...   contact: abderrahmane.nezrouk@nokia.com
...   Updated 21/12/2020 add Set Multiples Parameters Values
...   To work this library need Global or test Suite Variable ${GNB_Architecture}=Cloud(coam)/Classical
...   Updated 05/05/2021 add optional global cmd line variable enable_virtual_display
...   ${enable_virtual_display} is an optional command line variable it can set to False to disable virtual display
...   for debug purpose (Exp --variable enable_virtual_display:False).

#Deprecated Library taf.ul.oam.selenium_coam replaced by taf.selenium.gnb.oam.coam.classical
#Library     taf.ul.oam.selenium_coam   WITH NAME    selenium_coam

Library     taf.selenium.gnb.oam.coam.classical     WITH NAME    selenium_coam
Library     taf.gnb.oam.coam.admin                  WITH NAME    coam_admin

*** Keywords ***
Load and Activate BTS Software Package localy
    [Arguments]    ${file_path}    ${falg_to_check}    ${timeout}=60
    [Documentation]    this keyword use webUI to update BSR or Software pakage.
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout

    Selenium Login
    # loading software package from local drive in ‘Software Update’ page
    ${rtype}    selenium_coam.load_software_package_from_local_drive     file_path=${file_path}    timeout=${timeout}
    Log      ${rtype}
    # Activate software after download  timeout (int) – int, time to wait software update, default is 30 second
    #selenium_coam.software_update    is_activate=True    timeout=30
    selenium_coam.software_update    timeout=30
    Wait Until Keyword Succeeds    360s    10s    Check Software Update Procession    ${falg_to_check}
    [Return]     ${rtype}

Check Software Update Procession
    [Arguments]    ${falg_to_check}
    ${flag}    selenium_coam.check_software_update_progress
    Log    ${flag}
    Should be equal    ${flag["status"]}    ${falg_to_check}

Set Parameter Value
    [Arguments]    ${distname}    ${param_name}    ${value_to_set}    ${filter_param}    ${timeout}=60
    [Documentation]    this keyword use webUI to set the parameter value
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout

    Selenium Login
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${filter_param}    abbr=${param_name}
    ...     new_value=${value_to_set}
    Validate and Activate plan    timeout=${timeout}

Set Multiples Parameters Values
    [Arguments]    ${params_distname_dict}    ${params_values_dict}    ${filters_params_dict}    ${timeout}=60
    [Documentation]    this keyword use webUI to set the multiple parameter value
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout

    Selenium Login
    ${keys}=    Set variable    ${params_values_dict.keys()}
    :FOR    ${param_name}   IN    @{keys}
    \     selenium_coam.set_parameter_value    dist_name=${params_distname_dict["${param_name}"]}
    ...    filter_param=${filters_params_dict["${param_name}"]}    abbr=${param_name}
    ...    new_value=${params_values_dict["${param_name}"]}
    \     sleep    2s

    Validate and Activate plan    timeout=${timeout}

Set Parameters Values with distnames
    [Arguments]    ${params_distname_dict}    ${filters_params_dict}    ${timeout}=60
    [Documentation]    this keyword use webUI to set the multiple parameter value
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout

    Selenium Login
    ${distnames}=    Set variable    ${params_distname_dict.keys()}
    :FOR    ${distname}   IN    @{distnames}
    \     ${dict_values}     Set Variable      ${params_distname_dict["${distname}"]}
    \     Update Parameters Values      ${distname}    ${dict_values}     ${filters_params_dict}

    Validate and Activate plan    timeout=${timeout}

Update Parameters Values
    [Arguments]       ${distname}    ${dict_values}     ${filters_params_dict}
    :FOR    ${key}   IN    @{dict_values.keys()}
    \       selenium_coam.set_parameter_value    dist_name=${distname}
    ...    filter_param=${filters_params_dict["${key}"]}    abbr=${key}
    ...    new_value=${dict_values["${key}"]}
    \     sleep    2s

Set Wrong Parameter Value and Get Error Message
    [Arguments]    ${distname}    ${param_name}    ${value_to_set}    ${filter_param}
    [Documentation]    this keyword use webUI to set the multiple parameters values
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout

    Selenium Login

    ${bts_id}    selenium_coam.get_bts_id
    selenium_coam.set_parameter_value    dist_name=${distname}    filter_param=${filter_param}    abbr=${param_name}
    ...    new_value=${value_to_set}
    sleep    8s
    ${error_msg}=    selenium_coam.get_error_info_after_set_parameter
    # selenium_coam.activate_plan    activate_plan_despite_errors=True
    # selenium_coam.check_activate_plan_status
    sleep    5s
    # Selenium logout
    [return]    ${error_msg}


Get Parameter Value Of
    [Arguments]    ${distname}    ${abbr}    ${filter_param}
    [Documentation]    this keyword use webUI to check the parameter value
    ...    Author: A.NEZROUK
    [Teardown]      Run Keyword and Ignore Error    Selenium Logout
    Selenium Login

    ${bts_id}    selenium_coam.get_bts_id
    ${param_value}=    selenium_coam.get_parameter_value    dist_name=${distname}    filter_param=${filter_param}
    ...    abbr=${abbr}
    # Selenium Logout
    [return]    ${param_value}

Selenium Login
    [Documentation]    this keyword is used to login to webUI
    ...    Author: A.NEZROUK
    [Arguments]     ${browser}=Firefox

    ${WEBUI_COAM}=    Set Variable If   '${GNB_Architecture}' == 'CLOUD'
    ...                   https://192.168.255.129/#/login
    ...                   https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/#/login

    ${WEBUI_NAME}=    Set Variable    ${tl.gnbs[0].cu.oam_http_connection_details.username}
    ${WEBUI_PWD}=     Set Variable    ${tl.gnbs[0].cu.oam_http_connection_details.password}

    ${enable_virtual_display}=    Get Variable Value    ${enable_virtual_display}    True
    Run keyword If    '${enable_virtual_display}'=='True'
    ...   selenium_coam.enable_virtual_display

    Log     ${WEBUI_COAM} ${WEBUI_NAME} ${WEBUI_PWD} browser
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}     browser=${browser}

Selenium Logout
    [Documentation]    this keyword is used to ensure webUI session deconnexion
    ...    Author: A.NEZROUK
    selenium_coam.logout
    ${enable_virtual_display}=    Get Variable Value    ${enable_virtual_display}    True
    Run keyword If    '${enable_virtual_display}'=='True'
    ...   selenium_coam.disable_virtual_display
    selenium_coam.close_browser

Validate and Activate plan
    [Arguments]      ${timeout}=60
    selenium_coam.validate_plan    timeout=10
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=${timeout}
    sleep    5s
