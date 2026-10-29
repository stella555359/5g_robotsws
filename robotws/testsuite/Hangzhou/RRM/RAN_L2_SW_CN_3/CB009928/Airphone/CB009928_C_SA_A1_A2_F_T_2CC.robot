*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Documentation
...     9928 test

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${SCFC_NAME}      SCFC_9928_C_A1_A2_NSA_2T_2F_3.xml
${SCFC_NAME}      SCFC_9928_C_A1_A2_NSA_2T_2F_6_multi.xml     #mumimo+multibwp+8927+powersaving
#${AIRPHONE_NAME}    IPHY_2AQQL_AHFIB_AHLOA_8x4.xml
${AIRPHONE_NAME}    IPHY_2AQQL_AHFIB_AHLOA_6.xml
#${WTS_NAME}    WTS_4cell_SA_NSA_2TDD_2FDD.lua
${WTS_NAME}    WTS_4cell_SA_NSA_2TDD_2FDD_6.lua

#${SCFC_NAME}      SCFC_9928_C_A1_A2_NSA_2T_2F_4.xml     #mumimo+multibwp
#${SCFC_NAME}      SCFC_9928_C_A1_A2_NSA_2T_2F_5.xml     #mumimo+multibwp+8927+powersaving

@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM_SA_switch}    30
${UE_NUM_SA}    45    #40
#${UE_NUM_SWITCH}    30    #30
${UE_NUM_SA_A1}   15
${UE_NUM_SA_A2}   16
#${UE_NUM_SA_cell1}    40


#${UE_NUM_SA_switch}    10    #A1+A2 switch
#${UE_NUM_SA}    10    #40
#${UE_NUM_SA_A1}   5
#${UE_NUM_SA_A2}   6

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${TP_PEAK_DL}    1300000
${TP_PEAK_DL_MU}  5200000
${TP_PEAK_UL}    150000   #211mbps

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250


*** Test Cases ***
CB009928_C_B3_321_A2_measurement_based_Pcell_switch_from_F_to_T_SA_DL_3CC_CA_KPI_PMCounter
    step1:get ready for gnb
    step2:Attach SA UE and check scelladdition
    step3:trigger 15SA UEs A1 Pcell switch and 15 SA UES A2 Pcell Switch
   # step4:trigger SA scell addition
   # step5:trigger SA UE A1 pcell switch back to cell2
   # step6:trigger SA scell addition again

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    #WRN/.uplane    WRN/L2-PS
	Set Test Variable    ${custom_error}
	Prepare gnb onair
	Create SRS_pos profile
	set UEs Pos
#   Get gnb_logs from git
#	modify gnb_logs config

step2:Attach SA UE and check scelladdition
    Log To Console   \n-------------step2:Attach SA UE and check scelladdition---------------
    Start capture only gnb syslog in 'step2' file
    FOR    ${num}    IN RANGE    1    1+${UE_NUM_SA}
        airphone_cleanup_egate_console_log
        ${gw_pdu_r}    evaluate    ${num}%10+1
        Start collect UE f1ap    UE${num}_attach_f1ap
        Airphone SA Attach    ue_id=${num}
        Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
        Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
        Log To Console   attach UE${num} successfully
        Stop collect UE f1ap    UE${num}_attach_f1ap
#        Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=98    #TDD scell addition
        Collect AP egate log    ${num}_step2
        run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step2    ini=fdd_cell4_scell_addition
    END

     SA send data UEs    start=1    end=${UE_NUM_SA}
     Verify fullbuffer CAUE throughput    CA_start=1    CA_end=${UE_NUM_SA}
     ${PM_counter_file}    Get counter file     #check 99999999928
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
#     3CC_CA_tti_check    tti_file=step2
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'

SA send data UEs
    [Arguments]     ${start}    ${end}=45    ${mhz}=55
    log to console    push data for UEs
    FOR    ${num}    IN RANGE    ${start}    ${start}+${end}
        ${gw_pdu_r}    evaluate    ${num}%10+1
        SA send mutiple trf dl data    ${num}    1   ${mhz}M   ${gw_pdu_r}    tcp    #175mbps
        SA send mutiple trf ul data    ${num}    1    15M   ${gw_pdu_r}
    END

step3:trigger 15SA UEs A1 Pcell switch and 15 SA UES A2 Pcell Switch
     Log To Console   \n-------------step3:trigger 15SA UEs A1 Pcell switch and 15 SA UES A2 Pcell Switch---------------
     Start capture only gnb syslog in 'step3_UE_a1_pcellwitch' file
     FOR    ${num}    IN RANGE    1    ${UE_NUM_SA_A1}+1      #5ue switch ,5ue stable
         airphone_cleanup_egate_console_log
         airphone_execute_egate_command
         ...    ue_measurement_send_nr id\=${num} meas_id\=4 event\=A1 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=100 scell_rsrq\=100
         Collect AP egate log    ${num}_step3_a1
         run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step3_a1    ini=handover_ft_4_to_1
     END
     ${PM_counter_file}    Get counter file     #check 99999999928
     ${get KPI NR_1289a}    get KPI NR_1289a    ${PM_counter_file}    cell_id=4
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     run keyword and continue on failure    should be true    ${get KPI NR_1289a}==1
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3_UE_a1_pcellwitch' file '${custom_error}'
     Start capture only gnb syslog in 'step3_UE_a2_pcellwitch' file
     FOR    ${num}    IN RANGE    ${UE_NUM_SA_A2}    ${UE_NUM_SA_A2}+${UE_NUM_SA_A1}      #5ue switch ,5ue stable
         airphone_cleanup_egate_console_log
         airphone_execute_egate_command
         ...    ue_measurement_send_nr id\=${num} meas_id\=6 event\=A2 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=100 scell_rsrq\=100
         Collect AP egate log    ${num}_step3_a2
         run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step3_a2    ini=handover_ft_4_to_1
     END
     ${PM_counter_file}    Get counter file     #check 99999999928
     ${get KPI NR_5318a}    get KPI NR_5318a    ${PM_counter_file}    cell_id=4
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
     should be true    ${NR_5054a_ini_bler}<0.01
     should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure     should be true    ${NR_5055b_res_bler}==0
     Verify fullbuffer Mix_CAUE throughput    CA_start=1
     3CC_CA_tti_check    tti_file=step3
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3_UE_a2_pcellwitch' file '${custom_error}'

step4:trigger SA scell addition
     Log To Console   \n-------------step4:trigger SA scell addition---------------
     Start capture only gnb syslog in 'step4' file
     FOR    ${num}    IN RANGE    1    1+${UE_NUM_SA_switch}       #5ue switch ,5ue stable
         airphone_cleanup_egate_console_log
         airphone_execute_egate_command
         ...    ue_measurement_send_nr id\=${num} meas_id\=9 event\=A1 rs_type\=ssb srsrp_nr\=98     #NSA A1 based pcell switch
         Collect AP egate log    ${num}_step4
         run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step4    ini=tdd_cell1_scell_addition_3cc_2
     END
     Verify fullbuffer Mix_CAUE throughput_3CC    CA_start=1
     Airphone SA Stop Data    ue_start=1    ue_end=45
     SA send data UEs    start=1    end=${UE_NUM_SA}    mhz=75
     ${PM_counter_file}    Get counter file     #check 99999999928
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step4' file '${custom_error}'

step5:trigger SA UE A1 pcell switch back to cell2
    Log To Console   \n-------------step5:trigger SA UE A1 pcell switch back to cell2---------------
     airphone_cleanup_egate_console_log
     Start capture only gnb syslog in 'step5' file
     FOR    ${num}    IN RANGE    1    1+${UE_NUM_SA_switch}       #5ue switch ,5ue stable
         airphone_execute_egate_command
        ...    ue_measurement_send_nr id\=${num} meas_id\=10 event\=A1 srsrp_nr\=11 srsrq_nr\=11 scell\=1 scell_rsrp\=100 scell_rsrq\=100
         Collect AP egate log    ${num}_step5
         run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step5    ini=handover_ft_1_to_2
     END
     Airphone SA Stop Data    ue_start=1    ue_end=45
     SA send data UEs    start=1    end=${UE_NUM_SA}    mhz=75
     ${PM_counter_file}    Get counter file     #check 99999999928
#     ${get KPI NR_1289a}    get KPI NR_1289a    ${PM_counter_file}    cell_id=1
#     run keyword and continue on failure    should be true    ${get KPI NR_1289a}==1
#     run keyword and continue on failure    should be true    ${get KPI NR_1289a}==1
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     run keyword and continue on failure    should be true    ${NR_5054a_ini_bler}<0.01
     run keyword and continue on failure    should be true    ${NR_5055b_res_bler}==0
     Verify fullbuffer Mix_CAUE throughput    CA_start=1
#     3CC_CA_tti_check    tti_file=step5
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step5' file '${custom_error}'

step6:trigger SA scell addition again
     Log To Console   \n-------------step6:trigger SA scell addition again--------------
     airphone_cleanup_egate_console_log
     Start capture only gnb syslog in 'step6' file
     FOR    ${num}    IN RANGE    1    1+${UE_NUM_SA_switch}
         airphone_execute_egate_command
         ...    ue_measurement_send_nr id\=${num} meas_id\=18 event\=A1 rs_type\=ssb srsrp_nr\=98      #NSA A1 based pcell switch
         Collect AP egate log    ${num}_step6
         run keyword and continue on failure     Analyse RRC airphone rrclogs   ${num}_step6    ini=tdd_cell1_scell_addition_3cc
    END

     Verify fullbuffer Mix_CAUE throughput_3CC    CA_start=1
     ${PM_counter_file}    Get counter file     #check 99999999928
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=1
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=1
     should be true    ${NR_5054a_ini_bler}<0.01
     should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=2
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=2
     should be true    ${NR_5054a_ini_bler}<0.01
     should be true    ${NR_5055b_res_bler}==0
     ${NR_5055b_res_bler}    get KPI NR_5055b    ${PM_counter_file}    cell_id=4
     ${NR_5054a_ini_bler}    get KPI NR_5054a    ${PM_counter_file}    cell_id=4
     should be true    ${NR_5054a_ini_bler}<0.01
     should be true    ${NR_5055b_res_bler}==0
#     3CC_CA_tti_check    tti_file=step6
	 run keyword and continue on failure    Stop capture gnb and ap syslog in 'step6' file '${custom_error}'

Get counter file
    FOR    ${num}    IN RANGE    1    1200
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=3min
        log to console    \n${remaining_time}
        Wait '2s' for stable
        ${remaining_time_real}    evaluate    ${remaining_time}-230    #230 time update PM file
        log to console    \n${remaining_time_real}
        Run Keyword if    ${num}>=10 and ${remaining_time_real}==0   Exit For Loop
        Run Keyword if    ${num}>=10 and ${remaining_time_real}==1   Exit For Loop
        Run Keyword if    ${num}>=10 and ${remaining_time_real}==2   Exit For Loop
        Run Keyword if    ${num}>=10 and ${remaining_time_real}==3   Exit For Loop
    END
    Wait '12s' for stable
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    [Return]    ${PM_counter_file}

Analyse RRC airphone rrclogs
    [Arguments]    ${EGATE_TAG}    ${ini}
    check_log_with_au2anlysis    ${CURDIR}/ini/${ini}.ini    p
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

debug line
     airphone_execute_egate_command    ue_measurement_send_nr id\=${UEID} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=50
     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3
     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=1
     run keyword if  ${UEID}==20
     ...   airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=1 scell\=8
     run keyword if  ${UEID}==20
     ...   airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=2 scell\=9
     Wait '2s' for stable
     Collect AP egate log    ${UEID}_egate
#     run keyword and continue on failure     Analyse RRC scelladd NSA AperiCSI Set in rrclog   ${UEID}_${egate_log_tag}
     NSA full buffer sent
     Verify fullbuffer CAUE throughput

3CC_CA_tti_check
    [Arguments]     ${tti_file}
    log to console    start collect ttitrace
    Start GNB Ttitrace With Streaming Mode    lcr_cell_id=1,2,4    name=${tti_file}
    run keyword and continue on failure    Wait for '0s' to stop ttitrace with name'${tti_file}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_file}    tti_dl
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_file}    tti_ul

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
    log to console  ${\n}---decode tti start---
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

Verify fullbuffer CAUE throughput
    [Arguments]     ${CA_start}    ${CA_end}
    FOR    ${num}    IN RANGE    ${CA_start}    ${CA_start}+${CA_end}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ScellTP_${dl_throughput_scell1}_ULTP_${ul_throughput_pcell}
    END

Verify fullbuffer Mix_CAUE throughput
    [Arguments]     ${CA_start}
    ${CA_res}    evaluate    ${CA_start}+${UE_NUM_SA_switch}
    FOR    ${num}    IN RANGE    ${CA_start}    ${CA_start}+${UE_NUM_SA_switch}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ULTP_${ul_throughput_pcell}
    END
    FOR    ${num}    IN RANGE    ${CA_res}    ${CA_start}+${UE_NUM_SA}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ScellTP_${dl_throughput_scell1}_ULTP_${ul_throughput_pcell}
    END

Verify fullbuffer Mix_CAUE throughput_3CC
    [Arguments]     ${CA_start}
    ${CA_res}    evaluate    ${CA_start}+${UE_NUM_SA_switch}
    FOR    ${num}    IN RANGE    ${CA_start}    ${CA_start}+${UE_NUM_SA_switch}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
        ${dl_throughput_scell2}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=2    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        ${ul_throughput_Scell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=2    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_Scell1TP_${dl_throughput_scell1}_Scell2TP_${dl_throughput_scell2}
        Log To Console    \nUE_${num}_PcellTP_UL_${ul_throughput_pcell}_Scell1TP_UL_${ul_throughput_Scell}
    END
#        Log To Console    \nUE_${num}_PcellTP_UL_${ul_throughput_pcell}
    FOR    ${num}    IN RANGE    ${CA_res}    ${CA_start}+${UE_NUM_SA}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${dl_throughput_scell1}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=1    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console    \nUE_${num}_PcellTP_${dl_throughput_pcell}_ScellTP_${dl_throughput_scell1}_ULTP_${ul_throughput_pcell}
    END

set UEs Pos
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    1+${ue_end}
        ${pos_id}    evaluate    ${num}%10+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${pos_id}
    END


#KPI counter check
get KPI NR_5313a
    [Arguments]    ${PM_counter_file}   ${cell_id}
    ${5G_NSA_A1_Pcell_switch}    create list
    FOR    ${num}    IN RANGE    5    13
        ${counter_2}   evaluate   2000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55145C0${counter_2}    cell_id=${cell_id}
        append to list    ${5G_NSA_A1_Pcell_switch}    ${result}
    END
    log to console    5G_NSA_A1_Pcell_switch_counter is ${5G_NSA_A1_Pcell_switch}
    ${ATT}    evaluate    sum(${5G_NSA_A1_Pcell_switch[0:2]})
    ${fail}    evaluate    ${5G_NSA_A1_Pcell_switch[2]}+${5G_NSA_A1_Pcell_switch[3]}+${5G_NSA_A1_Pcell_switch[5]}
    ${total}   evaluate    sum(${5G_NSA_A1_Pcell_switch[0:2]})+${5G_NSA_A1_Pcell_switch[4]}+sum(${5G_NSA_A1_Pcell_switch[6:8]})
    ${NR_5313a}    evaluate    int((${ATT}-${fail})/${total})
    should be true    ${NR_5313a}==1
#    should be true    ${M55145C02005}>2
    log to console    5G NSA A1 based HO total success ratio is ${NR_5313a}
    [return]     ${NR_5313a}

get KPI NR_5493a
    [Arguments]    ${PM_counter_file}   ${cell_id}
    ${5G_NSA_A1_Pcell_switch}    create list
    ${5G_NSA_A2_Pcell_switch}    create list
    ${5G_SA_A1_Pcell_switch}    create list
    ${5G_SA_A2_Pcell_switch}    create list
    FOR    ${num}    IN RANGE    21    25
        ${counter_2}   evaluate   4000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55145C0${counter_2}    cell_id=${cell_id}
        append to list    ${5G_NSA_A2_Pcell_switch}    ${result}
    END

    log to console    5G_NSA_A2_Pcell_switch_counter is ${5G_NSA_A2_Pcell_switch}
#    ${SUSS}    evaluate    ${5G_NSA_A2_Pcell_switch[3]}
    ${total}    evaluate    ${5G_NSA_A2_Pcell_switch[0]}+${5G_NSA_A2_Pcell_switch[1]}+${5G_NSA_A2_Pcell_switch[2]}
    ${NR_5493a}    evaluate    int(${5G_NSA_A2_Pcell_switch[3]}/${total})
    should be true    ${NR_5493a}==1
#    should be true    ${M55145C04024}>2
    log to console    5G NSA A1 based HO total success ratio is ${NR_5493a}
    [return]     ${NR_5493a}

get KPI NR_1289a
    [Arguments]    ${PM_counter_file}   ${cell_id}
    ${5G_SA_A1_Pcell_switch}    create list
    ${5G_SA_A2_Pcell_switch}    create list
    FOR    ${num}    IN RANGE    1    5
        ${counter_2}   evaluate   2000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55145C0${counter_2}    cell_id=${cell_id}
        append to list    ${5G_SA_A1_Pcell_switch}    ${result}
    END

    log to console    5G_SA_A1_Pcell_switch_counter is ${5G_SA_A1_Pcell_switch}
    ${total}    evaluate    ${5G_SA_A1_Pcell_switch[0]}+${5G_SA_A1_Pcell_switch[2]}+${5G_SA_A1_Pcell_switch[3]}
    ${NR_1289a}    evaluate    int(${5G_SA_A1_Pcell_switch[1]}/${total})
    should be true    ${NR_1289a}==1
#    should be true    ${M55145C04024}>2
    log to console    5G SA A1-based inter-frequency intra-DU handover total success ratio per PLMN is ${NR_1289a}
    [return]     ${NR_1289a}

get KPI NR_5318a
    [Arguments]    ${PM_counter_file}   ${cell_id}
    ${5G_SA_A1_Pcell_switch}    create list
    ${5G_SA_A2_Pcell_switch}    create list
    FOR    ${num}    IN RANGE    1    5
        ${counter_2}   evaluate   3000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55145C0${counter_2}    cell_id=${cell_id}
        append to list    ${5G_SA_A2_Pcell_switch}    ${result}
    END

    log to console    5G_SA_A2_Pcell_switch_counter is ${5G_SA_A2_Pcell_switch}
    ${total}    evaluate    ${5G_SA_A2_Pcell_switch[0]}+${5G_SA_A2_Pcell_switch[2]}+${5G_SA_A2_Pcell_switch[3]}
    ${NR_5318a}    evaluate    int(${5G_SA_A2_Pcell_switch[1]}/${total})
    should be true    ${NR_5318a}==1
#    should be true    ${M55145C04024}>2
    log to console    5G SA A1-based inter-frequency intra-DU handover total success ratio per PLMN is ${NR_5318a}
    [return]     ${NR_5318a}


Online change bfSubbandSize enabled
    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8322_case27_16PRB.json
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '15s' for stable


step7:override multi_rank and check logs
    Log To Console   \n-------------step7:override multi_rank and check logs---------------
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    Log To Console   \n-------------step7:override rank3 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2 scell\=0
        Wait '1s' for stable
    END
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=3    UE2_layer=2
    Collect ttitrace and Check    tti_tag=tti_step7_1    ini_file=Case16_step7_tti_1
    Log To Console   \n-------------step7:override rank2 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=3 scell\=0
        Wait '1s' for stable
    END
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=2    UE2_layer=2
    Collect ttitrace and Check    tti_tag=tti_step7_2    ini_file=Case16_step7_tti_2
    Log To Console   \n-------------step7:override rank1 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=4 scell\=0
        Wait '1s' for stable
    END
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=1    UE2_layer=1
    Collect ttitrace and Check    tti_tag=tti_step7_3    ini_file=Case16_step7_tti_3


#get F1AP and UE id for test start
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
    Log To Console   Check '${bip_file}' Crnti and gnb_du_id
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
    [Arguments]     ${bip_file}    ${ini_path}
    Log To Console   Check '${bip_file}' srs_switch
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/${bip_file}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_file}/f1ap.csv    ${FILTER_f1ap_srsModify}    ${titles_tasSrsResourceInd}
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/${ini_path}.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_file}/
#get F1AP and UE id for test end

Collect bip and Check
    Start collect bip log
    Wait for '1s' to stop bip log with name'${BIP_TAG1}'

Add RD
#    Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true
    Add GNB swconfig    0x9D0000:5

SA send data for UEs
    [Arguments]     ${ue_start}    ${ue_end}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END

SA send data for all 20UEs
    FOR    ${num}    IN RANGE    1    5
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END
    Wait '3s' for stable
    FOR    ${num}    IN RANGE    5    9
        SA send mutiple trf dl data    ${num}    1   120M   1    tcp
        SA send mutiple trf ul data    ${num}    1    10M   1
    END
    Wait '3s' for stable
    FOR    ${num}    IN RANGE    9    19
        SA send mutiple trf dl data    ${num}    1   10k   1    tcp
        SA send mutiple trf ul data    ${num}    1   10k   1
    END

Check non_CA SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}=100
    Wait until keyword succeeds    48s    8s    Verify non_CA SA UE throughput    ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}

Verify non_CA SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${dl_target}
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${ul_target}
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    UE${ue_start} to UE${UE_NUM_SA} DL_TP_result are ${UEs_TP_DL}
    log to console    UE${ue_start} to UE${UE_NUM_SA} UL_TP_result are ${UEs_TP_UL}

Verify multi SA UEs throughput
    [Arguments]     ${ue_start}    ${ue_end}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>120000
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>10000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    UE${ue_start} to UE${UE_NUM_SA} DL_TP_result are ${UEs_TP_DL}
    log to console    UE${ue_start} to UE${UE_NUM_SA} UL_TP_result are ${UEs_TP_UL}


Get '${UE_NUM_SA}' UEs rnti
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	   ${ue_rnti}    file match all   ${TEST_LOG_DIRECTORY()}/All/attach_UE${num}_egate/egate_console.log.001   crnti: (\\d+)
	   set suite variable     ${ue${num}_rnti}    ${ue_rnti[0]}
	   Log To Console   UE_ID${num} Crnti is ${ue${num}_rnti}
    END

Airphone SA Detach UE
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        Airphone SA Detach    ue_id=${num}
    END


Attach SA UEs with f1ap
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
       Start collect UE f1ap    UE${num}_attach_f1ap_${tag}
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=1    type=internal
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=1   nwslice_id=1   gw_id=${num}
       Wait '1s' for stable
       Log To Console   attach UE${num} successfully
       Stop collect UE f1ap    UE${num}_attach_f1ap_${tag}
       Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap_${tag}    ${num}
    END
#       SA send mutiple trf ul data    ${num}    1   100k   1

Airphone SA Stop Data
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+${ue_start}
        ${gw_pdu_r}    evaluate    ${num}%10+1
        Airphone SA Stop Data Traffic     ${num}     bi    pdu=${gw_pdu_r}
    END
#    wait '10s' for stable
#    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_start}+${ue_end}+1
#        ${gw_pdu_r}    evaluate    ${num}%10+1
#        SA send mutiple trf dl data    ${num}    1   1K   ${gw_pdu_r}    tcp    #175mbps
#        SA send mutiple trf ul data    ${num}    1    1K   ${gw_pdu_r}
#    END

Create SRS_pos profile
    FOR    ${num}    IN RANGE    1    13
        airphone_execute_egate_command    ${PROFILE${num}}
    END


SA send little data buffer
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=15M
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    1   ${data}   1    tcp
        SA send mutiple trf ul data    ${num}    1    30M   1
    END

SA send full data buffer
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=170M
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    3   ${data}   1    tcp
        SA send mutiple trf ul data    ${num}    1    30M   1
    END


# gnb logs capture
Get gnb_logs from git
     ${exist}    List Directory    /home/ute
    Run keyword if    'gnb_logs-tool' not in ${exist}    OperatingSystem.Run
    ...     cd ${f};git clone https://gitlabe1.ext.net.nokia.com/p5li/gnb_logs-tool;unzip -d ${f}gnb_logs-tool ${f}gnb_logs-tool/gnb_logs.zip
    OperatingSystem.Run    rm /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    modify gnb_logs config

Start collect logs by gnb_logs
    [Arguments]    ${command}
    log to console    Start collect logs by gnb_logs
    OperatingSystem.Run    rm -rf /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129*
    TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
    TAF_SSH.Execute    chmod 777 /home/ute/gnb_logs-tool/gnb_logs/gnb_logs    connection=bsh
    TAF_SSH.Send Command    cd /home/ute/gnb_logs-tool/gnb_logs;${command}    connection=bsh
    TAF_SSH.Read Output Until    (Q)uit    connection=bsh

Wait for '${time}' to stop collect logs by gnb tool
    log to console    stop collect logs by gnb tool
    Wait '${time}' for stable
    OperatingSystem.Run    touch /home/ute/gnb_logs-tool/gnb_logs/stop_mon.log
    Wait Until Keyword Succeeds    30000    10    file should contain
    ...    /home/ute/gnb_logs-tool/gnb_logs/tool.log    Tool finished running
    OperatingSystem.Run    scp /home/ute/gnb_logs-tool/gnb_logs/BTS-1_192.168.255.129* ${TEST_LOG_DIRECTORY()}/All

modify gnb_logs config
    setup_txt    /home/ute/gnb_logs-tool/gnb_logs/config.ini
    Modify Txt Node    TTI_log_files:500    BIP_log_files:12
    teardown_txt


get KPI NR_5055b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_UNSUCC_64TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
    ${PDSCH_UNSUCC_256TBL_MCS}    create list
    ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_2}   evaluate   2000+${num}
        ${counter_3}   evaluate   3000+${num}
        ${counter_6}   evaluate   6000+${num}
        ${counter_7}   evaluate   7000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}

	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_6}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_7}    cell_id=${cell_id}
        append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
#    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
#    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
#    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
    ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
    ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
    ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
    log to console    KPI NR_5055b residual bler is ${NR_5055b}
    [Return]    ${NR_5055b}

get KPI NR_5054a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_INITX_64TBL_MCS}    create list
    ${PDSCH_SUCC_INI_64TBL_MCS}    create list
    ${PDSCH_INI_256TBL_MCS}    create list
    ${PDSCH_SUCC_INI_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    10
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0000${counter_0}    cell_id=${cell_id}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    10    29
        ${counter_0}   evaluate   0+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C000${counter_0}    cell_id=${cell_id}
        append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
    END

    FOR    ${num}    IN RANGE    0    29
        ${counter_1}   evaluate   1000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_1}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
    END
    FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
        ${counter_4}   evaluate   4000+${num}
        ${counter_5}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_4}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55300C0${counter_5}    cell_id=${cell_id}
        append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
#    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
#    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
#    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
    ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
    ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
    ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
    log to console    KPI NR_5054a ini bler is ${NR_5054a}
    [Return]    ${NR_5054a}


get KPI NR_5108d
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
    ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
    FOR    ${num}    IN RANGE    0    32
        ${counter_22}   evaluate   2000+${num}
        ${counter_6}   evaluate   6000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_22}    cell_id=${cell_id}
        append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_6}    cell_id=${cell_id}
        append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
    END

#    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
#    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}

    ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03005    cell_id=${cell_id}
    ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00016    cell_id=${cell_id}
    ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00018    cell_id=${cell_id}
    ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
    ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
    [Return]    ${NR_5108d}


get KPI NR_5258a
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${L_M55304C0400X}   create list
    ${M55304C0400X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0400${num}    cell_id=${cell_id}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C040${num}    cell_id=${cell_id}
        ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
        append to list    ${L_M55304C0400X}    ${result}
    END

    ${L_M55304C0800X}   create list
    ${M55304C0800X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0800${num}    cell_id=${cell_id}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C080${num}    cell_id=${cell_id}
        ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
        append to list    ${L_M55304C0800X}    ${result}
    END
    ${L_M55304C1000X}   create list
    ${M55304C1000X}    set variable    0
    FOR    ${num}    IN RANGE    0    10
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C1000${num}    cell_id=${cell_id}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    FOR    ${num}    IN RANGE    10    32
        ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C100${num}    cell_id=${cell_id}
        ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
        append to list    ${L_M55304C1000X}    ${result}
    END

    ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
    ${L_M55308}   create list
    ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C03006    cell_id=${cell_id}
    ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10002    cell_id=${cell_id}
    ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00009    cell_id=${cell_id}
    ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00011    cell_id=${cell_id}
    append to list    ${L_M55308}    ${M55308C03006}
    append to list    ${L_M55308}    ${M55308C10002}
    append to list    ${L_M55308}    ${M55308C00009}
    append to list    ${L_M55308}    ${M55308C00011}
    ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
    ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
#    log to console    64qam:${L_M55304C0400X}
#    log to console    dft_s_ofdm:${L_M55304C0800X}
#    log to console    256qam:${L_M55304C1000X}
#    log to console    ${L_M55308}
#    log to console    SE_KPI_Value=${NR_5109d}
    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12001    cell_id=${cell_id}
    ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
#    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
    [Return]    ${NR_5258a}


get KPI NR_5242b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
    ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
    FOR    ${num}    IN RANGE    0    29
        ${counter_2}   evaluate   1000+${num}
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_2}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55366C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
    END

    FOR    ${num}    IN RANGE    0    28
        ${counter_3}   evaluate   5000+${num}
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55304C0${counter_3}    cell_id=${cell_id}
        append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
    END

    ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55304C00001    cell_id=${cell_id}
    ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001    cell_id=${cell_id}
    ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10003    cell_id=${cell_id}
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
    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
    [Return]    ${NR_5242b}

get KPI NR_5192c and NR_5100b
    [Arguments]    ${PM_counter_file}    ${cell_id}
    ${DL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C01001    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00008    cell_id=${cell_id}
    ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02000    cell_id=${cell_id}
    ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})

    ${ACC_SCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C17001    cell_id=${cell_id}
    ${TOTAL_COSCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C02004    cell_id=${cell_id}
    ${DL_DATA_SLOTS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00001    cell_id=${cell_id}
    ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00005    cell_id=${cell_id}
    ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00015    cell_id=${cell_id}
    ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C00017    cell_id=${cell_id}
    ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
    ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
    log to console    KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}
    [Return]    ${NR_5192c}    ${NR_5100b}
