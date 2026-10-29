*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot

*** Variables ***

*** Keywords ***
General_SiSo_stability_with_L3Call
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The objective of the case is to verify the stability of the set system during long duration
    ...    run and test for possible throughput and latency degradation or unit overheating.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 18.08.2022 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    Simple UE L3 Call And Throughput    duration=${900}
