*** Settings ***
Documentation
...            [Author]         "Sahana T C"
...            [Maintenance]    "TRS I & V Tools Bangalore Team"

Variables       ta_e2e_bts_trs_fw
Resource        ${CURDIR}/../../resources/common_keywords.robot


*** Keywords ***
Create ORU Instance
        Setup Remote Access     remote_device=airframe    alias=afsession
        Execute Interactive Remote Command      command=su     alias=afsession
        Execute Interactive Remote Command      command=${su_password}     alias=afsession
        Execute Interactive Remote Command      command=${oru_instance}     alias=afsession

Login to sshenb and fronthaul and capture
        Setup Remote Access     remote_device=bts     alias=co
        BuiltIn.Sleep   10

        Log    Modify actEcpriRuMPlaneSecurity from RuProtectDisabled to RuProtectEnabled
        Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist}     fhnet_login_only=${True}      timeout=60      alias=conn2
        Get RF ORAN IPs
        Execute Interactive Remote Command     command=${start_capture}     alias=conn2
        Perform Recommissioning     type=param      param_path=${dist1}     operation=update    value=RuProtectEnabled     timeout=300
        BuiltIn.Sleep    100
        Verify Alarm        faultid=10      occurrences=2   should_exist=${True}    alarm_type=active
        Run Keyword And Ignore Error      Verify Alarm        faultid=1806      occurrences=1   should_exist=${True}    alarm_type=active
        BuiltIn.Sleep    600
        Verify Ipsec Status1
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Perform Recommissioning     type=param      param_path=${plaintext}     operation=update    value=false     timeout=300
        BuiltIn.Sleep    50
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Run Keyword And Ignore Error      Verify Alarm        faultid=1806      occurrences=1   should_exist=True    alarm_type=active
        BuiltIn.Sleep    100
        Verify Ipsec Status1
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Get File From Remote Host    source=/user/toor4nsn/test5.pcap      destination=/home/ute    alias=co
        Log    Reset RF and Check IPsec status
        Perform Recommissioning     type=param      param_path=${plaintext}     operation=update    value=true     timeout=300
        Reset      operation=reset_unit      dist_name=${ERMOD}      reset_type=Hard      timeout=200    verify_bts=${False}
        BuiltIn.Sleep    400
        Verify Ipsec Status1
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

        Log    Modify actEcpriRuMPlaneSecurity from RuProtectEnabled to RuProtectDisabled
        BuiltIn.Sleep    10
        Perform Recommissioning     type=param      param_path=${dist1}     operation=update    value=RuProtectDisabled     timeout=300

        Execute Interactive Remote Command     command=${start_capture1}     alias=conn2
        BuiltIn.Sleep   800
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Get File From Remote Host    source=/user/toor4nsn/test6.pcap      destination=/home/ute    alias=co
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

        Log    Modify Modify actEcpriRuMPlaneSecurity from RuProtectDisabled to RuProtectOptional
        Perform Recommissioning     type=param      param_path=${dist1}     operation=update    value=RuProtectOptional     timeout=300
        Execute Interactive Remote Command     command=${start_capture2}     alias=conn2
        BuiltIn.Sleep    300
        Verify Alarm        faultid=10      occurrences=1   should_exist=True    alarm_type=active
        Run Keyword And Ignore Error      Verify Alarm        faultid=1806      occurrences=1   should_exist=True    alarm_type=active
        BuiltIn.Sleep    700
        Verify Ipsec Status2
        Perform Recommissioning     type=param      param_path=${plaintext}     operation=update    value=false     timeout=300
        BuiltIn.Sleep    50
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Run Keyword And Ignore Error      Verify Alarm        faultid=1806      occurrences=1   should_exist=True    alarm_type=active
        BuiltIn.Sleep    100
        Verify Ipsec Status2
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Get File From Remote Host    source=/user/toor4nsn/test5.pcap      destination=/home/ute    alias=co
        Log     Reset RF and Check IPsec status
        Perform Recommissioning     type=param      param_path=${plaintext}     operation=update    value=true     timeout=300
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Verify BTS Status      should_be_onair=${True}     rat=5g
        Get File From Remote Host    source=/user/toor4nsn/test7.pcap      destination=/home/ute    alias=co
        Log    Reset RF and Check IPsec status
        Reset      operation=reset_unit  dist_name=${ERMOD}      reset_type=Hard      timeout=200    verify_bts=${False}
        BuiltIn.Sleep    400
        Verify Ipsec Status2
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active

        Log    Modify actEcpriRuMPlaneSecurity from RuProtectOptional to RuProtectDisabled
        BuiltIn.Sleep    10
        Perform Recommissioning     type=param      param_path=${dist1}     operation=update    value=RuProtectDisabled     timeout=300
        Execute Interactive Remote Command     command=${start_capture1}     alias=conn2
        BuiltIn.Sleep   800
        Verify Alarm        faultid=10      occurrences=0   should_exist=${False}    alarm_type=active
        Rfmodule Teardown       alias=conn2
        Get File From Remote Host    source=/user/toor4nsn/test6.pcap      destination=/home/ute    alias=co
        Teardown Remote Access     alias=co
        Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
        Verify BTS Status      should_be_onair=${True}     rat=5g

Get IPS
        Setup Remote Access     remote_device=bts     alias=co
        BuiltIn.Sleep   10
        Rfmodule Setup      config_device=rf_module     rf_ip_distname=${dist}     fhnet_login_only=${True}      timeout=60      alias=conn2
        Get RF ORAN IPs
        Rfmodule Teardown       alias=conn2
        Teardown Remote Access     alias=co

#       Fetch SOAP/RP1 RF IP and ORAN IP
Get RF ORAN IPs
        ${soaprp}=      Execute Interactive Remote Command      command=${getaeqeip}     alias=conn2
        ${soaprp1}=     Get Line    ${soaprp}   -3
        Set Suite Variable  ${soaprp1}    ${soaprp1}
        ${oranip}=      Execute Interactive Remote Command      command=${getoranip}     alias=conn2
        ${oran}=     Get Line    ${oranip}   -3
        Set Suite Variable  ${oran}    ${oran}
        Check Ping

Get RF IPs
        ${soaprp}=      Execute Interactive Remote Command      command=${getaweucip}     alias=conn2
        ${soaprp1}=     Get Line    ${soaprp}   -3
        Set Suite Variable  ${soaprp1}    ${soaprp1}
        Check Ping1

Check Ping1
       ${ping_aweuc}=      Execute Interactive Remote Command      command=ping -c 10 ${soaprp1}     alias=conn2
       BuiltIn.Sleep    10
       Should Contain    ${ping_aweuc}    ${packet_loss}

#      Ping to Soap/RP1 and ORAN Ru
Check Ping
       ${ping_aeqe}=      Execute Interactive Remote Command      command=ping -c 10 ${soaprp1}     alias=conn2
       BuiltIn.Sleep    10
       Should Contain    ${ping_aeqe}    ${packet_loss}
       ${ping_oran}=      Execute Interactive Remote Command      command=ping -c 10 ${oran}     alias=conn2
       BuiltIn.Sleep    10
       Should Contain    ${ping_oran}    ${packet_loss}

Verify Ipsec Status1
        ${output1}=      Execute Interactive Remote Command     command=ipsec status    alias=conn2
        Should Contain  ${output1}  ESTABLISHED
        Should Contain  ${output1}  INSTALLED
        Should Contain  ${output1}  ${DROP}
        Should Contain  ${output1}  icmp

Verify Ipsec Status2
        ${output1}=      Execute Interactive Remote Command     command=ipsec status     alias=conn2
        Should Contain  ${output1}  ESTABLISHED
        Should Contain  ${output1}  INSTALLED
        Should Contain  ${output1}  ${PASS}
        Should Not Contain  ${output1}  icmp
