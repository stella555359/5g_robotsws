*** Settings ***
Documentation
...    author:          Grzegorz Niedzwiedz
...    contact:         grzegorz.niedzwiedz@nokia.com
...    Test Plan (QC):  Root/Test_Sets/25R3/New_Features/VRF_WRO3_T04/CB011146
...    Description:     The CB011146 feature introduces new REST API interface.

Resource    ../Resources/CB011146_CR_Keywords.robot

*** Variables ***

@{CRAN}    vCU    vDU

*** Keywords ***

CB011146-CR-B_APIGW_Authenticaton
    FOR    ${i}    IN    @{CRAN}
        Delete All Certificates    hw_type=${i}
        ${CRAN}=    Set Variable If    '${i}'=='vCU'    ${CRAN_VCU}    ${CRAN_VDU}
        ${LMP_IP}=    Set Variable If    '${i}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
        ${MRBTS_IP}    Set Variable If    '${i}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
        Log    CHECKING CONNECTION TO ${i}    console=True
        Log    Step 0: Initializing the RSA and ECDSA certificates and change btsMaxFailedLoginAttempts    console=True
        Certificates Initialization    hw_type=${i}    cert_type=ECDSA    ca_sub_name=${ECDSA}
        Certificates Initialization    hw_type=${i}    cert_type=RSA      ca_sub_name=${RSA}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                             param_name=btsMaxFailedLoginAttempts    param_value=${0}    hw_type=${i}

        Log    Step 1: Log to Webem with wrong REST creditentials    console=True
        ${login_status}=          CB011146_CR_Keywords.Perform REST login    ${wronglogin_2}    ${i}
        Should Contain            ${login_status}       Authentication failed

        Log    Step 2: Set TLS 1.2 to true and certificates to RSA type and start PCAP    console=True
        Configure TLS versions          1_2=true    1_3=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForTlsAuth    param_value=RSA    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForRestHttpsTLSAuth    param_value=RSA    hw_type=${i}
        Start TCPdump    capture_type=pod    pod_names=ute-oamext-0    hw_type=${i}

        Log    Step 3: Log to WebEM with correct REST creditentials and check TLS version   console=True
        ${rest_login}=    CB011146_CR_Keywords.Perform REST login    ${correct_login_2}    ${i}
        Should Contain    ${rest_login}         SSL connection using TLSv1.2
        Sleep             15s                   reason=Wait until PCAP file is collected properly

        Log    Step 4: Check if connection is established with TLS 1.2 and RSA cert    console=True
        ${pcap_path}=    Stop TCPdump and Download Pcap    pod_name=ute-oamext-0     hw_type=${i}
        ${VM_address}=                  Get VM address
        Check PCAP for REST connection    ${pcap_path}    ${LMP_IP}
        Check Used Certificate            ${pcap_path}    ${RSA_pcap}    ${LMP_IP}    ${VM_address}

        Log    Step 5: Check if WebEM session list have REST session connected    console=True
        ${operation_list}=    Run keyword and ignore error    Check Operation History   ${i}
        Run keyword and ignore error    Should not be true    ${operation_list}

        Log    Step 6: Perform logout from webEM using REST command    console=True
        ${token_value}=                   CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${output}=                        CB011146_CR_Keywords.Perform REST logout   ${token_value}    ${i}
        Should Contain                    ${output}             HTTP/1.1 204
        Sleep             15s                   reason=Wait until PCAP file is collected properly

        Log    Step 7: Set certificates to ECDSA type and start PCAP    console=True
        Configure TLS versions          1_2=true    1_3=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForTlsAuth    param_value=ECDSA    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForRestHttpsTLSAuth    param_value=ECDSA    hw_type=${i}
        Start TCPdump    capture_type=pod    pod_names=ute-oamext-0    hw_type=${i}

        Log    Step 8: Log to WebEM with correct REST creditentials and check TLS version   console=True
        ${rest_login}=    CB011146_CR_Keywords.Perform REST login    ${correct_login_2}    ${i}
        Should Contain    ${rest_login}         SSL connection using TLSv1.2
        Sleep             15s                   reason=Wait until PCAP file is collected properly

        Log    Step 9: Check if connection is established with TLS 1.2 and RSA cert    console=True
        ${pcap_path}=    Stop TCPdump and Download Pcap    pod_name=ute-oamext-0     hw_type=${i}
        ${VM_address}=                  Get VM address
        Check PCAP for REST connection    ${pcap_path}    ${LMP_IP}
        Check Used Certificate            ${pcap_path}    ${ECDSA_pcap}    ${LMP_IP}    ${VM_address}

    #    Log    Step 10: Check if WebEM session list have REST session connected    console=True
    #    ${operation_list}=    Check Operation History   ${i}
    #    Should not be true    ${operation_list}

        Log    Step 11: Perform logout from WebEM using REST command    console=True
        ${token_value}=                   CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${output}=                        CB011146_CR_Keywords.Perform REST logout   ${token_value}    ${i}
        Should Contain                    ${output}             HTTP/1.1 204
        Sleep             15s                   reason=Wait for Operation History list update

    #    Log    Step 12: Check if WebEM session list does NOT have REST session connected    console=True
    #    ${operation_list}=    Check Operation History   ${i}
    #    Should be true    ${operation_list}

        Log    Step 13: Set TLS version to 1.3    console=True
        Configure TLS versions          1_2=false    1_3=true    hw_type=${i}

        Log    Step 14: Log to WebEM with correct REST creditentials and check TLS version   console=True
        ${rest_login}=    CB011146_CR_Keywords.Perform REST login    ${correct_login_2}    ${i}
        Should Contain    ${rest_login}         SSL connection using TLSv1.3
        Sleep                             15s

    #    Log    Step 15: Check if WebEM session list have REST session connected    console=True
    #    ${operation_list}=    Check Operation History   ${i}
    #    Should not be true    ${operation_list}
        ${get_sw_cran}    Set Variable If    '${i}'=='vCU'    ${get_sw_cu1}    ${get_sw_du1}
        Log    Step 16: Check SW version using REST command and compare it with SW from WebEM    console=True
        ${token_value}=                   CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${rest_sw_version}=               Get Information using REST Command    ${LMP_IP}    ${get_sw_cran}    ${token_value}
        ${webem_sw_version}=              Get BTS info    ${i}
        Should Contain                    ${rest_sw_version}    ${webem_sw_version}

        Log    Step 17: Perform site reset    console=True
        Perform Reset and Wait for Expected State    configured    ${i}

    #    Log    Step 18: Check if WebEM session list does have REST session connected after site reset   console=True
    #    ${operation_list}=    Check Operation History   ${i}
    #    Should not be true    ${operation_list}

        Log    Step 19: Try to use bad token to get SW Version using REST command    console=True
        ${token_value}=                   CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${rest_sw_version}=               Get Information using REST Command    ${LMP_IP}    ${get_sw_cran}    ${token_value}_wrong
        ${webem_sw_version}=              Get BTS info    ${i}
        Should Not Contain                ${rest_sw_version}    ${webem_sw_version}
        Log     SW Version was not compared, due to M2M inactive token.    console=True
    END

    [Teardown]                        Run Keywords
    ...                               Run keyword and ignore error      Restore Default Certificates on BTS    vCU
    ...     AND                       Run keyword and ignore error      Restore Default Certificates on BTS    vDU
