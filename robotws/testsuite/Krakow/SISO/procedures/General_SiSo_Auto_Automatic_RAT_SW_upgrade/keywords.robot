*** Settings ***

Library     ./keywords.py
Resource    taf/rfrl/bts/robot/gnb.robot


*** Keywords ***
Get RU Files From
    [Arguments]    ${files_path}
    ${files_paths}    get_ru_files_from_path    directions=${files_path}
    [Return]    ${files_paths}

Make Backup RU Config Files
    [Arguments]    ${config_files}
    make_backup_all_files   files_paths=${config_files}

Change RU Config Values to NULL
    [Arguments]    ${config_files}
    change_values_of_all_rus_config_to_null    files_paths=${config_files}

Restore Backup RU Config Files
    [Arguments]    ${config_files}
    restore_all_backup_files    files_paths=@{config_files}
    Reset All gNB Radio Units from GUI
    Wait Until Keyword Succeeds     8 min     30 sec   Verify gNB is onAir
