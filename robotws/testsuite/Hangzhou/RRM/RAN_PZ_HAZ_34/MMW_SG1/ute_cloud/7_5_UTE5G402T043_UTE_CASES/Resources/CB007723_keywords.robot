*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1MODIFY_SCF_COMMON


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot


*** Keywords ***
Check SSB and CSI-RS from X2 log and UE attach start traffic
    [Documentation]   author: Wang liya
    ...    check SSB longbitmap in RRC Reconfiguration (NSA) IE: rach-ConfigGeneric
    [Arguments]     ${log_name}=enb_x2    ${ssb}=ffff    ${csi-rs-list}=87    ${ssb1}=0f0f
    ...    ${cell_index_for_attach}=1    ${csi-rs-list1}=88
    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
    ${GP_act}    Get GP value from webUI
    Start X2 log capture from eNB    log_name=${log_name}
    L3 call check tp    cell_id=${cell_index_for_attach}
    ${enb_x2_log}    Stop X2 log capture from eNB    log_name=${log_name}
    cap.load_pcap_file    pcap_file=${enb_x2_log}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
    ...    tshark_path=${TSHARK_PATH}    alias=pcap_ssb_csi
    ${rrcReconfig}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.procedureCode == 27    pcap_parser=pcap_ssb_csi
    ${ssb-PositionsInBurst}    cap.get_field_value_by_xpath    pcap_parser=pcap_ssb_csi
    ...    xpath=.//nr-rrc.ssb_PositionsInBurst/nr-rrc.longBitmap    attribute_name=value
    ${csi-MeasConfig}    cap.get_field_value_by_xpath    pcap_parser=pcap_ssb_csi
    ...    xpath=.//nr-rrc.slots640    attribute_name=show
    run keyword if    ${GP_act}    run keywords
    ...    run keyword and continue on failure    should Contain    ${ssb-PositionsInBurst}[0]   ${ssb}    AND
    ...    run keyword and continue on failure    should be equal as strings    ${csi-MeasConfig}[0]   ${csi-rs-list}
    ...    ELSE    run keywords
    ...    run keyword and continue on failure    should Contain    ${ssb-PositionsInBurst}[0]   ${ssb1}    AND
    ...    run keyword and continue on failure    should be equal as strings    ${csi-MeasConfig}[0]   ${csi-rs-list1}
    Stop data transfer and detach UE
    [Teardown]    run keyword and ignore error    Kill tcpdump on gNB

L3 call check tp
    [Documentation]   author: Wang liya
    ...    ue attach and check tp
    [Arguments]     ${cell_id}=1
    power_ue.UE Attach    ue_type=${UE_TYPE}
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=2800M    duration=300s
    sleep    2s
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=100M    duration=300s    iperf_type=via_command
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s   filter=L2Lo
    Check tput via power UE    cell_id=${cell_id}    exp_dl=1    exp_ul=-1    log=${tput_log}    min_percent=0.1


Get GP value from webUI
    [Documentation]   author: wang liya
    ...    get GP value from 4CC webui
    ${parameter}    create list
    FOR    ${i}    IN RANGE    1     5
           ${GP_exp}    Get NIDD value via rest api   parameter=tddFrameStructure    p_index=1    dist_name=${NR_CELL_NAME_1}${i}
           ${parameter}    Combine Lists   ${parameter}     ${GP_exp}
    END
    ${GP_act}    run keyword and return status    should contain Any    ${parameter}    6Symbols    10Symbols
    [Return]   ${GP_act}


Modify Mixed GP and RANGE parameter via rest api and wait onair and L3call
    [Documentation]   author: wang liya
    ...    Modify mixed range and GP parameter and wait onair
    [Arguments]        ${prachConfigurationIndex}=122    ${timeout_restapi}=3 min    ${timeout_onair}=6 min
    ...    ${connection}=GNB_OAM    ${cell_index_for_attach}=1    ${GP}=10Symbols    ${rangeEx}=0-6.9km
    @{GP}    create list    ${GP}    ${GP}    ${GP}    ${GP}
    @{rangeEx}    create list    ${rangeEx}    ${rangeEx}    ${rangeEx}    ${rangeEx}
    ${parameter}    create list
    FOR    ${i}    IN RANGE    1     5
           ${j}   Convert To Integer    ${i}
           ${j}   evaluate    ${j}-1
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${GP}[${j}]'}])]
           ${range1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='rangeExtension', value='${rangeEx}[${j}]')]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}    ${guardPeriodLength1}    ${range1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${timeout_onair}
    Check SSB and CSI-RS from X2 log and UE attach start traffic    cell_index_for_attach=${cell_index_for_attach}


Modify GP parameter via rest api and wait onair and L3call
    [Documentation]   author: wang liya
    ...    Modify mixed range and GP parameter and wait onair
    [Arguments]        ${prachConfigurationIndex}=126    ${timeout_restapi}=3 min    ${timeout_onair}=6 min    ${connection}=GNB_OAM
    ...    ${cell_index_for_attach}=1    ${GP}=10Symbols
    @{gp}    create list    ${GP}    ${GP}    ${GP}    ${GP}
    ${parameter}    create list
    FOR    ${i}    IN RANGE    1     5
           ${j}   Convert To Integer    ${i}
           ${j}   evaluate    ${j}-1
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${gp}[${j}]'}])]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}    ${guardPeriodLength1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${timeout_onair}
    Check SSB and CSI-RS from X2 log and UE attach start traffic    cell_index_for_attach=${cell_index_for_attach}


Modify all B4 configuration index and L3 Call
    [Documentation]   author: wang liya
    ...    Traverse all B4 regular prachIndex values
    [Arguments]     ${guardPeriodLength}=2Symbols
    @{list_prachConfigurationIndex}    create list    136    125
     FOR  ${parameter}  IN  @{list_prachConfigurationIndex}
           For cell paremeter Keyword   prachConfigurationIndex=${parameter}
           Check SSB and CSI-RS from X2 log and UE attach start traffic
     END

For cell paremeter Keyword
    [Documentation]   author: wang liya
    ...               cyclic operation cell paremeter
    [Arguments]        ${guardPeriodLength}=2Symbols    ${rangeEx}=1x_range    ${zczc}=0    ${RAPreamble}=32    ${root}=0
    ...    ${timeout_restapi}=3 min    ${timeout_onair}=3 min    ${connection}=GNB_OAM    ${prachConfigurationIndex}=114
    ${parameter}    create list
    FOR    ${i}    IN RANGE    1     5
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${guardPeriodLength}'}])]
           ${zczc1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='zeroCorrelationZoneConfig', value='${zczc}')]
           ${range1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='rangeExtension', value='${rangeEx}')]
           ${preamble1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='totalNumberOfRAPreambles', value='${RAPreamble}')]
           ${root1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_1}${i}', parameter='prachRootSequenceIndex', value='${root}')]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}
           ...    ${guardPeriodLength1}    ${zczc1}    ${range1}    ${preamble1}    ${root1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    Wait until cluster is on cell on air status    timeout=${timeout_onair}
