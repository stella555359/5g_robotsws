*** Settings ***
Documentation       Test suite for CB012611 case 5 ABIO reset when ABIO with one loki failed mode
...                 Author: YuaGao
...                 Contact: yuan.1.gao@nokia-sbell.com
Variables         ../test_line_specific/SBTS_SYVE_1910/My_Variables.py
Resource          ../test_resources/CM/CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf.robot

*** Test Cases ***
CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Setup]    Common Test Setup SBTS    SetValidatePlanAgainstDetectedHW=${FALSE}
    CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Teardown]    Common Test Teardown SBTS
