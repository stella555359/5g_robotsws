*** Settings ***
Documentation    Cloud local users accounts management keywords.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com

Resource    ../connections/connections.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     Collections
Library     String

*** Keywords ***

#################################################### Main  Keywords ####################################################

Setup Local User Account
    [Documentation]    Description:    Create and activate local user account
    ...                Input:          account_type = BTSSecurity, BTSApplication or BTSRead, also serves as username
    ...                                password = password for desired local user
    ...                                status = active/deactive
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${account_type}    ${password}    ${status}    ${hw_type}=${NONE}
    Log                Setup ${account_type} account on ${hw_type}    console=true
    Run Keyword If    '${hw_type}'=='vCU'    _Update Local User Account on vCU    username=${account_type}
    ...                                      new_password=${password}    active_status=${status}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Update Local User Account on vDU    username=${account_type}
    ...                                      new_password=${password}    active_status=${status}
    ...    ELSE        FAIL                  hw_type doesn't exist

Change Local User Account Password
    [Documentation]    Description:    Change password of existing local user
    ...                Input:          account_type = BTSSecurity, BTSApplication or BTSRead
    ...                                old_password = current password of chosen local user
    ...                                new_password = desired password for chosen local user
    ...                                status = optional (only if you want to activate/deactivate user), active/deactive
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${account_type}      ${old_password}    ${new_password}
    ...                ${status}=${NONE}    ${hw_type}=${NONE}
    Log                Changing password of ${account_type} user on ${hw_type}    console=true
    Run Keyword If    '${hw_type}'=='vCU'    _Update Local User Account on vCU    username=${account_type}
    ...                                      old_password=${old_password}    new_password=${new_password}
    ...                                      active_status=${status}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Update Local User Account on vDU    username=${account_type}
    ...                                      old_password=${old_password}    new_password=${new_password}
    ...                                      active_status=${status}
    ...    ELSE        FAIL                  hw_type doesn't exist

Change Local User Account State
    [Documentation]    Description:    Activate/deactivate local user account
    ...                Input:          account_type = BTSSecurity, BTSApplication or BTSRead
    ...                                is_active = True/False
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${account_type}    ${is_active}    ${hw_type}=${NONE}
    Log                Changing state of ${account_type} account to ${is_active} on ${hw_type}    console=true
    Run Keyword If    '${hw_type}'=='vCU'    _Change Local User Account State on vCU
    ...                                      account_type=${account_type}    state=${is_active}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Change Local User Account State on vDU
    ...                                      account_type=${account_type}    state=${is_active}
    ...    ELSE        FAIL                  hw_type doesn't exist

Get Account Report
    [Documentation]    Description:    Get report about chosen account
    ...                Input:          account_type = BTSSecurity, BTSApplication, BTSRead, Nemuadmin, wsuser, etc.
    ...                                hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         Dictionary with informations about chosen account
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${account_type}     ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${temp_conn}=      Run Keyword If     "${pre-connection}"=="${NONE}"    Connect to ADMIN    hw_type=${hw_type}
    ...                ELSE    Set Variable    ${pre-connection}
    ${report}=         Run Keyword If     '${hw_type}'=='vCU'    vcu_admin.get_account_status_report
    ...                                                          connection=${temp_conn}
    ...                ELSE IF            '${hw_type}'=='vDU'    vdu_admin.get_account_status_report
    ...                                                          vdu_connection=${temp_conn}
    ...                ELSE                FAIL                  hw_type doesn't exist
    FOR    ${user}    IN    @{report}
        ${correct_user}=    Run Keyword and Return Status    Dictionary Should Contain Value
        ...                                                  ${user}    ${account_type}
        ${user_report}=     Set Variable If    ${correct_user}    ${user}
        IF    ${correct_user}    BREAK
    END
    [Return]           ${user_report}
    [Teardown]         Run Keyword If    "${pre-connection}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                    connection=${temp_conn}    hw_type=${hw_type}

Check Password Expiration Date
    [Documentation]    Description:    Check password expiration date for chosen user.
    ...                                User needs to be in active state.
    ...                Input:          username = username of chosen user
    ...                                password = password of chosen user
    ...                                hw_type = vCU/vDU
    ...                Output:         Password Expiration Date
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${username}    ${password}    ${hw_type}=${NONE}
    ${temp_conn}=      Connect to ADMIN    username=${username}    password=${password}
    ...                                    alias=${username}_${hw_type}    hw_type=${hw_type}
    ${output}=         Run Keyword If      '${hw_type}'=='vCU'    vcu_admin.account_users_system_get
    ...                                                           username=${username}
    ...                                                           connection=${temp_conn}
    ...                ELSE IF             '${hw_type}'=='vDU'    vdu_admin.account_users_system_get
    ...                                                           username=${username}
    ...                                                           vdu_connection=${temp_conn}
    ...                ELSE                 FAIL                  hw_type doesn't exist
    ${output_str}=     Convert to String    ${output}
    ${date}=           Get Substring        ${output_str}    30    -2
    [Return]           ${date}
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

Change Service Account Password
    [Documentation]    Description:    Change service account password
    ...                Input:          username = current username
    ...                                old_password = current password
    ...                                new_password = desired password
    ...                                hw_type = vCU/vDU
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${username}      ${old_password}    ${new_password}    ${hw_type}=${NONE}
    Log                Changing password of ${username} on ${hw_type}    console=true
    Run Keyword If    '${hw_type}'=='vCU'    _Change Service Account Password on vCU    username=${username}
    ...                                      old_password=${old_password}    new_password=${new_password}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Change Service Account Password on vDU    username=${username}
    ...                                      old_password=${old_password}    new_password=${new_password}
    ...    ELSE        FAIL                  hw_type doesn't exist

Change Password For Specified Connection
    [Documentation]    Description:    Change password for user with specified connection
    [Arguments]        ${username}   ${password}  ${new_password}  ${connection}   ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.update_local_user_account
    ...                                      username=${username}
    ...                                      password=${password}
    ...                                      new_password=${new_password}
    ...                                      connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.account_users_system_patch
    ...                                      username=${username}
    ...                                      password=${password}
    ...                                      new_password=${new_password}
    ...                                      vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

################################################ Supplementary Keywords ################################################

_Update Local User Account on vCU
    [Arguments]       ${username}    ${new_password}=${NONE}
    ...               ${old_password}=${NONE}    ${active_status}=${NONE}
    ${temp_conn}=     Connect to ADMIN    hw_type=vCU
    ${result}=        vcu_admin.update_local_user_account
    ...               username=${username}        password=${old_password}    new_password=${new_password}
    ...               connection=${temp_conn}     active_status=${active_status}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Update Local User Account on vDU
    [Arguments]       ${username}    ${new_password}=${NONE}
    ...               ${old_password}=${EMPTY}    ${active_status}=${NONE}
    ${temp_conn}=     Connect to ADMIN    hw_type=vDU
    ${result}=        vdu_admin.account_users_system_patch
    ...               username=${username}        password=${old_password}    new_password=${new_password}
    ...               vdu_connection=${temp_conn}    activeStatus=${active_status}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Change Local User Account State on vCU
    [Arguments]       ${account_type}    ${state}
    ${temp_conn}=     Connect to ADMIN    hw_type=vCU
    ${result}=        vcu_admin.change_local_account_state
    ...               account_type=${account_type}    enable=${state}    connection=${temp_conn}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Change Local User Account State on vDU
    [Arguments]       ${account_type}    ${state}
    ${temp_conn}=     Connect to ADMIN    hw_type=vDU
    ${result}=        vdu_admin.change_local_account_state
    ...               account_type=${account_type}    enable=${state}    vdu_connection=${temp_conn}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

_Change Service Account Password on vCU
    [Arguments]       ${username}    ${new_password}    ${old_password}
    ${temp_conn}=     Connect to Admin    hw_type=vCU
    ${result}=        vcu_admin.update_service_account_password    username=${username}
    ...               password=${old_password}    new_password=${new_password}    connection=${temp_conn}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vCU

_Change Service Account Password on vDU
    [Arguments]       ${username}    ${new_password}    ${old_password}
    ${temp_conn}=     Connect to Admin    hw_type=vDU
    ${result}=        vdu_admin.update_service_account_password    username=${username}
    ...               password=${old_password}    new_password=${new_password}    vdu_connection=${temp_conn}
    Should Be True    "${result["content"]}"=="Success"
    [Teardown]        Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU
