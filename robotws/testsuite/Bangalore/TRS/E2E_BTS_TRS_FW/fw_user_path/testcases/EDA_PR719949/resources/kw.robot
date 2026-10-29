*** Settings ***
Documentation
...             [Author]         "Pooja K"
...             [Maintenance]    "TRS I & V Tools Bangalore Team"
...             [Precondition]   " "


Library    SSHLibrary
Library    OperatingSystem
Library    Process
Library    String
Library    BuiltIn
Library    Collections


*** Variables ***
${vnc_ip}           10.58.141.136
${host}             10.58.141.137
${username}         ute
${password}         UTE.debian12
${tc_variables}     testcase_variables.json
${variables}        ta_e2e_bts_trs_fw


*** Keywords ***
verify BTS basic status
    Verify Bts Status   should_be_onair=${True}
    Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
    Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
    Sleep   20
    Verify Alarm      faultid=4082      occurrences=0       should_exist=${False}      alarm_type=active
    Sleep   20

Verify power_on_off on PM & SN core
    FOR    ${index}    IN RANGE    ${length}
       Poweroff_BTS    RRB1        ${RRB1['PrimaryBTSPortID']}
       Sleep    60
       Verify rechability of SecondaryBTS
       Sleep    60
       Poweron_BTS        RRB1    ${RRB1['PrimaryBTSPortID']}
       Sleep    300
       Verify Bts Status   should_be_onair=${True}
       Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
       Verify Alarm      faultid=4082      occurrences=0       should_exist=${False}      alarm_type=active
       Sleep   20
       Check SSH Login      Primarybts
       Check SSH Login      Secondarybts
       Poweroff_BTS    RRB2    ${RRB2['SecondaryBTSPortID']}
       Sleep    10
       verify expected and unexpected alarms
       Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
       Verify Alarm      faultid=4082      occurrences=0       should_exist=${False}      alarm_type=active
       Poweron_BTS    RRB2    ${RRB2['SecondaryBTSPortID']}
       Sleep   60
       Verify Bts Status   should_be_onair=${True}
       Verify Alarm    expected_alarms=${expected_alarms}     check_unexpected_alarms=True      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=active
       Verify Alarm      faultid=6450      occurrences=0       should_exist=${False}      alarm_type=history
       Sleep   20
       Check SSH Login      Primarybts
       Check SSH Login      Secondarybts
    END

verify expected and unexpected alarms
    Verify Alarm        faultid=4352     rat=5g     should_exist=${True}        occurrences=1     check_unexpected_alarms=${False}
    Verify Alarm        faultid=6450     rat=5g     should_exist=${False}       occurrences=0     check_unexpected_alarms=${False}
    Verify Alarm        faultid=4082     rat=5g     should_exist=${False}       occurrences=0     check_unexpected_alarms=${False}


Poweroff_BTS
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 0
    Sleep   120
    [Teardown]  Teardown Remote Access

Check SSH Login
    [Arguments]     ${bts}
    Setup Remote Access     remote_device=${bts}
    [Teardown]  Teardown Remote Access

Poweron_BTS
    [Arguments]     ${RRB}  ${port}
    Setup Remote Access     remote_device=${RRB}
    Remote Command Execute      command=gpio write ${port}s 1
    Sleep   120
    [Teardown]  Teardown Remote Access

Verify rechability of SecondaryBTS
    SSHLibrary.Open Connection  ${host}
    SSHLibrary.Login            ${username}  ${password}
    ${stdout}=                  SSHLibrary.Execute Command     ping 192.168.255.119 -c 4
    Log                         ${stdout}
    Should contain      ${stdout}     4 packets transmitted, 4 received, 0% packet loss
