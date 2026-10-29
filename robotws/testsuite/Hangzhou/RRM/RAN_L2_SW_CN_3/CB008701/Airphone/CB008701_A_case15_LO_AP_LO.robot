*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_l3gao    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Documentation     maxDlHarqTx=8
...               0x340000=15      # as PM counter period update to 15/15=1min

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8701_case15_LO_AP_LO.xml   #corr 90
${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO_104040.xml
${WTS_NAME}       wts_aehc_8701_aplo_nsa.cfg
@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM}         8
${EGATE_TAG}      MUmimo
${BIP_TAG}    mumumo_bip
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
@{Rdparameter}     0x9D0000:3     0x580981:1   0x58077e:1     0x580539:9    #enable CNI111720
${TP_sum}    0
${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${TP_PEAK_DL}    750000  #750mbps
${TP_PEAK_UL}    80000   #80mbps

${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60

#${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
#${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
#${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
#${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
#${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
#${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
#${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
#${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS


${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-250,-250
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=-26 srs_transmit_power_per_port\=-320,-320,-250,-250

*** Test Cases ***
CB008701_A_B4_case15_PMcounter_dlMuMaxNumLayerPerMuRbg_variblity_test
    step1:get ready for gnb
    step2:attach UEs with Pos and get rnti
    step3:send full buffer for UEs and check logs
    step4:online change dlMuMaxNumLayerPerMuRbg '16' to check couter and TP
    step4:online change dlMuMaxNumLayerPerMuRbg '14' to check couter and TP
    step4:online change dlMuMaxNumLayerPerMuRbg '12' to check couter and TP
    #step4:online change dlMuMaxNumLayerPerMuRbg '10' to check couter and TP
    step5:override UE1 rank
    step6:online change dlMuMaxNumLayerPerMuRbg '15' to check couter and TP
    step6:online change dlMuMaxNumLayerPerMuRbg '13' to check couter and TP
    step6:online change dlMuMaxNumLayerPerMuRbg '11' to check couter and TP
    step6:online change dlMuMaxNumLayerPerMuRbg '9' to check couter and TP
#    step7:override UE1 rank4
#    step7:online change dlMuMaxNumLayerPerMuRbg '0' to check couter and TP
#    step8:online change actDlMuMimoEnh false to check couter and TP

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb---------------
	Modify 8701 Swconfig
	Get and Update BSR File    ${par_of_bsr_name}
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt     #WRN/L2-PS    WRN/.uplane
	Set Test Variable    ${custom_error}
	Prepare gnb onair
#	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log

step2:attach UEs with Pos and get rnti
    Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
    Create SRS_pos profile
	Attach '${UE_NUM}' SA UEs with f1ap
	set '${UE_NUM}' SA UEs Pos

step3:send full buffer for UEs and check logs
    Log To Console   \n-------------step3:send full buffer for UEs and check logs---------------
    Start capture only gnb syslog in 'step3_senddata' file
    SA '${UE_NUM}' UE Data buffer send
    Wait '5s' for stable
#    Collect bip and Check
#    Wait '5s' for stable
    run keyword and continue on failure    Collect ttitrace and Check    tti_tag=benchmark_tti_step3    ini_file=8701_benchmark_1
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3_senddata' file '${custom_error}'

step4:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP
    Log To Console   \n-------------step4:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP---------------
    Start capture gnb and ap syslog in 'layer${layer}' file
    Online change parameters    dlMuMaxNumLayerPerMuRbg=${layer}    actDlMuMimoEnh=true
    run keyword and continue on failure    Check counters with Mulayer '${layer}' layer
    ${TP_r}    evaluate    16-${layer}
    ${TP}    evaluate    2350000-${TP_r}*75000   #2350000.
    Wait '5s' for stable
    run keyword and continue on failure    Check 8 SA UE throughput     ${TP}    rank1_yes=No  #2751700
    run keyword and continue on failure    tti check    8701_case15_pair_check    UE_Mulayer_${layer}
    Stop capture gnb and ap syslog in 'layer${layer}' file



step5:override UE1 rank
    Overide UE1 Rank1
    Airphone '8' SA Stop Data Traffic
    SA '${UE_NUM}' UE Data buffer send with UE1 rank1

step7:override UE1 rank4
    Overide UE1 Rank4
    Airphone '8' SA Stop Data Traffic
    SA '${UE_NUM}' UE Data buffer send

step6:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP
    Log To Console   \n-------------step6:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP---------------
    Start capture gnb and ap syslog in 'layer${layer}' file
    Online change parameters    dlMuMaxNumLayerPerMuRbg=${layer}    actDlMuMimoEnh=true
    run keyword and continue on failure    Check counters with Mulayer '${layer}' layer
    ${TP_r}    evaluate    16-${layer}
    ${TP}    evaluate    2350000-${TP_r}*75000   #2350000.
    Wait '5s' for stable
    run keyword and continue on failure    Check 8 SA UE throughput     ${TP}    rank1_yes=Yes  #2751700
    tti check    8701_case15_pair_check    UE_Mulayer_${layer}
    Stop capture gnb and ap syslog in 'layer${layer}' file

step7:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP
    Log To Console   \n-------------step7:online change dlMuMaxNumLayerPerMuRbg '${layer}' to check couter and TP---------------
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=3  #UE1 back to rank4 report
    Start capture gnb and ap syslog in 'layer${layer}' file
    Online change parameters    dlMuMaxNumLayerPerMuRbg=${layer}    actDlMuMimoEnh=true
    run keyword and continue on failure    Check counters with Mulayer '${layer}' layer
    Wait '5s' for stable
    run keyword and continue on failure    Verify 8 SA UEs throughput no pair     700000  #2751700
    tti check    8701_case15_nopair_check    UE_Mulayer_${layer}
    Stop capture gnb and ap syslog in 'layer${layer}' file

step8:online change actDlMuMimoEnh false to check couter and TP
    Log To Console   \n-------------step8:online change actDlMuMimoEnh 'false' to check couter and TPP---------------
    Start capture gnb and ap syslog in 'actDlMuMimoEnh_false' file
    Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
    Online change parameters    dlMuMaxNumLayerPerMuRbg=16    actDlMuMimoEnh=false
    run keyword and continue on failure    Check counters with Mulayer '255' layer
    Wait '5s' for stable
    Attach '${UE_NUM}' SA UE
    SA '${UE_NUM}' UE Data buffer send
    run keyword and continue on failure    Verify 8 SA UEs throughput no pair     700000
    tti check    8701_case15_nopair_check    actDlMuMimoEnh_false
    Stop capture gnb and ap syslog in 'actDlMuMimoEnh_false' file

Collect bip and Check
    Start collect bip log
    Wait for '0.5s' to stop bip log with name'step3_bip'

Online change parameters
    [Arguments]    ${dlMuMaxNumLayerPerMuRbg}    ${actDlMuMimoEnh}
    ${template}    OperatingSystem.Get File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8701_case15.json
    log to console    ${template}    ${dlMuMaxNumLayerPerMuRbg}    ${actDlMuMimoEnh}
    ${message} =    Replace Variables    ${template}
    Create File    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8701_case15_modified.json    ${message}
    Online recommissioning with delta json file
    ...   ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8701_case15_modified.json
    Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair

tti check
    [Arguments]    ${ini_file}    ${tti_file}
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'${tti_file}'
    run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value    ${TEST_LOG_DIRECTORY()}/All/${tti_file}/tti_dl.csv
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti


Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}
	Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'${tti_tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
    check_cdm_group_and_dmrs_port_by_antenna_port_value     ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv

Create SRS_pos profile
    FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
        airphone_execute_egate_command    ${PROFILE${num}}
    END

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

set '${UE_NUM}' SA UEs Pos
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${num_r}    evaluate    ${num}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
    END

SA '${UE_NUM}' UE Data buffer send
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       SA send mutiple trf dl data    ${num}    2   175M    1   #peak 375mbps
       SA send mutiple trf ul data    ${num}    1   10M    1
    END

SA '${UE_NUM}' UE Data buffer send with UE1 rank1
    SA send mutiple trf dl data    1    2   100M    1
    SA send mutiple trf ul data    1    1   15M    1
    FOR    ${num}    IN RANGE    2    ${UE_NUM}+1
       SA send mutiple trf dl data    ${num}    2   175M    1
       SA send mutiple trf ul data    ${num}    1   15M    1
    END

check TP and bler with ttitrace
    [Arguments]    ${throughput}    ${time_avg}    ${tti_file}
    ${a}  get_ues_tbsize_by_sfn   ${test_log_directory()}/All/${tti_file}/tti_dl.csv
    ...        ${test_log_directory()}/All/${tti_file}/tti_dl_new.csv   ${time_avg}   filter=dlFdSchedData.ackNack\=ACK
    @{keys}  Get Dictionary Keys   ${a}
    FOR      ${key}     IN     @{keys}
        ${result}   evaluate  ${a[${key}]}/${time_avg}/1024/1000
        log to console   result is ${result}
        log to console   TP is ${throughput}
        should be true  ${result}>${throughput}
    END

Modify 8701 Swconfig
	Add GNB swconfig    @{Rdparameter}


Check SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}
    Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${ue_start}    ${ue_end}

Verify multi SA UEs throughput
    [Arguments]     ${ue_start}    ${ue_end}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>305000
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>9000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    UE${ue_start} to UE${ue_end} DL_TP_result are ${UEs_TP_DL}
    log to console    UE${ue_start} to UE${ue_end} UL_TP_result are ${UEs_TP_UL}

Check 8 SA UE throughput
    [Arguments]     ${throughput}    ${rank1_yes}
    run keyword if   '${rank1_yes}'=='Yes'     Wait until keyword succeeds    48s    8s    Verify 8 SA UEs throughput with UE1 rank1    ${throughput}
    run keyword if   '${rank1_yes}'=='No'     Wait until keyword succeeds    48s    8s    Verify 8 SA UEs throughput     ${throughput}

Verify 8 SA UEs throughput
    [Arguments]    ${target_cell_throughput}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    ${TP_target}    evaluate   ${target_cell_throughput}/8
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#        wait '200ms' for stable
        run keyword if   ${dl_throughput_pcell}<300000    should_be_true    ${dl_throughput_pcell}>150000
#        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${TP_target}
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>9000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    target DL_TP_result per ue are ${TP_target}
    log to console    UE1 to UE8 DL_TP_result are ${UEs_TP_DL}
    log to console    UE1 to UE8 UL_TP_result are ${UEs_TP_UL}

Verify 8 SA UEs throughput no pair
    [Arguments]    ${target_cell_throughput}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    ${TP_target}    evaluate   ${target_cell_throughput}/8
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword if   ${dl_throughput_pcell}<300000    should_be_true    ${dl_throughput_pcell}>${TP_target}
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>9000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    target DL_TP_result per ue are ${TP_target}
    log to console    UE1 to UE8 DL_TP_result are ${UEs_TP_DL}
    log to console    UE1 to UE8 UL_TP_result are ${UEs_TP_UL}

Verify 8 SA UEs throughput with UE1 rank1
    [Arguments]    ${target_cell_throughput}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    ${TP_target}    evaluate   ${target_cell_throughput}/8
    FOR    ${num}    IN RANGE    2    ${UE_NUM}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
#        Run Keyword If    ${num}==1    should_be_true    ${dl_throughput_pcell}>(${target_cell_throughput}/8/3)
#        Run Keyword If    ${num}>1    should_be_true    ${dl_throughput_pcell}>(${target_cell_throughput}/8)
#        ${TP_sum}    evaluate   ${TP_sum}+${dl_throughput_pcell}
#        Run Keyword If    ${num}==${UE_NUM}   should be true   ${TP_sum}> ${target_cell_throughput}
        run keyword if   ${dl_throughput_pcell}<300000    should_be_true    ${dl_throughput_pcell}>150000
#        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>${TP_target}
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>9000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
    END
    log to console    target DL_TP_result per ue are ${TP_target}
    log to console    UE1 to UE8 DL_TP_result are ${UEs_TP_DL}
    log to console    UE1 to UE8 UL_TP_result are ${UEs_TP_UL}

Attach '${UE_NUM}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${num} ------
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=${num}    type=internal
       Airphone Pdu Session Setup   ue_id=${num}    pdu_id=${num}   nwslice_id=1    gw_id=${num}
       Wait '1s' for stable
    END
#       run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID_SA   ${EGATE_TAG}_${num}

Airphone NSA Stop Data Traffic And Detach UE
    FOR    ${num}    IN RANGE    12    ${UE_NUM}+12
        Airphone NSA Stop Data Traffic   ${num}    BI
        Airphone NSA Detach    ${num}
    END

Airphone '${UE_NUM}' SA Stop Data Traffic
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Stop Data Traffic     ${num}     BI    1
    END

Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       Airphone SA Stop Data Traffic     ${num}     BI    1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '1s' for stabible
    END


check_SRS_resource_and_PDSCH_scramblingID
    [Arguments]    ${EGATE_TAG}
    check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

check_SRS_resource_and_PDSCH_scramblingID_SA
    [Arguments]    ${EGATE_TAG}
    check_log_with_au2anlysis    ${CURDIR}/ini/check_SRS_resource_and_PDSCH_scramblingID_8701_case02.ini    p
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate

Check mupair in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/8701_case02_mupair.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Overide UE bler
   airphone_execute_egate_command    bler_testmode_nr profile_id\=1 dl_bler\=100,2,3,4,5,6
   airphone_execute_egate_command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
   airphone_execute_egate_command    ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate

Overide UE1 Rank1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 ri\=0
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2

Overide UE1 Rank4
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=3
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3

Overide UE1 Rank2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3
    SA send mutiple trf dl data    1    1   150M    1

Check counters with Mulayer '${layer_num}' layer
    run keyword if    ${layer_num}==16     check 8701 counter with MUlayer 16
    run keyword if    ${layer_num}==15     check 8701 counter with MUlayer 15
    run keyword if    ${layer_num}==14     check 8701 counter with MUlayer 14
    run keyword if    ${layer_num}==13     check 8701 counter with MUlayer 13
    run keyword if    ${layer_num}==12     check 8701 counter with MUlayer 12
    run keyword if    ${layer_num}==11     check 8701 counter with MUlayer 11
    run keyword if    ${layer_num}==10     check 8701 counter with MUlayer 10
    run keyword if    ${layer_num}==9      check 8701 counter with MUlayer 9
    run keyword if    ${layer_num}==8    check 8701 counter with MUlayer 8
    run keyword if    ${layer_num}==0      check 8701 counter with MUlayer 0
    run keyword if    ${layer_num}==255      check 8701 counter with MUlayer 255   #255 means MUMIMO false


wait last PM counter remaintiome
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}

Get 8701 counter
    log to console    ${\n}---capture counter start---
    Wait '40s' for stable
    ${PRB_DL_SU_MIMO_LAYER_list}   create list
    ${PRB_DL_MU_MIMO_LAYER_list}   create list
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    counter remianing time is ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    FOR    ${num}    IN RANGE    1    5
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C3400${num}    cell_id=1
        set suite variable     ${PRB_DL_SU_MIMO_${num}LAYER}     ${result}
        append to list    ${PRB_DL_SU_MIMO_LAYER_list}    ${PRB_DL_SU_MIMO_${num}LAYER}
        log to console    ${PRB_DL_SU_MIMO_LAYER_list}
    END

    FOR    ${num}    IN RANGE    5    10
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C3400${num}    cell_id=1
        ${num_layer}   evaluate   ${num}-3
        set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
        append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
        log to console    ${PRB_DL_MU_MIMO_LAYER_list}
    END

    FOR    ${num}    IN RANGE    10    12
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C340${num}    cell_id=1
        ${num_layer}   evaluate   ${num}-3
        set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
        append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
        log to console    ${PRB_DL_MU_MIMO_LAYER_list}
    END

    FOR    ${num}    IN RANGE    16    24
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C340${num}    cell_id=1
        ${num_layer}   evaluate   ${num}-7
        set suite variable     ${PRB_DL_MU_MIMO_${num_layer}LAYER}     ${result}
        log to console    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
        append to list    ${PRB_DL_MU_MIMO_LAYER_list}    ${PRB_DL_MU_MIMO_${num_layer}LAYER}
        log to console    ${PRB_DL_MU_MIMO_LAYER_list}
    END

    log to console    SUlayer 1_2_3_4 ${PRB_DL_SU_MIMO_LAYER_list}
    log to console    MUlayer 2_3_4_5_6_7_8_9_10_11_12_13_14_15_16 ${PRB_DL_MU_MIMO_LAYER_list}

    ${PRB_DL_MU_MIMO_PAIR_UE_list}   create list
    FOR    ${num}    IN RANGE    12    16
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C340${num}    cell_id=1
        ${num_ue}   evaluate   ${num}-11
        set suite variable     ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}     ${result}
        log to console    ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}
        append to list    ${PRB_DL_MU_MIMO_PAIR_UE_list}    ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}
        log to console    mu pair ue 0_2_3_4_5_6_7_8 is ${PRB_DL_MU_MIMO_PAIR_UE_list}
    END

    FOR    ${num}    IN RANGE    24    28
	    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
        ...    counter_id=M55308C340${num}    cell_id=1
        ${num_ue}   evaluate   ${num}-19
        set suite variable     ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}     ${result}
        log to console    ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}
        append to list    ${PRB_DL_MU_MIMO_PAIR_UE_list}    ${PRB_DL_MU_MIMO_${num_ue}PAIR_UE}
        log to console    mu pair ue 0_2_3_4_5_6_7_8 is ${PRB_DL_MU_MIMO_PAIR_UE_list}
    END

    ${MAC_DTCH_CELL_THP_DL_MAX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55309C12001    cell_id=1
    ${Cell1_TP_total}    evaluate    ${MAC_DTCH_CELL_THP_DL_MAX}*8/1024/1024
    log to console    Cell1_TP_total is ${Cell1_TP_total}

	${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34028  cell_id=1
	${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34029  cell_id=1
    log to console   M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH is ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}
    log to console   M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH is ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}
#    should be true    ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0
#    should be true    ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0

   	${M55308C10001_PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001   cell_id=1

    ${MU_MIMO_layer_total}    evaluate    sum(${PRB_DL_MU_MIMO_LAYER_list})
    ${SU_MIMO_layer_total}    evaluate    sum(${PRB_DL_SU_MIMO_LAYER_list})
    ${SU_MIMO_layer_plus_SU_layer}    evaluate     ${SU_MIMO_layer_total}+${MU_MIMO_layer_total}
    ${mu_prb_and_legacy_pdsch_prb}    evaluate     ${SU_MIMO_layer_plus_SU_layer}-${M55308C10001_PRB_USED_PDSCH}
    run keyword and continue on failure   should be true  ${mu_prb_and_legacy_pdsch_prb}<(${SU_MIMO_layer_plus_SU_layer}/10)

    set global variable    ${PRB_DL_MU_MIMO_LAYER_list}

Get 8701 counters
    Wait '40s' for stable
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    log to console    ${remaining_time}
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
	${M55308C34023_PRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34023    cell_id=1
	${M55308C34022_PRB_DL_MU_MIMO_15LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34022    cell_id=1
	${M55308C34021_PRB_DL_MU_MIMO_14LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34021    cell_id=1
	${M55308C34020_PRB_DL_MU_MIMO_13LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34020    cell_id=1
	${M55308C34019_PRB_DL_MU_MIMO_12LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34019    cell_id=1
	${M55308C34018_PRB_DL_MU_MIMO_11LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34018    cell_id=1
	${M55308C34017_PRB_DL_MU_MIMO_10LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34017    cell_id=1
	${M55308C34016_PRB_DL_MU_MIMO_9LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34016    cell_id=1
    #CB008305
	${M55308C34011_PRB_DL_MU_MIMO_8LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34011    cell_id=1
	${M55308C34010_PRB_DL_MU_MIMO_7LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34010    cell_id=1
	${M55308C34009_PRB_DL_MU_MIMO_6LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34009    cell_id=1
	${M55308C34008_PRB_DL_MU_MIMO_5LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34008    cell_id=1
 	${M55308C34007_PRB_DL_MU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34007    cell_id=1
  	${M55308C34006_PRB_DL_MU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34006    cell_id=1
  	${M55308C34005_PRB_DL_MU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34005    cell_id=1
  	${M55308C34004_PRB_DL_SU_MIMO_4LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34004   cell_id=1
  	${M55308C34003_PRB_DL_SU_MIMO_3LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34003   cell_id=1
    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34002   cell_id=1
    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34001   cell_id=1

	${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34027   cell_id=1
	${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34026   cell_id=1
	${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34025   cell_id=1
	${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34024   cell_id=1
    #CB008305
	${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34015   cell_id=1
	${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34014   cell_id=1
	${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34013   cell_id=1
	${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34012  cell_id=1
	${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34028  cell_id=1
	${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}=   get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C34029  cell_id=1

   	${M55308C10001_PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
    ...    counter_id=M55308C10001   cell_id=1

    ${MU_MIMO_layer_list}    create list    ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}    ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
    ...     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
    ...     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
    ...     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
    ...     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}     ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
    ...     ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}     ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
    ...     ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}     ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
    ...     ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
    ${MU_MIMO_layer_total}    evaluate    sum(${MU_MIMO_layer_list})

    ${SU_MIMO_layer_list}    create list     ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
    ...     ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
    ${SU_MIMO_layer_total}    evaluate    sum(${SU_MIMO_layer_list})

    ${MU_paired_UE_list}     create list        ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
    ...    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}     ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
    ...    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}     ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
    ...    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
    ${MU_paired_UE_total}    evaluate    sum(${MU_paired_UE_list})

    run keyword and continue on failure   should be true   ${MU_MIMO_layer_total}==${MU_paired_UE_total}
    run keyword and continue on failure   should be true   ${SU_MIMO_layer_total}>=${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
    ${SU_MIMO_layer_plus_SU_layer}    evaluate     ${SU_MIMO_layer_total}+${MU_MIMO_layer_total}
    ${mu_prb_and_legacy_pdsch_prb}    evaluate     ${SU_MIMO_layer_plus_SU_layer}-${M55308C10001_PRB_USED_PDSCH}
    run keyword and continue on failure   should be true  ${mu_prb_and_legacy_pdsch_prb}<(${SU_MIMO_layer_plus_SU_layer}/10)

    set global variable    ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}
    set global variable    ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}
    set global variable    ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}
    set global variable    ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}
    set global variable    ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}
    set global variable    ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}
    set global variable    ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}
    set global variable    ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}
    set global variable    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}
    set global variable    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}
    set global variable    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}
    set global variable    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}
    set global variable    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}
    set global variable    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}
    set global variable    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}
    set global variable    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}
    set global variable    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}
    set global variable    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}
    set global variable    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}
    set global variable    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}
    set global variable    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}
    set global variable    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}
    set global variable    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}
    set global variable    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}
    set global variable    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}
    set global variable    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}
    set global variable    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}
    set global variable    ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}
    set global variable    ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}


check 8701 counter with MUlayer 16
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0
#    Get 8701 counter
#    run keyword and continue on failure    should_be_true     ${PRB_DL_MU_MIMO_LAYER_list[14]}>0

Get counter file
    FOR    ${num}    IN RANGE    1    1200
        ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=3min
        log to console    \n${remaining_time}
        Wait '0.2s' for stable
        ${remaining_time_real}    evaluate    ${remaining_time}-230    #230 time update PM file
        log to console    \n${remaining_time_real}
        Run Keyword if    ${remaining_time_real}==0   Exit For Loop
    END
#    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=3min
#    log to console    \n${remaining_time}
#    Wait Throughput Timer    ${remaining_time}
     Wait '5s' for stable
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
    [Return]    ${PM_counter_file}


check 8701 counter with MUlayer 15
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 14
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 13
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 12
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}>0
    run keyword and continue on failure    should_be_true     ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true     ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true     ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 11
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}>0
    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}+${M55308C34018_PRB_DL_MU_MIMO_11LAYER}>3000000
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 10
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}>8000000
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 9
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}>0
    should_be_true     ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}+${M55308C34016_PRB_DL_MU_MIMO_9LAYER}>8000000
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 8
    Get 8701 counters

    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}>11000000
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}>0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0

check 8701 counter with MUlayer 0
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}==0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}>0


check 8701 counter with MUlayer 255
    Get 8701 counters
    run keyword and continue on failure    should_be_true     ${M55308C34023_PRB_DL_MU_MIMO_16LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34022_PRB_DL_MU_MIMO_15LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34021_PRB_DL_MU_MIMO_14LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34020_PRB_DL_MU_MIMO_13LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34019_PRB_DL_MU_MIMO_12LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34018_PRB_DL_MU_MIMO_11LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34017_PRB_DL_MU_MIMO_10LAYER}==0
    run keyword and continue on failure    should_be_true     ${M55308C34016_PRB_DL_MU_MIMO_9LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34011_PRB_DL_MU_MIMO_8LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34010_PRB_DL_MU_MIMO_7LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34009_PRB_DL_MU_MIMO_6LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34008_PRB_DL_MU_MIMO_5LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34007_PRB_DL_MU_MIMO_4LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34006_PRB_DL_MU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34005_PRB_DL_MU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34004_PRB_DL_SU_MIMO_4LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34003_PRB_DL_SU_MIMO_3LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34002_PRB_DL_SU_MIMO_2LAYER}==0
    run keyword and continue on failure    should_be_true    ${M55308C34001_PRB_DL_SU_MIMO_1LAYER}>0
    run keyword and continue on failure    should_be_true    ${M55308C34027_PRB_DL_MU_MIMO_8PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34026_PRB_DL_MU_MIMO_7PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34025_PRB_DL_MU_MIMO_6PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34024_PRB_DL_MU_MIMO_5PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34015_PRB_DL_MU_MIMO_4PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34014_PRB_DL_MU_MIMO_3PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34013_PRB_DL_MU_MIMO_2PAIR_UE}==0
    run keyword and continue on failure    should_be_true    ${M55308C34012_PRB_DL_MU_MIMO_NOPAIR_UE}>0
    run keyword and continue on failure    should_be_true     ${M55308C34028_TOT_MU_MIMO_PAIR_UE_PDSCH}==0
    run keyword and continue on failure    should_be_true     ${M55308C34029_TOT_MU_MIMO_ELIG_UE_PDSCH}==0

Attach '${UE_NUM}' SA UEs with f1ap
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       Start collect UE f1ap    UE${num}_attach_f1ap
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ue_id=${num}    pdu_id=1   type=internal
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=1   nwslice_id=1   gw_id=${num}
       Wait '1s' for stable
       Log To Console   attach UE${num} successfully
       Stop collect UE f1ap    UE${num}_attach_f1ap
       Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap    ${num}
       SA send mutiple trf ul data    ${num}    1   100k   1
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
