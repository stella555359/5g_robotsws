# *** Settings ***
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        owner_l3gao    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Test Timeout      600 minutes
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# 
# Documentation
# ...    8701 APLO porting ,tapering enable ,but lowerSE ,so disable
# ...    8X4 dlmimo enable ,cell on air fail ,need raise issue
# ...   2UE two position ,one list
# ...   40mhz fail
# ...   NSA buffer not enough.
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# #${SCFC_NAME}      SCFC_87957_Case01_APLO.xml
# #${SCFC_NAME}      SCFC_87957_Case01_APLO_100mhz.xml
# #${SCFC_NAME}      SCFC_8701_case01_aplo_AEHC_mengya.xml   #corr 90
# ${SCFC_NAME}      SCFC_8701_case01_aplo_AEHC_mengya_enhance.xml
# ${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO.xml
# ${WTS_NAME}       wts_aehc_8701_aplo_nsa.cfg
# ${UE_NUM}         8
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# @{Rdparameter}    0x340000:15     0x580587:16     0x580450:6     0x5801c8:0
# ${Position1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${Position8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${EGATE_TAG}  egate_8701
# ${peak_mu}    4268
# ${peak_mu_mengya}    804*4
# 
# *** Test Cases ***
# CNI87957_Case01_8UEs_4Pos_rank2_pairing_SA
#     step1: gNB and AP prepair
#     step2_3: move 8UE to 4Pos
# #    step4: move 6UE to Pos0
# #    step5: move 8UE to 4Pos and mix data
# #    step6: move 8UE to 4Pos and bler add    #only for  0x580450:6
# 
# 
# *** Keywords ***
# step1: gNB and AP prepair
#     Modify 8701 Swconfig
#     Active GNB L2 feature debug traces
#     Get and Update BSR File    ${par_of_bsr_name}
#     Prepare gnb onair
# 
# step2_3: move 8UE to 4Pos
#     log to console  ${\n}---step2_3 move 8UE to 4Pos---
#     Start capture gnb and ap syslog in '8UE_in_4Pos' file
#     Set SA 8UEs in 4 Pos
#     Attach '${UE_NUM}' SA UE
#     Internal send DL data
#     Airphone override to rank2
#     Wait '3s ' to stable
#     run keyword and continue on failure   Check 8UE_in_4Pos throughput
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_8UE_in_4Pos_snapshot.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '8UE_in_4Pos' file
# 
# step4: move 6UE to Pos0
#     log to console  ${\n}---step4 move 6UE to Pos0---
#     Start capture gnb and ap syslog in '6UE_in_POS0' file
#     Set SA 6UEs in Pos0
#     Attach '${UE_NUM}' SA UE
#     Internal send DL data 6plus2
# #    Internal send DL data
#     Airphone override to rank2
#     Wait '3s ' to stable
#     run keyword and continue on failure   Check 6UE_in_POS0 throughput
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_8UE_in_4Pos_snapshot.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '6UE_in_POS0' file
# 
# 
# step5: move 8UE to 4Pos and mix data
#     log to console  ${\n}---step5: move 8UE to 4Pos and mix data---
#     Start capture gnb and ap syslog in '8UE_in_4Pos_mixdata' file
#     Set SA 8UEs in 4 Pos
#     Attach '${UE_NUM}' SA UE
#     Internal send DL data mixdata
#     Airphone override to rank2
#     Wait '3s ' to stable
#     run keyword and continue on failure   Check 8UE_in_4Pos throughput mixdata
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_8UE_in_4Pos_snapshot.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '8UE_in_4Pos_mixdata' file
# 
# step6: move 8UE to 4Pos and bler add
#     log to console  ${\n}---step6: move 8UE to 4Pos and bler add---
#     Start capture gnb and ap syslog in '8UE_in_4Pos_bler' file
#     Set SA 8UEs in 4 Pos
#     Attach '${UE_NUM}' SA UE
#     Internal send DL data
#     Airphone override to rank2
#     Wait '3s ' to stable
#     run keyword and continue on failure   Check 8UE_in_4Pos throughput
#     add bler to UE1
#     run keyword and continue on failure    Get 87957 counter
#     log to console   ttitrace capture about 120s
#     Wait '120s' for stable
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     log to console  ${\n}---capture snapshot---
#     Collect GNB SnapShot     target_file_name=${test_log_directory()}/All/gnb_comon_8UE_in_4Pos_snapshot.zip
#     log to console    stop syslog and check wrn
#     Stop capture gnb and ap syslog in '8UE_in_4Pos_bler' file
# 
# 
# add bler to UE1
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=20,2,3,4,5   #add bler
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# Get 87957 counter
#     log to console    ${\n}---wait for 100s for counter---
#     Wait '100s' for stable
#     log to console    ${\n}---capture counter start---
#     ${PRB_DL_SU_MIMO_LAYER_list}   create list
#     ${PRB_DL_MU_MIMO_LAYER_list}   create list
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    counter remianing time is ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     : FOR    ${num}    IN RANGE    1    5
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    set suite variable     ${PRB_DL_SU_MIMO_${num}LAYER}     ${result}
#     \    append to list    ${PRB_DL_SU_MIMO_LAYER_list}    ${PRB_DL_SU_MIMO_${num}LAYER}
#     \    log to console    ${PRB_DL_SU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    5    10
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3400${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    10    12
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-3
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     : FOR    ${num}    IN RANGE    16    24
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C340${num}    cell_id=1
#     \    ${num_layer}   evaluate   ${num}-7
#     \    set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
#     \    log to console    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
#     \    log to console    ${PRB_DL_MU_MIMO_LAYER_list}
#     log to console    SUlayer 1_2_3_4 ${PRB_DL_SU_MIMO_LAYER_list}
#     log to console    MUlayer 2_3_4_5_6_7_8_9_10_11_12_13_14_15_16 ${PRB_DL_MU_MIMO_LAYER_list}
# 
#     ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${Cell1_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
#     log to console    Cell1_TP_total is ${Cell1_TP_total}
# 
# Check 8UE_in_4Pos throughput
#     Wait until keyword succeeds    60s    5s    Verify 8UE_in_4Pos throughput
# 
# Check 8UE_in_4Pos throughput mixdata
#     Wait '10s' for stable
#     Wait until keyword succeeds    60s    5s    Verify 8UE_in_4Pos throughput mixdata
# 
# Verify 8UE_in_4Pos throughput mixdata
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>6000    #lei 240000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    8UEs_DL_TP_total are ${UEs_TP_DL}
#     log to console    8UEs_UL_TP_total are ${UEs_TP_UL}
# 
# Verify 8UE_in_4Pos throughput
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>190000    #lei 240000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    8UEs_DL_TP_total are ${UEs_TP_DL}
#     log to console    8UEs_UL_TP_total are ${UEs_TP_UL}
# 
# Check 6UE_in_POS0 throughput
#     Wait until keyword succeeds    60s    5s    Verify 6UE_in_POS0 throughput
# 
# Verify 6UE_in_POS0 throughput
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>30000    #250000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    ${UEs_TP_DL}
#     log to console    ${UEs_TP_UL}
# 
# Check 8UE_in_8POS throughput
#     Wait until keyword succeeds    60s    5s    Verify 8UE_in_8POS throughput
# 
# Verify 8UE_in_8POS throughput
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>130000    #250000
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    ${UEs_TP_DL}
#     log to console    ${UEs_TP_UL}
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_case1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# 
# 
# Internal send DL data 6plus2
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    run keyword if     ${num}<7    SA send mutiple trf dl data    ${num}    1    120M    pdu_id=${num}    protocol=tcp
#     \    run keyword if     ${num}>6    SA send mutiple trf dl data    ${num}    3    175M    pdu_id=${num}    protocol=tcp
#     \    SA send mutiple trf ul data    ${num}    2    15M    pdu_id=${num}    protocol=tcp
#     \    log to console    data sent to ue${num}
#     \    Wait '3s ' to stable
# 
# Wait '${time} ' to stable
#     sleep    ${time}
# 
# Detach SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_sa_detach    ue_id=${num}
#     \    Wait '3s' for stabible
# 
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case1.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Verify throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${sa_dl_tput}=    Airphone SA Get Throughput    ${num}    DL    ${num}
#     \    run keyword and continue on failure    Should be true    ${sa_dl_tput}>300000
# 
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify '${UE_NUM}' SA UEs throughput
# 
# Verify '${UE_NUM}' SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure     should_be_true    ${dl_throughput_pcell}>250000
# 
# Modify 8701 Swconfig
#     Add GNB swconfig    @{Rdparameter}
# 
# Set SA 8UEs in 4 Pos
#     ${SET_UE1_Position}    set variable    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE2_Position}    set variable    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE3_Position}    set variable    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     ${SET_UE4_Position}    set variable    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     ${SET_UE5_Position}    set variable    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     ${SET_UE6_Position}    set variable    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     ${SET_UE7_Position}    set variable    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     ${SET_UE8_Position}    set variable    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${Position${num}}
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${SET_UE${num}_Position}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=10
# 
# Attach '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   SA send mutiple trf dl data    ${num}    1   100    ${num}
#     \   Wait '2s' for stable
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}
# 
# Airphone override to rank2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=6 cqi\=15 ri\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-8 testmode\=csi_override action\=activate profile_id\=6
# 
# 
# 
# 
# Set SA 6UEs in Pos0
#     ${SET_UE1_Position}    set variable    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE2_Position}    set variable    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE3_Position}    set variable    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE4_Position}    set variable    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE5_Position}    set variable    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE6_Position}    set variable    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE7_Position}    set variable    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     ${SET_UE8_Position}    set variable    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${Position${num}}
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${SET_UE${num}_Position}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=10
# 
# Set SA 8UEs in 8Pos
#     ${SET_UE1_Position}    set variable    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     ${SET_UE2_Position}    set variable    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     ${SET_UE3_Position}    set variable    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     ${SET_UE4_Position}    set variable    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     ${SET_UE5_Position}    set variable    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
#     ${SET_UE6_Position}    set variable    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
#     ${SET_UE7_Position}    set variable    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
#     ${SET_UE8_Position}    set variable    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 sinr_target_srs\=100 sinr_target_pucch\=-300 noise_srs\=-1053
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${Position${num}}
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ${SET_UE${num}_Position}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=10
# 
# Attach '${UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
#     \   NSA send ue '${num}' mutiple trf '5' for each '175M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '5M' UL data
# 
# check_SRS_resource_and_PDSCH_scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
#     \    should_be_true    ${dl_throughput_pcell}>250000
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${UE_DL_TP_list}   create list
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   target TP is ${throughput}
#     \    run keyword and continue on failure    should be true  ${result}>${throughput}
#     \    append to list   ${UE_DL_TP_list}    ${result}
#     log to console    ${UE_DL_TP_list}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
#     log to console  ${\n}---decode tti start---
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# 
# Internal send DL data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    SA send mutiple trf dl data    ${num}    2    175M    pdu_id=${num}    protocol=tcp
#     \    SA send mutiple trf ul data    ${num}    2    15M    pdu_id=${num}    protocol=tcp
#     \    log to console    data sent to ue${num}
#     \    Wait '1s ' to stable
# 
# Internal send DL data mixdata
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    run keyword if     ${num}<3    SA send mutiple trf dl data    ${num}    1    10M    pdu_id=${num}    protocol=tcp
#     \    run keyword if     ${num}>2    SA send mutiple trf dl data    ${num}    2    175M    pdu_id=${num}    protocol=tcp
#     \    SA send mutiple trf ul data    ${num}    2    15M    pdu_id=${num}    protocol=tcp
#     \    log to console    data sent to ue${num}
#     \    Wait '1s ' to stable
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   Airphone SA Stop Data Traffic     ${num}     BI    ${num}
# #    \   Airphone SA Stop Data Traffic     ${num}     DL    ${num}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=deactivate profile_id\=10
#     \   airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=deactivate profile_id\=6 scell\=0
#     \   log to console    detach ue${num} and deactive testmode
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=6 delete\=1
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=10 delete\=1
