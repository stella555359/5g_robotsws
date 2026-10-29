*** Settings ***
Documentation
...  author:        Pawel Wisniewski
...  contact:       pawel.1.wisniewski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com
...  description:   5GC002300 + 5GC002052 + 5GC001329 TMO CVR Test Cases regression.


Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002300/resources/tests_2300.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/logs_collection.robot

Test Setup    Run Keywords
...    Test Setup for 5GC002300  AND
...    Start syslog capture

Test Teardown  run keywords
...      Stop syslog capture                 AND
...      Add Scout Data Info To Testcase     AND
...      Collect snapshot if test failed

*** Test Cases ***
[1]5GC002300_5GC002052_5GC001329_EIRP_TMO_CVR
    [1]5GC002300_5GC002052_5GC001329_EIRP_TMO_CVR
