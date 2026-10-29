*** Settings ***
Library        String
Library        OperatingSystem
Library        BuiltIn
Library        DateTime
Library        OperatingSystem
Library        SSHLibrary
Library        taf.transport.ssh    WITH NAME    ssh

Library     XML    use_lxml=True
Library        Process
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library    SeleniumLibrary

Resource    ./pretest_posttest.robot
Resource    ./system.robot
Resource    ./selenium.robot


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
${POP_CONTINUE_BTN}                            //div[@class="ui-modal"]//button[contains(text(), "Continue")]
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
#BTS_STATUS
${DETAILED_VIEW_SMOD_OBJECT}                   //div[contains(text(), "SMOD-1")]
@{DETAILED_VIEW_RMOD_OBJECT}
...                                            //div[contains(text(), "RMOD-1")]
...                                            //div[contains(text(), "RMOD-2")]
...                                            //div[contains(text(), "RMOD-3")]
@{DETAILED_VIEW_BBMOD_OBJECT}
...                                            //div[contains(text(), "BBMOD-1")]
...                                            //div[contains(text(), "BBMOD-2")]
...                                            //div[contains(text(), "BBMOD-3")]
@{DETAILED_VIEW_CELL_OBJECT}
...                                            //div[@aria-label="NRCELL 1"]//div[2]
...                                            //div[@aria-label="NRCELL 2"]//div[2]
...                                            //div[@aria-label="NRCELL 3"]//div[2]
${DETAILED_VIEW_GNSS_OBJECT}                   //div[contains(text(), "GNSSE-1")]
${DETAILED_VIEW_TRS_OBJECT}                    //div[@aria-label="Transport module 1"]
${DETAILED_VIEW_PARAMETER_NAME}                //td[@class="parameter-name ng-binding"]
${DETAILED_VIEW_PARAMETER_VALUE}               //td[@class="parameter-value ng-binding"]
${DETAILED_VIEW_GPS_OBJECT}                    //div[contains(@aria-label, "GPS Receiver 1")]
${RUNTIME_VIEW_RESET_SITE_BTN}                 //ui-button[@a-text="Reset Site"]
${RUNTIME_VIEW_OBJECT_NOT_CONFIGURED}          //div[@title="Hardware not configured"]
#CONFIGURATION
${CONFIG_MGMNT_SCF_INPUT}                      //input[@type="file" and @accept=".xml,.raml"]
${CONFIG_MGMNT_SAVE_BTS_CONFIGURATION_BTN}     //ui-button[@a-text="Save BTS Configuration"]
${CONFIG_MGMNT_SAVE_BTS_CONFIG_CONFIRM_BTN}    //ui-button[@a-text="Save"]
${CONFIG_MGMNT_VALIDATE_PLAN_BTN}              //ui-button[@a-title="Validate Plan"]
${CONFIG_MGMNT_ACTIVATE_PLAN_BTN}              //ui-button[@a-title="Activate Plan"]
${CONFIG_MGMNT_ACTIVATE_PLAN_ERRORS_CHBOX}     //span[contains(text(), "Activate plan despite of validation errors")]
${CONFIG_MGMNT_ACTIVATE_PLAN_SUCCESSFULLY}     //div[contains(text(), "Operation finished successfully")]
#ALARMS
${ALARM_MGMNT_OBJECT_NAME_INPUT}               //ui-text-input[@a-value="search.current"]//input[@placeholder="Object name"]
${ALARM_MGMNT_SELECT_PATH}                     //button[@class="btn btn-icon-button alarm-faults ng-scope"]
${ALARM_MGMNT_SELECT_CRITICAL_BTN}             ${ALARM_MGMNT_SELECT_PATH}//div[@ui-tooltip="Critical Alarms"]
${ALARM_MGMNT_SELECT_MAJOR_BTN}                ${ALARM_MGMNT_SELECT_PATH}//div[@ui-tooltip="Major Alarms"]
${ALARM_MGMNT_SELECT_MINOR_BTN}                ${ALARM_MGMNT_SELECT_PATH}//div[@ui-tooltip="Minor Alarms"]
${ALARM_MGMNT_SELECT_WARNINGS_BTN}             ${ALARM_MGMNT_SELECT_PATH}//div[@ui-tooltip="Warnings"]
${ALARM_MGMNT_UNSELECT_PATH}                   //button[@class="btn btn-icon-button alarm-faults ng-scope active"]
${ALARM_MGMNT_UNSELECT_CRITICAL_BTN}           ${ALARM_MGMNT_UNSELECT_PATH}//div[@ui-tooltip="Critical Alarms"]
${ALARM_MGMNT_UNSELECT_MAJOR_BTN}              ${ALARM_MGMNT_UNSELECT_PATH}//div[@ui-tooltip="Major Alarms"]
${ALARM_MGMNT_UNSELECT_MINOR_BTN}              ${ALARM_MGMNT_UNSELECT_PATH}//div[@ui-tooltip="Minor Alarms"]
${ALARM_MGMNT_UNSELECT_WARNINGS_BTN}           ${ALARM_MGMNT_UNSELECT_PATH}//div[@ui-tooltip="Warnings"]
#DIAGNOSTIC
${IP_CONNECTIVITY_ADDRESS}                     //input[@aria-labelledby="ip-connectivity-address-label"]
${IP_CONNECTIVITY_START_BTN}                   //ui-button[@a-text="Start"]
${IP_CONNECTIVITY_HOST_INFO}                   (//td[@class="ng-binding"])[1]
${IP_CONNECTIVITY_ADDRESS_INFO}                (//td[@class="ng-binding"])[2]
${IP_CONNECTIVITY_STATUS_PASSED}               //input[@value="Passed"]
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
${INPUT_DIST_NAME}                          //*[@id="oru-targerDN"]
${INPUT_AUTH_SSH_SERV_PUB_KEY_FORM_ID}      //*[@id="ssh-server-host-public-key-format-identifier"]
${INPUT_AUTH_SSH_SERV_PUB_KEY_VALUE}        //*[@id="ssh-server-host-public-key-value"]

${USER_ORU_ADD_ACCOUNT_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div/div[2]/div/div[2]/div[1]
...  /config-oru-account-table/p-table/div/div/div/div[3]/div/table/tfoot/tr/td[2]/p-button/button/span[1]
${USER_ORU_ADD_ACCOUNT_22R3}=   //*[@id="pr_id_6-table"]/tfoot/tr/td[2]/button/span[1]

${CONFIG_MGMNT_SEND_NETCONF_ACCOUNT_CONFIG}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div
...  /div/config-oru-account-ng/div/div[2]/execution-bar/div/div[1]/p-button/button

${SEND_NETCONF_CONFIG_RESULT}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
...  /div/div/config-oru-account-ng/div/div[2]/execution-bar/div/div[1]/div

${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div/div[2]
...  /div/div[2]/div[1]/config-oru-account-table/p-table/div/div/div/div[2]/table/tbody/tr/td[3]/button/span[1]

${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_22R3}=  //*[@id="pr_id_6-table"]/tbody/tr/td[3]/button/span[1]

${Select_SECOND_ORU_ACCOUNT_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div
...  /div[2]/div/div[2]/div[1]/config-oru-account-table/p-table/div/div/div/div[2]/table/tbody/tr[2]/td[2]
#${Select_SECOND_ORU_ACCOUNT_22R3}=  //*[@id="pr_id_6-table"]/tbody/tr[1]/td[2]
#${Select_SECOND_ORU_ACCOUNT_22R3}=  //*[@id="pr_id_6-table"]/tbody/tr[2]
${Select_SECOND_ORU_ACCOUNT_22R3}=  //*[@id="pr_id_6-table"]/tbody/tr[2]/td[2]
#//*[@id="pr_id_6-table"]/tbody/tr[2]/td[1]/span
${NETCONF_ORU_ACCOUNT_NAME_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng/div
...  /div[2]/div/div[2]/div[1]/config-oru-account-table/p-table/div/div/div/div[3]/div/table/tfoot/tr/td[1]
${NETCONF_ORU_ACCOUNT_NAME_22R3}=  //*[@id="pr_id_6-table"]/tfoot/tr/td[1]

${SERVER_AUTH_METHODE}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
...  /config-oru-account-ng/div/div[2]/div/div[1]/div[3]/p-dropdown/div/div[2]/span

${NO_AUTH_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
...  /config-oru-account-ng/div/div[2]/div/div[1]/div[3]/p-dropdown/div/div[4]/div/ul/p-dropdownitem[1]/li
${NO_AUTH_22R3}=  //*[@id="pr_id_4_list"]/p-dropdownitem[1]/li/span

${DEACT_SSH_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng
...  /div/div[2]/div/div[1]/div[3]/p-dropdown/div/div[4]/div/ul/p-dropdownitem[3]/li/span
${DEACT_SSH_22R3}=  //*[@id="pr_id_4_list"]/p-dropdownitem[3]/li/span

${PUBLIC_KEY_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/config-oru-account-ng
...  /div/div[2]/div/div[1]/div[3]/p-dropdown/div/div[4]/div/ul/p-dropdownitem[2]/li/span
${PUBLIC_KEY_22R3}=      //*[@id="pr_id_4_list"]/p-dropdownitem[2]/li/span

${CONFIGURE_ADD_NEETCONF_ACCOUNT}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
...  /config-oru-account-ng/div/div[2]/div/div[2]/div[2]/account-config/div/div[2]/button/span

${ADDITIONAL_NETCONF_RESULT_22R2}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
...  /config-oru-account-ng/div/div[2]/div/div[2]/div[1]/div[2]/ui-inline-info/div/span[2]
${ADDITIONAL_NETCONF_RESULT_22R3}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div
...  /config-oru-account-ng/div/div[2]/div/div[2]/div[1]/div[2]/ot-instruction/div/span

${SERVER_AUTH_METHODE1}=  SEPARATOR=
...  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section
...  /div/div/config-oru-account-ng/div/div[2]/div/div[1]/div[3]/p-dropdown

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

*** Keywords ***

Set Var For Different Branches
    ${USER_ORU_ADD_ACCOUNT}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${USER_ORU_ADD_ACCOUNT_22R2}
    ...                                                ${USER_ORU_ADD_ACCOUNT_22R3}
    Set Global Variable  ${USER_ORU_ADD_ACCOUNT}

    ${Select_SECOND_ORU_ACCOUNT}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${Select_SECOND_ORU_ACCOUNT_22R2}
    ...                                                ${Select_SECOND_ORU_ACCOUNT_22R3}
    Set Global Variable  ${Select_SECOND_ORU_ACCOUNT}

    ${PUBLIC_KEY}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${PUBLIC_KEY_22R2}
    ...                                                ${PUBLIC_KEY_22R3}
    Set Global Variable  ${PUBLIC_KEY}

    ${NETCONF_ORU_ACCOUNT_NAME}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${NETCONF_ORU_ACCOUNT_NAME_22R2}
    ...                                                ${NETCONF_ORU_ACCOUNT_NAME_22R3}
    Set Global Variable  ${NETCONF_ORU_ACCOUNT_NAME}

    ${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1}  Set Variable If  '${sw_release}'=='SBTS22R2'  ${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_22R2}
    ...                                                ${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1_22R3}
    Set Global Variable  ${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1}

    ${DEACT_SSH}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${DEACT_SSH_22R2}
    ...                                                ${DEACT_SSH_22R3}
    Set Global Variable  ${DEACT_SSH}

    ${NO_AUTH}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${NO_AUTH_22R2}
    ...                                                ${NO_AUTH_22R3}
    Set Global Variable  ${NO_AUTH}

    ${ADDITIONAL_NETCONF_RESULT}    Set Variable If    '${sw_release}' == 'SBTS22R2'    ${ADDITIONAL_NETCONF_RESULT_22R2}
    ...                                                ${ADDITIONAL_NETCONF_RESULT_22R3}
    Set Global Variable  ${ADDITIONAL_NETCONF_RESULT}

Add Credentials To First Account
    SELENIUM Set Name Of First O-RU Account  user
    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
    SELENIUM Send O-RU Account Configuration And Check State Success

Recreate Credentials To First Account in WebEM
    SELENIUM Set Name Of First O-RU Account  user
    SELENIUM Set Pasword Of First O-RU Account  xranuser-password
    SELENIUM Send O-RU Account Configuration And Check State Failed

Set Name Of First Account
    [Arguments]    ${account_name}
    ${result_code}=   SELENIUM Set Name Of First Account  ${account_name}
    [return]  ${result_code}

Add New O-RU Account
    SELENIUM Add New O-RU Account

Go To Netconf Radio Management Menu
    SELENIUM Go To Netconf Radio Management

Logout And Close Browser
    SELENIUM Logout User From Web Element Manager
    SELENIUM Teardown Environment

SELENIUM Setup
#    Log To Console    SELENIUM Setup
#    SELENIUM Prepare Enviroment
#    SELENIUM Run Xvfb
#    SELENIUM Export DISPLAY
    SELENIUM Login To Web Element Manager

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
    Check Second O-RU Account Netconf Radio Added
    SELENIUM Click Visible Element
    ...    locator=${Select_SECOND_ORU_ACCOUNT}

Check First O-RU Account Netconf Radio Added
    wait until page contains   SSDORU-1

Check Second O-RU Account Netconf Radio Added
    wait until page contains   SSDORU-2

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

SELENIUM Add new second O-RU Name and Netconf Account
    [Arguments]     ${xranuser}
    ...             ${xranpass}
    SELENIUM Add New Second O-RU Account
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  5

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
    ...    locator=${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1}
    Wait Until Keyword Succeeds  30  5  Check Delete Success O-RU1

SELENIUM Delete Credentials Of First O-RU Account Fail
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_DELETE_NETCONF_ACCOUNT1}
    Wait Until Keyword Succeeds  30  5  Check Delete Failed O-RU1

Check Delete Failed O-RU1
    ${validation_text}  SeleniumLibrary.Get Element Attribute  ${SEND_NETCONF_CONFIG_RESULT}  ng-reflect-text
    Should Contain  ${validation_text}  Unknown error: Validation is p

Check Delete Success O-RU1
    ${validation_text}  SeleniumLibrary.Get Text  ${NETCONF_ORU_ACCOUNT_NAME}
#    ${validation_text}  SeleniumLibrary.Get Text  ${SEND_NETCONF_CONFIG_RESULT}
    log to console   ${validation_text}
    Should be empty    ${validation_text}


SELENIUM Select Server AUTH METHODE PUBLIC KEY
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

SELENIUM Create default Netconf user account Public key based
    [Arguments]    ${pub_key_value}
    SELENIUM Select Server AUTH METHODE PUBLIC KEY
    Add New O-RU Account
    SELENIUM Set O-RU target distName    ${dist_name}
    SELENIUM Set O-RU target key format    ${pub_key_format}
    SELENIUM Set O-RU target key value    ${pub_key_value}
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success

SELENIUM Add new O-RU Name and Netconf Account Branch
    [Arguments]     ${xranuser}
    ...             ${xranpass}
    SELENIUM Add New O-RU Account Branch
    sleep  5
    SELENIUM Set Name Of First O-RU Account  ${xranuser}
    SELENIUM Set Pasword Of First O-RU Account  ${xranpass}
    SELENIUM Send O-RU Account Configuration And Check State Success
    sleep  5

SELENIUM Add New O-RU Account Branch
    SELENIUM Click Visible Element
    ...    locator=${CHECK_RMOD1}
    SELENIUM Click Visible Element
    ...    locator=${USER_ORU_ADD_ACCOUNT_BRANCH}
