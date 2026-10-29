*** Settings ***
Documentation
...    Author: krzysztof.gryga@nokia.com, rafal.janik@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com
...    Maintainer: rafal.janik@nokia.com, krzysztof.gryga@nokia.com, adam.masztalerz@nokia.com, piotr.pinderak@nokia.com

Library    Process
Library    SeleniumLibrary

*** Variables ***
${WEBEM_IP}                                    https://192.168.255.1:3600
${USERNAME}                                    Nemuadmin
${PASSWORD}                                    nemuuser
${USERNAME_DEV}                                developer
${PASSWORD_DEV}                                $developer#
${WELCOME_SCREEN_USERNAME_INPUT}=              //div[@class="input-username"]//input
${WELCOME_SCREEN_USERNAME_INPUT_modified}=     //div[@class="ui-inputgroup"]//input[@placeholder="Username"]
${WELCOME_SCREEN_USERNAME_INPUT_SBTS}=         //input[@id="login-username"]
${WELCOME_SCREEN_PASS_INPUT}=                  //div[@class="input-password"]//input
${WELCOME_SCREEN_PASS_INPUT_modified}=         //div[@class="ui-inputgroup"]//input[@placeholder="Password"]
${WELCOME_SCREEN_PASS_INPUT_SBTS}=             //input[@id="login-password"]
${WELCOME_SCREEN_LOGIN_BTN}=                   //ui-button[@a-text="Login"]
${WELCOME_SCREEN_LOGIN_BTN_modified}=          //p-button[@ng-reflect-label="Login"]
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

*** Keywords ***
SELENIUM Activate Plan
    [Arguments]
    ...    ${timeout}=120
    SELENIUM Pop Execute
    SELENIUM Check If Acivate Plan Finished Successfully
    ...    timeout=${timeout}

SELENIUM Activate Plan Despite Of Validation Errors
    [Arguments]
    ...    ${timeout}=120
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_ACTIVATE_PLAN_BTN}
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_ACTIVATE_PLAN_ERRORS_CHBOX}
    SELENIUM Pop Execute
    SELENIUM Check If Acivate Plan Finished Successfully
    ...    timeout=${timeout}

SELENIUM Avoid Lock Screen
    [Arguments]
    ...    ${timeout}=15
    Wait Until Page Does Not Contain Element
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_OPTIONS}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_OPTIONS_SETTING}
    SELENIUM Input Text in Visible Element
    ...    locator=${SETTINGS_LOCK_SCREEN_INPUT}
    ...    text=${timeout}
    Run Keyword And Return Status    Click Element
    ...    locator=${SETTINGS_APPLY_BTN}

SELENIUM Check Administrative State Locked
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Administrative state:
    ...    expected_value=Locked

SELENIUM Check Administrative State Unlocked
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Administrative state:
    ...    expected_value=Unlocked

SELENIUM Check Availability Status Dependency
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Availability status:
    ...    expected_value=Dependency

SELENIUM Check Availability Status Failed
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Availability status:
    ...    expected_value=Failed

SELENIUM Check Availability Status Not Installed
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Availability status:
    ...    expected_value=NotInstalled

SELENIUM Check Availability Status Offline
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Availability status:
    ...    expected_value=Offline

SELENIUM Check Availability Status Online
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Availability status:
    ...    expected_value=Online

SELENIUM Check Expected Status
    [Arguments]    ${index}
    ...            ${name}
    ...            ${expected_name}
    ...            ${expected_value}
    ${value}    Run Keyword If    '${name}' == '${expected_name}'
    ...    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_VALUE})[${index+1}]
    Run Keyword If    '${name}' == '${expected_name}'
    ...    Should Be Equal
    ...    first=${value}
    ...    second=${expected_value}

SELENIUM Check GNSS While OnAir
    [Arguments]    ${component_locator}=${DETAILED_VIEW_GNSS_OBJECT}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Enabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Online
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}

SELENIUM Check If Cell Is Connected With RMOD
    [Arguments]    ${cell_id}
    ...            ${rmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_CELL_OBJECT[${cell_id}]}
    ${RMOD_connected}    SELENIUM Get Text From Object
    ...    text_locator=(//tbody[@class="trx-table-body"])[1]
    ${status}    Run Keyword And Return Status    Should Contain
    ...    container=${RMOD_connected}
    ...    item=RMOD-${rmod_id+1}
    [Return]  ${status}

SELENIUM Check If RMOD Is Connected With BBMOD
    [Arguments]    ${rmod_id}
    ...            ${bbmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_BBMOD_OBJECT[${bbmod_id}]}
    ${BBMOD_R_number}    SELENIUM Get Text From Object
    ...    text_locator=//div[@class="element-header-data ng-scope"]
    ${BBMOD_R_number}    Fetch From Right
    ...    string=${BBMOD_R_number}
    ...    marker=Runtime object: BBMOD_R-
    SELENIUM Click Visible Element
    ...    locator=//div[@aria-label="Baseband Module ${BBMOD_R_number}"]//div[@class="connector-icons"]//div
    ${BBMOD_connected}    SELENIUM Get Text From Object
    ...    text_locator=//td[@class="parameter-value ng-binding" and contains(text(),'RMOD')]
    ${RMOD_connected}    SELENIUM Get Text From Object
    ...    text_locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}
    ${RMOD_connected}    Fetch From Right
    ...    string=${RMOD_connected}
    ...    marker=RMOD-1 / RMOD
    ${status}    Run Keyword And Return Status    Should Contain
    ...    container=${BBMOD_connected}
    ...    item=${RMOD_connected}
    [Return]  ${status}

SELENIUM Check BBMOD While BBMOD Reset
    [Arguments]    ${bbmod_id}
    SELENIUM Check Component While BBMOD Reset
    ...    component_locator=${DETAILED_VIEW_BBMOD_OBJECT[${bbmod_id}]}

SELENIUM Check BBMOD While OnAir
    [Arguments]    ${bbmod_id}
    SELENIUM Check Component While OnAir
    ...    component_locator=${DETAILED_VIEW_BBMOD_OBJECT[${bbmod_id}]}

SELENIUM Check Component While BBMOD Reset
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Disabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Offline
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Not Initialized
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Component While Cell Lock
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Disabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Dependency
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Configured
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Component While Cell Reset
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Disabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Failed
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Not Initialized
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Component While OnAir
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
     ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Enabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Online
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Configured
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Component While RMOD Lock
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Enabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Online
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Locked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Configured
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Component While RMOD Reset
    [Arguments]    ${component_locator}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${component_locator}
    ${nr_elem_operational}    SeleniumLibrary.Get Element Count
    ...    locator=${DETAILED_VIEW_PARAMETER_VALUE}
    :FOR    ${index}    IN RANGE    ${nr_elem_operational}
    \    ${text}    SELENIUM Get Text From Object
    ...    text_locator=(${DETAILED_VIEW_PARAMETER_NAME})[${index+1}]
    \    SELENIUM Check Operational State Disabled
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Availability Status Not Installed
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Administrative State Unlocked
    ...    name=${text}
    ...    index=${index}
    \    SELENIUM Check Procedural Status Not Initialized
    ...    name=${text}
    ...    index=${index}

SELENIUM Check Operational State Enabled
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Operational state:
    ...    expected_value=Enabled

SELENIUM Check Operational State Disabled
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Operational state:
    ...    expected_value=Disabled

SELENIUM Check Procedural Status Configured
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Procedural status:
    ...    expected_value=configured

SELENIUM Check Procedural Status Not Initialized
    [Arguments]    ${index}
    ...            ${name}
    SELENIUM Check Expected Status
    ...    index=${index}
    ...    name=${name}
    ...    expected_name=Procedural status:
    ...    expected_value=not initialized

SELENIUM Check RMOD And Cell States Are Reset
    [Arguments]    ${bbmod_id}
    :FOR    ${index}  IN RANGE  ${OUT_ADMIN_RMODS_AMOUNT}
    \    ${status}    SELENIUM Check If RMOD Is Connected With BBMOD
    ...    rmod_id=${index}
    ...    bbmod_id=${bbmod_id}
    \    Run Keyword If    ${status}
    ...    SELENIUM Wait Till RMOD And Cell States Are Reset
    ...    rmod_id=${index}

SELENIUM Check RMOD Cells While OnAir
    [Arguments]    ${rmod_id}
    :FOR    ${index}    IN RANGE    ${OUT_ADMIN_LNCELS_AMOUNT}
    \    ${status}    SELENIUM Check If Cell Is Connected With RMOD
    ...    cell_id=${index}
    ...    rmod_id=${rmod_id}
    \    Run Keyword If    ${status}
    ...    SELENIUM Check Component While OnAir
    ...    component_locator=${DETAILED_VIEW_CELL_OBJECT[${index}]}

SELENIUM Check RMOD Cells While RMOD Lock
    [Arguments]    ${rmod_id}
    :FOR    ${index}    IN RANGE    ${OUT_ADMIN_LNCELS_AMOUNT}
    \    ${status}    SELENIUM Check If Cell Is Connected With RMOD
    ...    cell_id=${index}
    ...    rmod_id=${rmod_id}
    \    Run Keyword If    ${status}
    ...    SELENIUM Check Component While Cell Lock
    ...    component_locator=${DETAILED_VIEW_CELL_OBJECT[${index}]}

SELENIUM Check RMOD Cells While RMOD Reset
    [Arguments]    ${rmod_id}
    :FOR    ${index}    IN RANGE    ${OUT_ADMIN_LNCELS_AMOUNT}
    \    ${status}    SELENIUM Check If Cell Is Connected With RMOD
    ...    cell_id=${index}
    ...    rmod_id=${rmod_id}
    \    Run Keyword If    ${status}
    ...    SELENIUM Check Component While Cell Reset
    ...    component_locator=${DETAILED_VIEW_CELL_OBJECT[${index}]}

SELENIUM Check RMOD While OnAir
    [Arguments]    ${rmod_id}
    SELENIUM Check Component While OnAir
    ...    component_locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}

SELENIUM Check RMOD While RMOD Reset
    [Arguments]    ${rmod_id}
    SELENIUM Check Component While RMOD Reset
    ...    component_locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}

SELENIUM Check RMOD While RMOD Lock
    [Arguments]    ${rmod_id}
    SELENIUM Check Component While RMOD Lock
    ...    component_locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}

SELENIUM Check If Acivate Plan Finished Successfully
    [Arguments]
    ...    ${timeout}=120
    Wait Until Element Is Visible
    ...    locator=${CONFIG_MGMNT_ACTIVATE_PLAN_SUCCESSFULLY}
    ...    timeout=${timeout}
    SELENIUM Pop Close

SELENIUM Check If Alarm Exists
    [Arguments]
    ...            ${fault_id}
    ${alarm_raised}     SELENIUM Is Alarm Raised    ${fault_id}
    should be true      ${alarm_raised}

SELENIUM Check If Alarm Not Exists
    [Arguments]
    ...            ${fault_id}
    ${alarm_raised}     SELENIUM Is Alarm Raised    ${fault_id}
    should not be true  ${alarm_raised}

SELENIUM Check If RMOD Is Not Configured In Detailed Site View
    [Arguments]
    ...    ${timeout}=10
    SELENIUM Go To Detailed Site View
    Wait Until Element is Visible
    ...    locator=${RUNTIME_VIEW_OBJECT_NOT_CONFIGURED}
    ...    timeout=${timeout}

SELENIUM Check If RMOD Is Visible In Detailed Site View
    [Arguments]
    ...    ${rmod_id}
    ...    ${timeout}=10
    SELENIUM Go To Detailed Site View
    Wait Until Element is Visible
    ...    locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}
    ...    timeout=${timeout}

SELENIUM Check SMOD While OnAir
    SELENIUM Check Component While OnAir
    ...    component_locator=${DETAILED_VIEW_SMOD_OBJECT}

SELENIUM Click Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=20s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Click Element
    ...    locator=${locator}

SELENIUM Collect Snapshot
    SELENIUM Go To Snapshot Tab
    SYSTEM Remove File From Directory
    ...    fileName=Snapshot_MRBTS-*
    ...    fileDirectory=/home/ute/Downloads
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_SNAPSHOT_BTN}
    Wait Until Element is Visible
    ...    timeout=360
    ...    locator=//label[contains(text(),'Collection completed')]
    Wait Until Keyword Succeeds
    ...    360
    ...    10
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=Snapshot_MRBTS-
    ...    fileDirectory=/home/ute/Downloads

SELENIUM Create New BTS Read Only User In User Account Management
    [Arguments]
    ...    ${alias}
    ...    ${password}
    SELENIUM Go To User Account Management
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_CHOOSE_ACCOUNT_LIST}
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_CHOOSE_ACCOUNT_READ_ONLY}
    SELENIUM Input Text in Visible Element
    ...    locator=${USER_ACC_MGMNT_ALIAS_INPUT}
    ...    text=${alias}
    SELENIUM Input Text in Visible Element
    ...    locator=${USER_ACC_MGMNT_PASSWORD_INPUT}
    ...    text=${password}
    SELENIUM Input Text in Visible Element
    ...    locator=${USER_ACC_MGMNT_PASSWORD_CONFIRM_INPUT}
    ...    text=${password}
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_ACCOUNT_STATE_LIST}
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_ACCOUNT_STATE_ACTIVE}
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_SAVE_BTN}
    Wait Until Element Is Visible
    ...    locator=${USER_ACC_MGMNT_PROCESS_COMPLETED_MSG}
    ...    timeout=60
    SELENIUM Click Visible Element
    ...    locator=${USER_ACC_MGMNT_CLOSE_BTN}

SELENIUM Download Help File
    SYSTEM Remove File From Directory
    ...    fileName=admin-help.pdf
    ...    fileDirectory=/home/ute/Downloads
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_OPTIONS}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_OPTIONS_HELP}
    Wait Until Keyword Succeeds
    ...    30
    ...    1
    ...    SYSTEM Check If File Is In Directory
    ...    fileName=admin-help.pdf
    ...    fileDirectory=/home/ute/Downloads

SELENIUM Export DISPLAY
   Set Environment Variable
   ...     name=DISPLAY
   ...     value=:99

SELENIUM Filter Alarms For Selected Object In Active Alarms
    [Arguments]    ${object_name}
    SELENIUM Input Text in Visible Element
    ...    locator=${ALARM_MGMNT_OBJECT_NAME_INPUT}
    ...    text=${object_name}

SELENIUM Get Text From Object
    [Arguments]
    ...    ${text_locator}
    ${text}    Get Text
    ...    locator=${text_locator}
    [Return]    ${text}

SELENIUM Get Text From Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    ${out_text}    Get Text
    ...    locator=${locator}
    [Return]    ${out_text}

SELENIUM Go To Active Alarms Tab
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS}
    SELENIUM Mouse Over Visible Element
    ...    locator=${NAVI_BAR_ALARMS_ALARM_MANAGEMENT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS_ACTIVE_ALARMS}

SELENIUM Go To Alarm History Tab
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS}
    SELENIUM Mouse Over Visible Element
    ...    locator=${NAVI_BAR_ALARMS_ALARM_MANAGEMENT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS_ALARM_HISTORY}

SELENIUM Go To Configuration Management
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION_MANAGEMENT}

SELENIUM Go to Configuration Reset
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION_RESET}
    Sleep  2

SELENIUM Go To Detailed Site View
    Run Keyword and Ignore Error  Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_BTS_STATUS}
    SELENIUM Mouse Over Visible Element
    ...    locator=${NAVI_BAR_BTS_STATUS_RUNTIME_VIEW}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_BTS_STATUS_DETAILED_VIEW}

SELENIUM Go To Diagnostic Site View
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_BTS_STATUS_DIAGNOSTIC}

SELENIUM Go To SFP Monitoring
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_DIAGNOSTIC}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_DIAGNOSTIC_SFP_MONITORING}

SELENIUM Go To Fault Toggling History Tab
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS}
    SELENIUM Mouse Over Visible Element
    ...    locator=${NAVI_BAR_ALARMS_ALARM_MANAGEMENT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_ALARMS_TOGGLING_HISTORY}

SELENIUM Go To IP Connectivity Test
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_DIAGNOSTIC}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONNECTIVITY_TEST}

SELENIUM Go To Parameter Editor
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION}
    SELENIUM Mouse Over Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION_MANAGEMENT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_CONFIGURATION_PARAM_EDITOR}

SELENIUM Go To Snapshot Tab
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_DIAGNOSTIC}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_SNAPSHOT}

SELENIUM Go To User Account Management
    Wait Until Element Is Not Visible
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_USER_ACCOUNT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_USER_ACCOUNT_MANAGEMENT}

SELENIUM Input Text in Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${text}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Input Text
    ...    locator=${locator}
    ...    text=${text}

SELENIUM Install Chromedriver
    Run
    ...    command=sudo cp /home/ute/trunk/selenium/chromedriver /usr/bin
    Run
    ...    command=sudo chmod +x /usr/bin/chromedriver

SELENIUM Is Alarm Raised
    [Arguments]
    ...            ${fault_id}
    ${out_alarms_objects_list}    Get WebElements
    ...    locator=//td[@class="ng-binding ng-scope fault-name-cell"][2]
    ${alarms_objects_len}    Get Length
    ...    item=${out_alarms_objects_list}
    :FOR    ${alarm}    IN RANGE    ${alarms_objects_len}
    \    ${webem_fault_detail}    Get Text
    ...    locator=(//td[@class="ng-binding ng-scope fault-id-cell"][2])[${alarm+1}]
    \    Run Keyword If    '${webem_fault_detail}' == '${fault_id}'
    ...    return from keyword    ${TRUE}
    return from keyword  ${FALSE}

SELENIUM Load SCF File
    [Arguments]
    ...    ${key}
    SELENIUM Go To Configuration Management
    Press Key
    ...    locator=${CONFIG_MGMNT_SCF_INPUT}
    ...    key=${key}
	Wait Until Keyword Succeeds
    ...    30
    ...    5
    ...    SELENIUM Pop Close

SELENIUM Lock RMOD
    [Arguments]
    ...    ${rmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}
    SELENIUM Click Visible Element
    ...    locator=${DETAILS_PANEL_LOCK_BTN}
    SELENIUM Pop Confirm Lock

SELENIUM Login To Web Element Manager
    [Arguments]    ${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    ...            ${browser_type}=chrome
    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    ...    url=${browser_url}
    ...    browser=${browser_type}
    ...    alias=${browser_alias}
    SELENIUM Confirm Not Secure Connection If Is Needed
    ${is_login_possible}    Run Keyword And Return Status    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...    text=${webem_username}
    Run Keyword Unless    ${is_login_possible}    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT_SBTS}
    ...    text=${webem_username}
    ${is_login_possible}    Run Keyword And Return Status    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...    text=${webem_password}
    Run Keyword Unless    ${is_login_possible}    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT_SBTS}
    ...    text=${webem_password}
    ${is_login_possible}    Run Keyword And Return Status    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN}
    Run Keyword Unless    ${is_login_possible}    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_SBTS}
    SELENIUM Pop Confirm
    Wait Until Page Does Not Contain Element
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Close Pop If Visible
    SELENIUM Click Visible Element
    ...    locator=//div[@class="ui-icon-svg ui-icon-full-screen"]
    SELENIUM Avoid Lock Screen

SELENIUM Login To Web Element Manager modified
    [Arguments]    ${browser_url}=${WEBEM_IP}
    ...            ${webem_username}=${USERNAME}
    ...            ${webem_password}=${PASSWORD}
    ...            ${browser_type}=chrome
    ...            ${browser_alias}=browser
    Set Selenium Implicit Wait    5
    Open Browser
    ...    url=${browser_url}
    ...    browser=${browser_type}
    ...    alias=${browser_alias}
    SELENIUM Confirm Not Secure Connection If Is Needed
    ${is_login_possible}    Run Keyword And Return Status    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT_modified}
    ...    text=${webem_username}
    Run Keyword Unless    ${is_login_possible}    SELENIUM Input Text in Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT_SBTS}
    ...    text=${webem_username}
    ${is_login_possible}    Run Keyword And Return Status    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT_modified}
    ...    text=${webem_password}
    Run Keyword Unless    ${is_login_possible}    Input Text
    ...    locator=${WELCOME_SCREEN_PASS_INPUT_SBTS}
    ...    text=${webem_password}
    ${is_login_possible}    Run Keyword And Return Status    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_modified}
    Run Keyword Unless    ${is_login_possible}    Click Element
    ...    locator=${WELCOME_SCREEN_LOGIN_BTN_SBTS}
    SELENIUM Pop Confirm
    Wait Until Page Does Not Contain Element
    ...    timeout=60
    ...    locator=//div[@class="notifyjs-corner"]//div
    SELENIUM Close Pop If Visible
    SELENIUM Click Visible Element
    ...    locator=//div[@class="ui-icon-svg ui-icon-full-screen"]
    SELENIUM Avoid Lock Screen


SELENIUM Logout User From Web Element Manager
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_USER_ACCOUNT}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_BAR_USER_ACCOUNT_LOGOUT}

SELENIUM Mouse Over Visible Element
    [Arguments]
    ...    ${locator}
    ...    ${timeout}=10s
    Wait Until Element Is Visible
    ...    locator=${locator}
    ...    timeout=${timeout}
    Mouse Over
    ...    locator=${locator}

SELENIUM Pop Close
    SELENIUM Click Visible Element
    ...    locator=${POP_CLOSE_BTN}

SELENIUM Close Pop If Visible
    ${is_pop_visible}    run keyword and return status
                         ...    Wait Until Element Is Visible
                            ...    locator=${POP_CLOSE_BTN}
                            ...    timeout=20s
    run keyword if  ${is_pop_visible}    SELENIUM Pop Close

SELENIUM Pop Confirm
    SELENIUM Click Visible Element
    ...    locator=${POP_CONFIRM_BTN}

SELENIUM Pop Confirm Lock
    SELENIUM Click Visible Element
    ...    locator=${POP_LOCK_BTN}

SELENIUM Pop Confirm Reset
    SELENIUM Click Visible Element
    ...    locator=${POP_RESET_CONFIRM_BTN}

SELENIUM Pop Confirm Unlock
    SELENIUM Click Visible Element
    ...    locator=${POP_UNLOCK_BTN}

SELENIUM Pop Execute
    SELENIUM Click Visible Element
    ...    locator=${POP_EXECUTE_BTN}

SELENIUM Pop Submit
    SELENIUM Click Visible Element
    ...    locator=${POP_SUBMIT_BTN}

SELENIUM Prepare Enviroment
    SELENIUM Install Chromedriver
    SELENIUM Run Xvfb
    SELENIUM Export DISPLAY

SELENIUM Remove Selected Object In Configuration Management
    [Arguments]
    ...    ${object_name}
    ...    ${object_to_remove}=//global-search//span[contains(text(), "${object_name}")]
    SELENIUM Go To Configuration Management
    SELENIUM Click Visible Element
    ...    locator=${NAVI_PANEL_OBJECTS}
    SELENIUM Input Text in Visible Element
    ...    locator=${NAVI_PANEL_OBJECT_NAME_INPUT}
    ...    text=${object_name}
    SELENIUM Click Visible Element
    ...    locator=${object_to_remove}
    SELENIUM Click Visible Element
    ...    locator=${NAVI_PANEL_REMOVE_OBJECT_BTN}
    SELENIUM Click Visible Element
    ...    locator=${POP_OBJECT_REMOVAL_ONLY_SELECTED_RBTN}
    SELENIUM Pop Submit

SELENIUM Reset BBMOD
    [Arguments]
    ...    ${bbmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_BBMOD_OBJECT[${bbmod_id}]}
    SELENIUM Click Visible Element
    ...    locator=${DETAILS_PANEL_RESET_BTN}
    SELENIUM Pop Confirm Reset

SELENIUM Reset GPS
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_GPS_OBJECT}
    SELENIUM Click Visible Element
    ...    locator=${DETAILS_PANEL_RESET_BTN}
    SELENIUM Pop Confirm Reset

SELENIUM Reset RMOD
    [Arguments]
    ...    ${rmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}
    SELENIUM Click Visible Element
    ...    locator=${DETAILS_PANEL_RESET_BTN}
    SELENIUM Pop Confirm Reset

SELENIUM Reset Site
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${RUNTIME_VIEW_RESET_SITE_BTN}
    SELENIUM Pop Confirm Reset

SELENIUM Run Xvfb
    Start Process
    ...    command=/usr/bin/Xvfb :99 -screen 0 1920x1080x16
    ...    shell=yes

SELENIUM Save BTS Configuration
    SELENIUM Go To Configuration Management
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_SAVE_BTS_CONFIGURATION_BTN}
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_SAVE_BTS_CONFIG_CONFIRM_BTN}

SELENIUM Select Critical Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_SELECT_CRITICAL_BTN}

SELENIUM Select Major Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_SELECT_MAJOR_BTN}

SELENIUM Select Minor Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_SELECT_MINOR_BTN}

SELENIUM Select Warning Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_SELECT_WARNINGS_BTN}

SELENIUM Teardown Enviroment
    Close All Browsers
    Terminate All Processes

SELENIUM Unlock RMOD
    [Arguments]
    ...    ${rmod_id}
    SELENIUM Go To Detailed Site View
    SELENIUM Click Visible Element
    ...    locator=${DETAILED_VIEW_RMOD_OBJECT[${rmod_id}]}
    SELENIUM Click Visible Element
    ...    locator=${DETAILS_PANEL_UNLOCK_BTN}
    SELENIUM Pop Confirm Unlock

SELENIUM Unselect Critical Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_UNSELECT_CRITICAL_BTN}

SELENIUM Unselect Major Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_UNSELECT_MAJOR_BTN}

SELENIUM Unselect Minor Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_UNSELECT_MINOR_BTN}

SELENIUM Unselect Warning Severity In Active Alarms
    SELENIUM Click Visible Element
    ...    locator=${ALARM_MGMNT_UNSELECT_WARNINGS_BTN}

SELENIUM Validate Plan
    SELENIUM Click Visible Element
    ...    locator=${CONFIG_MGMNT_VALIDATE_PLAN_BTN}

SELENIUM Wait Till BBMOD RMOD And Cell States Are OnAir
    [Arguments]    ${bbmod_id}
    Wait Until Keyword Succeeds
    ...    1200
    ...    5
    ...    SELENIUM Check BBMOD While OnAir
    ...    bbmod_id=${bbmod_id}
    :FOR    ${index}  IN RANGE  ${OUT_ADMIN_RMODS_AMOUNT}
    \    ${status}    SELENIUM Check If RMOD Is Connected With BBMOD
    ...    rmod_id=${index}
    ...    bbmod_id=${bbmod_id}
    \    Run Keyword If    ${status}
    ...    Wait Until Keyword Succeeds
    ...    600
    ...    5
    ...    SELENIUM Wait Till RMOD And Cell States Are OnAir
    ...    rmod_id=${index}

SELENIUM Wait Till BBMOD RMOD And Cell States Are Reset
    [Arguments]    ${bbmod_id}
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Run Keywords
    ...    SELENIUM Check BBMOD While BBMOD Reset
    ...    bbmod_id=${bbmod_id}    AND
    ...    SELENIUM Check RMOD And Cell States Are Reset
    ...    bbmod_id=${bbmod_id}

SELENIUM Wait Till RMOD And Cell States Are Lock
    [Arguments]    ${rmod_id}
    Wait Until Keyword Succeeds
    ...    120
    ...    5
    ...    Run Keywords
    ...    SELENIUM Check RMOD While RMOD Lock
    ...    rmod_id=${rmod_id}    AND
    ...    SELENIUM Check RMOD Cells While RMOD Lock
    ...    rmod_id=${rmod_id}

SELENIUM Wait Till RMOD And Cell States Are OnAir
    [Arguments]    ${rmod_id}
    Wait Until Keyword Succeeds
    ...    360
    ...    5
    ...    Run Keywords
    ...    SELENIUM Check RMOD While OnAir
    ...    rmod_id=${rmod_id}    AND
    ...    SELENIUM Check RMOD Cells While OnAir
    ...    rmod_id=${rmod_id}

SELENIUM Wait Till RMOD And Cell States Are Reset
    [Arguments]    ${rmod_id}
    Wait Until Keyword Succeeds
    ...    120
    ...    5
    ...    Run Keywords
    ...    SELENIUM Check RMOD While RMOD Reset
    ...    rmod_id=${rmod_id}    AND
    ...    SELENIUM Check RMOD Cells While RMOD Reset
    ...    rmod_id=${rmod_id}

SELENIUM Confirm Not Secure Connection Google Chrome
    Click Element
    ...    locator=//button[contains(text(),'Advanced')]
    SELENIUM Click Visible Element
    ...    locator=//*[@id="proceed-link"]

SELENIUM Confirm Not Secure Connection Mozilla Firefox
    Click Element
    ...    locator=//*[@id="advancedButton"]
    SELENIUM Click Visible Element
    ...    locator=//*[@id="exceptionDialogButton"]

SELENIUM Confirm Not Secure Connection If Is Needed
    ${status}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//button[contains(text(),'Advanced')]
    ...    timeout=15
    Run Keyword If    ${status}    SELENIUM Confirm Not Secure Connection Google Chrome
