*** Settings ***
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    SBTS00    RAN_5G_TDD    RAN_5G    owner_changyli    
...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8322_8D4U_1070_80M_8X4.xml
#${SCFC_NAME}      SCFC_8322_4D4U_AQQL_1208_100M_8x4.xml
${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_8x4.xml
${WTS_NAME}    wts_SA_NSA_case21.cfg

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog

#&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
#...    NUMBER_OF_FILES=30

${FILTER_DU_ID}    f1ap||e1ap||rrc
@{titles_du_id}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${FILTER_SRS_REQ}    uldata_srsreceivereq
@{titles_bfsubbandid}   3gpp.sfn    3gpp.slot    3gpp.rnti    UlData_srsBwvReportRequest_t.bfSubbandId_item
${CH_BW}              217
${SUB_BAND_SIZE}      8

${UE_NUM_SA}         4
${UE_NUM_NSA}        4
${UE_SA_ID}         1
${UE1_SA_ID}         1
${UE2_SA_ID}         2
${UE3_SA_ID}         3
${UE4_SA_ID}         4
${UE_NSA_ID}        11

${BIP_TAG}          bip
${BIP_TAG1}          bip1
${BIP_TAG2}          bip2
${BIP_TAG3}          bip3
${BIP_TAG4}          bip4
${EGATE_TAG}       egate
${EGATE_TAG1}       egate1
${TTI_TAG}           tti
${TTI_TAG2}           tti2
${TTI_TAG3}           tti3


*** Test Cases ***
CB008322_E6_case001_subband_BF_interaction_with_8port_CSI-RS_PMI_actCsirsMultiplexing_true
    Active GNB L2 feature debug traces
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file

    #step1
	Attach 4SA UEs with t2r4 and check logs
	#step2
    Send 4SA UEs full data and check logs
    #step3
    Send small data to UE1 and check logs
    #step4
    Change actUeCsirsCoexistCellCsirs true and reattach 4SA UEs with t2r4 and send full data
    #step5
    Send small data to UE1 with full data in actUeCsirsCoexistCellCsirs true

    Detach all SA UEs
    Collect AP egate log    ${EGATE_TAG}_all
    Stop capture gnb and ap syslog in 'after_onair' file


*** Keywords ***
Add RD
	Add GNB swconfig    0x580434:0     	#pdcch use best beam
    Add GNB swconfig    0x580556:0x834    #rdStartPatternId 0x834=2100
	Add GNB swconfig    0x5901EB:0        #rdForceEnablingWidebandTasSrs
	Add GNB swconfig    0x5901E6:0xA0    #rdMinSrsUePeriodicity  default=80   slot160
    Add GNB swconfig    0x5901E6:80    #rdMinSrsUePeriodicity  default=80   slot160
    Add GNB swconfig    0x580763:4  	#rdWbSrsRankTresh
#    Add GNB swconfig    0x5805ae:1      #rdEnableSrsSwitchScheduler
    Add GNB swconfig    0x58076C:10   #rdWbSrsPrbTresh  buffer good thresh
#    Add GNB swconfig    0x5805b4:20   #rdPeriodSrsCheck 5-100  60
#    Add GNB swconfig    0x5805b5:1  #rdNumSrsCheck
    Add GNB swconfig    0x580477:3  #UL Comma print
    Add GNB swconfig    0x580264:3   # DL Comma print
    Add GNB swconfig    0x580265:1   #rdNumberOfUeCsirsSymbol
    Add GNB swconfig    0x5805b0:60  #rdSrsBufPercent


Attach 4SA UEs with t2r4 and check logs
    Attach '${UE_NUM_SA}' SA UEs with '${EGATE_TAG}'
	${rnti_list}    Get SA UE crnti in RRC log'${EGATE_TAG}'
	Log To Console    rnti_list=${rnti_list}
	${ue1_rnti}    set variable    ${rnti_list[0]}
	Log To Console    ue1_rnti=${ue1_rnti}
	set suite variable     ${ue1_rnti}
	${ue2_rnti}    set variable    ${rnti_list[1]}
	set suite variable     ${ue2_rnti}
	${ue3_rnti}    set variable    ${rnti_list[2]}
	set suite variable     ${ue3_rnti}
	${ue4_rnti}    set variable    ${rnti_list[3]}
	set suite variable     ${ue4_rnti}

#	run keyword and continue on failure	   Check cell specific CSI RS not multiplexing in rrclog‘${EGATE_TAG}_egate’
	run keyword and continue on failure	   Check all cell specific CSI RS multiplexing in rrclog‘${EGATE_TAG}_egate’

Send 4SA UEs full data and check logs
    SA send data '${UE_NUM_SA}' UEs
	Wait '5s' for stabible
	run keyword and continue on failure	   Check SA UE throughput
    Start collect bip log
    Wait for '1s' to stop bip log with name'${BIP_TAG1}'
	Start collect ttitrace
    Wait for '4s' to stop ttitrace with name'${TTI_TAG}_rt'
    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_rt_dl.csv
    run keyword and continue on failure	   Check ttitrace'tti_rt_E6_case001.ini'
    run keyword and continue on failure	   Convert '${BIP_TAG1}' BIP and check

Send small data to UE1 and check logs
    Stop data transfer'${UE1_SA_ID}'
    SA send small data to ‘${UE1_SA_ID}’ UE
    wait '1s' for stable
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'${TTI_TAG}_low'
    #Start collect bip log
    #Wait for '1s' to stop bip log with name'${BIP_TAG2}'
    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_low_dl.csv
    run keyword and continue on failure	   Check ttitrace'tti_rt_dft_E6_case001.ini'

Change actUeCsirsCoexistCellCsirs true and reattach 4SA UEs with t2r4 and send full data
    Detach UE '${UE1_SA_ID}'
    Detach UE '${UE2_SA_ID}'
    Detach UE '${UE3_SA_ID}'
    Detach UE '${UE4_SA_ID}'
    Online change actUeCsirsCoexistCellCsirs 'true'
    Attach '${UE_NUM_SA}' SA UEs with '${EGATE_TAG1}'

	${rnti_list}    Get SA UE crnti in RRC log'${EGATE_TAG1}'
	Log To Console    rnti_list=${rnti_list}
	${ue1_rnti}    set variable    ${rnti_list[0]}
	Log To Console    ue1_rnti=${ue1_rnti}
	set suite variable     ${ue1_rnti}
	${ue2_rnti}    set variable    ${rnti_list[1]}
	set suite variable     ${ue2_rnti}
	${ue3_rnti}    set variable    ${rnti_list[2]}
	set suite variable     ${ue3_rnti}
	${ue4_rnti}    set variable    ${rnti_list[3]}
	set suite variable     ${ue4_rnti}

	run keyword and continue on failure	   Check cell specific CSI RS multiplexing in rrclog‘${EGATE_TAG1}_egate’
	run keyword and continue on failure	   Check ue specific CSI RS multiplexing in rrclog‘${EGATE_TAG1}_egate’

	SA send data '${UE_NUM_SA}' UEs
	Wait '5s' for stabible
	run keyword and continue on failure	   Check SA UE throughput
	Start collect bip log
    Wait for '1s' to stop bip log with name'bip_ue'
    Start collect ttitrace
    Wait for '4s' to stop ttitrace with name'${TTI_TAG}_ue'
    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_ue_dl.csv
    run keyword and continue on failure	   Check ttitrace'tti_rt_UE_E6_case001.ini'
    #run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_ue_dl.csv
    #...    ${ue1_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
    #run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_ue_dl.csv
    #...    ${ue2_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}
    run keyword and continue on failure	   Convert 'bip_ue' BIP and check

Send small data to UE1 with full data in actUeCsirsCoexistCellCsirs true
    Start collect ttitrace
    Stop data transfer'${UE1_SA_ID}'
    SA send small data to ‘${UE1_SA_ID}’ UE
    Stop data transfer'${UE3_SA_ID}'
    SA send small data to ‘${UE3_SA_ID}’ UE
    Wait for '1s' to stop ttitrace with name'${TTI_TAG}_mix_pmi'
   # Start collect bip log
   # Wait for '1s' to stop bip log with name'bip_mix'
    Start collect ttitrace
    Wait for '4s' to stop ttitrace with name'${TTI_TAG}_mix'
    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_mix_dl.csv
    run keyword and continue on failure	   Check ttitrace'tti_mix_pmi_E6_case001.ini'
    run keyword and continue on failure	   Check ttitrace'tti_mix_E6_case001.ini'
    #run keyword and continue on failure	   check_csirs_pattern_id_for_ue_specific_csirs    ${TEST_LOG_DIRECTORY()}/All/${TTI_TAG}_mix_dl.csv
    #...    ${ue1_rnti}    ${CH_BW}    ${SUB_BAND_SIZE}


Detach all SA UEs
    airphone_sa_detach    ue_id=${UE1_SA_ID}    timeout=30
    airphone_sa_detach    ue_id=${UE2_SA_ID}    timeout=30
    airphone_sa_detach    ue_id=${UE3_SA_ID}    timeout=30
    airphone_sa_detach    ue_id=${UE4_SA_ID}    timeout=30

Attach '${UE_NUM_SA}' SA UEs with '${egate_tag}'
    airphone_cleanup_egate_console_log
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
       Airphone SA Attach    ue_id=${num}
       Wait '2s' for stabible
       Airphone Set Traffic Type    ue_id=${num}    pdu_id= ${num}    type=internal
       Wait '2s' for stabible
       Airphone Pdu Session Setup    ue_id=${num}   pdu_id=${num}   nwslice_id=1   gw_id=${num}
       Wait '2s' for stabible
    END
    Collect AP egate log    ${egate_tag}

SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    5   175M   ${num}    tcp
        SA send mutiple trf ul data    ${num}    1    10M   ${num}
    END

Airphone SA Stop Data Traffic And Detach UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        Airphone SA Detach    ue_id=${num}
    END

Stop data transfer'${UE_ID}'
    airphone_sa_stop_data_traffic    ue_id=${UE_ID}    pdu_id=${UE_ID}    direction=dl

SA send small data to ‘${UE_ID}’ UE
    SA send mutiple trf dl data    ${UE_ID}    1   10M   ${UE_ID}


Check SA UE throughput
    Wait until keyword succeeds    60s    5s    Verify multi SA UEs throughput

Verify multi SA UEs throughput
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        Log To Console		UE:${num} dl_tput= ${dl_throughput_pcell}
        Log To Console		UE:${num} ul_tput= ${ul_throughput_pcell}
    END
#        should_be_true    ${dl_throughput_pcell}>210000


Check ttitrace'${ini_file}'
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Check ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_case19.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/


SA UE '${UE_ID}' fix RANK3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=40 ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=40 scell\=0

SA UE '${UE_ID}' fix RANK2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=30 ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=30 scell\=0

SA UE '${UE_ID}' fix RANK1
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=20 ri\=0 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=20 scell\=0

Set UE '${UE_ID}' pos and move
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=30 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5
    ...    trigger_puxch_update\=0 azimuth\=30 zenith\=10 test_type=SRS
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1

Set UE '${UE_ID}' low power
    ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=40 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
    ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-650,-600,-650,-600
    airphone_execute_egate_command    ${cmd}
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=40

Set UE '${UE_ID}' power deactivate
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=40

Set UE '${UE_ID}' position1
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43

Set UE '${UE_ID}' position2
    airphone_execute_egate_command    ul_mimo_srs_beam_pos_nr profile_id\=43 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=43


Get SA UE crnti in RRC log'${EGATE_TAG}'
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   crnti: (\\d+)
    [return]     ${rnti_list}

Get NSA UE crnti in RRC log'${EGATE_TAG}'
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/${EGATE_TAG}_egate/egate_console.log.001   newUE-Identity (\\d+)
    [return]     ${rnti_list}


Online change actUeCsirsCoexistCellCsirs '${state}'
	TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actUeCsirsCoexistCellCsirs    ${state}    online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    TAF_ADMIN.teardown admin    connection=online
    Wait '30s' for stabible


Check cell specific CSI RS not multiplexing in rrclog‘${egate_dir}’
    check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}

Check ue specific CSI RS not multiplexing in rrclog‘${egate_dir}’
    check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}

Check all cell specific CSI RS multiplexing in rrclog‘${egate_dir}’
    check_log_with_au2anlysis    ${CURDIR}/ini/all_cell_specific_csirs_multiplex.ini    p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}

Check cell specific CSI RS multiplexing in rrclog‘${egate_dir}’
    check_log_with_au2anlysis    ${CURDIR}/ini/cell_specific_csirs_multiplex.ini    p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}

Check ue specific CSI RS multiplexing in rrclog‘${egate_dir}’
    check_log_with_au2anlysis    ${CURDIR}/ini/ue_specific_csirs_multiplex.ini    p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${egate_dir}


Convert '${bip_tag}' BIP and check
    Log To Console   convert bip to csv
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/tcpdump_L2L1_bip_filtering_off.pcap0
     ...    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    ${FILTER_SRS_REQ}    ${titles_bfsubbandid}
     check_srsreceivereq_bfSubbandId_item    ${TEST_LOG_DIRECTORY()}/All/${bip_tag}/bip_bfsubbandid.csv    0    0     28



