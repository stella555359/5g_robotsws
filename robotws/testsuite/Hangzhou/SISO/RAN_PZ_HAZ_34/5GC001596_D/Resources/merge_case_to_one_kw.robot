*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: MMW1
...   Feature 5GC001596 in 5G19B program

Resource     ./5GC001596_D_Keywords.robot

*** Keywords ***
1596_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
    [Documentation]    author: Liu Zheng
    ${default_nrarfcn}    get nrarfcn for specific cell
    set test variable    ${DEFAULT_NRARFCN}
    FOR    ${run_time}    IN RANGE    ${TEST_REPEAT_TIMES}
        ${tmp_flie_name}    gnb_classical_hangzhou.Create RU temp file    ru_alias=RU_1
        csn.Disconnect    connection=RU_1
        csn.Disconnect    connection=ASIK Master
        ${update_nrarfcn}    evaluate    ${DEFAULT_NRARFCN}+4*(1+${run_time})
        update nrarfcn should success    nrarfcn=${update_nrarfcn}
        Sleep    1 min
        Wait until keyword succeeds    10 min    5 sec    COAM Check GNB RU status
        Connect to Common Unit Master    alias=ASIK Master
        Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM
        gnb_classical_hangzhou.Verify RU temp file disappeared    last_ru_tag=${tmp_flie_name}    ru_alias=RU_1
        csn.execute  command=uptime  connection=RU_1
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
    END

1596_BTS_Commissioning_several_times
    [Documentation]    author: Liu Zheng
    [Arguments]     ${scf_modify_parameters}=${PARAMS_TO_MODIFY_SCF}    ${swconfig_modify}=${None}
    ...    ${is_pdl_checking_needed}=${True}    ${scf_template_path}=${SCF_DEFAULT_FILE_PATH}
    FOR    ${run_time}    IN RANGE    ${TEST_REPEAT_TIMES}
        run keyword if    ${run_time}>${0}    Sleep    3 min
        ${pdl_validation_result}    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
        ...    scf_modify=${scf_modify_parameters}    is_called_in_test_case_level=${True}
        ...    is_pdl_checking_needed=${is_pdl_checking_needed}    scf_template_path=${scf_template_path}
        run keyword if    '${is_pdl_checking_needed}' == '${True}'    Should be true    ${pdl_validation_result}!=${False}
        ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
    END

1596_General_SiSo_RF_module_reset_from_GUI
    [Documentation]    author: Liu Zheng
    FOR    ${run_time}    IN RANGE    ${TEST_REPEAT_TIMES}
        Perform RU Reset    ru_index=${1}
        Wait Until Keyword Succeeds    90 sec    5 sec    RU Should Be Offline    ru_index=${1}
        Wait Until Keyword Succeeds    3 min    5 sec    Cell Should Be Disabled
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
    END

1596_General_SiSo_RF_module_power_reset
    [Documentation]    Author: Liu Zheng
    Perform RU Power Off    ru_index=${1}
    Wait until keyword succeeds    3 min    1 sec    RU Should Be Power Off    ru_index=${1}    connection=GNB_OAM
    Sleep    30 sec
    Perform RU Power On    ru_index=${1}
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
    ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}

1596_OAM_report_alarm_while_configuration_error
    [Documentation]    Author: Liu Zheng
    ${cell_list}    Get cell list for GNB
    ${length}    Get length    ${cell_list}
    FOR    ${index}    IN RANGE    ${length}
         Update prachConfigurationIndex and check fault 7506 for each cell    cell_list=${cell_list[${index}]}
    END

1596_Stability_Start-up_time_measurement_for_cell_onair
    [Documentation]    Author: Liu Zheng
    FOR    ${run_time}    IN RANGE    ${10}
        ${test_begin_time_epoch}    Perform BTS site reset and get the reset time epoch    download_dir=${TS_CASE_LOG_PATH}
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
        ${test_end_time_epoch}        DateTime.get current date    result_format=epoch    exclude_millis=True
        Should be true    ${test_end_time_epoch}-${test_begin_time_epoch} < 648
    END

