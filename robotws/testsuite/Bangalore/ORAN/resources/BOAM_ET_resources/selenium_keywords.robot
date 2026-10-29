*** Settings ***
Library    taf.selenium.sbts    WITH NAME    selenium

*** Variables ***
${RMOD_COLUMN}=     //div[@class="RMOD-column"]
${RMOD_STATE}=
...    //div[@class="site-widget-header site-widget-header-horizontal-bar"]//div[@class="site-widget-diode green-diode"]
${HW_DETAILS}=      //hardware-details//*[contains(text()
${ACCOUNTS_CONFIGURATION}=    //div[contains(text(),'Accounts configuration')]
${PLUS_BUTTON_TRUNK}
...  //button[@class="p-element p-button-secondary p-button-text p-button-sm p-button p-component p-button-icon-only"]
${PLUS_BUTTON_22R2}    //button[@class="ui-button-secondary ui-button ui-widget ui-state-default ui-corner-all ui-button-icon-only"]
${PARAMETER_EDITOR_BUTTON}=    //span[contains(text(),'Parameter Editor')]
${SEARCH_OBJECT_BUTTON}=    //div/execution-bar/div/pe-global-search-filter/ui-text-input/div/input
${PLUS_BUTTON_PE}=    //i[@class="fa fa-plus"]
${OBJECT_CLASS_BUTTON}=    //div[contains(text(), 'Object class:')]/following-sibling::div
${LOAD_DEF_CHECKBOX}=    //input[@ng-model="$ctrl.newChildModel.loadDefaultValues"]
${PLAN_TO_COPY_BUTTON}=    //div[contains(text(), 'Plan to copy from:')]/following-sibling::div
${COPY_FROM_BUTTON}=    //div[contains(text(), 'Copy from:')]/following-sibling::div
${ID_BUTTON}=    //div[contains(text(), 'Id:')]/following-sibling::div
${SUBMIT_BUTTON}=    //ui-button[@a-text="Submit"]
${SEARCH_PARAM_BUTTON}=    //div/pe-toolbar/div/ui-text-input/div/input
${PARAMETER_INPUT}=    parameter-input/div/ui-text-input/div/input

*** Keywords ***
Login To Web Element Manager
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}
    selenium.login    ${url}    ${username}    ${password}    version=${version}    browser=${browser}
	
Teardown Environment
    selenium.logout

Check Privacy Error
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="main-message"]/h1
    ...                                           timeout=30
    ${privacy_error}    Run Keyword If    ${status}    Get Text    locator=//*[@id="main-message"]/h1
    ${privacy_error}    Run Keyword And Return Status    Should Contain    ${privacy_error}    is not private
    Run Keyword If    ${privacy_error}    Proceed Unsafe Connection

Proceed Unsafe Connection
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="details-button"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="details-button"]
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...                                           xpath=//*[@id="proceed-link"]
    ...                                           timeout=30
    Run Keyword If    ${status}    Click Element  xpath=//*[@id="proceed-link"]
	
Go To Commissioning Wizard
    Wait Until Element Is Visible   locator=${CONFIGURATION_TAB}
    Click Element   locator=${CONFIGURATION_TAB}
    Mouse Over    locator=${CONFIGURATION_MANAGEMENT_BUTTON}
    Mouse Over    locator=${COMMISSIONING_WIZARD_BUTTON}
    Click Element   locator=${COMMISSIONING_WIZARD_BUTTON}
    Wait Until Keyword Succeeds    100
    ...    5
    ...    Element Should Be Visible   locator=//h4[@title="O-RU radio configuration warning"]
    Click Element    locator=//ui-button[@a-text="Close"]

Try To Add ORU In Commissioning
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser} 
    Login To Web Element Manager1
    Go To Commissioning Wizard
    Add Oru Radio
    Close All Browsers

Add Oru Radio
    Element Should Not Be Visible    locator=${RMOD_COLUMN}//div[@aria-label="Radio Module 1"]
    Click Element    locator=${RMOD_COLUMN}//i[@class="plus"]
    Input Text
    ...    locator=//div[@class="hw-element-select-wrapper"]//input
    ...    text=O-RU
    Page Should Contain Element    locator=//input[@placeholder="No Data"]
    Click Element    locator=${RMOD_COLUMN}//i[@class="plus"]
    Input Text
    ...    locator=//div[@class="hw-element-select-wrapper"]//input
    ...    text=ORU
    Page Should Contain Element    locator=//input[@placeholder="No Data"]
    Click Element    locator=${RMOD_COLUMN}//i[@class="plus"]
    Page Should Not Contain Element    locator=//div[@class="hw-element" and contains(text(), 'OFSEGA (O-RU)')]
    	

Add Default Netconf Account
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${oru_name}    ${account_name}    ${account_pwd}
    ...            ${confirm_account_pwd}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
    selenium.configure_default_netconf_account    ${oru_name}    ${account_name}    ${account_pwd}
    ...    ${confirm_account_pwd}
	selenium.send_netconf_configuration
	Teardown Environment
    Log    \n+ Default Netconf Account Added    console=yes
	
Add Default Netconf Account Without Teardowning
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${oru_name}    ${account_name}    ${account_pwd}
    ...            ${confirm_account_pwd}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
    selenium.configure_default_netconf_account    ${oru_name}    ${account_name}    ${account_pwd}
    ...    ${confirm_account_pwd}
	selenium.send_netconf_configuration
    Log    \n+ Default Netconf Account Added    console=yes

Login To Web Element Manager1
    [Arguments]    ${login}=${CUSTOMER_LOGIN}
    ...            ${password}=${CUSTOMER_PASSWORD}
    Set Selenium Implicit Wait    5
    Open Browser    ${WebEM IP}   chrome
    Check Privacy Error
    Proceed Unsafe Connection
    Run Keyword And Ignore Error    Maximize Browser Window
    Input Text    locator=${INPUT_NAME_FIELD}
    ...           text=${login}
    Input Password    locator=${INPUT_PASSWORD_FIELD}
    ...               password=${password}
    Click Element   locator=${LOGIN_BUTTON}
    ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=100
    Run Keyword If    ${is_visible}    Click Element    locator=${CONFIRM_BUTTON}
    ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    locator=${CONFIRM_BUTTON}    timeout=20
    Run Keyword If    ${is_visible}    Click Element    locator=${CONFIRM_BUTTON}
    Close BTS Startup View

Close BTS Startup View
    ${close}=    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Close')]
    ...    timeout=100
    Run Keyword If    '${close}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]
	
Add Additional Netconf Account
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${oru_name}    ${account_name}    ${account_pwd}
    ...            ${confirm_account_pwd}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
    selenium.configure_additional_netconf_account    ${oru_name}    ${account_name}    ${account_pwd}
    ...    ${confirm_account_pwd}
	selenium.send_netconf_configuration
	Teardown Environment
    Log    \n+ Additional Netconf Account Added    console=yes

Clear Netconf Account Configuration
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${oru_name}
    Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
    selenium.delete_additional_netconf_account    ${oru_name}
    selenium.send_netconf_configuration

Remove Netconf Accounts From Gnb Using Webem
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${oru_name}
    Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
    selenium.delete_additional_netconf_account    ${oru_name}
	selenium.send_netconf_configuration
	ADMIN Reset Site
    ADMIN Assert All Bbmods Are In Enabled State    timeout=180
	
Remove Additional Netconf Account From Gnb Using Webem
    [Arguments]    ${oru_name}
    selenium.delete_additional_netconf_account    ${oru_name}
	selenium.send_netconf_configuration
    ADMIN Reset Site
    ADMIN Assert All Bbmods Are In Enabled State    timeout=180
    Wait Until MPlane Is Connected
	
Reset Radio In Webem Using Reset Button
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${ru_index}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
	selenium.reset_ru    ru_index=${ru_index}
	Teardown Environment
	
Add Cell
    [Arguments]    ${url}    ${username}    ${password}
    ...            ${version}    ${browser}    ${cell_type}
	Login To Web Element Manager    ${url}    ${username}    ${password}    ${version}    ${browser}
	selenium.add_cell    ${cell_type}
	Teardown Environment

Open Details Panel If Is Closed
    ${DetPanelOpen}    Run Keyword And Return Status    Page Should Not Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    ${DetPanelClose}    Run Keyword And Return Status    Page Should Contain Element
    ...    locator=//wf-panel[@class="details-panel view-panel ng-isolate-scope ng-hide"]
    Run Keyword If    ${DetPanelClose}    Click Element
    ...    locator=//ui-button[@class="show-panel-button ng-scope ng-isolate-scope ui-tooltip-source"]
    Log    DetPanelOpen=${DetPanelOpen} DetPanelClose=${DetPanelClose}

Navigate To Simplified Site View
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    Click Element    locator=//span[contains(text(),'Site Runtime View')]

Navigate To Detailed Site View
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    Mouse Over    locator=//span[contains(text(),'Site Runtime View')]
    Click Element    locator=//a[contains(text(),'Detailed Site View')]

Assert Rmod Contains Green Diode
    Navigate To Simplified Site View
    Page Should Contain Element
    ...    locator=//div[@class="rmod-grid-element"]//div[@class="site-widget-diode green-diode"]
    Navigate To Detailed Site View
    Page Should Contain Element
    ...    locator=${RMOD_COLUMN}${RMOD_STATE}
    Log    \n+ Green diode checked    console=yes

Assert Proper Oru Status Parameters Are Visible In Site Views
    Open Details Panel If Is Closed
    FOR    ${key}    IN    @{ORU_STATUS_PARAMETERS.keys()}
        Page Should Contain Element
        ...    locator=${HW_DETAILS},'${key}')]//parent::tr//*[contains(text(),'${ORU_STATUS_PARAMETERS["${key}"]}')]
    END
    Log    \n+ RMOD status parameters checked    console=yes

Open Detailed Panel In Simplified Site View
    [Arguments]    ${locator_simplified}
    #Register Keyword To Run On Failure    NONE
    Navigate To Simplified Site View
    Wait Until Element Is Visible
    ...    locator=${locator_simplified}
    Click Element
    ...    locator=${locator_simplified}
    Open Details Panel If Is Closed
    #Register Keyword To Run On Failure    Capture Page Screenshot

Open Detailed Panel In Detailed Site View
    [Arguments]    ${locator_detailed}
    #Register Keyword To Run On Failure    NONE
    Navigate To Detailed Site View
    Wait Until Element Is Visible
    ...    locator=${locator_detailed}
    Click Element
    ...    locator=${locator_detailed}
    Open Details Panel If Is Closed
    #Register Keyword To Run On Failure    Capture Page Screenshot

Compare Parameters from Ims and Site View
    [Arguments]    ${locator_simplified}
    ...            ${locator_detailed}
    ...            ${parameters_dict}
    ...            ${ims_parameters}
    Set Log Level    ERROR
    Open Detailed Panel In Simplified Site View    ${locator_simplified}
    Compare Parameters from Ims and Gui    ${parameters_dict}    ${ims_parameters}
    Open Detailed Panel In Detailed Site View    ${locator_detailed}
    Compare Parameters from Ims and Gui    ${parameters_dict}    ${ims_parameters}
    Set Log Level    TRACE

Compare Parameters from Ims and Gui
    [Arguments]    ${parameters_dict}
    ...            ${ims_parameters}
    FOR    ${parameter}     IN    @{parameters_dict.keys()}
        ${value}=    Get From Dictionary    dictionary=&{ims_parameters}    key=${parameter}
        Assert Parameter Is Not Empty    ${value}
        ${value}=    Convert To String    ${value}
        ${passed}=    Run Keyword And Return Status    Should Be Equal     '${parameters_dict["${parameter}"]}'    'Availability status'
        ${is_None}=    Run Keyword If    ${passed}    Run Keyword And Return Status    Should Be Equal    ${value}    None
        ${value}=    Set Variable If    ${is_None}    -    ${value}
        Page Should Contain Element
        ...    locator=${HW_DETAILS},'${parameters_dict["${parameter}"]}')]//parent::tr//*[contains(text(),'${value}')]
    END

Prepare Environment
    Set Plus Button Based On The Release
    Chmod Chromedriver
    Run Xvfb
    Export DISPLAY

Chmod Chromedriver
    Run  sudo chmod +x /usr/bin/chromedriver

Run Xvfb
    Start Process  /usr/bin/Xvfb :99 -screen 0 1920x1080x16   shell=yes

Export DISPLAY
    Set Environment Variable  DISPLAY  :99

Set Plus Button Based On The Release
    ${status}=    Run Keyword And Return Status    Should Contain Any    ${OUT_ACTIVE_SW}    22R2
    Run Keyword If    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_22R2}
    Run Keyword Unless    ${status}    Set Suite Variable    ${PLUS_BUTTON}    ${PLUS_BUTTON_TRUNK}
