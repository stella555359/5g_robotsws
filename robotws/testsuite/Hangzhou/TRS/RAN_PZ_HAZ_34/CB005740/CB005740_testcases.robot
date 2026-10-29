*** Settings ***
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_common_keywords.robot
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB005740/Resources/CB005740_variables.py

Documentation
...   author: Yu lu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

Force Tags    5G_TRS
...    PY36

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}

*** Variables ***
@{file_name_original}   ptp_5740_original_port3.pcap   ptp_5740_original_port4.pcap   ptp_5740_original_port1.pcap   ptp_5740_original_port2.pcap

@{file_name_two}  ptp_5740_two_port3.pcap   ptp_5740_two_port4.pcap   ptp_5740_two_port1.pcap  ptp_5740_two_port2.pcap

@{file_name_four}  ptp_5740_four_port3.pcap  ptp_5740_four_port4.pcap   ptp_5740_four_port1.pcap   ptp_5740_four_port2.pcap

${data_transfer_dl}       900M
${data_transfer_ul}      200M
${Expected_Throughput_DL}      1
${Expected_Throughput_UL}      0.05


*** Test Cases ***
[1]CB005740_C_001_Upgrade to new SW version supporting sync resiliency without activating resiliency
    [Tags]  CB005740    CIT_22R4    CIT_TRUNK    CDRT_22R4
    [Setup]  CB005740 Case Setup
    BTS_site_reset for 5740
    Check ClockState and MaterUsed      ok_num_expect=${1}   index_begin=${0}   index_end=${4}
    Check complete PTP messages for All ports       file_name=${file_name_original}
    Configuration topMasterList    topMasterList_parameter=${CB007963_TOPMASTER_LIST_FIRST}
    Check ClockState and MaterUsed      ok_num_expect=${2}   index_begin=${0}   index_end=${2}
    Check Two Structure Log in Wireshark Log for SSM and PTP    file_name=${file_name_two}
    Check loss sync
    Configuration topMasterList    topMasterList_parameter=${CB007963_TOPMASTER_LIST_ALL_1}
    Check ClockState and MaterUsed      ok_num_expect=${4}    index_begin=${0}   index_end=${4}
    Check Four Structure Log in Wireshark Log for SSM and PTP   file_name=${file_name_four}
    [Teardown]  CB005740 Case Teardown

[1]CB005740_C_002_Parameter ruECpriPortNumber of ToP Master_1 configured to same or different vs set-by-system parameter topSlavePortNumbe
    [Tags]  CB005740    CIT_22R4    CIT_TRUNK    CDRT_22R4
    [Setup]  CB005740 Case Setup
    ${PortNumber_used}    ${PortNumber_notused}     Set ruECpriPortNumber from topMasterUsed is used
    Check status and port used       PortNumber=${PortNumber_used}     is_or_not_used=used
    Set ruECpriPortNumber from topMasterUsed is not used      PortNumber_notused=${PortNumber_notused}
    Check status and port used       PortNumber=${PortNumber_notused}     is_or_not_used=used
    [Teardown]  CB005740 Case Teardown

[1]CB005740_C_005_Other ToP Master becomes better than still usable current best ToP Master
    [Tags]  CB005740   CIT_22R4    CIT_TRUNK    CDRT_22R4
    [Setup]  CB005740 Case Setup
    Add one element and set value     start_num=${0}     end_num=${1}
    sleep    10min
    Check status and port used for 5740    PortNumber=3     is_or_not_used=used    ClockState=MASTER_CLOCK_OK    index_num=${0}
    Run Keyword And Continue On Failure     Start DLUL traffic and Caculate Tput when change Priority    data_transfer_dl=${data_transfer_dl}
    ...   data_transfer_ul=${data_transfer_ul}
    ...   Expected_Throughput_DL=${Expected_Throughput_DL}
    ...   Expected_Throughput_UL=${Expected_Throughput_UL}
    Check status and port used for 5740    PortNumber=4     is_or_not_used=used    ClockState=MASTER_CLOCK_OK    index_num=${1}
    [Teardown]  CB005740 Case Teardown

[1]CB005740_C_006_UE_traffic_test_without_sync_resiliency_activated_when_sync_master_switch
    [Tags]  CB005740    CIT_22R4    CIT_TRUNK    CDRT_22R4
    [Setup]  CB005740 Case Setup
    Configuration topMasterList    topMasterList_parameter=${CB007963_TOPMASTER_LIST_ALL_6}
    Run Keyword And Continue On Failure     Start DLUL traffic and Caculate Tput when change TPS            data_transfer_dl=${data_transfer_dl}
    ...   data_transfer_ul=${data_transfer_ul}
    ...   Expected_Throughput_DL=${Expected_Throughput_DL}
    ...   Expected_Throughput_UL=${Expected_Throughput_UL}
    Run Keyword And Continue On Failure    Check alarms when change TPS switch for 5740
    Recover by enable port and check alarms for 5740
    Sleep    10min
    Check ClockState and MaterUsed      ok_num_expect=${4}   index_begin=${0}   index_end=${4}
    Check status and port used for 5740    PortNumber=3     is_or_not_used=used    ClockState=MASTER_CLOCK_OK   index_num=${2}
    [Teardown]  CB005740 Case Teardown
