*** Settings ***
Documentation
...  author:      Klaudyna Piechocka
...  contact:     klaudyna.piechocka@nokia.com

Library    OperatingSystem
Library    DateTime
Library    Collections
Library    CB012224.py

*** Variables ***
@{REPORT_CONTENT}           role    roleActivationState
...                         lastLoginTime     lastLogoutTime
...                         passwordLifetime    passwordExpiryTime       accountStatus
...                         accountDisabledReason    numberOfActiveSessions
@{HUMAN_ACCOUNTS}           Nemuadmin    BTSSecurity    BTSApplication    BTSRead
@{MACHINE_ACCOUNTS}         georesiliency   swmupgrade
${nemuadmin}=               Nemuadmin

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
    ${length}=   BuiltIn.Get Length    ${report}
    ${role_act_time}=     Create List
   FOR    ${x}    IN RANGE    ${length}
            ${account_name}=    Convert To Lowercase    ${report[${x}]["accountName"]}
            Run Keyword If    '${account_name}' == '${account_type}'
            ...                Convert To String    ${report[${x}]["roles"][0]["roleActivationTime"]}
            Run Keyword If    '${account_name}' == '${account_type}'
            ...                Append To List    ${role_act_time}    ${report[${x}]["roles"][0]["roleActivationTime"]}
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
    ${account_type}=       Convert To Lowercase   ${account_type}
    ${length}=             BuiltIn.Get Length     ${report}
    ${role_deact_time}=    Create List
       FOR    ${x}    IN RANGE    ${length}
           ${account_name}=   Convert To Lowercase    ${report[${x}]["accountName"]}
           Run Keyword If     '${account_name}' == '${account_type}'
           ...                Convert To String    ${report[${x}]["roles"][0]["roleDeactivationTime"]}
           Run Keyword If     '${account_name}' == '${account_type}'
           ...                Append To List   ${role_deact_time}   ${report[${x}]["roles"][0]["roleDeactivationTime"]}
           Exit For Loop If   '${account_name}' == '${account_type}'
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

    ${length}=             BuiltIn.Get Length     ${report}
    ${str_all}=            Convert To String      ${report}

    FOR    ${account}    IN    @{HUMAN_ACCOUNTS}
        Should Contain    ${str_all}    ${account}
    END

    FOR    ${x}    IN RANGE    ${length}
            ${account_name}=     Convert To String       ${report[${x}]["accountName"]}
            ${str}=              Convert To String       ${report[${x}]}
            Run keyword If       '${account_name}'=='Nemuadmin'
            ...                  Check Report Content    ${str}    @{REPORT_CONTENT}
    END

Check Report Content
    [Documentation]    Description:    KW to check if the report has the content defined in OM_GEN_SFS_SYSSEC.3532
    ...                                It loops through the list of term and checks if they are in report.
    ...                                For  accountDisabledReason it checks if acount is enabled or disabled with reason
    ...                Input:          report = report for a single account as string
    ...                                report_content = content defined in OM_GEN_SFS_SYSSEC.3532
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${report}    @{report_content}
    FOR    ${term}    IN    @{report_content}
        Run Keyword If    '${term}' != 'accountDisabledReason'    Should Contain    ${report}   ${term}
        ...                ELSE    Check If Account Is Enabled Or Disabled With Reason    ${report}
    END

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
    ${current_date}=                Get Current Date
    ${days}=                        Evaluate                        ${allowed_lifetime} + 1
    ${calc_date}=                   Add Time To Date                ${current_date}         ${days} days
    ${calc_date_day}=               Split String                    ${calc_date}            ${SPACE}
    ${length}=                      BuiltIn.Get Length     ${report}
    FOR    ${x}    IN RANGE    ${length}
        Run Keyword If     '${report[${x}]["accountName"]}' == '${account_type}'
        ...                 Should Contain    '${report[${x}]["accountLifetime"]}'      ${allowed_lifetime}
        Run Keyword If     '${report[${x}]["accountName"]}' == '${account_type}'
        ...                 Should Contain    '${report[${x}]["accountExpiryTime"]}'    ${calc_date_day[0]}
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
    ${current_date}=                Get Current Date
    ${days}=                        Evaluate                        ${allowed_idle_period} + 1
    ${calc_date}=                   Add Time To Date                ${current_date}             ${days} days
    ${calc_date_day}=               Split String                    ${calc_date}                ${SPACE}
    ${length}=                      BuiltIn.Get Length     ${report}
    FOR    ${x}    IN RANGE    ${length}
        Run Keyword If     '${report[${x}]["accountName"]}' == '${account_type}'
        ...                 Should Contain    '${report[${x}]["allowedIdlePeriod"]}'      ${allowed_idle_period}
        Run Keyword If     '${report[${x}]["accountName"]}' == '${account_type}'
        ...                 Should Contain    '${report[${x}]["idlePeriodExpirationTime"]}'    ${calc_date_day[0]}
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
    ${length}=                      BuiltIn.Get Length     ${report}
    FOR    ${x}    IN RANGE    ${length}
        Run Keyword If     '${report[${x}]["accountName"]}' == '${nemuadmin}'
        ...                 Should Contain    '${report[${x}]["allowedIdlePeriod"]}'     ${allowed_idle_period}
        Exit For Loop If    '${report[${x}]["accountName"]}' == '${nemuadmin}'
    END

Set Allowed Lifetime and Idle Period to Null
    [Documentation]    Description:    KW to change Allowed Lifetime and Idle Period to Null
    ...                Input:          report = obtained report
    ...                                allowed_idle_period = value of the localUserAllowedIdlePeriod parameter
    ...                                account_type = type of the account for which allowed idle period ios checked
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         klaudyna.piechocka@nokia.com
    [Arguments]        ${hw_type}
    ${dist_name}=         Create List    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1    MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${param_list}=        Create List    localUserAllowedLifetime              localUserAllowedIdlePeriod
    ...                                  sysAdmAllowedIdlePeriod               sysAdmAllowedLifetime
    ${value_list_null}=   Create List    0    0    0   0
    Add Multiple Parameters on BTS       ${dist_name}
    ...                                  ${param_list}
    ...                                  ${value_list_null}
    ...                                  hw_type=${hw_type}
