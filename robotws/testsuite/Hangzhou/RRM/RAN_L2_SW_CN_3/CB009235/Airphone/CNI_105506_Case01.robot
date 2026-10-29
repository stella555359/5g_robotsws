# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    Author_lei.4.gao@nokia-sbell.com    AP    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# #${SCFC_NAME}      CNI_105506_case01.xml
# ${SCFC_NAME}      CNI_105506_case01_non_bwp.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_8x4_GL.xml
# ${WTS_NAME}    wts_9235_1cell_SA_NSA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# 
# ${egate_tag}    egate
# 
# ${TP_PEAK_DL}    1300000
# ${TP_PEAK_DL_MU}  5200000
# ${TP_PEAK_UL}    150000
# 
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${TP_sum}    0
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# @{TOOLS_LIST}    luashark    bip_script    common_config_golden    common_config_private    mcshark   ttitrace_decode
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE21}    ul_mimo_srs_beam_pos_nr profile_id\=21 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE22}    ul_mimo_srs_beam_pos_nr profile_id\=22 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE23}    ul_mimo_srs_beam_pos_nr profile_id\=23 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# 
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=57 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE24}    ul_mimo_srs_beam_pos_nr profile_id\=24 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=47 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE25}    ul_mimo_srs_beam_pos_nr profile_id\=25 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=37 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE26}    ul_mimo_srs_beam_pos_nr profile_id\=26 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=27 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE27}    ul_mimo_srs_beam_pos_nr profile_id\=27 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=17 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE28}    ul_mimo_srs_beam_pos_nr profile_id\=28 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=7 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE29}    ul_mimo_srs_beam_pos_nr profile_id\=29 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-3 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE30}    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-13 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE31}    ul_mimo_srs_beam_pos_nr profile_id\=31 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-23 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE32}    ul_mimo_srs_beam_pos_nr profile_id\=32 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-33 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE33}    ul_mimo_srs_beam_pos_nr profile_id\=33 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-43 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE34}    ul_mimo_srs_beam_pos_nr profile_id\=34 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-53 zenith\=-19 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${PROFILE35}    ul_mimo_srs_beam_pos_nr profile_id\=35 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-63 zenith\=-22 srs_transmit_power_per_port\=-320,-320,-250,-250
# ${rdParallelSchScheme}    10
# ${rdParallelSchScheme_2}    0
# ${excel_path}    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/CB009235/Airphone/log/CNI105506.xls
# ${UE_NUM}    16  # 68
# #${command}    sudo ./gnb_logs -t -c -b -cp
# ${command}    sudo ./gnb_logs -t -c
# 
# 
# *** Test Cases ***
# CNI_105506_Case01_68UEs_34Pos_pairing_RD10
# 	Add RD    corre=${rdParallelSchScheme}
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
# #    step3:parallel scheduling 'false' ‘nonbler’ ‘RD_${rdParallelSchScheme}’ and check counter '1'
#     Airphone SA Detach UE
# 
# 
# *** Keywords ***
# Add RD
#     [Arguments]    ${corre}
# #    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
# #    Add GNB swconfig    0x580539:16   #Num UE threshold,to collect trace
#     Add GNB swconfig    0x340000:15
#     Add GNB swconfig    0x580450:${rdParallelSchScheme}
#     Add GNB swconfig    0x57000B:0xFFFFFFFF
#     Add GNB swconfig    0x57000C:0xFFFFFFFF
# 
# step1:get ready for gnb
# #    Active GNB L2 feature debug traces
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/.uplane    WRN/L2-PS
# 	Set Test Variable    ${custom_error}
#     Get gnb_logs from git
# 	modify gnb_logs config
# 	Prepare gnb onair
# 	Airphone Cleanup Egate Console Log
# 	Build excel table
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     Start capture only gnb syslog in 'step2_attach' file
#     Start collect logs by gnb_logs    ${command}    #debug
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2_attach' file '${custom_error}'
# 	Start capture only gnb syslog in 'step2_attach_to_Send_data' file
# 	set '${UE_NUM}' SA UEs Pos
# 	SA send data '${UE_NUM}' UEs
# #	add UEs bler
# #	Wait for '0.5s' to stop collect logs by gnb tool   #debug
# 	Wait '15s' for stable
#     run keyword and continue on failure	   Get UEs TP for debug
#     run keyword and continue on failure	   Get UEs TP for debug
#     Wait for '0.5s' to stop collect logs by gnb tool   #debug
#     capture snapshot start once    step2
# #    run keyword and continue on failure    Collect ttitrace and Check
# #    ...    tti_tag=tti_step2    ini_file=CNI_case01_tti_dl_step3
# #	run keyword and continue on failure	   Collect bip and Check
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2_attach_to_Send_data' file '${custom_error}'
# 
# 
# step3:parallel scheduling '${actMuAwareTdSch}' ‘${bler}’ ‘${RD}’ and check counter '${table_tag}'
#     Log To Console   \n---------step3:parallel scheduling----------
#     Start capture only gnb syslog in 'syslog_step3_${actMuAwareTdSch}_${bler}_${RD}' file
# #    online change parameters    delta_105506_case01    ${actMuAwareTdSch}    10    100
# #    Wait '10s' for stable
#     run keyword and continue on failure	   Get UEs TP for debug
#     run keyword and continue on failure    Collect ttitrace and Check
#     ...    tti_tag=tti_step3_${actMuAwareTdSch}_${bler}_${RD}    ini_file=CNI_case01_tti_dl_step3
#     run keyword and continue on failure	   Get UEs TP for debug
#     ${PM_counter_file}    Get counter file
#     ${8701_pair_counter_for_table}    Ideal line PRB_mulayer counter check    ${PM_counter_file}
# #    ${9235_kpi_list}    KPI counter check    ${PM_counter_file}
# #    Record result for 9235 perfomance    ${table_tag}    ${actMuAwareTdSch}    ${bler}    ${RD}
# #    ...    ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     run keyword and continue on failure
#     ...    Stop capture gnb and ap syslog in 'syslog_step3_${actMuAwareTdSch}_${bler}_${RD}' file '${custom_error}'
#     capture snapshot start once    step3
# 
# step4:parallel scheduling '${actMuAwareTdSch}' ‘${bler}’ ‘${RD}’ and check counter '${table_tag}'
#     Log To Console   \n---------step3:parallel scheduling----------
#     Start capture only gnb syslog in 'syslog_step4_${actMuAwareTdSch}_${bler}_${RD}' file
#     add UEs bler
#     online change parameters    delta_105506_case01    ${actMuAwareTdSch}    10    100
#     Wait '10s' for stable
#     run keyword and continue on failure    Collect ttitrace and Check
#     ...    tti_tag=tti_step3_${actMuAwareTdSch}_${bler}_${RD}    ini_file=CNI_case01_tti_dl_step4
#     run keyword and continue on failure	   Get UEs TP for debug
#     ${PM_counter_file}    Get counter file
#     ${8701_pair_counter_for_table}    Ideal line PRB_mulayer counter check    ${PM_counter_file}
# #    ${9235_kpi_list}    KPI counter check    ${PM_counter_file}
# #    Record result for 9235 perfomance    ${table_tag}    ${actMuAwareTdSch}    ${bler}    ${RD}
# #    ...    ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     run keyword and continue on failure
#     ...    Stop capture gnb and ap syslog in 'syslog_step4_${actMuAwareTdSch}_${bler}_${RD}' file '${custom_error}'
# 
# step5:kpi and counter check
#     Log To Console   \n--------step5:kpi and counter check-------
#     ${sum_prb_layer_X_layer1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    1
#     ${sum_prb_layer_X_layer2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    2
#     ${sum_prb_layer_X_layer3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    3
#     ${sum_prb_layer_X_layer4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    4
#     ${KPI_NR_5242b_cell_tp_avg1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    1
#     ${KPI_NR_5242b_cell_tp_avg2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    2
#     ${KPI_NR_5242b_cell_tp_avg3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    3
#     ${KPI_NR_5242b_cell_tp_avg4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    4
#     run keyword and continue on failure    should be true    ${sum_prb_layer_X_layer2}>${sum_prb_layer_X_layer4}
#     run keyword and continue on failure    should be true    ${KPI_NR_5242b_cell_tp_avg2}>${KPI_NR_5242b_cell_tp_avg4}
#     ${9235_sum_prb_layer_gain}    evaluate    (${sum_prb_layer_X_layer2}-${sum_prb_layer_X_layer4})/${sum_prb_layer_X_layer4}
#     log to console    sum_prb_layer_gain is ${9235_sum_prb_layer_gain}
#     run keyword and continue on failure    should be true    ${9235_sum_prb_layer_gain}>0.14
#     ${9235_cell_avg_gain}    evaluate    (${KPI_NR_5242b_cell_tp_avg2}-${KPI_NR_5242b_cell_tp_avg4})/${KPI_NR_5242b_cell_tp_avg4}
#     log to console    9235_cell_avg_gain is ${9235_cell_avg_gain}
#     run keyword and continue on failure    should be true    ${9235_cell_avg_gain}>0.19
#     capture snapshot start once    step5
# 
# 
# SA send data '${UE_NUM_SA}' UEs
#     log to console    push data for UEs
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    4   160M   ${gw_pdu_r}    tcp
# #    \    SA send mutiple trf dl data    ${num}    1   30M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    3M   ${gw_pdu_r}
# 
# Build excel table
#     ${colomn_9235}   create list
#     : FOR    ${num}    IN RANGE    2    17
#     \    append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer${num}
#     append to list    ${colomn_9235}    sum_prb_layer_X_layer
#     append to list    ${colomn_9235}    PRB_DL_SU_MIMO_layer_total
#     append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer_total
#     append to list    ${colomn_9235}    KPI_NR_5055_bresidual_bler    KPI_NR_5054a_iniBler    KPI_NR_5108dSE_downlink    KPI_NR_5109dSE_uplink
#     append to list    ${colomn_9235}    KPI_NR_5242b_cell_tp_avg    KPI_NR_5258a_cell_tp_max    KPI_NR_5100b_ue_tp_avg    KPI_NR_5192c_UE_num_perTTi
#     append to list    ${colomn_9235}    PRB_DL_MU_MIMO_paired_UE_0    PRB_DL_MU_MIMO_paired_UE_2    PRB_DL_MU_MIMO_paired_UE_3
#     append to list    ${colomn_9235}    PRB_DL_MU_MIMO_paired_UE_4    PRB_DL_MU_MIMO_paired_UE_5    PRB_DL_MU_MIMO_paired_UE_6
#     append to list    ${colomn_9235}    PRB_DL_MU_MIMO_paired_UE_7    PRB_DL_MU_MIMO_paired_UE_8
#     modify excel cell       ${excel_path}     Sheet1     0    0    ${SOFTWARE_INFO}_CNI105506_perfomance_case01
#     : FOR    ${num}    IN RANGE    0    34
#     \    ${num_table}    evaluate    ${num}+1
#     \    modify excel cell       ${excel_path}     Sheet1     ${num_table}    0    ${colomn_9235[${num}]}
# 
# 
# Record result for 9235 perfomance
#     [Arguments]     ${table_tag}    ${actMuAwareTdSch}    ${bler}    ${RD}    ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     modify excel cell       ${excel_path}      Sheet1     0    ${table_tag}    CNI105506_${actMuAwareTdSch}_${bler}_${RD}
#     : FOR    ${num}    IN RANGE    0    18
#     \    ${num_table}    evaluate    ${num}+1
#     \    modify excel cell       ${excel_path}     Sheet1     ${num_table}    ${table_tag}
#     ...    ${8701_pair_counter_for_table[${num}]}
#     : FOR    ${num}    IN RANGE    0    8
#     \    ${num_table}    evaluate    ${num}+19
#     \    modify excel cell       ${excel_path}      Sheet1     ${num_table}     ${table_tag}
#     ...    ${9235_kpi_list[${num}]}
#     : FOR    ${num}    IN RANGE    0    8
#     \    ${num_table}    evaluate    ${num}+27
#     \    modify excel cell       ${excel_path}      Sheet1     ${num_table}     ${table_tag}
#     ...    ${8701_pair_UEs_counter_for_table[${num}]}
# 
# 
# add UEs bler
#     Log To Console   add bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=95,2,3,4
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# remove UEs bler
#    Log To Console   remove bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=0,0,0,0
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# Get UEs TP for debug
#     ${UEs_TP_DL_r1}   create list
#     ${UEs_TP_UL_r1}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL_MU}/${UE_NUM}
#     \    ${TP_DL_perUE_target_nopairing}   evaluate  ${TP_PEAK_DL}/${UE_NUM}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    append to list    ${UEs_TP_DL_r1}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL_r1}    ${ul_throughput_pcell}
#     log to console    UE1 to UE${UE_NUM} DL_TP_result are ${UEs_TP_DL_r1}
#     log to console    UE1 to UE${UE_NUM} UL_TP_result are ${UEs_TP_UL_r1}
# 
# capture snapshot start once
#     [Arguments]    ${log_tag}
#     Log To Console    --capture snapshot start
#     Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip
# 
# Check SA UE throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}
#     Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}
# 
# Verify multi SA UEs throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL}*${UE${num}_layer}/4
#     \    ${TP_DL_perUE_target_nopairing}   evaluate  ${TP_PEAK_DL}/${UE_NUM}*${UE${num}_layer}/4
#     \    ${TP_UL_perUE_target}   evaluate  ${TP_PEAK_UL}/${UE_NUM}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword if    '${tag}'=='pair'    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target_pairing}
#     \    run keyword if    '${tag}'=='nopair'    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target_nopairing}
#     \    run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${TP_UL_perUE_target}
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target_pairing is ${TP_DL_perUE_target_pairing}
#     log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target_nopairing is ${TP_DL_perUE_target_nopairing}
#     log to console    cell_UL_TP_target is ${TP_PEAK_UL},UE_DL_TP_target is ${TP_UL_perUE_target}
#     log to console    UE1 to UE${UE_NUM} DL_TP_result are ${UEs_TP_DL}
#     log to console    UE1 to UE${UE_NUM} UL_TP_result are ${UEs_TP_UL}
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    36    #35pos
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos   #per position 2ues
#     log to console    ste ues pos
#     : FOR    ${num}    IN RANGE    1    35
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
#     : FOR    ${num}    IN RANGE    35    69
#     \    ${num_r}    evaluate    ${num}-33
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    2   175M    1   #peak 375mbps
#     \   SA send mutiple trf ul data    ${num}    1   10M    1
# 
# #get F1AP and UE id for test start
# Start collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Start collect '${bip_file}' tcpdump
#     ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
#     Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}
# 
# Stop collect UE f1ap
#     [Arguments]     ${bip_file}
#     Log To Console    Stop collect '${bip_file}' tcpdump
#     Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}
# 
# Get Crnti and gnb_du_id from f1ap
#     [Arguments]     ${bip_file}    ${ue_id}
#     Log To Console   Check '${bip_file}' srs_switch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
#     ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
#     Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
#     ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
#     set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
#     Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----
# 
# Get col_values from bip csv
#     [Arguments]    ${csv_file}    ${col_name}
#     ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
#     ${col_value_list}    Remove Duplicates    ${col_values}
#     [return]     ${col_value_list}
# 
# Check UE srs_switch from s1ap
#     [Arguments]     ${bip_file}    ${ini_paht}
#     Log To Console   Check '${bip_file}' srs_switch
#     Run Keyword And ignore error    Convert BIP To CSV
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
#     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_paht}.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
# 
# 
# Analyse odftbeam in rrclog
#     [Arguments]     ${tag}    ${ini_file}
# 	check_log_with_au2anlysis    ${CURDIR}/ini/${ini_file}.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tag}_egate
# 
# Set ports power and creat file
#     [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
#     ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
#     airphone_execute_egate_command    ${cmd}
# 
# Collect bip and Check
#     Start collect bip log
#     Wait for '1s' to stop bip log with name'step2_bip'
# 
# Set UE '${UE_ID}' position1
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-750,-750,-750,-750
# 
# Collect ttitrace and Check
#     [Arguments]     ${tti_tag}    ${ini_file}
# 	Start collect ttitrace    name=${tti_tag}
#     Wait for '0.3s' to stop ttitrace with name'${tti_tag}'
#     run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode   name=${tti_tag}
#     log to console  ${\n}---decode tti start---
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti
# #    run keyword if    '${tti_tag}'=='tti_step3_muacorr_10'    Decoder Tttirace From Pcap To Csv
# #    ...    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti
# 
# Check ttitrace with ini
#     [Arguments]     ${tti_tag}    ${ini_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/
# 
# Get '${UE_NUM_SA}' UEs rnti
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# 	\   ${ue_rnti}    file match all   ${TEST_LOG_DIRECTORY()}/All/attach_UE${num}_egate/egate_console.log.001   crnti: (\\d+)
# 	\   set suite variable     ${ue${num}_rnti}    ${ue_rnti[0]}
# 	\   Log To Console   UE_ID${num} Crnti is ${ue${num}_rnti}
# 
# Airphone SA Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Detach    ue_id=${num}
#     Collect AP egate log      all
# 
# Attach '${UE_NUM_SA}' SA UEs with f1ap
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
# #    \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
# 
# 
# Online change parameters
#     [Arguments]    ${delta_9235_case10}    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}
#     ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}.json
#     log to console    ${template}
#     ${message} =    Replace Variables    ${template}
#     Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json    ${message}
#     Online recommissioning with delta json file
#     ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
# Get counter file
#     Wait '60s' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     [Return]    ${PM_counter_file}
# 
# Ideal line PRB_mulayer counter check
#     [Arguments]    ${PM_counter_file}
#     ${8701_pair_counter}   create list
#     ${8701_pair_counter_for_table}   create list
#     ${8701_pair_UEs_counter_for_table}   create list
#     : FOR    ${num}    IN RANGE    1    30
#     \    ${counter_1}   evaluate   4000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3${counter_1}    cell_id=1
#     \    append to list    ${8701_pair_counter}    ${result}
#     log to console    8701_pair_counter all is = ${8701_pair_counter}
#     log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are = ${8701_pair_counter[0:4]}
#     log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are = ${8701_pair_counter[4:11]}
#     log to console    PRB_DL_MU_MIMO_layer2 is = ${8701_pair_counter[4]}
#     log to console    PRB_DL_MU_MIMO_layer3 is = ${8701_pair_counter[5]}
#     log to console    PRB_DL_MU_MIMO_layer4 is = ${8701_pair_counter[6]}
#     log to console    PRB_DL_MU_MIMO_layer5 is = ${8701_pair_counter[7]}
#     log to console    PRB_DL_MU_MIMO_layer6 is = ${8701_pair_counter[8]}
#     log to console    PRB_DL_MU_MIMO_layer7 is = ${8701_pair_counter[9]}
#     log to console    PRB_DL_MU_MIMO_layer8 is = ${8701_pair_counter[10]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_6_7_8 are = ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
#     log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are = ${8701_pair_counter[15:23]}
#     log to console    PRB_DL_MU_MIMO_layer_9 is = ${8701_pair_counter[15]}
#     log to console    PRB_DL_MU_MIMO_layer_10 is = ${8701_pair_counter[16]}
#     log to console    PRB_DL_MU_MIMO_layer_11 is = ${8701_pair_counter[17]}
#     log to console    PRB_DL_MU_MIMO_layer_12 is = ${8701_pair_counter[18]}
#     log to console    PRB_DL_MU_MIMO_layer_13 is = ${8701_pair_counter[19]}
#     log to console    PRB_DL_MU_MIMO_layer_14 is = ${8701_pair_counter[20]}
#     log to console    PRB_DL_MU_MIMO_layer_15 is = ${8701_pair_counter[21]}
#     log to console    PRB_DL_MU_MIMO_layer_16 is = ${8701_pair_counter[22]}
# 
#     log to console    PRB_DL_MU_MIMO_paired_UE_0 is = ${8701_pair_counter[11]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_2 is = ${8701_pair_counter[12]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_3 is = ${8701_pair_counter[13]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_4 is = ${8701_pair_counter[14]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_5 is = ${8701_pair_counter[23]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_6 is = ${8701_pair_counter[24]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_7 is = ${8701_pair_counter[25]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_8 is = ${8701_pair_counter[26]}
# 
#     log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are = ${8701_pair_counter[27]} ${8701_pair_counter[28]}
#     ${sum_prb_layer1}    evaluate    ${8701_pair_counter[4]}*2+${8701_pair_counter[5]}*3+${8701_pair_counter[6]}*4
#     ${sum_prb_layer2}    evaluate    ${8701_pair_counter[7]}*5+${8701_pair_counter[8]}*6+${8701_pair_counter[9]}*7+${8701_pair_counter[10]}*8
#     ${sum_prb_layer3}    evaluate    ${8701_pair_counter[15]}*9+${8701_pair_counter[16]}*10+${8701_pair_counter[17]}*11+${8701_pair_counter[18]}*12
#     ${sum_prb_layer4}    evaluate    ${8701_pair_counter[19]}*13+${8701_pair_counter[20]}*14+${8701_pair_counter[21]}*15+${8701_pair_counter[22]}*16
#     ${sum_prb_layer_X_layer}    evaluate    ${sum_prb_layer1}+${sum_prb_layer2}+${sum_prb_layer3}+${sum_prb_layer4}
# 
#     log to console    sum_prb_layer_X_layer is ${sum_prb_layer_X_layer}
# 
#     ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
#     ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
#     ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
# #    ${pair_to_muelig}    evaluate    ${8701_pair_counter[27]}/${8701_pair_counter[28]}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
#     run keyword and continue on failure   should be true   ${PRB_DL_SU_MIMO_layer_total}==${8701_pair_counter[11]}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
# #    run keyword and continue on failure   should be true   ${pair_to_muelig}>0.98
#     log to console    PRB_DL_SU_MIMO_layer_total is = ${PRB_DL_SU_MIMO_layer_total}
#     log to console    PRB_DL_MU_MIMO_layer_total is = ${PRB_DL_MU_MIMO_layer_total}
#     log to console    PRB_DL_MU_paired_UE_total is = ${PRB_DL_MU_paired_UE_total}
#     append to list    ${8701_pair_counter_for_table}    ${8701_pair_counter[4]}    ${8701_pair_counter[5]}    ${8701_pair_counter[6]}
#     ...    ${8701_pair_counter[7]}    ${8701_pair_counter[8]}    ${8701_pair_counter[9]}    ${8701_pair_counter[10]}
#     ...    ${8701_pair_counter[15]}    ${8701_pair_counter[16]}    ${8701_pair_counter[17]}    ${8701_pair_counter[18]}
#     ...    ${8701_pair_counter[19]}    ${8701_pair_counter[20]}    ${8701_pair_counter[21]}    ${8701_pair_counter[22]}
#     ...    ${sum_prb_layer_X_layer}    ${PRB_DL_SU_MIMO_layer_total}    ${PRB_DL_MU_MIMO_layer_total}
#     append to list    ${8701_pair_UEs_counter_for_table}    ${8701_pair_counter[11]}    ${8701_pair_counter[12]}    ${8701_pair_counter[13]}
#     ...    ${8701_pair_counter[14]}    ${8701_pair_counter[23]}    ${8701_pair_counter[24]}    ${8701_pair_counter[25]}
#     ...    ${8701_pair_counter[26]}
#     set global variable    ${8701_pair_counter}
#     set global variable    ${8701_pair_counter_for_table}
#     set global variable    ${8701_pair_UEs_counter_for_table}
#     [Return]    ${8701_pair_counter_for_table}
# 
# KPI counter check
#     [Arguments]    ${PM_counter_file}
#     ${PDSCH_UNSUCC_64TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
#     ${PDSCH_UNSUCC_256TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_2}   evaluate   2000+${num}
#     \    ${counter_3}   evaluate   3000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
#     \    ${counter_7}   evaluate   7000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_2}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}
# 
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_7}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
# #    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
# #    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
# #    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
#     ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
#     ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
#     ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.001
# #    log to console    KPI NR_5055b residual bler is ${NR_5055b}
# 
#     ${PDSCH_INITX_64TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_64TBL_MCS}    create list
#     ${PDSCH_INI_256TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_256TBL_MCS}    create list
# 
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    10    29
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_1}   evaluate   1000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_1}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
#     \    ${counter_4}   evaluate   4000+${num}
#     \    ${counter_5}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_4}    cell_id=1
#     \    append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_5}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
# #    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
# 
#     ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
#     ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
#     ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
# 
# 
#     ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
#     ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_22}   evaluate   2000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_22}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
# #    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
# #    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}
# 
#     ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03005    cell_id=1
#     ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00016    cell_id=1
#     ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00018    cell_id=1
#     ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
#     ${NR_5108d_fenmu}    evaluate    ${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5}))
#     evaluate    ${NR_5108d_numerato}/1    ${NR_5108d}
#     evaluate    ${NR_5108d_numerato}/${NR_5108d_fenmu}    ${NR_5108d}
# #    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
# 
#     ${L_M55304C0400X}   create list
#     ${M55304C0400X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0400${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C040${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     ${L_M55304C0800X}   create list
#     ${M55304C0800X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0800${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C080${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     ${L_M55304C1000X}   create list
#     ${M55304C1000X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C1000${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C100${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
#     ${L_M55308}   create list
#     ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03006    cell_id=1
#     ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10002    cell_id=1
#     ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00009    cell_id=1
#     ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00011    cell_id=1
#     append to list    ${L_M55308}    ${M55308C03006}
#     append to list    ${L_M55308}    ${M55308C10002}
#     append to list    ${L_M55308}    ${M55308C00009}
#     append to list    ${L_M55308}    ${M55308C00011}
#     ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
#     run keyword and continue on failure     ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
# #    log to console    64qam:${L_M55304C0400X}
# #    log to console    dft_s_ofdm:${L_M55304C0800X}
# #    log to console    256qam:${L_M55304C1000X}
# #    log to console    ${L_M55308}
# #    log to console    SE_KPI_Value=${NR_5109d}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
# #    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_2}   evaluate   1000+${num}
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_2}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55366C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
#     : FOR    ${num}    IN RANGE    0    28
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C00001    cell_id=1
#     ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10003    cell_id=1
# #    log to console    PDSCH_INI_VOL_64TBL_MCS_list 0_to_28 is ${PDSCH_INI_VOL_64TBL_MCS_list}
# #    log to console    PDSCH_INI_VOL_256TBL_MCS_list 0_to_27 is ${PDSCH_INI_VOL_256TBL_MCS_list}
# #    log to console    MEAS_PERIOD_NR_MAC_PDU_TPUT is ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
# #    log to console    PRB_USED_PDSCH is ${PRB_USED_PDSCH}
# #    log to console    PRB_AVAIL_PDSCH is ${PRB_AVAIL_PDSCH}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
#     ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
#     ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
#     ${NR_5242b_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
#     ${NR_5242b_fenzi2}    evaluate    ${NR_5242b_fenzi1}/${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#     ${NR_5242b_fenmu}    evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
#     ${NR_5242b}    evaluate    ${NR_5242b_fenzi2}/${NR_5242b_fenmu}
# #    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
# 
# 
#     ${DL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C01001    cell_id=1
#     ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00005    cell_id=1
#     ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C02000    cell_id=1
#     ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})
# 
#     ${ACC_SCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C17001    cell_id=1
#     ${TOTAL_COSCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C02004    cell_id=1
#     ${DL_DATA_SLOTS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00001    cell_id=1
#     ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00005    cell_id=1
#     ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00015    cell_id=1
#     ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00017    cell_id=1
#     ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
#     ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
# 
#     log to console    KPI NR_5055b residual bler is = ${NR_5055b}
#     log to console    KPI NR_5054a iniBler is = ${NR_5054a}
#     log to console    KPI NR_5108d SE_downlink is = ${NR_5108d}
#     log to console    KPI NR_5109d SE_uplink is = ${NR_5109d}
#     log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
#     log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
#     log to console    KPI NR_5100b Avg MAC user thp DL = ${NR_5100b}
#     log to console    KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.005
#     ${9235_kpi_list}   create list    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}    ${NR_5242b}
#     ...    ${NR_5258a}    ${NR_5100b}    ${NR_5192c}
#     [return]     ${9235_kpi_list}
# 
# # gnb logs capture
# Get gnb_logs from git
#      ${exist}    List Directory    /home/ute
#     Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
#     ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
#     OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
#     modify gnb_logs config
# 
# Start collect logs by gnb_logs
#     [Arguments]    ${command}
#     log to console    Start collect logs by gnb_logs
#     OperatingSystem.Run    rm -rf /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129*
#     TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
#     TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
#     TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
#     TAF_SSH.Read Output Until    (Q)uit    connection=bsh
# 
# Wait for '${time}' to stop collect logs by gnb tool
#     log to console    stop collect logs by gnb tool
#     Wait '${time}' for stable
#     OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
#     Wait Until Keyword Succeeds    30000    10    file should contain
#     ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running
#     OperatingSystem.Run    scp /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129* ${TEST_LOG_DIRECTORY()}/All
# 
# modify gnb_logs config
#     setup_txt    /home/ute/gnb_logs-tool/gnb_logs/config.ini
#     Modify Txt Node    TTI_log_files:500    BIP_log_files:12
#     teardown_txt
