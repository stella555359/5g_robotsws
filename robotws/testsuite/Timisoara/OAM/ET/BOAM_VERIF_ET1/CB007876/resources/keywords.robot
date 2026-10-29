*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    taf.transport.ssh
Library    taf.gnb.oam.coam.admin

Resource    ../../resources/admin.robot
Resource    ../../resources/fault_trigger.robot

*** Keywords ***
Trigger fault 2080 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=537985600    receiver=537989634    fault_state=1    fault_id=2080    unit_id=32

Trigger fault 2074 in RD models
    [Arguments]    ${unit_id}
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=575734336    receiver=537989634    fault_state=1    fault_id=2074    unit_id=9037

Blocking cell
    [Arguments]    ${NRCELL_R_path}
    taf.gnb.oam.coam.admin.Block    dist_name=${NRCELL_R_path}
