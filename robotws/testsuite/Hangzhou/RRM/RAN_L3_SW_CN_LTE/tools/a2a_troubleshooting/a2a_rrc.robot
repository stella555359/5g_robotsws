*** Settings ***
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
${SAVE LOG DIRECTORY}    C:\\N-20W5PF3FM1AK-Data\\y165zhan\\Downloads\\LTE843_27_secondary_with_primary_notification
${a2a_ini_file}    ${SAVE LOG DIRECTORY}${/}a2a.ini

*** Test Cases ***
a2a check
    Log To Console    ${SAVE LOG DIRECTORY}
    Check Logs With Au2anlysis    ${a2a_ini_file}    p
