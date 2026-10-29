*** Settings ***
Documentation
...   Author: liangliang.heng@nokia-sbell.com

Resource   ../Resource/Common.robot

*** Variables ***

*** Keyword ***
B_8_SA_ClassicalgNB_Streaming_PCMD_gNBDU_Uplane_Measurements_Enhancements_TimingAdvance
    log to console     check elemnet  TimingAdvance
    Load Pcap File with Filter
     ...                        pcap_file=${TCPDUMP_PATH}
     ...                        record_type=Du
     ...                        input_type=15
     ...                        filter=tcp.dstport==${dcap_server_port}
    ${initial_value_list}=    wireshark.get_field_value_by_xpath
    ...    xpath=.//nsetapx.timingAdvanceRecord/nsetapx.data_element/nsetapx.taData/nsetapx.initial
    ${initial_value_length}=     Get Length   ${initial_value_list}
    FOR   ${idx}    IN RANGE    0   ${initial_value_length}
        Should Be True   ${initial_value_list}[${idx}] % ${4} ==0
    END
    Log To Console   check value is OK

Case Setup: B_8
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    Log To Console   Case Setup: B_8

Case Teardown: B_8
    robot_common_operations.Common Case Teardown
    Log To Console   Case Teardown: B_8
    Check Extra Reset From Blackbox on Teardown   Reset_before=${RESET_REASON}
