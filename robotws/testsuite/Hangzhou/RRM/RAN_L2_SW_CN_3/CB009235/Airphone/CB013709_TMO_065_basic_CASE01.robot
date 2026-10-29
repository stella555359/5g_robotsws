*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Resource    Resource/RTM_kpi_report.robot
Documentation     CB009925   author  l3gao
     ...    1pos ,130
     ...    8 pos ，130 ue
     ...    small bwp UEs
     ...    different data buffer
     ...    power saving UEs
     ...    mu pair Pcell an scell and CA traffic

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB013709_TMO_065_basic_CASE01.xml
${AIRPHONE_NAME}    IPHY_TMO_065.xml
${WTS_NAME}    WTS_TMO_065.lua
@{LOG_NAME_LIST}    gnb_snapshot    #sosreport

${egate_tag}    egate

${TP_PEAK_DL}    1300000
${TP_PEAK_DL_MU}  5200000
${TP_PEAK_UL}    150000

&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID
@{TOOLS_LIST}    luashark    ttitrace_decode    bip_script    common_config_golden    common_config_private    mcshark

${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-55 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${UE_NUM}    130
@{cpalne_common}    0x9D0000:5    0x590072:1    0x41001b:1    0x66001b:1    0x890001:1    0x890002:1
...    0x890003:1    0x890004:1    0x890005:1    0x890006:1     0x9D0000:5  #CPlane
@{13709_CB_CAtraffic_Rdparameter}    0x5802b7:10009 #rdStopCGActivationOlcPerCent
@{13709_A_Rdparameter}    0x5808A6:1 #rdEnableOverloadErrMsg    0x5800CA:4004004 #rdMaxNumUeTdDl    0x5800CB:4004004 #rdMaxNumUeTdUl
...    0x580822:30030030 #rdMinAdaptiveSlotProcessingRatio_perCent
...    0x580821:50050050 #rdMaxAdaptiveSlotProcessingRatioPerCent
*** Test Cases ***
CB013709_TMO_065_basic_CASE1
    Add 13079 RD
    Restart IWF
    step1:get ready for gnb
    step2:attach UEs with Pos and get rnti
    step3:check mu KPI manual
    Generate kpi report until success modify
    Airphone SA Detach UE

*** Keywords ***
Add 13079 RD
    Add GNB swconfig    @{cpalne_common}
#    Add GNB swconfig    @{13709_CB_CAtraffic_Rdparameter}
#    Add GNB swconfig    @{13709_A_Rdparameter}

step1:get ready for gnb
#    Start capture only gnb syslog in 'step1_on_air' file
#	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P03_COVERAGE_00520_00001
	${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/l1_application_rt
    ...    WRN/.uplane    WRN/L2-PS
	Set Test Variable    ${custom_error}
	Prepare gnb onair    multi_cells=True
	Airphone Cleanup Egate Console Log
	Build excel table
#    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step1_on_air' file '${custom_error}'

step2:attach UEs with Pos and get rnti
    Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
    Start capture only gnb syslog in 'step2_attach' file
    Change UEs cell location
    Create SRS_pos profile
	Attach '${UE_NUM}' SA UEs with f1ap
	SA send data '${UE_NUM}' UEs
	Wait '300s' for stable      #no srs pos
	set '${UE_NUM}' SA UEs Pos
    Collect AP egate log    allUE_attach
#    run keyword and continue on failure	   Collect bip and Check
#    run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step2    ini_file=Case11_tti_noNACK
	add UEs bler
	Wait '300s' for stable
	stop data for all '${UE_NUM}'ues
	Wait '180s' for stable
	SA send data '${UE_NUM}' UEs
	Wait '180s' for stable
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2_attach' file '${custom_error}'

Attach '${UE_NUM_SA}' SA UEs with f1ap
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       run keyword if    1<=${num}<=10    Start collect UE f1ap    UE${num}_attach_f1ap
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=${gw_pdu_r}    type=internal
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${gw_pdu_r}  nwslice_id=1   gw_id=${gw_pdu_r}
       Wait '1s' for stable
       airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} dir\=dl trf_id\=5 mbps\=1 seconds\=60000s
#       SA send mutiple trf dl data    ${num}    1   1M   ${gw_pdu_r}    tcp
       run keyword if    1<=${num}<=10    airphone_execute_egate_command
       ...    ue_pdu_session_modify ue\=${num} pdu\=${gw_pdu_r} qosflows_to_add\=2 by\=amf     #5qi5
       Wait '1s' for stable
       run keyword if    1<=${num}<=10    airphone_execute_egate_command
       ...    ue_pdu_session_modify ue\=${num} pdu\=${gw_pdu_r} qosflows_to_add\=3 by\=amf     #5qi5
       Wait '0.5s' for stable
       run keyword if    1<=${num}<=10    Stop collect UE f1ap    UE${num}_attach_f1ap
       run keyword if    1<=${num}<=10    Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
       airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=100
##      debug
#       ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
#       ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#       log to console    UE_${num} TP_result are ${dl_throughput_pcell} ${ul_throughput_pcell}
    END

Change UEs cell location
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=1-4       #no 100 small bwp
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=5-8       #no 90_100 small bwp
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=9-15      #30 big data
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=16-30     #30 big data
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=31-45     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=46-60     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=61-75     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=76-90     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=91-105     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=106-120     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=4 id\=121-125     #30 mid data
    airphone_execute_egate_command	  ue_change_location cell\=5 id\=126-130     #30 mid data

SA send data '${UE_NUM_SA}' UEs
    log to console    push data for UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       run keyword if    1<=${num}<=30     SA send mutiple trf dl data    ${num}    1   100M   ${gw_pdu_r}    tcp
       run keyword if    1<=${num}<=30     SA send mutiple trf ul data    ${num}    1    5M   ${gw_pdu_r}
       run keyword if    31<=${num}<=60     SA send mutiple trf dl data    ${num}    1   20M   ${gw_pdu_r}    tcp
       run keyword if    31<=${num}<=60     SA send mutiple trf ul data    ${num}    1    5M   ${gw_pdu_r}
       run keyword if    61<=${num}<=90     SA send mutiple trf dl data    ${num}    1   8M   ${gw_pdu_r}    tcp
       run keyword if    61<=${num}<=90     SA send mutiple trf ul data    ${num}    1    1M   ${gw_pdu_r}
       run keyword if    91<=${num}<=120     SA send mutiple trf dl data    ${num}    1   2M   ${gw_pdu_r}    tcp
       run keyword if    91<=${num}<=120     SA send mutiple trf ul data    ${num}    1    100k   ${gw_pdu_r}
       run keyword if    121<=${num}<=1000     SA send mutiple trf dl data    ${num}    1   10M   ${gw_pdu_r}    tcp
       run keyword if    121<=${num}<=1000     SA send mutiple trf ul data    ${num}    1    100k   ${gw_pdu_r}
       Log To Console   perform data for UE${num} success
    END

SA send mutiple trf dl data
    [Arguments]    ${ue_id}    ${number}    ${dl_data}    ${pdu_id}=1    ${protocol}=udp
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone SA Start Data Traffic    ${ue_id}    DL    ${dl_data}    pdu_id=${pdu_id}    duration=60000s    trf_id=${num}
        ...    protocol=${protocol}
    END

stop data for all '${UE_NUM_SA}'ues    #for power saving
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       ${gw_pdu_r}    evaluate    ${num}%10+1
       run keyword and continue on failure    Airphone Sa Stop Data Traffic    ${num}    dl    pdu_id=${gw_pdu_r}
       run keyword and continue on failure    Airphone Sa Stop Data Traffic    ${num}    ul    pdu_id=${gw_pdu_r}
       airphone_execute_egate_command    trf_data_start ue\=${num} pdu\=${gw_pdu_r} dir\=dl trf_id\=5 kbps\=50 seconds\=6000s protocol\=udp
    END

step3:check mu KPI manual
    Log To Console   \n---------step3:check mu KPI manual----------
    Start capture only gnb syslog in 'syslog_step3' file
#    online change parameters    delta_9235_case10    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}
#    Wait '10s' for stable
#    run keyword and continue on failure    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case11_tti
#    Wait '60s' for stable
#    run keyword and continue on failure	   Get UEs TP for debug
    ${PM_counter_file}    Get counter file
    FOR    ${num}    IN RANGE    1    5
        Log To Console   cell_${num} counter
        ${8701_pair_counter_for_table}    Ideal line PRB_mulayer counter check    ${PM_counter_file}    ${num}
        ${9235_kpi_list}    KPI counter check    ${PM_counter_file}    ${num}
#        Record result for 9235 perfomance    ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}
#        ...    ${8701_pair_counter_for_table}    ${9235_kpi_list}
    END
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'syslog_step3' file '${custom_error}'
#    capture snapshot start once    step3_9235${actMuAwareTdSch}_corr${dlMuAwareCorrThd}

step5:kpi and counter check
    Log To Console   \n--------step5:kpi and counter check-------
    ${sum_prb_layer_X_layer1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    1
    ${sum_prb_layer_X_layer2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    2
    ${sum_prb_layer_X_layer3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    3
    ${sum_prb_layer_X_layer4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    4
    ${sum_prb_layer_X_layer5}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    5
    ${sum_prb_layer_X_layer6}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     16    6
    ${KPI_NR_5242b_cell_tp_avg1}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    1
    ${KPI_NR_5242b_cell_tp_avg2}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    2
    ${KPI_NR_5242b_cell_tp_avg3}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    3
    ${KPI_NR_5242b_cell_tp_avg4}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    4
    ${KPI_NR_5242b_cell_tp_avg5}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    5
    ${KPI_NR_5242b_cell_tp_avg6}     read_excel_cell    ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     23    6
    FOR    ${num_gain}    IN RANGE    2    6
        ${result}    evaluate    ${sum_prb_layer_X_layer${num_gain}}-${sum_prb_layer_X_layer6}
        Run Keyword if    ${result}>0    Exit For Loop
    END
#    should be true    ${result}>0
    FOR    ${num_gain}    IN RANGE    2    6
        ${result2}    evaluate    ${KPI_NR_5242b_cell_tp_avg${num_gain}}-${KPI_NR_5242b_cell_tp_avg6}
        Run Keyword if    ${result2}>0    Exit For Loop
    END
#    should be true    ${result2}>0

Record result for 9235 perfomance
    [Arguments]     ${table_tag}    ${actMuAwareTdSch}     ${dlMuAwareCorrThd}    ${8701_pair_counter_for_table}    ${9235_kpi_list}
    Log To Console   ${table_tag} ${actMuAwareTdSch} ${dlMuAwareCorrThd} ${8701_pair_counter_for_table} ${9235_kpi_list}
    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    ${table_tag}    9235_${actMuAwareTdSch}_mucor_${dlMuAwareCorrThd}
    FOR    ${num}    IN RANGE    0    18
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    ${table_tag}
        ...    ${8701_pair_counter_for_table[${num}]}
    END
    FOR    ${num}    IN RANGE    0    8
        ${num_table}    evaluate    ${num}+19
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}     ${table_tag}
        ...    ${9235_kpi_list[${num}]}
    END


Build excel table
    ${colomn_9235}   create list
    FOR    ${num}    IN RANGE    2    17
        append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer${num}
    END
    append to list    ${colomn_9235}    sum_prb_layer_X_layer
    append to list    ${colomn_9235}    PRB_DL_SU_MIMO_layer_total
    append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer_total
    append to list    ${colomn_9235}    KPI_NR_5055_bresidual_bler    KPI_NR_5054a_iniBler    KPI_NR_5108dSE_downlink    KPI_NR_5109dSE_uplink
    append to list    ${colomn_9235}    KPI_NR_5242b_cell_tp_avg    KPI_NR_5258a_cell_tp_max    KPI_NR_5100b_ue_tp_avg    KPI_NR_5192c_UE_num_perTTi
    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    0    ${SOFTWARE_INFO}_TMO065_CASE01
    FOR    ${num}    IN RANGE    0    26
        ${num_table}    evaluate    ${num}+1
        modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    0    ${colomn_9235[${num}]}
    END

add UEs bler
    Log To Console   add bler
   airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=97,30,30
   FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
   END

remove UEs bler2
   FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=deactivate
   END
   airphone_execute_egate_command    bler_testmode_nr profile_id\=2 delete\=yes

remove UEs bler
   Log To Console   remove bler
   airphone_execute_egate_command    bler_testmode_nr profile_id\=2 dl_bler\=0,0,0,0
   FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_execute_egate_command    ue_testmode_set_nr id\=${num} scell\=0 testmode\=bler profile_id\=2 action\=activate
    END

Get UEs TP for debug
    ${UEs_TP_DL_r1}   create list
    ${UEs_TP_UL_r1}   create list
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL_MU}/${UE_NUM}
        ${TP_DL_perUE_target_nopairing}   evaluate  ${TP_PEAK_DL}/${UE_NUM}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        append to list    ${UEs_TP_DL_r1}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL_r1}    ${ul_throughput_pcell}
    END
    log to console    UE1 to UE${UE_NUM} DL_TP_result are ${UEs_TP_DL_r1}
    log to console    UE1 to UE${UE_NUM} UL_TP_result are ${UEs_TP_UL_r1}


capture snapshot start once
    [Arguments]    ${log_tag}
    Log To Console    --capture snapshot start
    Run Keyword And Ignore Error    Collect GNB SnapShot    target_file_name=${TEST_LOG_DIRECTORY()}/All/${log_tag}_gnb_comon_snapshot.zip

Check SA UE throughput
    [Arguments]     ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}
    Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}

Verify multi SA UEs throughput
    [Arguments]     ${UE1_layer}    ${UE2_layer}     ${tag}    ${peaktp}
    log to console    ${UE1_layer} ${UE2_layer} ${tag} ${peaktp}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${TP_DL_perUE_target_pairing}   evaluate  ${TP_PEAK_DL}*${UE${num}_layer}/4
        ${TP_DL_perUE_target_nopairing}   evaluate  ${TP_PEAK_DL}/${UE_NUM}*${UE${num}_layer}/4
        ${TP_UL_perUE_target}   evaluate  ${TP_PEAK_UL}/${UE_NUM}
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword if    '${tag}'=='pair'    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target_pairing}
        run keyword if    '${tag}'=='nopair'    should_be_true    ${dl_throughput_pcell}>${TP_DL_perUE_target_nopairing}
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>${TP_UL_perUE_target}
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target_pairing is ${TP_DL_perUE_target_pairing}
    log to console    cell_DL_TP_target is ${TP_PEAK_DL},UE_DL_TP_target_nopairing is ${TP_DL_perUE_target_nopairing}
    log to console    cell_UL_TP_target is ${TP_PEAK_UL},UE_DL_TP_target is ${TP_UL_perUE_target}
    log to console    UE1 to UE${UE_NUM} DL_TP_result are ${UEs_TP_DL}
    log to console    UE1 to UE${UE_NUM} UL_TP_result are ${UEs_TP_UL}

Create SRS_pos profile
    FOR    ${num}    IN RANGE    1    9    #9pos
        airphone_execute_egate_command    ${PROFILE${num}}
    END

set '${UE_NUM}' SA UEs Pos   #per position 2ues
    log to console    ste ${UE_NUM}ues in 8 pos
    FOR    ${num}    IN RANGE    9    ${UE_NUM}+1     #bellow 8 UEs are smallbwp UEs
        ${num_r}    Evaluate    (${num} - 1) % 8 + 1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
        Wait '0.5s' for stable
    END


SA '${UE_NUM}' UE Data buffer send
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       SA send mutiple trf dl data    ${num}    2   175M    1   #peak 375mbps
       SA send mutiple trf ul data    ${num}    1   10M    1
    END

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


Analyse odftbeam in rrclog
    [Arguments]     ${tag}    ${ini_file}
	check_log_with_au2anlysis    ${CURDIR}/ini/${ini_file}.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tag}_egate

Set ports power and creat file
    [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
    ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
    ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
    airphone_execute_egate_command    ${cmd}

Collect bip and Check
    Start collect bip log
    Wait for '0.3s' to stop bip log with name'step2_bip'

Set UE '${UE_ID}' position1
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}
	Start collect ttitrace    name=${tti_tag}
    Wait for '0.5s' to stop ttitrace with name'${tti_tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode   name=${tti_tag}
    log to console  ${\n}---decode tti start---
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti
#    run keyword if    '${tti_tag}'=='tti_step3_muacorr_10'    Decoder Tttirace From Pcap To Csv
#    ...    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

Get '${UE_NUM_SA}' UEs rnti
   FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
	   ${ue_rnti}    file match all   ${TEST_LOG_DIRECTORY()}/All/attach_UE${num}_egate/egate_console.log.001   crnti: (\\d+)
	   set suite variable     ${ue${num}_rnti}    ${ue_rnti[0]}
	   Log To Console   UE_ID${num} Crnti is ${ue${num}_rnti}
    END

Airphone SA Detach UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Detach    ue_id=${num}
    END
    Collect AP egate log      all


Online change parameters
    [Arguments]    ${delta_9235_case10}    ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}
    ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}.json
    log to console    ${template}
    log to console    ${delta_9235_case10} ${actMuAwareTdSch} ${dlMuAwareCorrThd} ${dlMuAwarePrbRatio}
    ${message} =    Replace Variables    ${template}
    Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json    ${message}
    Online recommissioning with delta json file
    ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/${delta_9235_case10}_modified.json
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair

Get counter file
#    Wait '60s' for stable
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    [Return]    ${PM_counter_file}

