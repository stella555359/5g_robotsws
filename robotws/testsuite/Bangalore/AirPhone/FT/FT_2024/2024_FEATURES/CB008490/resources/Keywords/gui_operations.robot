# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This contains the keywords which are needed to fetch the files or data from GUI WEBEM.
...              :author Shilpa V Swamy

Library           taf.selenium.gnb.oam.coam.classical    WITH NAME       selenium_coam
Library           OperatingSystem

*** Variables ***
${WEBUI_URL}     https://192.168.255.1
${WEBUI_NAME}    Nemuadmin
${WEBUI_PWD}     nemuuser
${files}         All log files
${snapshot}      gNB_snapshot
${GUI_Timeout}    10

*** Keywords ***
Collect snapshot from GUI
    [Arguments]
    [Documentation]    This keyword is used to collect the Snapshot from GUI
    ...                Modified Date: 08-April-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    ${path}    Join Path    ${OUTPUT_DIR}    ${snapshot}
    Create Directory    ${path}
    selenium_coam.enable_virtual_display    width=1920     height=1280
    selenium_coam.login    url=${WEBUI_URL}   username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ...    screenshot_dir=${OUTPUT_DIR}    download_dir=${path}     alias=sel_coam
    selenium_coam.disable_message_box    timeout=${GUI_Timeout}    coam=sel_coam
    ${status}    Run Keyword    selenium_coam.start_up_view_window_exists    timeout=${GUI_Timeout}    coam=sel_coam
    Run Keyword If  '${status}'=='True'   selenium_coam.close_start_up_view_window    timeout=${GUI_Timeout}    coam=sel_coam
    selenium_coam.snapshot_collection_settings   coverage=${files}    save_location=Local    coam=sel_coam
    ${file_path}    selenium_coam.collect_snapshot    coam=sel_coam
    Log To Console    ${file_path}
    Teardown the GUI page

Teardown the GUI page
    [Documentation]    This keyword is used to close the GUI browser
    ...                Modified Date: 29-March-2021
    ...                Last Modified by: shilpa.v_swamy@nokia.com
    Run Keyword and Ignore Error    Run Keywords    selenium_coam.logout    click_timeout=${GUI_Timeout}
    ...    coam=sel_coam    AND    selenium_coam.close_browser    coam=sel_coam    AND    selenium_coam.disable_virtual_display
