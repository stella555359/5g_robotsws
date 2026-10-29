*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_MP_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Documentation     chbw 80mhz
...   256qam enable
...   dmrs_fdm enable
...   1208 frame  4X4 mimo

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}     SCFC_8305_case22_MP.xml
${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO.xml
${WTS_NAME}      WTS_1cell_SA_NSA.lua
@{LOG_NAME_LIST}    gnb_snapshot

${UE_NUM}  10
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
${EGATE_TAG}      MUmimo
${BIP_TAG}    mumumo_bip
${peak_tp_AP}    1200000     #2000000
${peak_tp_tti}   1000000    #1200000

${TP_PEAK_DL}    1050000
${TP_PEAK_DL_MU}  2100000
${TP_PEAK_UL}    150000

${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=51 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=24 zenith\=-10 srs_transmit_power_per_port\=-300,-300,-250,-250
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-45 zenith\=-30 srs_transmit_power_per_port\=-300,-300,-250,-250

*** Test Cases ***
CB008305_C_B2_case22_2UEs_rank2_Powersaving
    step1:get ready for gnb
    step2:attach UEs with Pos and get rnti
    step3:trigger powersaving and check pairing
    step4:powersaving shut down and check pairing

*** Keywords ***
step1:get ready for gnb
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Prepare gnb onair
	Airphone Cleanup Egate Console Log

step2:attach UEs with Pos and get rnti
    Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
    Start capture only gnb syslog in 'step2_attach' file
    Create SRS_pos profile
	Attach '${UE_NUM}' SA UEs with f1ap
	set '${UE_NUM}' SA UEs Pos
	run keyword and continue on failure    Stop capture only gnb syslog in 'step2_attach' file

step3:trigger powersaving and check pairing
    Log To Console   \n-------------step3:trigger powersaving and check pairing---------------
    Start capture gnb and ap syslog in 'step3_powersaving_trigger' file
    SA send data '${UE_NUM}' UEs little
    Wait '10s' for stable
    Wait until keyword succeeds    50s    12s    Check ue mu pair and tput is correct    ${peak_tp_AP}    8    #2ue without data
    Start collect ttitrace    name=powersaving_trigger
    Wait for '1.5s' to stop ttitrace with name'powersaving_trigger'
    run keyword and continue on failure    check TP and bler with ttitrace   ${peak_tp_tti}    1
    ...    powersaving_trigger    tti_dl_case22_bwpenable   8   #2ue without data
#    Get 8305 counter
    run keyword and continue on failure    Airphone '${UE_NUM}' SA Stop Data Traffic
    Stop capture gnb and ap syslog in 'step3_powersaving_trigger' file

step4:powersaving shut down and check pairing
    Log To Console   \n-------------step4: powersaving shut down and check pairing---------------
    Start capture gnb and ap syslog in 'step4_PS_off' file
    SA send data '${UE_NUM}' UEs
    Wait until keyword succeeds    50s    12s    Check ue mu pair and tput is correct    ${peak_tp_AP}    8
    Start collect ttitrace    name=PS_off
    Wait for '1.5s' to stop ttitrace with name'PS_off'
    run keyword and continue on failure    check TP and bler with ttitrace   ${peak_tp_tti}    1
    ...    PS_off   tti_dl_case22_bwpdisable   8
    Get 8305 counter
    Stop capture gnb and ap syslog in 'step4_PS_off' file

Get 8305 counter
    Wait '40s' for stable
    ${PRB_DL_SU_MIMO_LAYER_list}   create list
    ${PRB_DL_MU_MIMO_LAYER_list}   create list
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    counter remianing time is ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
  ${8701_pair_counter}   create list
    FOR    ${num}    IN RANGE    1    30
        ${counter_1}   evaluate   4000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C3${counter_1}    cell_id=1
        append to list    ${8701_pair_counter}    ${result}
    END
    log to console    8701_pair_counter all are = ${8701_pair_counter}
    log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are = ${8701_pair_counter[0:4]}
    log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are = ${8701_pair_counter[4:11]}
    log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_7_8 are = ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
    log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are = ${8701_pair_counter[15:23]}
    log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are = ${8701_pair_counter[27]} ${8701_pair_counter[28]}

    ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
    ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
    ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
    run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
    run keyword and continue on failure   should be true   ${PRB_DL_SU_MIMO_layer_total}>=${8701_pair_counter[11]}
    run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
    log to console    PRB_DL_SU_MIMO_layer_total are = ${PRB_DL_SU_MIMO_layer_total}
    log to console    PRB_DL_MU_MIMO_layer_total are = ${PRB_DL_MU_MIMO_layer_total}
    log to console    PRB_DL_MU_paired_UE_total are = ${PRB_DL_MU_paired_UE_total}

    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_2}    cell_id=1
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55366C0${counter_3}    cell_id=1
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C0${counter_3}    cell_id=1
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END


    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=1
    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=1
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=1
#    log to console    PDSCH_INI_VOL_64TBL_MCS_list 0_to_28 is ${PDSCH_INI_VOL_64TBL_MCS_list}
#    log to console    PDSCH_INI_VOL_256TBL_MCS_list 0_to_27 is ${PDSCH_INI_VOL_256TBL_MCS_list}
#    log to console    MEAS_PERIOD_NR_MAC_PDU_TPUT is ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#    log to console    PRB_USED_PDSCH is ${PRB_USED_PDSCH}
#    log to console    PRB_AVAIL_PDSCH is ${PRB_AVAIL_PDSCH}

    ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
    ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
    ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
    ${NR_5242b_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
    ${NR_5242b_fenzi2}    evaluate    ${NR_5242b_fenzi1}/${MEAS_PERIOD_NR_MAC_PDU_TPUT}
    ${NR_5242b_fenmu}    evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
    ${NR_5242b}    evaluate    ${NR_5242b_fenzi2}/${NR_5242b_fenmu}
#    log to console    NR_5242b is ${NR_5242b}

Add bler to '${UE_NUM}' SA UE
    airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=10,2,3,4,5,6   #add bler
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
    END
    Wait '20s' for stable

SA send data '${UE_NUM_SA}' UEs
    log to console    push data for UEs
    ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
    ${data_num}    evaluate   int(${ue_peak}/175)
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        run keyword if    1<=${num}<=8    SA send mutiple trf dl data    ${num}    2   135M   ${gw_pdu_r}    tcp
        run keyword if    1<=${num}<=8    SA send mutiple trf ul data    ${num}    1    30M   ${gw_pdu_r}
        run keyword if    9<=${num}<=10    SA send mutiple trf dl data    ${num}    1   2M   ${gw_pdu_r}    tcp
        run keyword if    9<=${num}<=10    SA send mutiple trf ul data    ${num}    1    2M   ${gw_pdu_r}
    END

SA send data '${UE_NUM_SA}' UEs little
    log to console    push data for UEs
    ${ue_peak}    evaluate   int(${TP_PEAK_DL_MU}/1000/${UE_NUM})
    ${data_num}    evaluate   int(${ue_peak}/175)
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        run keyword if    1<=${num}<=8    SA send mutiple trf dl data    ${num}    2   135M   ${gw_pdu_r}    tcp
        run keyword if    1<=${num}<=8    SA send mutiple trf ul data    ${num}    1    30M   ${gw_pdu_r}
        run keyword if    9<=${num}<=10    SA send mutiple trf dl data    ${num}    1   300   ${gw_pdu_r}    tcp
        run keyword if    9<=${num}<=10    SA send mutiple trf ul data    ${num}    1   300   ${gw_pdu_r}
    END

Airphone '${UE_NUM}' SA Stop Data Traffic
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
        Airphone SA Stop Data Traffic     ${num}     DL    ${gw_pdu_r}
    END

Check_rrc
    [Arguments]    ${EGATE_TAG}
    check_log_with_au2anlysis    ${CURDIR}/ini/8305_case22_rrclog.ini    p
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

Set '${UE_NUM}'UE different DOA and enhence SRS power
    airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
    airphone_execute_egate_command    ue_srs_beam_pos_nr profile_id\=2 init_pos\=2 srsMode\=fixed
    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=180 sinr_target_pucch\=-300 noise_srs\=-1053
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
         run keyword if   ${num}%2==1      airphone_execute_egate_command
    ...   ue_testmode_set_nr id\=${num} testmode\=ue_srs_beam_pos action\=activate profile_id\=1
         run keyword if   ${num}%2==0      airphone_execute_egate_command
    ...   ue_testmode_set_nr id\=${num} testmode\=ue_srs_beam_pos action\=activate profile_id\=2
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_sinr action\=activate profile_id\=5
    END

Check rrc log
    Airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All/egate    unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/rrc_8305.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate

check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}    ${ini_file}    ${UE_NUM}=8
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    ${Target}    evaluate  ${throughput}/${UE_NUM}/1024
    ${UEs_TP_DL_tti}   create list
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        append to list    ${UEs_TP_DL_tti}    ${result}
#        log to console   result is ${UEs_TP_DL_tti}
        run keyword and continue on failure    should be true  ${result}>${Target}
    END
    log to console   target is ${Target}
    log to console   tti result is ${UEs_TP_DL_tti}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti

Check ue mu pair and tput is correct
    [Arguments]    ${ue_tput_peak}    ${UE_NUM}=2
    ${ret_y}    evaluate    ${ue_tput_peak}/${UE_NUM}
    log to console    target is ${ret_y}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${dl_tput}    airphone_get_throughput_on_specific_scell    ue_id=${num}   scell_id=0    type=pdsch    tput_type=ave
        ${ul_tput}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should be true    ${dl_tput}>${ret_y}
        append to list    ${UEs_TP_DL}    ${dl_tput}
        append to list    ${UEs_TP_UL}    ${ul_tput}
    END
    log to console    8UEs_DL_TP_total are ${UEs_TP_DL}
    log to console    8UEs_UL_TP_total are ${UEs_TP_UL}

Add RD
    Add GNB swconfig    0x340000:15
    Add GNB swconfig    0x9D0000:15


Create SRS_pos profile
    FOR    ${num}    IN RANGE    2    6
        airphone_execute_egate_command    ${PROFILE${num}}
    END

set '${UE_NUM}' SA UEs Pos
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        run keyword if    1<=${num}<=2    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
        run keyword if    3<=${num}<=4    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
        run keyword if    5<=${num}<=6    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
        run keyword if    7<=${num}<=8    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
        run keyword if    9<=${num}<=9    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
        run keyword if    10<=${num}<=10    airphone_execute_egate_command
    ...    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    END

Attach '${UE_NUM_SA}' SA UEs with f1ap
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       ${gw_pdu_r}    evaluate    ${num}%10+1
       Start collect UE f1ap    UE${num}_attach_f1ap
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '1s' for stable
       Log To Console   attach UE${num} successfully
       Stop collect UE f1ap    UE${num}_attach_f1ap
       Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
       Collect AP egate log    UE_${num}_rrc
       run keyword and continue on failure     Check_rrc   UE_${num}_rrc
    END



Start collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Start collect '${bip_file}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Stop collect '${bip_file}' tcpdump
    Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}

Get Crnti and gnb_du_id from f1ap
    [Arguments]     ${bip_file}    ${ue_id}
    Log To Console   Check '${bip_file}' srs_switch
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_rrc_itl_l2ps}    ${titles_duID_Crnti}
    ${gnb_du_id_list}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    f1ap.GNB_DU_UE_F1AP_ID
    Set Test Variable    ${ue${ue_id}_gnb_du_id}    ${gnb_du_id_list[0]}
    ${ue_rnti}    Get col_values from bip csv    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    3gpp.rnti
    set suite variable     ${ue${ue_id}_rnti}    ${ue_rnti[0]}
    Log To Console   \n------UE${ue_id} gnb_du_id is ${ue${ue_id}_gnb_du_id},crnti is ${ue${ue_id}_rnti}-----

Get col_values from bip csv
    [Arguments]    ${csv_file}    ${col_name}
    ${col_values}    read_csv_columns    ${csv_file}    ${col_name}
    ${col_value_list}    Remove Duplicates    ${col_values}
    [return]     ${col_value_list}

Check UE srs_switch from s1ap
    [Arguments]     ${bip_file}    ${ini_paht}
    Log To Console   Check '${bip_file}' srs_switch
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_paht}.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/

DeRegister ‘${UE_NUM}’ SA UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '2s' for stabible
