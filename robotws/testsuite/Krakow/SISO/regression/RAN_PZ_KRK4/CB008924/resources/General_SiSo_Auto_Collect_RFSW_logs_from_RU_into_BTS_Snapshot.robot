*** Settings ***

Library     OperatingSystem
Library     snapshot_analyzer.py
Resource    taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
General SiSo Auto Collect RFSW logs from RU into BTS Snapshot
    [Arguments]    ${mandatory_logs}=${None}
    ${path_to_snapshot} =      Collect Snapshot From gNB via GUI
    Wait Till Snapshot Saved
    ${p}    split path    ${path_to_snapshot}
    move file    ${path_to_snapshot}    ${p}[0]/snap.zip
    snapshot_analyzer.Find Mandatory RFSW Logs in Snapshot    directory=${p}[0]/snap.zip    mandatory_logs=${mandatory_logs}
