*** Settings ***
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB007963/Resources/CB007963_common_keywords.robot
Variables    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/CB007963/Resources/CB007963_variables.py

Documentation
...   author: Yu lu
...   contact: lu.1.yu@nokia-sbell.com
...   squad group: SG_02

Force Tags    5G_TRS
...    PY36

Suite Setup     SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${True}


*** Variables ***
${data_transfer_dl}       900M
${data_transfer_ul}      80M
${Expected_Throughput_DL}      800
${Expected_Throughput_UL}      70


*** Test Cases ***
[1]CB007963-SR-G_010_Parameter ruECpriPortNumber of ToP Master_1 configured to value which is out of scope
    [Setup]  CB007963 Case Setup
    Check PDL verification
    [Teardown]  CB007963 Case Teardown

[1]CB007963-SR-G_003_Activate resiliency by configuring a ToP Master_2
    [Setup]  CB007963 Case Setup
    Configuration paramter    param_data=${PARAM_7963_STRUCTURE1[2]}    index_num=${0}
    Check TOPP_R    PortNumber_used=${1}
    Configuration paramter    param_data=${PARAM_7963_STRUCTURE2[2]}    index_num=${0}
    Check TOPP_R    PortNumber_used=${2}
    Configuration two topMasterList
    Check ClockState and MaterUsed for 7963      ok_num_expect=${2}   index_begin=${0}   index_end=${2}
    Check Structure count    expect_count=${2}
    [Teardown]  CB007963 Case Teardown

[1]CB007963-SR-G_006_Recovery from failure of current best ToP Master with available second-best ToP Master
    [Setup]  CB007963 Case Setup
    Configuration two topMasterList
    Start DLUL traffic and Caculate Tput when change TPS switch        data_transfer_dl=${data_transfer_dl}
    ...   data_transfer_ul=${data_transfer_ul}
    ...   Expected_Throughput_DL=${Expected_Throughput_DL}
    ...   Expected_Throughput_UL=${Expected_Throughput_UL}
    [Teardown]  CB007963 Case Teardown

[1]CB007963-SR-G_005_Recovery from failure of current best ToP Master followed by failure of second-best ToP Master
    [Setup]  CB007963 Case Setup
    Configuration two topMasterList
    Run Keyword And Continue On Failure    Check alarms when change TPS switch
    Recover by enable port and check alarms
    Sleep    10min
    Check ClockState and MaterUsed for 7963      ok_num_expect=${2}   index_begin=${0}   index_end=${2}
    Check status and port used for 7963    PortNumber=${2}     is_or_not_used=used    ClockState=MASTER_CLOCK_OK   index_num=${1}
    [Teardown]  CB007963 Case Teardown

[1]CB007963-SR-G_007_Other ToP Master becomes better than still usable current best ToP Master
    [Setup]  CB007963 Case Setup
    Configuration two topMasterList
    Sleep    10min
    Check status and port used for 7963    PortNumber=${2}     is_or_not_used=used    ClockState=MASTER_CLOCK_OK    index_num=${1}
    Start DLUL traffic and Caculate Tput when change localPriority        data_transfer_dl=${data_transfer_dl}
    ...   data_transfer_ul=${data_transfer_ul}
    ...   Expected_Throughput_DL=${Expected_Throughput_DL}
    ...   Expected_Throughput_UL=${Expected_Throughput_UL}
    Check status and port used for 7963    PortNumber=${1}     is_or_not_used=used    ClockState=MASTER_CLOCK_OK    index_num=${0}
    [Teardown]  CB007963 Case Teardown
