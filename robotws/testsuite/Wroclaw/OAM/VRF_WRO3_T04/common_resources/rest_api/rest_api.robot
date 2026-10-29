*** Settings ***
Documentation    REST API keywords, variables (IP addresses etc.).
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Library    taf.transport.ssh        WITH NAME   ssh
Library    OperatingSystem
Library    SSHLibrary

Resource    ../vm/vm_operations.robot
Resource    ../ip_traffic/ip_traffic.robot
Resource    ../connections/connections.robot
Resource    ../netact/netact_operations.robot
Resource    ../alarms/alarm.robot
Resource    ../mantaray/mantaray.robot
Resource    ../pcap_analysis/pcap_analysis.robot
Resource    ../certificates/certificates.robot
Resource    ../commissioning/parameters.robot

*** Variables ***
${rsa}=                     CB007672
${ecdsa}=                   CB005999_test
${ECDSA_SUBJECT_NAME}       CN = CB005999_test
${RSA_SUBJECT_NAME}         C=PL, O=Common, CN=IPSEC

${login_1}                   curl -v https://${MPLANE_IPV4}/ext/api/auth/v1/login -k -X POST -H "Accept: application/json"
${login_2}                  -H "Conten-Type: application/json" -H "Authorization: Basic TmVtdWFkbWluOm5lbXV1c2Vy
${wronglogin_2}             -H "Content-Type: application/json" -H "Authorization: Basic TmVtdWFkbWluOm5lbXV1c1Vy
${login_3}                  -H "Conten-Type: application/json" -H "Authorization: Basic QlRTQXBwbGljYXRpb246UXdlcnR5X3F3ZXJ0eTEyIw==
${wronglogin_3}             -H "Conten-Type: application/json" -H "Authorization: Basic QlRTQXBwbGljYXRpb246UXdlcnR6MTIj

${logout}                   curl https://${MPLANE_IPV4}/ext/api/auth/v1/logout -k -X POST -H "Accept: application/json"
${get_sw}                   curl https://${MPLANE_IPV4}/ext/api/swm/v1/software -k -X GET -H "Accept: application/json"

${part2}                    -H "Content-Type: application/json" -H "Authorization: Bearer
${part3}                    " -i -w "\nHTTP Status: \%{http_code}\n"

${app_user_account}         BTSApplication
${admin_user_account}       Nemuadmin
${admin_password}           nemuuser
${app_password}             Qwerty_qwerty12#

*** Keywords ***
Perform REST login
    [Documentation]    Description:    Performing login with REST command.
    ...                Input:          login_command: command with hashed username and password
    ...                Output:         rest_login: output from the login to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${login_command}
    Log                Using REST try to log to Webem    console=True
    ${rest_login}      RUN    ${login_1} ${login_command} ${part3}
    [Return]           ${rest_login}

Perform REST logout
    [Documentation]    Description:    Performing logout with REST command.
    ...                Input:          token_value: token that must be provided to authenticate connection
    ...                Output:         rest_logout: output from the logout to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${token_value}
    Log                Using REST try to log out from WebEM    console=True
    ${rest_logout}=    RUN    ${logout} ${part2} ${token_value} ${part3}
    [Return]           ${rest_logout}

Get Token Value
    [Documentation]    Description:    Getting the token value from the proper authentication
    ...                Input:          rest_login: output from the login to get token
    ...                Output:         token_value: the token
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${rest_login}
    ${rest_login1}=    Fetch From Right    ${rest_login}    {
    ${rest_login2}=    Split String        ${rest_login1}    ,
    ${token_line}=     rest_api.Get Line Matching Regexp    ${rest_login2}    "[Tt]oken":*"
    ${token1}=         Convert to string     ${token_line}
    @{split}=          Split String          ${token1}    "
    ${token_value}=    Set variable          ${split}[3]
    [Return]           ${token_value}

Check PCAP for REST connection
    [Documentation]    Description:    Check if the handshake was occured during connection between M-Plane and REST API
    ...                Input:          tcpdump_path: path to PCAP file
    ...                Output:         pass/fail
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${tcpdump_path}
    PCAP Should Contain Message
    ...    tshark_filter=tls.handshake.type == 11 and ip.src == ${MPLANE_IPV4} and ip.dst == ${VM_IP}
    ...    pcap_file=${tcpdump_path}

Get Sessions List
    [Documentation]    Description:    Getting all active sessions
    ...                Input:          N/A
    ...                Output:         connections_list: the sessions list from WebEM
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]   ${pre-conn}=${NONE}
    ${connection}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN
    ...               ELSE    Set Variable      ${pre-conn}
    ${output}=        admin.Check Link Status    detailed_output=True    connection=${connection}
    ${connections_list}=    Evaluate    [message['type'] for message in ${output['requestMessage']}]
    [Return]          ${connections_list}
    [Teardown]        Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}

Get Information using REST Command
    [Documentation]    Description:    Executing command with REST API
    ...                Input:          rest_command: the used command to get information like SW version
    ...                                token_value: the token (from the Get Token Value KW)
    ...                Output:         rest_output: the output from the defined command
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${rest_command}    ${token_value}
    ${rest_output}=    Run    ${rest_command} ${part2} ${token_value} ${part3}
    [Return]           ${rest_output}

Wait For CNUM alarm
    [Arguments]   ${fault_id}=4775
    ${connection}                     Connect to ADMIN
    ...                               alias=alarm
    Wait Until Alarm Appears On BTS   fault_id=${fault_id}
    ...                               timeout=1800
    [Teardown]                        Disconnect from ADMIN
    ...                               connection=alarm

Get Username From Sessions List
    [Documentation]    Description:    Getting all active sessions
    ...                Input:          N/A
    ...                Output:         connections_list: the sessions list from WebEM
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]   ${pre-conn}=${NONE}
    ${connection}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN
    ...               ELSE    Set Variable      ${pre-conn}
    ${output}=        admin.Check Link Status    detailed_output=True    connection=${connection}
    ${connections_list}=    Evaluate    [message['userName'] for message in ${output['requestMessage']}]
    [Return]          ${connections_list}
    [Teardown]        Run Keyword and Ignore Error    Disconnect from ADMIN    ${connection}

Get Line Matching Regexp
    [Arguments]    ${lines}    ${pattern}
    FOR    ${line}    IN    @{lines}
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ${pattern}
        Run Keyword If    ${match}    Return From Keyword    ${line}
    END
    Fail    No line matching pattern '${pattern}' found
