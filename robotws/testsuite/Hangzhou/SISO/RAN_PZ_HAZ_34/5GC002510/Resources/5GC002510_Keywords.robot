*** Settings ***
Documentation    Auther:Qiming.Yang@nokia-sbell.com

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002548/Resource/5GC002548_Common.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot

*** Keywords ***
Recover RU By Power In Teardown
    [Arguments]  ${connection}=GNB_OAM
    ${ru_num}    RRH_common_keyword.COAM Get GNB RU Number    connection=${connection}
    Run Keyword If Test Failed    Run Keyword And Ignore Error    Power On For All RU    ru_num=${ru_num}

Check Cells Status
    [Documentation]
    ...    to check all cells status
    [Arguments]    ${timeout}=10 min
    wait until keyword succeeds    ${timeout}
    ...                            15s
    ...                            Verify all cells should be onair

