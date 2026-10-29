*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_common_ute.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000702/Resources/5GC000702_variables.py

*** Keywords ***
5GC001274_008_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP_100MHz
    [Documentation]    CHBW:100MHz
    Update Framestructure And CHBW    update_param_name=${FRAME_TO_11160ms_100MHz_4Symbols_AWHQE}
    Start L3 Call And Verify Throughput    ul_data_transfer=75M
    ...                                    dl_data_transfer=1700M
    ...                                    expect_ul_tput=70.5
    ...                                    expect_dl_tput=1540
    ...                                    duration=360
    ...                                    target_avg_percent=0.98
    ...                                    min_percent=0.85
    ...                                    reset_sol=${none}

FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_60MHz
    [Documentation]    CHBW:60MHz
    ...                Feature_ID:FGCR-3610-B
    Update Framestructure And CHBW    update_param_name=${FRAME_TO_11160ms_60MHz_4Symbols_AWHQE}
    Start L3 Call And Verify Throughput    ul_data_transfer=50M
    ...                                    dl_data_transfer=900M
    ...                                    expect_ul_tput=29.3
    ...                                    expect_dl_tput=757
    ...                                    reset_sol=${none}

FGCR4454_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_40MHz_AWHQE
    [Documentation]    CHBW:40MHz
    [Tags]    Qualcomm    Classical
    Update Framestructure And CHBW    update_param_name=${FRAME_TO_1070_40MHz_2Symbols}
    Start L3 Call And Verify Throughput    ul_data_transfer=75M
    ...                                    dl_data_transfer=600M
    ...                                    expect_ul_tput=35
    ...                                    expect_dl_tput=426
    ...                                    reset_sol=${none}

FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_80MHz
    [Documentation]    CHBW:80MHz
    ...    Feature_ID:FGCR-3610-C
    Get gNb Cu Type Value
#    Start L3 Call And Verify Throughput    ul_data_transfer=70M
#    ...                                    dl_data_transfer=1300M
#    ...                                    expect_ul_tput=66
#    ...                                    expect_dl_tput=1223
#    ...                                    duration=360
#    ...                                    target_avg_percent=0.98
#    ...                                    min_percent=0.85
    Start L3 Call And Verify Throughput With NRDIM    ul_data_transfer=70M
    ...                                               dl_data_transfer=1300M
    ...                                               ue_ul_layer=${1}
    ...                                               reset_sol=${none}

5GC001157_09_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_20MHz
    [Documentation]    CHBW:20MHz
    ...    Feature_ID:FGCR-3610;FGCR-3626  for 1116 3ms
    run keyword and ignore error    Update Framestructure And CHBW    update_param_name=${FRAME_TO_11163ms_20MHz_4Symbols}
    Update msg1FrequencyStart Value    msg1FrequencyStart=10
#    Start L3 Call And Verify Throughput    ul_data_transfer=20M
#    ...                                    dl_data_transfer=400M
#    ...                                    expect_ul_tput=13
#    ...                                    expect_dl_tput=287
#    ...                                    duration=360
#    ...                                    target_avg_percent=0.98
#    ...                                    min_percent=0.85

    Start L3 Call And Verify Throughput With NRDIM    ul_data_transfer=20M
    ...                                               dl_data_transfer=400M
    ...                                               ue_ul_layer=${1}
    ...                                               reset_sol=${none}


FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_50MHz_AWHQE
    [Documentation]    CHBW:50MHz
    ...                Feature_ID:FGCR-3610-B
    Update Framestructure And CHBW    update_param_name=${FRAME_TO_1070_50MHz_2Symbols}
    Start L3 Call And Verify Throughput    ul_data_transfer=50M
    ...                                    dl_data_transfer=800M
    ...                                    expect_ul_tput=36
    ...                                    expect_dl_tput=530
    ...                                    reset_sol=${none}

FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_90MHz_AWHQE
    [Documentation]    CHBW:90MHz
    ...                Feature_ID:FGCR-3610-B
    run keyword if    'SBTS00' in '${stream}'    Change CHBW and Frame related params with WebUI    updated_params=${UPDATE_PARAMS_1208_90M}
    ...                             ELSE
    ...                                          Update Framestructure And CHBW    update_param_name=${FRAME_TO_1208_90MHz_2Symbols}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword Unless    'SBTS00' in '${stream}'    RRH_common_keyword.General SiSo RU Lock Unlock
    Sleep    3min
    Start L3 Call And Verify Throughput    ul_data_transfer=70M
    ...                                    dl_data_transfer=1200M
    ...                                    expect_ul_tput=45
    ...                                    expect_dl_tput=1100
    ...                                    duration=360
    ...                                    target_avg_percent=0.8
    ...                                    reset_sol=${none}
    [Teardown]    run keywords    Run Keyword And Ignore Error    Recommission With Backup SCF File And Wait Gnb On Air
    ...                                                                                                 scf_file_name=SCF_${stream}
    ...                                                                                                is_pdl_checking_needed=${False}    AND
    ...                           Run Keyword And Ignore Error    Perform gNB Restart And Check on air via rest api
    ...                                                                                                is_x2_check_from_gnb_needed=${False}