*** Settings ***

Resource    taf/rfrl/bts/robot/gnb.robot
Resource    ./keywords.robot

*** Keywords ***
eCPRI RU Logs Collection
    ${path_to_snapshot} =      Collect Snapshot From gNB via GUI
    Wait Till Snapshot Saved
    Set Test Variable   ${path_to_snapshot}
    Find Mandatory Files in gNB Snapshot    directory=${path_to_snapshot}
    Start and Cancel Snapshot Collection From gNB via GUI
    ${path_to_snapshot} =      Collect Snapshot From gNB via GUI
    Wait Till Snapshot Saved
    Set Test Variable   ${path_to_snapshot}
    Find Mandatory Files in gNB Snapshot    directory=${path_to_snapshot}
