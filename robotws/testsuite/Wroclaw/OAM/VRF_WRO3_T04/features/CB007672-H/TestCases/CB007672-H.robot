*** Settings ***
Documentation
...     description:    Test cases for the CB007672-H feature.

Library    SeleniumLibrary
Library    Process
Library    taf.config.scf   WITH NAME  scf
Library    taf.transport.ssh
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/selenium/selenium.robot
Library     ../../../common_resources/selenium/selenium_operations.py
Resource    ../resources/CB007672-H.robot
Library     ../resources/CB007672-H.py
Library     taf.sbts.oam.coam.admin    WITH NAME    coam_admin


*** Keywords ***
CB007672-H-SyVe_suppressing_mandatory_pasword_update
    [Documentation]    This testcase checks if updating default password is not enforced by default
    ${value}=  Check current parameter value    dist_name=MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1
    ...                                         param_name=allowSysAdminDefaultPassword
    Should be true    ${value}[0]
    admin.Connect to ADMIN
    [Teardown]    admin.Disconnect from ADMIN

CB007672-H-SyVe_enforcing_mandatory_pasword_update
    [Documentation]    This testcase checks if updating default password is enforced when parameter is activated
    Log   Collecting scf    console=true
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
    Change Parameter on BTS    MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1  allowSysAdminDefaultPassword  false  connection=${connection}
    Run Keyword And Expect Error    STARTS:AdminApiConnectionClosedException: Cannot establish socket connection.  admin.Connect to ADMIN
    ${driver}=  CB007672-H.Log To Webem    Nemuadmin  password=${default_admin_password}
    Check If Update Window Appears   ${driver}  ${sw_release}
    Update With Incorrect Old Password    ${driver}  ${sw_release}
    Update With Different New Passwords    ${driver}  ${sw_release}
    Update With Incorrect New Password    ${driver}  ${sw_release}
    ${driver2}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver2}  ${sw_release}
    ${new_pass}=  Update Password   ${driver2}  ${sw_release}    Qwerty12#
    ${connection}=    coam_admin.connect_to   bts_host=192.168.255.129    username=Nemuadmin  password=${new_pass}
    Log    ${new_pass}  console=true
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

Viewing_Modifying Allow System Administrator Default Password Parameter
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
    ${driver}=  CB007672-H.Log To Webem    Nemuadmin  password=${default_admin_password}
    Confirm button    ${driver}
    Open User Account Management    ${driver}
    System admin def pass   ${driver}
    Plan activation     ${driver}
    ${state_allowsysadmin}=  Get State AllowSysAdminDefaultPassword    ${connection}
    Should Be Equal As Strings    ${state_allowsysadmin}    False
    Sleep    10
    Open User Account Management    ${driver}
    System admin def pass   ${driver}
    Plan activation     ${driver}
    ${state_allowsysadmin}=  Get State AllowSysAdminDefaultPassword    ${connection}
    Should Be Equal As Strings    ${state_allowsysadmin}    True


Operator Is Redirected To Update Default Password Page
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
    ${driver}=  CB007672-H.Log To Webem    Nemuadmin  password=${default_admin_password}
    Confirm button    ${driver}
    Open User Account Management    ${driver}
    System admin def pass   ${driver}
    Plan activation     ${driver}
    ${driver2}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver2}  ${sw_release}
    ${new_pass}=  Update Password   ${driver2}  ${sw_release}    Qwerty12#
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

Update Default Password With Input Valid New Password
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Login To Web Element Manager Quick
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Click Enable Element
    ...    locator=${UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${UPDATE_DEFAULT_PASSWORD_SUCCESFULL}
    Log In With New Credentials     Nemuadmin    ${NEWPASSWORD}
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

Update Default Password Is Not Possible
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Change Parameter on BTS    MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1  allowSysAdminDefaultPassword  false
    Login To Web Element Manager Quick
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD_INVALID}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD_INVALID}
    Element Should Be Disabled
    ...    ${UPDATE_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD_INVALID}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${DIFFERENT_NEW_AND_CONFIRM_PASSWORD}
    Element Should Be Disabled
    ...    ${UPDATE_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${INVALID_OLD_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Click Enable Element
    ...    locator=${UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${AUTHENTICATION_FAILED}
    ${driver2}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver2}  ${sw_release}
    ${new_pass}=  Update Password   ${driver2}  ${sw_release}    Qwerty12#
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

Update Default Password In Another Concurrent Session
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Log    ${sw_release}    console=true
    Wait Until Keyword Succeeds  30 min  60 sec  Change Parameter on BTS    MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1  allowSysAdminDefaultPassword
    ...     false
    ${driver}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver}  ${sw_release}
    ${driver2}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver2}  ${sw_release}
    ${new_pass}=  Update Password   ${driver}  ${sw_release}    Qwerty12#
    ${new_pass}=  Update Password   ${driver2}  ${sw_release}    Qwerty12#    close=0
    Password is already updated    ${driver2}
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

Update Default Password After Session Termination
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    ${sw_release}=  Get Software Release Name
    Wait Until Keyword Succeeds  30 min  60 sec  Change Parameter on BTS    MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1  allowSysAdminDefaultPassword
    ...     false
    Login To Web Element Manager Quick
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    Sleep    10min
    SELENIUM Click Enable Element
    ...    locator=${UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${MSG_AUTHENTIACION_EXPIRED}
    ${driver2}=  CB007672-H.Log To Webem    Nemuadmin  nemuuser
    Check If Update Window Appears   ${driver2}  ${sw_release}
    ${new_pass}=  Update Password   ${driver2}  ${sw_release}    Qwerty12#
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

WebEM Display Notification To Update Default Password After Changing Parameter In Other Session
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Login To Web Element Manager
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Changing Parameter AllowSysAdmin In Other Session With Reset Site
    Switch Browser    1
    Wait Until Keyword Succeeds  300  20
    ...    Element Should Be Visible
    ...    //span[contains(text(), "Update default password")]
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_DISCONNECT}
    SELENIUM Click Enable Element
    ...    locator=${BUTTON_UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Click Enable Element
    ...    locator=${UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${UPDATE_DEFAULT_PASSWORD_SUCCESFULL}
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

WebEM Display Notification To Update Default Password After Reconfiguration
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Login To Web Element Manager
    ...    login=${Nemuadmin_name}
    ...    password=${Nemuadmin_password}
    &{linkSpeed_param_dict}=   Create Dictionary    parameterName=linkSpeed                       operation=update    value=Auto
    &{allowSys_param_dict}=    Create Dictionary    parameterName=allowSysAdminDefaultPassword    operation=update    value=false
    Log   ${linkSpeed_param_dict}  console=true
    Log   ${allowSys_param_dict}  console=true

    &{linkSpeed_dict}=    Create Dictionary     distName=MRBTS-${mrbts}/EQM-1/HWTOP-1/CABLINK-1
    ...                                         operation=update
    ...                                         parameters=@{linkSpeed_param_dict}

    &{allowSys_dict}=    Create Dictionary      distName=MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1
    ...                                         operation=update
    ...                                         parameters=@{allowSys_param_dict}

    Log  ${linkSpeed_dict}  console=true
    @{delta}=    Create List    ${linkSpeed_dict}    ${allowSys_dict}
    Log  ${delta}  console=true
    coam_admin.Perform Delta Recommissioning
    ...    delta_file=${delta}
    ...    timeout=300
    ...    skip_parameter_relation_errors=True
    ...    connection=${connection}
    Wait Until Keyword Succeeds  300  20
    ...    Element Should Be Visible
    ...    //span[contains(text(), "Update default password")]
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_DISCONNECT}
    SELENIUM Click Enable Element
    ...    locator=${BUTTON_DISCONNECT}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${WELCOME_SCREEN_USERNAME_INPUT}
    Login To Web Element Manager Quick
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    SELENIUM Input Text In Visible Element
    ...    locator=${OLD_PASSWORD_INPUT}
    ...    text=${NEMUADMIN_PASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Input Text In Visible Element
    ...    locator=${CONFIRM_NEW_PASSWORD_INPUT}
    ...    text=${NEWPASSWORD}
    SELENIUM Click Enable Element
    ...    locator=${UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${UPDATE_DEFAULT_PASSWORD_SUCCESFULL}
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}

WebEM Display Notification To Update Default Password After Manual Reconnection
    ${connection}=  admin.Connect to ADMIN
    ${scf_path}=  admin.Download SCF  connection=${connection}
    Login To Web Element Manager
    ...    login=${Nemuadmin_name}
    ...    password=${Nemuadmin_password}
    SELENIUM Click Enable Element
    ...    locator=//*[@class="fa fa-ellipsis-v"]
    SELENIUM Click Enable Element
    ...    locator=//*[contains(text(), ' Disconnect')]
    ${driver}=  CB007672-H.Log To Webem    Nemuadmin  password=${default_admin_password}
    Confirm button    ${driver}
    Open User Account Management    ${driver}
    System admin def pass   ${driver}
    Plan activation     ${driver}
    Sleep    10
    Switch Browser    1
    SELENIUM Click Enable Element
    ...    locator=//*[@class="fa fa-ellipsis-v"]
    SELENIUM Click Enable Element
    ...    locator=//*[@aria-label="Connect Button"]
     Wait Until Keyword Succeeds  300  20
    ...    Element Should Be Visible
    ...    //span[contains(text(), "Update default password")]
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  100  20
    ...    Element Should Be Visible
    ...    ${BUTTON_DISCONNECT}
    SELENIUM Click Enable Element
    ...    locator=${BUTTON_UPDATE_PASSWORD}
    Wait Until Keyword Succeeds  20  1
    ...    Element Should Be Visible
    ...    ${VALIDATION_RULES}
    [Teardown]   Run Keyword    Reset Local User Credentials    ${scf_path}
