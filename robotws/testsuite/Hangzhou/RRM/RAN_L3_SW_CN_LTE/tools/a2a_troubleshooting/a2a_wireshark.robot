*** Settings ***
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
${SAVE LOG DIRECTORY}    C:\\temp\\0417\\CB008909-SR-A-B8_ET_42_01_Counters_and_PCMD_check
${a2a_ini_file}    ${SAVE LOG DIRECTORY}${/}a2a.ini

*** Test Cases ***
a2a check
    Log To Console    ${SAVE LOG DIRECTORY}
    recreate_wireshark_txt_files    ${a2a_ini_file}
    Check Logs With Au2anlysis    ${a2a_ini_file}    w
