*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.gnb.oam.coam.admin

Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot

*** Keywords ***

Trigger fault 8102 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=575734336    receiver=537989634    fault_state=1    fault_id=8102    unit_id=8797
    
Trigger fault 8103 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=575734336    receiver=537989634    fault_state=1    fault_id=8103    unit_id=8797

Trigger fault 8104 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=575734336    receiver=537989634    fault_state=1    fault_id=8104    unit_id=8797

Trigger fault 8105 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=575734336    receiver=537989634    fault_state=1    fault_id=8105    unit_id=8797

