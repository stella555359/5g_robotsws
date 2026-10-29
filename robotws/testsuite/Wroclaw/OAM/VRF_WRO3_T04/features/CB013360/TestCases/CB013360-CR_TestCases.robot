*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/26R1/CB013360/
...    Description:

Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/accounts/accounts.robot
Resource    ../../../../cloud_common_resources/alarms/alarms.robot

*** Variables ***
${wrong_pass}=        notNokia@123
${local_pass_ab2}=    Nokia@User@AB2@12345
${local_pass_ab3}=    Nokia@User@AB3@12345

${7672_cert}=         CN=CB007672
${ipsec_cert}=        C=PL, O=Common, CN=IPSEC

${insta_ip_correct}=     10.42.54.11
${insta_incorrect_p}=    10.42.54.13
${insta_incorrect_s}=    10.42.54.15
${correct_crldp}=        ${insta_ip_correct}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${incorrect_crldp_p}=    ${insta_incorrect_p}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${incorrect_crldp_s}=    ${insta_incorrect_s}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary

${crl_update_alarm}=     CRL Update failure or certificate revoked

${crl_update_log}=        UPDATE_CRL
${cert_init_log}=         TRIGGER_CERTIFICATE_INITIALIZATION
${status_pass_log}=       'eventStatus': 'SUCCESS'
${status_fail_log}=       'eventStatus': 'FAILURE'
${status_inc_log}=        'eventStatus': 'INCOMPLETE'
${app_pass_log}=          userRole=appUserAccessMode, Operation Details=Password changed
${sec_pass_log}=          userRole=secUserAccessMode, Operation Details=Password changed
${read_pass_log}=         userRole=readOnlyUserAccessMode, Operation Details=Password changed
${app_act_true_log}=      "appAdmActivated\":true
${app_act_false_log}=     "appAdmActivated\":false
${sec_act_true_log}=      "secAdmActivated\":true
${sec_act_false_log}=     "secAdmActivated\":false
${read_act_true_log}=     "readOnlyActivated\":true
${read_act_false_log}=    "readOnlyActivated\" false
${login_fail_log}=        Failed to login with read-write mode, error: Authentication failed
${cmp_key_log}=           CMP_KEY_UPDATE

${lab_with_atl}=          srnclab2010

*** Keywords ***
Additional_sec_event_record_local_accounts_operations_vDU
    Log                                  Step 0: Turn on local user parameters    console=True
    ${local_dn}=    Create List          MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ...                                  MRBTS-${MRBTS}/MNL-1/AMGR-1/LUAC-1
    ${local_pn}=    Create List          appAdmActivated    secAdmActivated    readOnlyActivated
    ${local_pv}=    Create List          true    true    true
    Change Multiple Parameters on BTS    ${local_dn}    ${local_pn}    ${local_pv}    hw_type=vDU
    Log                                  Step 1: Try to connect to system admin with incorrect password    console=True
    Run Keyword and Expect Error         *AuthenticationFailed*    Connect to ADMIN
    ...                                  password=${wrong_pass}    hw_type=vDU
    Log                                  Step 2: Connect to system admin with correct credentials    console=True
    Sleep    10s                         reason=Wait before next connection attempt
    ${conn_sys}=                         Connect to ADMIN    hw_type=vDU
    Log                                  Step 3: Perform CMP Key Update as system admin    console=True
    Configure CMP                        ca_subject_name=${7672_cert}    pre-connection=${conn_sys}    hw_type=vDU
    Update CMP Server Settings           pre-connection=${conn_sys}    hw_type=vDU
    Initialize Certificate               pre-connection=${conn_sys}    hw_type=vDU
    Update CMP Key                       pre-connection=${conn_sys}    hw_type=vDU
    Log                                  Step 4: Disconnect from system admin connection    console=True
    Disconnect from ADMIN                ${conn_sys}    hw_type=vDU
    Log                                  Step 5: Setup and connect as read-only user    console=True
    Setup Local User Account             account_type=BTSRead    password=${local_pass_ab2}
    ...                                  status=active    hw_type=vDU
    ${conn_read}=                        Connect to ADMIN     username=BTSRead
    ...                                  password=${local_pass_ab2}    hw_type=vDU
    Log                                  Step 6: Try to perform CMP Key Update as read-only user    console=True
    Run Keyword and Expect Error         *HTTP method not allowed for read-write session*    Update CMP Key
    ...                                  pre-connection=${conn_read}    hw_type=vDU
    Log                                  Step 7: Disconnect from read-only user connection    console=True
    Disconnect from ADMIN                ${conn_read}    hw_type=vDU
    Log                                  Step 8: Setup and connect as security admin    console=True
    Setup Local User Account             account_type=BTSSecurity    password=${local_pass_ab2}
    ...                                  status=active    hw_type=vDU
    ${conn_sec}=                         Connect to ADMIN     username=BTSSecurity
    ...                                  password=${local_pass_ab2}    hw_type=vDU
    Log                                  Step 9: Verify logs using security admin connection    console=True
    ${report}=                           Get Account Report    account_type=BTSRead
    ...                                  pre-connection=${conn_sec}    hw_type=vDU
    Should not be Empty                  ${report["lastLoginTime"]}
    Should not be Empty                  ${report["lastLogoutTime"]}
    [Teardown]    Run Keywords           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  ${conn_sys}    hw_type=vDU
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  ${conn_read}    hw_type=vDU
    ...    AND                           Run Keyword and Ignore Error    Disconnect from ADMIN
    ...                                                                  ${conn_sec}    hw_type=vDU

Additional_sec_event_record_local_accounts_operations_by_Manta-Ray_vDU
    Log                                 Step 2: Setup and activate Security Admin account    console=True
    Setup Local User Account            account_type=BTSSecurity    password=${local_pass_ab3}
    ...                                 status=active    hw_type=vDU
    Log                                 Step 3: Setup and activate Application Admin account    console=True
    Setup Local User Account            account_type=BTSApplication    password=${local_pass_ab3}
    ...                                 status=active    hw_type=vDU
    Log                                 Step 4: Setup and activate ReadOnly user account    console=True
    Setup Local User Account            account_type=BTSRead    password=${local_pass_ab3}
    ...                                 status=active    hw_type=vDU
    Log                                 Step 5: Deactivate Security Admin account    console=True
    Change Local User Account State     account_type=BtsSecurity    is_active=${FALSE}    hw_type=vDU
    Log                                 Step 6: Deactivate Application Admin account    console=True
    Change Local User Account State     account_type=BtsApplication    is_active=${FALSE}    hw_type=vDU
    Log                                 Step 7: Deactivate ReadOnly user account    console=True
    Change Local User Account State     account_type=BtsRead    is_active=${FALSE}    hw_type=vDU

Audit_login_during_manual_CRL_download_failure_and_retry_vCU
    Log                     Step 1: Remove CRLDPconfig object if exists    console=True
    Delete Object on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1    hw_type=vCU
    Log                     Step 2: Connect to system admin with correct credentials    console=True
    ${conn}=                Connect to ADMIN    hw_type=vCU
    Log                     Step 3: Create and configure CRLDPconfig with both ip address wrong    console=True
    ${pn}=                  Create List    primaryCRLDP    secondaryCRLDP
    ${pv}=                  Create List    ${incorrect_crldp_p}    ${incorrect_crldp_s}
    Create Object with Multiple Parameters on BTS    MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                                              ${pn}    ${pv}    hw_type=vCU    pre-connection=${conn}
    Log                                  Step 4: Initialize certificate    console=True
    ${dn}=    Create List                MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ...                                  MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1
    ${pn}=    Create List                distributionPointSource    crlDownloadProtocol    usageEnabled
    ${pv}=    Create List                Configuration_parameter    LDAP_OR_HTTP    Enabled
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    pre-connection=${conn}    hw_type=vCU
    Configure CMP                        ca_subject_name=${7672_cert}    pre-connection=${conn}    hw_type=vCU
    Update CMP Server Settings           pre-connection=${conn}    hw_type=vCU
    Initialize Certificate               pre-connection=${conn}    hw_type=vCU
    Log                                  Step 5: Check if CRL update fails    console=True
    vcu_admin.trigger_crl_information_update    timeout=${300}    connection=${conn}
    Wait Until Keyword Succeeds          15min    10s    Check if last CRL Update was incorrect
    ...                                  pre-connection=${conn}    hw_type=vCU
    Log                                  Looking for "${crl_update_alarm}" alarm    console=True
    Wait Until Keyword Succeeds          15min    10s    Alarm Should be Active    alarm=${crl_update_alarm}
    ...                                  pre-connection=${conn}    hw_type=vCU
    Log                                  Step 6: Update secondaryCRLDP to correct value    console=True
    Change Parameter on BTS              dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                                  param_name=secondaryCRLDP    param_value=${correct_crldp}    hw_type=vCU
    Log                                  Step 7-8: Check if CRL update passes    console=True
    vcu_admin.trigger_crl_information_update    timeout=${300}    connection=${conn}
    Wait Until Keyword Succeeds          15min    10s    Check if last CRL Update was correct
    ...                                  pre-connection=${conn}    hw_type=vCU
    Log                                  Waiting for "${crl_update_alarm}" alarm to disappear    console=True
    Wait Until Keyword Succeeds          15min    10s    Alarm Should not be Active    alarm=${crl_update_alarm}
    ...                                  pre-connection=${conn}    hw_type=vCU
    [Teardown]    Run Keywords    Disconnect from ADMIN    ${conn}    hw_type=vCU
    ...    AND                    Restore Default Certificates on BTS    hw_type=vCU

Audit_login_during_certificate_enrollment_or_renewal_vCU
    Log                        Step 0: Remove CRLDPconfig object if exists   console=True
    Delete Object on BTS       dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1    hw_type=vCU
    Log                        Step 1: Connect to system admin with correct credentials    console=True
    ${conn}=                   Connect to ADMIN    hw_type=vCU
    ${state_before}=           Get Current BTS State      hw_type=vCU    pre-connection=${conn}
    Log                        Step 2: Configure primary and secondary CMP with wrong server addresses    console=True
    Configure Both CMP         primary_ca_subject_name=${7672_cert}    secondary_ca_subject_name=${ipsec_cert}
    ...                        primary_ca_server_host=5.5.5.5    secondary_ca_server_host=6.6.6.6    hw_type=vCU
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1    param_name=cmpPollingTimeout
    ...                        param_value=60    hw_type=vCU    pre-connection=${conn}
    Log                        Step 3: Try to initialize certyficate with wrong server address    console=True
    Run Keyword and Expect Error    *    Initialize Certificate    pre-connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds     5min    10s    Alarm Should be Active    alarm=61510
    ...                             pre-connection=${conn}    hw_type=vCU
    Log                        Step 5: Wait for automatic reattempt    console=True
    Sleep    180s              reason=Waiting until reattempt ends
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active    alarm=61510
    ...                             pre-connection=${conn}    hw_type=vCU
    Log                        Step 6: Configure primary and secondary CMP with correct server addresses    console=True
    Configure Both CMP         primary_ca_subject_name=${7672_cert}
    ...                        secondary_ca_subject_name=${ipsec_cert}    hw_type=vCU
    Log                        Step 7: Initialize certyficate with correctly filled server addresses     console=True
    Initialize Certificate         pre-connection=${conn}    hw_type=vCU
    Wait Until Keyword Succeeds    5min    10s    Alarm Should not be Active    alarm=61510
    ...                                           pre-connection=${conn}    hw_type=vCU
    Log                        Step 9: Restore default certificates    console=True
    Restore Default Certificates on BTS    pre-connection=${conn}    hw_type=vCU
    Disconnect from ADMIN      ${conn}    hw_type=vCU
    Log                        Step 10: Perform vCU reset    console=True
    Perform Reset and Wait for Expected State    state=${state_before}    hw_type=vCU
    [Teardown]                 Run Keywords    Run Keyword and Ignore Error
    ...                        Disconnect from ADMIN    ${conn}    hw_type=vCU
    ...    AND                 Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CMP-1
    ...                        param_name=cmpPollingTimeout    param_value=60    hw_type=vCU

Collect and check ATL logs A
    Log                     Last Step: Verify MantaRay logs   console=True
    Sleep    1h             reason=Log will be generated after 1h
    ${req_fields}=          Create List    eventType    eventStatus    userName    additionalText
    ${graylog_log}=         Gather Logs from Graylog    ${NMS_LAB}    range_sec=3600
    ...                     range_from=3600    fields=${req_fields}
    ${atl_log}=             Convert to String    ${graylog_log}
    Create File             /home/ute/graylog_a.txt    ${atl_log}
    ${count_login_fail}=    Set Variable    ${0}
    ${count_cmp_pass}=      Set Variable    ${0}
    ${count_cmp_fail}=      Set Variable    ${0}
    FOR    ${log}    IN    @{graylog_log}
        ${to_be_checked}=       Convert to String    ${log}
        ${status_login}=        Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${login_fail_log}
        ${count_login_fail}=    Run Keyword If    ${status_login}    Evaluate    ${count_login_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_login_fail}
        ${status_cmp}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${cmp_key_log}
        ${status_pass}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_pass_log}
        ${status_fail}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_fail_log}
        ${status_inc}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_inc_log}
        ${count_cmp_fail}=      Run Keyword If    ${status_cmp} and ${status_inc}
        ...                     Evaluate    ${count_cmp_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_cmp_fail}
        ${count_cmp_pass}=      Run Keyword If    ${status_cmp} and ${status_pass}
        ...                     Evaluate    ${count_cmp_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_cmp_pass}
    END
    Run Keyword and Continue on Failure    Should not be Equal    ${count_login_fail}    ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cmp_pass}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cmp_fail}      ${0}

Collect and check ATL logs B
    Log                    Last Step: Verify MantaRay logs   console=True
    Sleep    1h            reason=Log will be generated after 1h
    ${req_fields}=         Create List    eventType    eventStatus    userName    additionalText
    ${graylog_log}=        Gather Logs from Graylog    ${NMS_LAB}    range_sec=3600
    ...                    range_from=3600    fields=${req_fields}
    ${atl_log}=            Convert to String    ${graylog_log}
    Create File            /home/ute/graylog_b.txt    ${atl_log}
    ${count_crl_pass}=     Set Variable    ${0}
    ${count_crl_fail}=     Set Variable    ${0}
    ${count_cert_pass}=    Set Variable    ${0}
    ${count_cert_fail}=    Set Variable    ${0}
    FOR    ${log}    IN    @{graylog_log}
        ${to_be_checked}=       Convert to String    ${log}
        ${status_crl}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${crl_update_log}
        ${status_cert}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${cert_init_log}
        ${status_pass}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_pass_log}
        ${status_fail}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_fail_log}
        ${status_inc}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_inc_log}
        ${count_crl_fail}=      Run Keyword If    ${status_crl} and ${status_fail}
        ...                     Evaluate    ${count_crl_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_crl_fail}
        ${count_crl_pass}=      Run Keyword If    ${status_crl} and ${status_pass}
        ...                     Evaluate    ${count_crl_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_crl_pass}
        ${count_cert_fail}=     Run Keyword If    ${status_cert} and ${status_inc}
        ...                     Evaluate    ${count_cert_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_cert_fail}
        ${count_cert_pass}=     Run Keyword If    ${status_cert} and ${status_pass}
        ...                     Evaluate    ${count_cert_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_cert_pass}
    END
    Run Keyword and Continue on Failure    Should not be Equal    ${count_crl_pass}     ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_crl_fail}     ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cert_pass}    ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cert_fail}    ${0}
