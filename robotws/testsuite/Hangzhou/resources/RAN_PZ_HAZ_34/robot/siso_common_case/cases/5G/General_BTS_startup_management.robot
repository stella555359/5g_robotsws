*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
*** Variables ***

*** Keywords ***
General_BTS_startup_management
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify BTS startup management
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.11.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    ${ru_index_list}  Get All RU Index
    Perform RAC and RAU Power Off  ${ru_index_list}
    Perform RAC Power On  ${ru_index_list}
    Power On RU_and_check RF Delayed Startup  ${ru_index_list}
    Commissioning SCF And Check On Air      scf_path=${Golden_SCF_Path}
