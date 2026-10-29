*** Settings ***
Documentation
...  User interface to set counters parameters and collect and check counters.

Library     taf.sbts.oam.coam.admin  WITH NAME  coam_admin
Library     taf.nms.netact    WITH NAME    netact
Library     Counters.py
Library     check_counter_intervals.py
Resource    ../commissioning/parameters.robot
Resource    ../admin/admin.robot
Library       Collections

*** Variables ***
# ipRmDropPcktsRtLimICMP [M51328C15] test settings
${M51328C15_BURST}=                               32
${M51328C15_LIMIT}=                               1000
${M51328C15_INCREASE_PERCENT}=                    0.10
${M51328C15_PPS}=                                 ${M51328C15_LIMIT} + (${M51328C15_LIMIT} * ${M51328C15_INCREASE_PERCENT})
${M51328C15_count}=                                10
${M51328C15_PACKETS}=                             ${M51328C15_count} * (${M51328C15_PPS})
${M51328C15_TCPDUMP_STATISTICAL_ERROR}=           0.25
${M51328C15_TCPDUMP_STATISTICAL_ERROR_MORE}=      (1 + ${M51328C15_TCPDUMP_STATISTICAL_ERROR})
${M51328C15_TCPDUMP_STATISTICAL_ERROR_LESS}=      (1 - ${M51328C15_TCPDUMP_STATISTICAL_ERROR})
${M51328C15_SHOULD_BE_COLLECTED}=                 ${M51328C15_PACKETS} - (${M51328C15_LIMIT} * ${M51328C15_count}) - ${M51328C15_BURST}
${M51328C15_TEST_STATISTICAL_ERROR}=              (${M51328C15_count} * (${M51328C15_PPS})) / 10


*** Keywords ***
Wait For Next Counter Interval and Get Counter Timestamp with Value
    [Documentation]    Description:      Keyword to choose the proper time to send the packets. It check the available counter
    ...                                  and wait for the next one. After that - the packet must be sent and then the same KW
    ...                                  could be used to get the value for the counter. Example:
    ...                - available_counter=10:15:00 - KW wait until counter 10:20:00 will be available.
    ...                - available_counter=10:20:00 - KW end because new counter is available
    ...                - packets are sent - it must be used KW from test_pc.robot file
    ...                - available_counter=10:20:00 - KW wait until next counter will be available
    ...                                               because the next one will have the packets
    ...                - available_counter=10:25:00 - KW end because new counter with packets is available
    ...                Return:           Dictionary with counter's timestamp and value.
    ...                Author:           jagoda.kubacka@nokia.com
    [Arguments]        ${counter_id}                  #the ID for the counter, example: M51328C18
    ${temp_conn}=      admin.Connect to ADMIN
    &{all_events}    counters._Get Counter Objects From WebEM    counter_id=${counter_id}
    ${event_list}    Convert To List    ${all_events.keys()}
    ${last_counter}    Get From List    ${event_list}    -1
    ${value}    Get From Dictionary    ${all_events}    ${last_counter}
    Log to console    ${last_counter}
    ${is_event_created}=     Set Variable    ${False}
    WHILE                    not ${is_event_created}
        &{all_events}    counters._Get Counter Objects From WebEM    counter_id=${counter_id}
        ${event_list}    Convert To List    ${all_events.keys()}
        ${current_counter}    Get From List    ${event_list}    -1
        ${is_event_created}=    Evaluate    '${current_counter}' > '${last_counter}'
        IF    not ${is_event_created}
            Log To Console    Waiting for counter event...
            Sleep    10sec
        END
    END
    &{all_events}    counters._Get Counter Objects From WebEM    counter_id=${counter_id}
    ${event_list}    Convert To List    ${all_events.keys()}
    ${last_counter}    Get From List    ${event_list}    -1
    ${value}    Get From Dictionary    ${all_events}    ${last_counter}
    &{last_counter_dict}    Create Dictionary
    Set To Dictionary    ${last_counter_dict}    ${last_counter}=${value}
    [Return]                 ${last_counter}    ${value}
    [Teardown]               Run Keyword and Ignore Error    admin.Disconnect from ADMIN    connection=${temp_conn}

counters._Get Counter Objects From WebEM
    [Arguments]            ${counter_id}    ${mrbts_id}=50203    ${timeout}=90
    ${temp_conn}=          admin.Connect to ADMIN
    ${counters}=           coam_admin.get_pm_counters
    ...                    counter_ids=${counter_id}
    ...                    timeout=${timeout}
    ...                    connection=${temp_conn}
    &{counters_dict}       Create Dictionary
    ${counters_dict}    Set Variable    ${counters}[TRS][MRBTS-${mrbts_id}][TNLSVC-1][TNL-1][IPNO-1][IP_filtering_Stats][${counter_id}]
    &{counters_dict_new}    Create Dictionary
    FOR    ${item}    IN    @{counters_dict.keys()}
       ${converted_time}    convert_time_from_epoch    ${item}
       ${value}=    Get From Dictionary    ${counters_dict}    ${item}
       ${new_key}    Set Variable    ${converted_time}
       Set To Dictionary    ${counters_dict_new}    ${new_key}=${value}
    END
    [Return]    &{counters_dict_new}
    [Teardown]             admin.Disconnect from ADMIN    connection=${temp_conn}

Change Rejected Packets Interval To 5min
    ${connection}=  Connect to ADMIN
    ${correct_dist}=  Set Variable      MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    change parameter on bts             dist_name=${correct_dist}
    ...                                 param_name=ipFilteringInterval
    ...                                 param_value=5min
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Change Reporting Interval To 5min
    ${connection}=  Connect to ADMIN
    ${correct_dist}=  Set Variable      MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1
    change parameter on bts             dist_name=${correct_dist}
    ...                                 param_name=reportingIntervalPm
    ...                                 param_value=5min
    ...                                 skip_parameter_relation_errors=${FALSE}
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Send Packets via Scapy
    [Arguments]        ${packet_type}    # Type of packets that can be sent: TCP, SCTP, ICMP, UDP
    ...                ${ip_dst}         # The destination address that packets will be sent on this IP
    ...                ${pps}            # The amount of packets sent per second
    ...                ${count}           # The amount of all packets that will be sent
    ...                ${vlan}=eth0           # The ID of vlan
    ...                ${sport}=${NONE}  # The source port (neccessary in SCTP)
    ...                ${dport}=${NONE}  # The destination port (neccessary in UDP, TCP)
    ...                ${type}=${NONE}   # Type of ICMP packet (0 - echo-replay; 3 - destination-unreachable;
                                         # 8 - echo-request; 11 - time-exceeded; 12 - parameter-problem)
    ${python_path}=    Run  which python
    ${command}=        Run Keyword If  '${packet_type}'=='SCTP'
    ...    Catenate    'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_dst}")
    ...                /scapy.SCTP(sport=${sport}, dport=${dport}), pps=${pps}, count=${count}, iface="${vlan}", parse_results=1)'
    ...    ELSE IF     '${packet_type}'=='UDP'
    ...    Catenate    'import scapy.all as scapy;scapy.sendpfast(scapy.Ether()/scapy.IP(dst="${ip_dst}")
    ...                /scapy.UDP(dport=${dport}), pps=${pps}, count=${count}, iface="${vlan}", parse_results=1)'
    ...    ELSE IF     '${packet_type}'=='TCP'
    ...    Catenate    'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${ip_dst}")
    ...                /scapy.TCP(dport=${dport}, flags="S"), pps=${pps}, count=${count}, iface="${vlan}", parse_results=1)
    ...    ELSE IF     '${packet_type}'=='ICMP'
    ...    Catenate    'import scapy.all as scapy; scapy.sendpfast((scapy.Ether() / scapy.IP(dst="${ip_dst}")
    ...                /scapy.ICMP(type=${type}, code=0), pps=${pps}, count=${count}, iface="${vlan}", parse_results=1))'
    ...    ELSE        Log    The packet_type was not provided - this is neccessary!    console=true
    Run    sudo -E ${python_path} -c ${command}

Change Counter Capture Interval Time
    [Arguments]       ${param_name}     ${minutes}
    ${connection}=                      Connect To ADMIN
    ${dist}=       Set Variable    MRBTS-${BTS_ID}/TNLSVC-1/PMTNLINT-1
    Change Parameter on BTS             dist_name=${dist}
    ...                                 param_name=${param_name}
    ...                                 param_value=${minutes}
    ...                                 connection=${connection}
    [Teardown]  Disconnect from ADMIN   ${connection}

Check If Counters Are Captured With Correct Interval
    [Arguments]    ${password}  ${minutes}  ${destination}  ${counter}
    ${connection}=  Connect to ADMIN
    ${bool}=  Check if Set Interval Works  password=${password}  minutes=${minutes}
    ...                                    destination=${destination}  counter=${counter}
    Should be true  ${bool}
    [Teardown]  Disconnect from ADMIN     ${connection}

Get First Counter From NetAct
    [Documentation]    Get counters list from netact for given counter and given time amount
    [Arguments]    ${_counters}    ${_time_amount}
    netact.Add Web URL      ${LAB_NAME}lbwas.srnblr.nsn-rdnet.net    ${NMS_USERNAME}  ${NMS_PASSWORD}
    @{nms_counters}=    netact.Get Pm Counters
    ...    technology=SBTS-Nokia Multi Radio Transceiver Station
    ...    measurement=IP filtering Statistics
    ...    counters=${_counters}
    ...    filter_by=MRBTS
    ...    mo_names=PLMN-PLMN/MRBTS-${BTS_ID}
    ...    object_aggregation=PLMN/MRBTS
    ...    time_aggregation=RAW
    ...    time_filter=relative
    ...    time_from=NOW
    ...    time_amount=${_time_amount}
    ...    time_period=MIN
    [Teardown]    netact.Delete Node    web_url
    [Return]  ${nms_counters}[0][${_counters}]

Get Counters from WebEM
    [Arguments]    @{counters}
    ${webem_counters}=    Run Keyword With ADMIN Connection    coam_admin.Get Pm Counters    @{counters}
    [Return]    ${webem_counters}

Convert Time To Epoch
    [Arguments]    ${input_time}
    ${current_date}=    Get Current Date  result_format=%Y.%m.%d
    ${datetime_string}=    Catenate    SEPARATOR=    ${current_date}${input_time}:00
    ${epoch_time}=  _Convert DateTime To Epoch  ${datetime_string}
    [Return]  ${epoch_time}

_Convert DateTime To Epoch
    [Arguments]  ${datetime_string}
    ${epoch_time}=  Convert Date  ${datetime_string}  result_format=%s
    [Return]  ${epoch_time}

Get Correct Counter Value by Epoch Time
    [Arguments]  ${webem_counters}    ${epoch_time}    ${epoch_offset}
    ${corrected_epoch}=    Evaluate    ${epoch_time} + ${epoch_offset}
    ${regex_filter}=    Set Variable    (${corrected_epoch}): (\\d*)
    ${counters_string}=    Evaluate     str(${webem_counters}).replace("'","")
    ${output}=    Evaluate    re.search("${regex_filter}", "${counters_string}").group(2)
    [Return]  ${output}
