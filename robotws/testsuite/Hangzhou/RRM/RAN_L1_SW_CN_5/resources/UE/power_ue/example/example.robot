*** Settings ***
Documentation     Example case for using power_ue.
...               Please do not modify the file without notification to author
...               Author: Civen Chen
...               Contact: civen.chen@nokia-sbell.com
Resource          ../power_ue.robot    # import power_ue interfaces.

*** Test Cases ***
Power UE L3 Call
    [Setup]    UE setup
    ${5Grach_ed}    power_ue.UE Attach    ue_type=qct_dx50
    Run Keyword And Ignore Error    power_ue.Verify attach    ue_type=qct_dx50    5Grach_ed=${5Grach_ed}    4G_check=False
    Run Keyword And Ignore Error    UL traffic
    Run Keyword And Ignore Error    DL traffic
    [Teardown]    UE teardown

*** Keywords ***
UE setup
    power_ue.Prepare UE    ue_type=qct_dx50

UE teardown
    power_ue.UE Detach    ue_type=qct_dx50

UL traffic
    Run Keyword And Ignore Error    power_ue.Start traffic    ue_type=qct_dx50    direction=ul    throughput=10M    duration=10
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=qct_dx50    direction=ul    throughput=8
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=qct_dx50    direction=ul

DL traffic
    Run Keyword And Ignore Error    power_ue.Start traffic    ue_type=qct_dx50    direction=dl    throughput=10M    duration=10
    Run Keyword And Ignore Error    power_ue.Check throughput    ue_type=qct_dx50    direction=dl    throughput=8
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=qct_dx50    direction=dl
