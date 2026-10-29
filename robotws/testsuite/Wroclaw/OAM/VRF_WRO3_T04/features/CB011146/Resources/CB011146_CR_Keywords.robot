*** Settings ***
Documentation
...  author:     Grzegorz Niedzwiedz
...  contact:    grzegorz.niedzwiedz@nokia.com

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/connections/connections.robot
Resource    ./../../../cloud_common_resources/tls/tls.robot
Resource    ../../../cloud_common_resources/mantaray/mantaray.robot
Resource    ../../../../cloud_common_resources/alarms/alarms.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot
Resource    ../../../../cloud_common_resources/logs/pcap_analysis.robot

Library	           OperatingSystem
Library            Collections

*** Variables ***

# Login
${login_1}              curl -v -k -X POST -H "Accept: application/json" -H "Content-Type: application/json" -H "Authorization:
${wronglogin_2}         Basic TmVtdWFkbWluOmZvb2Jhcg==" https://
${correct_login_2}      Basic TmVtdWFkbWluOk5va2lhQDEyMw==" https://
${login_3}              /ext/api/auth/v1/login -i -w "\nHTTP Status: \%{http_code}\n"
${correct_login_1}      Basic QlRTQXBwbGljYXRpb246UXdlcnR5MTIj" https://      #BTSApplication/Qwerty12#
${wronglogin_1}         Basic QlRTQXBwbGljYXRpb246UXdjVyc=" https://     #BTSApplication/QwcW'

# Logout
${logout}           curl -v -k -X POST -H "Content-Type: application/json" -H "Authorization: Bearer
${logout2}          " -H "Content-Type: application/json" https://
${logout3}          /ext/api/auth/v1/logout  -i -w "\nHTTP Status: \%{http_code}\n"

# SW version
${get_sw}           curl -k -X GET "https://
${get_sw_cu1}      /api/licensed/v1/cu" -H "Content-Type: application/json" -H "Authorization: Bearer
${get_sw_du1}      /api/licensed/v1/vdu" -H "Content-Type: application/json" -H "Authorization: Bearer

# Certs
${ECDSA}    CN = CB005999_test
${RSA}      CN = CB007672
#PCAP
${ECDSA_pcap}    CB005999_test
${RSA_pcap}      CB007672

#Ciphers TLS 1.2
@{ECDSA_CIPHERS}        ECDHE-ECDSA-AES256-GCM-SHA384    ECDHE-ECDSA-AES128-GCM-SHA256
@{RSA_CIPHERS}          ECDHE-RSA-AES256-GCM-SHA384      DHE-RSA-AES256-GCM-SHA384    DHE-RSA-AES256-SHA256    AES256-GCM-SHA384    AES256-SHA256
...                     DHE-RSA-AES128-GCM-SHA256        DHE-RSA-AES128-SHA256        AES128-GCM-SHA256        AES128-SHA256
@{TLS12CBC_CIPHERS_DISABLED}       DHE-RSA-AES256-SHA256            AES256-SHA256                DHE-RSA-AES128-SHA256    AES128-SHA256
@{TLS12RSAKEX_CIPHERS_DISABLED}    AES256-GCM-SHA384                AES256-SHA256                AES128-GCM-SHA256        AES128-SHA256

#user account and Mantaray credentials
${app_user_account}         BTSApplication
${admin_user_account}       Nemuadmin
${admin_password}           nemuuser
${app_password}             Qwerty12#


*** Keywords ***
Certificates Initialization
    [Arguments]    ${hw_type}    ${cert_type}   ${ca_sub_name}
    Update CMP Server Settings      hw_type=${hw_type}
    ...                             key_pool_type=${cert_type}
    Configure CMP                   ca_subject_name=${ca_sub_name}
    ...                             hw_type=${hw_type}
    ...                             server_type=${cert_type}
    Initialize Certificate          hw_type=${hw_type}
    ...                             key_pool_type=${cert_type}

Perform REST login with ciphers
    [Documentation]    Description:    Performing login with REST command.
    ...                Input:          login_command: command with hashed username and password
    ...                                cipher: TLS 1.2 cipher we want to use for connection
    ...                Output:         rest_login: output from the login to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${login_command}    ${cipher}    ${hw_type}
    Log                Loging with cipher: ${cipher}   console=True
    ${mplane_ip}       Set variable if    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${rest_login}      RUN    ${login_1} ${login_command}${mplane_ip}${login_3} --ciphers ${cipher}
    [Return]           ${rest_login}

Check Ciphers With Curl
    [Documentation]    Description:    Loop through each cipher and execute the curl command
    ...                Input:          cipher_list: list of working ciphers which needs to be check for establshing connection
    ...                                wrong_cipher_list: list of ciphers which cannot be used for establishing connection
    ...                                hw_type: vCU/vDU
    ...                Output:         true/false
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${cipher_list}  ${wrong_cipher_list}  ${hw_type}
    ${mplane_ip}       Set variable if    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    Log    Checing working ciphers.    console=True
    FOR    ${cipher}      IN    @{cipher_list}
        ${rest_login}=    Perform REST login with ciphers    ${correct_login_2}    ${cipher}    ${hw_type}
        Should Contain    ${rest_login}                      SSL connection using TLSv1.2 / ${cipher}
        ${token_value}=                   CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${output}=                        CB011146_CR_Keywords.Perform REST logout   ${token_value}    ${hw_type}
        Sleep    5s
    END
    Log    Checking disabled ciphers.    console=True
    FOR    ${cipher}      IN    @{wrong_cipher_list}
        ${rest_login}=    Perform REST login with ciphers    ${correct_login_2}    ${cipher}    ${hw_type}
        Should Contain    ${rest_login}                      alert handshake failure
    END

Available Cipher List
    [Documentation]    Description:    Compares list of available RSA ciphers with list of ciphers that cannot be used
    ...                                and crates new list with working ciphers
    ...                Input:          RSA_cipher_list: list of RSA ciphers which needs to be check for establshing connection
    ...                                ciphers_to_remove: list of ciphers for removing based on both list
    ...                Output:         New cipher list
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${RSA_cipher_list}    ${ciphers_to_remove}
    ${available_ciphers}=    Copy List    ${RSA_cipher_list}
    Remove Values From List    ${available_ciphers}    @{ciphers_to_remove}
    [Return]    ${available_ciphers}

Perform REST login
    [Documentation]    Description:    Performing login with REST command.
    ...                Input:          login_command: command with hashed username and password
    ...                Output:         rest_login: output from the login to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${login_command}    ${hw_type}
    Log                Using REST try to log to Webem    console=True
    ${mplane_ip}       Set variable if    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${rest_login}      RUN    ${login_1} ${login_command}${mplane_ip}${login_3}
    [Return]           ${rest_login}

Get Line Matching Regexp
    [Arguments]    ${lines}    ${pattern}
    FOR    ${line}    IN    @{lines}
        ${match}=    Run Keyword And Return Status    Should Match Regexp    ${line}    ${pattern}
        Run Keyword If    ${match}    Return From Keyword    ${line}
    END
    Fail    No line matching pattern '${pattern}' found

Perform REST logout
    [Documentation]    Description:    Performing logout with REST command.
    ...                Input:          token_value: token that must be provided to authenticate connection
    ...                Output:         rest_logout: output from the logout to REST API
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${token_value}    ${hw_type}
    Log                Using REST log out from WebEM    console=True
    ${mplane_ip}       Set variable if    '${hw_type}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
    ${rest_logout}=    RUN    ${logout} ${token_value}${logout2}${mplane_ip}${logout3}
    [Return]           ${rest_logout}

Get Token Value
    [Documentation]    Description:    Getting the token value from the proper authentication
    ...                Input:          rest_login: output from the login to get token
    ...                Output:         token_value: the token
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${rest_login}
    ${rest_login1}=    Fetch From Right    ${rest_login}    {
    ${rest_login2}=    Split String        ${rest_login1}    \n
    ${token_line}=     CB011146_CR_Keywords.Get Line Matching Regexp    ${rest_login2}    .*"[Tt]oken": "([^"]+)"
    ${token_info}=     Get Regexp Matches    ${token_line}    "[Tt]oken": "([^"]+)"
    ${token1}=         Convert to string     ${token_info}
    @{split}=          Split String          ${token1}    "
    ${token_value}=    Set variable          ${split}[3]
    Log    ${token_value}     console=Trie
    [Return]           ${token_value}

Check PCAP for REST connection
    [Documentation]    Description:    Check if the handshake was occured during connection between M-Plane and REST API
    ...                Input:          tcpdump_path: path to PCAP file
    ...                Output:         pass/fail
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${tcpdump_path}    ${bts_ip}
    ${VM_address}=                    Get VM address
    PCAP Should Contain Message
    ...    tshark_filter=tls.handshake.type == 11 and ip.src == ${bts_ip} and ip.dst == ${VM_address}
    ...    pcap_file=${tcpdump_path}


Check Operation History
    [Arguments]     ${hw_type}=${NONE}
    ${operation}    Get Operation History List    hw_type=${hw_type}
    ${operation_history}    Set Variable If    '${hw_type}'=='vCU'    ${operation}[created]   ${operation}
    @{login_list}=    Create List
    @{logout_list}=    Create List
    FOR    ${i}    IN    @{operation_history}
        IF    '${i}[triggering_source]' == 'M2M'
            IF    '${i}[name]' == 'Login'
                Append To List    ${login_list}    ${i}
            ELSE IF    '${i}[name]' == 'Logout'
                Append To List    ${logout_list}    ${i}
            END
        END
    END
   ${match}=    Compare Session ID    ${login_list}    ${logout_list}
   [Return]    ${match}

Compare Session ID
    [Documentation]    Description:    Compare last logout and login session ID for match
    ...                Input:          login_list    logout_list from Get Operation History KW
    ...                Output:         true/false for maching session id
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]    ${login_list}    ${logout_list}
    FOR    ${login_id}    IN    ${login_list}
        ${login_session_id}    Get From Dictionary    ${login_id}[0]    session_id
        FOR    ${logout_id}     IN    ${logout_list}
            ${logout_session_id}    Get From Dictionary    ${logout_id}[0]    session_id
            ${match}    Set Variable If    '${login_session_id}' == '${logout_session_id}'    ${TRUE}    ${FALSE}
            Run Keyword If    '${match}'=='${TRUE}'    Return From Keyword    ${match}
        END
        Log to console    ${match}
    END
    Log to console    ${match}
    [Return]    ${match}


Get Information using REST Command
    [Documentation]    Description:    Executing command with REST API
    ...                Input:          rest_command: the used command to get information - depends on CU and DU
    ...                                token_value: the token (from the Get Token Value KW)
    ...                Output:         rest_output: the output from the defined command
    ...                Author:         grzegorz.niedzwiedz@nokia.com
    [Arguments]        ${bts_ip}    ${rest_command}    ${token_value}
    ${rest_output}=    Run    ${get_sw}${bts_ip}${rest_command} ${token_value}"
    [Return]           ${rest_output}

Get BTS info
    [Arguments]        ${hw_type}=${NONE}
    ${connection}=     Connect to ADMIN      hw_type=${hw_type}
    ${dictionary}        Run Keyword If        '${hw_type}'=='vCU'    vcu_admin.get_cu_state   connection=${connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_vdu_state_data    vdu_connection=${connection}
    ...    ELSE        FAIL                  hw_type doesn't exist
    ${software_version}=    Get From Dictionary    ${dictionary}    software_version
    Log    The software version is: ${software_version}    console=True
    [Return]    ${software_version}
    [Teardown]    Disconnect from ADMIN    hw_type=${hw_type}    connection=${connection}
