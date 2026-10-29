*** Settings ***
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
${SAVE LOG DIRECTORY}    C:\\Temp\\reduce_wireshark_a2a\\CIT\\LTE5510-A-i_01_01_MeNB_initiated_SgNB_Modification
${a2a_ini_file}    ${CURDIR}${/}a2a.ini

*** Test Cases ***
a2a check
    Log To Console    ${SAVE LOG DIRECTORY}
    Check Logs With Au2anlysis    ${a2a_ini_file}    p
