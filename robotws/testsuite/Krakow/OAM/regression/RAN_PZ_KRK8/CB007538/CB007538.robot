*** Settings ***
Documentation
...                 author/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 maintainer/contact: Hubert Kowalczyk / hubert.kowalczyk@nokia.com
...                 Test suite veryfing correctness of PCMD messages implemented by feature 7538.
...
...                 This suite handles verification of the following messages:
...                 ueCallType
...                 pwrHeadroomRecord
...                 ChannelStateInfoReportTraceRecord
...                 BeamUsageTraceRecord
...
...                 Tests should be executed on an SA testline with SMAwave UE

Library             OperatingSystem
Library             DateTime
Library             taf.ue
Library             taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Library             resources/CB007538_Keywords.py
Resource            taf/rfrl/ue/robot/REAL_UE.robot
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource            testsuite/Krakow/OAM/resources/collect_logs.robot
Resource            resources/CB007538_Keywords.robot
Variables           taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

Force Tags          rf50


*** Variables ***
# robocop: disable=0920
${fault_x2_link}                No X2 link available
${diag_files}                   Diagnostic Files collected
${high_memory_consumption}      High memory consumption
${third_party}                  Failure in connection between BTS and 3rd party tool
${x2_gnb}                       Setup of X2 connectivity to gNB failed
@{CUSTOM_ALLOWED_ALARMS}
...                             ${fault_x2_link}
...                             ${diag_files}
...                             ${high_memory_consumption}
...                             ${third_party}
...                             ${x2_gnb}
${suite_directory}              /home/ute/test_repository/testsuite/Krakow/OAM/regression/RAN_PZ_KRK8/CB007538


*** Test Cases ***
# robocop: disable=0301

[1]CB007538-C_02_Indication_of_the_UE_call_type_EN_DC_mode
    Prepare environment configuration If needed    4T4R

    ${pcap_path}=    Set Variable    ${LOG_PATH}/pcmd_data.pcap
    ${json_path}=    Set Variable    ${LOG_PATH}/output_data.json
    start collecting logs with output path    output_path=pcmd_data.pcap
    Start DLUL Data Transfer And Verify Throughput
    ...    ue_index=1
    ...    duration=200
    ...    dl_throughput=180M
    ...    ul_throughput=22M
    ...    max_deviation=20%
    Stop collecting logs with output path    output_path=pcmd_data.pcap
    Convert pcap to json    path=${pcap_path}    output_path=${json_path}

    Verify presence of pcmd messages pwrheadroomrecord    path=${json_path}
    Verify presence of pcmd messages uecalltype    path=${json_path}
    Verify presence of pcmd messages channelstateinfo    path=${json_path}
    Verify presence of pcmd messages beamusagetracerecord    path=${json_path}
