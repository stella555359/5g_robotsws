*** Settings ***
Documentation
...    Author: Radu Catlan/Cristina Nicolae
...    Maintainer: Radu Catlan (radu-vasile.catlan@nokia.com)/Cristina Nicolae (cristina.nicolae@nokia.com)
...    Group in charge: BTS_OAM_CU
...    References: DOORS
...    Feature Description: CB007188-5G-J
...    Execution command:  robot -L TRACE -b debug.log general.robot

Resource   ./resources/CB007188-5G-J.robot
Resource   ./resources/xpath_7188-5G-J.robot
Suite Teardown  Run Keyword And Ignore Error  Logout vDU
Force Tags      CRT      requires-ipv4    5G_RAN    CLOUD_5G_AIC    product-vDU

*** Test Cases ***
[1]7_CB007188-5G-J_Trigger_fault_id_ 1936_rise_in_vDU
    [Tags]  CRT
    Trigger 1937&1936

[1]3_CB007188-5G-J_Check _alarm _with_fault_id_ 1937_rise_with_coresponding _alarm_reporting_in_vDU_WebEM
    [Tags]  CRT
    Check active 1937&1936 in fault history log
    Login vDU
    Check fault 1937 is raised in WebEM

[1]4_CB007188-5G-J_Check _active_alarm_7116_with_fault1937_is_cleared_if_condition_met
    [Tags]  CRT
    Deactivate 1937&1936
    Check fault 1937 is cleared in WebEM

[1]8_CB007188-5G-J_check _clearing_fault_id_ 1936_in_vDU
    [Tags]  CRT
    Check cleared 1937&1936 in fault history log



#    Check alarms with faults 1937&1936
#    [Tags]  CRT
#    Trigger 1937&1936
#    Check active 1937&1936 in fault history log
#    Login vDU
#    Check fault 1937 is raised in WebEM
#    Deactivate 1937&1936
#    Check fault 1937 is cleared in WebEM
#    Check cleared 1937&1936 in fault history log
