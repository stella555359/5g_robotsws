*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Resource    ../../5GC000702/Resources/5GC000702_common_ute.robot


*** Variables ***

*** Keywords ***
5GC002548_B_117_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_100M_peak_Concurrent_Mode
    [Documentation]   NSA: DL: 1.357G UL:54M 0% (case bler: UL:5% DL:5%)
    Modify To 2056 Config
    Get gNb Cu Type Value
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    1289    1221
    Start L3 Call And Verify Throughput   ul_data_transfer=135M
    ...                                   dl_data_transfer=1500M
    ...                                   expect_ul_tput=100
    ...                                   expect_dl_tput=${expected_dl_tput}
    ...                                   reset_sol=pc_reset
    ...                                   4G_check=${False}

5GC000657_5GC0011116_3ms_02_A2_L3_call_with peak_throughput_with_beamforming_80M
    [Documentation]    NSA:DL :1.07G UL:43M 0% (case bler: UL:5% DL:5%)
    Modify To 2056 Config
    ${status}    run keyword and return status    Modify_Band_Frame_Structure
    ...                            ru_index=${1}    frame_structure=1116_0ms_GP1_A7    band=80    prach_index=156    beamset=4 beams
    ...                            dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword if  not ${status}    Perform gNB Restart And Check on air via rest api
    Get gNb Cu Type Value
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    1016    963
    Start L3 Call And Verify Throughput    ul_data_transfer=95M
    ...                                    dl_data_transfer=1200M
    ...                                    expect_ul_tput=75
    ...                                    expect_dl_tput=${expected_dl_tput}
    ...                                   4G_check=${False}

5GC002548_B_119_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_50M_peak_Concurrent_Mode
    [Documentation]   samsung 20S not support 0M ,case change to 60M
    ...               NSA: DL : 561M  UL : 48.5M 0% (case bler: UL:5% DL:5%)
    ...               NSA: DL : 687M  UL : 59.71M 0% (case bler: UL:5% DL:5%)
    Modify To 2056 Config
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    650    615
    ${status}    run keyword and return status    Modify_Band_Frame_Structure
    ...                            ru_index=${1}    frame_structure=1070_GP1_A3    band=60    prach_index=98    beamset=4 beams
    ...                            dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword if  not ${status}    Perform gNB Restart And Check on air via rest api
    Run Keyword And Ignore Error    Connect To Gnb Coam Via SSL
    Start L3 Call And Verify Throughput    ul_data_transfer=125M
    ...                                    dl_data_transfer=800M
    ...                                    expect_ul_tput=56
    ...                                    expect_dl_tput=${expected_dl_tput}
    ...                                   4G_check=${False}

5GC002548_B_123_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_40M_peak_Concurrent_Mode
    [Documentation]   NSA: DL:541.9M UL: 24.39M 0%  (case bler: UL:5% DL:5%)
    Modify To 2056 Config
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    513    486
    ${status}    run keyword and return status    Modify_Band_Frame_Structure
    ...                            ru_index=${1}    frame_structure=1208_GP1_A1    band=40    prach_index=98    beamset=4 beams
    ...                            dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword if  not ${status}    Perform gNB Restart And Check on air via rest api
    Run Keyword And Ignore Error    Connect To Gnb Coam Via SSL
    Start L3 Call And Verify Throughput    ul_data_transfer=80M
    ...                                    dl_data_transfer=700M
    ...                                    expect_ul_tput=40
    ...                                    expect_dl_tput=${expected_dl_tput}
    ...                                   4G_check=${False}

5GC002548_B_118_SiSo_E2E_system_setup_with_data_transfer_conducted_2510_A_256QAM_4Layer_20M_peak_Concurrent_Mode
    [Documentation]   NSA20M: DL: 252M UL: 11.8M 60M:DL :802 UL:38M (case bler: UL:5% DL:5%)
    Modify To 2056 Config
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    239    226
    ${status}    run keyword and return status    Modify_Band_Frame_Structure
    ...                            ru_index=${1}    frame_structure=1116_3ms_GP1_A5    band=20    prach_index=98    beamset=4 beams
    ...                            dl_ul_layer=4DL4UL    dl_modulation=dl_256QAM
    run keyword if  not ${status}    Perform gNB Restart And Check on air via rest api
    Update msg1FrequencyStart Value    cell_id=1    msg1FrequencyStart=10
    Run Keyword And Ignore Error    Connect To Gnb Coam Via SSL
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                    dl_data_transfer=500M
    ...                                    expect_ul_tput=19
    ...                                    expect_dl_tput=${expected_dl_tput}
    ...                                   4G_check=${False}

5GC002540_E_10_03_AEHC_AEQE_AEQQ_peak_tput_3S_2CC_8D4U_40M60M_20M20M_40M50M_1X25G
    [Documentation]   NSA40M: DL: 525M UL: 41M 0% (case bler: UL:5% DL:5%)
    Get gNb Cu Type Value
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    498    472
    Start L3 Call And Verify Throughput   ul_data_transfer=70M
    ...                                   dl_data_transfer=600M
    ...                                   expect_ul_tput=39
    ...                                   expect_dl_tput=${expected_dl_tput}
    ...                                   reset_sol=pc_reset
    ...                                   4G_check=${False}
    return from keyword if    '${stream}'=='SBTS23R1'
    Connect to gnb coam via ssl
    ${modified_scf_file_path}    Modify and Save SCF    ParameterToDelete=${PARAMS_TO_DELETE_FOR_100_80_80}
    ...                                                 ParamterToModify=${PARAMS_TO_MODIFY_FOR_100_80_80}
    ...                                                 ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_100_80_80}
    COAM Commission with scf file    scf_file_path=${modified_scf_file_path}    timeout=900
    sleep    60s
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair


5GC002089-B_05_5GC002089-42_AEHC_RU_lock_and_unlock_L3_call_multiple_BBMODs
    [Arguments]    ${ru_index}=1    ${cell_index}=1    ${cell_group_idx}=0
    Perform RU lock via rest api    ru_idx=${ru_index}    timeout=120
    Wait Until Keyword Succeeds    180 sec    3 sec    RU Should Be Locked    ru_index=${ru_index}
    Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Disabled    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    ${allowed_fault_list}    Create list    @{ALLOWED_FAULT}    ${fault_16}    ${fault_4298}    ${fault_7300}   ${fault_7319}    ${fault_7312}
    Unexpect Alarm Should Not Exist    allowed_faults=${allowed_fault_list}
    Perform RU unlock via rest api    ru_idx=${ru_index}    timeout=120
    Wait Until Keyword Succeeds    240 sec    3 sec    RU Should Be Unlocked    ru_index=${ru_index}
    Wait Until Keyword Succeeds    180 sec    5 sec    Cell Should Be Enabled    cell_idx=${cell_index}    cell_group_idx=${cell_group_idx}
    COAM Wait For Gnb Ready And Cell Setup    timeout=5 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${ALLOWED_FAULT}
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    90M    80M
    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95
    [Teardown]    Run Keyword And Ignore Error     run keywords
    ...    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    AND
    ...    Run Keyword And Ignore Error   Perform RU unlock via rest api    ru_idx=${ru_index}

5GC002089-B_06_5GC002089-42_AEHC_RU_module_reset_from_GUI
    [Arguments]    ${ru_index}=1    ${cell_index}=1
    Perform RF Module Reset from GUI    ru_index=${ru_index}
    COAM Wait For Gnb Ready And Cell Setup    timeout=15 min
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    90M    80M
    ${reset_sol}    set variable if  'SBTS00' in '${stream}'    ue_reboot    ${none}
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=70
    ...                                    expect_dl_tput=800
    ...                                    4G_check=${False}
    ...                                    reset_sol=${reset_sol}
    ...                                    cellid=${cell_index}
    ...                                    target_avg_percent=0.95
