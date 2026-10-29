*** Settings ***
Documentation     [Procedure] ""
...               [Date] "Date of creation "
...               [Author] "Vinay"
...               [QC_Path] "QC_Path in Test Plan"
...               [QC_ID] "QC_ID in Test Lab for reporting"
...               [Feature_ID] ""
...               [Function_Hash_Tags] ""
...               [Validation_status] Validated and Passed
...               [Validated_TestLine] 2020
...               [Validation Date]

Variables         ta_e2e_bts_trs_fw
Resource          taf/rfrl/trs_e2e_fw/setup/framework.robot
Resource          ${CURDIR}/../resources/common_keywords.robot
Resource          ${CURDIR}/../resources/Common_IPSEC_Operations.robot
Resource          ${CURDIR}/resources/common_ipsec_setup_keywords.robot
Library           Collections

Suite Setup       Run Keywords    Suite Setup Preconditions
...               AND    Setup Oamops
Suite Teardown    Run Keywords    Suite Teardown Postconditions
...               AND    Teardown Oamops


*** Test Cases ***
[1][1.0] SMTRS 31138 - Recreate IPSec Tunnels by Stopping and starting Security GW post Upgrade and reset
    ${ipsec_value}=    Get Parameter
    ...    param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1:ipSecEnabled
    Should Be True    ${ipsec_value}
    Verify Ipsec Tunnels Status

    Perform Recommissioning
    ...    type=param
    ...    param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-2:remoteTunnelEndpoint
    ...    operation=update
    ...    value=${wrong_rtep_ip}
    ...    timeout=300

    ${p_faultids}=    Get Current Alarm List
    BuiltIn.Sleep    100s

    ${post_faultids}=    Get Current Alarm List
    ${ft_id}=    Convert To String    ${ipsec_fault_id}
    Should Contain    ${post_faultids}    ${ft_id}

    Perform Recommissioning
    ...    type=param
    ...    param_path=MRBTS-${bts_id}/TNLSVC-1/TNL-1/IPAPP-1/IPSECC-1/IKEP-2:remoteTunnelEndpoint
    ...    operation=update
    ...    value=${correct_rtep_ip}
    ...    timeout=300

    BuiltIn.Sleep    100s

    ${pre_faultids}=    Get Current Alarm List
    Should Not Contain    ${pre_faultids}    ${ipsec_fault_id}

    Verify Pre Fragmentation with ICMP    alias=alias_1
    Verify Pre Fragmentation with Traffic

    ${post_faultids}=    Get Current Alarm List
    ${new_alarms}=    Fault list after reset
    ...    ${pre_faultids}
    ...    ${post_faultids}

    Should Be Empty    ${new_alarms}



*** Keywords ***
Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List
    FOR    ${i}    IN RANGE    ${length}
        ${fault_id}=    Convert To Integer    ${list[${i}]['faultId']}
        Append To List    ${list1}    ${fault_id}
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

Fault list after reset_1
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids_1}
    ${list}=    Create List
    FOR    ${i}    IN    @{post_alarm_faultids_1}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END
    [return]    ${list}

Start Ip traffic capture point B file mode
    [Arguments]    ${capture_device}    ${uplane_val}=True    ${alias}=default
    Traffic Capture Start
    ...    capture_device=${capture_device}
    ...    mode=file
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=${uplane_val}
    ...    timeout=120
    ...    alias=${alias}
    Sleep    10

Make 5g Call
    Call Setup    lte=device_1:data    verify_attach=${False}
    Call Start    lte=device_1:data    profile=udp_10K_dl    iperf_section=device1
    Call Start    lte=device_1:data    profile=udp_10K_ul    iperf_section=device1
    BuiltIn.Sleep    120
    Call Stop    lte=device_1:data    profile=udp_10K_ul
    Call Stop    lte=device_1:data    profile=udp_10K_dl
    Call Teardown    lte=device_1:data

Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}

Verify Pre Fragmentation with Traffic
    ${pre_alarm_faultids}=    Get Current Alarm List
    Traffic Capture Start
    ...    capture_device=oam_device
    ...    mode=file
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=${True}
    ...    alias=pcap1

    Make 5g Call

    ${pcap_path}=    Traffic Capture Stop
    ...    mode=file
    ...    alias=pcap1

    BuiltIn.Sleep    30s

    Analyse Pcap
    ...    pcap_filename=${EXECDIR}/${pcap_path}
    ...    analysis=verify_frag_messages

    Analyse Pcap
    ...    pcap_filename=${EXECDIR}/${pcap_path}
    ...    analysis=verify_isakmp

    ${post_alarm_faultids}=    Get Current Alarm List

    ${alarms_post_execution}=    Fault list after reset
    ...    ${pre_alarm_faultids}
    ...    ${post_alarm_faultids}

    Should Be Empty    ${alarms_post_execution}

    [Teardown]    Run Keyword and Ignore Error
    ...    Traffic Capture Stop
    ...    mode=file
    ...    alias=pcap1

Verify Pre Fragmentation with ICMP
    [Arguments]    ${alias}

    Traffic Capture Start
    ...    capture_device=oam_device
    ...    mode=file
    ...    measurement_point=Transport_Interface
    ...    uplane_capturing=${True}
    ...    alias=${alias}

    Setup Remote Access    remote_device=mplane    alias=session1

    ${stdout_2}=    Execute Interactive Remote Command
    ...    command=ping -I ${src_ip} ${dest_ip} -s ${mtu_size} -c 100
    ...    alias=session1

    BuiltIn.Sleep    30s

    ${pcap_path1}=    Traffic Capture Stop
    ...    mode=file
    ...    alias=${alias}

    Analyse Pcap
    ...    pcap_filename=${EXECDIR}/${pcap_path1}
    ...    analysis=verify_frag_messages

    Analyse Pcap
    ...    pcap_filename=${EXECDIR}/${pcap_path1}
    ...    analysis=verify_isakmp

    [Teardown]    Run Keyword and Ignore Error
    ...    Traffic Capture Stop
    ...    mode=file
    ...    alias=${alias}
