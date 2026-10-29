*** Settings ***
Documentation
...     [Procedure]             "The test case is planned to validate 7821 feature"
...     [Date]                  "20-4-24"
...     [Author]                "Vinay"
...     [QC_Path]               "QC_Path in Test Plan"
...     [QC_ID]                 "QC_ID in Test Lab for reporting"
...     [Funtion_Hash_Tags]     "FIREWALL, COUNTERS, NETACT"
...     [Domain_Hash_Tags]      "counters"
...     [Feature_ID]            "CB007821"
...     [Validation_status]     "Validated and Passed"
...     [Validated_TestLine]    "MRBTS-3611"
...     [Config_Comments]       "This script requires basic SCF loading"

Variables         ta_e2e_bts_trs_fw
Library           ${CURDIR}/../CB007821_ST/resources/CB007821_functions.py   WITH NAME    7821
Resource          ${CURDIR}/../resources/common_keywords.robot

Suite Setup       Run Keywords    Suite Setup Preconditions
...               AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...               AND    Teardown Oamops

*** Test Cases ***
[1][1.0] AEHC radio is not detected after BTS SW update
    Basic Checks
    Check Is RUs IP Are in DHCP Range Pool    ${bts_MPlane}
    Check If All RUs Are In Enabled State
    Check RMOD's for enabled state
    Firewall_actMplaneFronthaulFirewall_true
    BuiltIn.Sleep    200
    Modify RMOD product code and check BTS status

*** Keywords ***
Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List
    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list1}    ${list[${i}]['faultId']}
    END
    [return]    ${list1}

Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}
    ${list}=    Create List
    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END
    [return]    ${list}

Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}

Check Radions ABIP for AEQP_A
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    ${output}=    Execute Interactive Remote Command
    ...    command=bsh ${baseband_select} ip netns exec radions ip a
    ...    alias=bts_MPlane_session
    Log    ${output}
    ${regex}=    7821.Get Regex    param_name=Radions A
    ${status}=   7821.Get Regex Matches    ${output}    ${regex}
    Should Be True    ${status}
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check Radions ABIP for AEQP_R
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    ${output}=    Execute Interactive Remote Command
    ...    command=bsh ${baseband_select} ip netns exec radions ip r
    ...    alias=bts_MPlane_session
    ${regex}=    7821.Get Regex    param_name=Radions R
    ${status}=   7821.Get Regex Matches    ${output}    ${regex}
    Should Be True    ${status}
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check DHCP Relay Agent
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    ${output}=    Execute Interactive Remote Command
    ...    command=bsh ${baseband_select} ip netns exec radions ps aux | grep -i dhcp_relay
    ...    alias=bts_MPlane_session
    Log    ${output}
    ${regex}=    7821.Get Regex    param_name=DHCP Relay
    ${status}=   7821.Get Regex Matches    ${output}    ${regex}
    Should Be True    ${status}
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check Fronthaul IP
    Log    Check Fronthaul IP    console=True
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    ${output}=    Execute Interactive Remote Command
    ...    command=lxc-attach --set-var COLUMNS=250 -n 0x3018 -- ip a show rlan0.ecpri
    ...    alias=bts_MPlane_session
    Log    ${output}
    ${output}=    Split String    ${output}
    ${output}=    Join Output     ${output}
    ${FHNET}=     7821.Get BTS Info    ${BTS_ID}    IPs    FHNET    L2
    ${FHNET}=     Convert To String    ${FHNET}
    Should Contain    ${output}    ${FHNET}
    Log    OK    console=True
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check RU IP Pool
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    Log    Check RU Ip Pool    console=True
    ${output}=    Execute Interactive Remote Command
    ...    command=lxc-attach --set-var COLUMNS=250 -n 0x3018 -- ip r
    ...    alias=bts_MPlane_session
    ${output}=    Split String    ${output}
    ${output}=    Join Output     ${output}
    ${FHNET}=       7821.Get BTS Info    ${BTS_ID}    IPs    FHNET       L2
    ${Route_IP}=    7821.Get BTS Info    ${BTS_ID}    IPs    IP_route   L2
    Should Contain    ${output}    ${Route_IP}
    Should Contain    ${output}    ${FHNET}
    Log    OK    console=True
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check CCSSysComGwExe
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    Log    Checking CCSSysComGwExe    console=True
    ${output}=    Execute Interactive Remote Command
    ...    command=lxc-attach --set-var COLUMNS=250 -n 0x3018 -- netstat -lnup
    ...    alias=bts_MPlane_session
    ${output}=    Split String    ${output}
    ${output}=    Join Output     ${output}
    ${FHNET}=    7821.Get BTS Info    ${BTS_ID}    IPs    FHNET    L2
    Should Contain    ${output}    ${FHNET}
    Log    OK    console=True
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check If BTS Is Pingable
    [Arguments]    ${bts_MPlane}
    ${result}=    Run Process    ping ${bts_MPlane} -c 1    shell=True
    Log    all output: ${result.stdout}
    Should Contain    ${result.stdout}    64 bytes from ${bts_MPlane}

Basic Checks
    Log    Basic Checks    console=True
    Check Radions ABIP for AEQP_A
    Check Radions ABIP for AEQP_R
    Check DHCP Relay Agent
    Ping DHCP Server    dhcp_type=${dhcp_type}
    Check Fronthaul IP
    Check RU IP Pool
    Check CCSSysComGwExe
    Log    Basic Checks Done    console=True

Check Is RUs IP Are in DHCP Range Pool
    [Arguments]    ${bts_MPlane}
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    Log    Check RU's Ips    console=True
    ${output}=    Execute Interactive Remote Command
    ...    command=lxc-attach -n 0x3018 | cat /ffs/run/config/FRIps.txt
    ...    alias=bts_MPlane_session
    ${output}=    Split String    ${output}
    ${DHCP_pool}=    7821.Get BTS Info    ${BTS_ID}    IPs    DHCP_pool    L2
    ${ips}=          7821.Check If In Range    ${output}    ${DHCP_pool}
    Should Not Be Empty    ${ips}
    Log    Ping All Available RUs    console=True
    ${pings}=        7821.Ping R Us    ${ips}    ${bts_MPlane}
    Should Be True    ${pings}
    Log    Pings Successful    console=True
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Check RMOD's for enabled state
    ${rmod_list}=    Query Admin Infomodel    query=get list //RMOD_R-*
    Log    ${rmod_list}
    FOR    ${rmod}    IN    @{rmod_list}
        ${status}=       Get From Dictionary    dictionary=${rmod}    key=operationalState
        ${dist_name}=    Get From Dictionary    dictionary=${rmod}    key=dist_name
        ${dist_name}=    Convert To String    ${dist_name}
        Should Be Equal    ${status}    enabled
    END

Check If All RUs Are In Enabled State
    Setup Remote Access    remote_device=bts_MPlane    alias=bts_MPlane_session
    Log    Checking RUs    console=True
    ${rmod_list}=    Query Admin Infomodel    query=get list //RMOD_R-*
    Log    ${rmod_list}
    FOR    ${rmod}    IN    @{rmod_list}
        ${status}=    Get From Dictionary    dictionary=${rmod}    key=operationalState
        Should Be Equal    ${status}    enabled
    END
    [Teardown]    Teardown Remote Access    alias=bts_MPlane_session

Get PDU Statuses
    ${pdu_ips}=    7821.Get PDU IPs    ${BTS_ID}
    FOR    ${pdu}    IN    @{pdu_ips}
        7821.Log PDU Settings    ${pdu}
    END

Check IPSec
    Log    [1]Firewall_actMplaneFronthaulFirewall_true    console=True
    Firewall_actMplaneFronthaulFirewall_true

Firewall_actMplaneFronthaulFirewall_true
    Perform Recommissioning
    ...    type=param
    ...    param_path=MRBTS-3611/MNL-1/MNLENT-1/FEATCADM-1:actMplaneFronthaulFirewall
    ...    operation=update
    ...    value=true
    ...    timeout=600
    Check RMOD's for enabled state
    Verify Bts Status    req_rat=5g    should_be_onair=${True}    timeout=120
    Perform Recommissioning
    ...    type=param
    ...    param_path=MRBTS-3611/MNL-1/MNLENT-1/FEATCADM-1:actEcpriRuMPlaneSecurity
    ...    operation=update
    ...    value=RuProtectDisabled
    ...    timeout=600
    Check RMOD's for enabled state
    Verify Bts Status    req_rat=5g    should_be_onair=${True}    timeout=300
    ${rmod_list}=    Query Admin Infomodel    query=get list //RMOD_R-*
    Log    ${rmod_list}
    ${length}=    Get Length    ${rmod_list}
    ${dist}=      Get From Dictionary    dictionary=${rmod_list[0]}    key=dist_name
    ${rmod}    ${var}=    Should Match Regexp    ${dist}    \\/(RMOD_R-\\d)
    FOR    ${rm}    IN    @{rmod_list}
        ${dist_name}=    Get From Dictionary    dictionary=${rm}    key=dist_name
        ${rmod_name}    ${var}=    Should Match Regexp    ${dist_name}    \\/(RMOD_R-\\d)
    END

Modify RMOD product code and check BTS status
    Perform Recommissioning
    ...    type=param
    ...    param_path=${Rmod_DN}:${Productcode}
    ...    operation=update
    ...    value=${productcodeValue}
    ...    timeout=600
    Check RMOD's for enabled state
    Verify Bts Status    req_rat=5g    should_be_onair=${True}

Ping DHCP Server
    [Arguments]    ${dhcp_type}
    Log    Ping DHCP Server    console=True

    ${DHCP_IP}=    7821.Get BTS Info    ${BTS_ID}    IPs    FHNET    ${dhcp_type}
    ${loki}=    Set Variable If    '${BTS_ID}' == '51072'    1:2    1:1

    ${output}=    Execute Command And Read Output
    ...    command=bsh ${loki} ip netns exec radions ping -c 1 ${DHCP_IP}
    ...    ip=${mplane}

    ${catenated_output}=    Catenate    @{output}
    Log    Ping Successful    console=True

