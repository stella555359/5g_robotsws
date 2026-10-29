*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot

*** Variables ***

*** Keywords ***
General_BFD_alarms_checking_for_BFD_down_ingress_and_BFD_down_egress
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the case is to the applicable to RP1/SOAP management interfaces.BFD alarms shown
    ...    in webem per Session (for manually configured BFD sessions) are started and cancelled abnormally.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.07.2019 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]    ${ru_index}=1
    add nft table udp_table0 in ru    ru_index=${ru_index}
    Wait until keyword succeeds    3min    30s    Expect Fault Should Present    faultId=61606    configObjectName=BFD-2
    delete nft table udp_table0 in ru    ru_index=${ru_index}
    [Teardown]  Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
