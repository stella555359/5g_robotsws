*** Settings ***

Documentation
...   This Task brings the ute airphone testline to on air

Library     OperatingSystem

Resource    ../ute_workarounds.robot
Resource    ../wts_ue.robot
Resource    ../gnb.robot
Resource    ../connect.robot


*** Tasks ***
Bring Testline to on Air Status Task
    ${dcap_alias}   connect.Connect To Test Pc Proxy For Node   node_id=0   node_type=gnb

    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    IF   ${connected}   PASS Execution    Connecto to egate was succesful

    ${wts_status}=    Run Keyword And Return Status    Bring Airphone TL To On Air Status Without Reboot
    IF    ${wts_status} == False             Bring Airphone TL To On Air Status
