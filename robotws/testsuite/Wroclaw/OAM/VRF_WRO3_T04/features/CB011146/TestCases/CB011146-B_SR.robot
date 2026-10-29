*** Settings ***
Documentation
...    author:          Grzegorz Niedzwiedz
...    contact:         grzegorz.niedzwiedz@nokia.com
...    Test Plan (QC):  Root/Test_Sets/25R3/New_Features/VRF_WRO3_T04/CB011146
...    Description:     The CB011146 feature introduces new REST API interface.

Resource    ../../../common_resources/rest_api/rest_api.robot

*** Keywords ***
CB011146-SR-B_APIGW_Authenticaton
    Add Multiple Alarms to Watchdog List    4291
    Log    Step 0: Initializing the RSA and ECDSA certificates    console=True
    Set CMP Server Settings         key_pool_type=ECDSA
    Set CMP Server Settings         key_pool_type=RSA
    Configure CMP                   ca_subject_name=${ECDSA_SUBJECT_NAME}
    ...                             server_type=ECDSA
    Initialize Certificates         key_pool_type=ECDSA
    Configure CMP                   ca_subject_name=${RSA_SUBJECT_NAME}
    ...                             server_type=RSA
    Initialize Certificates         key_pool_type=RSA
    Log    Step 1: Log to Webem with wrong REST creditentials    console=True
    ${login_status}=          Perform REST login    ${wronglogin_2}
    Should Contain            ${login_status}       Authentication failed
    Log    Step 2: Set TLS 1.2 to true and certificates to RSA type and start PCAP    console=True
    Configure TLS versions    1_2=true  cert_type=RSA
    Start Tcpdump
    Log    Step 3: Log to WebEM with correct REST creditentials and check TLS version   console=True
    ${rest_login}=    Perform REST login    ${login_2}
    Should Contain    ${rest_login}         SSL connection using TLSv1.2
    Sleep             15s                   reason=Wait until PCAP file is collected properly
    Log    Step 4: Check if connection is established with TLS 1.2 and RSA cert    console=True
    ${tcpdump_path}=                  Stop TCPDump And Download PCAP    tcpdump_filename=tls_and_cert_check.pcap
    ${VM_address}=                    Get VM IP address
    Check PCAP for REST connection    ${tcpdump_path}
    Check Used Certificate            ${tcpdump_path}       ${rsa}   ${MPLANE_IPV4}   ${VM_address}
    Log    Step 5: Check if WebEM session list have REST session connected    console=True
    ${sessions_list}=                 Get Sessions List
    List Should Contain Value         ${sessions_list}      REST
    Log    Step 6: Perform logout from webEM using REST command    console=True
    ${token_value}=                   Get Token Value       ${rest_login}
    ${output}=                        Perform REST logout   ${token_value}
    Should Contain                    ${output}             HTTP Status: 204
    Log    Step 7: Set certificates to ECDSA type and start PCAP    console=True
    Configure TLS versions            1_2=true             cert_type=ECDSA
    Start Tcpdump
    Log    Step 8: Log to WebEM with correct REST creditentials and check TLS version   console=True
    ${rest_login}=                    Perform REST login    ${login_2}
    Should Contain                    ${rest_login}         SSL connection using TLSv1.2
    Sleep                             15s                   reason=Wait until PCAP file is collected properly
    Log    Step 9: Check if connection is established with TLS 1.2 and RSA cert    console=True
    ${tcpdump_path}=                  Stop TCPDump And Download PCAP    tcpdump_filename=tls_and_cert_check.pcap
    ${VM_address}=                    Get VM IP address
    Check PCAP for REST connection    ${tcpdump_path}
    Check Used Certificate            ${tcpdump_path}      ${ecdsa}    ${MPLANE_IPV4}     ${VM_address}
    Log    Step 10: Check if WebEM session list have REST session connected    console=True
    ${sessions_list}=                 Get Sessions List
    List Should Contain Value         ${sessions_list}      REST
    Log    Step 11: Perform logout from WebEM using REST command    console=True
    ${token_value}=                   Get Token Value       ${rest_login}
    ${output}=                        Perform REST logout   ${token_value}
    Should Contain                    ${output}             HTTP Status: 204
    Log    Step 12: Check if WebEM session list does NOT have REST session connected    console=True
    ${sessions_list}=                 Get Sessions List
    List Should Not Contain Value     ${sessions_list}      REST
    Log    Step 13: Set TLS version to 1.3    console=True
    Configure TLS versions            1_3=true              cert_type=RSA
    Log    Step 14: Log to WebEM with correct REST creditentials and check TLS version   console=True
    ${rest_login}=                    Perform REST login    ${login_2}
    Should Contain                    ${rest_login}         SSL connection using TLSv1.3
    Sleep                             15s
    Log    Step 15: Check if WebEM session list have REST session connected    console=True
    ${sessions_list}=                 Get Sessions List
    List Should Contain Value         ${sessions_list}      REST
    Log    Step 16: Check SW version using REST command and compare it with SW from WebEM    console=True
    ${token_value}=                   Get Token Value       ${rest_login}
    ${rest_sw_version}=               Get Information using REST Command    ${get_sw}    ${token_value}
    ${connection}=                    Connect to ADMIN
    ${webem_sw_version}=              coam_admin.Get SW Version        connection=${connection}
    Disconnect from ADMIN             ${connection}
    Should Contain                    ${rest_sw_version}    ${webem_sw_version}
    Log    Step 17: Perform site reset    console=True
    Reset Site And Reconnect
    Wait Until Keyword Succeeds       10m  60s   Wait Until BTS Reach Configured Or OnAir State
    Log    Step 18: Check if WebEM session list does NOT have REST session connected after site reset   console=True
    ${sessions_list}=                 Get Sessions List
    List Should Not Contain Value     ${sessions_list}      REST
    Log    Step 19: Try to use inactive token to get SW Version using REST command    console=True
    ${token_value}=                   Get Token Value       ${rest_login}
    ${rest_sw_version}=               Get Information using REST Command    ${get_sw}    ${token_value}
    ${connection}=                    Connect to ADMIN
    ${webem_sw_version}=              coam_admin.Get SW Version        connection=${connection}
    Disconnect from ADMIN             ${connection}
    Should Not Contain                ${rest_sw_version}    ${webem_sw_version}
    [Teardown]                        Run Keyword and ignore error   Clear Certificates
