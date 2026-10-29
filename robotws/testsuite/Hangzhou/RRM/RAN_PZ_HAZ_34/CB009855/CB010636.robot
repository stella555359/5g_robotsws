# @Time    : 2024/6/26 11:27
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @Group   : NSB MN RAN RD VRF HAZ3 5
# @File    : CB010636.robot
# @Software: PyCharm
# @Doc     : Some Description
*** Settings ***
Suite Setup         MMW5 Common Suite Setup
Suite Teardown      Run Keywords    MMW5 Common Suite Teardown
...    AND     Connect to gnb coam via ssl
...    AND     Run Keyword And Ignore Error    Modify Parameter On BTS With Activate
...    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${ENB_LNBTS_ID}/LNCEL-221    parameter=administrativeState    value=unlocked
...    AND     Sleep    15s
...    AND     Run Keyword And Ignore Error    coam.perform_delta_recommissioning
...    delta_file=${CURDIR}/${MRBTS_ID}_PWS_active.json    skip_parameter_relation_errors=True
...    should_activate=True    timeout=${600}    connection=GNB_OAM
Test Setup          MMW5 Common Case Setup
Test Teardown       MMW5 Common Case Teardown
Force Tags          CRT_TRUNK    PY36

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB009855_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py
Library    CB010636_check.py

*** Variables ***
${SCF_10636}     ${CURDIR}/CB009855W_Resources/SCF_10636.xml
@{5CC_GLOBAL_CELL_IDS}    1    2    4    5    6

*** Test Cases ***
CB009855_W_102_NR_peak_UDP_Tput_per_UE_for_3T+2F(nonDSS)_DL_CA_and_T+F_UL_CA
    [Documentation]    Author: xiaofei.zhao@nokia-sbell.com
    ...    Init Define: 2023/12/20 10:35
    COAM Commission with scf file    ${SCF_10636}    is_pdl_checking_needed=${False}    timeout=900
    Wait Until Keyword Succeeds    25min    15s    CI_commssion.Verify all cells should be Online

    Run    rm -rf ${TS_CASE_LOG_PATH}/10636/

    UE Attach With Verify Attach

    ${webservice}=  Create Dictionary
    ...  host=10.57.228.130
    ...  user=Nemuadmin
    ...  password=nemuuser
    ...  port=443
    ${l2_stream_config_2}=  Create Dictionary
    ...  nr_phy_cell_ids=50,52,55,266,271
    ...  up_sw=L2Lo
    ...  trace_type=Component
    @{l2_stream_configuration}    Create List    ${l2_stream_config_2}
    tcpdump.create tcpdump collector
    ...  name=tcpdump
    ...  options=-i eth0 udp and src 10.57.228.130 and dst 10.57.177.114 and dst port 5678
    ...  sudo_password=ute
    l2stream3.create sbts l2stream collector
    ...  name=l2stream3
    ...  webservice=${webservice}
    ...  destination_ip_addr=10.57.177.114
    ...  collector=tcpdump
    ...  l2_stream_configuration=${l2_stream_configuration}
    core.setup_collectors    names=l2stream3
    core.start_collectors    names=l2stream3

    UE Start DL Traffic    throughput=1376M    dl_time=60s    parallel=3
    Sleep    20s

    core.stop_collectors    names=l2stream3
    core.collect_collectors    names=l2stream3    target_dir=${TS_CASE_LOG_PATH}/10636
    core.teardown_collectors    names=l2stream3

    ${tp_result}    UE Check Muiti Cells UL&DL Throughput    cells=${5CC_GLOBAL_CELL_IDS}    ultarget_throughput=0
    ...    dltarget_throughput=0
    ${dl_syslog_value}    Set Variable    ${tp_result[1]}

    Sleep    200s

    ${counter_ids}    Set Variable    M55349C00030,M55349C00036
    ${counters}    coam.get_pm_counters    counter_ids=${counter_ids}    connection=GNB_OAM
    ${vol}    Get Recent Single Counter Value
    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00030']}
    ${time}    Get Recent Single Counter Value
    ...    counters=${counters['BTS']['MRBTS-${MRBTS_ID}']['NRBTS-${NRBTS_ID}']['NRCELL-4']['NHRRC']['M55349C00036']}
    ${dl_counter_value}    Evaluate    ${vol}/${time}
    
    Verify Two Throughputs Are Percent Similar    ${dl_syslog_value}    ${dl_counter_value}
    

    Run    python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py ${TS_CASE_LOG_PATH}/10636/l2stream3/tcpdump/tcpdump.pcap legacyCsv
    ${tti_csv_files}    Run    find ${TS_CASE_LOG_PATH}/10636/l2stream3/tcpdump/ -name MacPduMuxReq.csv
    @{tti_csv_files}    Split String    ${tti_csv_files}    \n
    
    ${pass_case}    Set Variable    False
    FOR    ${tti_csv_file}    IN    @{tti_csv_files}
        ${result}    get_RLC_value_from_L2LO_ttitrace_log    50    FR1_FDD    True    1F1T    ${tti_csv_file}
        log to console    ${result}[0]
        log to console    ${result}[1]
        ${dl_tti_value}    Evaluate    ${result[0]}/${result[1]}
        ${compare_syslog_tti}    Run Keyword And Return Status    Verify Two Throughputs Are Percent Similar    
        ...    ${dl_syslog_value}    ${dl_tti_value}
        ${compare_counter_tti}    Run Keyword And Return Status    Verify Two Throughputs Are Percent Similar
        ...    ${dl_counter_value}    ${dl_tti_value}
        ${pass_case}    Run Keyword If    ${compare_syslog_tti}==True and ${compare_counter_tti}==True
        ...    Set Variable    True
        ...    ELSE    Set Variable    False
        Exit For Loop If    ${compare_syslog_tti}==True and ${compare_counter_tti}==True
    END

    Should Be True    ${pass_case}==True
