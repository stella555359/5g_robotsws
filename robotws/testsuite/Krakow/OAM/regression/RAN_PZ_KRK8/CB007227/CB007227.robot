*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Test suite veryfing correctness of PCMD messages implemented by feature 7227.
...                 This suite handles specific test cases from the following subfeatures:
...                 -A, -C, -E, -F, -B

Library             taf.ue
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             resources/CB007227_Keywords.py
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            testsuite/Krakow/OAM/resources/collect_logs.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            resources/CB007227_Keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          RF50


*** Variables ***
# robocop: disable=0920
${fault_x2_link}                No X2 link available
${diag_files}                   Diagnostic Files collected
${high_memory_consumption}      High memory consumption
${third_party}                  Failure in connection between BTS and 3rd party tool
@{CUSTOM_ALLOWED_ALARMS}        ${fault_x2_link}    ${diag_files}    ${high_memory_consumption}    ${third_party}
${suite_directory}              /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CB007227


*** Test Cases ***
# robocop: disable=0301
[1][1.0] CB007227-A 01 Activation of the PCMD - gNB CU-UP Trace Session configuration
    Change pcmd reporting status in gnb configuration    status=false
    ${disabled_path}=    Set Variable    ${LOG_PATH}/pcmd_disabled.pcap
    ${disabled_json}=    Set Variable    ${LOG_PATH}/output_disabled.json
    start collecting logs with output path    output_path=pcmd_disabled.pcap
    Sleep    120s
    Stop collecting logs with output path    output_path=pcmd_disabled.pcap
    Convert pcap to json    path=${disabled_path}    output_path=${disabled_json}
    Verify lack of pcmd messages    path=${disabled_json}
    Change pcmd reporting status in gnb configuration    status=true
    Wait For Site To Be Onair
    ${enabled_path}=    Set Variable    ${LOG_PATH}/pcmd_enabled.pcap
    ${enabled_json}=    Set Variable    ${LOG_PATH}/output_enabled.json
    Start collecting logs with output path    output_path=pcmd_enabled.pcap
    Sleep    120s
    Stop collecting logs with output path    output_path=pcmd_enabled.pcap
    Convert pcap to json    path=${enabled_path}    output_path=${enabled_json}
    Verify presence of pcmd messages    path=${enabled_json}

[1][1.0] CB007227-C 05 Monitoring of the PCMD content related to CB007227-C
    ${log_pcap_path}=    Set Variable    ${LOG_PATH}/pcmd_data_C.pcap
    ${log_json_path}=    Set Variable    ${LOG_PATH}/output_data_C.json
    Start collecting logs with output path    output_path=pcmd_data_C.pcap
    Attach Ue and check 5G state    ue_alias=UE_1    scg_fails=0
    Start Data Transfer and Monitor Troughput    duration=120s    tput=500 mbits/sec
    ...    direction=dl    deviation=20%    alias=UE_1    protocol=tcp    parallel_streams=6
    Stop collecting logs with output path    output_path=pcmd_data_C.pcap
    Convert pcap to json    path=${log_pcap_path}    output_path=${log_json_path}
    Verify presence of pcmd latency messages    path=${log_json_path}

[1][1.0] CB007227-E 10 MBA activation with RAN UE ID functionality on the gNB CU-CP
    ${log_pcap_path}=    Set Variable    ${LOG_PATH}/pcmd_data_E.pcap
    ${log_json_path}=    Set Variable    ${LOG_PATH}/output_data_E.json
    start collecting logs with output path    output_path=pcmd_data_E.pcap
    Attach Ue and check 5G state    ue_alias=UE_1    scg_fails=0
    Start Data Transfer and Monitor Troughput    duration=600s    tput=500 mbits/sec
    ...    direction=dl    deviation=20%    alias=UE_1    protocol=tcp    parallel_streams=6
    Stop collecting logs with output path    output_path=pcmd_data_E.pcap
    Convert pcap to json    path=${log_pcap_path}    output_path=${log_json_path}
    Verify presence of pcmd cu vendor messages    path=${log_json_path}

[1][1.0] CB007227-F 14 Activation the monitoring of the PCMD content related to CB007227-F
    Upload commisioning with specific config    commisioning_path=${pcmd_f_tc_activation_precondition_scf_path}
    Upload commisioning with specific config    commisioning_path=${pcmd_f_tc_activation_runtime_scf_path}
    ${log_pcap_path}=    Set Variable    ${LOG_PATH}/pcmd_data_F.pcap
    ${log_json_path}=    Set Variable    ${LOG_PATH}/output_data_F.json
    ${tput_start_time}=    get_current_datetime
    Start collecting logs with output path    output_path=pcmd_data_F.pcap
    Attach Ue and check 5G state    ue_alias=UE_1    scg_fails=0
    Start Data Transfer and Monitor Troughput    duration=180s    tput=500 mbits/sec
    ...    direction=dl    deviation=20%    alias=UE_1    protocol=tcp    parallel_streams=6
    Stop collecting logs with output path    output_path=pcmd_data_F.pcap
    Convert pcap to json    path=${log_pcap_path}    output_path=${log_json_path}
    Verify presence of pcmd F messages after enabling them    path=${log_json_path}
    Wait for next pm counter collection
    ${parsed_output_dl}=    Extract data from counter    counter_name=M55319C02009
    ${json_tputs_dl}=    Get tputs from json custom
    ...    path=${log_json_path}
    ...    tp_field_name=nsetapx.sumOfPdcpSduTxDataBurstBytes
    ${filtered_pcmd_tputs_dl}=    Filter tput messages below timestamp
    ...    messages=${json_tputs_dl}
    ...    cutoff_timestamp=${tput_start_time}
    ${filtered_counter_tputs_dl}=    Filter tput messages below timestamp
    ...    messages=${parsed_output_dl}
    ...    cutoff_timestamp=${tput_start_time}
    ${sum_of_tputs_dl_pcmd}=    Sum tput messages    messages=${filtered_pcmd_tputs_dl}
    ${sum_of_tputs_dl_counters}=    Sum tput messages    messages=${filtered_counter_tputs_dl}
    Compare tput sums    tput_sum_a=${sum_of_tputs_dl_counters}    tput_sum_b=${sum_of_tputs_dl_pcmd}
    ${parsed_output_ul}=    Extract data from counter    counter_name=M55319C06009
    ${json_tputs_ul}=    Get tputs from json custom
    ...    path=${log_json_path}
    ...    tp_field_name=nsetapx.sumOfPdcpSduRxDataBurstBytes
    ${filtered_pcmd_tputs_ul}=    Filter tput messages below timestamp
    ...    messages=${json_tputs_ul}
    ...    cutoff_timestamp=${tput_start_time}
    ${filtered_counter_tputs_ul}=    Filter tput messages below timestamp
    ...    messages=${parsed_output_ul}
    ...    cutoff_timestamp=${tput_start_time}
    ${sum_of_tputs_ul_pcmd}=    Sum tput messages    messages=${filtered_pcmd_tputs_ul}
    ${sum_of_tputs_ul_counters}=    Sum tput messages    messages=${filtered_counter_tputs_ul}
    Run keyword and ignore error
    ...    Compare tput sums
    ...    tput_sum_a=${sum_of_tputs_ul_counters}
    ...    tput_sum_b=${sum_of_tputs_ul_pcmd}

[1][1.0] CB007227-B 04 Activation of PCMD measurements for U-Plane gNB-CU-UP
    Upload commisioning with specific config    commisioning_path=${pcmd_b_tc_activation_precondition_scf_path}
    Upload commisioning with specific config    commisioning_path=${pcmd_b_tc_activation_runtime_scf_path}
    ${enabled_path}=    Set Variable    ${LOG_PATH}/pcmd_data_B.pcap
    ${enabled_json}=    Set Variable    ${LOG_PATH}/pcmd_data_B.json
    ${tput_start_time}=    get_current_datetime
    Start collecting logs with output path    output_path=pcmd_data_B.pcap
    Attach Ue and check 5G state    ue_alias=UE_1    scg_fails=0
    Start Data Transfer and Monitor Troughput    duration=180s    tput=500 mbits/sec
    ...    direction=dl    deviation=20%    alias=UE_1    protocol=tcp    parallel_streams=6
    Start Data Transfer and Monitor Troughput    duration=180s    tput=25 mbits/sec
    ...    direction=ul    deviation=20%    alias=UE_1    protocol=tcp    parallel_streams=6
    Stop collecting logs with output path    output_path=pcmd_data_B.pcap
    Convert pcap to json    path=${enabled_path}    output_path=${enabled_json}
    Verify presence of pcmd B messages after enabling them    path=${enabled_json}
    Wait for next pm counter collection
    ${parsed_output_dl}=    Extract data from counter    counter_name=M55319C02009
    ${json_tputs_dl}=    Get tputs from json custom
    ...    path=${enabled_json}
    ...    tp_field_name=nsetapx.sumOfPdcpSduTxBytes
    ${filtered_pcmd_tputs_dl}=    Filter tput messages below timestamp
    ...    messages=${json_tputs_dl}
    ...    cutoff_timestamp=${tput_start_time}
    ${filtered_counter_tputs_dl}=    Filter tput messages below timestamp
    ...    messages=${parsed_output_dl}
    ...    cutoff_timestamp=${tput_start_time}
    ${sum_of_tputs_dl_pcmd}=    Sum tput messages    messages=${filtered_pcmd_tputs_dl}
    ${sum_of_tputs_dl_counters}=    Sum tput messages    messages=${filtered_counter_tputs_dl}
    Compare tput sums    tput_sum_a=${sum_of_tputs_dl_counters}    tput_sum_b=${sum_of_tputs_dl_pcmd}
    ${parsed_output_ul}=    Extract data from counter    counter_name=M55319C06009
    ${json_tputs_ul}=    Get tputs from json custom
    ...    path=${enabled_json}
    ...    tp_field_name=nsetapx.sumOfPdcpSduRxBytes
    ${filtered_pcmd_tputs_ul}=    Filter tput messages below timestamp
    ...    messages=${json_tputs_ul}
    ...    cutoff_timestamp=${tput_start_time}
    ${filtered_counter_tputs_ul}=    Filter tput messages below timestamp
    ...    messages=${parsed_output_ul}
    ...    cutoff_timestamp=${tput_start_time}
    ${sum_of_tputs_ul_pcmd}=    Sum tput messages    messages=${filtered_pcmd_tputs_ul}
    ${sum_of_tputs_ul_counters}=    Sum tput messages    messages=${filtered_counter_tputs_ul}
    Compare tput sums    tput_sum_a=${sum_of_tputs_ul_counters}    tput_sum_b=${sum_of_tputs_ul_pcmd}
