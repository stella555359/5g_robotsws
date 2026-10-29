# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_9235_16D8U_1070_100M_case18.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case18.xml
# ${WTS_NAME}       wts_9235_1cell_SA_NSA_case18.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM_SA}         4
# ${UE_NUM_NSA}         4
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${TTI_TAG}      tti
# 
# ${UE1_SA_ID}        1
# ${UE2_SA_ID}        2
# ${UE3_SA_ID}        3
# ${UE4_SA_ID}        4
# ${UE5_SA_ID}        5
# ${UE6_SA_ID}        6
# ${UE7_SA_ID}        7
# ${UE8_SA_ID}        8
# ${UE9_SA_ID}        9
# ${UE10_SA_ID}        10
# ${UE11_NSA_ID}        11
# ${UE12_NSA_ID}        12
# 
# ${NSA_UE_ID_LOW}    11
# ${NSA_UE_ID_HIGH}    14
# 
# ${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
# @{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
# ...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio
# 
# ${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
# 
# 
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=8 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# 
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=6 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# 
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=21 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
# 
# 
# ${BEAM_PROFILE1}   beam_control_testmode_nr profile_id\=20 ueBeamIndexInitial\=0,1,2,3,4,5 csirs_bestbeam\=0
# ...    csirs_rsrp_best\=-44 csirs_rsrp_avg\=-50
# ${BEAM_PROFILE2}   beam_control_testmode_nr profile_id\=21 ueBeamIndexInitial\=1,0,2,3,4,5 csirs_bestbeam\=5
# ...    csirs_rsrp_best\=-45 csirs_rsrp_avg\=-120
# 
# #${BEAM_PROFILE1}   beam_control_testmode_nr profile_id=20 ueBeamIndexInitial=0,1,2,3,4,5 csirs_bestbeam=0 csirs_rsrp_best=-44 csirs_rsrp_avg=-50
# #${BEAM_PROFILE2}   beam_control_testmode_nr profile_id=21 ueBeamIndexInitial=1,0,2,3,4,5 csirs_bestbeam=1 csirs_rsrp_best=-45 csirs_rsrp_avg=-70
# ${BEAM_PROFILE3}   beam_control_testmode_nr profile_id=22 ueBeamIndexInitial=2,0,1,3,4,5 csirs_bestbeam=2 csirs_rsrp_best=-50 csirs_rsrp_avg=-125
# ${BEAM_PROFILE4}   beam_control_testmode_nr profile_id=23 ueBeamIndexInitial=3,0,1,2,4,5 csirs_bestbeam=3 csirs_rsrp_best=-52 csirs_rsrp_avg=-128
# 
# *** Test Cases ***
# CB009235_B_B101_CASE18_dlMuAware_mulit_Macce_with_nonGBR_ini_retrans_mueligible_and_pairing
# ##    Active GNB L2 feature debug traces
#     step1:gnb ready for onair and check cellsetup log
#     step2:attach UEs and send full buffer for UEs
#     Step3: change UE SSBeamId
#     Step4: add bler and change UE SSBeamId
#     Step5: stop data and change UE SSBeamId
# 
#     Collect AP egate log    ${EGATE_TAG}
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# step1:gnb ready for onair and check cellsetup log
#     Log To Console   \n-------------step1:get ready for gnb---------------
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs and send full buffer for UEs
#     Log To Console   \n-------------step2:attach UEs and send full buffer for UEs--------------
#     Set UEs beam
# 
# 	Attach NSA UEs'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
# 	Set UEs pos
#     NSA send data to UEs'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
# 
#     Wait '10s' for stabible
#     Check NSA UE throughput
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_no_bler'
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_no_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_bler_case18.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Step3: change UE SSBeamId
#     Log To Console   \n-------------step3:change UE SSBeamId--------------
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stabible
#     Trigger UEs beam change file '${3}'
# 
#     Wait '1s' for stabible
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}Change UE SSBeamId
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}Change UE SSBeamId/beam_swich
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/Change UE SSBeamId/beam_swich_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_switch_case18.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/Change UE SSBeamId/
# 
# Step4: add bler and change UE SSBeamId
#     Log To Console   \n-------------step4:add bler and change UE SSBeamId--------------
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    Add dl bler to UE'${num}'
# 
# 	Start GNB Ttitrace With Streaming Mode
# 	Trigger UEs beam change file '${4}'
#     Wait '1s' for stabible
#     Trigger UEs beam change file '${3}'
#     Wait '1s' for stabible
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}add bler and change UE SSBeamId
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}add bler and change UE SSBeamId/beam_switch_bler
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/add bler and change UE SSBeamId/beam_switch_bler_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_bler_case18.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/add bler and change UE SSBeamId/
# 
# Step5: stop data and change UE SSBeamId
#      airphone_nsa_stop_data_traffic    ue_id=${NSA_UE_ID_LOW}    direction=dl
#     Start GNB Ttitrace With Streaming Mode
#     Trigger UEs beam change file '${2}'
#     Wait '2s' for stabible
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}stop data and change UE SSBeamId
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}stop data and change UE SSBeamId/beam_switch_nodata
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/stop data and change UE SSBeamId/beam_switch_nodata_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_no_data_case18.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/stop data and change UE SSBeamId/
# 
# Set UE beam id'${UE_ID}'
#     airphone_execute_egate_command    ${BEAM_PROFILE1}
#     airphone_execute_egate_command    ${BEAM_PROFILE2}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=beam_control action\=activate profile_id\=20
#     ...    beamaction\=attach scell\=0
# 
# Change NSA UE beam id
#     airphone_execute_egate_command    ue_testmode_set_nr id\=11 testmode\=beam_control action\=activate profile_id\=21 beamaction\=switch scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=12 testmode\=beam_control action\=activate profile_id\=21 beamaction\=switch scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=beam_control action\=activate profile_id\=21 beamaction\=switch scell\=8
#     airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=beam_control action\=activate profile_id\=21 beamaction\=switch scell\=8
# 
# 
# Set UEs beam
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=0,1,2,3,4,5 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#    airphone_execute_egate_command
#    ...    beam_control_testmode_nr profile_id\=3 ueBeamIndexInitial\=2,3,4,5,0,1 ssbeam_bestbeam\=2 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-85
#    airphone_execute_egate_command
#    ...    beam_control_testmode_nr profile_id\=4 ueBeamIndexInitial\=4,5,0,1,2,3 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-75
# 
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    ${cmd}    catenate    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=2
#     ...    beamaction\=attach scell\=8,9
#     \    airphone_execute_egate_command   ${cmd}
# 
# Trigger UEs beam change file '${profile_id}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    ${cmd}    catenate    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=${profile_id}
#     ...    beamaction\=switch scell\=8,9
#     \    airphone_execute_egate_command    ${cmd}
#     \   Log To Console    --UE${num} beam change
# 
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# #    \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# 
# Detach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_sa_detach    ue_id=${num}    timeout=30
# 
# Set UEs pos
#     airphone_execute_egate_command    ${PROFILE11}
#     airphone_execute_egate_command    ${PROFILE12}
#     airphone_execute_egate_command    ${PROFILE13}
#     airphone_execute_egate_command    ${PROFILE14}
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
# Add dl bler to UE'${UE_ID}'
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=${30+${UE_ID}} dl_bler\=150,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=8 testmode\=bler profile_id\=${30+${UE_ID}} action\=activate
# 
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    1   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# 
# SA send data to UEs'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    SA send mutiple trf dl data    ${num}    1   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# Attach NSA UEs'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}   ${NSA_UE_ID_HIGH}+1
# #    \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# 
# NSA send data to UEs'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \   NSA send ue '${num}' mutiple trf '6' for each '175M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '10M' UL data
# 
# Airphone NSA Stop Data Traffic And Detach UE'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# 
# Stop SA UE'${UE_ID}' data
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=dl
#     airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=ul
# 
# Check SA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput
# 
# Verify multi SA UEs throughput
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
#     \    Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
# #    \    should_be_true    ${dl_throughput_pcell}>210000
# 
# 
# Check NSA UE throughput
#     Wait until keyword succeeds    60s    5s    Verify multi NSA UEs throughput
# 
# Verify multi NSA UEs throughput
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
# #    \    append to list    ${ue_TP}    ${dl_throughput_pcell}
#     \    Log to console    UE:${num} dl_tput=${dl_throughput_pcell}
#     \    Log to console    UE:${num} ul_tput=${ul_throughput_pcell}
# 
# Verify multi NSA UEs throughput'${NSA_UE_ID_LOW}' to '${NSA_UE_ID_HIGH}'
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=8    type=pusch    tput_type=ave
# #    \    append to list    ${ue_TP}    ${dl_throughput_pcell}
#     \    Log to console    UE:${num} dl_tput=${dl_throughput_pcell}
#     \    Log to console    UE:${num} ul_tput=${ul_throughput_pcell}
# 
# Check Srs Resource
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_12_egate
# 
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_13_egate
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_14_egate
# 
# Get all UEs rnti
#     ${rnti_list}    create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    ${rnti}    Get SA UE crnti in RRC log'${EGATE_TAG}_${num}'
#     \    Log To Console   UE${num} rnti=${rnti}
# 	\    set suite variable     ${ue${num}_rnti}    ${rnti}
#     \    append to list    ${rnti_list}    ${rnti}
# 
#     : FOR    ${num}    IN RANGE    ${NSA_UE_ID_LOW}    ${NSA_UE_ID_HIGH}+1
#     \    ${rnti}    Get NSA UE crnti in RRC log'${EGATE_TAG}_${num}'
#     \    Log To Console   UE${num} rnti=${rnti}
# 	\    set suite variable     ${ue${num}_rnti}    ${rnti}
#     \    append to list    ${rnti_list}    ${rnti}
# 
#     Log To Console    rnti_list=${rnti_list}
# 
# Get SA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   crnti: (\\d+)
#     [return]     ${rnti_list[0]}
# 
# Get NSA UE crnti in RRC log'${EGATE_TAG}'
#     Log To Console   check UE RRC log to get all ue crnti
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
#     [return]     ${rnti_list}
# 
# Add RD
#     Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#     Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
# 
