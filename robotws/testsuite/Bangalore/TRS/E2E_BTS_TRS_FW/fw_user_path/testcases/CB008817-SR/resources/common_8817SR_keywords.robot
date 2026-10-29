*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot

*** Keywords ***
Login to sshenb and fronthaul and capture secondary
    Continue Keyword Execution On Failure    ${True}
    Setup Remote Access     remote_device=chained_bts     alias=secondary
    BuiltIn.Sleep    10
    Execute Interactive Remote Command      command=${ssh_enb2}     alias=secondary
    Execute Interactive Remote Command      command=${lxc_enb2}     alias=secondary
    ${aeqy}=     Execute Interactive Remote Command      command=${aeqy_ip}     alias=secondary
    ${soaprp1}=     Get Line    ${aeqy}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}

    Perform Recommissioning     type=param      param_path=${dist1}     operation=update
    ...    value=RuProtectEnabled     timeout=300
    BuiltIn.Sleep    400
    Verify Alarm        faultid=10      occurrences=2   should_exist=${True}    alarm_type=active
    BuiltIn.Sleep    300
    Verify Ipsec Status1
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Reset      operation=reset_unit  dist_name=${RMODE}      reset_type=Hard      timeout=600
    ...      verify_bts=${False}
    BuiltIn.Sleep    100
    Verify Ipsec Status1
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

    Log   Modify actEcpriRuMPlaneSecurity from RuProtectEnabled to RuProtectDisabled
    BuiltIn.Sleep    10
    Perform Recommissioning     type=param      param_path=${dist1}     operation=update
    ...     value=RuProtectDisabled     timeout=300
    BuiltIn.Sleep   300
    Verify Alarm        faultid=10      occurrences=2   should_exist=${True}    alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0     should_exist=${False}      alarm_type=active
    BuiltIn.Sleep   300
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=10      occurrences=1     should_exist=${False}      alarm_type=active
    Perform Recommissioning     type=param      param_path=${dist1}     operation=update
    ...     value=RuProtectOptional     timeout=300
    BuiltIn.Sleep    300
    Verify Alarm        faultid=10      occurrences=2   should_exist=${True}    alarm_type=active
    Run Keyword And Ignore Error      Verify Alarm        faultid=1806      occurrences=0
    ...     should_exist=${True}    alarm_type=active
    BuiltIn.Sleep    600
    Verify Ipsec Status2
    Verify Alarm        faultid=10      occurrences=1   should_exist=${False}    alarm_type=active
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Log     Reset RF and Check IPsec status
    Reset      operation=reset_unit  dist_name=${RMODE}      reset_type=Hard      timeout=600
    ...    verify_bts=${False}
    BuiltIn.Sleep    250
    Verify Ipsec Status2
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

    Log    Modify actEcpriRuMPlaneSecurity from RuProtectOptional to RuProtectDisabled
    BuiltIn.Sleep    10
    Perform Recommissioning     type=param      param_path=${dist1}     operation=update
    ...    value=RuProtectDisabled     timeout=300
    BuiltIn.Sleep   300
    Verify Alarm        faultid=10      occurrences=2   should_exist=${True}    alarm_type=active
    Teardown Remote Access     alias=secondary
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    BuiltIn.Sleep   500
    Verify BTS Status      should_be_onair=${True}     rat=5g
    Verify Alarm      faultid=10      occurrences=0       should_exist=${False}      alarm_type=active
    Verify BTS Status      should_be_onair=${True}     rat=5g

Get IPS
    Setup Remote Access     remote_device=bts     alias=co
    BuiltIn.Sleep   10
    Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist}     fhnet_login_only=${True}
    ...      timeout=60      alias=conn2
    Get RF ORAN IPs
    Rfmodule Teardown       alias=conn2
    Teardown Remote Access     alias=co

Get RF ORAN IPs
    ${soaprp}=      Execute Interactive Remote Command      command=${getaeqeip}     alias=conn2
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    ${oranip}=      Execute Interactive Remote Command      command=${getoranip}     alias=conn2
    ${oran}=     Get Line    ${oranip}   -3
    Set Suite Variable  ${oran}    ${oran}
    Check Ping

Get RF ORAN IPs secondary
    ${soaprp}=      Execute Interactive Remote Command      command=${getazqiip}     alias=secondary
    ${soaprp1}=     Get Line    ${soaprp}   -3
    Set Suite Variable  ${soaprp1}    ${soaprp1}
    Check Ping

Check Ping
    ${ping_azqi}=      Execute Interactive Remote Command      command=ping -c 10 ${soaprp1}     alias=secondary
    BuiltIn.Sleep    10
    Should Contain    ${ping_azqi}    ${packet_loss}

Verify Ipsec Status1
    ${output1}=      Execute Interactive Remote Command     command=ipsec status    alias=secondary
    Should Contain  ${output1}  ESTABLISHED
    Should Contain  ${output1}  INSTALLED
    Should Contain  ${output1}  DROP
    Should Contain  ${output1}  icmp

Verify Ipsec Status2
    ${output1}=      Execute Interactive Remote Command     command=ipsec status     alias=secondary
    Should Contain  ${output1}  ESTABLISHED
    Should Contain  ${output1}  INSTALLED
