*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_9235_8D4U_AQQL_1116_0_case01.xml
${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case01.xml
${WTS_NAME}       wts_SA_NSA_case01.cfg

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${UE_NUM_SA}         14
${EGATE_TAG}      MUmimo
${BIP_TAG}    mumumo_bip
${TTI_TAG}      tti



${filter_cell_setup}    itf_l2_ps_cell_cellsetupreq
@{titles_muaware}    itf_DlMuMimoEnhConfig.actMuAwareTdSch    itf_DlMuMimoEnhConfig.dlMuAwareCorrThd    itf_DlMuMimoEnhConfig.dlMuAwarePrbRatio
...    itf_DlMuMimoEnhConfig.dlMuPairingPrbRatio

${filter_cell_reconfiguration_req}     itf_l2_ps_cell_cellreconfigurationreq
@{titles_remuaware}    itf_DlMuMimoEnhReConfig.actMuAwareTdSch    itf_DlMuMimoEnhReConfig.dlMuAwareCorrThd
...    itf_DlMuMimoEnhReConfig.dlMuAwarePrbRatio   itf_DlMuMimoEnhReConfig.dlMuPairingPrbRatio


${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=58 zenith\=22 srs_transmit_power_per_port=-320,-320,-280,-280

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-18 zenith\=22 srs_transmit_power_per_port=-320,-320,-280,-280

${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-58 zenith\=-2 srs_transmit_power_per_port=-320,-320,-280,-280

${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-2 srs_transmit_power_per_port=-320,-320,-280,-280



*** Test Cases ***
CB009235_A_B101_CASE01_feature_activation_deactivation
    step1:gnb ready for onair and check cellsetup log
    step2:attach UEs with Pos and check srs resource
    step3:send full buffer for UEs and check logs
    step4:online change actMuAwareTdSch true and check logs
    step5:online change actMuAwareTdSch false and check logs
    #step6:detach all UEs
    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
step1:gnb ready for onair and check cellsetup log
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	${wrn_info}    create list    WRN/L2-PS
	Prepare gnb onair    ${wrn_info}
	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log
#	run keyword and continue on failure    Convert cellsetup bip and check

step2:attach UEs with Pos and check srs resource
    Log To Console   \n-------------step2:attach UEs with Pos and check srs resource--------------
	Attach '${UE_NUM_SA}' SA UE
	Set UEs pos
	run keyword and continue on failure    Check Srs Resource
    Get all UEs rnti

step3:send full buffer for UEs and check logs
    Log To Console   \n-------------step3:send full buffer for UEs and check logs---------------
    SA send data '${UE_NUM_SA}' UEs
    Wait '10s' for stabible
    Check SA UE throughput
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_false'
    #check ttitrace
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_false_case01.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
    reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_false_dl.csv
    ${filter_rnti}    Create List    ${ue9_rnti}
    append to list    ${filter_rnti}    ${ue10_rnti}
    Log To Console   ${filter_rnti}
    set suite variable    ${filter_rnti}


step4:online change actMuAwareTdSch true and check logs
    Log To Console   \n-------------step4:online change actMuAwareTdSch true and check ---------------
    Online change actMuAwareTdSch 'true' and check bip logs
    Check SA UE throughput

    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tti_true'
    run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_true_case01.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
    run keyword and continue on failure    reorder_csv_CB009235    ${TEST_LOG_DIRECTORY()}/All/tti_true_dl.csv


step5:online change actMuAwareTdSch false and check logs
    Log To Console   \n-------------step5:online change actMuAwareTdSch false and check---------------
    Online change actMuAwareTdSch 'false' and check bip logs

step6:detach all UEs
    Log To Console   \n-------------step6:detach all UEs ---------------
    Detach '${UE_NUM_SA}' SA UE

Convert cellsetup bip and check
    Log To Console   Convert cellsetup bip and check
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellsetup.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/cellsetup.csv    ${filter_cell_setup}    ${titles_muaware}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/cellsetup_bip.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Attach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       airphone_cleanup_egate_console_log
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
       Collect AP egate log    ${EGATE_TAG}_${num}
       Wait '3s' for stabible
    END


SA UE '${UE_ID}' fix RANK2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=30 ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=30 scell\=0

Detach '${UE_NUM_SA}' SA UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_sa_detach    ue_id=${num}    timeout=30
    END


Create UE pos profile
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ${PROFILE${num}}
    END

Set UEs pos
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command    ${PROFILE4}

#    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
#        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}

    FOR    ${num}    IN RANGE    1    1+3
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    END

    FOR    ${num}    IN RANGE    4    4+3
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    END

    FOR    ${num}    IN RANGE    7    7+3
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
    END

    FOR    ${num}    IN RANGE    10    10+3
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
    END
#
    airphone_execute_egate_command    ue_testmode_set_nr id\=13 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2


SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    3   175M   ${num}    tcp
        SA send mutiple trf ul data    ${num}    1    10M   ${num}
    END

Check Srs Resource
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case01.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_1_egate
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_peridicSRS_case01.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_8_egate

    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_13_egate
    run keyword and continue on failure    check_log_with_au2anlysis  ini_path=${CURDIR}/ini/RRC_AperidicSRS_case01.ini    log_need_to_check=p
   ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/MUmimo_14_egate


Get all UEs rnti
    ${rnti_list}    create list
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        ${rnti}    Get SA UE crnti in RRC log'${EGATE_TAG}_${num}'
        Log To Console   UE${num} rnti=${rnti}
        set suite variable     ${ue${num}_rnti}    ${rnti}
        append to list    ${rnti_list}    ${rnti}
    END
    Log To Console    rnti_list=${rnti_list}



Get SA UE crnti in RRC log'${EGATE_TAG}'
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   crnti: (\\d+)
    [return]     ${rnti_list[0]}

Get NSA UE crnti in RRC log'${EGATE_TAG}'
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
    [return]     ${rnti_list}

Online change actMuAwareTdSch '${state}' and check bip logs
    Start collect 'actMuAwareTdSch_${state}' tcpdump
    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_9235_case01_actMuAwareTdSch_${state}.json
    Stop collect 'actMuAwareTdSch_${state}' tcpdump

    Run Keyword If    '${state}'=='true'    set suite variable     ${9235_state}    1
    ...    ELSE    set suite variable     ${9235_state}    0
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${state}.pcap
     ...    ${TEST_LOG_DIRECTORY()}/All/actMuAwareTdSch_${9235_state}.csv    ${filter_cell_reconfiguration_req}    ${titles_remuaware}
   # run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/actmuaware_state_bip.ini   log_need_to_check=i
   # ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    ${tput_sum}    Set variable    ${0}
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
        Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
        ${tput_sum}    evaluate    ${tput_sum}+${dl_throughput_pcell}
    END
#        should_be_true    ${dl_throughput_pcell}>210000
    Log To Console    tput_sum=${tput_sum}


Add RD
    Add GNB swconfig    0x58077e:1   #rdEnableMuAwareTdSchTtiTrace
    Add GNB swconfig    0x580539:10   #Num UE threshold,to collect trace



