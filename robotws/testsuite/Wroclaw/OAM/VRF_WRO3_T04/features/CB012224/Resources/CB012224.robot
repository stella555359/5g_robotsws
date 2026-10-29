*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com

Library    OperatingSystem
Library    DateTime
Library    Collections
Library    CB012224.py
Library    taf.sbts.oam.coam.admin    WITH NAME   coam_admin

*** Variables ***
@{REPORT_CONTENT}           role    roleActivationState    roleActivationTime    roleDeactivationTime
...                         lastLoginTime     lastLogoutTime    accountLifetime     accountExpiryTime
...                         passwordLifetime    passwordExpiryTime    allowedIdlePeriod    accountStatus
...                         accountDisabledReason    numberOfActiveSessions
@{REPORT_CONTENT_DCUSER}    lastLoginTime     lastLogoutTime
...                         passwordLifetime    passwordExpiryTime
...                         accountDisabledReason   accountStatus
${accountStatusReport}      payload.requestMessage.accountStatusReport
@{ACCOUNTS}                 Nemuadmin    BTSSecurity    BTSApplication    BTSRead
${nemuadmin}                Nemuadmin
${falseIP}                  10.11.12.13
${default_localPriority}    128
*** Keywords ***
Check Reported Activation Time
    [Documentation]    Description:    KW to check what is Activation Time. Loop goes throuhg the list of accounts and
    ...                                returns roleActivationTime for selected account_type
    ...                Input:          report = report content
    ...                                account_type = the account type for which activation time is checked
    ...                Output:         role_act_time = Activation Time
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${report}    ${account_type}
    ${account_type}=      Convert To Lowercase   ${account_type}
    ${account_report}=    Convert Report To Dictionary    ${report}
    ${role_act_time}=     Create List
    FOR    ${account}    IN    @{account_report}
        ${account_name}=    Convert To Lowercase    ${account["accountName"]}
        Run Keyword If    '${account_name}' == '${account_type}'
        ...                Append To List    ${role_act_time}    ${account["roleActivationTime"]}
        Exit For Loop If    '${account_name}' == '${account_type}'
    END
    [Return]    ${role_act_time}

Check Reported Deactivation Time
    [Documentation]    Description:    KW to check what is Deactivation Time. Loop goes throuhg the list of accounts and
    ...                                returns roleDeactivationTime for selected account_type
    ...                Input:          report = report content
    ...                                account_type = the account type for which activation time is checked
    ...                Output:         role_deact_time = Deactivation Time
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${report}    ${account_type}
    ${account_type}=    Convert To Lowercase   ${account_type}
    ${account_report}=    Convert Report To Dictionary    ${report}
    ${role_deact_time}=    Create List
    FOR    ${account}    IN    @{account_report}
        ${account_name}=    Convert To Lowercase    ${account["accountName"]}
        Run Keyword If    '${account_name}' == '${account_type}'
        ...                Append To List    ${role_deact_time}    ${account["roleDeactivationTime"]}
        Exit For Loop If    '${account_name}' == '${account_type}'
    END
    [Return]    ${role_deact_time}

Check Local Account State Report Content
    [Documentation]    Description:    KW to check if the report has the content defined in OM_GEN_SFS_SYSSEC.3532
    ...                                First the loop goes through selected accounts and checks if the contain fields
    ...                                listed in  @{REPORT_CONTENT}, then the keyword checks contents for dc/wsuser
    ...                Input:          report_path = path to exported raport
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}
     ${account_report}=    Convert Report To Dictionary    ${report}
     FOR    ${account}    IN    @{ACCOUNTS}
            ${single_account_report}=    Generate Report For Single Account    ${account_report}    ${account}
            ${str}=    Convert To String     ${single_account_report}
            Check Report Content    ${str}    @{REPORT_CONTENT}
     END

     ${wsuser_report}=    Generate Report For Single Account    ${account_report}    wsuser
     ${wsuser_str}=    Convert to string     ${wsuser_report}
     Should Contain    ${wsuser_str}   accountStatus

     ${dcuser_report}=    Generate Report For Single Account    ${account_report}    dcuser
     ${dcuser_str}=    Convert to string     ${dcuser_report}
     Check Report Content   ${dcuser_str}    @{REPORT_CONTENT_DCUSER}

Check Report Content
    [Documentation]    Description:    KW to check if the report has the content defined in OM_GEN_SFS_SYSSEC.3532
    ...                                It loops through the list of term and checks if they are in report.
    ...                                For  accountDisabledReason it checks if acount is enabled or disabled with reason
    ...                Input:          report_path = path to exported raport
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}    @{report_content}
    ${skip_pass_verify}=    Verify Password Set    ${report}
    FOR    ${term}    IN    @{report_content}
        # Skip both branches for passwordLifetime/passwordExpiryTime if Password is not set
        Run Keyword If    ${skip_pass_verify} and ('${term}' == 'passwordLifetime' or '${term}' == 'passwordExpiryTime')
        ...    Continue For Loop
        # For all other terms, preserve the original ELSE logic
        Run Keyword If    '${term}' != 'accountDisabledReason'    Should Contain    ${report}    ${term}
        ...     ELSE    Check if Account is Enabled or Disabled With Reason    ${report}
    END


## Helper Keyword
Verify Password Set
    [Arguments]    ${verify_report}
    ${result}=    Run Keyword And Return Status    Should Contain    ${verify_report}    Password is not set
    [Return]    ${result}

Check If Account Is Enabled Or Disabled With Reason
    [Documentation]    Description:    KW to check if account is enabled or contains accountDisabledReason if disabled
    ...                Input:          report_path = path to exported raport
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}
    ${result}          run keyword and ignore error   Should Contain    ${report}    accountDisabledReason
    Run Keyword If    '${result[0]}'=='FAIL'   Should Contain    ${report}    Enabled    ELSE
    ...               Should Contain    ${report}    Disabled


Check Reported Allowed Lifetime
    [Documentation]    Description:    KW to check if Allowed Lifetime is correct
    ...                                First the keyword calculates what should be accountExpiryTime amd then in loop it
    ...                                checks if information in loop in report is correct.
    ...                Input:          report = obtained report
    ...                                allowed_lifetime = value of the localUserAllowedLifetime parameter
    ...                                account_type = type of the account for which allowed lifetime is checked
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}    ${allowed_lifetime}    ${account_type}
    ${account_report}=              Convert Report To Dictionary    ${report}
    ${role_allowed_lifetime}=       Create List
    ${role_allowed_exp}=            Create List
    ${current_date}=                Get Current Date
    ${days}=                        Evaluate                        ${allowed_lifetime} + 1
    ${calc_date}=                   Add Time To Date                ${current_date}         ${days} days
    ${calc_date_day}=               Split String                    ${calc_date}            ${SPACE}

    FOR    ${account}    IN    @{account_report}
        Run Keyword If      '${account["accountName"]}' == '${account_type}'
        ...                 Should Contain    ${account["accountLifetime"]}      ${allowed_lifetime}
        Run Keyword If      '${account["accountName"]}' == '${account_type}'
        ...                 Should Contain    ${account["accountExpiryTime"]}    ${calc_date_day[0]}
        Exit For Loop If    '${account["accountName"]}' == '${account_type}'
    END

Check Reported Allowed Idle Period
    [Documentation]    Description:    KW to check if Allowed Idle Period is correct
    ...                                First the keyword calculates what should be idlePeriodExpirationTime amd then
    ...                                in loop it checks if information in loop in report is correct.
    ...                Input:          report = obtained report
    ...                                allowed_idle_period = value of the localUserAllowedIdlePeriod parameter
    ...                                account_type = type of the account for which allowed idle period ios checked
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}    ${allowed_idle_period}    ${account_type}
    ${account_report}=              Convert Report To Dictionary    ${report}
    ${role_allowed_lifetime}=       Create List
    ${role_allowed_exp}=            Create List
    ${current_date}=                Get Current Date
    ${days}=                        Evaluate                        ${allowed_idle_period} + 1
    ${calc_date}=                   Add Time To Date                ${current_date}             ${days} days
    ${calc_date_day}=               Split String                    ${calc_date}                ${SPACE}

    FOR    ${account}    IN    @{account_report}
        Run Keyword If      '${account["accountName"]}' == '${account_type}'
        ...                  Should Contain    ${account["allowedIdlePeriod"]}           ${allowed_idle_period}
        Run Keyword If      '${account["accountName"]}' == '${account_type}'
        ...                  Should Contain    ${account["idlePeriodExpirationTime"]}    ${calc_date_day[0]}
        Exit For Loop If    '${account["accountName"]}' == '${account_type}'
    END

Check Reported Allowed Idle Period For System Account
    [Documentation]    Description:    KW to check if Allowed Idle Period is correct
    ...                                First the keyword calculates what should be idlePeriodExpirationTime amd then in loop it
    ...                                checks if information in loop in report is correct.
    ...                Input:          report = obtained report
    ...                                allowed_idle_period = value of the localUserAllowedIdlePeriod parameter
    ...                                account_type = type of the account for which allowed idle period ios checked
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}    ${allowed_idle_period}
    ${account_report}=              Convert Report To Dictionary    ${report}

    FOR    ${account}    IN    @{account_report}
        Run Keyword If      '${account["accountName"]}' == '${nemuadmin}'
        ...                  Should Contain    ${account["allowedIdlePeriod"]}           ${allowed_idle_period}
        Run Keyword If      '${account["accountName"]}' == '${nemuadmin}'
        ...                  Should Contain    ${account["idlePeriodExpirationTime"]}    -
        Exit For Loop If    '${account["accountName"]}' == '${nemuadmin}'
    END
Convert Report To Dictionary
    [Documentation]    Description:    KW to convert report to list of dictionaries
    ...                                First the KW cleans the string, then it loops throuth the list of single account report
    ...                                amd converts it to dictionary
    ...                Input:          report = report content as string
    ...                Output:         Repprt as list of dictionaries
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]         ${report}
    ${report}=           Convert to String    ${report}
    ${split_report}=     Split String      ${report}    accountStatusReport': [
    ${clean_report}=     Replace String    ${split_report[1]}    ]}, "errorCode": 0}}    ${EMPTY}
    ${clean_report}=     Replace Commas In Brackets    ${clean_report}    ;
    ${clean_report}=     Replace String    ${clean_report}    {    ${EMPTY}
    ${clean_report}=     Replace String    ${clean_report}    "    ${EMPTY}
    ${clean_report}=     Replace String    ${clean_report}    '    ${EMPTY}
    ${account_report}=   Split String      ${clean_report}    },
    ${account_list}=     Create List

    FOR    ${account}    IN    @{account_report}
        ${entries}=         Split String                    ${account}    ,
        ${account_dict}=    Create Dictionary From Pairs    ${entries}    ${account_list}
    END
    [Return]    ${account_list}

Create Dictionary From Pairs
    [Documentation]    Description:    KW to create dictionary from list of pairs. KW loops throuth each entry
    ...                                in single account report and creates the dictionary
    ...                Input:          report = report content
    ...                                account_list = empty list used to store created dictionaries
    ...                Output:         list of dictionaries
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${pairs}    ${account_list}
     ${account_dict}=    Create Dictionary
     FOR    ${pair}    IN    @{pairs}
        ${key_and_value}=    Split String       ${pair}    :
        ${key}=              Strip String       ${key_and_value[0]}
        ${value}=            Strip String       ${key_and_value[1]}
        Set To Dictionary    ${account_dict}    ${key}    ${value}
     END
     Append To List    ${account_list}    ${account_dict}
    [Return]    ${account_list}

Generate report for single account
    [Documentation]    Description:    KW to split report in a form of a list of dictionaries
    ...                                to  dictionary for single account. The loop goes through the repoort for
    ...                                all accounts and it extracts a report for given account
    ...                Input:          report = report in a form of a list of dictionaries
    ...                                account_type = account for which report is generated
    ...                Output:         report in a form of dictionary for single account
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]    ${report}    ${account_type}
    @{account_report}=    Create List
     FOR    ${account}    IN    @{report}
        Run Keyword If     '${account["accountName"]}' == '${account_type}'
        ...                 Append To List    ${account_report}    ${account}
        Exit For Loop If   '${account["accountName"]}' == '${account_type}'
     END
    [Return]    ${account_report}

Remove Synchronization
    [Documentation]    Description:    KW to remove synchronization when there is only GNSS configured
    ...                Output:         N/A
    ...                Author:         klaudyna.piechocka@nokia.com
    ${temp_conn}=                       Connect to ADMIN
    ${values_sync}=                     Create Dictionary
    Set to Dictionary                   ${values_sync}
    ...                                 syncInputPrio     ${1}
    ...                                 syncInputType     TOPP
    ${values_sync_list}=                Create List       ${values_sync}
    Change Parameter on BTS             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                                 param_name=syncInputList
    ...                                 param_value=${values_sync_list}
    ...                                 skip_parameter_relation_errors=${True}
    ${params_list}=  get_list_of_params_for_topp_object
    Run Keyword and Ignore Error        coam_admin.perform_object_recommissioning
    ...                                 dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...                                 parameter=${params_list}
    ...                                 operation=update
    ...                                 skip_parameter_relation_errors=${true}
    ...                                 should_activate=${True}
    ...                                 connection=${temp_conn}
    Wait Until Keyword Succeeds          15min    60s    Wait until BTS reach Configured or OnAir state
    Run Keyword and Ignore Error   Delete Object From BTS
    ...                                   dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
    ...                                   connection=${temp_conn}
    Wait Until Keyword Succeeds          15min    60s    Wait until BTS reach Configured or OnAir state
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    ${temp_conn}

