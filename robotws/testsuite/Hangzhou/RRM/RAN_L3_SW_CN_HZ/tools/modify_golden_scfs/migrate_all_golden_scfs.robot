*** Settings ***
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown
Resource          ../../resources/DevHZ5_resource.robot
Library           ./lib/modify_golden_scfs.py

*** Variables ***
${PATH_SPECIFIED}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L3_SW_CN_HZ/resources/configuration_file/trunk
@{PARAMS_TO_MODIFY}
...    ${EMPTY}

*** Test Cases ***
Modify SCF Files
    ${config_path}=    decide configurate files path
    ${golden_path}=    set variable if    '${PATH_SPECIFIED}'==''    ${config_path}    ${PATH_SPECIFIED}
    log    modify all scf files under ${golden_path}    level=WARN
    log to console    \n
    modify_golden_scf_files    ${golden_path}   ${PARAMS_TO_MODIFY}

*** Keywords ***
Suite Setup
    Common Suite Setup
    _Get Iphy Info

Suite Teardown
    Common Suite Teardown
    Execute Cmd On Pc    rm -rf ${SAVE LOG DIRECTORY}
