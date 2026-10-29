*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in user library taf.ul.hanging_resources.

Library    ../python/robot_json_helper.py    WITH NAME   json_helper_py
Library    taf.ul.hanging_resources
Library    OperatingSystem
Library    Collections
Resource    ../testline.robot
Suite Setup   Setup The Output Filepath

***Test Cases ***
Test Resources
    [TAGS]              HANGRES

    ${resources_before}=   Get Resources Usage   node_id=0   node_type=gnb
    json_helper_py.Dump Json To File    ${resources_before}    ${BEFORE_FILE}

Test Resources Should Be Equal
    [TAGS]              HANGRES
    ${res_before_1}=   json_helper_py.Load Json From File    ${BEFORE_FILE}
    ${res_before_2}=    json_helper_py.Load Json From File   ${BEFORE_FILE}

    Resources Should Be Equal   ${res_before_1}   ${res_before_2}

    Set List Value   ${res_before_2['CPCELL']}    ${0}    7

    Run Keyword And Expect Error   Resources Differ!    Resources Should Be Equal   ${res_before_1}   ${res_before_2}    exclude=${None}

    Configure Default Excluding Resource Paths   add=//CPCELL

    Resources Should Be Equal   ${res_before_1}   ${res_before_2}

    Configure Default Excluding Resource Paths   remove=//CPCELL

    Run Keyword And Expect Error   Resources Differ!    Resources Should Be Equal   ${res_before_1}   ${res_before_2}    exclude=${None}

*** Keywords ***
Setup The Output Filepath
    ${target_dir}=    testline.Get Test Suite Log Directory
    Set Suite Variable   ${BEFORE_FILE}   ${target_dir}/resources_before.json
    Set Suite Variable   ${AFTER_FILE}   ${target_dir}/resources_after.json

