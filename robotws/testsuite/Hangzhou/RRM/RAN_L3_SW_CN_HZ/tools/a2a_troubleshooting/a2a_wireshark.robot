*** Settings ***
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
${SAVE LOG DIRECTORY}    C:\\TA\\786
${a2a_ini_file}    C:\\TA\\robotws\\testsuite\\Hangzhou\\RRM\\RAN_L3_SW_CN_HZ\\new_feature\\zy\\5GC000786-F\\a2a_F001\\a2a.ini
${RECREATE_WIRESHARK_FLAG}    ${True}

*** Test Cases ***
a2a check
    Log To Console    \n${SAVE LOG DIRECTORY}
    recreate_wireshark_txt_files    ${a2a_ini_file}
    _Check Logs With Au2anlysis    ${a2a_ini_file}    w
