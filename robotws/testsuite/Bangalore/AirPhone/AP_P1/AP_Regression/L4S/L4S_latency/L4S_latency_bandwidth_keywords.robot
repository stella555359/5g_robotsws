*** Settings ***
Documentation     author: Sudha V
...               contact: sudha.v@nokia.com
...               Description:

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot
Resource        ../../Carrier_Aggregation/CA_Common_Keywords.robot
Resource        ../../../Resources/robot/wts_sa.robot
Resource        ../../../Resources/robot/wts.robot
Library         ../../../Resources/Python/IperfUtilities.py    WITH NAME   iperf

*** Variables ***
${UE_IP}                         1.2.4.2
${THROUGHPUT}                    70M
${TRAFFIC_DURATION}              10000
@{ports}                         7263    7261    7265
${L4S_port}                      7267
${latency}                       80000
@{bandwidth_classic_flow}

*** Keywords ***
Register For L4S SA UEs
    [Arguments]    ${L4S_SA_UE_List}    ${pdu_id}=1
    ${is_list}    Evaluate    isinstance(${L4S_SA_UE_List}, list)
    ${L4S_SA_UE_List}    Run Keyword If    not ${is_list}    Create List    ${L4S_SA_UE_List}    ELSE    Set Variable    ${L4S_SA_UE_List}
    FOR    ${ue_id}    IN    @{L4S_SA_UE_List}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    trf_type=external
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${ue_id}    nwslice=1
    END

Register SA UE
    [Arguments]    ${SA_UE_List}    ${pdu_id}=3
    ${is_list}    Evaluate    isinstance(${SA_UE_List}, list)
    ${SA_UE_List}    Run Keyword If    not ${is_list}    Create List    ${SA_UE_List}    ELSE    Set Variable    ${SA_UE_List}
    FOR    ${ue_id}    IN    @{SA_UE_List}
        Run Keyword And Ignore Error    Check pcap files in gNB
        Ensure UE Register Is Successful    ue_id=${ue_id}
        Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    trf_type=internal
        Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${ue_id}    nwslice=1
    END

Start Classic Iperf Flows
    [Arguments]    ${BLER_activate_mode}
    ${server_procs}=    Create List
    ${client_procs}=    Create List
    FOR    ${port}    IN    @{ports}
        ${iperf_file}=    Set Variable    /tmp/iperf_${port}_${BLER_activate_mode}.log
        ${server}    ${client}=    Start Downlink Data Transfer using Iperf
        ...    ${UE_IP}    ${THROUGHPUT}    ${TRAFFIC_DURATION}    ${iperf_file}    ${port}
	    Sleep    30s
        Append To List    ${server_procs}    ${server}
        Append To List    ${client_procs}    ${client}
    END

    [Return]    ${server_procs}    ${client_procs}

Start L4S Iperf Flow
    [Documentation]    Starts L4S downlink iperf flow, collects server/client processes and extracts lowest bandwidth.
    [Arguments]    ${BLER_activate_mode}
    ${server_procs_L4S}=    Create List
    ${client_procs_L4S}=    Create List
    ${iperf_file}=    Set Variable    /tmp/iperf_${L4S_port}_${BLER_activate_mode}.log
    ${server}    ${client}=    Start Downlink L4S Data Transfer using Iperf
    ...    ${UE_IP}    ${THROUGHPUT}    ${TRAFFIC_DURATION}    ${iperf_file}    ${L4S_port}
    Sleep    30s
    Append To List    ${server_procs_L4S}    ${server}
    Append To List    ${client_procs_L4S}    ${client}

    [Return]    ${server_procs_L4S}    ${client_procs_L4S}

Validate L4S bandwidth
    [Documentation]    Compares L4S bandwidth with half of the average classic flow bandwidth
    [Arguments]    ${BLER_activate_mode}
    FOR    ${port}    IN    @{ports}
	    ${classic_iperf_file}=    Set Variable    /tmp/iperf_${port}_${BLER_activate_mode}_client.log
	    ${average_bandwidth}=    Get average bandwidth    ${classic_iperf_file}
	    Append To List    ${bandwidth_classic_flow}    ${average_bandwidth}
    END
    ${L4S_iperf_file}=    Set Variable    /tmp/iperf_${L4S_port}_${BLER_activate_mode}_client.log
    ${L4S_average_bandwidth}=    Get average bandwidth    ${L4S_iperf_file}
    ${lowest_average_classic}=    Evaluate    min(${bandwidth_classic_flow})
    ${half_lowest_classic}=    Evaluate    float(${lowest_average_classic}) / 2
    Should Be True    ${L4S_average_bandwidth} >= ${half_lowest_classic}
	...    msg=L4S bandwidth ${L4S_average_bandwidth} is less than half of classic average bandwidth ${half_lowest_classic}

Validate L4S iperf latency
    [Arguments]    ${BLER_activate_mode}
	${L4S_iperf_file}=    Set Variable    /tmp/iperf_${L4S_port}_${BLER_activate_mode}_client.log
	${status}    iperf.check_average_latency_is_reached    ${latency}    ${L4S_iperf_file}
	Run Keyword And Continue On Failure    Run keyword If    '${status}' == 'False'    FAIL    "Latency greater than 80000micro seconds"