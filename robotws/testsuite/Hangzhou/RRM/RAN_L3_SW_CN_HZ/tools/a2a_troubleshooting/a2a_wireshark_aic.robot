*** Settings ***
Resource          ../../resources_aic/DevHZ5_resource_aic.robot

*** Variables ***
${SAVE LOG DIRECTORY}    C:\\TA
${a2a_ini_file}    C:\\TA\\robotws\\testsuite\\Hangzhou\\RRM\\RAN_L3_SW_CN_HZ\\new_feature\\a2a_001\\a2a.ini
${RECREATE_WIRESHARK_FLAG}    ${True}

*** Test Cases ***
a2a check
    Log To Console    \n${SAVE LOG DIRECTORY}
    recreate_wireshark_txt_files    ${a2a_ini_file}
    Check Logs With Au2anlysis Aic    ${a2a_ini_file}    w
