*** Settings ***
Documentation
...  The purpose of this test case is to check SFP diagnostic data of DWDM self-tunable transceiver module from WebEM

Library           taf.selenium.sbts  WITH NAME  selenium_coam

*** Variables ***
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password
@{ST_SFP}        ${EMPTY}                    # sfp dn list; example: RMOD-10(FRHG)/OPT_IF1;

*** Keywords ***
TC__SiSo_PM_Diagnostic_DWDM_self-tunable_SFP_monitoring_from_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28061
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is to check SFP diagnostic data of DWDM self-tunable transceiver module from WebEM
    ...  Only SFP provided by @{ST_SFP} is verified under "SFP Monitoring" in ADMIN, several sfps can be testet in TC
    ...  Convention for adding @{ST_SFP} ex. RMOD-10(FRHG)/OPT_IF1
    ...  TC is checking sfps from both sides (BB <-> RMOD) but only sfps from RMOD side need to be provided in @{ST_SFP}
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 04.05.2023 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-28061 - Initial creation

    Set Tags    CA-REC    OWNER-daniel.bartkowiak@nokia.com    AUTHOR-daniel.bartkowiak@nokia.com
    ...    MAINTAINER-daniel.bartkowiak@nokia.com    PHASE-CRT
    ...    FEATURE-CB006519-SR

    SiSo_PM_Diagnostic_DWDM_self-tunable_SFP_monitoring_from_WebEM.Preconditions
    step1: Get Parameters from SFP Monitoring
    step2: Static Parameters Inspection
    step3: Dynamic Parameters Inspection
    SiSo_PM_Diagnostic_DWDM_self-tunable_SFP_monitoring_from_WebEM.Postconditions

    [Teardown]  Run Keywords  Log to console  TC finished. Result = ${KEYWORD STATUS}
    ...  AND  Set Suite Variable  ${KEYWORD STATUS}
    ...  AND  DWDM Selenium Logout And Close Browser

step1: Get Parameters from SFP Monitoring
    Log to console  ------------------------------------------------
    Log to console  step1: Get Parameters from SFP Monitoring
    Log to console  ------------------------------------------------${\n}
    DWDM Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/selenium
    ${combined_dict}=  Create Dictionary
    FOR  ${sfp}  IN  @{ST_SFP}
      ${dwdm_params_dict_admin}=  selenium_coam.Get Applied Sfps Detailed Info  sfp_module=Tunable DWDM  link_port=${sfp}
      ${combined_dict}=  Set SFPs Dictionary  ${combined_dict}  ${dwdm_params_dict_admin}
    END
    Set Test Variable  ${DWDM_PARAMS_DICT}  ${combined_dict}
    selenium_coam.Save Screenshot  filename=dwdm_parameters_screen  screenshot_dir=${BTS Files}/selenium
    Log To Console  DWDM parameters succesfuly collected ${\n}

step2: Static Parameters Inspection
    Log to console  -----------------------------------
    Log to console  step2: Static Parameters Inspection
    Log to console  -----------------------------------${\n}
    ${static_statuses_list}=  Create List
    FOR  ${p}  IN  @{STATIC_PARAMETERS_LIST}
      ${statuses_list}=  Verify Parameters From SFP  ${p}
      Append To List  ${static_statuses_list}  ${statuses_list}
    END
    ${is_pass}=  Run Keyword And Return Status  List Should Not Contain Value  ${static_statuses_list}  False
    Run Keyword If  ${is_pass}  Log To Console  Static Parameters on tested SFPs are correct ${\n}
    ...  ELSE  Run Keyword And Continue On Failure  Fail  Static parameters inspection failed

step3: Dynamic Parameters Inspection
    Log to console  -----------------------------------
    Log to console  step3: Dynamic Parameters Inspection
    Log to console  -----------------------------------${\n}
    ${dynamic_statuses_list}=  Create List
    FOR  ${p}  IN  @{DYNAMIC_PARAMETERS_LIST}
      ${statuses_list}=  Verify Parameters From SFP  ${p}
      Append To List  ${dynamic_statuses_list}  ${statuses_list}
    END
    ${is_pass}=  Run Keyword And Return Status  List Should Not Contain Value  ${dynamic_statuses_list}  False
    Run Keyword If  ${is_pass}  Log To Console  Dynamic Parameters on tested SFPs are correct ${\n}
    ...  ELSE  Run Keyword And Continue On Failure  Fail  Dynamic parameters inspection failed

Set SFPs Dictionary
    [Arguments]  ${new_dict}  ${admin_params_dict}
    FOR  ${key}  IN  @{admin_params_dict.keys()}
      Set To Dictionary  ${new_dict}  ${key}=${admin_params_dict['${key}']}
    END
    [Return]  ${new_dict}

Preconditions
    ${static_parameters_list}=  Create List  DWDM first channel frequency  DWDM first channel  DWDM last channel frequency
    ...  DWDM last channel  DWDM minimum grid spacing  DWDM tuning capability  DWDM self tuning capability
    ...  DWDM tuned channel  DWDM channel configuration method
    ${dynamic_parameters_list}=  Create List  Scanning status of DWDM SFP module  Tunable SFP frequency error  Tunable SFP wavelength error
    ...  DWDM first channel wavelength  DWDM last channel wavelength
    Set Test Variable  ${STATIC_PARAMETERS_LIST}  ${static_parameters_list}
    Set Test Variable  ${DYNAMIC_PARAMETERS_LIST}  ${dynamic_parameters_list}

Postconditions
    ${missing_value_list}=  Create List
    FOR  ${sfp_key}  IN  @{DWDM_PARAMS_DICT.keys()}
      ${status}=  Run Keyword And Return Status  Dictionary Should Contain Value  ${DWDM_PARAMS_DICT['${sfp_key}']}  -
      Run Keyword If  ${status}  Append To List  ${missing_value_list}  True
    END
    Run Keyword If  "True" in "${missing_value_list}"  Log  Some DWDM parameters exist with missing value  WARN

Verify Parameters From SFP
    [Arguments]  ${param}
    ${failed_statuses_list}=  Create List
    FOR  ${sfp_key}  IN  @{DWDM_PARAMS_DICT.keys()}
      ${status}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${DWDM_PARAMS_DICT['${sfp_key}']}  ${param}
      ...  $(param) was not found in SFP Monitoring under ${sfp_key}! Fail
      Run Keyword If  "${status}"=="False"  Run Keywords  Log To Console  ${param} on ${sfp_key} -> Missing in Admin ${\n}
      ...  AND  Append To List  ${failed_statuses_list}  ${status}
    END
    Return From Keyword If  "False" in "${failed_statuses_list}"  False

DWDM Selenium Login And Disable Screen Lock
    [Arguments]  ${download_dir}=${EMPTY}  ${connection}=default
    ${browser}=  selenium_coam.Create Firefox Browser
    ...  download_dir=${download_dir}
    ...  screenshot_dir=${download_dir}
    ...  name=firefox_browser
    ${release}=  admin.Get Sw Release Name  connection=${connection}
    selenium_coam.Login
    ...  url=${WEBUI_URL}
    ...  username=${WEBUI_NAME}
    ...  password=${WEBUI_PWD}
    ...  version=${release}
    ...  browser=${browser}
    ${view_exists}=  selenium_coam.Start Up View Window Exists
    Run Keyword If  ${view_exists}  selenium_coam.Close Start Up View Window
    selenium_coam.Disable Message Box
    selenium_coam.Disable Screen Lock

DWDM Selenium Logout And Close Browser
    Run Keyword And Ignore Error  selenium_coam.Logout
    Run Keyword And Ignore Error  selenium_coam.Close Browser

TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
