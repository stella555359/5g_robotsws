*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/basic/simple_ue.robot
*** Variables ***

*** Keywords ***
Common_SiSo_Call_Multi_UE_throughput_testing
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE]  The purpose of this test case is to verify multi-UE L3 call with 1 UE per cell with
    ...    simultaneous throughput test in the test environment of multiple cells.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.20.2021 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]  ${ru_index}=${None}  ${cell_id}=${None}
    ...    ${ue_num_for_call_per_cell}=1    ${dl_tp}=205  ${ul_tp}=26
    ...    ${duration}=${180}    ${protocol}=udp    ${check_wait_time}=30
    ...    ${target_avg_percent}=0.9    ${min_percent}=0.8
    ${flag}    run keyword and return status    Should contain    ${TEST_TAGS}[0]    S-
    ${SCF_Path}    run keyword if    ${flag}      Replace String    ${Golden_SCF_Path}    .xml    _${TEST_TAGS}[0].xml
        ...           ELSE    set variable     ${Golden_SCF_Path}
    #run keyword if    ${flag}      Commissioning SCF And Check On Air for Common    scf_path=${SCF_Path}
    ${cell_id_list}    Get All Cell Id    ru_index=${ru_index}    cell_type=${cell_type}
    ${cell_list}    run keyword if    '${cell_id}'=='${None}'    set variable    ${cell_id_list}
    ...    ELSE    create list    ${cell_id}
    Simple UE L3 Call And Throughput    cell_list=${cell_list}
    ...                                 ue_num_for_call_per_cell=${ue_num_for_call_per_cell}
    ...                                 dl_tp=${dl_tp}
    ...                                 ul_tp=${ul_tp}
    ...                                 duration=${duration}
    ...                                 protocol=${protocol}
    ...                                 check_wait_time=${check_wait_time}
    ...                                 target_avg_percent=${target_avg_percent}
    ...                                 min_percent=${min_percent}
    ...                                 scf_path=${SCF_Path}
