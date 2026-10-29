*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB007672-H feature.

Resource     ../../../common_resources/admin/admin.robot
Resource     ../../../common_resources/alarms/alarm.robot
Library      taf.config.scf                             WITH NAME   scf
Library      taf.sbts.oam.coam.admin                    WITH NAME   coam_admin
Library      taf.fdsw.rc                                WITH NAME    rescue
Library      taf.transport.ssh                          WITH NAME    ssh

*** Variables ***
${default_admin_password}=    nemuuser
@{WHITELIST2}=    &{FAULT_7305}    &{FAULT_7300}    &{FAULT_7100}    &{FAULT_7103}    &{FAULT_7523}
&{FAULT_7305}              fault_id=7305
...                        alarm_id=7107
...                        alarm_severity=regex"Critical|Warning|Minor|Major"
...                        fault_name="NG SCTP setup fail"
...                        notifier=
&{FAULT_7300}              fault_id=7300
...                        alarm_id=7107
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="No X2 link available"
...                        notifier=
&{FAULT_7100}              fault_id=7100
...                        alarm_id=7114
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="F1 Cell activation failed due to X2 link unavailable"
...                        notifier=
&{FAULT_7103}              fault_id=7103
...                        alarm_id=7114
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="SA cell activation failed"
...                        notifier=
&{FAULT_7523}              fault_id=7523
...                        alarm_id=7115
...                        alarm_severity=regex"Warning|Minor|Major"
...                        fault_name="Cell Activation timeout at gNB-DU"
...                        notifier=


${DELTA_2}    /home/ute/MN/UTE/robotws/testsuite/Wroclaw/TRS/RAN_5G/features/CB007672-H/resources/reset.json
${LOGOUT}    //*[contains(text(), "Unable to display BTS hardware and cells information due to missing, incomplete, or invalid BTS data.")]
${ALLOWSYSADMIN}    //wizard-parameter-input-cell[@ng-if="$ctrl.allowSysAdminDefaultPasswordParameterExists"]/div/div[2]/div/n-checkbox/div/label/span
${UPDATE_DEFAULT_PASSWORD_SUCCESFULL}    //span[contains(text(), 'Default password is updated successfully, please login with the new password.')]
${MSG_PASSWORD_IS_ALREADY_UPDATED}    //span[contains(text(), "Default password is updated by another user, please login with correct password")]
${UPDATE_DEFAULT_PASSWORD_INFO}    //*[contains(text(), "Please update the default password as it's not allowed to be used anymore.")]
${WEBEM_IP}                                          https://192.168.255.129:443
${WELCOME_SCREEN_USERNAME_INPUT}=                    //*[@id="login-username"]
${WELCOME_SCREEN_PASS_INPUT}=                        //*[@id="login-password"]
${WELCOME_SCREEN_LOGIN_BTN}=                         //span[contains(text(), 'Login')]
${CONFIRM_BUTTON}=                                   //ui-button[@a-text="Confirm"]
${NEMUADMIN_NAME}                                    Nemuadmin
${NEMUADMIN_PASSWORD}                                nemuuser
${NEWPASSWORD}                                       Nokia123$
${NEWPASSWORD_INVALID}                               Nokia
${INVALID_OLD_PASSWORD}                              NemuuseR
${OLD_PASSWORD_INPUT}                                //input[@name="oldPassword"]
${NEW_PASSWORD_INPUT}                                //input[@name="password"]
${CONFIRM_NEW_PASSWORD_INPUT}                        //input[@name="confirmPassword"]
${BUTTON_UPDATE_PASSWORD}                            //span[contains(text(), "Update Password")]
${BUTTON_DISCONNECT}                                 //span[contains(text(), "Disconnect")]
${UPDATE_PASSWORD}                                   //button[@ng-reflect-label="Update"]
${VALIDATION_RULES}                                  //div[contains(text(), " New password validation rules ")]
${AUTHENTICATION_FAILED}                             //span[contains(text(), "Authentication failed, please try again")]
${DIFFERENT_NEW_AND_CONFIRM_PASSWORD}                //small[contains(text(), "Confirm password must be identical with the new password.")]
${MSG_AUTHENTIACION_EXPIRED}                         //span[contains(text(), "Authentication has expired, please re-login")]
${ASOF_VM_IP}                                        10.44.149.53
*** Keywords ***
Upload default scf
    [Arguments]    ${scf_path}
    ${connection}=  admin.Connect to ADMIN    password=${default_admin_password}
    log    Uploading scf  console=true
    coam_admin.perform_commissioning    scf_file=${scf_path}  skip_parameter_relation_errors=False  should_activate=True
    ...    timeout=900  connection=${connection}
    [Teardown]    admin.Disconnect from ADMIN

Reset Local User Credentials
    [Arguments]    ${scf_path}
	${connection}=        ssh.connect_to    ${LMP_IP}    ${ROOT_USERNAME}   ${ROOT_PASSWORD}
	Log                   Reseting counter to prevent SW Fallback     console=${TRUE}
	ssh.execute           command=ddal -s ddal_boot_set_reset_loop_count 0
	...                   connection=${connection}
	Log                   Removing file: /ffs/run/config/..    console=${TRUE}
	${console_output}=    ssh.execute                     command=rm -rf /ffs/run/config/
	...                                                   connection=${connection}
	Should Not Contain    ${console_output}               No such file or directory
	Log                   File removed, rebooting BTS     console=${TRUE}
	ssh.execute           command=ddal -s ddal_reboot_sm_site_graceful DDAL_REBOOT_SM_SHELF_SIDE_OWN
	...                   connection=${connection}
	Log                   Default credentails restored    console=${TRUE}
	[Teardown]    Run keywords  	run keyword and ignore error    ssh.disconnect    connection=${connection}
	...    AND    wait until keyword succeeds    5min    60sec    Upload default scf  ${scf_path}
	...    AND    Wait until BTS reach Configured or OnAir state


Restore default admin password
    [Arguments]    ${scf_path}    ${new_pass}    ${new_username}=Nemuadmin
    log    Restoring password  console=true
    ${connection}=  coam_admin.connect_to   bts_host=192.168.255.129  username=${new_username}  password=${new_pass}
    log    connected    console=true
    ${cos}=    Run Keyword And Ignore Error    coam_admin.reset_configuration    remove_user_account_credentials=True
    ...                         remove_site_id=True
    ...                         remove_security_credentials=True
    ...                         timeout=1800
    ...                         connection=${connection}
    ...                         detailed_output=true
    log    configuration reseted    console=true
    log    ${cos}    console=true
    ${conn}=  Wait until keyword succeeds    10min    1min    rescue.connect_to   ip_address=192.168.255.129  port=443
    ...                                                                           username=${new_username}  password=${new_pass}
    ${active}=  rescue.get_active_sw_partition  connection=${conn}
    ${options}=    rescue.get_available_reset_options  slot_id=${active}     connection=${conn}
    ${reset type}=    Get Proper Reset Type    remove_user_account_credentials=True
    rescue.software_rollback    sw_slot_id=${active}    timeout=600    connection=${conn}    reset_type=${reset type}
    Log    sw_uploaded    console=true
    ${connection}=    Wait until keyword succeeds    10min    1min    coam_admin.connect_to   bts_host=192.168.255.129    password=nemuuser
    [Teardown]    Run keywords      Upload default scf  ${scf_path}
    ...    AND    Wait until BTS reach Configured or OnAir state     connection=${connection}
    ...    AND    Run Keyword And Ignore Error    admin.Disconnect from ADMIN    ${connection}

Get Proper Reset Type
    [Arguments]    ${remove_operator_certificates}=False    ${remove_user_account_credentials}=False    ${repair_center_reset}=False
    ${reset_type}    Set Variable If    ${repair_center_reset}    RepairCenterReset
    ...    ${remove_operator_certificates} and ${remove_user_account_credentials}   WithCertsAndCredsFromActive
    ...    ${remove_operator_certificates}    WithCertFromActive
    ...    ${remove_user_account_credentials}    WithCredsFromActive
    ...    FromActive
    [Return]    ${reset_type}

Get State AllowSysAdminDefaultPassword
    [Arguments]    ${connection}
    ${scf_file}=   coam_admin.get_current_scf_file   local_dir_path=${OUTPUT_DIR}/${TEST_NAME}    file_name=SCFC.xml
    ...   export_type=configuration
    ...   connection=${connection}
    scf.load_scf    ${OUTPUT_DIR}/${TEST_NAME}/SCFC.xml
    ${state}=    scf.get_value_from_scf    dist_name=MRBTS-${mrbts}/MNL-1/AMGR-1/LUAC-1   p_name=allowSysAdminDefaultPassword
    [Return]    ${state}

Open User Account Management In Commisioning Wizard
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.configuration.TITLE"]
    Click Element    locator=//span[text()="Configuration Management"]//following-sibling::i[@class="nav-expand-icon ng-scope"]
    Click Element    locator=//*[@heading="Steps"]
    Click Element    locator=//div[@title="Security"]
    Click Element    locator=//div[@title="User Account Management"]

Log In With New Credentials
    [Arguments]    ${Username}    ${Password}
    SELENIUM Input Text In Visible Element
    ...    locator=${WELCOME_SCREEN_USERNAME_INPUT}
    ...    text=${Username}
    SELENIUM Input Text In Visible Element
    ...    locator=${WELCOME_SCREEN_PASS_INPUT}
    ...    text=${Password}
    Click Element
    ...       locator=${WELCOME_SCREEN_LOGIN_BTN}
    Wait Until Element Is Visible
    ...       locator=${CONFIRM_BUTTON}
    ...       timeout=40
    Click Element    locator=${CONFIRM_BUTTON}
    ${reload}=    Run Keyword And Return Status    Element Should Be Visible    locator=//button[contains(text(),'Close')]
    Run Keyword If    '${reload}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]
    ${plug}=    Run Keyword And Return Status    Element Should Be Visible    locator=//h4[@title="Plug and Play"]
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Cancel')]

Changing Parameter AllowSysAdmin In Other Session With Reset Site
    Login To Web Element Manager
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Open User Account Management In Commisioning Wizard
    Click Element
    ...    locator=${ALLOWSYSADMIN}
    SELENIUM Click Enable Element
    ...    locator=//ui-button[@a-text="Done"]
    Activate Plan
    SELENIUM Reset Site
    Wait Until Keyword Succeeds  60  10
    ...    Element Should Be Visible
    ...    ${LOGOUT}
#    Close Browser

Changing Parameter AllowSysAdmin In Other Session
    Login To Web Element Manager
    ...    login=${NEMUADMIN_NAME}
    ...    password=${NEMUADMIN_PASSWORD}
    Open User Account Management In Commisioning Wizard
    Click Element
    ...    locator=${ALLOWSYSADMIN}
    SELENIUM Click Enable Element
    ...    locator=//ui-button[@a-text="Done"]
    Activate Plan
#    Close Browser

SYSTEM Execute Command On IPHY
    [Arguments]    ${command}
    taf.transport.ssh.connect_to
    ...    hostname=192.168.200.1
    ...    username=toor4nsn
    ...    password=oZPS0POrRieRtu
    ...    alias=iphy
    ${reply}    Run Keyword And Return    taf.transport.ssh.execute
    ...    command=${command}
    ...    connection=iphy
    taf.transport.ssh.Disconnect   iphy
    [Return]    ${reply}
