*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com
...  description: TC for CB012224. CB012224 verifies the contents of

Resource    ../Resources/CB012224_cloud.robot
Resource    ../../../../cloud_common_resources/connections/connections.robot
Resource    ../../../../cloud_common_resources/commissioning/commissioning.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Library      taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library      taf.gnb.oam.coam.cu     WITH NAME    vcu_admin

*** Variables ***
${BTS_ID}=                    ${tl.gnbs[0].global_bts_id}
${account_type}=              BtsSecurity
${allowed_lifetime}=          10
${allowed_idle_period}=       5
@{ACCOUNTS_IDLE_LIFETIME}=    Nemuadmin    BTSSecurity    BTSApplication    BTSRead
${delta}=                     ${CURDIR}/Wroclaw/OAM/features/CB012224/Resources/delta.json
${scf_file}=                  ${CURDIR}/scf.xml
${nemuadmin}=                 Nemuadmin

*** Keywords ***
CB012224-B_#01_Role_activation_and_deactivation_time_update_vDU
    Log    Step 1: Login to WebEM as System Administrator    console=true
    ${connection1}=    Connect to ADMIN    hw_type=vDU
    Log    Step 2: Activation of the inactive role for one of local human account from WebEM    console=true
    Run Keyword And Ignore Error
    ...                                  vdu_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=false
    ...                                  vdu_connection=${connection1}
    Wait Until Keyword Succeeds          10min   30s
    ...                                  vdu_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=true
    ...                                  vdu_connection=${connection1}
    Log    Step 3: Checing if the Role Activation Time has been updated    console=true
    ${rep_act_before}=     vdu_admin.get_account_status_report   vdu_connection=${connection1}
    ${act_time_before}=    Check Reported Activation Time    report=${rep_act_before}    account_type=${account_type}
    Log    Step 4: Reset the BTS    console=true
    Perform Reset and Wait for Expected State    hw_type=vDU    state=configured
    ${connection2}=    Connect to ADMIN    hw_type=vDU
    Log    Step 5: Checing if the Role Activation Timeis the same before and after restart    console=true
    ${rep_act_after}=    vdu_admin.get_account_status_report   vdu_connection=${connection2}
    ${act_time_after}=    Check Reported Activation Time    report=${rep_act_after}    account_type=${account_type}
    Should Be Equal    ${act_time_before}    ${act_time_after}
    Log    Step 6: Deactivation of the active role for one of local human account from WebEM    console=true
    Wait Until Keyword Succeeds          10min   30s
    ...                                  vdu_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=${false}
    ...                                  vdu_connection=${connection2}
    Log    Step 7: Checing if the Role Deactivation Time has been updated    console=true
    ${rep_deact_before}=     vdu_admin.get_account_status_report   vdu_connection=${connection2}
    ${deact_time_before}=    Check Reported Deactivation Time    report=${rep_deact_before}    account_type=${account_type}
    Log    Step 8: Reset the BTS    console=true
    Perform Reset and Wait for Expected State    hw_type=vDU    state=configured
    ${connection3}=    Connect to ADMIN    hw_type=vDU
    Log    Step 9: Checing if the Role Deactivation Timeis the same before and after restart    console=true
    ${rep_deact_after}=     vdu_admin.get_account_status_report   vdu_connection=${connection3}
    ${deact_time_after}=    Check Reported Deactivation Time    report=${rep_deact_after}    account_type=${account_type}
    Should Be Equal    ${deact_time_before}    ${deact_time_after}
    [Teardown]    Run keywords           vdu_admin.change_local_account_state
    ...                                  account_type=${account_type}
    ...                                  enable=${false}
    ...                                  vdu_connection=${connection3}
    ...    AND                           Disconnect from ADMIN  ${connection3}    hw_type=vDU

CB012224-B_#02_Local_user_accounts_status_report-triggering_and_exporting_vDU
    Log    Step 1: Login to WebEM as System Administrator    console=true
    ${connection}=    Connect to ADMIN    hw_type=vDU
    Change Parameter on BTS
    ...                                   dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                   param_name=localPasswdExpiryPeriod
    ...                                   param_value=9999
    ...                                   hw_type=vDU
    Log    Step 2: Generate local user accounts status report    console=true
    ${connection}=    Connect to ADMIN    hw_type=vDU
    ${report}=    vdu_admin.get_account_status_report   vdu_connection=${connection}
    Log    Step 3: Check if report contains the list of data defined in the requirement    console=true
    Check Local Account State Report Content    ${report}
    [Teardown]    Run Keywords
    ...                                   Change Parameter on BTS
    ...                                   dist_name=MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                   param_name=localPasswdExpiryPeriod
    ...                                   param_value=0
    ...                                   hw_type=vDU
    ...            AND                    Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}    hw_type=vDU

CB012224-B_#03_Unsuccessful_local_user_accounts_status_report_vCU
    Log    Step 0: Configure local account    console=true
    ${connection_ADMIN}=    Connect to ADMIN        hw_type=vCU
    vcu_admin.update_local_user_account
    ...                                             username=BTSApplication
    ...                                             active_status=active
    ...                                             new_password=Ut3pa5s#1be1
    ...                                             connection=${connection_ADMIN}
    Log     Step 1: Log in BTSApplication without appropriate provilages and check the time    console=true
    Disconnect from ADMIN    ${connection_ADMIN}    hw_type=vCU
    ${connection}=    Connect to ADMIN
    ...                                             hw_type=vCU
    ...                                             secure=${True}
    ...                                             username=BTSApplication
    ...                                             password=Ut3pa5s#1be1
    Log    Step 2: Generate local user accounts status report    console=true
    Run Keyword And Expect Error         *405*
    ...                                  vcu_admin.get_account_status_report    connection=${connection}
    [Teardown]    Run Keyword   Disconnect from ADMIN    ${connection}    hw_type=vCU

CB012224-B_#06_Local_user_accounts_status_report-triggering_and_exporting_checking_implementation_of_CB012187_vCU
    Log    Step 1: Change "Allowed lifetime" and "Allowed idle period" parameters    console=true
    ${dist_name}=    Create List    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                             MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ${param_list}=   Create List    localUserAllowedLifetime              localUserAllowedIdlePeriod
    ...                             sysAdmAllowedIdlePeriod               sysAdmAllowedLifetime
    ${value_list}=   Create List    10    5     5    10
    ${value_list_null}=   Create List    0    0    0   0
    ${lengh}=    Get Length   ${param_list}
    FOR    ${i}    IN RANGE    ${lengh}
        Change Parameter on BTS
        ...                                   dist_name=${dist_name[${i}]}
        ...                                   param_name=${param_list[${i}]}
        ...                                   param_value=${value_list[${i}]}
        ...                                   hw_type=vCU
    END
    Log    Step 2: Generate local user accounts status report    console=true
    ${connection}=    Connect to ADMIN    hw_type=vCU
    ${rep_lifetime_idle}=    vcu_admin.get_account_status_report    connection=${connection}
    Log    Step 3: Check if report ccontains the correct "Allowed lifetime" and "Allowed idle period"    console=true
    FOR    ${account}    IN    @{ACCOUNTS_IDLE_LIFETIME}
        Run Keyword If    '${account}' != '${nemuadmin}'
        ...    Check Reported Allowed Idle Period   ${rep_lifetime_idle}     ${allowed_idle_period}    ${account}
        Run Keyword If    '${account}' == '${nemuadmin}'
        ...    Check Reported Allowed Idle Period For System Account    ${rep_lifetime_idle}     ${allowed_idle_period}
        Check Reported Allowed Lifetime      ${rep_lifetime_idle}       ${allowed_lifetime}      ${account}
    END
    [Teardown]                           Change Multiple Parameters on BTS    ${dist_name}
    ...                                  ${param_list}
    ...                                  ${value_list_null}
    ...                                  hw_type=vCU
