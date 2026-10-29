*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Resource          ${CURDIR}/../../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/../../resources/common_keywords.robot

*** Variables ***
${tc_variables}     testcase_variables.json

*** Keywords ***
Verify BTS Precondition
    Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
    BuiltIn.Sleep       20

Verify tunnel status with Additional CA
    Verify tunnel status
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
    BuiltIn.Sleep       20

Restore all Certificate
    certificate configure    operation=restore_vendor_certificate
    BuiltIn.Sleep       10
    certificate configure    operation=delete_cert    all_certs=${True}
    BuiltIn.Sleep       10

Install Additonal TA Certificates
    certificate configure    operation=install_certificate    cert_file=${ta_certificate}    cert_type=AdditionalCa    cert_format=PEM
    Log    TA Certificate Installed successfully
    BuiltIn.Sleep       20
    Certificate Configure       operation=install_cmp_certificate       key_pool_type=RSA       timeout=300
    BuiltIn.Sleep       20
    certificate configure    operation=install_certificate    cert_file=${ta1_certificate}    cert_type=AdditionalCa    cert_format=PEM
    Log    TA Certificate Installed successfully
    BuiltIn.Sleep       60

Verify tunnel status
    ${dict}=       Query Admin Infomodel           query=get object //IKEP_R-1 is [remoteTunnelEndpointIP=172.16.205.77]
    ${ikePeerState}=     Get From Dictionary     dictionary=${dict}      key=ikePeerState
    Should Be Equal As Strings      ${ikePeerState}     ESTABLISHED

Get Ipsec Tunnels Status
    [Arguments]    ${dut}=default
     @{parent_tunnel_moc_list} =     Query Admin Infomodel       query=get list ${ike_sa_l_moc_path}     alias=${dut}
    FOR    ${ike_tunnel}   IN  @{parent_tunnel_moc_list}
       Log         ${ike_tunnel}
       ${parent_tunnel_stateInfo}=       Get From Dictionary     dictionary=${ike_tunnel}        key=stateInfo
       ${parent_tunnel_proceduralState}=     Get From Dictionary     dictionary=${parent_tunnel_stateInfo}       key=proceduralState
       Should Be True  '${parent_tunnel_proceduralState}'=='Established'
    END

Verify IP Certificates
    [Arguments]     ${certificate}
    Certificate Configure    operation=install_certificate    cert_file=${certificate}      cert_type=BtsTrustChain     cert_format=P12
    ...     password=${IP_BTSCertpass}
    BuiltIn.Sleep    20
