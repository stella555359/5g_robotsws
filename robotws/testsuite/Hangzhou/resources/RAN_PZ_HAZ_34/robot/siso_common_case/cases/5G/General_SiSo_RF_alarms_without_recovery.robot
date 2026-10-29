*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_SiSo_RF_alarms_without_recovery
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is verification of RU connection and lack of attempt of RU recovery from fault state.
    ...    RU should be affected by unrecoverable error triggered during normal BTS run.
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 03.18.2020 - - Created
    ...    *******************
    ...    Test case flowchart
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=1    ${Tdanger_target}=30.0
    Connect to gnb coam via ssl
    ${SW_version}    Get Active SW Version
    @{split_version}    string.split string    ${SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]

    ${Tdanger_init}    Run keyword if    '${stream}'>'SBTS24R2'    Get Tdanger Value from Json File in SBTS00    ru_index=${ru_index}
    ...    ELSE    Get Tdanger Value from Json File    ru_index=${ru_index}
    log to console   \n init Tdanger value:${Tdanger_init}
    log to console    \n Trigger Alarm 1937
    Run keyword if    '${stream}'>'SBTS24R2'
    ...    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_init}    target_value=${Tdanger_target}
    ...    cmd=touch    ru_index=${ru_index}
    ...    ELSE    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_init}    target_value=${Tdanger_target}
    ...    cmd=touch    ru_index=${ru_index}
    log to console   \n Check Alarm 1937 Appear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present    faultId=1937
    log to console    \n Recovery Alarm 1937
    Run keyword if    '${stream}'>'SBTS24R2'
    ...    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_target}    target_value=${Tdanger_init}
    ...    cmd=rm -rf    ru_index=${ru_index}
    ...    ELSE    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}    target_value=${Tdanger_init}
    ...    cmd=rm -rf    ru_index=${ru_index}
    log to console    \n Check Alarm 1937 Disappear On WebEM
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent    faultId=1937
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]    Run keyword if    '${stream}'>'SBTS24R2'
    ...    run keywords    Modify Tdanger Value In Json File with RU reset in SBTS00    init_value=${Tdanger_target}
    ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}    AND    coam wait gnb and cells ready
    ...    timeout=15min    gnb_type='${gNb_CuType}'
    ...    ELSE    run keywords    Modify Tdanger Value In Json File with RU reset    init_value=${Tdanger_target}
    ...    target_value=${Tdanger_init}    cmd=rm -rf    ru_index=${ru_index}    AND    coam wait gnb and cells ready
    ...    timeout=15min    gnb_type='${gNb_CuType}'
