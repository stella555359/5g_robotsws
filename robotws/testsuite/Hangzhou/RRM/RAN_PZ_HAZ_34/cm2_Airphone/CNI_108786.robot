*** Settings ***
Documentation     author: Chen Yin
...               contact: yin.1.chen@nokia-sbell.com
...               squad group: SG_02

Resource          testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002029-A/Resources/5GC002029_A_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/SG2_Common_setup_teardown.robot
Resource          testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/cm2_Airphone/Resource/CNI_108786_common_resource.robot

Suite Setup    SG2_Common_setup_teardown.Common Suite setup    if_commissioning=${False}
Suite Teardown       robot_common_operations.Common Suite Teardown

*** Test Cases ***
[1][1.0] CNI_108786_A_09_Dynamic Transform Precoder Switching in Presence of Adapative Number of SRS Ports For TDD cell with 108786 enable
    [Setup]    CNI108786 Common Case setup
    COAM Wait for gnb ready and cell setup    timeout=20 min
    [Teardown]    Run keyword and ignore error    SG2_Common_setup_teardown.Common Case teardown    need_Btslog=${True}