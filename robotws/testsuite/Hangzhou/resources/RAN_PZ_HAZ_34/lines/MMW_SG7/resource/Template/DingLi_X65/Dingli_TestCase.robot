*** Settings ***
Suite Setup    Setup BTS env and set keyword prority
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs

Documentation    Suite description
...   author:      Flora Du
...   contact:     Flora.du@nokia-sbell.com
...   squad group: MMW_SG7
...   Feature:     XXXXXXXX

Force Tags    release-SBTS23R3    testline-7_5_UTE5G402T2452    UE_TYPE-DingLi_1UE

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG7/resource/UEs/Dingli_common_keywords.robot

*** Variables ***
${if_commissioning}    False
${peak_ul}    1000000
${peak_dl}    1000M


*** Test Cases ***
DingLi_TestCase
    Set test variable    ${TS_CASE_LOG_PATH}     ${TEST_LOG_DIR}
    DingLi_Client.UE Prepare
    DingLi_Client.UE Attach
    DingLi_Client.Check PCI In Attach Info    expect_pci=700
    DingLi UE Start Trf And Check Tput    ul_throughput=58000    dl_throughput=430M    expect_ul_tput=56    expect_dl_tput=419
    ...    target_avg_percent=0.98    duration=180

