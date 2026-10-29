*** Settings ***
Documentation
...    Testsuite for regression testing of feature CB009512-B part 1: TC07, TC14, TC19, TC21.
...    author: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com
...    maintainer: Lukasz Wlosowicz, lukasz.wlosowicz@nokia.com

Resource    ./resources/keywords-B.robot

Suite Setup    Run keywords
...    Common suite setup with OnAir test line preparation
       ...    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
       ...    increase_timeout_for_update_sw=900
       ...    increase_time_for_checking_cells=600
       ...    prefix_tag=CB010652-C    AND
...    Get SW release from BTS and set NetAct MRBTS release variable    AND
...    Integrate to NetAct and activate user accounts on BTS    AND
...    Set passwords and activate BTSSecurity BTSApplication and BTSRead users on BTS

Suite Teardown    Run keywords
...    Deactivate CNUM and deintegrate from NetAct    AND
...    Common suite teardown


*** Test Cases ***
[1][3.0] CB009512-B-SR-07-Login_to_gNB_using_CNUM_user_with_read-only_access_mode
    [Setup]    Run keywords
    ...        keywords-B.Set allowed alarms    AND
    ...        keywords-B.Set allowed alarms for ASiR    AND
    ...        Common preconditions with watching alarms    AND
    ...        AsirWebEM.Clean browser    AND
    ...        AsirWebEM.Set virtual enable    virtual_enable=${VIRTUAL_DISPLAY}
    Log    IF FOLLOWING LOGIN FAILS, PLEASE DOUBLECHECK THAT CNUM USERS ARE CONFIGURED ON THE NETACT CLAB.    console=${True}
    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${True}    user_name=${CNUM_SYS_ADMIN_USERNAME}
    ...    user_password=${CNUM_SYS_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_SYS_ADMIN_USERNAME}    expected_role=BTS System Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    AsirWebem.Enter config man    sub_menu=view
    AsirWebem.Enter config man    sub_menu=save
    AsirWebEM.Logout

    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${True}    user_name=${CNUM_SEC_ADMIN_USERNAME}
    ...    user_password=${CNUM_SEC_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_SEC_ADMIN_USERNAME}    expected_role=BTS Security Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    AsirWebem.Enter config man    sub_menu=view
    AsirWebem.Enter config man    sub_menu=save
    AsirWebEM.Logout

    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${True}    user_name=${CNUM_APP_ADMIN_USERNAME}
    ...    user_password=${CNUM_APP_ADMIN_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_APP_ADMIN_USERNAME}    expected_role=BTS Application Administrator
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    AsirWebem.Enter config man    sub_menu=view
    AsirWebem.Enter config man    sub_menu=save
    AsirWebEM.Logout

    AsirWebEM.Login with downgraded privileges    read_only_checkbox=${True}    user_name=${CNUM_READ_ONLY_USER_USERNAME}
    ...    user_password=${CNUM_READ_ONLY_USER_PASSWORD}
    Verify username role and access mode in ASiR WebEM    expected_access_mode=Read-only
    ...    expected_username=${CNUM_READ_ONLY_USER_USERNAME}    expected_role=BTS Read-Only User
    keywords-B.Verify config man button status    ${EXPECTED_ACTIVE_BUTTONS_READ_ONLY}
    AsirWebem.Enter config man    sub_menu=view
    AsirWebem.Enter config man    sub_menu=save
    [Teardown]    Run keywords
    ...    AsirWebEM.Logout    AND
    ...    AsirWebEM.Clean browser    AND
    ...    Common postconditions with watching alarms

[1][3.0] CB009512-B-SR-14-Verification_with_ASiR_WebEM-Activation of Local User Accounts from WebEM by Security Administrator
    [Setup]    Setup for TC14
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    username=BTSSecurity    password=${SEC_ADMIN_PASSWORD}
    ...    use_ssl=${USE_SSL}    name=SEC_adm_conn
    admin.Set user account    old_username=BTSApplication    old_password=${SEC_ADMIN_PASSWORD}    new_username=app_alias
    ...    new_password=${APP_ADMIN_PASSWORD_TC14}    connection=SEC_adm_conn    timeout=${120}
    admin.Set user account    old_username=BTSRead    old_password=${SEC_ADMIN_PASSWORD}    new_username=read_alias
    ...    new_password=${READ_ONLY_USER_PASSWORD_TC14}    connection=SEC_adm_conn    timeout=${120}
    admin.Set user account    old_username=BTSSecurity    old_password=${SEC_ADMIN_PASSWORD}    new_username=sec_alias
    ...    new_password=${SEC_ADMIN_PASSWORD}    connection=SEC_adm_conn    timeout=${120}
    Set appAdmActivated and readOnlyActivated to true via Security Admin
    Verify access to ASiR WebEM's functionalities for Local System Admin
    Verify access to ASiR WebEM's functionalities for Local Security Admin
    Verify access to ASiR WebEM's functionalities for Local Application Admin
    Verify access to ASiR WebEM's functionalities for Local Read-only User
    Verify access to ASiR WebEM's functionalities for CNUM System Admin
    Verify access to ASiR WebEM's functionalities for CNUM Security Admin
    Verify access to ASiR WebEM's functionalities for CNUM Application Admin
    Verify access to ASiR WebEM's functionalities for CNUM Read-only User
	[Teardown]    Run keywords
    ...    AsirWebEM.Logout    AND
    ...    AsirWebEM.Clean browser    AND
    ...    Common postconditions with watching alarms    AND
    ...    admin.Set user account    old_username=BTSApplication    old_password=${SEC_ADMIN_PASSWORD}    new_username=app_alias
           ...    new_password=${APP_ADMIN_PASSWORD}    connection=SEC_adm_conn    timeout=${120}    AND
    ...    admin.Set user account    old_username=BTSRead    old_password=${SEC_ADMIN_PASSWORD}    new_username=read_alias
           ...    new_password=${READ_ONLY_USER_PASSWORD}    connection=SEC_adm_conn    timeout=${120}    AND
	...    admin.Teardown admin    connection=SYS_adm_conn    AND
    ...    admin.Teardown admin    connection=SEC_adm_conn

[1][3.0] CB009512-B-SR-19-Verification_with_ASiR_WebEM-Deactivation of Local User Accounts from WebEM by System Administrator CNUM user
    [Setup]    Setup for TC19
    admin.Setup admin    bts_host=${BTS_ADDRESS}    bts_port=${BTS_PORT}    username=${CNUM_SYS_ADMIN_USERNAME}
    ...    password=${CNUM_SYS_ADMIN_PASSWORD}    use_ssl=${USE_SSL}    name=CNUM_sys_adm_conn
    Verify login error message for user    Nemuadmin         nemuuser                      ${LOGIN_RESTRICTED_TO_CNUM_ERR_MESSAGE}
    Verify login error message for user    BTSSecurity       ${SEC_ADMIN_PASSWORD}         ${LOGIN_RESTRICTED_TO_CNUM_ERR_MESSAGE}
    Verify login error message for user    BTSApplication    ${APP_ADMIN_PASSWORD}         ${LOGIN_RESTRICTED_TO_CNUM_ERR_MESSAGE}
    Verify login error message for user    BTSRead           ${READ_ONLY_USER_PASSWORD}    ${LOGIN_RESTRICTED_TO_CNUM_ERR_MESSAGE}
    Set secAdmActivated appAdmActivated and readOnlyActivated to false
    Set actRestrictLoginToCnum    value=false    admin_alias=CNUM_sys_adm_conn
    Verify login error message for user    BTSSecurity       ${SEC_ADMIN_PASSWORD}         Account is disabled
    Verify login error message for user    BTSApplication    ${APP_ADMIN_PASSWORD}         Account is disabled
    Verify login error message for user    BTSRead           ${READ_ONLY_USER_PASSWORD}    Account is disabled
    Verify access to ASiR WebEM's functionalities for CNUM System Admin
    Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Security Admin
    Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Application Admin
    Verify that access to ASiR WebEM's functionalities is degraded to read-only for CNUM Read-only User
    [Teardown]    Teardown for TC19

[1][1.0] CB009512-B-SR-21-Verify_ASiR_WebEM_Login_Delay
    [Setup]    Run keywords
    ...        keywords-B.Set allowed alarms    AND
    ...        keywords-B.Set allowed alarms for ASiR    AND
    ...        Common preconditions with watching alarms    AND
    ...        AsirWebEM.Clean browser    AND
    ...        AsirWebEM.Set virtual enable    virtual_enable=${VIRTUAL_DISPLAY}
    Modify webEMSessionLoginDelay on ASiR if needed    10
    commissioning.Perform parameter recommissioning    MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1    btsSessionLoginDelay    update    1
    ${first_login_error_message}=    AsirWebEM.Login and return error message    user_name=Nemuadmin    user_password=sdkjfhsf
    Should be equal as strings    ${first_login_error_message}    Resource owner credentials are invalid.
    ...    msg=Login error message different than expected
    ${second_login_error_message}=    AsirWebEM.Login and return error message    user_name=Nemuadmin    user_password=nemuuser
    Should be equal as strings    ${second_login_error_message}    Access denied due to pending ASiR WebEM login delay.
    ...    msg=Login error message different than expected. Please check in logs that 10 seconds timer didn't expire between login attempts.
    [Teardown]    Run keywords
    ...           AsirWebEM.Clean browser    AND
    ...           Restore webEMSessionLoginDelay on ASiR if needed    AND
    ...           Common postconditions with watching alarms
