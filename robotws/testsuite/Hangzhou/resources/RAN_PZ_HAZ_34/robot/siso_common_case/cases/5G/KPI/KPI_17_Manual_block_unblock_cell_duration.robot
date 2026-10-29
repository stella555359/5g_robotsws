*** Settings ***
Documentation    This is common keywords for siso related cases
...              Please do not modify the file without notification to author

Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/btslog_check.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Library     taf.sbts.oam.coam.admin   WITH NAME   coam
Library     taf.ul.oam_kpi_calculations   WITH NAME   oam_kpi

*** Keywords ***
KPI_17_Manual_block_unblock_cell_duration
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test case is to verify bts block/unblock functionality.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 25.01.2024 - - Created
    ...    ticket:https://jiradc.ext.net.nokia.com/browse/LEOPARD-1678?filter=-1
    ...    *******************
    ...    Owner_kaihui.fan@nokia-sbell.com
    [Arguments]  ${cell_block_durtion}=10    ${cell_unblock_durtion}=18   ${connection}=GNB_OAM   ${gnb_type}=${gNb_CuType}
    ${cell_id_list}  Get All Cell Id    cell_type=${cell_type}
    Get X2 link shutdown waiting time   connection=${connection}
    @{split_version}    string.split string    ${Active_SW_version}    separator=_
    ${stream}    set variable     ${split_version}[0]
    Selenium Login And Disable Screen Lock
    Block cells and check status    block_list=${cell_id_list}   gnb_type='${gnb_type}'
    UnBlock Cells and check status    block_list=${cell_id_list}   gnb_type='${gnb_type}'    skip_deepsleep=${True}
    ${ims2_path}    Set Variable   ${TS_CASE_LOG_PATH}/IMS2_KPI17_Block_Unblock.ims2
    log to console   IMS2 path is ${ims2_path}
    coam.collect_im_snapshot   connection=${connection}   target_file_name=${ims2_path}   timeout=${300}
    IMS2 Check Cell Block Unblock KPI   cell_id_list=${cell_id_list}   ims2_file_path=${ims2_path}
    ...    cell_block_durtion=${cell_block_durtion}   cell_unblock_durtion=${cell_unblock_durtion}
    [Teardown]  selenium logout and close browser

IMS2 Check Cell Block Unblock KPI
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${cell_id_list}    ${ims2_file_path}   ${kpi_block_name}=kpi17a  ${kpi_unblock_name}=kpi17b
    ...    ${cell_block_durtion}=10    ${cell_unblock_durtion}=30
    FOR    ${cell_id}  IN  @{cell_id_list}
        ${block_result}   oam_kpi.calculate_kpi17a   ims_file_path=${ims2_file_path}   global_cell_id=${cell_id}
        ${block_downtime}   Get Variable Value   ${block_result['${kpi_block_name}'][-1]['delta'].total_seconds()}   0
        log to console   cell-${cell_id} block duration:${block_downtime}
        ${unblock_result}   oam_kpi.calculate_kpi17b   ims_file_path=${ims2_file_path}   global_cell_id=${cell_id}
        ${unblock_downtime}   Get Variable Value   ${unblock_result['${kpi_unblock_name}'][-1]['delta'].total_seconds()}   0
        log to console   cell-${cell_id} unblock duration:${unblock_downtime}
        run keyword and continue on failure    Should Be True
        ...    ${block_downtime}<=${cell_block_durtion} and ${block_downtime}>${0}
        run keyword and continue on failure    Should Be True
        ...    ${unblock_downtime}<=${cell_unblock_durtion} and ${unblock_downtime}>${0}
        oam_kpi.clear_results
    END
