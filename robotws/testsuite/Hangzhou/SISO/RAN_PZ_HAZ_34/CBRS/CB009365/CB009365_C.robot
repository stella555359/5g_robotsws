*** Settings ***
Suite Setup          CB009365-C CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           Run keywords    CB009365-C CBRS Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=16
Test Teardown        CB009365-C CBRS Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    resources/CB009365_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB009365

Force Tags    SBTS00
...   PY36


*** Test Cases ***
[1]CB009365-C_68_data_transfer_conducted_peak_throughput_NR_40M+20M+10M_LTE_10M+10M+20M+20M_under_concurrent_mode
    [Tags]    CRT_TRUNK
    CB009365-C_68_data_transfer_conducted_peak_throughput_NR_40M+20M+10M_LTE_10M+10M+20M+20M_under_concurrent_mode

[1]CB009365-C_5_4T4R 3 NR + 4 LTE concurrent mode Frequency Selection Algorithm run more than once in one BTS TS1.2
    [Tags]    CRT_TRUNK
    CB009365-C_5_4T4R 3 NR_4 LTE concurrent mode Frequency Selection Algorithm run more than once in one BTS TS1.2

[1]CB009365-C_B_18_2x2T2R split mode LTE CBSD Registration with SAS VERSION TS2.0 is successful
    [Tags]    CRT_TRUNK
    CB009365-C_B_18_2x2T2R split mode LTE CBSD Registration with SAS VERSION TS2.0 is successful

[1]CB009365-C_A_16_Online_delete_higher_priority_CBRS_cell_in 2x2T2R split mode
    [Tags]    CRT_TRUNK    CIT_23R4
    CB009365-C_A_16_Online_delete_higher_priority_CBRS_cell_in 2x2T2R split mode

[1]CB009365-C_11_Frequency Selection Algorithm of one BTSes in 2x2T2R split mode with overlaping
    [Tags]    CRT_TRUNK    CIT_23R4
    CB009365-C_11_Frequency Selection Algorithm of one BTSes in 2x2T2R split mode with overlaping

[1]CB009365-C_64_online_add_and_delete_NR_cell_under_inter_BTS_split_mode
    [Tags]    CRT_TRUNK
    CB009365-C_64_online_add_and_delete_NR_cell_under_inter_BTS_split_mode

[1]CB009365-C_72_data_transfer_conducted_peak_throughput_NR_40M+30M+20M_LTE_20M+20M+10M+10M_under_inter_BTS_split_mode
    [Tags]    CRT_TRUNK
    CB009365-C_72_data_transfer_conducted_peak_throughput_NR_40M+30M+20M_LTE_20M+20M+10M+10M_under_inter_BTS_split_mode

[1]CB009509-B_1_SBTS_Concurrent_2T2R_Data_Transfer_Conducted_NR60+20+20+LTE10+10+10+10MHz
    [Tags]    CRT_TRUNK
    CB009509-B_1_SBTS_RFS_2T2R_Data_Transfer_Conducted_NR60+20+20+LTE10+10+10+10MHz

