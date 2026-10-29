*** Settings ***
Documentation
...    Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...    Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    Process
Library    SeleniumLibrary

Library    SeleniumLibrary
*** Variables ***
${WEBEM_IP}                                    https://192.168.255.1:3600
${USERNAME}                                    Nemuadmin
${PASSWORD}                                    nemuuser
${USERNAME_DEV}                                developer
${PASSWORD_DEV}                                $developer#
${WELCOME_SCREEN_USERNAME_INPUT}=              //div[@class="input-username"]//input
${WELCOME_SCREEN_USERNAME_INPUT_SBTS}=         //input[@id="login-username"]
${WELCOME_SCREEN_PASS_INPUT}=                  //div[@class="input-password"]//input
${WELCOME_SCREEN_PASS_INPUT_SBTS}=             //input[@id="login-password"]
${WELCOME_SCREEN_LOGIN_BTN}=                   //ui-button[@a-text="Login"]
${WELCOME_SCREEN_LOGIN_BTN_SBTS}=              //span[contains(text(), "Login")]
#POPs
${POP_CONFIRM_BTN}                             //div[@class="ui-modal"]//button[contains(text(), "Confirm")]
${POP_CLOSE_BTN}                               //div[@class="ui-modal"]//button[contains(text(), "Close")]
${POP_EXECUTE_BTN}                             //div[@class="ui-modal"]//button[contains(text(), "Execute")]
${POP_LOCK_BTN}                                //div[@class="ui-modal"]//button[contains(text(), "Lock")]
${POP_UNLOCK_BTN}                              //div[@class="ui-modal"]//button[contains(text(), "Unlock")]
${POP_RESET_CONFIRM_BTN}                       //div[@class="ui-modal"]//button[contains(text(), "Reset")]
${POP_SUBMIT_BTN}                              //div[@class="ui-modal"]//button[contains(text(), "Submit")]
${POP_OBJECT_REMOVAL_ONLY_SELECTED_RBTN}       //label[contains(text(), "Remove only the selected object")]
#DETAILS_PANEL
${DETAILS_PANEL_RESET_BTN}                     //ui-button[@a-title="Reset"]
${DETAILS_PANEL_LOCK_BTN}                      //ui-button[@a-title="Lock"]
${DETAILS_PANEL_UNLOCK_BTN}                    //ui-button[@a-title="Unlock"]
#NAVI_PANEL
${NAVI_PANEL_OBJECT_NAME_INPUT}                //global-search//input[@placeholder="Object name"]
${NAVI_PANEL_OBJECTS}                          //a[contains(text(), "Objects")]
${NAVI_PANEL_REMOVE_OBJECT_BTN}                //ui-button[@a-title="Remove object"]
#NAVI_BAR
${NAVI_BAR_BTS_STATUS}                         //div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
${NAVI_BAR_BTS_STATUS_RUNTIME_VIEW}            //span[contains(text(),'Site Runtime View')]
${NAVI_BAR_BTS_STATUS_DETAILED_VIEW}           //span[contains(text(),'Detailed Site View')]
${NAVI_BAR_BTS_STATUS_DIAGNOSTIC}              //li[@heading="Diagnostics"]
${NAVI_BAR_CONFIGURATION}                      //div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
${NAVI_BAR_CONFIGURATION_MANAGEMENT}           //span[contains(text(),'Configuration Management')]
${NAVI_BAR_CONFIGURATION_RESET}                //span[contains(text(),'Configuration Reset')]
${NAVI_BAR_CONFIGURATION_PARAM_EDITOR}         //span[contains(text(),'Parameter Editor')]
${NAVI_BAR_CONF_NETCONF_RADIO_MANAGEMENT}      //span[contains(text(),'Netconf Radio Management')]
${NAVI_BAR_ALARMS}                             //div[@aria-describedby="admin.navigationBar.alarms.TITLE"]
${NAVI_BAR_ALARMS_ALARM_MANAGEMENT}            //span[contains(text(),'Alarm Management')]
${NAVI_BAR_ALARMS_ACTIVE_ALARMS}               //span[contains(text(),'Active Alarms')]
${NAVI_BAR_ALARMS_ALARM_HISTORY}               //span[contains(text(),'Alarm History')]
${Plug_and_Play}                               //span[contains(text(),'Plug and Play')]
${Centralized_RET_Management}                  //span[contains(text(),'Centralized RET Management')]
${Centralized_RAE_Management}                  //span[contains(text(),'Centralized RAE Management')]
${Remote_Power_Control}                        //span[contains(text(),'Remote Power Control')]
${NAVI_BAR_ALARMS_TOGGLING_HISTORY}            //span[contains(text(),'Fault Toggling History')]
${NAVI_BAR_DIAGNOSTIC}                         //div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
${NAVI_BAR_DIAGNOSTIC_SFP_MONITORING}          //span[contains(text(),'SFP Monitoring')]
${NAVI_BAR_CONNECTIVITY_TEST}                  //span[contains(text(),'IP Connectivity Test')]
${NAVI_BAR_SNAPSHOT}                           //span[(text()='Snapshot')]
${NAVI_BAR_SNAPSHOT_BTN}                       //button[contains(text(),'Collect Snapshot')]
${NAVI_BAR_DEVELOPER_MODE}                     //div[@aria-describedby="admin.navigationBar.developerMenu.TITLE"]
${NAVI_BAR_USER_ACCOUNT}                       //nav-item[contains(@class, "user-account")]
${NAVI_BAR_USER_ACCOUNT_MANAGEMENT}            //button[@aria-label="User Account Management"]
${NAVI_BAR_USER_ACCOUNT_LOGOUT}                //button[@aria-label="Logout"]
${NAVI_BAR_OPTIONS}                            //menu-bar[@class="menu-header ng-isolate-scope"]
${NAVI_BAR_OPTIONS_SETTING}                    //a[contains(text(), "Settings")]
${NAVI_BAR_OPTIONS_HELP}                       //a[contains(text(), "Download help")]
${NAVI_BAR_SOFTWARE}                           //div[@aria-describedby="admin.navigationBar.software.TITLE"]
${NAVI_BAR_SOFTWARE_MANAGEMENT}                //span[contains(text(),'Software Management')
${NAVI_BAR_SOFTWARE_UPDATE}                    //span[contains(text(),'Software Update')]

#CONFIGURATION
${CONFIG_MGMNT_SCF_INPUT}                      //input[@type="file" and @accept=".xml,.raml"]
${CONFIG_MGMNT_SAVE_BTS_CONFIGURATION_BTN}     //ui-button[@a-text="Save BTS Configuration"]
${CONFIG_MGMNT_SAVE_BTS_CONFIG_CONFIRM_BTN}    //ui-button[@a-text="Save"]
${CONFIG_MGMNT_VALIDATE_PLAN_BTN}              //ui-button[@a-title="Validate Plan"]
${CONFIG_MGMNT_ACTIVATE_PLAN_BTN}              //ui-button[@a-title="Activate Plan"]
${CONFIG_MGMNT_ACTIVATE_PLAN_ERRORS_CHBOX}     //span[contains(text(), "Activate plan despite of validation errors")]
${CONFIG_MGMNT_ACTIVATE_PLAN_SUCCESSFULLY}     //div[contains(text(), "Operation finished successfully")]

#LOCAL USER ACCOUNT MANAGEMENT
${USER_ACC_MGMNT_LOCAL_USER_ACCOUNT}           //a[contains(text(), "Local User Account Management")]
${USER_ACC_MGMNT_CHOOSE_ACCOUNT_LIST}          //ui-select[@a-placeholder="Choose account you want to update"]//wf-dropdown
${USER_ACC_MGMNT_CHOOSE_ACCOUNT_READ_ONLY}     //span[contains(text(), "BTS Read-Only User")]
${USER_ACC_MGMNT_ALIAS_INPUT}                  //ui-text-input[contains (@id, "alias")]//input
${USER_ACC_MGMNT_PASSWORD_INPUT}               //ui-text-input[contains (@id, "local-password")]//input
${USER_ACC_MGMNT_PASSWORD_CONFIRM_INPUT}       //ui-text-input[contains (@id, "confirm-password")]//input
${USER_ACC_MGMNT_ACCOUNT_STATE_LIST}           //ui-select[@id="uam-local-account-state"]//wf-dropdown
${USER_ACC_MGMNT_ACCOUNT_STATE_ACTIVE}         //*[@title="Active"]
${USER_ACC_MGMNT_ACCOUNT_STATE_InaCTIVE}         //*[@title="Active"]
${USER_ACC_MGMNT_SAVE_BTN}                     //ui-button[@a-text="Save"]
${USER_ACC_MGMNT_CLOSE_BTN}                    //ui-button[@a-text="Close"]
${USER_ACC_MGMNT_PROCESS_COMPLETED_MSG}        //span[contains(text(), "Process completed")]
#OPTIONS
${SETTINGS_LOCK_SCREEN_INPUT}                  //div[@class="ui-custom-form-control"]//input
${SETTINGS_APPLY_BTN}                          //button[contains(text(),'Apply')]
#O-RU accounts
${INPUT_DEFAULT_ACCOUNT_NAME_TEXT}             //*[@id="account-name"]
${INPUT_DEFAULT_ACCOUNT_PASS_TEXT}             //*[@id="account-pwd"]
${INPUT_DEFAULT_ACCOUNT_PASS_CONFIRM_TEXT}     //*[@id="confirm-account-pwd"]
${INPUT_ADD_ACCOUNT_NAME_TEXT}                 //*[@id="additional-netconf-account-name"]
${INPUT_ADD_ACCOUNT_PASS_TEXT}                 //*[@id="additional-netconf-account-pwd"]
${INPUT_ADD_ACCOUNT_PASS_CONFIRM_TEXT}         //*[@id="confirm-additional-netconf-account-pwd"]

#### branch
${CHECK_RMOD1}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div/div[2]/div/div[1]/config-oru-account-
...  table/p-table/div/div/div/div[2]/table/tbody/tr/td[1]/p-tablecheckbox/div/div[2]
${USER_ORU_ADD_ACCOUNT_BRANCH} =  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div/div[2]/div/div[2]/account-config/
...  button[2]/span
${CONFIGURE_ADD_NETCONF_ACCOUNT_BRANCH}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div/div[2]/div/div[2]/div[2]/
...  account-config/div/div[2]/button/span

${CONFIG_MGMNT_SEND_NETCONF_ACCOUNT_CONFIG}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div
...  /div/config-oru-account-ng/div/div[2]/execution-bar/div/div[1]/p-button/button

${SEND_NETCONF_CONFIG_RESULT}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
...  /div/div/config-oru-account-ng/div/div[2]/execution-bar/div/div[1]/div

*** Keywords ***

SELENIUM Go To Netconf Radio Management
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONF_NETCONF_RADIO_MANAGEMENT}
    Sleep  2
    Check Netconf Radio Management Page Loaded

Check Netconf Radio Management Page Loaded
    wait until page contains  Netconf Radio Management

SELENIUM Add New O-RU Account
    SELENIUM Click Visible Element
    ...    locator=${USER_ORU_ADD_ACCOUNT}
    Check First O-RU Account Netconf Radio Added

SELENIUM Configure Additional Netconf Account
    SELENIUM Click Visible Element
    ...    locator=${CONFIGURE_ADD_NEETCONF_ACCOUNT}
#    Check First O-RU Account Netconf Radio Added

SELENIUM Add New Second O-RU Account
    SELENIUM Click Visible Element
    ...    locator=${USER_ORU_ADD_ACCOUNT}
    Check First O-RU Account Netconf Radio Added
    SELENIUM Click Visible Element
    ...    locator=${Select_SECOND_ORU_ACCOUNT}

Check First O-RU Account Netconf Radio Added
    wait until page contains   SSDORU-1

SELENIUM Add new O-RU Name and Netconf Account
    [Arguments]     ${xranuser}
    ...             ${xranpass}
    Add New O-RU Account
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  5

SELENIUM Set Name Of First O-RU Account
    [Arguments]    ${account_name}
    SELENIUM Input Text in Visible Element  ${INPUT_DEFAULT_ACCOUNT_NAME_TEXT}  ${account_name}
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_DEFAULT_ACCOUNT_NAME_TEXT}  ng-reflect-text
    [return]  ${validation_text}

SELENIUM Set Pasword Of First O-RU Account
    [Arguments]    ${account_password}
    SELENIUM Input Text in Visible Element  ${INPUT_DEFAULT_ACCOUNT_PASS_TEXT}  ${account_password}
    SELENIUM Input Text in Visible Element  ${INPUT_DEFAULT_ACCOUNT_PASS_CONFIRM_TEXT}  ${account_password}

SELENIUM Send O-RU Account Configuration And Check State Success
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_SEND_NETCONF_ACCOUNT_CONFIG}
    Wait Until Keyword Succeeds  30  2  Check Send Success

SELENIUM Send O-RU Account Configuration And Check State Not Success
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_SEND_NETCONF_ACCOUNT_CONFIG}
    Wait Until Keyword Succeeds  30  5  Check Send Not Success

SELENIUM Set Name Of Additional O-RU Account
    [Arguments]    ${account_name1}
    SELENIUM Input Text in Visible Element  ${INPUT_ADD_ACCOUNT_NAME_TEXT}  ${account_name1}
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_ADD_ACCOUNT_NAME_TEXT}  ng-reflect-text
    [return]  ${validation_text}

SELENIUM Set Pasword Of Additional O-RU Account
    [Arguments]    ${account_password1}
    SELENIUM Input Text in Visible Element  ${INPUT_ADD_ACCOUNT_PASS_TEXT}  ${account_password1}
    SELENIUM Input Text in Visible Element  ${INPUT_ADD_ACCOUNT_PASS_CONFIRM_TEXT}  ${account_password1}

Check Send Not Success
    ${validation_text}  SeleniumLibrary.Get Text  ${SEND_NETCONF_CONFIG_RESULT}
    Should Not Contain  ${validation_text}  Configure netconf radio succeeded.

Check Send Success
    ${validation_text}  SeleniumLibrary.Get Text  ${SEND_NETCONF_CONFIG_RESULT}
    Should Contain   ${validation_text}  Configure netconf radio succeeded.

Check Additional Netconf
    ${validation_text}  SeleniumLibrary.Get Text  ${ADDITIONAL_NETCONF_RESULT}
    Should Contain   ${validation_text}  Additional netconf account shall be same in all accounts.

Check Send Failed
    ${validation_text}  SeleniumLibrary.Get Text  ${SEND_NETCONF_CONFIG_RESULT}
    Should Contain  ${validation_text}  Unknown error: Validation is p

SELENIUM Send O-RU Account Configuration And Check State Failed
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_SEND_NETCONF_ACCOUNT_CONFIG}
    Wait Until Keyword Succeeds  30  5  Check Send Failed

SELENIUM Delete Credentials Of First O-RU Account Success
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_CONFIG}
    Wait Until Keyword Succeeds  30  5  Check Delete Success O-RU1

SELENIUM Delete Credentials Of First O-RU Account Fail
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_CONFIG}
    Wait Until Keyword Succeeds  30  5  Check Delete Failed O-RU1

Check Delete Failed O-RU1
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${SEND_NETCONF_CONFIG_RESULT}  ng-reflect-text
    Should Contain  ${validation_text}  Unknown error: Validation is p

Check Delete Success O-RU1
    ${validation_text}  SeleniumLibrary.Get Text  ${NETCONF_ORU_ACCOUNT_NAME}
#    ${validation_text}  SeleniumLibrary.Get Text  ${SEND_NETCONF_CONFIG_RESULT}
    log to console   ${validation_text}
    Should be empty    ${validation_text}


SELENIUM Select Server AUTH METHODE
    SELENIUM Click Visible Element
    ...    locator=${SERVER_AUTH_METHODE}
    SELENIUM Click Visible Element
    ...    locator=${PUBLIC_KEY}

SELENIUM Select Server NO AUTH
    SELENIUM Click Visible Element
    ...    locator=${SERVER_AUTH_METHODE}
    SELENIUM Click Visible Element
    ...    locator=${NO_AUTH}

SELENIUM Select Server DEACT SSH
    SELENIUM Click Visible Element
    ...    locator=${SERVER_AUTH_METHODE}
    SELENIUM Click Visible Element
    ...    locator=${DEACT_SSH}

SELENIUM Select Server
    SELENIUM Click Visible Element
    ...    locator=${SERVER_AUTH_METHODE1}
     ${validation_text}  SeleniumLibrary.Get Element Attribute  ${SERVER_AUTH_METHODE1}  ng-reflect-model
    [return]  ${validation_text}


#    ${validation_text}   SeleniumLibrary.Select From List By Value    ${SERVER_AUTH_METHODE}    ${method}

#    SELENIUM Input Text in Visible Element  ${SERVER_AUTH_METHODE}  ${account_name}
#    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_DEFAULT_ACCOUNT_NAME_TEXT}  ng-star-inserted

#    [return]  ${validation_text}

SELENIUM Set O-RU target distName
    [Arguments]    ${dist_name}
    SELENIUM Input Text in Visible Element  ${INPUT_DIST_NAME}  ${dist_name}
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_DIST_NAME}  ng-reflect-text
    [return]  ${validation_text}

SELENIUM Set O-RU target key format
    [Arguments]    ${pub_key_format}
    SELENIUM Input Text in Visible Element  ${INPUT_AUTH_SSH_SERV_PUB_KEY_FORM_ID}  ${pub_key_format}
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_AUTH_SSH_SERV_PUB_KEY_FORM_ID}  ng-reflect-text
    [return]  ${validation_text}

SELENIUM Set O-RU target key value
    [Arguments]    ${pub_key_value}
    SELENIUM Input Text in Visible Element  ${INPUT_AUTH_SSH_SERV_PUB_KEY_VALUE}  ${pub_key_value}
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${INPUT_AUTH_SSH_SERV_PUB_KEY_VALUE}  ng-reflect-text
    [return]  ${validation_text}
### Selenium branch

SELENIUM Add new O-RU Name and Netconf Account Branch
    [Arguments]     ${xranuser}
    ...             ${xranpass}
    SELENIUM Add New O-RU Account Branch
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  5

SELENIUM Add new and additional O-RU Name and Netconf Account Branch
    [Arguments]     ${xranuser}
    ...             ${xranpass}
    ...             ${xranuser2}
    ...             ${xranpass2}
    SELENIUM Add New O-RU Account Branch
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    ### additional Netconf Account
    SELENIUM Configure Additional Netconf Account Branch
    SELENIUM Set Name Of Additional O-RU Account  ${xranuser2}
    SELENIUM Set Pasword Of Additional O-RU Account  ${xranpass2}

    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  5


SELENIUM Add New O-RU Account Branch
    SELENIUM Click Visible Element
    ...    locator=${CHECK_RMOD1}
    SELENIUM Click Visible Element
    ...    locator=${USER_ORU_ADD_ACCOUNT_BRANCH}

SELENIUM Configure Additional Netconf Account Branch
    SELENIUM Click Visible Element
    ...    locator=${USER_ORU_ADD_ACCOUNT_BRANCH}
