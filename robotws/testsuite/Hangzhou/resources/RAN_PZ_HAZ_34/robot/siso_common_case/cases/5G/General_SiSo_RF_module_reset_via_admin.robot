*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Library       taf.sbts.oam.coam.admin    WITH NAME    coam
Resource      ../../step_keywords/5G/recommissioning_and_make_throughput.robot
Resource      ../../step_keywords/5G/basic/coam_check_status.robot

*** Variables ***

*** Keywords ***
General_SiSo_RF_module_reset_via_admin
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test case is to verify that radio module
    ...    and OAM behaves correctly during procedure of radio module reset triggered by user via admin.
    ...    for ticket https://jiradc.ext.net.nokia.com/browse/LEOPARD-738
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 15.07.2019  - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Arguments]  ${with_call}=${False}  ${with_peak}=${False}  ${duration}=${30}    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ...    ${suite_name}=default    ${test_name}=default
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active    connection=${connection}
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    connection=${connection}
    ${ru_index_list}    Get All RU Index    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        log to console    \n***RF Module index ${ru_index} Reset via admin**
        ${ru_index}  Convert To Integer    ${ru_index}
        coam.reset_unit    dist_name=MRBTS-${mrbts_id}/EQM-1/APEQM-1/RMOD-${RU_index}
        ...    force_radio_reset=${True}    timeout=${300}    connection=${connection}
    END
    wait until keyword succeeds   3x    30 sec    Check status after rmod reset
    ...    before_active_fault_list=${before_active_fault_list}    before_history_fault_list=${before_history_fault_list}
    ...    gnb_type=${gNb_CuType}    connection=${connection}
    FOR    ${ru_index}    IN    @{ru_index_list}
        ${cell_list}    Get All Cell Id    ${ru_index}    connection=${connection}
        run keyword if  ${with_call}  Get UE From Init File and Make call  cell_list=${cell_list}
        ...    with_peak=${with_peak}  duration=${duration}    connection=${connection}
        ...    suite_name=${suite_name}    test_name=${test_name}
    END
