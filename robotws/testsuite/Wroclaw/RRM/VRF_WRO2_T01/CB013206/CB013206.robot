*** Settings ***
Documentation
...  author:        Jaroslaw Wojczyszyn
...  contact:       jaroslaw.wojczyszyn@nokia.com
...  maintainer:    jaroslaw.wojczyszyn@nokia.com
...  Description:   Test Cases for CB013206 feature. This file contain only run interface. The main code is located in
...                 resources/test_13206.robot file.
...  Topology:      CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU

Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013206/resources/tests_13206.resource
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot

Test Setup          Run Keywords
...       Start syslog capture                 AND
...       get ues    ${ues}    S25

Test Teardown       Run Keywords
...       Stop syslog capture                   AND
...       Add Scout Data Info To Testcase       AND
...       Collect snapshot if test failed

Suite Teardown   Back to default configuration


*** Test Cases ***
[1]CB013206-A#1_NonPMQAP_NX2CC_RAB_IN_SESSION_DUR
    [Tags]    nsa   24r3    to
    [1]CB013206-A#1_NonPMQAP_NX2CC_RAB_IN_SESSION_DUR
