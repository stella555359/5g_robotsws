*** Settings ***
Documentation
...    SISO Common Resource files

Library     taf.selenium.gnb.oam.core    WITH NAME    selenium_core
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    ./admin_ui.robot

*** Keywords ***
Selenium Login And Create Web Driver
    [Arguments]    ${url}=https://${BTS_HOST}   ${username}=Nemuadmin   ${password}=nemuuser   ${display}=${false}
    ...   ${driver_alias}=WEBEM_DRIVER   ${alias}=default
    Log    ${driver_alias}
    ${driver}   COAM WEBUI Login   url=${url}   username=${username}   password=${password}   display=${display}
    ...   driver_alias=WEBEM_DRIVER   alias=${alias}
    Set Test Variable   ${driver}

Webui Enter Into CW Page
    COAM_WEBUI_Click_Button   xpath=//span[@ui-tooltip='Configuration']
    Sleep   3s
    COAM_WEBUI_Move_To_Element   xpath=//span[contains(text(),'Configuration Reset')]
    Sleep   3s
    COAM_WEBUI_Move_To_Element   xpath=//span[contains(text(),'Configuration Management')]
    Sleep   3s
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(),'Configuration Management')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[@class='commissioning-wizard-container']
    Sleep   3s

Webui Open CW Modal View
    [Arguments]   ${step_name}=General BTS/Site Settings
    COAM_WEBUI_Click_Button   xpath=//a[contains(text(),'Steps')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-steps
    Sleep   3s
    COAM_WEBUI_Input_Value   xpath=//input[@placeholder='Step name']   text=${step_name}
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${step_name}"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[contains(@class, 'wizard-steps-modal-container')]
    Sleep   3s

Webui Open CW Modal View Cell Page
    [Arguments]   ${cell_type}=LTE TDD   ${step_name}=Basic Cell Settings
    COAM_WEBUI_Click_Button   xpath=//a[contains(text(),'Steps')]
    COAM_WEBUI_Wait_For_Visibility   xpath=//wizard-steps
    Sleep   3s
    COAM_WEBUI_Input_Value   xpath=//input[@placeholder='Step name']   text=${cell_type}
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${cell_type}"]
    Sleep   3s
    COAM_WEBUI_Click_Button   xpath=//wizard-steps//span[text()="${step_name}"]
    COAM_WEBUI_Wait_For_Visibility   xpath=//div[contains(@class, 'wizard-steps-modal-container')]
    Sleep   3s

Webui Change Cell Parameters On CW Modal View
    [Arguments]    ${para_name}    ${para_value}
    Log    ${para_name}
    Log    ${para_value}
    COAM_WEBUI_Click_Button    xpath=//a[contains(text(),'Steps')]

Webui Modify Cell Massive MIMO Antenna Array Mode
    [Arguments]   ${value}
    FOR    ${cell_info}    IN    @{ALL_CELL_LIST}
        Webui Select Parameter In CW Modal View   cell_id=${cell_info["cellId"]}
        ...    param_name=Massive MIMO antenna array mode   value=${value}
    END

Webui Select Parameter In CW Modal View
    [Arguments]    ${cell_id}    ${param_name}   ${value}
    ${status}  Run Keyword And Return Status   COAM_WEBUI_Get_Element_Text    xpath=//label[contains(text(), '${param_name}')]/../..//button
    Run Keyword If    "${status}"=="True"
    ...    COAM_WEBUI_Click_Button   xpath=//span[contains(text(), 'LNCEL-${cell_id}')]
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(), 'LNCEL-${cell_id}')]
    Sleep   3s
    COAM_WEBUI_Click_Button   xpath=//label[contains(text(), '${param_name}')]/../..//button
    Sleep   3s
    COAM_WEBUI_Scroll_To_Element
    ...    xpath=//label[contains(text(),'${param_name}')]/../..//wf-dropdown-item//span[contains(text(),'${value}')]
    COAM_WEBUI_Wait_For_Visibility
    ...    xpath=//label[contains(text(),'${param_name}')]/../..//wf-dropdown-item//span[contains(text(),'${value}')]
    COAM_WEBUI_Click_Button
    ...    xpath=//label[contains(text(),'${param_name}')]/../..//wf-dropdown-item//span[contains(text(),'${value}')]
    Sleep   5s
    COAM_WEBUI_Click_Button   xpath=//span[contains(text(), 'LNCEL-${cell_id}')]

Webui Done CW Modal View
    COAM_WEBUI_Click_Button   xpath=//button[contains(text(),'Done')]
    Sleep   5s

SISO Webui mMimoAntArrayMode Commissioning
    [Arguments]    ${mmimo_ant_array_mode}    ${alias}
    Selenium Login And Create Web Driver    driver_alias=WEBEM_DRIVER   alias=${alias}
    Webui Enter Into CW Page
    Webui Open CW Modal View Cell Page    cell_type=LTE TDD
    Webui Modify Cell Massive MIMO Antenna Array Mode    value=${mmimo_ant_array_mode}
    Webui Done CW Modal View
    Selenium Active Plan    alias=${alias}
 	Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Make L3call    ping=${True}
    Check Alarms
    Check Historical Alarms
    Get And Check Reset Counter For All BTS Node     correct_reset_counter=0
    [Teardown]    Run Keyword And Ignore Error   Selenium Logout    alias=${alias}
