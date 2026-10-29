*** Settings ***
Documentation
...         author: shushu.huang
...         contact: shushu.huang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CB013388 KPI

Suite Setup
Suite Teardown
Test Timeout    1000 min

Resource    ./Resources/CB013388_Common_Keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables   ./Resources/TL905_Configration.py




*** Test Cases ***
[1]CB013388_Multi-UES_AND_KPI_Testing_in_loops
    Run Keyword and Continue on Failure    Multi-UES KPI testing 10 times
    Step1: Prepare MultiUE And Attach
    Step2: Start UDP Traffic
    set CB01338 to True
    Step3: Check TP for TDD
    Step2: MultiUE Detach
    Run Keyword and Continue on Failure    Multi-UES KPI testing 10 times
    Step1: Prepare MultiUE And Attach
    Step2: Start UDP Traffic
    set CB01338 to False
    Step3: Check TP for TDD
    Step2: MultiUE Detach
    Run Keyword and Continue on Failure    Multi-UES KPI testing 10 times

[1]CB013388_Multi-UES_AND_KPI_Testing
    [Setup]    #Test Case setup
    [Timeout]    30min
    Set PA prepare for cell1
    Run Keyword and Continue on Failure    UE attach to cell1 1 times
    Step1: Prepare MultiUE And Attach
    Set PA prepare handover to cell2
    Step2: MultiUE Detach
    Run Keyword and Continue on Failure    UE attach to cell2 1 times
    Step1: Prepare MultiUE And Attach
    Step2: Start UDP Traffic
    Step3: Check TP for TDD
    Run Keyword and Continue on Failure    UE handover 6 times
    #Step4: Detach UE
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic And Detach UE



*** Keywords ***
Multi-UES KPI testing ${num} times
    log to console    Multi-UES KPI testing ${num} times
    FOR   ${i}   IN RANGE   ${num}
        Set PA prepare for cell1
        Step1: Prepare MultiUE And Attach
        Set PA prepare handover to cell2
        Step2: MultiUE Detach
        Step1: Prepare MultiUE And Attach
        Step2: Start UDP Traffic
        Step3: Check TP for TDD
        Run Keyword and Continue on Failure    UE handover 10 times
    END
    [teardown]    Run Keyword And Ignore error    Stop Traffic And Detach UE
