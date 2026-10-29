*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
*** Variables ***

*** Keywords ***
General_SiSo_Auto_BTS_site_reset
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify success rate of gNB site reset activated from
    ...    WebUI interface.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 03.02.2020 - - Created
    ...    - 12.10.2023 - - Modify case
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${with_call}=${False}    ${with_peak}=${True}    ${ue_cell_id}=${1}    ${MAX_LOOP}=${1}
    ...    ${get_all_bts_cells}=${False}
    ${cell_list}  run keyword if    ${get_all_bts_cells}    get all cell id
    ...    ELSE    create list    ${ue_cell_id}
    FOR    ${TEST_LOOP}    IN RANGE    1    ${MAX_LOOP}+1
        Log To Console    \n GNB Reset Iteration:${TEST_LOOP}
        Perform BTS Site Reset
        sleep     60s  
        COAM Wait gnb And Cells ready    timeout=20 min    gnb_type='${gNb_CuType}'
        run keyword if    ${with_call}    Get UE From Init File and Make call    cell_list=${cell_list}
        ...    with_peak=${with_peak}    duration=${300}
    END
