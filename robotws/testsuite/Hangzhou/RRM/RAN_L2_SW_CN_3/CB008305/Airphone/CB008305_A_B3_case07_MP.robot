# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_MP_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation     chbw change from 100mhz to 60mhz
# ...   256qam enable
# ...   dmrs_fdm enable
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${SCFC_NAME}     SCFC_8305_case07_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO.xml
# ${WTS_NAME}      WTS_2cell_SA_NSA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# @{Rdparameter}    0x340000:15
# ${UE_NUM}  2
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# 
# ${TP_PEAK_DL}    1300000
# ${TP_PEAK_DL_MU}  5200000
# ${TP_PEAK_UL}    150000
# 
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=51 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-280,-280
# 
# *** Test Cases ***
# CB008305_A_B4_case07_two_rank3_Ues_paired_and_SCID_check
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     step3:check pairing and TP with multi_ranks
#     step4:add bler to check pairing and TP with multi_ranks
# 
# *** Keywords ***
# step1:get ready for gnb
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     Start capture only gnb syslog in 'step2_attach' file
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 	SA send data '${UE_NUM}' UEs
# 	Wait '10s' for stable
# 	run keyword and continue on failure    Stop capture only gnb syslog in 'step2_attach' file
# 
# step3:check pairing and TP with multi_ranks
#     Log To Console   \n-------------step3:check pairing and TP with multi_ranks---------------
#     run keyword and continue on failure    Fix 2UE rank'2' to check mu pair and TP
#     run keyword and continue on failure    Fix 2UE rank'3' to check mu pair and TP
#     run keyword and continue on failure    Fix 2UE rank'4' to check mu pair and TP
# 
# step4:add bler to check pairing and TP with multi_ranks
#     Log To Console   \n-------------step4:add bler to check pairing and TP with multi_ranks---------------
#     Start capture gnb and ap syslog in 'step4' file
#     run keyword and continue on failure    Add bler and check mu retrans pair with rank'3'
#     run keyword and continue on failure    Add bler and check mu retrans pair with rank'4'
#     Stop capture gnb and ap syslog in 'step4' file
#     DeRegister ‘${UE_NUM}’ SA UEs
# 
# Add RD
#     Add GNB swconfig    0x340000:15
#     Add GNB swconfig    0x580542:0   #SE check
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    ${num_r}    evaluate    ${num}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
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
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
# 
# SA send data '${UE_NUM_SA}' UEs
#     log to console    push data for UEs
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    6   175M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    170M   ${gw_pdu_r}
# 
# Add bler and check mu retrans pair with rank'${rank}'
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=10,2,3,4
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
#     ${rank_ret}  evaluate   ${rank}-1
#     ${ri_file_id}    evaluate  ${rank}+0
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${ri_file_id} cqi\=15 ri\=${rank_ret}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=${ri_file_id}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=${ri_file_id}
#     Wait '30s' for stable
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_se_bler_${rank}'
#     run keyword and continue on failure    check TP and bler with ttitrace   700    1    tti_se_bler_${rank}
#     ...    8305_case05_ttitrace_TP_Bler    ${rank}
# 
# Fix 2UE rank'${rank}' to check mu pair and TP
#     log to console  2UE_rank${rank}_fix_pair_check
#     ${rank_ret}  evaluate   ${rank}-1
#     ${ri_file_id}    evaluate  ${rank}+0
#     Start capture gnb and ap syslog in 'rank${rank}_fix_pair' file
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${ri_file_id} cqi\=15 ri\=${rank_ret}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=${ri_file_id}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=${ri_file_id}
#     wait '5s' for stable
#     run keyword and continue on failure    Wait until keyword succeeds    48s    8s     Check ue tput is correct '${rank}'
#     wait '5s' for stable
# #    Start collect bip log
# #    Wait for '1s' to stop bip log with name'bip_2UE_rank${rank}_mu_pair_check'    #PR676137
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_2UE_rank${rank}_mu_pair_check'
#     run keyword and continue on failure    check TP and bler with ttitrace   700    1
#     ...    tti_2UE_rank${rank}_mu_pair_check   tti_case7_rank${rank}_AP    ${rank}
#     Stop capture gnb and ap syslog in 'rank${rank}_fix_pair' file
# 
# 
# Attach '${UE_NUM}' SA UEs
#     Start capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
#     \   Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    UE_${num}_rrc
#     \   run keyword and continue on failure     Check_rrc   UE_${num}_rrc
#     Stop capture gnb and ap syslog in 'SA_${UE_NUM}_ue_rrc' file
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
# 
# Data buffer send to '${UE_NUM}' SA UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    7   175M    ${num}    tcp
#     \   SA send mutiple trf ul data    ${num}    3   20M    ${num}    tcp
# 
# Check_rrc
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/8305_SA_RRC.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Check rrc log
#     Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
#     run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate
# 
# Check ue tput is correct '${rank}'
#     ${dl_tput1}    airphone_get_throughput_on_specific_scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tput2}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     ${TP_test}    evaluate    875000*${rank}/4
#     run keyword and continue on failure    should be true    ${dl_tput1}>${TP_test}
#     run keyword and continue on failure    should be true    ${dl_tput2}>${TP_test}
#     log to console   egate UE1 with rank${rank} tp is ${dl_tput1}
#     log to console   egate UE2 with rank${rank} tp is ${dl_tput2}
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}    ${ue_rank}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}_tti/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}_tti/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    ${throughput_target}    evaluate  (${throughput}*${ue_rank})/4
#     \    should be true  ${result}>${throughput_target}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}_tti/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}_tti/tti
# 
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