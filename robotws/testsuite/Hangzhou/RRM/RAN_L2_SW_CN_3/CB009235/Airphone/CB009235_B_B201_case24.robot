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
# ${SCFC_NAME}      SCFC_9235_8D4U_AQQL_1116_0_case24.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case01.xml
# ${WTS_NAME}       wts_SA_NSA_case01.cfg
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM_SA}         3
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${TTI_TAG}      tti
# 
# ${UE1_SA_ID}        1
# ${UE2_SA_ID}        2
# ${UE3_SA_ID}        3
# ${UE4_SA_ID}        4
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-14 zenith\=8 srs_transmit_power_per_port=-320,-320,-280,-280
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280
# 
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=21 zenith\=-5 srs_transmit_power_per_port\=-320,-320,-280,-280
# 
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=9 zenith\=-5 srs_transmit_power_per_port\=-320,-320,-280,-280
# 
# *** Test Cases ***
# CB009235_B_B201_CASE24_dlMuAware_8DL4UL_SE_check_maxDlMuMimoLayer_4
#     Step1:gnb ready for onair
#     Step2:attach UEs with Pos
#     Step3:send full buffer for UEs and check logs
#     Step4:online change dlMuMaxNumLayerPerMuRbg and check logs
#     Step5：override CQI trigger bad threshold and check log
#     Step6:Online change dlMuMimoSpectralEffThd equal 9 and check logs
#     Step7:Online change dlMuMimoSpectralEffThd equal 8 and check logs
#     Step8: online change actMuAwareTdSch false and check log
#     #Step9:detach all UEs
#     Stop capture gnb and ap syslog in 'after_onair' file
# 
# 
# *** Keywords ***
# Step1:gnb ready for onair
# #    Active GNB L2 feature debug traces
#     Log To Console   \n----Step1:gnb ready for onair---
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# Step2:attach UEs with Pos
#     Log To Console   \n--Step2:attach UEs with Pos---
# 	Attach '${UE_NUM_SA}' SA UE
# 	Set UEs pos
# 	Get all UEs rnti
# 
# Step3:send full buffer for UEs and check logs
#     Log To Console   \n--Step3:send full buffer for UEs and check logs---
#     SA send data '${UE_NUM_SA}' UEs
#     Wait '10s' for stabible
#     Check SA UE throughput
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'tti_16layer'
#     #check ttitrace
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_16layer_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_16layer_dl.csv
# 
# 
# Step4:online change dlMuMaxNumLayerPerMuRbg and check logs
#     Log To Console   \n--Step4:online change dlMuMaxNumLayerPerMuRbg and check logs---
#     Online change dlMuMaxNumLayerPerMuRbg '4'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_4layer'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_4layer_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_4layer_dl.csv
# 
# Step5：override CQI trigger bad threshold and check log
#     Log To Console   \n--Step5：override CQI trigger bad threshold and check log---
#     Override CQI trigger bad threshold
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_cqi'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_cqi_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_cqi_dl.csv
#     Override CQI trigger good threshold
# 
# Step6:Online change dlMuMimoSpectralEffThd equal 9 and check logs
#     Log To Console   \n--Step6:Online change dlMuMimoSpectralEffThd equal 9 and check logs---
#     Online change dlMuMimoSpectralEffThd '9'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_se9'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_se9_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_se9_dl.csv
# 
# Step7:Online change dlMuMimoSpectralEffThd equal 8 and check logs
#     Log To Console   \n--Step7:Online change dlMuMimoSpectralEffThd equal 8 and check logs---
#     Online change dlMuMimoSpectralEffThd '8'
#     Wait '5s' for stabible
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti_se8'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_se8_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_se8_dl.csv
# 
# Step8: online change actMuAwareTdSch false and check log
#     Log To Console   \n--Step8: online change actMuAwareTdSch false and check log---
#     Online change actMuAwareTdSch 'false'
# 
# step9:detach all UEs
#     Log To Console   \n--step9:detach all UEs---
#     Detach '${UE_NUM_SA}' SA UE
# 
# Online change actMuAwareTdSch '${state}'
#     Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_9235_case01_actMuAwareTdSch_${state}.json
#     Wait '10s' for stabible
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_${state}'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_false_case24.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
#     reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_${state}_dl.csv
# 
# Convert cellsetup bip and check
#     Log To Console   Convert cellsetup bip and check
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
#      ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/cellsetup_bip.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
# 
# Attach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   airphone_cleanup_egate_console_log
#     \   Airphone SA Attach    ue_id=${num}
#     \   Wait '2s' for stabible
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Wait '2s' for stabible
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '2s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
#     \   Wait '3s' for stabible
# 
# SA UE '${UE_ID}' fix RANK2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=30 ri\=1 ri_mode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=30 scell\=0
# 
# Detach '${UE_NUM_SA}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_sa_detach    ue_id=${num}    timeout=30
# 
# 
# Create UE pos profile
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# Set UEs pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
# 
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    4   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    10M   ${num}
# 
# Check Srs Resource
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS.ini    log_need_to_check=p
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
# 
# Online change dlMuMaxNumLayerPerMuRbg '${value}'
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1   dlMuMaxNumLayerPerMuRbg    ${value}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
# 
# Online change dlMuMimoSpectralEffThd '${value}'
# 	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1   dlMuMimoSpectralEffThd    ${value}    online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     TAF_ADMIN.teardown admin    connection=online
#     Wait '30s' for stabible
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
# Add RD
#     Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#     Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace
# 
# Override CQI trigger bad threshold
# #    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=15 ri\=3
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=11 cqi\=5 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=11 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=11 scell\=0
# #
# 
# Override CQI trigger good threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=10 cqi\=15 ri\=3
# #    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=11 cqi\=2 ri\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=10 scell\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=10 scell\=0
# 
# 
# Add dl bler to UE'${UE_ID}'
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=${30+${UE_ID}} dl_bler\=150,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} scell\=0 testmode\=bler profile_id\=${30+${UE_ID}} action\=activate
