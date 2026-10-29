*** Settings ***
Suite Setup    Suite Setup For Aic BTS Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters Aic
Test Setup    Common Test Setup And Start To Capture Logs Aic
Test Teardown    Common Test Teardown And Stop Capture Logs Aic

Documentation    Suite description
...   Author:      Mao Cathy
...   Contact:     cathy.mao@nokia-sbell.com
...   Squad Group: MMW_SG7
...   Feature:     Cloud

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources_aic/DevHZ5_resource_aic_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_throughput.robot

*** Variables ***
${Golden_VDU_SCF_Path}    /home/ute/MN/UTE/robotws/commissionings/HGZ/7_5_UTE5G401T2461/vDU/SCF_vDUCNF00.xml
${testline_name}    7_5_UTE5G401T2461
@{ue_index_list}    0


*** Test Cases ***
Cloud_E2E_L3Call
    ${cell_and_peak_info}    Prepare Cell Params
    Cloud UE L3 CAll Procedure    ue_index_list=${ue_index_list}    cell_and_peak_info=${cell_and_peak_info}
    ...    check_wait_time=60    duration=${120}

*** Keywords ***
Suite Setup For Aic BTS Env
    [Arguments]    ${scf}=SCF_SBTS00.xml
    Set Library Search Order     admin
    Setup BTS Env Aic   scf=${scf}

Aic Cells Should Be Onair
    ${onair_status}  Wait Aic BTS Onair And Return Status
    Run Keyword If  '${onair_status}'=='${False}'    Fail

Prepare Cell Params
    Set Test Variable    ${SAVE_LOG_DIRECTORY}     ${TEST_LOG_DIR}
    ${cell_list}    Get CellsIdList For vDU
    ${cell_and_peak_info}    Cloud Generate Peak Information with Given Params    cell_id=${cell_list[0]}
    ...    dl_tp=${100}    ul_tp=${10}    duration=${120}
    ...    target_avg_percent=0.8    min_percent=0.5
    [Return]    ${cell_and_peak_info}

Get CellsIdList For vDU
    ${cells_id}  create list
    Get Aic Config Ip And Account Info For Vdu
    ${du_cells_info}    get_vdu_cells
    Log    ${du_cells_info}
    FOR    ${cell}    IN    @{du_cells_info}
        append to list    ${cells_id}    ${cell}[id]
    END
    [Return]    ${cells_id}
