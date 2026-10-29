*** Settings ***
Documentation   The feature introduces security improvements and new hardening measures

...             Test Case scenario author:     Marta Gał, Michalina Kalenik
...             Test Case scenario contact:    marta.gal@nokia.com, michalina.kalenik@nokia.com

...             Test Case automation author:   Mykhailo Yevchuk
...             Test Case automation contact:  mykhailo.yevchuk@nokia.com

Resource            ../Resources/Keywords.robot
Resource            ../../CB007672-A/Resources/Keywords.robot
Resource            ../../../common_resources/counters/counters_keywords.robot
Library             ../../CB007672-A/Resources/resources.py    WITH NAME    main_resource
Library             Telnet
Library             taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Variables           ../Resources/resources.py

*** Variables ***

${CRL_alarm_new}=     CRL Update failure
${CRL_alarm_old}=      CRL Update Failure
@{BRANCHES_WITH_OLD_ALARM}       SBTS24R1     SBTS23R4     SBTS23R3

*** Keywords ***
CB008259-B_Successfully_manually_trigger_CRL_download_from_WebEM_to_BTS
    ${connection}=  Connect to Admin
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    ${alarms}=    Convert To String   ${BTS_allarms}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_ALARM}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${CRL_alarm}      ${CRL_alarm_old}
    ...         ELSE    Set Global Variable    ${CRL_alarm}     ${CRL_alarm_new}
    Should Not Contain      ${alarms}     ${CRL_alarm}
    ${caSubjectName_value}=  Create caSubjectName Parameter Raw String  CN\\=8259_auto
    Change Parameter in CMP Object  caSubjectName  ${caSubjectName_value}  ${connection}
    Change Parameter in CMP Object  cmpPollingTimeout  3600  ${connection}
    Change Parameter in CMP Object  serverHost  10.42.54.13  ${connection}
    Change Parameter in CMP Object  serverPath  pkix  ${connection}
    Change Parameter in CMP Object  serverPort  8080  ${connection}
    ${serverType_value}=  Check Current Parameter Value  serverType  dist_name=${CMP_OBJECT_PATH}  connection=${connection}
    Run Keyword If  ${serverType_value} != ['RSA']  Change Parameter in CMP Object  serverType  RSA  ${connection}
    Run Keyword and Ignore Error    Delete CRLDPCONFIG Object  ${connection}
    Create CRLDPCONFIG Object  ${connection}
    Change Parameter in CRLH Object  crlDownloadProtocol  LDAP_OR_HTTP  ${connection}
    Change Parameter in CRLH Object  distributionPointSource  Configuration_parameter  ${connection}
    coam_admin.Restore Vendor Certificate    connection=${connection}
    Initialize Certificates
    Update Certificate Revocation List  domain_type=3GPP  connection=${connection}  timeout=600
    ${CRL_all_states}=  Check Current Parameter Value  dist_name=${CRLH_R-1_OBJECT_PATH}  param_name=state
    ${CRL_last_state}=  Set Variable  '${CRL_all_states}[-1]'
    Log  Certificate Last State: ${CRL_last_state}  console=True
    ${CRL_info}=   coam_admin.Get Certificate Revocation List  domain_type=3GPP   timeout=900  connection=${connection}
    ${Certificate_failure_reason}=  Get Failure Reason Of Certificate  ${CRL_info}
    Should Be Equal  ${CRL_last_state}  'CRL_LastUpdateOK'
    Should Be Equal  '${Certificate_failure_reason}'  '[]'
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    Log  ${BTS_allarms}
    ${alarms}=    Convert To String   ${BTS_allarms}
    Should Not Contain      ${alarms}     ${CRL_alarm}
#   Delete created iside TC object
    Delete CRLDPCONFIG Object  ${connection}
    [Teardown]  Disconnect From Admin  ${connection}

CB008259-B_Unsuccessfully_manually_trigger_CRL_download_from_WebEM_to_BTS
    ${connection}=  Connect to Admin
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    ${alarms}=    Convert To String   ${BTS_allarms}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_ALARM}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${CRL_alarm}      ${CRL_alarm_old}
    ...         ELSE    Set Global Variable    ${CRL_alarm}     ${CRL_alarm_new}
    Should Not Contain      ${alarms}     ${CRL_alarm}
    ${caSubjectName_value}=  Create caSubjectName Parameter Raw String  CN\\=8259_auto_invalid
    Change Parameter in CMP Object  caSubjectName  ${caSubjectName_value}  ${connection}
    Change Parameter in CMP Object  cmpPollingTimeout  3600  ${connection}
    Change Parameter in CMP Object  serverHost  10.42.54.13  ${connection}
    Change Parameter in CMP Object  serverPath  pkix  ${connection}
    Change Parameter in CMP Object  serverPort  8080  ${connection}
    ${serverType_value}=  Check Current Parameter Value  serverType  dist_name=${CMP_OBJECT_PATH}  connection=${connection}
    Run Keyword If  ${serverType_value} != ['RSA']  Change Parameter in CMP Object  serverType  RSA  ${connection}
    Run Keyword and Ignore Error    Delete CRLDPCONFIG Object  ${connection}
    Create CRLDPCONFIG Object  ${connection}
    Change Parameter in CRLH Object  crlDownloadProtocol  LDAP_OR_HTTP  ${connection}
    Change Parameter in CRLH Object  distributionPointSource  Configuration_parameter  ${connection}
    coam_admin.Restore Vendor Certificate    connection=${connection}
    ${initialize_certificates_status}=  Run Keyword And Expect Error  *  Initialize Certificates
    ${init_cert_error_code}=  Get Restore Vendor Certificate Error Code  ${initialize_certificates_status}
    Should Be Equal  ${CERT_ERROR_MSG}  ${init_cert_error_code}
    ${update_certificates_status}=  Run Keyword And Expect Error  *  Update Certificate Revocation List
                                                                  ...  domain_type=3GPP
                                                                  ...  connection=${connection}
                                                                  ...  timeout=600
    ${update_cert_error_code}=  Get Restore Vendor Certificate Error Code  ${update_certificates_status}
    Should Be Equal  ${CERT_ERROR_MSG}  ${update_cert_error_code}
    ${CRL_all_states}=  Check Current Parameter Value  dist_name=${CRLH_R-1_OBJECT_PATH}  param_name=state
    ${CRL_last_state}=  Set Variable  '${CRL_all_states}[-1]'
    Log  Certificate Last State: ${CRL_last_state}  console=True
    ${CRL_info}=   coam_admin.Get Certificate Revocation List  domain_type=3GPP   timeout=900  connection=${connection}
    ${Certificate_failure_reason}=  Get Failure Reason Of Certificate  ${CRL_info}
    Should Be Equal  ${CRL_last_state}  'CRL_LastUpdateFailed'
    Should Be Equal  '${Certificate_failure_reason}'  '['CaSignatureCheckFailed']'
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    log  ${BTS_allarms}
    ${alarms}=    Convert To String   ${BTS_allarms}
    Should Contain      ${alarms}     ${CRL_alarm}
#     restore valid Cert name and delete created iside TC object
    ${caSubjectName_value}=  Create caSubjectName Parameter Raw String  CN\\=8259_auto
    Change Parameter in CMP Object  caSubjectName  ${caSubjectName_value}  ${connection}
    Delete CRLDPCONFIG Object  ${connection}
    Sleep  120  reason=Wait until Alarm disappear
    Log  Waiting until BTS Alarm appear  console=True
    [Teardown]  Disconnect From Admin  ${connection}

CB008259-B_Automatically_trigger_CRL_download_from_WebEM_to_BTS
    ${connection}=  Connect to Admin
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    ${alarms}=    Convert To String   ${BTS_allarms}
    ${INSTALLED_SW_BRANCH}=   admin.Get Software Release Name
    Run Keyword If    "${INSTALLED_SW_BRANCH}" in ${BRANCHES_WITH_OLD_ALARM}    Set Global Variable   ${status}    0
    ...         ELSE    Set Global Variable   ${status}    1
    Run Keyword If    '${status}'=='0'    Set Global Variable   ${CRL_alarm}      ${CRL_alarm_old}
    ...         ELSE    Set Global Variable    ${CRL_alarm}     ${CRL_alarm_new}
    Should Not Contain      ${alarms}     ${CRL_alarm}
    ${caSubjectName_value}=  Create caSubjectName Parameter Raw String  CN\\=8259_auto_invalid
    Change Parameter in CMP Object  caSubjectName  ${caSubjectName_value}  ${connection}
    Change Parameter in CMP Object  cmpPollingTimeout  3600  ${connection}
    Change Parameter in CMP Object  serverHost  10.42.54.13  ${connection}
    Change Parameter in CMP Object  serverPath  pkix  ${connection}
    Change Parameter in CMP Object  serverPort  8080  ${connection}
    ${serverType_value}=  Check Current Parameter Value  serverType  dist_name=${CMP_OBJECT_PATH}  connection=${connection}
    Run Keyword If  ${serverType_value} != ['RSA']  Change Parameter in CMP Object  serverType  RSA  ${connection}
    Run Keyword and Ignore Error    Delete CRLDPCONFIG Object  ${connection}
    Create CRLDPCONFIG Object  ${connection}
    Change Parameter in CRLH Object  crlDownloadProtocol  LDAP_OR_HTTP  ${connection}
    Change Parameter in CRLH Object  distributionPointSource  Configuration_parameter  ${connection}
    coam_admin.Restore Vendor Certificate    connection=${connection}

    Sleep  300  reason=Wait until Alarm disappear
    Log  Waiting until BTS Alarm appear  console=True
    ${BTS_allarms}=  coam_admin.Get Active Alarms  connection=${connection}
    ${alarms}=    Convert To String   ${BTS_allarms}
    Should Contain      ${alarms}     ${CRL_alarm}

    ${CRL_all_states}=  Check Current Parameter Value  dist_name=${CRLH_R-1_OBJECT_PATH}  param_name=state
    ${CRL_last_state}=  Set Variable  '${CRL_all_states}[-1]'
    Log  Certificate Last State: ${CRL_last_state}  console=True
    ${CRL_info}=   coam_admin.Get Certificate Revocation List  domain_type=3GPP   timeout=900  connection=${connection}
    ${Certificate_failure_reason}=  Get Failure Reason Of Certificate  ${CRL_info}
    Should Be Equal  ${CRL_last_state}  'CRL_LastUpdateFailed'
    Should Be Equal  '${Certificate_failure_reason}'  '['CaSignatureCheckFailed']'
    # restore valid Cert name and delete created iside TC object
    ${caSubjectName_value}=  Create caSubjectName Parameter Raw String  CN\\=8259_auto
    Change Parameter in CMP Object  caSubjectName  ${caSubjectName_value}  ${connection}
    Delete CRLDPCONFIG Object  ${connection}
    [Teardown]  Disconnect From Admin  ${connection}

CB008259-A_Rate_limit_for_ARP_packets-ipRmDropPcktsRtLimARP
    [Arguments]  ${Test_PC_connection_to_activate}  ${Test_PC_interface}
    counters_keywords.Change Rejected Packets Interval To 5min
    counters_keywords.Change Reporting Interval To 5min
    Run Keyword And Ignore Error  Check If There Are Any Transport Counter Issues And Reboot BTS If Neened  M51328C17
    Wait Until Transport Counters Available After Reboot  M51328C17
    Actualize NetAct Counters
    log  waiting for new interval start to test counter's burst value  console=yes
    Wait For New Interval Start  M51328C17
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C17
    ${counter_WebEm_value_before}=  Get Counter Value From WebEm  M51328C17
    ${counter_NetAct_value_before}=  Get Counter Value From NetAct  M51328C17
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    log  NetAct and WebEm counters time is correct  console=yes
    Remove NetAct Counters Raport
    log  counter value from WebEm before test is ${counter_WebEm_value_before}  console=yes
    log  counter value from NetAct before test is ${counter_NetAct_value_before}  console=yes
    Activate connection on Test PC  ${Test_PC_connection_to_activate}
    ${mac_address_for_m_place}=  Get MAC address for IPv4 address  ${M_PLANE_IP}
    Start Tcpdump For M51328C17 Counter
    ${scapy_status}=  Send Packets For M51328C17 Counter To BTS  ${mac_address_for_m_place}  7500  7500  ${Test_PC_interface}
    Kill Tcpdump For M51328C17 Counter
    ${number_of_packets}=  Get Number Of Packets After Packets Flood For M51328C17
    Should Be True  ${number_of_packets} > 3750
    Should Be True  ${number_of_packets} < 11250
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C17
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C17
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C17
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C17
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} == 0)
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} == 0)
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully sent and counter's burst works properly  console=yes
    log  waiting for new interval start to test counter's packets per second value  console=yes
    Wait For New Interval Start  M51328C17
    Start Tcpdump For M51328C17 Counter
    ${scapy_status}=  Send Packets For M51328C17 Counter To BTS  ${mac_address_for_m_place}  ${M51328C17_PPS}
    ...   ${M51328C17_PACKETS}  ${Test_PC_interface}
    Kill Tcpdump For M51328C17 Counter
    ${number_of_packets}=  Get Number Of Packets After Packets Flood For M51328C17
    Should Be True  ${number_of_packets} > (${M51328C17_PACKETS} * ${M51328C17_TCPDUMP_STATISTICAL_ERROR_LESS})
    Should Be True  ${number_of_packets} < (${M51328C17_PACKETS} * ${M51328C17_TCPDUMP_STATISTICAL_ERROR_MORE})
    log  packets were successfully collected on BTS with tcpdump  console=yes
    Wait For New Interval Start  M51328C17
    ${WebEm_counter_time}=  Get Counter Time From WebEm  M51328C17
    ${counter_WebEm_value_after}=  Get Counter Value From WebEm  M51328C17
    ${counter_NetAct_value_after}=  Get Counter Value From NetAct  M51328C17
    Compare NetAct And WebEm Counter Time  ${WebEm_counter_time}
    Remove NetAct Counters Raport
    log  counter value from WebEm after test is ${counter_WebEm_value_after}  console=yes
    log  counter value from NetAct after test is ${counter_NetAct_value_after}  console=yes
    ${equation_WebEm}=  Catenate  (${counter_WebEm_value_after} - ${counter_WebEm_value_before} > ${M51328C17_SHOULD_BE_COLLECTED} -
    ...  ${M51328C17_TEST_STATISTICAL_ERROR}) and (${counter_WebEm_value_after} - ${counter_WebEm_value_before} <
    ...  ${M51328C17_SHOULD_BE_COLLECTED} + ${M51328C17_TEST_STATISTICAL_ERROR})
    ${equation_NetAct}=  Catenate  (${counter_NetAct_value_after} - ${counter_NetAct_value_before} > ${M51328C17_SHOULD_BE_COLLECTED} -
    ...  ${M51328C17_TEST_STATISTICAL_ERROR}) and (${counter_NetAct_value_after} - ${counter_NetAct_value_before} <
    ...  ${M51328C17_SHOULD_BE_COLLECTED} + ${M51328C17_TEST_STATISTICAL_ERROR})
    Should Be True  ${counter_WebEm_value_after} == ${counter_NetAct_value_after}
    Should Be True  ${equation_WebEm}
    Should Be True  ${equation_NetAct}
    log  packets were successfully collected in M51328C17 transport counter  console=yes

CB008259-E_Improvement_AaShell_input_commands
    ${release_name}=  Get Software Release Name
    ${sbts23r4_release}=  Set Variable If  '${release_name}' == 'SBTS23R4'  True
    ${ssh_session}=  Create SSH Session With System Module  ${LMP_IP}  ${OAM_USERNAME}  ${OAM_PASSWORD}
    Create Telnet AaShell Session Inside SSH Tunnel  ${ssh_session}
    Compare AaShell Commands  ${ssh_session}  ${sbts23r4_release}
    [Teardown]  Run Keywords  Kill Telnet AaShell Session Inside SSH Tunnel  ${ssh_session}  AND
    ...                       Kill SSH Session With System Module  ${ssh_session}
