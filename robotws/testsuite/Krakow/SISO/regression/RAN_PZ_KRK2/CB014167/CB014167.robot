*** Settings ***
Documentation
...    Author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
...    Maintainer: Piotr Wajda, piotr.wajda@nokia.com
...    CB014167

Library           Collections
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource          testsuite/Krakow/SISO/regression/RAN_PZ_KRK2/CB014167/keywords.robot




Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...    increase_time_for_checking_radios=2100


Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Test Cases ***
[1][3.0] CB014167-A_1_Blackbox_version_verification
    Compare Version

[1][1.0] CB014167-C_6_ SFP_optical_signal_histogram
    Check Histogram

[1][1.0] CB014167-F_12_Alarm_history_in_RU_blackbox_includes_BTS_faults_and_internal_RU_faults
    Check Reset

[1][1.0] CB014167-B_5_ SFP_information_logging
    Set SFPs HW for test
    Check SFP

