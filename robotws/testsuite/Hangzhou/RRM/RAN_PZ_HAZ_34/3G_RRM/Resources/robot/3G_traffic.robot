# @Time    : 2025/11/3 9:48
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : 3G_traffic.robot
# @Software: PyCharm
# @Doc     : 3G Traffic Related Keywords
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: 3G Traffic Related Keywords

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/traffic.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/ue.robot

*** Keywords ***
UE Attach And Verify 3G With DL TCP Traffic
    [Documentation]    Author:chun.li@nokia-sbell.com
    ...    Attach UE and verify 3G attach success
    [Arguments]    ${ue_index}=0    ${parallel}=2
    ${ue_type}    translate power ue type from testline    ${ue_index}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    ${3Grach_ed}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
    Verify 3G Attach by ADB Command    ${ue_index}
    UE Start DL TCP Traffic    ue_index=${ue_index}    parallel=${parallel}
    Sleep    30s
    [Teardown]    Run Keywords
    ...    Run Keyword And Ignore Error    Close the iperf3 process on UEPC    AND
    ...    Run Keyword And Ignore Error    Close the iperf3 process on APPserver    AND
    ...    power_ue.UE Detach   ue_index=${ue_index}    ue_type=${ue_type}