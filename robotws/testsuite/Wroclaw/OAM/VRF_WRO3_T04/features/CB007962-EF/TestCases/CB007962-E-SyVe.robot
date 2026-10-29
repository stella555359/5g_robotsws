*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../Resources/CB007962-E-SyVe_Keywords.robot

*** Keywords ***
[1]CB007962-E-SyVe_Crash_Event
    Crash Event After Killing A Process

[2]CB007962-E-SyVe_Crash_Event
    Crash Event After Killing A Process

[3]CB007962-E-SyVe_Crash_Event
    Crash Event After Killing A Process

Crash_Event_ASIM
    Crash Event After Killing A Process

Crash_event_ABIQ
    Crash Event After Killing A Process

[1]CB007962-E-SyVe_Reboot_Event
    Reboot Event After Reboot Command

[2]CB007962-E-SyVe_Reboot_Event
    Reboot Event After Reboot Command

[3]CB007962-E-SyVe_Reboot_Event
    Reboot Event After Reboot Command

Reboot_Event_ASIM
    Reboot Event After Reboot Command

Reboot_event_ABIQ
    Reboot Event After Reboot Command

BTS_records_event-log_when_bts_reboot
    Reboot Event After Reboot Command

BTS_records_event-log_when_NE3S_operation_from_NMS_to_ne3sadapt
    ${status}=    Run Keyword and Return Status    Parameter Changing Event Should Be Store In ATL Logs
    Run Keyword If    '${status}'=='False'    Parameter Changing Event Should Be Store In ATL Logs
    ...       ELSE    Pass Execution     Test passed after first try
