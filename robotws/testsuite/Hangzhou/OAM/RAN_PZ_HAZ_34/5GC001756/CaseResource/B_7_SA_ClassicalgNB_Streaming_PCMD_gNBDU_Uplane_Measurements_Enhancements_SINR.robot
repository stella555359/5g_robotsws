*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com
...   to define the feature 5GC001756_B_7_SA
...   contact: ruiyu.han@nokia-sbell.com   menghua.luo@nokia-sbell.com

Resource   ../Resource/Common.robot


*** Keyword ***
B_7_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_SINR
    log to console     check elemnet  SINR_SUlSchedulingTraceRecord
    Load Pcap File with Filter
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        record_type=Du
     ...                        input_type=3
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${sumOfSinrSamples_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.avgSinr_element/nsetapx.sumOfSinrSamples
    ${numOfSinrSamples_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.ulSchedulingRecord/nsetapx.data_element/nsetapx.avgSinr_element/nsetapx.numOfSinrSamples
    ${sumOfSinrSamples_length}=     Get Length   ${sumOfSinrSamples_value_list}
    ${numOfSinrSamples_length}=     Get Length   ${numOfSinrSamples_value_list}
    Should Be True   ${sumOfSinrSamples_length} == ${numOfSinrSamples_length}
    FOR   ${idx}    IN RANGE    0   ${sumOfSinrSamples_length}
        ${numOfSinrSamples}   Set Variable   ${numOfSinrSamples_value_list}[${idx}]
        ${sumOfSinrSamples}   Set Variable   ${sumOfSinrSamples_value_list}[${idx}]
        ${min_sumOfSinrSamples}   Evaluate   ${numOfSinrSamples}* ${-10}
        ${max_sumOfSinrSamples}   Evaluate   ${numOfSinrSamples}* ${40}
        Should Be True   ${numOfSinrSamples} >0 or ${numOfSinrSamples}==0
        Should Be True   ${sumOfSinrSamples} > ${min_sumOfSinrSamples} or ${sumOfSinrSamples} == ${min_sumOfSinrSamples}
        Should Be True   ${sumOfSinrSamples} < ${max_sumOfSinrSamples} or ${sumOfSinrSamples} == ${max_sumOfSinrSamples}
    END
    Log To Console   check value is OK

Case Setup: B_7
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: B_7

Case Teardown: B_7
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: B_7
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
    CI_interface.Common Case Teardown
