*** Settings ***

Documentation
...    Author:   tomasz.zadworny@nokia.com
...    Maintainer:    piotr.korczynski@nokia.com

Resource  ./keywords.robot

*** Keywords ***
Automated__SiSo__Alarm__FHS_1933
    [Arguments]   ${test_logs_path}=${cfg.test_logs_path}    ${fhs_under_test_serial_number}=${FHS_UNDER_TEST_SERIAL_NUMBER}
    Common Test Setup
    ${fhs_node}=    Get BTS ID For FHS    ${fhs_under_test_serial_number}
    Add Allowed Alarm   faultId=61652, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61524, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61649, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=4655, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4654, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=10, severity=Minor                     alias=${fhs_node}
    Generate fault 1933 on FHS module by file modifications    ${fhs_under_test_serial_number}              alias=${fhs_node}
    [Teardown]    Run Keywords
    ...  Cancel fault 1933 on FHS module by file modifications              alias=${fhs_node}
    ...  AND   Remove Old Configuration Files From FHS
    ...  AND   Verify Multi BTS State
    ...  AND   Assert No Unexpected Active Alarms                           alias=${fhs_node}
    ...  AND   Assert No Unexpected Historical Alarms                       alias=${fhs_node}
    ...  AND   Common Test Teardown

Automated__SiSo__Alarm__FHS_1932
    [Arguments]   ${test_logs_path}=${cfg.test_logs_path}    ${fhs_under_test_serial_number}=${FHS_UNDER_TEST_SERIAL_NUMBER}
    Common Test Setup
    ${fhs_node}=    Get BTS ID For FHS    ${fhs_under_test_serial_number}
    Add Allowed Alarm   faultId=61652, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61524, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61649, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=4655, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4654, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=10, severity=Minor                     alias=${fhs_node}
    Generate fault 1932 on FHS module by file modifications    ${fhs_under_test_serial_number}              alias=${fhs_node}
    [Teardown]    Run Keywords
    ...  Cancel fault 1932 on FHS module by file modifications              alias=${fhs_node}
    ...  AND   Remove Old Configuration Files From FHS
    ...  AND   Verify Multi BTS State
    ...  AND   Assert No Unexpected Active Alarms                           alias=${fhs_node}
    ...  AND   Assert No Unexpected Historical Alarms                       alias=${fhs_node}
    ...  AND   Common Test Teardown

Automated__SiSo__Alarm__FHS_1936
    [Arguments]   ${test_logs_path}=${cfg.test_logs_path}    ${fhs_under_test_serial_number}=${FHS_UNDER_TEST_SERIAL_NUMBER}
    Common Test Setup
    ${fhs_node}=    Get BTS ID For FHS    ${fhs_under_test_serial_number}
    Add Allowed Alarm   faultId=61652, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61524, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61649, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=4655, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4654, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=10, severity=Minor                     alias=${fhs_node}
    Generate fault 1936 on FHS module by file modifications    ${fhs_under_test_serial_number}              alias=${fhs_node}
    [Teardown]    Run Keywords
    ...  Cancel fault 1936 on FHS module by file modifications              alias=${fhs_node}
    ...  AND   Remove Old Configuration Files From FHS
    ...  AND   Verify Multi BTS State
    ...  AND   Assert No Unexpected Active Alarms                           alias=${fhs_node}
    ...  AND   Assert No Unexpected Historical Alarms                       alias=${fhs_node}
    ...  AND   Common Test Teardown

Automated__SiSo__Alarm__FHS_1937
    [Arguments]   ${severity}=Minor    ${test_logs_path}=${cfg.test_logs_path}    ${fhs_under_test_serial_number}=${FHS_UNDER_TEST_SERIAL_NUMBER}
    Common Test Setup
    ${fhs_node}=    Get BTS ID For FHS    ${fhs_under_test_serial_number}
    Add Allowed Alarm   faultId=61652, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61524, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61649, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=4655, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4654, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=1936, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=10, severity=Minor                     alias=${fhs_node}
    Generate fault 1937 on FHS module by file modifications    ${fhs_under_test_serial_number}  severity=${severity}  alias=${fhs_node}
    [Teardown]    Run Keywords
    ...  Cancel fault 1937 on FHS module by file modifications              severity=${severity}    alias=${fhs_node}
    ...  AND   Remove Old Configuration Files From FHS
    ...  AND   Verify Multi BTS State
    ...  AND   Assert No Unexpected Active Alarms                           alias=${fhs_node}
    ...  AND   Assert No Unexpected Historical Alarms                       alias=${fhs_node}
    ...  AND   Common Test Teardown

Automated_SiSo_Fault_Management_FHS_EAC_check
    [Arguments]  ${test_logs_path}=${cfg.test_logs_path}    ${fhs_under_test_serial_number}=${FHS_UNDER_TEST_SERIAL_NUMBER}
    Common Test Setup
    ${fhs_node}=    Get BTS ID For FHS    ${fhs_under_test_serial_number}
    Add Allowed Alarm   faultId=61652, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61524, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=61649, severity=Minor                       alias=${fhs_node}
    Add Allowed Alarm   faultId=4655, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4654, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4681, severity=Warning                     alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Minor                        alias=${fhs_node}
    Add Allowed Alarm   faultId=4592, severity=Warning                     alias=${fhs_node}
    Check EAC alarms on FHS    ${fhs_under_test_serial_number}              alias=${fhs_node}
    [Teardown]    Run Keywords
    ...  Verify Multi BTS State
    ...  AND   Assert No Unexpected Active Alarms                           alias=${fhs_node}
    ...  AND   Assert No Unexpected Historical Alarms                       alias=${fhs_node}
    ...  AND   Common Test Teardown
