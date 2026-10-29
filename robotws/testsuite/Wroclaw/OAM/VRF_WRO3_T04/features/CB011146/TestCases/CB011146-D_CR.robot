*** Settings ***
Documentation
...    author:          Grzegorz Niedzwiedz/Agnieszka Brzoska
...    contact:         grzegorz.niedzwiedz@nokia.com/agnieszka.brzoska@nokia.com
...    Test Plan (QC):  Root/Test_Sets/25R3/New_Features/VRF_WRO3_T04/CB011146
...    Description:     The CB011146 feature introduces new REST API interface.

Resource    ../Resources/CB011146_CR_Keywords.robot

*** Variables ***

@{CRAN}    vCU    vDU

*** Keywords ***
CB011146-CR-D_Supported_ciphers_check_with_Logging_about_failed_TLS_connections
    Log    CHECKING CONNECTION TO vCU   console=True
    FOR    ${i}    IN    @{CRAN}
        ${MRBTS_IP}    Set Variable If    '${i}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
        Log    Step 0: Initializing the RSA and ECDSA certificates    console=True
        Restore Default Certificates on BTS    ${i}
        Certificates Initialization    hw_type=${i}    cert_type=ECDSA    ca_sub_name=${ECDSA}
        Certificates Initialization    hw_type=${i}    cert_type=RSA      ca_sub_name=${RSA}

        Log    Step 2: Set up TLS settings on BTS    console=True
        Configure TLS versions          1_2=true    1_3=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForTlsAuth             param_value=RSA      hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForRestHttpsTLSAuth    param_value=RSA      hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12CbcCipherDisabled         param_value=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12RsaKExDisabled            param_value=false    hw_type=${i}
        Sleep                           60
        Log    Step 3: Log to WebEM with REST and check RSA ciphers   console=True
        Check Ciphers With Curl         ${RSA_CIPHERS}   ${ECDSA_CIPHERS}    ${i}

        Log    Step 4: Log to WebEM with REST and check RSA ciphers with only tls12CbcCipherDisabled set to TRUE   console=True
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12CbcCipherDisabled         param_value=true    hw_type=${i}
        ${available_ciphers}=           Available Cipher List    ${RSA_CIPHERS}                       ${TLS12CBC_CIPHERS_DISABLED}
        Check Ciphers With Curl         ${available_ciphers}     ${TLS12CBC_CIPHERS_DISABLED}         ${i}

        Log    Step 5: Log to WebEM with REST and check RSA ciphers with only tls12RsaKExDisabled set to TRUE   console=True
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12CbcCipherDisabled         param_value=false    hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12RsaKExDisabled            param_value=true     hw_type=${i}
        ${available_ciphers}=           Available Cipher List    ${RSA_CIPHERS}                        ${TLS12RSAKEX_CIPHERS_DISABLED}
        Check Ciphers With Curl         ${available_ciphers}     ${TLS12RSAKEX_CIPHERS_DISABLED}       ${i}

        Log    Step 6: Log to WebEM with REST and check ECDSA ciphers   console=True
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForTlsAuth             param_value=ECDSA      hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=certTypeForRestHttpsTLSAuth    param_value=ECDSA      hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12CbcCipherDisabled         param_value=false      hw_type=${i}
        Change Parameter on BTS         dist_name=MRBTS-${MRBTS_IP}/MNL-1/MNLENT-1/MPLANENW-1
        ...                             param_name=tls12RsaKExDisabled            param_value=false      hw_type=${i}
        Check Ciphers With Curl         ${ECDSA_CIPHERS}                          ${RSA_CIPHERS}         ${i}
    END
    [Teardown]                        Run Keywords
    ...                               Run keyword and ignore error      Restore Default Certificates on BTS    vCU
    ...     AND                       Run keyword and ignore error      Restore Default Certificates on BTS    vDU

CB011146-CR-D_M2m_user_account_operations
    FOR    ${i}    IN    @{CRAN}
        ${CRAN}=    Set Variable If    '${i}'=='vCU'    ${CRAN_VCU}    ${CRAN_VDU}
        ${LMP_IP}=    Set Variable If    '${i}'=='vCU'    ${LMP_VCU_IP}    ${LMP_VDU_IP}
        ${MRBTS_IP}    Set Variable If    '${i}'=='vCU'    ${MRBTS_CU}    ${MRBTS}
        Log    Step 0: Precondition- setup user account    console=True
        Log    CHECKING CONNECTION TO vCU   console=True
        Setup Local User Account      ${app_user_account}    ${app_password}    active    hw_type=${i}
        Log    Step 1: Change parameter on BTS    console=True
        Change Parameter on BTS       MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                           param_name=btsMaxFailedLoginAttempts    param_value=0    hw_type=${i}
        Log    Step 2: Log to Webem with wrong REST creditentials several times   console=True
        #Using a loop to perform multiple login attempts
        FOR    ${index}               IN RANGE    5
        ${login_status}=              CB011146_CR_Keywords.Perform REST login    ${wronglogin_2}    ${i}
        Should Contain Any                ${login_status}    Authentication failed   Locked user
        Sleep    5s                   reason=btsSessionLoginDelay
        END
        Log    Step 3: Log to WebEM with correct REST creditentials  console=True
        ${rest_login}=               CB011146_CR_Keywords.Perform REST login    ${correct_login_2}    ${i}
        Log    Step 4: Perform logout from webEM using REST command   console=True
        ${token_value}=              CB011146_CR_Keywords.Get Token Value       ${rest_login}
        ${output}=                   CB011146_CR_Keywords.Perform REST logout   ${token_value}    ${i}
        Should Contain               ${output}             HTTP/1.1 204
        Log    Step 5: Change parameter on BTS- btsMaxFailedLoginAttempts    console=True
        Change Parameter on BTS      MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=btsMaxFailedLoginAttempts    param_value=2    hw_type=${i}
        Log    Step 6: Change parameter on BTS- lockout duration    console=True
        Change Parameter on BTS      MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=btsAccountLockoutDuration    param_value=1    hw_type=${i}
        Log    Step 7: Log to Webem with wrong creditentials 3 times- we want to lock account   console=True
        #Using a loop to perform multiple login attempts
        FOR    ${index}              IN RANGE    4
        ${login_status}=             CB011146_CR_Keywords.Perform REST login    ${wronglogin_1}    ${i}
        Should Contain Any           ${login_status}    Authentication failed   Locked user
        Sleep    5s                  reason=btsSessionLoginDelay
        END
        Log    Step 8: Try to log to WebEM with correct credential- account is locked    console=True
        ${rest_login}=               CB011146_CR_Keywords.Perform REST login    ${correct_login_1}    ${i}
        Should contain               ${rest_login}    Locked user
        Log    Step 9: Log as Admin and change BTS account lockout duration to different value    console=True
        ${rest_login}=               CB011146_CR_Keywords.Perform REST login    ${correct_login_2}    ${i}
        Should Contain               ${rest_login}         SSL connection using TLS
        Change Parameter on BTS      MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=btsAccountLockoutDuration    param_value=2    hw_type=${i}
        Log    Step 10: Change parameter and log in to BTSApplication    console=True
        Change Parameter on BTS      MRBTS-${MRBTS_IP}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=jwtExpirationTime    param_value=10    hw_type=${i}
        ${rest_login_1}=             CB011146_CR_Keywords.Perform REST login   ${correct_login_1}    ${i}
        Should Contain               ${rest_login_1}    SSL connection using TLS
        Log    Step 11: Using wrong credential until account is locked    console=True
        #Using a loop to perform multiple login attempts
        FOR    ${index}              IN RANGE    3
        ${login_status}=             CB011146_CR_Keywords.Perform REST login    ${wronglogin_1}    ${i}
        Should Contain Any           ${login_status}    Authentication failed   Locked user
        Sleep    5s                  reason=btsSessionLoginDelay
        END
        Log    Step 12: Check SW version using token from step 10 and compare it with SW from WebEM    console=True
        ${token_value}=             CB011146_CR_Keywords.Get Token Value    ${rest_login_1}
        ${get_sw_cran}    Set Variable If    '${i}'=='vCU'    ${get_sw_cu1}    ${get_sw_du1}
        ${rest_sw_version}=         Get Information using REST Command    ${LMP_IP}    ${get_sw_cran}    ${token_value}
        ${vcu_connection}=          Connect to ADMIN    hw_type=${i}
        ${webem_sw_version}=        Get BTS info    hw_type=${i}
        Should Contain              ${rest_sw_version}    ${webem_sw_version}
    END
    Log    Step 13: Enable parameter enableUserAccountCtrlAlarm and activate cnum user- check alarm    console=True
    Change Parameter on BTS     MRBTS-${MRBTS_CU}/MNL-1/AMGR-1/LUAC-1
    ...                         enableUserAccountCtrlAlarm    true    hw_type=vCU
    ${NMS_LAB_VCU}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vCU   preferred_lab=srnclab1047
    Run Keyword and ignore error
    ...                        nms.activate_cnum
    ...                        ne_id_value=PLMN-PLMN/MRBTS-${MRBTS_CU}
    ...                        alias=${NMS_LAB_VCU}
    ...                        ldap_access_type=STARTTLS
    ...                        ip_type=IPv4
    Wait Until Keyword Succeeds
    ...                        10min    1min    Alarm Should be Active    4775    hw_type=vCU
    ${rest_login_1}=          CB011146_CR_Keywords.Perform REST login   ${correct_login_1}    vCU
    Log    Step 14: Waiting for expiration token and try to use inactive token    console=True
    Sleep    600s             reason=waiting about 10min until token expired
    ${token_value}=           CB011146_CR_Keywords.Get Token Value       ${rest_login_1}
    ${rest_sw_version}=       Get Information using REST Command    ${LMP_VCU_IP}    ${get_sw_cu1}    ${token_value}
    ${webem_sw_version}=      Get BTS info    vCU
    Should Not Contain        ${rest_sw_version}    ${webem_sw_version}

    Change Parameter on BTS     MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                         enableUserAccountCtrlAlarm    true    hw_type=vDU
    ${NMS_LAB_VDU}    Integrate Cloud BTS with NMS Lab without TLS    hw_type=vDU   preferred_lab=srnclab1047
    Run Keyword and ignore error
    ...                        nms.activate_cnum
    ...                        ne_id_value=PLMN-PLMN/MRBTS-${MRBTS}
    ...                        alias=${NMS_LAB_VDU}
    ...                        ldap_access_type=STARTTLS
    ...                        ip_type=IPv4
    Wait Until Keyword Succeeds
    ...                        10min    1min    Alarm Should be Active    4775    hw_type=vDU
    Log    Step 14: Waiting for expiration token and try to use inactive token    console=True
    ${rest_login_1}=          CB011146_CR_Keywords.Perform REST login   ${correct_login_1}    vDU
    Sleep    600s             reason=waiting about 10min until token expired
    ${token_value}=           CB011146_CR_Keywords.Get Token Value       ${rest_login_1}
    ${rest_sw_version}=       Get Information using REST Command    ${LMP_VDU_IP}    ${get_sw_du1}    ${token_value}
    ${webem_sw_version}=      Get BTS info    vDU
    Should Not Contain        ${rest_sw_version}    ${webem_sw_version}
    [Teardown]                 Run keywords
    ...                        Run keyword and ignore error    nms.deactivate_cnum
    ...                        ne_id_value=PLMN-PLMN/MRBTS-${MRBTS}
    ...    AND                 Run keyword and ignore error    nms.deactivate_cnum
    ...                        ne_id_value=PLMN-PLMN/MRBTS-${MRBTS_CU}
    ...    AND                 Deintegrate Cloud BTS from NMS Lab  ${NMS_LAB_VDU}    hw_type=vDU
    ...    AND                 Deintegrate Cloud BTS from NMS Lab  ${NMS_LAB_VCU}    hw_type=vCU
