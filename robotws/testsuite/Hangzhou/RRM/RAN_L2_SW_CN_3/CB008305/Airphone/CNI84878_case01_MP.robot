# *** Settings ***
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_MP_AP_LO
# Resource          ../../resources/KISS/robot/common_resource.robot
# Resource          ../../resources/sg10/internal_resource/internal_resource.robot
# Documentation
# ...     sinr_target_srs\=100 /azimuth=40,15,-40,-60     tapering enable   pass
# ...     actUeCsirsCoexistCellCsirs  true  pass
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_84878_case01_MP.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_84878.xml
# ${WTS_NAME}      WTS_1cell_SA_NSA_84878.lua
# ${UE_ID1}         1
# ${UE_ID2}         2
# ${UE_ID3}         3
# ${UE_ID4}         4
# @{LOG_NAME_LIST}    gnb_snapshot    # ap_snapshot    egatelog
# ${FILTER_1}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
# @{titles_1}    DlData_PdschGrant.bestBeamPowerOffset
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='false'   L2HI_MIRRORING='false'   L2RT_MIRRORING='false'
# ...    CPRT_MIRRORING='false'    NUMBER_OF_FILES=20
# @{Rdparameter}    0x580264:3   0x340000:3
# ${UE_NUM}         2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# 
# ${TP_PEAK_DL}    1050000
# ${TP_PEAK_DL_MU}  2100000
# ${TP_PEAK_UL}    150000
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
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=51 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-300,-300
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-300,-300
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-300,-300
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-300,-300
# 
# *** Test Cases ***
# CNI84878_case01_A_B1_Beam_power_balancing_optimizations_for_CB008305_with_varible_rank_without_tapering
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     Wait '10s' for stable
#     Fix 2UE rank'4''4' and check bestbeampoweroffset
#     Fix 2UE rank'3''4' and check bestbeampoweroffset
#     Fix 2UE rank'2''4' and check bestbeampoweroffset
#     Fix 2UE rank'1''4' and check bestbeampoweroffset
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
# 
# *** Keywords ***
# step1:get ready for gnb
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Prepare gnb onair
# 	Airphone Cleanup Egate Console Log
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=0
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 ri\=2
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=5 cqi\=15 ri\=3
# 
# 
# Fix UEs to '${ue1_rank}''${ue2_rank}'
#     ${ue1_rank_file}    evaluate    ${ue1_rank}+1
#     ${ue2_rank_file}    evaluate    ${ue2_rank}+1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=${ue1_rank_file}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=${ue2_rank_file}
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     Start capture only gnb syslog in 'step2_attach' file
#     Create SRS_pos profile
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 	SA '${UE_NUM}' UE Data buffer send
# 	run keyword and continue on failure    Stop capture only gnb syslog in 'step2_attach' file
# 
# 
# Add RD
#     Add GNB swconfig    0x340000:15
#     Add GNB swconfig    0x580264:3
#     Add GNB swconfig    0x9D0000:15
# 
# Fix 2UE rank'${ue1_rank}''${ue2_rank}' and check bestbeampoweroffset
#     Start capture gnb and ap syslog in 'rank_${ue1_rank}_${ue2_rank}' file
#     Fix UEs to '${ue1_rank}''${ue2_rank}'
#     Wait '19s' for stable
#     Collect 'rank_${ue1_rank}_${ue2_rank}' ttitrace
#     Wait '5s' for stable
#     run keyword and continue on failure    Check throughput    680000    680000    ${ue1_rank}    ${ue2_rank}
#     Wait '5s' for stable
#     Collect and convert 'rank_${ue1_rank}_${ue2_rank}' BIP
#     Stop capture gnb and ap syslog in 'rank_${ue1_rank}_${ue2_rank}' file
# 
# 
# check_SRS_resource_and_PDSCH_scramblingID_SA
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/rrc_8305.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# Collect '${rank}' ttitrace
#     Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'tti_${rank}'
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/84878_ttitrace.ini
#     ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tti_${rank}/
# 
# Collect and convert '${rank}' BIP
#     Start collect bip log
#     Wait for '0.5s' to stop bip log with name'bip_${rank}'
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_${rank}/tcpdump_L2L1_bip_filtering_off.pcap00
#     ...    ${TEST_LOG_DIRECTORY()}/All/bip_${rank}/bip_${rank}.csv    ${FILTER_1}    ${titles_1}
# 
#     Check best beam power offset index in bip'${rank}'
# 
# Check best beam power offset index in bip'${rank}'
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_bestBeamPowerOffsetIndex.ini     i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_${rank}/
# 
# Check throughput
#     [Arguments]    ${ue1_tput}    ${ue2_tput}     ${ue1_rank}    ${ue2_rank}
#     Wait until keyword succeeds    60s    5s    Verify throughput-2'${ue1_tput}''${ue2_tput}''${ue1_rank}''${ue2_rank}'
# 
# Verify throughput-2'${ue1_tput}''${ue2_tput}''${ue1_rank}''${ue2_rank}'
#     ${dl_throughput_ue1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID1}    scell_id=0    type=pdsch    tput_type=ave
#     ${dl_throughput_ue2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
#     ${ue1_target}    evaluate    ${ue1_tput}*${ue1_rank}/4
#     ${ue2_target}    evaluate    ${ue2_tput}*${ue2_rank}/4
#     Log To Console    ue1_tput:${dl_throughput_ue1}  ue1_target:${ue1_target}
#     Log To Console    ue2_tput:${dl_throughput_ue2}  ue2_target:${ue2_target}
#     should_be_true    ${dl_throughput_ue1}>${ue1_target}
#     should_be_true    ${dl_throughput_ue2}>${ue2_target}
# 
# 
# check TP and bler with ttitrace
#     [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}
#     ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
#     ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
#     @{keys}  Get Dictionary Keys   ${a}
#     : FOR      ${key}     IN     @{keys}
#     \    ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
#     \    log to console   result is ${result}
#     \    log to console   TP is ${throughput}
#     \    should be true  ${result}>${throughput}
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti
# 
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   SA send mutiple trf dl data    ${num}    6   175M    ${gw_pdu_r}    tcp
#     \   SA send mutiple trf ul data    ${num}    1   20M    ${gw_pdu_r}    tcp
# 
# Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   Airphone SA Stop Data Traffic     ${num}     BI    ${gw_pdu_r}
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '4s' for stabible
# 
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# check_SRS_resource_and_PDSCH_scramblingID
#     [Arguments]    ${EGATE_TAG}
#     check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate
# 
# 
# Check mupair in ttitrace
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/8701_case02_mupair.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Overide UE bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4,5,6
#    airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
#    airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 
# 
# enhence SRS power
#     [Arguments]    ${sinr_target_srs}     ${file_snr}
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1
#     airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=2 srsMode\=fixed
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=${file_snr} sinr_target_srs\=${sinr_target_srs} noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=${file_snr}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_sinr action\=activate profile_id\=${file_snr}
#     Attach '${UE_NUM}' SA UE
#     SA '${UE_NUM}' UE Data buffer send
#     Start capture gnb and ap syslog in '${sinr_target_srs}_${file_snr}' file
#     Collect '${sinr_target_srs}_${file_snr}' ttitrace
#     Stop capture gnb and ap syslog in '${sinr_target_srs}_${file_snr}' file
#     Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
# 
# Create SRS_pos profile
#     : FOR    ${num}    IN RANGE    2    6
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    run keyword if    1<=${num}<=1    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     \    run keyword if    2<=${num}<=2    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
#     \    run keyword if    3<=${num}<=3    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     \    run keyword if    4<=${num}<=4    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
#     \    run keyword if    5<=${num}<=9    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     \    run keyword if    10<=${num}<=10    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# 
# Attach '${UE_NUM_SA}' SA UEs with f1ap
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
# #    \   airphone_cleanup_egate_console_log
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \   Start collect UE f1ap    UE${num}_attach_f1ap
#     \   Airphone SA Attach    ue_id=${num}
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
#     \   Wait '1s' for stable
# #    \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}
# 
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
# 
# DeRegister ‘${UE_NUM}’ SA UEs
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '2s' for stabible
