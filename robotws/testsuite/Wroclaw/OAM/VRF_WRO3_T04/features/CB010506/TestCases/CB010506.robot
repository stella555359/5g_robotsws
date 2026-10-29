*** Settings ***
Documentation    Suite for testing common_resources for cloud

Library    taf.transport.ssh       WITH NAME    ssh
Library    taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library    OperatingSystem


Resource        ../../../../cloud_common_resources/connections/connections.robot
Resource        ../../../../cloud_common_resources/parameters/parameters.robot
Resource        ../../../../cloud_common_resources/alarms/alarms.robot
Resource        ../../../../cloud_common_resources/certificates/certificates.robot
Resource        ../../../../cloud_common_resources/resets/resets.robot
Resource        ../../../../cloud_common_resources/pods_and_containers/pods.robot
Resource        ../../../cloud_common_resources/counters/counters.robot
Resource        ../Resources/resources.robot
Resource        ../../../cloud_common_resources/test_pc/test_pc.robot
Resource        taf/rfrl/cbts/robot/netact/netact.robot
Resource        taf/rfrl/cbts/robot/webem_operations.robot

*** Variables ***

${IP_TEST_PC}=  10.42.63.239
${LOGIN_TEST_PC}=  trs
${PASS_TEST_PC}=  YT_xk39b

*** Keywords ***
CB010506_A_T01_Firewall_Mplane_Rate_Limit_Counter_ICMP_Packets_vDU
    Log  Step 1, 2: Connecting to vDU and changing the icmpResponseEnabled parameter to false    console=true
    ${dist_name_tnl}=          Check Parameter Object Via Value on BTS    param_value=oam certman-server tracecontroller
    ...                        hw_type=vDU
    ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name_tnl}[0]    4
    Change Parameter on BTS    dist_name=${specific_dist_name}    param_name=icmpResponseEnabled
    ...                        param_value=false    hw_type=vDU
    Log  Step 3: Checking if the icmpResponseEnabled set to false and checking if ping/traceroute is disbabled    console=true
    ${response}=               Check Parameter Value    param_name=icmpResponseEnabled
    ...                        dist_name=${specific_dist_name}    hw_type=vDU
    ${reponse_off_on}=         Set Variable If    '${response}'=='false'    off    on
    Execute Ping Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Execute Traceroute Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Log  Step 4: Resetting the vDU and waiting when vDU is in onAir state    console=true
    Perform Reset and Wait for Expected State    state=onAir    hw_type=vDU
    Log  Step 5: Checking if ping and tracereoute is still disabled after reset    console=true
    ${response}=               Check Parameter Value    param_name=icmpResponseEnabled
    ...                        dist_name=${specific_dist_name}    hw_type=vDU
    Execute Ping Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Execute Traceroute Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Log  Step 6: Setting the icmpResponseEnabled parameter to true    console=true
    Change Parameter on BTS    dist_name=${specific_dist_name}    param_name=icmpResponseEnabled
    ...                        param_value=true    hw_type=vDU
    Log  Step 7: Checking if the icmpResponseEnabled set to true and checking if ping/traceroute is enabled    console=true
    ${response}=               Check Parameter Value    param_name=icmpResponseEnabled
    ...                        dist_name=${specific_dist_name}    hw_type=vDU
    ${reponse_off_on}=         Set Variable If    '${response}'=='false'    off    on
    Execute Ping Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Execute Traceroute Test From TestPC    ping=${reponse_off_on}    hw_type=vDU
    Log  Step 8: Setting the ipFilteringInterval parameter to 5min    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1    param_name=ipFilteringInterval
    ...                        param_value=5min    hw_type=vDU
    Log  Step 9: Sending the ICMP packages type 0 (ECHO_REPLY) to the M-Plane vDU    console=true
    ${icmp_type_int}=    Get Random ICMP Type
    Append to List    ${icmp_type_list}    8    ${icmp_type_int}
    Log  Used ICMP types: ${icmp_type_list}    console=true
    FOR    ${i}    IN    @{icmp_type_list}
        ${command}=    Set Variable    ICMP_TYPE_${i}_NFT_CHAIN
        ${dist_name}=              Check Parameter Object Via Value on BTS    param_value=${LMP_VDU_IP}    hw_type=vDU
        ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name}[0]    4
        ${nft_tables}=             Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=${command}
        Log  Nft tables before sending packets: ${nft_tables}    console=true
        ${M51328C15_value_before}=           Get Counters Value From WebEM on BTS    counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        ${M51328C15_time_before}=            Get Counters Time From WebEM on BTS     counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        Log  The value for ${M51328C15_COUNTER} is ${M51328C15_value_before}    console=true
        Log  The time for ${M51328C15_COUNTER} is ${M51328C15_time_before}    console=true
        ${execution_time}=         Execute Traffic From TestPC  packet_type=ICMP   ip_src=${LMP_VDU_IP}
        ...                        type=${i}    pps=${M51328C15_PPS}    loop=${M51328C15_LOOP}
        ...                        vlan=${LMP_VDU_VLAN}
        Log  The execution time of sending packets is ${execution_time}    console=true
        ${nft_tables}=             Get Nft Tables    hw_type=vDU    specific_pod=oamext    command=${command}
        Log  Nft tables after sending packets: ${nft_tables}    console=true
        Log  Step 10: Checking the M51328C15 (ipRmDropPcktsRtLimICMP) counter value for type 0 (ECHO_REPLY)    console=true
        Check If Proper Counter Is Increased    WebEM_time=${M51328C15_time_before}    time_before=${execution_time}
        ...                                     counter_id=${M51328C15_COUNTER}    object=${specific_dist_name}  hw_type=vDU
        ${M51328C15_value_after}=            Get Counters Value From WebEM on BTS    counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        Log  The value for ${M51328C15_COUNTER} after sending traffic is ${M51328C15_value_after}    console=true
        ${M51328C15_equation}=     Catenate    ${M51328C15_LOOP} - ${M51328C15_STATISTICAL_ERROR} < ${M51328C15_value_after}
        ...                        < ${M51328C15_STATISTICAL_ERROR}
        Should Not Be Equal        ${M51328C15_value_before}    ${M51328C15_value_after}
        Should Be True             ${M51328C15_equation}
    END
    [Teardown]    Run Keywords
    ...           ${dist_name_tnl}=          Check Parameter Object Via Value on BTS
    ...           param_value=oam certman-server tracecontroller    hw_type=vDU    AND
    ...           ${specific_dist_name}=     resources.Get Defined DistName    dist_name=${dist_name_tnl}[0]    length=4    AND
    ...           Change Parameter on BTS    dist_name=${specific_dist_name}    param_name=icmpResponseEnabled
    ...           param_value=true    hw_type=vDU

CB010506_B_T02_Firewall_TWAMP_Rate_Limit_Counter_F1C_F1U_Mplane_vCU
    Log  Step 1, 2: Connect to vCU and checking if IPAPP object exists. If not, IPAPP is created    console=true
    ${dist_name_tnl}=          Check Parameter Object Via Value on BTS    param_value=oam certman-server
    ...                        hw_type=vCU
    ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name_tnl}[0]    3
    ${object_status}=          Check if Object Exists in Scf File
    ...                        dist_name=${specific_dist_name}
    ...                        object_name=IPAPP-1
    ...                        hw_type=vCU
    Run Keyword If             '${object_status}'=='False'
    ...                        Create Object with Single Parameter on BTS
    ...                        dist_name=${specific_dist_name}/IPAPP-1
    ...                        param_name=twampSenderMessageRate
    ...                        param_value=RATE_1
    ...                        hw_type=vCU
    ...                        ELSE    Log    Object IPAPP-1 exists. No need to create this object.    console=true
    Log  Step 3, 4, 5, 6, 7: Creating TWAMPREFLECT object if not exists    console=true
    ${object_status}=          Check if Object Exists in Scf File
    ...                        dist_name=${specific_dist_name}/IPAPP-1
    ...                        object_name=TWAMPREFLECT-1
    ...                        hw_type=vCU
    @{TWAMP_PARAMS}=           Create List    refWaitTimeout    twampReflectorEnabled    twampReflectorLocalIpAddressDN
    ...                        twampReflectorUdpEchoEnabled
    @{TWAMP_VALUES}=           Create List    900    true    ${dist_name_tnl}[0]    true
    @{DIST_NAME}=              Create List    ${specific_dist_name}/IPAPP-1/TWAMPREFLECT-1
    Run Keyword If             '${object_status}'=='False'
    ...                        Create Object with Multiple Parameters on BTS
    ...                        dist_name=@{DIST_NAME}[0]
    ...                        param_names=${TWAMP_PARAMS}
    ...                        param_values=${TWAMP_VALUES}
    ...                        hw_type=vCU
    ...                        ELSE
    ...                        Change Multiple Parameters on BTS
    ...                        dist_names=${DIST_NAME}
    ...                        param_names=${TWAMP_PARAMS}
    ...                        param_values=${TWAMP_VALUES}
    ...                        hw_type=vCU
    Log  Step 8: Setting the ipFilteringInterval parameter to 5min    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS_CU}/TNLSVC-1/PMTNLINT-1    param_name=ipFilteringInterval
    ...                        param_value=5min    hw_type=vCU
    Log  Step 9: Sending UDP packages to Mplane to TWAMP destination port    console=true
    ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name_tnl}[0]    4
    ${nft_tables}=             Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=${TWAMP_NFT_CHAIN}
    ${M51328C7_value_before}=           Get Counters Value From WebEM on BTS    counter_id=${M51328C7_COUNTER}
    ...                                                                object=${specific_dist_name}  hw_type=vCU
    ${M51328C7_time_before}=            Get Counters Time From WebEM on BTS     counter_id=${M51328C7_COUNTER}
    ...                                                                object=${specific_dist_name}  hw_type=vCU
    Log    The value for ${M51328C15_COUNTER} is ${M51328C7_value_before}    console=true
    Log    The time for ${M51328C15_COUNTER} is ${M51328C7_time_before}    console=true
    ${execution_time}=         Execute Traffic From TestPC  packet_type=UDP   ip_src=${LMP_VCU_IP}
    ...                        dport=${M51328C7_DPORT}    pps=${M51328C7_PPS}    loop=${M51328C7_LOOP}
    ...                        vlan=${LMP_VCU_VLAN}
    Log    The execution time of sending packets is ${execution_time}    console=true
    ${nft_tables}=             Get Nft Tables    hw_type=vCU    specific_pod=oamext    command=${TWAMP_NFT_CHAIN}
    Log   Step 10: Checking the M51328C7 (ipRmDropPcktsRtLimTwamp) counter    console=true
    Check If Proper Counter Is Increased    WebEM_time=${M51328C7_time_before}    time_before=${execution_time}
    ...                                     counter_id=${M51328C7_COUNTER}    object=${specific_dist_name}  hw_type=vCU
    ${M51328C7_value_after}=            Get Counters Value From WebEM on BTS    counter_id=${M51328C15_COUNTER}
    ...                                                                object=${specific_dist_name}  hw_type=vCU
    Log    The value for ${M51328C15_COUNTER} after sending traffic is ${M51328C7_value_after}    console=true
    ${M51328C7_equation}=     Catenate    0 < ${M51328C7_value_after} < ${M51328C7_STATISTICAL_ERROR}
    Should Not Be Equal        ${M51328C7_value_before}    ${M51328C7_value_after}
    Should Be True             ${M51328C7_equation}
    [Teardown]                 Delete Object on BTS    dist_name=@{DIST_NAME}[0]    hw_type=vCU

CB010506_B_T03_Firewall_Mplane_Rate_Limit_Counter_TCP_Packets_Port_443_8443_8080_vDU
    Log  Step 1, 2: Connect to vDU and checking if IPAPP object exists. If not, IPAPP is created    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1    param_name=ipFilteringInterval
    ...                        param_value=5min    hw_type=vDU
    Sleep                      11min    reason=Wait until proper interval will be set
    Log  Step 5-10: Sending the packages to ports 443, 8080 (without TLS) and 8443 (with TLS) and checking 51328C18 counter.
    FOR    ${port}    IN    @{PORTS}
        Run Keyword If    '${port}'=='8443'    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1
        ...    param_name=oamTls    param_value=forced    hw_type=vDU
        ...    ELSE    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/MPLANENW-1    param_name=oamTls
        ...                        param_value=off    hw_type=vDU
        ${M51328C18_before}    Wait For Next Counter Interval and Get Counter Timestamp with Value
        ...    counter_id=${M51328C18_COUNTER}     ip_address=${LMP_VDU_IP}    hw_type=vDU
        ${number_of_packets}    Set Variable    0
        ${number_of_iteration}    Set Variable    0
        WHILE    ${number_of_packets} < ${M51328C18_LOOP} * 0.9
            Log    Numer iteracji to ${number_of_iteration}    console=true
            Start Tcpdump For Counter    hw_type=vDU
            Execute Traffic From TestPC    packet_type=TCP    ip_src=${LMP_VDU_IP}    pps=${M51328C18_PPS}
            ...                            loop=${M51328C18_LOOP}    dport=${port}    hw_type=vDU
            Kill Tcpdump For Counter
            ${number_of_packets}=  Get Number Of Packets After Packets Flood
            ${number_of_iteration}=    Evaluate    ${number_of_iteration}+1
            Run Keyword If    ${number_of_iteration} > 10    Fail
            Log    Liczba wyslanych pakietow wynosi: ${number_of_packets}    console=true
        END
        ${no_iteration}    Set Variable    0
        ${if_counter_increased}=     Set Variable    ${False}
        WHILE    not ${if_counter_increased}
            ${M51328C18_after}    Wait For Next Counter Interval and Get Counter Timestamp with Value
            ...    counter_id=${M51328C18_COUNTER}     ip_address=${LMP_VDU_IP}    hw_type=vDU
            Log    Counter after sending: ${M51328C18_after}    console=True
            ${M51328C18_after_value}    Get Dictionary Values    ${M51328C18_after}
            ${if_counter_increased}    Evaluate
            ...     (${M51328C18_LOOP} - ${M51328C18_STATISTICAL_ERROR}) > ${M51328C18_after_value}[0] > ${M51328C18_PPS}
            ${no_iteration}=    Evaluate    ${no_iteration}+1
            Run Keyword If    ${no_iteration} > 10    Fail
        END
        ${counter_condition}    Evaluate
        ...    (${M51328C18_LOOP} - ${M51328C18_STATISTICAL_ERROR}) > ${M51328C18_after_value}[0] > ${M51328C18_PPS}
        Should Be True    ${counter_condition}
        Sleep    6min    reason=Wait until next counter will be available and will be equal to 0
    END

CB010506_B_T04_Failover_Node_Failure_F1C_vCU_vDU
    ${alarms}=    Get Active Alarms From BTS    hw_type=vDU
    Should Be Equal    ${alarms}[total]    ${0}
    Delete Specific Pod    hw_type=vDU    specific_pod=cprt
    Check if Unit Status is OnAir    hw_type=vDU
    ${alarms}=    Get Active Alarms From BTS    hw_type=vDU
    Should Be Equal    ${alarms}[total]    ${0}
    Sleep    15min    reason=Check if some alarms won't be visible after some time after reset
    ${alarms}=    Get Active Alarms From BTS    hw_type=vDU
    Should Be Equal    ${alarms}[total]    ${0}
    ${alarms}=    Get Active Alarms From BTS    hw_type=vCU
    Should Be Equal    ${alarms}[total]    ${0}
    Delete Specific Pod    hw_type=vCU    specific_pod=upue
    Check if Unit Status is OnAir    hw_type=vCU
    ${alarms}=    Get Active Alarms From BTS    hw_type=vCU
    Should Be Equal    ${alarms}[total]    ${0}
    Sleep    5min    reason=Check if some alarms won't be visible after some time after reset
    ${alarms}=    Get Active Alarms From BTS    hw_type=vCU
    Should Be Equal    ${alarms}[total]    ${0}

CB010506_C_T05_Firewall_ICMP_Rate_Limit_Counter_F1C_vDU
    Log  Step 1, 2: Connecting to vDU and changing the icmpResponseEnabled parameter to true    console=true
    ${dist_name_tnl}=          Check Parameter Object Via Value on BTS    param_value=F1-C
    ...                        hw_type=vDU
    ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name_tnl}[0]    4
    Change Parameter on BTS    dist_name=${specific_dist_name}    param_name=icmpResponseEnabled
    ...                        param_value=true    hw_type=vDU
    Log  Step 3: Setting the ipFilteringInterval parameter to 5min    console=true
    Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/TNLSVC-1/PMTNLINT-1    param_name=ipFilteringInterval
    ...                        param_value=5min    hw_type=vDU
    Log  Step 4: Sending the ICMP packages type 8 (ECHO_REPLY) and random type (3, 11, 0 or 12) to the C-Plane vDU  console=true
    ${icmp_type_int}=    Get Random ICMP Type
    Append to List    ${icmp_type_list}    8    ${icmp_type_int}
    Log  Used ICMP types: ${icmp_type_list}    console=true
    FOR    ${i}    IN    @{icmp_type_list}
        ${command}=    Set Variable    ICMP_TYPE_${i}_NFT_CHAIN
        ${dist_name}=              Check Parameter Object Via Value on BTS    param_value=${F1C_VDU}    hw_type=vDU
        ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name}[0]    4
        ${nft_tables}=             Get Nft Tables    hw_type=vDU    specific_pod=cprt    command=${command}
        Log  Nft tables before sending packets: ${nft_tables}    console=true
        ${M51328C15_value_before}=           Get Counters Value From WebEM on BTS    counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        ${M51328C15_time_before}=            Get Counters Time From WebEM on BTS     counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        Log  The value for ${M51328C15_COUNTER} is ${M51328C15_value_before}    console=true
        Log  The time for ${M51328C15_COUNTER} is ${M51328C15_time_before}    console=true
        ${execution_time}=         Execute Traffic From TestPC  packet_type=ICMP   ip_src=${LMP_VDU_IP}
        ...                        type=${i}    pps=${M51328C15_PPS}    loop=${M51328C15_LOOP}
        ...                        vlan=${F1C_VDU_VLAN}
        Log  The execution time of sending packets is ${execution_time}    console=true
        ${nft_tables}=             Get Nft Tables    hw_type=vDU    specific_pod=cprt    command=${command}
        Log  Nft tables after sending packets: ${nft_tables}    console=true
        Check If Proper Counter Is Increased    WebEM_time=${M51328C15_time_before}    time_before=${execution_time}
        ...                                     counter_id=${M51328C15_COUNTER}    object=${specific_dist_name}  hw_type=vDU
        ${M51328C15_value_after}=            Get Counters Value From WebEM on BTS    counter_id=${M51328C15_COUNTER}
        ...                                                                object=${specific_dist_name}  hw_type=vDU
        Log  The value for ${M51328C15_COUNTER} after sending traffic is ${M51328C15_value_after}    console=true
        ${M51328C15_equation}=     Catenate    ${M51328C15_LOOP} - ${M51328C15_STATISTICAL_ERROR}
        ...                        < ${M51328C15_value_after} < ${M51328C15_STATISTICAL_ERROR}
        Should Not Be Equal        ${M51328C15_value_before}    ${M51328C15_value_after}
        Should Be True             ${M51328C15_equation}
    END
    [Teardown]    Run Keywords
    ...           ${dist_name_tnl}=          Check Parameter Object Via Value on BTS    param_value=F1-C
    ...           hw_type=vDU    AND
    ...           ${specific_dist_name}=     resources.Get Defined DistName Path    ${dist_name_tnl}[0]    4    AND
    ...           Change Parameter on BTS    dist_name=${specific_dist_name}    param_name=icmpResponseEnabled
    ...           param_value=true    hw_type=vDU
