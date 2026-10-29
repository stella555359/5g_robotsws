# *** Settings ***
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_9235_B_case16.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_2CELL_APLO.xml
# ${WTS_NAME}    wts_9235_2cell_SA_NSA_CA.lua
# @{LOG_NAME_LIST}    gnb_snapshot
# ${UE_NUM}    14
# ${egate_tag}    egate
# ${command}    sudo ./gnb_logs -t -c -cp
# 
# ${TP_PEAK_DL}    641000
# ${TP_PEAK_DL_MU}  1280000
# ${TP_PEAK_UL}    126000   #211mbps
# 
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# @{Rdparameter}     0x340000:3
# ${TP_sum}    0
# @{TOOLS_LIST}    luashark    ttitrace_decode    bip_script    common_config_golden    common_config_private    mcshark
# ${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
# @{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
# ...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
# ${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
# ...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
# @{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
# 
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=10 srs_transmit_power_per_port\=-300,-300,-250,-250
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
# ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=10 srs_transmit_power_per_port\=-300,-300,-250,-250
# 
# *** Test Cases ***
# CB009235_B_B101_CASE16_dlMuAware_Macce_TCI state Indication_with_nonGBR_retrans_mueligible_and_pairing
#     step1:get ready for gnb
#     step2:attach UEs with Pos and get rnti
#     step3:9235 enable check by ttilog
#     step4:Send A1 event for '10' UEs to add scell
#     step5:trigger UEs beam change
#     step6:add bler and change beam
#     step7:stop UEs data and change beam
#     step8:disable 9235 and check MACce
#     Airphone SA Detach UE
# 
# *** Keywords ***
# Add RD
#     Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
#     Add GNB swconfig    0x580776:1   #rdDlMuSbBfMode
#     Add GNB swconfig    0x580789:1   #disableRD by NIDD
#     Add GNB swconfig    0x580539:9   #Num UE threshold,to collect trace
# 
# step1:get ready for gnb
# 	Add RD
# 	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/L2-PS    #WRN/.uplane
# 	Set Test Variable    ${custom_error}
# 	Prepare gnb onair
# 	Airphone Cleanup Egate Console Log
# 
# step2:attach UEs with Pos and get rnti
#     Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
#     online change parameters    delta_9235_case10    true    10    80
#     Create SRS_pos profile
#     set '${UE_NUM}' SA UEs beam
# 	Attach '${UE_NUM}' SA UEs with f1ap
# 	set '${UE_NUM}' SA UEs Pos
# 	SA send data '${UE_NUM}' UEs
# 	Wait '10s' for stable
# 
# step3:9235 enable check by ttilog
#     Log To Console   \n-------------step3:9235 enable check by ttilogg---------------
# 	run keyword and continue on failure	   Get UEs TP for debug
# #	run keyword and continue on failure	   Collect bip and Check
# #    run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case03_step3_tti
# 
# step4:Send A1 event for '${UE_NUM}' UEs to add scell
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=100
# 
# step5:trigger UEs beam change
#     Log To Console   \n-------------step5:trigger UEs beam change---------------
#     airphone_cleanup_egate_console_log
#     Start capture only gnb syslog in 'step5_beamChange' file
#     Start collect ttitrace    name=step5_beamChange    lcr_cell_id=1
#     Trigger '10' SA UEs beam change file '3'
#     Wait for '0.1s' to stop ttitrace with name'step5_beamChange'
#     run keyword and continue on failure	   Check ttitrace with ini    step5_beamChange    Case16_step5_tti
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'step5_beamChange' file '${custom_error}'
#     Collect AP egate log    step5_beamChange
# 
# step6:add bler and change beam
#     Log To Console   \n-------------step6:add bler and change beam---------------
#     Start capture only gnb syslog in 'step6_beamchange_wittBler' file
#     airphone_cleanup_egate_console_log
#     add '14'UEs bler
#     Start collect ttitrace    name=step6_beamchange_wittBler    lcr_cell_id=1
#     Trigger '10' SA UEs beam change file '4'
#     Wait for '0.5s' to stop ttitrace with name'step6_beamchange_wittBler'
#     run keyword and continue on failure	   Check ttitrace with ini    step6_beamchange_wittBler    Case16_step6_tti
#     remove '14'UEs bler
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'step6_beamchange_wittBler' file '${custom_error}'
#     Collect AP egate log    step6_beamchange_wittBler
# #    capture snapshot start once    step6
# 
# step7:stop UEs data and change beam
#     Log To Console   \n-------------step7:stop UEs data and change beam---------------
#     Start capture only gnb syslog in 'step7_stop2UEdata_macce_only' file
#     Stop '4' UEs data
#     add '14'UEs bler
#     Start collect ttitrace    name=step7_stop2UEdata_macce_only    lcr_cell_id=1
#     Trigger '10' SA UEs beam change file '2'
#     Wait for '0.5s' to stop ttitrace with name'step7_stop2UEdata_macce_only'
#     run keyword and continue on failure	   Check ttitrace with ini    step7_stop2UEdata_macce_only    Case16_step7_tti
#     remove '14'UEs bler
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'step7_stop2UEdata_macce_only' file '${custom_error}'
#     Collect AP egate log    step7_stop2UEdata_macce_only
# 
# step8:disable 9235 and check MACce
#     Log To Console   \n-------------step8:disable 9235 and check MACce---------------
#     online change parameters    delta_9235_case10    false    10    10
#     Start capture only gnb syslog in 'step8_disable_macce' file
# #    resend '4' UEs data
#     add '14'UEs bler
#     Start collect ttitrace    name=step8_disable_macce    lcr_cell_id=1
#     Trigger '10' SA UEs beam change file '3'
#     Wait for '0.5s' to stop ttitrace with name'step8_disable_macce'
#     run keyword and continue on failure	   Check ttitrace with ini    step8_disable_macce    Case16_step8_tti
#     remove '14'UEs bler
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'step8_disable_macce' file '${custom_error}'
#     Collect AP egate log    step8_disable_macce
#     capture snapshot start once    step8_disable_macce
# 
# 
# add '${UE_NUM}'UEs bler
#    Log To Console   add bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=95,2,3,4
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# remove '${UE_NUM}'UEs bler
#    Log To Console   remove bler
#    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=0,0,0,0
#    : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#    \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
# 
# Stop '${UE_NUM_SA}' UEs data and resend with full data again
#     Log To Console    --stop and resend ${UE_NUM_SA}UE data
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=dl
# #    \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=ul
#     Wait '8s' for stable
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    1   40M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    1M   ${gw_pdu_r}
# 
# Stop '${UE_NUM_SA}' UEs data
#     Log To Console    --stop ${UE_NUM_SA}UE data
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=dl
# #    \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=ul
#     Wait '10s' for stable
# 
# resend '${UE_NUM_SA}' UEs data
#     Log To Console    --resed ${UE_NUM_SA}UE data
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    1   60M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    1M   ${gw_pdu_r}
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
# override '${UE_NUM_SA}' UEs Scell CQI trigger bad threshold
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1 ri\=3
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     \    Log To Console    --override UE${num} bad rlq
# 
# capture snapshot start once
#     [Arguments]    ${log_tag}
#     Log To Console    --capture snapshot start
#     Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip
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
#     : FOR    ${num}    IN RANGE    2    5
#     \    airphone_execute_egate_command    ${PROFILE${num}}
# 
# set '${UE_NUM}' SA UEs Pos
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    run keyword if    ${num}<7    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
#     \    run keyword if    ${num}>=7    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# 
# set '${UE_NUM}' SA UEs beam
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=2 ueBeamIndexInitial\=0,1,2,3,4,5 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
# 	airphone_execute_egate_command
# 	...    beam_control_testmode_nr profile_id\=3 ueBeamIndexInitial\=2,3,4,5,0,1 ssbeam_bestbeam\=2 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-85
# 	airphone_execute_egate_command
# 	...    beam_control_testmode_nr profile_id\=4 ueBeamIndexInitial\=4,5,0,1,2,3 ssbeam_bestbeam\=4 ssbeam_rsrp_best\=-45 ssbeam_rsrp_avg\=-75
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=2 beamaction\=switch scell\=0,1
# 
# Trigger '${UE_NUM}' SA UEs beam change file '${profile_id}'
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${num} testmode\=beam_control action\=activate profile_id\=${profile_id} beamaction\=switch scell\=0,1
#     \   Log To Console    --UE${num} beam change
# 
# SA '${UE_NUM}' UE Data buffer send
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \   SA send mutiple trf dl data    ${num}    2   175M    1   #peak 375mbps
#     \   SA send mutiple trf ul data    ${num}    1   10M    1
# 
# Trigger ‘${UE_NUM}’ ue release and addition
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr event\=A2 id\=${num} meas_id\=2 rs_type\=ssb scell\=1 scell_rsrp\=30
#     \    Log To Console    --release UE${num} scell
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=3 event\=A1 srsrp_nr\=100
#     \    Log To Console    --add back UE${num} scell
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
#     Wait for '1s' to stop bip log with name'step3_bip'
# 
# 
# Collect ttitrace and Check
#     [Arguments]     ${tti_tag}    ${ini_file}
# 	Start collect ttitrace
#     Wait for '1s' to stop ttitrace with name'${tti_tag}'
#     run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
# #    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv
#     check_cdm_group_and_dmrs_port_by_antenna_port_value     ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv
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
#     \   Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${gw_pdu_r}    type=internal
#     \   Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
#     \   Wait '1s' for stable
#     \   Log To Console   attach UE${num} successfully
#     \   Stop collect UE f1ap    UE${num}_attach_f1ap
#     \   Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
# 
# SA send data '${UE_NUM_SA}' UEs
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    1   100M   ${gw_pdu_r}    tcp
#     \    SA send mutiple trf ul data    ${num}    1    3M   ${gw_pdu_r}
# 
# Stop '${UE_NUM_SA}' UEs data and resend with little data again
#     ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
#     ${data_num}    evaluate   int(${ue_peak}/175)
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=dl
# #    \    airphone_execute_egate_command   trf_data_stop ue\=${num} pdu\=${gw_pdu_r} qfi\=1 dir\=ul
#     airphone_execute_egate_command   trf_data_stop ue\=1 pdu\=2 qfi\=3 dir\=dl   #ue1 has gbr
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#     \   ${gw_pdu_r}    evaluate    ${num}%10+1
#     \    SA send mutiple trf dl data    ${num}    1   1M   ${gw_pdu_r}    tcp
# #    \    SA send mutiple trf ul data    ${num}    1    1M   ${gw_pdu_r}
#     airphone_execute_egate_command   trf_data_start ue\=1 pdu\=2 qfi\=3 trf_id\=1 kbps\=500 dir\=dl
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
#     Modify Txt Node    TTI_log_files:100    BIP_log_files:12
#     teardown_txt