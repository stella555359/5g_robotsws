*** Settings ***
Documentation    Description:  Cloud Library with commonly used keywords

Library    BuiltIn
Library    OperatingSystem
Library    taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library    taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library    taf.hw.fhgw.cli    WITH NAME    issh
Library    taf.ul.vdu.helm    WITH NAME    helm

Resource    ./common_vcu.robot
Resource    ./common_vdu.robot

*** Keywords ***
placeholder keyword
    Log To Console    placeholder

vDU Collect Snapshot
    [Documentation]  Description:           Keyword gets vDU snapshot files ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     23-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${logs_dir_path}  ${compressed_or_not}=True

    ${vdu_snapshot_dir}=  Set Variable  ${logs_dir_path}/vdu_snapshot
    Create Directory  path=${vdu_snapshot_dir}
    vDU Rest Login
    Run Keyword And Ignore Error  vdu.Get Local Snapshot  directory=${vdu_snapshot_dir}
    ...  compressed_or_not=${compressed_or_not}
    [Teardown]  Run Keyword And Ignore Error  vDU Rest Logout

vCU Collect Snapshot
    [Documentation]  Description:           Keyword gets vDU snapshot files ${\n}
    ...              Return:                None ${\n}
    ...              Output:                None ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${logs_dir_path}  ${compressed_or_not}=True

    vCU Rest Login
    ${vcu_snapshot_dir}=  Set Variable  ${logs_dir_path}/vcu_snapshot
    Create Directory  path=${vcu_snapshot_dir}
    Run Keyword And Ignore Error  cu.Get Local Snapshot  directory=${vcu_snapshot_dir}
    ...  compressed=${compressed_or_not}
    [Teardown]  Run Keyword And Ignore Error  vCU Rest Logout

Get Command Result
    [Documentation]  Description:           Get results of executed ssh command ${\n}
    ...              Return:                Output from ssh command ${\n}
    ...              Output:                ${final_cmd_result} ${\n}
    ...              Author:                szymon.romanowski@nokia.com ${\n}
    ...              Maintainer:            szymon.romanowski@nokia.com ${\n}
    ...              Last Modification:     26-02-2024 made by szymon.romanowski@nokia.com ${\n}
    [Arguments]  ${cmd_result}

    ${cmd_result_lines}=  Split To Lines  string=${cmd_result}
    Remove From List  ${cmd_result_lines}  0
    Remove From List  ${cmd_result_lines}  -1
    ${cmd_result_length}=  Get Length  item=${cmd_result_lines}
    Should Be True  ${cmd_result_length}==1
    ${final_cmd_result}=  Set Variable  ${cmd_result_lines[0]}
    [Return]  ${final_cmd_result}
