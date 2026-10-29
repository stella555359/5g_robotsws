*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_variables.py

*** Keywords ***
CB012195_B_14_General_SiSo_E2E_system_setup_with_data_transfer_3S_3CC_3x8DL8UL_8Rx_ABIP
    [Arguments]    ${frames_info}
#    Update PA Value For Tput
    ${pa_value}    set variable    15
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_value}   RU_id=0
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${frames_info[0]}[cellid]
    ...                                     target_avg_percent=0.8
    ...                                     duration=180
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[2]}[cellid]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput    ul_data_transfer=${frames_info[2]}[ul_data_transfer]
    ...                                    dl_data_transfer=${frames_info[2]}[dl_data_transfer]
    ...                                    expect_ul_tput=${frames_info[2]}[expect_ul_tput]
    ...                                    expect_dl_tput=${frames_info[2]}[expect_dl_tput]
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[2]}[cellid]
    ...                                    target_avg_percent=0.8
    ...                                    duration=180
    [Teardown]     Run Keyword And Ignore Error    Stop Traffic In Teardown

CB012195_B_23_General_SiSo_Cell_block_and_unblock_3S_3CC_1x16DL8UL_2x8DL4UL_4Rx_8Rx_ABIP
    [Arguments]    ${frames_info}
    ${pa_value}    set variable    15
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${pa_value}   RU_id=0
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                            dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                            expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                            expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[0]}[cellid]
    ...                                            throuput_duration=3600
    ...                                            target_avg_percent=0.8
    ...                                            is_need_stop_traffic=${False}
    ...                                            min_percent=0
    ...                                            duration=180
    Lock Cell    cell_id=${frames_info[1]}[cellid]
    Run keyword unless   'SBTS00' in '${stream}'
    ...               Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[1]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[1]}[cellid]
    Run keyword unless   'SBTS00' in '${stream}'
    ...               Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[1]}[cellid]
    Sleep    2min
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                is_ulbler_calcu=${False}
    ...                                target_avg_percent=0.8
    ...                                cellid=${frames_info[0]}[cellid]
    ...                                min_percent=0
    ...                                duration=120
    Lock Cell    cell_id=${frames_info[2]}[cellid]
    Run keyword unless   'SBTS00' in '${stream}'
    ...               Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[2]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[2]}[cellid]
    Run keyword unless   'SBTS00' in '${stream}'
    ...               Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[2]}[cellid]
    Sleep    2min
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                         expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                         is_ulbler_calcu=${False}
    ...                         target_avg_percent=0.8
    ...                         cellid=${frames_info[0]}[cellid]
    ...                         min_percent=0
    ...                         duration=120
    [Teardown]     Run Keyword And Ignore Error    Stop Traffic In Teardown
