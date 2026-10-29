*** Settings ***
Documentation
...     description:    Keywords for test cases for the CB007672-I feature. This split is related to flexible
...                     IP addressing for PKI (gNB can deploy IPsec for the management plane (M-plane) without applying
...                     IPsec to PKI/certificate management traffic, it is possible to configure a dedicated IP address
...                     for certificate management operations in gNB which can be different from the M-plane address).

Library        taf.sbts.oam.coam.admin    WITH NAME    coam_admin
Library        taf.config.scf             WITH NAME    scf

Resource       ../../../common_resources/admin/admin.robot
Resource       ../../../common_resources/alarms/alarm.robot
Resource       ../../../common_resources/certificates/certificates.robot


*** Keywords ***
Deploy flexible address for PKI
    [Arguments]     ${ipversion}
    ${cmp_DN}=      Get x2Cplane ipAddressDN  p_name=ipV${ipversion}AddressDN1
    ${connection}=  Connect to ADMIN
    Change cmpCrlSrcAddressDN Value           cmp_IP_address=${cmp_DN}
    ...                                       ipversion=${ipversion}
    ...                                       operation=update
    ...                                       connection=${connection}
    [Teardown]      Disconnect from ADMIN     ${connection}

Undeploy flexible address for PKI
    [Arguments]     ${ipversion}
    ${connection}=  Connect to ADMIN
    Change cmpCrlSrcAddressDN Value           cmp_IP_address=${EMPTY}
    ...                                       ipversion=${ipversion}
    ...                                       operation=delete
    ...                                       connection=${connection}
    [Teardown]      Disconnect from ADMIN     ${connection}

Deploy invalid flexible address for PKI
    [Arguments]     ${ipversion}
    ${cmp_invalid_DN}=   Perform recommissioing for IPADDRESS object with invalid IP address    operation=create
    ...                                                                                         ipversion=${ipversion}
    ${connection}=  Connect to ADMIN
    Change cmpCrlSrcAddressDN Value           cmp_IP_address=${cmp_invalid_DN}
    ...                                       ipversion=${ipversion}
    ...                                       operation=update
    ...                                       connection=${connection}
    [Teardown]      Disconnect from ADMIN     ${connection}

Change cmpCrlSrcAddressDN Value
    [Arguments]     ${cmp_IP_address}    ${ipversion}    ${operation}    ${connection}
    &{param_dict}=  Create Dictionary         parameterName=cmpCrlSrcIpv${ipversion}AddressDN  value=${cmp_IP_address}
    ...                                       operation=${operation}
    ${param_list}=  Create List               ${param_dict}
    Log             Changing cmpCrlSrcIpv${ipversion}AddressDN value. &{param_dict}    console=True
    coam_admin.Perform Object Recommissioning      dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CERTHENT-1
    ...                                       parameter=@{param_list}
    ...                                       operation=update
    ...                                       connection=${connection}

Change mPlaneDscp Value
    [Arguments]     ${mPlaneDscp}
    ${connection}=  Connect to ADMIN
    &{param_dict}=  Create Dictionary         parameterName=mPlaneDscp  value=${mPlaneDscp}   operation=update
    ${param_list}=  Create List               ${param_dict}
    Log             Changing mPlaneDscp value to ${mPlaneDscp}    console=True
    coam_admin.Perform Object Recommissioning      dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/MPLANENW-1
    ...                                       parameter=@{param_list}
    ...                                       operation=update
    ...                                       connection=${connection}
    [Teardown]      Disconnect from ADMIN     ${connection}

Initialize Certificate
    [Arguments]    ${timeout}=120s    ${detailed_output}=True
    ${admin_connection}=    Connect To Admin
    coam_admin.CMP Initialize Certificate    timeout=${timeout}    connection=${admin_connection}    detailed_output=${detailed_output}
    Log    Certificate initialized.    console=${TRUE}
    [Teardown]    Run Keyword And Ignore Error     Disconnect From Admin    ${admin_connection}

Initialize Certificate And Expect Error
    ${status}=    Run Keyword And Expect Error    *    Initialize Certificate    timeout=30s
    Log     ${status}
    Should Match Regexp    ${status}    AdminApiProcedure.*Exception

Trigger Action Towards CMP/CRL Server And Verify Result
    [Documentation]   There is CMP Certificate Initialization as an connetion verification towards CMP/CRL server
    ...    Whenever BTS certificate SN (serialNumber) is chagning after CMP Certificate Initialization
    ...    it is proof that connection is correct.
    [Arguments]    ${cmp_action_expected_result}
    ${BTS_cert_SN_before_cert_init}=    Get BTS certificate Serial Number
    Run Keyword If    '${cmp_action_expected_result}'=='Succeed'    Initialize Certificate
    Run Keyword If    '${cmp_action_expected_result}'=='Fail'       Initialize Certificate And Expect Error
    ${BTS_cert_SN_after_cert_init}=    Get BTS certificate Serial Number
    Run Keyword If    '${cmp_action_expected_result}'=='Succeed'
    ...  Check If BTS Certificate SN Is Changed  ${BTS_cert_SN_before_cert_init}  ${BTS_cert_SN_after_cert_init}
    Run Keyword If    '${cmp_action_expected_result}'=='Fail'
    ...  Check If BTS Certificate SN Did Not Change  ${BTS_cert_SN_before_cert_init}  ${BTS_cert_SN_after_cert_init}

Check If BTS Certificate SN Is Changed
    [Arguments]    ${cert_SN_1}    ${cert_SN_2}
    Log    Comparing cert_SN_1=${cert_SN_1} and cert_SN_2=${cert_SN_2}
    Should Not Be Equal As Strings    ${cert_SN_1}     ${cert_SN_2}

Check If BTS Certificate SN Did Not Change
    [Arguments]    ${cert_SN_1}    ${cert_SN_2}
    Log    Comparing cert_SN_1=${cert_SN_1} and cert_SN_2=${cert_SN_2}
    Should Be Equal As Strings    ${cert_SN_1}     ${cert_SN_2}

Get BTS certificate Serial Number
    ${admin_connection}=    Connect To Admin
    ${type}    Set Variable    BTS
    ${cert_list}=    coam_admin.Get certificate list    cert_type=${type}    timeout=10s    connection=${admin_connection}
    FOR    ${element}    IN    @{cert_list}
        ${cert_type}    Get From Dictionary   ${element}    type
        ${keypooltype}     Get From Dictionary     ${element}     keyPoolType
        ${BTS_cert_SN}=  Run Keyword If  '${cert_type}'=='EndEntity'  Get From Dictionary  ${element}  serialNumber
        Run Keyword If    '${cert_type}'=='EndEntity'       Exit For Loop IF    '${keypooltype}'=='RSA'
    END
    [Return]    ${BTS_cert_SN}
    [Teardown]    Disconnect From Admin    ${admin_connection}

Check if gNB communicates with CMP/CRL server via defined dedicated CMP IP address
    [Arguments]    ${pcap_file}    ${ipversion}    ${ip_src}    ${ip_dst}
    ${output}=  Run Keyword If  ${ipversion}==6  Run  tshark -r ${pcap_file} -Y 'ipv6.src==${ip_src} && ipv6.dst==${ip_dst}'
    ...                                    ELSE  Run  tshark -r ${pcap_file} -Y 'ip.src==${ip_src} && ip.dst==${ip_dst}'
    Should Contain    ${output}    [ACK]

Check if gNB not communicates with CMP/CRL server via defined CMP IP address
    [Arguments]    ${pcap_file}    ${ipversion}    ${ip_src}    ${ip_dst}
    ${output}=  Run Keyword If  ${ipversion}==6  Run  tshark -r ${pcap_file} -Y 'ipv6.src==${ip_src} && ipv6.dst==${ip_dst}'
    ...                                    ELSE  Run  tshark -r ${pcap_file} -Y 'ip.src==${ip_src} && ip.dst==${ip_dst}'
    Should Not Contain    ${output}    [ACK]

Check if gNB communicates with CMP/CRL server via mplane address
    [Arguments]    ${pcap_file}    ${ipversion}    ${ip_src}    ${ip_dst}
    ${output}=  Run Keyword If  ${ipversion}==6  Run  tshark -r ${pcap_file} -Y 'ipv6.src==${ip_src} && ipv6.dst==${ip_dst}'
    ...                                    ELSE  Run  tshark -r ${pcap_file} -Y 'ip.src==${ip_src} && ip.dst==${ip_dst}'
    Should Contain    ${output}    [ACK]

Check If TOS Has Expected Expected Value
    [Arguments]    ${pcap_file}    ${ipversion}    ${ip_src}    ${ip_dst}    ${tos}
    ${output}=  Run Keyword If  ${ipversion}==6  Run  tshark -r ${pcap_file} -Y 'ipv6.src==${ip_src} && ipv6.dst==${ip_dst} && ipv6.tclass==${tos}'
    ...                                    ELSE  Run  tshark -r ${pcap_file} -Y 'ip.src==${ip_src} && ip.dst==${ip_dst} && ip.dsfield==${tos}'
    Should Not Be Empty   ${output}

Get x2Cplane ipAddressDN
    [Documentation]     Exemplary fragment of SCFa:
    ...                    <list name="x2Cplane">
    ...                     <item>
    ...                        <p name="ipV4AddressDN1">MRBTS-50281/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV4-1</p>
    ...                        <p name="ipV6AddressDN1">MRBTS-50281/TNLSVC-1/TNL-1/IPNO-1/IPIF-3/IPADDRESSV6-1</p>
    ...                      </item>
    ...                    </list>
    ...
    ...                   - p_name (String) for x2Cplane - ipV4AddressDN1 | ipV6AddressDN1
    [Arguments]    ${p_name}
    ${scf_filepath}=    Download SCF
    scf.Load Scf    file_path=${scf_filepath}
    ${x2Cplane_address_DN}    scf.Get value from scf
    ...                       dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...                       p_name=${p_name}
    ...                       list_name=x2Cplane
    [Return]    ${x2Cplane_address_DN}

Perform recommissioing for IPADDRESS object with invalid IP address
    [Arguments]    ${operation}    ${ipversion}
    ${localIpAddr}         Set Variable If    ${ipversion}==4    10.10.10.10    2a00:8a00:6000:0000::1:ae0d
    ${localIpPrefixLen}    Set Variable If    ${ipversion}==4    26             120
    ${operation}=    Convert To Lower Case    ${operation}
    ${admin_connection}=    Connect To Admin
    &{param_dict_0}=  Create Dictionary  parameterName=ipAddressAllocationMethod  operation=update  value=MANUAL
    &{param_dict_1}=  Create Dictionary  parameterName=ipAddressV${ipversion}Id  operation=update  value=2
    &{param_dict_2}=  Create Dictionary  parameterName=localIpAddr  operation=update  value=${localIpAddr}
    &{param_dict_3}=  Create Dictionary  parameterName=localIpPrefixLength  operation=update  value=${localIpPrefixLen}
    ${parameter_list}=    Create List    ${param_dict_0}    ${param_dict_1}    ${param_dict_2}    ${param_dict_3}
    ${dist_name}  Set Variable  MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV${ipversion}-2
    coam_admin.Perform Object Recommissioning    dist_name=${dist_name}
    ...                               parameter=${parameter_list}
    ...                               operation=${operation}
    ...                               skip_parameter_relation_errors=${FALSE}
    ...                               should_activate=${True}
    ...                               timeout=60s
    ...                               connection=${admin_connection}
    [Return]   ${dist_name}
    [Teardown]    Disconnect from ADMIN    connection=${admin_connection}

Wait For No Connection To Unit Alarm
    ${connection}                     Connect to ADMIN
    ...                               alias=alarm
    Wait Until Alarm Appears On BTS   fault_id=10
    ...                               timeout=1800
    [Teardown]                        Disconnect from ADMIN
    ...                               connection=alarm

Delete Secondary CMP
    ${conn}=     Connect to ADMIN
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                             param_name=secondaryServerHost
    ...                             timeout=120s
    ...                             connection=${conn}
    [Teardown]    Disconnect from ADMIN

Set Initial CMP Server Settings
    certificates.Set CMP Server Settings
    certificates.Update CMP Key

Reset Site And Check Alarms
    [Arguments]         ${allowed_alarms}
    ${alarm_before} =   admin.Get Active Alarms From BTS
    Sort List           ${alarm_before}
    Log                 Alarms before reset: ${alarm_before}  console=True
    Log                 Allowed alarms will be skipped: ${allowed_alarms}  console=True
    ${alarm_before} =   Trim Allowed Alarms  ${allowed_alarms}  ${alarm_before}
    ${check_RM} =       Run Keyword And Return Status  List Should Not Contain Value  ${alarm_before}  ${10}
    Log                 Is RU connected to BTS: ${check_RM}  console=True
    admin.Reset Site And Reconnect
    Run Keyword If      '${check_RM}'=='False'  Wait until keyword succeeds   20m  20s
    ...                 alarm.Wait For No Connection To Radio Unit Alarm
    Run Keyword If      '${check_RM}'=='True'   Wait until keyword succeeds   10m  20s
    ...                 admin.Wait until BTS reach Configured or OnAir state
    ${alarm_after} =    admin.Get Active Alarms From BTS
    Sort List           ${alarm_after}
    Log                 Alarms after reset: ${alarm_after}  console=True
    Log                 Allowed alarms will be skipped: ${allowed_alarms}  console=True
    ${alarm_after} =    Trim Allowed Alarms  ${allowed_alarms}  ${alarm_after}
    FOR  ${alarm_after_i}  IN  @{alarm_after}
        ${alarm}        Convert To Integer  ${alarm_after_i}
        Run Keyword If  ${alarm} in ${alarm_before}
        ...             Remove Values From List  ${alarm_after}  ${alarm}
    END
    ${alarm_com} =      Run Keyword And Return Status  Should Be Empty  ${alarm_after}
    Should Be True      ${alarm_com}   msg=Alarms: ${alarm_after} appeared after reset.

Trim Allowed Alarms
    [Arguments]         ${allowed_alarms}  ${alarm_list}
    FOR  ${allowed_alarm}  IN  @{allowed_alarms}
        ${alarm}        Convert To Integer  ${allowed_alarm}
        Remove Values From List  ${alarm_list}  ${alarm}
    END
    [Return]   ${alarm_list}

CRL Setup
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CRLH-1
    ...                        param_name=crlDownloadProtocol
    ...                        param_value=LDAP_OR_HTTP
