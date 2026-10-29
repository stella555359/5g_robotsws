*** Settings ***
Documentation
...    author:          Patryk Tatarek
...    contact:         patryk.tatarek@nokia.com
...    Test Plan (QC):  /VRF_WRO3_T04/25R3/CB013360/
...    Description:

Resource    ../../../common_resources/admin/admin.robot
Resource    ../../../common_resources/certificates/certificates.robot

*** Variables ***
${wrong_pass}=        NOTnemuuser
${new_admin_pass}=    Nokia@Admin@12345
${local_pass_ab1}=    Nokia@User@AB1@12345
${local_pass_ab2}=    Nokia@User@AB2@12345
${local_pass_ab3}=    Nokia@User@AB3@12345

${7672_cert}=     CN=CB007672
${ipsec_cert}=    C=PL, O=Common, CN=IPSEC

${insta_ip_correct}=      10.42.54.11
${insta_ip_incorrect}=    10.42.54.13
${correct_crldp}=         ${insta_ip_correct}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${incorrect_crldp}=       ${insta_ip_incorrect}:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary
${last_crl_ok}=           CRL_LastUpdateOK
${last_crl_fail}=         CRL_LastUpdateFailed

${for_spliting_logs}=     >1${SPACE}
${login_fail_log}=        Login as ReadWrite, WRONG_USERNAME_OR_PASSWORD
${cert_init_log}=         CMP_INITIALIZE_IND
${crl_update_log}=        CRL_UPDATE_IND
${cmp_key_log}=           CMP_KEY_UPDATE_IND
${status_pass_log}=       'eventStatus': 'SUCCESS'
${status_fail_log}=       'eventStatus': 'FAILURE'
${app_pass_log}=          userRole=appUserAccessMode, Operation Details=Password changed
${sec_pass_log}=          userRole=secUserAccessMode, Operation Details=Password changed
${read_pass_log}=         userRole=readOnlyUserAccessMode, Operation Details=Password changed
${app_act_true_log}=      "appAdmActivated":true
${app_act_false_log}=     "appAdmActivated":false
${sec_act_true_log}=      "secAdmActivated":true
${sec_act_false_log}=     "secAdmActivated":false
${read_act_true_log}=     "readOnlyActivated":true
${read_act_false_log}=    "readOnlyActivated":false
${login_log}=             Login
${logout_log}=            Logout
${nemu_user_log}=         Nemuadmin
${sec_user_log}=          BTSSecurity
${readonly_user_log}=     BTSRead

*** Keywords ***
Additional_sec_event_record_logging_users_and_session
    Log              Step 1: Try to connect to system admin with incorrect credentials    console=True
    Run Keyword and Expect Error    *Cannot establish socket connection*    coam_admin.connect_to    bts_host=${LMP_IP}
    ...                             username=${WEBEM_USERNAME}    password=${wrong_pass}    name=admin    timeout=${5}
    Log              Step 2: Connect to system admin with correct credentials    console=True
    ${conn}=         Connect to ADMIN
    Log              Step 3: Session should remain active for at least 1 minute    console=True
    Sleep            60s    reason=Wait 1 minute to check if session will remain active
    Log              Step 4: Disconnect from system admin connection    console=True
    Disconnect from ADMIN    ${conn}
    Log              Step 5: Setup and connect as read-only user    console=True
    Setup Local user account    account_type=BTSRead    new_password=${local_pass_ab1}
    ${conn_read}=    Connect to ADMIN    username=BTSRead    password=${local_pass_ab1}
    Log              Step 6: Try to verify logs using read-only connection    console=True
    Run Keyword and Expect Error    *Operation rejected due to no access permission*
    ...                             coam_admin.get_account_status_report    connection=${conn_read}
    Log              Step 7: Disconnect from read-only user connection    console=True
    Disconnect from ADMIN    ${conn_read}
    Log              Step 8: Setup and connect as security admin    console=True
    Setup Local user account    account_type=BTSSecurity    new_password=${local_pass_ab1}
    ${conn_sec}=     Connect to ADMIN    username=BTSSecurity    password=${local_pass_ab1}
    Log              Step 9: Verify logs using security admin connection    console=True
    ${report}=       coam_admin.get_account_status_report    connection=${conn_sec}
    ${rep_list}=     Get From Dictionary    ${report}    accountStatusReport
    FOR    ${account}    IN    @{rep_list}
        Run Keyword If      '${account["accountName"]}' == 'BTSRead'
        ...                  Should not be Empty    ${account["lastLoginTime"]}
        Run Keyword If      '${account["accountName"]}' == 'BTSRead'
        ...                  Should not be Empty    ${account["lastLogoutTime"]}
        Exit For Loop If    '${account["accountName"]}' == 'BTSRead'
    END
    Disconnect from ADMIN    ${conn_sec}
    [Teardown]       Run Keywords    Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}
    ...    AND       Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_read}
    ...    AND       Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_sec}

Additional_sec_event_record_local_accounts_operations
    Log               Step 1: Try to connect to system admin with incorrect credentials    console=True
    Run Keyword and Expect Error    *Cannot establish socket connection*    coam_admin.connect_to    bts_host=${LMP_IP}
    ...                             username=${WEBEM_USERNAME}    password=${wrong_pass}    name=admin    timeout=${5}
    Log               Step 2: Connect to system admin with correct credentials    console=True
    ${conn}=          Connect to ADMIN
    Log               Step 3: Perform CMP Key Update as system admin    console=True
    Configure CMP              ca_subject_name=${7672_cert}    connection=${conn}
    Initialize Certificates    connection=${conn}
    Update CMP Key             connection=${conn}
    Log               Step 4: Disconnect from system admin connection    console=True
    Disconnect from ADMIN    ${conn}
    Log               Step 5: Setup and connect as read-only user    console=True
    Setup Local user account    account_type=BTSRead    new_password=${local_pass_ab2}
    ${conn_read}=     Connect to ADMIN    username=BTSRead    password=${local_pass_ab2}
    Log               Step 6: Try to perform CMP Key Update as read-only user    console=True
    Run Keyword and Expect Error    *Operation rejected due to no access permission*
    ...                             Update CMP Key    connection=${conn_read}
    Log               Step 7: Disconnect from read-only user connection    console=True
    Disconnect from ADMIN    ${conn_read}
    Log               Step 8: Setup and connect as security admin    console=True
    Setup Local user account    account_type=BTSSecurity    new_password=${local_pass_ab2}
    ${conn_sec}=      Connect to ADMIN    username=BTSSecurity    password=${local_pass_ab2}
    Log               Step 9: Perform CMP Key Update as security admin    console=True
    Update CMP Key    connection=${conn_sec}
    [Teardown]        Run Keywords    Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn}
    ...    AND        Run Keyword and Ignore Error    Disconnect from ADMIN    ${conn_read}
    ...    AND        Disconnect from ADMIN    ${conn_sec}

Audit_logging_for_local_account_operations_by_MantaRay
    Log                                      Step 2: Setup and activate Security Admin account    console=True
    Setup Local user account                 account_type=BTSSecurity    new_password=${local_pass_ab3}
    Log                                      Step 3: Setup and activate Application Admin account    console=True
    Setup Local user account                 account_type=BTSApplication    new_password=${local_pass_ab3}
    Log                                      Step 4: Setup and activate ReadOnly user account    console=True
    Setup Local user account                 account_type=BTSRead    new_password=${local_pass_ab3}
    Log                                      Step 5: Deactivate Security Admin account    console=True
    ${conn}=                                 Connect to ADMIN
    coam_admin.change_local_account_state    account_type=BtsSecurity    enable=${FALSE}    connection=${conn}
    Log                                      Step 6: Deactivate Application Admin account    console=True
    coam_admin.change_local_account_state    account_type=BtsApplication    enable=${FALSE}    connection=${conn}
    Log                                      Step 7: Deactivate ReadOnly user account    console=True
    coam_admin.change_local_account_state    account_type=BtsRead    enable=${FALSE}    connection=${conn}
    [Teardown]                               Disconnect from ADMIN    ${conn}

Audit_login_during_manual_CRL_download_failure_and_retry
    Log                             Step 0: Remove CRLDPconfig object if exists    console=True
    Run Keyword and Ignore Error    Delete Object From BTS
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    Log                             Step 1: Connect to system admin with correct credentials    console=True
    ${conn}=                        Connect to ADMIN
    Log                             Step 2: Create and configure CRLDPconfig with wrong ip address    console=True
    ${params_dict}=                 Create Dictionary    parameterName=primaryCRLDP
    ...                             operation=update    value=${incorrect_crldp}
    ${params}=                      Create List    ${params_dict}
    Create Object on BTS            dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_list=${params}    connection=${conn}
    Log                             Step 3: Initialize certificate    console=True
    Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    ...                                  distributionPointSource=Configuration_parameter
    ...                                  crlDownloadProtocol=LDAP_OR_HTTP
    ...                                  usageEnabled=Enabled
    ...                                  connection=${conn}
    Configure CMP                   ca_subject_name=${7672_cert}    connection=${conn}
    Initialize Certificates         connection=${conn}
    Log                             Step 4: Check if CRL update fails    console=True
    Run Keyword and Expect Error    *Status reached: Failed*    Update Certificate Revocation List
    ...                             domain=3GPP    connection=${conn}
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active In BTS    fault_id=61074    connection=${conn}
    ${crl_state}=                   Check current parameter value    param_name=state    connection=${conn}
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ${crl_state_str}=               Get From List    ${crl_state}    ${0}
    Should be Equal                 ${crl_state_str}    ${last_crl_fail}
    Log                             Step 5: Configure CRLDPCONFIG-1 with correct secondaryCRLDP    console=True
    Delete Object From BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ${params_dict_prim}=            Create Dictionary    parameterName=primaryCRLDP
    ...                             operation=update     value=${incorrect_crldp}
    ${params_dict_sec}=             Create Dictionary    parameterName=secondaryCRLDP
    ...                             operation=update     value=${correct_crldp}
    ${params}=                      Create List    ${params_dict_prim}    ${params_dict_sec}
    Create Object on BTS            dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-1
    ...                             param_list=${params}    connection=${conn}
    Log                             Step 6-7: Check if CRL update passes    console=True
    Update Certificate Revocation List    domain=3GPP    connection=${conn}
    Wait Until Keyword Succeeds     3min    10s    Alarm Should Not Be Active in BTS
    ...                                            fault_id=61074    connection=${conn}
    ${crl_state}=                   Check current parameter value    param_name=state    connection=${conn}
    ...                             dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ${crl_state_str}=               Get From List    ${crl_state}    ${0}
    Should be Equal                 ${crl_state_str}    ${last_crl_ok}
    [Teardown]    Disconnect from ADMIN    ${conn}

Audit_login_during_certificate_enrollment_or_renewal
    Log                             Step 1: Try to connect to system admin with incorrect credentials    console=True
    Run Keyword and Expect Error    *Cannot establish socket connection*    coam_admin.connect_to    bts_host=${LMP_IP}
    ...                             username=${WEBEM_USERNAME}    password=${wrong_pass}    name=admin    timeout=${5}
    Log                             Step 2: Connect to system admin with correct credentials    console=True
    ${conn}=                        Connect to ADMIN
    Log                             Step 3: Try to initialize certyficate with wrong server address     console=True
    Configure CMP                   ca_subject_name=${7672_cert}    ca_server_host=5.5.5.5    connection=${conn}
    Run Keyword and Expect Error    *CMP server not reachable*    Initialize Certificates    connection=${conn}
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active In BTS    fault_id=61510    connection=${conn}
    Log                             Step 4: Configure secondary CMP with wrong server address     console=True
    Configure Secondary CMP         subject_name=${ipsec_cert}    server_host=6.6.6.6    connection=${conn}
    Log                             Step 5: Try to initialize certyficate with wrong server address     console=True
    Run Keyword and Expect Error    *CMP server not reachable*    Initialize Certificates    connection=${conn}
    Wait Until Keyword Succeeds     3min    10s    Alarm Should be Active In BTS    fault_id=61510    connection=${conn}
    Log                             Step 6: Fill secondary CMP with correct server address     console=True
    Configure Secondary CMP         subject_name=${ipsec_cert}    connection=${conn}
    Log                             Step 7: Initialize certyficate with correctly filled secondary CMP     console=True
    Initialize Certificates         connection=${conn}
    Wait Until Keyword Succeeds     3min    10s    Alarm Should not be Active In BTS
    ...                             fault_id=61510    connection=${conn}
    [Teardown]      Run Keywords    Clear Secondary CMP Configuration    connection=${conn}
    ...    AND                      Configure CMP    ca_subject_name=${7672_cert}    connection=${conn}
    ...    AND                      Disconnect from ADMIN    ${conn}

Collect and check ATL logs A
    Log                         Last Step: Verify MantaRay logs   console=True
    Sleep    1h                 reason=Log will be generated after 1h
    ${req_fields}=              Create List    eventType    eventStatus    userName    additionalText
    ${graylog_log}=             Gather Logs from Graylog    ${integrated_lab}    range_sec=3600
    ...                         range_from=3600    fields=${req_fields}
    ${atl_log}=                 Convert to String    ${graylog_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${app_pass_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${sec_pass_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${read_pass_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${app_act_true_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${app_act_false_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${sec_act_true_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${sec_act_false_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${read_act_true_log}
    Run Keyword and Continue on Failure      Should Contain    ${atl_log}    ${read_act_false_log}
    ${count_login_fail}=        Set Variable    ${0}
    ${count_nemu_in}=           Set Variable    ${0}
    ${count_nemu_out}=          Set Variable    ${0}
    ${count_read_in}=           Set Variable    ${0}
    ${count_read_out}=          Set Variable    ${0}
    ${count_sec_in}=            Set Variable    ${0}
    ${count_sec_out}=           Set Variable    ${0}
    ${count_cmp_pass}=          Set Variable    ${0}
    ${count_cmp_fail}=          Set Variable    ${0}
    FOR    ${log}    IN    @{graylog_log}
        ${to_be_checked}=       Convert to String    ${log}
        ${status_login}=        Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${login_fail_log}
        ${count_login_fail}=    Run Keyword If    ${status_login}    Evaluate    ${count_login_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_login_fail}
        ${status_login}=        Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${login_log}
        ${status_logout}=       Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${logout_log}
        ${status_nemu}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${nemu_user_log}
        ${status_sec}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${sec_user_log}
        ${status_readonly}=     Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${readonly_user_log}
        ${count_nemu_in}=       Run Keyword If    ${status_nemu} and ${status_login}
        ...                     Evaluate    ${count_nemu_in} + ${1}
        ...                     ELSE    Set Variable    ${count_nemu_in}
        ${count_nemu_out}=      Run Keyword If    ${status_nemu} and ${status_logout}
        ...                     Evaluate    ${count_nemu_out} + ${1}
        ...                     ELSE    Set Variable    ${count_nemu_out}
        ${count_read_in}=       Run Keyword If    ${status_readonly} and ${status_login}
        ...                     Evaluate    ${count_read_in} + ${1}
        ...                     ELSE    Set Variable    ${count_read_in}
        ${count_read_out}=      Run Keyword If    ${status_readonly} and ${status_logout}
        ...                     Evaluate    ${count_read_out} + ${1}
        ...                     ELSE    Set Variable    ${count_read_out}
        ${count_sec_in}=        Run Keyword If    ${status_sec} and ${status_login}
        ...                     Evaluate    ${count_sec_in} + ${1}
        ...                     ELSE    Set Variable    ${count_sec_in}
        ${count_sec_out}=       Run Keyword If    ${status_sec} and ${status_logout}
        ...                     Evaluate    ${count_sec_out} + ${1}
        ...                     ELSE    Set Variable    ${count_sec_out}
        ${status_cmp}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${cmp_key_log}
        ${status_pass}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_pass_log}
        ${status_fail}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_fail_log}
        ${count_cmp_fail}=      Run Keyword If    ${status_cmp} and ${status_fail}
        ...                     Evaluate    ${count_cmp_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_cmp_fail}
        ${count_cmp_pass}=      Run Keyword If    ${status_cmp} and ${status_pass}
        ...                     Evaluate    ${count_cmp_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_cmp_pass}
    END
    Run Keyword and Continue on Failure    Should not be Equal    ${count_login_fail}    ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_nemu_in}       ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_nemu_out}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_read_in}       ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_read_out}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_sec_in}        ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_sec_out}       ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cmp_pass}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cmp_fail}      ${0}

Collect and check ATL logs B
    Log                         Last Step: Verify MantaRay logs   console=True
    Sleep    1h                 reason=Log will be generated after 1h
    ${req_fields}=              Create List    eventType    eventStatus    userName    additionalText
    ${graylog_log}=             Gather Logs from Graylog    ${integrated_lab}    range_sec=3600
    ...                         range_from=3600    fields=${req_fields}
    ${count_crl_pass}=          Set Variable    ${0}
    ${count_crl_fail}=          Set Variable    ${0}
    ${count_login_fail}=        Set Variable    ${0}
    ${count_cert_pass}=         Set Variable    ${0}
    ${count_cert_fail}=         Set Variable    ${0}
    FOR    ${log}    IN    @{graylog_log}
        ${to_be_checked}=       Convert to String    ${log}
        ${status_crl}=          Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${crl_update_log}
        ${status_pass}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_pass_log}
        ${status_fail}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${status_fail_log}
        ${count_crl_fail}=      Run Keyword If    ${status_crl} and ${status_fail}
        ...                     Evaluate    ${count_crl_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_crl_fail}
        ${count_crl_pass}=      Run Keyword If    ${status_crl} and ${status_pass}
        ...                     Evaluate    ${count_crl_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_crl_pass}
        ${status_login}=        Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${login_fail_log}
        ${count_login_fail}=    Run Keyword If    ${status_login}    Evaluate    ${count_login_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_login_fail}
        ${status_cert}=         Run Keyword and Return Status    Should Contain    ${to_be_checked}    ${cert_init_log}
        ${count_cert_fail}=     Run Keyword If    ${status_cert} and ${status_fail}
        ...                     Evaluate    ${count_cert_fail} + ${1}
        ...                     ELSE    Set Variable    ${count_cert_fail}
        ${count_cert_pass}=     Run Keyword If    ${status_cert} and ${status_pass}
        ...                     Evaluate    ${count_cert_pass} + ${1}
        ...                     ELSE    Set Variable    ${count_cert_pass}
    END
    Run Keyword and Continue on Failure    Should not be Equal    ${count_crl_pass}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_crl_fail}      ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_login_fail}    ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cert_pass}     ${0}
    Run Keyword and Continue on Failure    Should not be Equal    ${count_cert_fail}     ${0}
