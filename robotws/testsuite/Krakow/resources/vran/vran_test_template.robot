*** Settings ***
Documentation    Sample tests for vran

Resource    ./resources/vran_keywords.robot

Suite Setup       Run Keywords    Import TL Variables
...               AND             Check If Hardware Components Are Available
Test Setup        Set Test Variable    ${log_dir}    ${OUTPUT DIR}/Logs/Test_Cases/${TEST NAME}/

*** Test Cases ***
[1] Test_with_attach_UE
    ute_ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    ute_ue.Attach UE   UE_1    52
    Start Streams For DL And UL Data Transmission For Specified Time For UDP
    ...    data_transfer_time=10
    ...    ul_throughput=10 Mbits/sec
    ...    dl_throughput=100 Mbits/sec
    Await DL And UL Data Transmission Finish
    Verify DL And UL Data Transmission Loss For UDP
    ute_ue.Detach UE   UE_1
    [Teardown]    Run Keywords    Collect Snasphot From vDU And CU
    ...           AND             Run Keyword And Ignore Error    ute_ue.Detach UE   UE_1

[2] Test_with_resets
    Reboot CU
    Check If Hardware Components Are Available
    Reboot vDU
    Check If Hardware Components Are Available
    Reboot RU
    Check If Hardware Components Are Available
    [Teardown]    Collect Snasphot From vDU And CU
