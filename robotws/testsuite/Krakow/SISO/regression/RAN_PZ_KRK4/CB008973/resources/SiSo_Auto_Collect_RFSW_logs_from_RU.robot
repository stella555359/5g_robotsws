*** Settings ***
Library     OperatingSystem
Library     testsuite/Krakow/SISO/regression/RAN_PZ_KRK4/CB008973/resources/RFSWLogsOperations.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/procedures/resources/robot/utilities.robot

*** Keywords ***
General SiSo Auto Collect RFSW logs from RU into BTS Snapshot
    [Arguments]    ${mandatory_logs}=${None}
    ${path_to_snapshot} =      Collect Snapshot From gNB via GUI
    Wait Till Snapshot Saved
    ${p}    split path    ${path_to_snapshot}
    move file    ${path_to_snapshot}    ${p}[0]/snap.zip
    find_rfsw_logs_in_snapshot    directory=${p}[0]/snap.zip    mandatory_logs=${mandatory_logs}
    Start and Cancel Snapshot Collection From gNB via GUI
