*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Auto_BTS_site_reset.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    5GC000702_common_ute.robot
Variables   5GC000702_variables.py

*** Keywords ***
5GC000702_M_112_Configuration_Of_2S_1CC_4DL_256QAM_2UL_64QAM_100MHz_mcs15_SFP_FORT_L3_Call_AZQL
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    SCF_${stream}.xml
    Modify SCF and Perform Commission    MOsToAdd=${Mos_TO_ADD_Two_Channels_FOR_4D4U}
    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_Two_Channels_FOR_4D4U}
    ...                                  scf_path=${scf_file_path}
    ...                                  scf_file_name=SCF_${stream}.xml
#    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
#    Update Chbw And Dynamic Pdcch Wait Gnb On Air    bandwidth=100MHz
    ${wireshark_log_path_on_testPC}    Start L3 Call And Verify Throughput   ul_data_transfer=110M
    ...                                   dl_data_transfer=1500M
    ...                                   expect_ul_tput=99.5
    ...                                   expect_dl_tput=1417
    ...                                   duration=360
#    ...                                   reset_sol=${reset_sol}
    ...                                   target_avg_percent=0.9
    ...                                   min_percent=0.8
    ...                                   4G_check=${False}

5GC000702_M_159_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    Connect to Common Unit Master    alias=ASIK Master
#    General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=${False}
    Start L3 Call And Verify Throughput   ul_data_transfer=80M
    ...                                   dl_data_transfer=1300M
    ...                                   expect_ul_tput=40
    ...                                   expect_dl_tput=950
    ...                                   reset_sol=${reset_sol}
    ...                                   duration=300
    ...                                   4G_check=${False}

5GC000702_M_151_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Update msg1FrequencyStart Value
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
#    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Start L3 Call And Verify Throughput    ul_data_transfer=50M
    ...                                    dl_data_transfer=500M
    ...                                    expect_ul_tput=9.5
    ...                                    expect_dl_tput=240
    ...                                    reset_sol=${reset_sol}
    ...                                   4G_check=${False}

5GC000702_M_172_Configuration_Of_2S_1CC_CL_2DL_2UL_L3_Call_AZQL
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Run Keyword And Continue On Failure    Check RU Calibration Status And Power
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                    dl_data_transfer=1100M
    ...                                    expect_ul_tput=68
    ...                                    expect_dl_tput=826
    ...                                    duration=360
    ...                                    reset_sol=${reset_sol}
    ...                                   4G_check=${False}

5GC000702_M_166_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQL
#    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
#    Update msg1FrequencyStart Value
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to Common Unit Master    alias=ASIK Master
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
#    General_SiSo_RU_lock_unlock.General_SiSo_RU_lock_unlock    with_call=${False}
    Start L3 Call And Verify Throughput    ul_data_transfer=20M
    ...                                    dl_data_transfer=400M
    ...                                    expect_ul_tput=10
    ...                                    expect_dl_tput=225
#    ...                                    reset_sol=${reset_sol}
    ...                                    target_avg_percent=0.9
    ...                                   4G_check=${False}

5GC000702_M_108_Configuration_Of_2S_1CC_4DL_2UL_on_air_AZQH
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    ${expected_dl_tput}     Set Variable If    '${gNbCuType}' == 'NSA'    490    460
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    ${wireshark_log_path_on_testPC}    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                    dl_data_transfer=700M
    ...                                    expect_ul_tput=18
    ...                                    expect_dl_tput=${expected_dl_tput}
    ...                                    is_wireshark_log_capture=${True}
    ...                                    reset_sol=${reset_sol}
    ...                                   4G_check=${False}
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s
    ...                                    Check PBCH BlockPower From X2 Log
    ...                                    wireshark_log_path_on_testPC=${wireshark_log_path_on_testPC}

5GC000702_M_161_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQH
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
#    Update Chbw And Dynamic Pdcch Wait Gnb On Air    bandwidth=100MHz
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    Connect to Common Unit Master    alias=ASIK Master
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    RRH_common_keyword.General SiSo RU Lock Unlock
    Start L3 Call And Verify Throughput    ul_data_transfer=80M
    ...                                    dl_data_transfer=1500M
    ...                                    expect_ul_tput=50
    ...                                    expect_dl_tput=1200
    ...                                    reset_sol=${reset_sol}
    ...                                   4G_check=${False}

5GC000702_M_153_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Lock Cell    cell_id=1
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=1
    Sleep    10sec
    Unlock Cell    cell_id=1
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=1
    Sleep    3min
    Start L3 Call And Verify Throughput    ul_data_transfer=50M
    ...                                    dl_data_transfer=1000M
    ...                                    expect_ul_tput=28
    ...                                    expect_dl_tput=740
    ...                                    reset_sol=${reset_sol}
    ...                                   4G_check=${False}

5GC001178_AE_5GC001138_AB_01_UL_DL_Traffic_With_1UE_chbw40Mhz
    [Documentation]
    ...    author: leji.jia@nokia-sbell.com.
    Start L3 Call And Verify Throughput
    ...                   ul_data_transfer=45M
    ...                   dl_data_transfer=800M
    ...                   expect_ul_tput=17
    ...                   expect_dl_tput=460
    ...                   ue_index=${0}
    ...                   4G_check=${False}

5GC001138_AB_10_UL+DL_Traffic_With_1UE
    [Documentation]
    ...    author: leji.jia@nokia-sbell.com.
    Common_setup_and_teardown.Case Common SetUp    update_param_name=${FRAME_TO_11160ms_60MHz_6Symbols_AAHF}
    ...                  is_dynamic_pdcch_update=${True}
    ...                  is_case_level_update_params_exist=${True}
    ...                  scf_file_path=${Golden_SCF_Path}
    COAM Wait for gnb ready and cell setup
    Sleep 	90s 	Wait for calibration setup
    Start L3 Call And Verify Throughput
    ...                   ul_data_transfer=75M
    ...                   dl_data_transfer=900M
    ...                   expect_ul_tput=25
    ...                   expect_dl_tput=700
    ...                   ue_index=${0}
    ...                   4G_check=${False}

OAM_KPI_Auto_BTS_site_reset
    Set Test Variable    ${reset_times}    20
    Set Test Variable    ${fail_count}    0
        FOR    ${count}    IN RANGE    ${reset_times}
        ${status}    Run Keyword And Return Status    General_SiSo_Auto_BTS_site_reset.General_SiSo_Auto_BTS_site_reset
        ${fail_count}    Set Variable If    '${status}'=='False'    ${fail_count}+1    ${fail_count}
    END
    ${fail_rate}    Evaluate    float(${fail_count})/float(${reset_times})
    Should be true    ${fail_rate}<=0.1

5GC001451_2_subSector_1xPol_CloseLoop_4x4_256QAM_Rank4
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    Change To Closeloop 256QAM And Change CHBW
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                 dl_data_transfer=800M
    ...                                 expect_ul_tput=27
    ...                                 expect_dl_tput=600
    ...                                    reset_sol=${reset_sol}
   [Teardown]    Recover Test Env In Case Teardown

5GC001451_4_subSector_OpenLoop_2x2_256QAM_Rank2
    ${reset_sol}    set variable if    'SBTS00' in '${stream}'    ue_reboot    ${none}
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Start L3 Call And Verify Throughput    ul_data_transfer=40M
    ...                                 dl_data_transfer=700M
    ...                                 expect_ul_tput=20
    ...                                 expect_dl_tput=240
    ...                                    reset_sol=${reset_sol}

General SiSo RF module power reset And 5G Site eCPRI link failure break 2mins recovery non RFS
    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
    Start L3 Call And Verify Throughput   ul_data_transfer=80M
    ...                                   dl_data_transfer=1500M
    ...                                   expect_ul_tput=60
    ...                                   expect_dl_tput=1250
    FOR    ${count}    IN RANGE    3
        Log To Console    \nBegin to perform link break 10 times in try ${count}.
        5G_Site_eCPRI_link_failure_break_2mins_recovery 10 times with L3 call
    END

5GC008145_A_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_Cell_lock_and_unlock
    [Arguments]    ${frames_info}
    Update Mix Band With Multi Cells And Wait Gnb OnAir    frames_info=${frames_info}
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    Sleep    120sec
    Start Mix Band L3 Call And Verify Throughput    frames_info=${frames_info}

5GC008145_A_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_8UL_ECPRI_RF_module_power_reset
    [Arguments]    ${frames_info}
    Update Mix Band With Multi Cells And Wait Gnb OnAir    frames_info=${frames_info}
    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
    Sleep    120sec
    Start Mix Band L3 Call And Verify Throughput    frames_info=${frames_info}

5GC008145_A_SA_TDD_BF_Activated_2UE_8DL_8UL_ECPRI
    [Arguments]    ${frames_info}    ${cellid}=1
    Update PA Value For Tput
    Sleep 	90s 	Wait for calibration setup
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${cellid}
    ...                                     duration=360
    ...                                     target_avg_percent=0.98
    ...                                     min_percent=0.85
#    Start L3 Call And Verify Throughput With NRDIM     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
#    ...                                                dl_data_transfer=${frames_info[1]}[dl_data_transfer]
#    ...                                                4G_check=${False}
#    ...                                                reset_sol=${none}
#    ...                                                cellid=${cellid}

CB008145_A_61_SA_TDD_BF_Activated_2UE_1Sector_2CC_8DL_4UL_ECPRI_100Mhz_90Mhz
    [Arguments]    ${scf_file_name}    ${frames_info}    ${cellid}=5
    Update PA Value For Tput
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    run keyword if    'SBTS23R3' in '${stream}' or 'SBTS23R1' in '${stream}'    Modify SCF and Perform Commission
    ...                                                                           MOsToAdd=${Mos_TO_ADD_FOR_100_90_SBTS22R4}
    ...                                                                           ParamterToModify=${PARAMS_TO_MODIFY_FOR_100_90_SBTS22R4}
    ...                                                                           ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_100_90_SBTS22R4}
    ...                                                                           scf_path=${scf_file_path}
    ...                                                                           scf_file_name=${scf_file_name}
    run keyword if    'SBTS23R2' in '${stream}' or 'SBTS23R4' in '${stream}'    Modify SCF and Perform Commission
    ...                                                                           MOsToAdd=${Mos_TO_ADD_FOR_100_90_SBTS23R4}
    ...                                                                           ParamterToModify=${PARAMS_TO_MODIFY_FOR_100_90_SBTS23R4}
    ...                                                                           ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_100_90_SBTS23R4}
    ...                                                                           scf_path=${scf_file_path}
    ...                                                                           scf_file_name=${scf_file_name}
    run keyword if    'SBTS00' in '${stream}'
    ...                                            Modify SCF and Perform Commission    MOsToAdd=${Mos_TO_ADD_FOR_100_90}
    ...                                                                                 ParamterToModify=${PARAMS_TO_MODIFY_FOR_100_90}
    ...                                                                                 ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_100_90}
    ...                                                                                 scf_path=${scf_file_path}
    ...                                                                                 scf_file_name=${scf_file_name}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Lock Cell
    Sleep    90s    Wait for calibration setup
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${cellid}
    [Teardown]    run keyword and ignore error    Unlock Cell

CB009332_SR_A_007_NR_1S_3CC_Bandwidths_Combinations_max_DL_and_UL_throughput_with_NR100_NR30_NR20_Continuous
    [Arguments]    ${frames_info}
    Update PA Value For Tput
    Lock Cell
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${frames_info[1]}[cellid]
    ...                                     target_avg_percent=0.95
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
    ...                                    target_avg_percent=0.95
    Unlock Cell
    Online Update Second Cell CHBW And Wait Gnb On Air
    Lock Cell
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Start L3 Call And Verify Throughput    ul_data_transfer=90M
    ...                                    dl_data_transfer=800M
    ...                                    expect_ul_tput=48
    ...                                    expect_dl_tput=580
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[1]}[cellid]
    ...                                    target_avg_percent=0.95
    [Teardown]    Run Keyword And Ignore Error    Unlock Cell

CB009332_SR_A_021_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_traffic_on_cell1_NR100_30_20
    [Arguments]    ${frames_info}    ${scf_file_name}
    Modify To 1Sector 3CC 4DL4UL Config    scf_file_name=${scf_file_name}
    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Lock Cell
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=4
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                            dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                            expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                            expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[0]}[cellid]
    ...                                            throuput_duration=3000
    ...                                            target_avg_percent=0.95
    ...                                            is_need_stop_traffic=${False}
    ...                                            min_percent=0.6
    Lock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[1]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[1]}[cellid]
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                is_ulbler_calcu=${False}
    ...                                target_avg_percent=0.9
    ...                                cellid=${frames_info[0]}[cellid]
    ...                                min_percent=0.6
    Lock Cell    cell_id=${frames_info[2]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[2]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[2]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[2]}[cellid]
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                         expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                         is_ulbler_calcu=${False}
    ...                         target_avg_percent=0.9
    ...                         cellid=${frames_info[0]}[cellid]
    ...                         min_percent=0.6
    [Teardown]     run keywords    Run Keyword And Ignore Error    Stop Traffic In Teardown    AND
    ...                            Run Keyword And Ignore Error    Unlock Cell

CB009332_SR_A_005_NR_1S_3CC_Bandwidths_Combinations_SiSo_cell_lock_and_unlock_with_NR40_NR30_NR20
    [Arguments]    ${frames_info}
    Update PA Value For Tput
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Lock Cell
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=4
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                            dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                            expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                            expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[1]}[cellid]
    ...                                            throuput_duration=3000
    ...                                            target_avg_percent=0.95
    ...                                            is_need_stop_traffic=${False}
    Lock Cell    cell_id=${frames_info[0]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[0]}[cellid]
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                                expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                is_ulbler_calcu=${False}
    ...                                target_avg_percent=0.9
    ...                                cellid=${frames_info[1]}[cellid]
    Unlock Cell    cell_id=${frames_info[0]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[0]}[cellid]
    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                         expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                         is_ulbler_calcu=${False}
    ...                         target_avg_percent=0.9
    ...                         cellid=${frames_info[1]}[cellid]
    [Teardown]     run keywords    Run Keyword And Ignore Error    Stop Traffic In Teardown    AND
    ...                            Run Keyword And Ignore Error    Unlock Cell

CNI_85831_008_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR80_NR70
    [Arguments]    ${scf_file_name}    ${frames_info}
    Update PA Value For Tput
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    run keyword if    'SBTS23R1' in '${stream}' or 'SBTS23R3' in '${stream}'     Modify SCF and Perform Commission
    ...                                                                                MOsToAdd=${Mos_TO_ADD_FOR_80_70_23R1}
    ...                                                                                ParamterToModify=${PARAMS_TO_MODIFY_FOR_80_70_23R1}
    ...                                                                                ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_80_70_23R1}
    ...                                                                                scf_path=${scf_file_path}
    ...                                                                                scf_file_name=${scf_file_name}
    ...                                            ELSE
    ...                                           Modify SCF and Perform Commission    MOsToAdd=${Mos_TO_ADD_FOR_80_70}
    ...                                                                               ParamterToModify=${PARAMS_TO_MODIFY_FOR_80_70}
    ...                                                                               ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_80_70}
    ...                                                                               scf_path=${scf_file_path}
    ...                                                                               scf_file_name=${scf_file_name}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Lock Cell
    Sleep    90s    Wait for calibration setup
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${frames_info[0]}[cellid]
    ...                                     target_avg_percent=0.9
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     is_do_require_ue=${False}
    ...                                     cellid=${frames_info[1]}[cellid]
    ...                                     target_avg_percent=0.9
    [Teardown]    run keyword and ignore error    Unlock Cell

CNI_85831_010_Full_NR_2cc_on_AEHC_max_DL_and_UL_throughput_with_NR60_NR60
    [Arguments]    ${scf_file_name}    ${frames_info}
    Update PA Value For Tput
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    Modify SCF and Perform Commission    ParamterToModify=${PARAMS_TO_MODIFY_FOR_60_60}
    ...                                  ListParamterToModify=${LIST_PARAMS_TO_MODIFY_FOR_60_60}
    ...                                  scf_path=${scf_file_path}
    ...                                  scf_file_name=${scf_file_name}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Lock Cell
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=4
    Sleep    90s    Wait for calibration setup
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     cellid=${frames_info[0]}[cellid]
    ...                                     target_avg_percent=0.9
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[1]}[ul_data_transfer]
    ...                                     dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                     expect_ul_tput=${frames_info[1]}[expect_ul_tput]
    ...                                     expect_dl_tput=${frames_info[1]}[expect_dl_tput]
    ...                                     4G_check=${False}
    ...                                     reset_sol=${none}
    ...                                     is_do_require_ue=${False}
    ...                                     cellid=${frames_info[1]}[cellid]
    ...                                     target_avg_percent=0.9
    [Teardown]    run keyword and ignore error    Unlock Cell

CB009163-A-A6_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Arguments]    ${frames_info}
    Run Keyword And Ignore Error    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Sleep    3min
    ${ul_data_transfer_0}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'
    ...                                                                 ${frames_info[0]}[ul_data_transfer_${stream}]
    ...                                                                 ${frames_info[0]}[ul_data_transfer]
    ${expect_ul_tput_0}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'
    ...                                                                ${frames_info[0]}[expect_ul_tput_${stream}]
    ...                                                                ${frames_info[0]}[expect_ul_tput]
    run keyword and ignore error    Connect to gnb coam via ssl
    run keyword if    'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'
    ...    Run Keyword And Continue On Failure
    ...        Start L3 Call And Verify Throughput With NRDIM     ul_data_transfer=${ul_data_transfer_0}
    ...                                                           dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                                           4G_check=${False}
    ...                                                           cellid=${frames_info[0]}[cellid]
    ...                                                           pucchprb=${4}
    ...                                                           reset_sol=${none}
    ...    ELSE
    ...    Run Keyword And Continue On Failure
    ...        Start L3 Call And Verify Throughput     ul_data_transfer=${ul_data_transfer_0}
    ...                                                dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                                expect_ul_tput=${expect_ul_tput_0}
    ...                                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                                4G_check=${False}
    ...                                                reset_sol=${none}
    ...                                                cellid=${frames_info[0]}[cellid]
    ...                                                target_avg_percent=0.9
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
    Sleep    3min
    ${ul_data_transfer_1}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[1]}[ul_data_transfer_${stream}]
    ...                                                                 ${frames_info[1]}[ul_data_transfer]
    ${expect_ul_tput_1}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[1]}[expect_ul_tput_${stream}]
    ...                                                                ${frames_info[1]}[expect_ul_tput]
    ${expect_dl_tput_1}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[1]}[expect_dl_tput_${stream}]
    ...                                                                ${frames_info[1]}[expect_dl_tput]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer_1}
    ...                                    dl_data_transfer=${frames_info[1]}[dl_data_transfer]
    ...                                    expect_ul_tput=${expect_ul_tput_1}
    ...                                    expect_dl_tput=${expect_dl_tput_1}
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[1]}[cellid]
    ...                                    target_avg_percent=0.9
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[2]}[cellid]
    Sleep    3min
    ${ul_data_transfer_2}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[2]}[ul_data_transfer_${stream}]
    ...                                                                 ${frames_info[2]}[ul_data_transfer]
    ${expect_ul_tput_2}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[2]}[expect_ul_tput_${stream}]
    ...                                                                ${frames_info[2]}[expect_ul_tput]
    ${expect_dl_tput_2}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[2]}[expect_dl_tput_${stream}]
    ...                                                                ${frames_info[2]}[expect_dl_tput]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer_2}
    ...                                    dl_data_transfer=${frames_info[2]}[dl_data_transfer]
    ...                                    expect_ul_tput=${expect_ul_tput_2}
    ...                                    expect_dl_tput=${expect_dl_tput_2}
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[2]}[cellid]
    ...                                    target_avg_percent=0.9
    run keyword if    'SBTS00' in '${stream}'    Update prachConfigurationIndex Value For All Cellls For Trunk    prachConfigurationIndex_value=206
    ...                ELSE
    ...                                          Update prachConfigurationIndex Value For All Cellls    prachConfigurationIndex_value=206
    Sleep    3min
    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Sleep    3min
    ${expect_dl_tput_0}    set variable if  'SBTS00' in '${stream}' or 'SBTS25R1' in '${stream}'    ${frames_info[0]}[expect_dl_tput_${stream}]
    ...                                                                ${frames_info[0]}[expect_dl_tput]
    Run Keyword And Continue On Failure
    ...    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer_0}
    ...                                    dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                    expect_ul_tput=${expect_ul_tput_0}
    ...                                    expect_dl_tput=${expect_dl_tput_0}
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[0]}[cellid]
    ...                                    target_avg_percent=0.9
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                 scf_file_name=SCF_${stream}
    ...                                                                 is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                is_x2_check_from_gnb_needed=${False}

General_SiSo_Cell_lock_and_unlock_with_traffic_on_cell1_NR100_40_20
    [Arguments]    ${frames_info}    ${scf_file_name}
    Get SCF File Path
    ${scf_file_path}    Join Path    ${scf_full_path}    ${scf_file_name}
    Modify SCF and Perform Commission    ParameterToDelete=${PARAMS_TO_DELETE_ALL_CEll_FRAME_STRYECTURE}
    ...                                  ListToAdd=${LIST_TO_ADD_ALL_CEll_1208_FRAME}
    ...                                  ParamterToModify=${PARAMS_TO_MODIFY_ALL_1208_FRAME}
    ...                                  ListParamterToModify=${LIST_PARAMS_TO_MODIFY_1208_FRAME}
    ...                                  scf_path=${scf_file_path}
    ...                                  scf_file_name=${scf_file_name}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Sleep    3min
    Run Keyword And Ignore Error    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    ${frames_info[0]}[ul_data_transfer_${stream}]
    ...                                                                 ${frames_info[0]}[ul_data_transfer]
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    ${frames_info[0]}[expect_ul_tput_${stream}]    ${frames_info[0]}[expect_ul_tput]
    Start L3 Call And Verify Throughput     ul_data_transfer=${ul_data_transfer}
    ...                                            dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                            expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                            expect_dl_tput=${expect_ul_tput}
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[0]}[cellid]
    ...                                            throuput_duration=3000
    ...                                            target_avg_percent=0.95
    ...                                            is_need_stop_traffic=${False}
    ...                                            min_percent=0.6
    Lock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[1]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[1]}[cellid]
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                                expect_ul_tput=${expect_ul_tput}
    ...                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                is_ulbler_calcu=${False}
    ...                                target_avg_percent=0.9
    ...                                cellid=${frames_info[0]}[cellid]
    ...                                min_percent=0.6
    Lock Cell    cell_id=${frames_info[2]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[2]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[2]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[2]}[cellid]
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                         is_ulbler_calcu=${False}
    ...                         target_avg_percent=0.9
    ...                         cellid=${frames_info[0]}[cellid]
    ...                         min_percent=0.6
    Stop Traffic In Teardown
    Sleep    3min
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[0]}[cellid]
    ...                                    target_avg_percent=0.9
    ...                                    min_percent=0.6
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic In Teardown

General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Arguments]    ${frames_info}    ${enb_cell_id}
    ${ul_data_transfer}    set variable if  'SBTS00' in '${stream}'    ${frames_info[0]}[ul_data_transfer_${stream}]
    ...                                                                 ${frames_info[0]}[ul_data_transfer]
    ${expect_ul_tput}    set variable if  'SBTS00' in '${stream}'    ${frames_info[0]}[expect_ul_tput_${stream}]    ${frames_info[0]}[expect_ul_tput]
    Start L3 Call And Verify Throughput     ul_data_transfer=${ul_data_transfer}
    ...                                            dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                            expect_ul_tput=${expect_ul_tput}
    ...                                            expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[0]}[cellid]
    ...                                            throuput_duration=3000
    ...                                            target_avg_percent=0.9
    ...                                            is_need_stop_traffic=${False}
    ...                                            min_percent=0.6
    Lock eNB Cell For Multiple Rat    cell_index=${enb_cell_id}
    Sleep    10sec
    Unlock eNB Cell For Multiple Rat    cell_index=${enb_cell_id}
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                         is_ulbler_calcu=${False}
    ...                         target_avg_percent=0.9
    ...                         cellid=${frames_info[0]}[cellid]
    ...                         min_percent=0.6
    Stop Traffic In Teardown
    Sleep    3min
    Start L3 Call And Verify Throughput    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                    expect_ul_tput=${expect_ul_tput}
    ...                                    expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                    is_do_require_ue=${False}
    ...                                    4G_check=${False}
    ...                                    reset_sol=${none}
    ...                                    cellid=${frames_info[0]}[cellid]
    ...                                    target_avg_percent=0.9
    ...                                    min_percent=0.6
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic In Teardown

CB010744_C_04_General_SiSo_E2E_system_setup_with_data_transfer_for_conducted_multicarrier_1x16DL8UL_2x8DL4UL
    [Arguments]    ${frames_info}    ${scf_file_name}
#    Set MCS Phase And ATT For 10744
#    Run Keyword And Ignore Error    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
#    Sleep    3min
#    DingLi_Client.UE Prepare
#    DingLi_Client.SA And NSA Mode Change
#    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
#    sleep    5sec
#    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach    ues_index=${${0}}
#    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
#    ...    ues_index=${${0}}    expect_pci=721
#    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
#    DingLi_Client.Start Data Transfer    ues_index=${${0}}
#    ...                                  ul_throughput=${frames_info[0]}[ul_data_transfer]
#    ...                                  dl_throughput=${frames_info[0]}[dl_data_transfer]
#    @{direction_component_list}    Create List    UL    DL
#    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
#    ...                                                                duration=120
#    ...                                                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
#    ...                                                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
#    ...                                                                cellid=${frames_info[0]}[cellid]
#    ...                                                                target_avg_percent=0.90
#    ...                                                                ue_type=huawei_sigspark
#    ...                                                                check_source=aasyslog
#    ...                                                                min_percent=0
#    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer     ues_index=${${0}}
#    Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${${0}}
    ${pa_value}    set variable if  'SBTS00' in '${stream}'    20    10
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
    Modify to 3S3CC 16DL4UL    scf_file_name=${scf_file_name}
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
#    Modify to 3S3CC 16DL4UL    scf_file_name=${scf_file_name}
#    #--- Do l3 call on cell 2 --- #
#    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[1]}[cellid]
#    Sleep    3min
#    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach    ues_index=${${0}}
#    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
#    ...    ues_index=${${0}}    expect_pci=722
#    DingLi_Client.Start Data Transfer    ues_index=${${0}}
#    ...                                  ul_throughput=${frames_info[1]}[ul_data_transfer]
#    ...                                  dl_throughput=${frames_info[1]}[dl_data_transfer]
#    @{direction_component_list}    Create List    UL    DL
#    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
#    ...                                                                duration=120
#    ...                                                                expect_ul_tput=${frames_info[1]}[expect_ul_tput]
#    ...                                                                expect_dl_tput=${frames_info[1]}[expect_dl_tput]
#    ...                                                                cellid=${frames_info[1]}[cellid]
#    ...                                                                target_avg_percent=0.90
#    ...                                                                ue_type=huawei_sigspark
#    ...                                                                check_source=aasyslog
#    ...                                                                min_percent=0
#    [Teardown]   run keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer     ues_index=${${0}}    AND
#    ...                          Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${${0}}
    [Teardown]     Run Keyword And Ignore Error    Stop Traffic In Teardown

CB010889_SR_AB_01_3CC_8D8U_data_transfer_100+50+20_1116_0ms
    [Arguments]    ${frames_info}
    Set MCS Phase And ATT For 10744
    Run Keyword And Ignore Error    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Sleep    3min
    DingLi_Client.UE Prepare
    DingLi_Client.SA And NSA Mode Change
    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
    sleep    5sec
    ${5G_band}    Set Variable    78
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach    ues_index=${${0}}
    ...                                                                             5G_band=${5G_band}
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info
    ...    ues_index=${${0}}    expect_pci=721
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    DingLi_Client.Start Data Transfer    ues_index=${${0}}
    ...                                  ul_throughput=${frames_info[0]}[ul_data_transfer]
    ...                                  dl_throughput=${frames_info[0]}[dl_data_transfer]
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                                                cellid=${frames_info[0]}[cellid]
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Lock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[1]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[1]}[cellid]
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                                                cellid=${frames_info[0]}[cellid]
    ...                                                                target_avg_percent=0.90
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    [Teardown]   run keywords    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer     ues_index=${${0}}    AND
    ...                          Run Keyword And Ignore Error    DingLi_Client.Detach    ues_index=${${0}}

CB012725_CA_3CC_16D8U_30km_100+50+40_data_transfer
    [Arguments]    ${frames_info}
    Run Keyword And Ignore Error    Update UE Attach Cell Index on SA Mode    attach_cell_index=${frames_info[0]}[cellid]
    Start L3 Call And Verify Throughput     ul_data_transfer=${frames_info[0]}[ul_data_transfer]
    ...                                            dl_data_transfer=${frames_info[0]}[dl_data_transfer]
    ...                                            expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                            expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                            4G_check=${False}
    ...                                            reset_sol=${none}
    ...                                            cellid=${frames_info[0]}[cellid]
    ...                                            throuput_duration=3000
    ...                                            target_avg_percent=0.9
    ...                                            is_need_stop_traffic=${False}
    ...                                            min_percent=0.6
    Lock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=${frames_info[1]}[cellid]
    Sleep    10sec
    Unlock Cell    cell_id=${frames_info[1]}[cellid]
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=${frames_info[1]}[cellid]
    ${direction_component_list}=  Create List    UL_L2LO    DL_L2LO
    Run Keyword And Continue On Failure
    ...    Check Tput With Power UE    direction_component_list=${direction_component_list}
    ...                                expect_ul_tput=${frames_info[0]}[expect_ul_tput]
    ...                                expect_dl_tput=${frames_info[0]}[expect_dl_tput]
    ...                                is_ulbler_calcu=${False}
    ...                                target_avg_percent=0.9
    ...                                cellid=${frames_info[0]}[cellid]
    ...                                min_percent=0.6
    [Teardown]    Run Keyword And Ignore Error    Stop Traffic In Teardown
