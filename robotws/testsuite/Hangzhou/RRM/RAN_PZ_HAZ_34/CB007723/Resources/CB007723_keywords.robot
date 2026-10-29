*** Settings ***
Documentation
...   This is template of automation testing
...   squad group: MMW_SG1MODIFY_SCF_COMMON

Variables   ./../TestData/7723_SCF_modify.py
Variables   ./../TestData/NIDD_modify.py
Variables   ./../TestData/GP_ExtendRange_mapping.py
Resource    ./CB007723_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/l3call.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_setup_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/collect_logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py


*** Variables ***
${protocol}  udp
${data_amount}    2M
${process_num}    1
${seg_size}    1480


*** Keywords ***
Check SSB and CSI-RS from X2 log and UE attach start traffic
    [Documentation]   author: Wang liya
    ...    check SSB longbitmap in RRC Reconfiguration (NSA) IE: rach-ConfigGeneric
    [Arguments]     ${log_name}=enb_x2_cell1    ${ssb}=ffff    ${csi-rs-list}=87    ${ssb1}=0f0f    ${connection}=GNB_OAM
    ...    ${cell_index_for_attach}=11    ${csi-rs-list1}=88    ${is_btslog_required}=${True}
    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
    ${GP_act}    Get GP value from webUI
    Start X2 log capture from eNB    log_name=${log_name}
    run keyword and continue on failure    L3 call check tp    cell_id=${cell_index_for_attach}
    wait until keyword succeeds    1 min    10 sec    Connect to eNB    alias=ENB    enb_index=${0}
    ${enb_x2_log}    Stop X2 log capture from eNB    log_name=${log_name}
    cap.load_pcap_file    pcap_file=${enb_x2_log}    command_template=${PDML_CONVERT_X2AP_TEMPLATE}
    ...    tshark_path=${TSHARK_PATH}    alias=${cell_index_for_attach}
    ${rrcReconfig}    cap.filter_packets_by_expression
    ...    filter_expression=x2ap.procedureCode == 27    pcap_parser=${cell_index_for_attach}
    ${ssb-PositionsInBurst}    cap.get_field_value_by_xpath    pcap_parser=${cell_index_for_attach}
    ...    xpath=.//nr-rrc.ssb_PositionsInBurst/nr-rrc.longBitmap    attribute_name=value
    ${csi-MeasConfig}    cap.get_field_value_by_xpath    pcap_parser=${cell_index_for_attach}
    ...    xpath=.//nr-rrc.slots640    attribute_name=show
    run keyword if    ${GP_act}    run keywords
    ...    run keyword and continue on failure    should Contain    ${ssb-PositionsInBurst}[0]   ${ssb}    AND
    ...    run keyword and continue on failure    should be equal as strings    ${csi-MeasConfig}[0]   ${csi-rs-list}
    ...    ELSE    run keywords
    ...    run keyword and continue on failure    should Contain    ${ssb-PositionsInBurst}[0]   ${ssb1}    AND
    ...    run keyword and continue on failure    should be equal as strings    ${csi-MeasConfig}[0]   ${csi-rs-list1}
    Stop data transfer and detach UE
    run keyword and ignore error    COAM Save snapshot via webUI
    [Teardown]    run keyword and ignore error    Kill tcpdump on gNB

L3 call check tp
    [Documentation]   author: Wang liya
    ...    ue attach and check tp
    [Arguments]
    ...    ${ul_duration}=1800    ${target_avg_percent}=0.9    ${min_percent}=0.85
    ${list_of_cell_ids}    Create List    16395    16396    16397    16398
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${UE_TYPE}
    Log To Console    Verify attach
    power_UE.Verify attach    ue_type=${UE_TYPE}    ue_index=${1}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl     throughput=600M    duration=300
    ...    iperf_type=via_command    protocol=${protocol}   data_amount=${data_amount}    process_num=${process_num}
    ...    seg_size=${seg_size}    buffer_size=1400B
    sleep    2s
    power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul     throughput=60M    duration=300    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=${data_amount}
    ${tput_log}    power_ue.Collect Tput     ue_type=${UE_TYPE}    duration=60s   filter=L2Lo
    power_ue.Check Bi Tput    ue_type=${UE_TYPE}    log=${tput_log}    cells=${list_of_cell_ids}
    ...    dltarget_throughput=600   ultarget_throughput=60
    ...    target_avg_percent=${target_avg_percent}    actCarrierAggregation=${True}    min_percent=${min_percent}


Get GP value from webUI
    [Documentation]   author: wang liya
    ...    get GP value from 4CC webui
    ${parameter}    create list
    FOR    ${i}    IN RANGE    11     15
           ${GP_exp}    Get NIDD value via rest api   parameter=tddFrameStructure    p_index=1    dist_name=${NR_CELL_NAME_11}${i}
           ${parameter}    Combine Lists   ${parameter}     ${GP_exp}
    END
    ${GP_act}    run keyword and return status    should contain Any    ${parameter}    6Symbols    10Symbols
    [Return]   ${GP_act}


Modify Mixed and RANGE parameter via rest api and wait onair and L3call
    [Documentation]   author: wang liya
    ...    Modify mixed range and GP parameter and wait onair
    [Arguments]        ${prachConfigurationIndex}=122    ${timeout_restapi}=5 min    ${timeout_onair}=12 min
    ...    ${connection}=GNB_OAM    ${cell_index_for_attach}=11    ${GP}=6Symbols    ${log_name}=enb_x2_cell1
    @{rangeEx}    create list    1x_range    0-6.9km    0-6.9km    0-6.9km
    ${parameter}    create list
    Cloud DU connect to gnb coam via ssl
    For cell paremeter Keyword
    FOR    ${i}    IN RANGE    11     15
           ${j}   Convert To Integer    ${i}
           ${j}   evaluate    ${j}-11
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${GP}'}])]
           ${range1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='rangeExtension', value='${rangeEx}[${j}]')]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}    ${guardPeriodLength1}    ${range1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    ${idx}    create list   11
    Wait until cluster is on cell on air status    timeout=${timeout_onair}    list_cell_index=${idx}     list_cell_group_index=1
    run keyword and continue on failure    Check SSB and CSI-RS from X2 log and UE attach start traffic
    ...    cell_index_for_attach=${cell_index_for_attach}    log_name=${log_name}


Modify GP parameter via rest api and wait onair and L3call
    [Documentation]   author: wang liya
    ...    Modify mixed range and GP parameter and wait onair
    [Arguments]        ${prachConfigurationIndex}=126    ${timeout_restapi}=5 min    ${timeout_onair}=12 min
    ...    ${connection}=GNB_OAM    ${cell_index_for_attach}=11    ${GP}=10Symbols        ${log_name}=enb_x2_cell1
    Cloud DU connect to gnb coam via ssl
    For cell paremeter Keyword
    ${parameter}    create list
    FOR    ${i}    IN RANGE    11     15
           ${j}   Convert To Integer    ${i}
           ${j}   evaluate    ${j}-11
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${GP}'}])]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}    ${guardPeriodLength1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    ${idx}    create list   11
    Wait until cluster is on cell on air status    timeout=${timeout_onair}    list_cell_index=${idx}     list_cell_group_index=1
    run keyword and continue on failure    Check SSB and CSI-RS from X2 log and UE attach start traffic
    ...    cell_index_for_attach=${cell_index_for_attach}    log_name=${log_name}

Modify all B4 configuration index and L3 Call
    [Documentation]   author: wang liya
    ...    Traverse all B4 regular prachIndex values
    [Arguments]     ${guardPeriodLength}=2Symbols
    @{list_prachConfigurationIndex}    create list    136    125
     FOR  ${parameter}  IN  @{list_prachConfigurationIndex}
           Cloud DU connect to gnb coam via ssl
           For cell paremeter Keyword   prachConfigurationIndex=${parameter}
           run keyword and continue on failure    Check SSB and CSI-RS from X2 log and UE attach start traffic
     END

For cell paremeter Keyword
    [Documentation]   author: wang liya
    ...               cyclic operation cell paremeter
    [Arguments]        ${guardPeriodLength}=2Symbols    ${rangeEx}=1x_range    ${zczc}=0    ${RAPreamble}=32    ${root}=0
    ...    ${timeout_restapi}=5 min    ${timeout_onair}=12 min    ${connection}=GNB_OAM    ${prachConfigurationIndex}=114
    ...    ${cbraPreamblesPerSsb}=n32
    ${parameter}    create list
    FOR    ${i}    IN RANGE    11     15
           ${prachConfigurationIndex1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='prachConfigurationIndex', value='${prachConfigurationIndex}')]
           ${guardPeriodLength1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='tddFrameStructure', value=[{'guardPeriodLength':'${guardPeriodLength}'}])]
           ${zczc1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='zeroCorrelationZoneConfig', value='${zczc}')]
           ${range1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='rangeExtension', value='${rangeEx}')]
           ${preamble1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='totalNumberOfRAPreambles', value='${RAPreamble}')]
           ${root1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='prachRootSequenceIndex', value='${root}')]
           ${cbr1}    evaluate
           ...    [dict(dist_name='${NR_CELL_NAME_11}${i}', parameter='cbraPreamblesPerSsb', value='${cbraPreamblesPerSsb}')]
           ${parameter}    Combine Lists   ${parameter}     ${prachConfigurationIndex1}
           ...    ${guardPeriodLength1}    ${zczc1}    ${range1}    ${preamble1}    ${root1}    ${cbr1}
    END
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameter}    timeout=${timeout_restapi}    connection=${connection}
    ${idx}    create list   11
    Wait until cluster is on cell on air status    timeout=${timeout_onair}    list_cell_index=${idx}     list_cell_group_index=1

Switch pcell for attach based on cell index
    [Documentation]    Author: wang liya  from biyao
    ...                Description: if prerequisite 'actDynTrigLteNrDualConnectivity = false' satisfied, defaultLnRelGnbCellId can be used
    ...                             in eNB scf to force the SgNBAddition on specific cell
    ...                ${cell_index_for_attach} is given as the gnb cell index which is chosen for ue attach, eg, 1, 2 ...
    [Arguments]  ${cell_index_for_attach}
    Make SgNBAddition on specific cell    gnb_ps_cell_index=${cell_index_for_attach}
