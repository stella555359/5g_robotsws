# *** Settings ***
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    Author_lei.4.gao@nokia-sbell.com    AP    SBTS00    RAN_5G_TDD    RAN_5G
# ...   CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_E1_case33_8X4_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_MUMIMO_8X4.xml
# #${WTS_NAME}    wts_8322_B32_SA_NSA_32UEs.cfg
# ${WTS_NAME}    wts_8322_1cell_SA_NSA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}    4
# ${egate_tag}    egate
# ${tti_tag}    ttitrace
# 
# 
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='false'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
# ...    NUMBER_OF_FILES=10
# ${TP_PEAK_DL}    1000000  #ideal 1.09gbps
# ${TP_PEAK_UL}    211000   #211mbps
# 
# @{Rdparameter}     0x340000:3
# ${TP_sum}    0
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=40 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-30 srs_transmit_power_per_port\=-270,-270,-230,-230
# 
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-30 srs_transmit_power_per_port\=-280,-280,-280,-280
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-5 zenith\=0 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=30 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-12 zenith\=30 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=30 srs_transmit_power_per_port\=-270,-270,-230,-230
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=12 zenith\=30 srs_transmit_power_per_port\=-270,-270,-230,-230
# 
# 
# *** Test Cases ***
# CB008322_E1_case033_subbandBeam_interwork_8layerMUMIMO_DLMIMO8X4_tapering
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     step3:RT beam user MU eligible and pairing
#     step4:ovride rank WBsrs user pairing with SBsrs user
#     step5:set high correlation 3 WBsrs user pairing
#     step6:add bler dft beam user pairing check fine
#     Airphone SA Detach UE
# 
# *** Keywords ***
# Add RD
#     Add GNB swconfig    0x580776:1   #rdDlMuSbBfMode
#     Add GNB swconfig    0x5805ba:0x21   #The minimum PRB of PDSCH to allow the transmission with subband beams.
#     Add GNB swconfig    0x5805bb:0x4   #The maximum distance between startPRB of each PDSCH PRB and mid-PRB
#     Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true
# 
# 
# step1:get ready for gnb
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Start capture gnb and ap syslog in 'after_onair' file
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 
# step3:RT beam user MU eligible and pairing
#     Log To Console   \n-------------step3:RT beam user MU eligible and pairing---------------
#     SA send data '${UE_NUM}' UEs
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'step3_bip'
# 	run keyword and continue on failure	   Check SA UE throughput
# 	...    UE1_layer=2    UE2_layer=2    UE3_layer=2    UE4_layer=2    tag=step3_pair    peaktp=${TP_PEAK_DL}
#     Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case33_step3_tti
# 
# Check SA UE throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}     ${UE3_layer}    ${UE4_layer}     ${tag}    ${peaktp}
#     Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${UE1_layer}    ${UE2_layer}
#     ...    ${UE3_layer}    ${UE4_layer}     ${tag}    ${peaktp}
# 
# Verify multi SA UEs throughput
#     [Arguments]     ${UE1_layer}    ${UE2_layer}     ${UE3_layer}    ${UE4_layer}     ${tag}    ${peaktp}
#     ${UEs_TP_DL}   create list
#     ${UEs_TP_UL}   create list
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL}*${UE${num}_layer}/4
#     \    ${TP_UL_perUE_target}   evaluate  ${TP_PEAK_UL}/${UE_NUM}
#     \    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#     \    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#     \    run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target_pairing}
#     \    run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${TP_UL_perUE_target}
#     \    append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
#     \    append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
#     log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target_pairing is ${TP_DL_perUE_target_pairing}
#     log to console    cell_UL_TP_target is ${TP_PEAK_UL},UE_DL_TP_target is ${TP_UL_perUE_target}
#     log to console    UE1 to UE${UE_NUM} DL_TP_result are ${UEs_TP_DL}
#     log to console    UE1 to UE${UE_NUM} UL_TP_result are ${UEs_TP_UL}
# 
# step4:ovride rank WBsrs user pairing with SBsrs user
#     Log To Console   \n-------------step4:ovride rank WBsrs user pairing with SBsrs user---------------
#     airphone_execute_egate_command   csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=0
#     Start collect UE f1ap    step4_srsModify
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3
#     Wait '3s' for stable
#     Stop collect UE f1ap    step4_srsModify
#     run keyword and continue on failure    Check UE srs_switch from s1ap    step4_srsModify    Case33_step4_F1ap
# 	run keyword and continue on failure	   Check SA UE throughput
# 	...    UE1_layer=1    UE2_layer=2    UE3_layer=2    UE4_layer=2    tag=step3_pair    peaktp=${TP_PEAK_DL}
#     run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step4    ini_file=Case33_step4_tti
#     airphone_execute_egate_command   csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=3
# 
# step5:set high correlation 3 WBsrs user pairing
#     Log To Console   \n-------------step5:set high correlation 3 WBsrs user pairing--------------
#     modify SRS_pos profile
#     Wait '5s' for stable
# 	run keyword and continue on failure	   Check SA UE throughput
# 	...    UE1_layer=1    UE2_layer=1    UE3_layer=1    UE4_layer=1    tag=step5_pair    peaktp=${TP_PEAK_DL}
#     run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case33_step5_tti
# 
# step6:add bler dft beam user pairing check fine
#     Log To Console   \n-------------step6:add bler dft beam user pairing check fine---------------
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=50,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case33_step6_tti
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=0
# #    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 delete\=1
# 
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# modify SRS_pos profile
#     : FOR    ${num}    IN RANGE    10    ${UE_NUM}+10
#     \    airphone_execute_egate_command    ${PROFILE${num}}
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${num_r2}    evaluate    ${num}+9
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r2}
#     Log To Console   modify SRS_pos profile done
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${num_r}    evaluate    ${num}+1
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
#     Wait for '1s' to stop bip log with name'${BIP_TAG1}'
# 
# Set UE '${UE_ID}' position1
#     airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# 
# Set UE '${UE_ID}' low power
#     ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
#     ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0 srs_transmit_power_per_port\=-750,-750,-750,-750
# 
# 
# Collect ttitrace and Check
#     [Arguments]     ${tti_tag}    ${ini_file}
# 	Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${tti_tag}'
#     split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv
#     run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
#     check_cdm_group_and_dmrs_port_by_antenna_port_value     ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     log to console  ${\n}---decode tti start---
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti
# 
# Check ttitrace with ini
#     [Arguments]     ${tti_tag}    ${ini_file}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/
# 
# SA send data '${UE_NUM_SA}' UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \    SA send mutiple trf dl data    ${num}    3   175M   ${num}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    20M   ${num}
#     Log To Console   all UEs data sent
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
# 
# Attach '${UE_NUM_SA}' SA UEs with f1ap
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
