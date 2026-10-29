*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB012224. CB012224 verifies the contents of

Resource    ../Resources/CB012224.robot
Resource     ../../../common_resources/connections/connections.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/commissioning/commissioning.robot
Library      taf.sbts.oam.coam.admin    WITH NAME   coam_admin

*** Variables ***
${account_type}=              BtsSecurity
${allowed_lifetime}=          10
${allowed_idle_period}=       5
@{ACCOUNTS_IDLE_LIFETIME}=    Nemuadmin    BTSSecurity    BTSApplication    BTSRead
${delta}=                     ${CURDIR}/Wroclaw/OAM/features/CB012224/Resources/delta.json
${scf_file}=                  ${CURDIR}/scf.xml
${nemuadmin}=                 Nemuadmin

*** Keywords ***
CB012224-A_#01_Role_activation_and_deactivation_time_update
    Log    Step 1: Login to WebEM as System Administrator    console=true
    ${connection}=    Connect to ADMIN
    Log    Step 2: Activation of the inactive role for one of local human account from WebEM    console=true
    Run Keyword And Ignore Error
    ...                                  coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=false
    ...                                  connection=${connection}
    Wait Until Keyword Succeeds          10min   30s
    ...                                  coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=true
    ...                                  connection=${connection}
    Log    Step 3: Checing if the Role Activation Time has been updated    console=true
    ${rep_act_before}=     coam_admin.get_account_status_report     connection=${connection}
    ${act_time_before}=    Check Reported Activation Time    report=${rep_act_before}    account_type=${account_type}
    Log    Step 4: Reset the BTS    console=true
    coam_admin.Reset Site      connection=${connection}    timeout=600
    Wait until BTS reach Configured or OnAir state    ${connection}
    Log    Step 5: Checing if the Role Activation Timeis the same before and after restart    console=true
    ${rep_act_after}=    coam_admin.get_account_status_report     connection=${connection}
    ${act_time_after}=    Check Reported Activation Time    report=${rep_act_after}    account_type=${account_type}
    Should Be Equal    ${act_time_before}    ${act_time_after}
    Log    Step 6: Deactivation of the active role for one of local human account from WebEM    console=true
    Wait Until Keyword Succeeds          10min   30s
    ...                                  coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=false
    ...                                  connection=${connection}
    Log    Step 7: Checing if the Role Deactivation Time has been updated    console=true
    ${rep_deact_before}=    coam_admin.get_account_status_report     connection=${connection}
    ${deact_time_before}=    Check Reported Deactivation Time   report=${rep_act_before}    account_type=${account_type}
    Log    Step 8: Reset the BTS    console=true
    coam_admin.Reset Site      connection=${connection}    timeout=600
    Wait until BTS reach Configured or OnAir state    ${connection}
    Log    Step 9: Checing if the Role Deactivation Timeis the same before and after restart    console=true
    ${rep_deact_after}=    coam_admin.get_account_status_report     connection=${connection}
    ${deact_time_after}=    Check Reported Deactivation Time    report=${rep_act_after}    account_type=${account_type}
    Should Be Equal    ${deact_time_before}    ${deact_time_after}
    [Teardown]    Run keywords           coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=false
    ...                                  connection=${connection}
    ...    AND                           Disconnect from ADMIN    ${connection}

CB012224-A_02_Local_user_accounts_status_report-triggering_and_exporting
    Log    Step 1: Login to WebEM as System Administrator    console=true
    ${connection}=    Connect to ADMIN
    Log    Step 2: Generate local user accounts status report    console=true
    ${report}=    coam_admin.get_account_status_report     connection=${connection}
    Log    Step 3: Check if report contains the list of data defined in the requirement    console=true
    Check Local Account State Report Content    ${report}
    Log    Step 4: Change "Allowed lifetime" and "Allowed idle period" parameters    console=true
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                                  localUserAllowedLifetime=${allowed_lifetime}
    ...                                  localUserAllowedIdlePeriod=${allowed_idle_period}
    ...                                  sysAdmAllowedIdlePeriod=${allowed_idle_period}
    ...                                  sysAdmAllowedLifetime=${allowed_lifetime}
    ...                                  skip_parameter_relation_errors=${TRUE}
    ...                                  connection=${connection}
    Log    Step 5: Generate local user accounts status report    console=true
    ${rep_lifetime_idle}=    coam_admin.get_account_status_report     connection=${connection}
    Log    Step 6: Check if report ccontains the correct "Allowed lifetime" and "Allowed idle period"    console=true
    FOR    ${account}    IN    @{ACCOUNTS_IDLE_LIFETIME}
        Run Keyword If    '${account}' != '${nemuadmin}'
        ...    Check Reported Allowed Idle Period   ${rep_lifetime_idle}     ${allowed_idle_period}    ${account}
        Run Keyword If    '${account}' == '${nemuadmin}'
        ...    Check Reported Allowed Idle Period For System Account    ${rep_lifetime_idle}     ${allowed_idle_period}
        Check Reported Allowed Lifetime      ${rep_lifetime_idle}     ${allowed_lifetime}       ${account}

    END
    [Teardown]    Run Keyword   Disconnect from ADMIN    ${connection}

CB012224-A_#03_Unsuccessful_role_activation_and_deactivation_time_update
    Log    Step0and1: Connect to admin and remove synchronization
    Download SCF    local_path=${CURDIR}
    ${connection}=    Connect to ADMIN
     Remove Synchronization
    Log    Step 2: Activation of the inactive role for one of local human account     console=true
    coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=true
    ...                                  connection=${connection}
    Log    Step 3: Generating local user accounts status report    console=true
    ${report_act}=    coam_admin.get_account_status_report     connection=${connection}
    Log    Step 4: Checking if Activation Time was not updated with the reason for time not being updated   console=true
    ${rep_act_time}=    Check Reported Activation Time    report=${report_act}    account_type=${account_type}
    ${rep_act_time_str}=    Convert To String    ${rep_act_time}
    Should Contain     ${rep_act_time_str}    Time not updated due to out of sync
    Log    Step 4: Deactivation of the inactive role for one of local human account     console=true
    coam_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=false
    ...                                  connection=${connection}
    Log    Step 5: Generating local user accounts status report    console=true
    ${report_deact}=    coam_admin.get_account_status_report     connection=${connection}
    Log    Step 6: Checking if Activation Time was not updated with the reason for time not being updated   console=true
    ${rep_deact_time}=    Check Reported Deactivation Time    report=${report_deact}    account_type=${account_type}
    ${rep_deact_time_str}=    Convert To String    ${rep_deact_time}
    Should Contain     ${rep_deact_time_str}    Time not updated due to out of sync
    [Teardown]    Run Keywords   Commission SCF    ${scf_file}
    ...    AND    Wait until BTS reach Configured or OnAir state    ${connection}

CB012224-A_04_Unsuccessful_local_user_accounts_status_report
    Log    Step 0: Configure local account    console=true
    ${connection_ADMIN}=    Connect to ADMIN
    Setup Local user account    BTSApplication    Ut3pa5s#1be1    connection=${connection_ADMIN}
    Log     Step 1: Log in BTSApplication without appropriate provilages and check the time    console=true
    ${connection}=    Connect to ADMIN    ip_address=192.168.255.129       alias=BTSApplication
    ...               username=BTSApplication   password=Ut3pa5s#1be1  admin_logs_path=${None}
    Log    Step 7: Generate local user accounts status report    console=true
    Run Keyword And Expect Error        *ErrorCode: 171*
    ...                                  coam_admin.get_account_status_report     connection=${connection}
    [Teardown]    Run Keyword   Disconnect from ADMIN    ${connection}
