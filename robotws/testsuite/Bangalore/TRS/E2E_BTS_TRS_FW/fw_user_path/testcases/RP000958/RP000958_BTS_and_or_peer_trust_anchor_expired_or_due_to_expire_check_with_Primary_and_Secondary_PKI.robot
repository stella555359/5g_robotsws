*** Settings ***
Documentation     [Procedure] "RP000958_CMP IR trigger to primary when Secondary reconfiguration is removed"
...               [Date] "Date of creation 25:09:18"
...               [Author] "Madhu Chinthakindi"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] "RP000833"
...               [Funtion_Hash_Tags] "HAND OVER"
...               [Validation_status] “Validated and Passed|Not Validated”
...               [Validated_TestLine] “3298 and 3248”
...               [Validation Date] “13-09-18”
...               [Config]      "SCF should contain CMP MO with primary and secondary CMP server configurations
...               and this testcase deals with polling certificates"

variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../resources/common_keywords.robot


Suite Setup		Run Keywords	Suite Setup Preconditions
...		AND		Setup Oamops
Suite Teardown     Run Keywords		Suite Teardown Postconditions
...		AND		Teardown Oamops

Library           Collections
Library           ${CURDIR}/../resources/cmp.py
Library           ute_fsmaccess

*** Test Cases ***
[1]RP000958_Automatic BTS Operator or Certificate retrieval unsuccessful Alarm check with Primary and Secondary PKI
    Precondition
    Verify BTS trust anchor alaram on primary cmp server
    Verify BTS trust anchor alaram on secondary cmp server
    Verify polling certs with IPv6 CMP
    Verify BTS trust anchor alaram on primary cmp server ipv6

*** Keywords ***
Precondition
	Perform Commissioning   scf_file=${Full_Configuration}       timeout=900		verify_bts_status=False  	timeout=900
    BuiltIn.Sleep   300
    Get Mplae Ip
    Read IP Parameters
    Restore Vendor Certs

Restore Vendor Certs
    Run Keyword And Ignore Error    certificate configure    operation=restore_vendor_certificate

Get Mplae Ip
    ${mplane} =    Get Parameter    param_path=${Mplane_ip_path}
    Set Suite Variable    ${mplane}    ${mplane}

Read IP Parameters
    ${cmp_ip_dict} =    Query Admin Infomodel    query=get object ${cmp_ip_path}
    ${primary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=${Primary_cmp_key}
    ${secondary_cmp_ip}=    Get From Dictionary    dictionary=${cmp_ip_dict}    key=${Secondary_cmp_key}
    Set Suite Variable    ${primary_cmp_ip}    ${primary_cmp_ip}
    Set Suite Variable    ${secondary_cmp_ip}    ${secondary_cmp_ip}

Trigger IR with accept_cert
    Run Keyword And Ignore Error        certificate configure    operation=install_cmp_certificate    timeout=100
    Wait Until Keyword Succeeds    5 min    30    verify cmp status    CMP_InitializationWaiting
    Sleep   33
    accept certificate    ${cloud_ip1}
    Wait Until Keyword Succeeds    4 min    30    verify cmp status    CMP_InitializationOK

Configure primary and secondary Ip
    [Arguments]    ${primary_ip}    ${secondary_ip}
    Perform Recommissioning    type=param    param_path=${cmp_primary_ip_path}    value=${primary_ip}    timeout=300    operation=update
    Perform Recommissioning    type=param    param_path=${cmp_secondary_ip_path}    value=${secondary_ip}    timeout=300    operation=update
    ${cmp_state} =    Query Admin Infomodel    query=get object ${cmp_r_moc_path}

####Restore vendor certificate keyword issue
    Run Keyword If    '${cmp_state['state']}'=='CMP_KeyUpdateFailed' or '${cmp_state['state']}'=='CMP_InitializationFailed'
    ...     certificate configure    operation=restore_vendor_certificate
    Run Keyword If    '${cmp_state['state']}'=='CMP_KeyUpdateRequested' or
    ...     '${cmp_state['state']}'=='CMP_KeyUpdateOngoing' or '${cmp_state['state']}'=='CMP_UpdateWaiting'
    ...     Run Keywords     BuiltIn.Sleep   80
    ...    AND    Wait Until Keyword Succeeds    4 min    30    verify cmp status    CMP_KeyUpdateOK
    Run Keyword If    '${cmp_state['state']}'=='CMP_InitializationRequested' or
    ...     '${cmp_state['state']}'=='CMP_InitializationOngoing' or '${cmp_state['state']}'=='CMP_InitializationWaiting'
    ...     Run Keywords     BuiltIn.Sleep   80
    ...     AND    Wait Until Keyword Succeeds    4 min    30    verify cmp status    CMP_InitializationOK

Verify BTS trust anchor alaram on primary cmp server
    Configure primary and secondary Ip    ${cmp_ip1}    ${cmp_ip2}
    Read IP Parameters
    Trigger IR with accept_cert
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=4999   timeout=300    operation=update
	Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}     occurrences=2
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=40    timeout=300    operation=update
    Sleep   300
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}     occurrences=1

Verify BTS trust anchor alaram on primary cmp server ipv6
    Configure primary and secondary Ip    ${cmp_ip1_v6}    ${cmp_ip2}
    Read IP Parameters
    Trigger IR with accept_cert
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=4999    timeout=300    operation=update
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}     occurrences=2
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=40    timeout=300    operation=update
    Sleep   300
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}     occurrences=1

Verify BTS trust anchor alaram on secondary cmp server
    Configure primary and secondary Ip    ${cmp_ip2}    ${cmp_ip1}
    Read IP Parameters
    Trigger IR with accept_cert
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=4999    timeout=300   operation=update
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}     occurrences=2
    Perform Recommissioning    type=param    param_path=${caCertificateUpdateTime_moc_path}    value=40    timeout=300    operation=update
    Wait Until Keyword Succeeds    4 min    30    Verify Alarm    faultid=61618    should_exist=${True}    occurrences=1

verify cmp status
    [Arguments]    ${CMP_status_check}
    ${cmp_state_var} =    Query Admin Infomodel    query=get object ${cmp_r_moc_path}
    Should be equal    ${cmp_state_var['state']}    ${CMP_status_check}

Verify polling certs with IPv6 CMP
    Perform Commissioning   scf_file=${Full_Configuration_ipv6}       timeout=900        verify_bts_status=False     timeout=900
    BuiltIn.Sleep   300
    Get Mplae Ipv6
    Read IP Parameters
    Restore Vendor Certs

Get Mplae Ipv6
    ${mplane} =    Get Parameter    param_path=${Mplane_ip_path_v6}
    Set Suite Variable    ${mplane}    ${mplane}