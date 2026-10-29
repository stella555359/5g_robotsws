*** Settings ***
Documentation
...  copyright: Nokia Networks
...  author: Jakub Szymczakiewicz, Sebastian Lupkowski
...  contact: I_EXT_5G_SISO_CRT_GMS <I_EXT_5G_SISO_CRT@internal.nsn.com>

Library      testsuite.Wroclaw.SyVe.RRM.CB012667.Res12667
Resource  taf/rfrl/procedures/cloud/setups_teardowns/setups_teardowns.robot


Test Setup      Cloud Test Setup      collect_syslog=${False}    collect_snapshot=${False}
Test Teardown   Cloud Test Teardown
Suite Teardown  Cloud Suite Teardown


*** Test Cases ***
CB012667_SR_A_02_RU_reset_duration_KPI51a_with_CB012667_for_benchmark
    Given Environment is prepared
    And Execution of 10 rmod restart attempts before activation is performed
    When Ecpri delay measurement is activated
    And Execution of 10 rmod restart attempts after activation is performed
    Then Time improvement is checked
    And Errors on bts are not present

CB012667_SR_A_04_Site_reset_duration_KPI1a_with_CB012667_for_benchmark
    Given Environment is prepared
    And Execution of 10 vdu restart attempts before activation is performed
    When Ecpri delay measurement is activated
    And Execution of 10 vdu restart attempts after activation is performed
    Then Time improvement is checked
    And Errors on bts are not present
