*** Settings ***
Documentation    Description:      Resources used during sending some traffic from TestPC to TL.
...              Author:           jagoda.kubacka@nokia.com
...              Modification:     14-05-2024 made by jagoda.kubacka@nokia.com


*** Variables ***

${login}              curl -v -k -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Basic
${login2}             " https://
${login_3}            /api/licensed/sec/v1/login
${ro}                 -H "AccessMode: ro"

${logout}             curl -v -k -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization: Bearer
${logout2}            " https://
${logout3}            /api/licensed/sec/v1/logout

${DCUSER_PASS}        ZGN1c2VyOlFBd3MxMjMhQCM=
${Nemuadmin}          TmVtdWFkbWluOk5va2lhQDEyMw==
${BTSSecurity}        QlRTU2VjdXJpdHk6UUF3czEyMyFAIw==

*** Keywords ***
Perform REST login
    [Documentation]    Description:    Performing login with REST command.
    ...                Input:          login_command: command with hashed username and password
    ...                Output:         rest_login: output from the login to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${login_command}    ${hw_type}    ${read_only}=False
    Log                Using REST try to log to Webem    console=True
    ${mplane_ip}       Set Variable If    '${hw_type}'=='vCU'        ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${command}         Set Variable If    '${read_only}'=='False'    ${login} ${login_command}${login2}${mplane_ip}${login_3}
    ...                ${login} ${login_command}${login2}${mplane_ip}${login_3} ${ro}
    ${rest_login}      RUN    ${command}
    [Return]           ${rest_login}

Perform REST logout
    [Documentation]    Description:    Performing logout with REST command.
    ...                Input:          token_value: token that must be provided to authenticate connection
    ...                Output:         rest_logout: output from the logout to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${token_value}    ${hw_type}
    Log                Using REST try to log out from WebEM    console=True
    ${mplane_ip}       Set Variable If    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${rest_logout}=    RUN   ${logout} ${token_value}${logout2}${mplane_ip}${logout3}
    Log to console    ${rest_logout}
    [Return]           ${rest_logout}

Get Token Value
    [Documentation]    Description:    Getting the token value from the proper authentication
    ...                Input:          rest_login: output from the login to get token
    ...                Output:         token_value: the token
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${rest_login}
    ${rest_login1}=    Fetch From Right    ${rest_login}    {
    ${rest_login2}=    Split String        ${rest_login1}    \n
    ${token_line}=     rest_api.Get Line Matching Regexp    ${rest_login2}    .*"[Tt]oken": "([^"]+)"
    ${token_info}=     Get Regexp Matches    ${token_line}    "[Tt]oken": "([^"]+)"
    ${token1}=         Convert to string     ${token_info}
    @{split}=          Split String          ${token1}    "
    ${token_value}=    Set variable          ${split}[3]
    Log    ${token_value}     console=True
    [Return]           ${token_value}

Get Line Matching Regexp
    [Arguments]    ${lines}    ${pattern}
    FOR    ${line}    IN    @{lines}
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ${pattern}
        Run Keyword If    ${match}    Return From Keyword    ${line}
    END
    Fail    No line matching pattern '${pattern}' found
