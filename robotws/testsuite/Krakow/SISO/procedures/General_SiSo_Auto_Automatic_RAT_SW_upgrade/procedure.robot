*** Settings ***

Resource    ./keywords.robot


*** Keywords ***
General SiSo Auto Automatic RAT SW upgrade
    [Arguments]    ${config_files_paths}    ${mandatory_alarms}
    ${files_paths}    Get RU Files From    files_path=${config_files_paths}
    Make Backup RU Config Files    config_files=${files_paths}
    Change RU Config Values to NULL    config_files=${files_paths}
    Reset All gNB Radio Units from GUI
    Wait Until Keyword Succeeds     900 sec     15 sec   Verify Mandatory Alarms on gNB    ${mandatory_alarms}
    [Teardown]    Restore Backup RU Config Files    config_files=${files_paths}
