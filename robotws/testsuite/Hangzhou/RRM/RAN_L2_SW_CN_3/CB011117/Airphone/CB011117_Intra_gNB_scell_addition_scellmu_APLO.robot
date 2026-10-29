*** Settings ***
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   CLOUD_5G_I_LO_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Documentation
...     step1:attach 2TDD UE
...     step2:push dl/ul little data for 4UEs ,check ack and beam id in pcell
...     step3:push full data for UE1-UE4 ,2UEs sb switch to wb,check ack and beam id in pcell
...
...     step4:trigger UE1-UE4 scell addition,check beam for pcell and scell
...                      2UEs wb in pcell,  UEs DFT and can dl pair in scell

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_11117_intra_gnb.xml
${AIRPHONE_NAME}    IPHY_11117_intra_gnb.xml
${WTS_NAME}    wts_11117_intra_gnb.cfg
@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM_SA}    4
${UE_NUM}    4

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID


#${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
#...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=15 srs_transmit_power_per_port\=-200,-200,-200,-200
#${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
#...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=15 srs_transmit_power_per_port\=-200,-200,-200,-200
#${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
#...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
#${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
#...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=5 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-15 srs_transmit_power_per_port\=-200,-200,-200,-200
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-53 zenith\=-19 srs_transmit_power_per_port\=-200,-200,-200,-200

${SET_PROFILE2}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_PROFILE5}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5

@{TOOLS_LIST}    luashark      bip_script    common_config_golden    common_config_private    mcshark    ttitrace_decode

*** Test Cases ***
CB011117_A1b_case002_Scel_is_added_after_SRS_for_SB_BF_being_configured_with_Critical_band_CA
    [Documentation]
    ...   CB011117 old name:CB011117_Intra_gNB_scell_addition_scellmumimo
    ...   Test Steps:
    ...                 1.Attach 4UEs to cell1_1
    ...                 2.Send little data buffer to all UEs,check tput and ttitrace
    ...                 3.Send full data buffer to all UEs, A1 add scell,check tput and ttitrace
    ...    Check points:
    ...                 1.scell attach success
    ...                 2.all UEs beamtype DFT
    ...                 3.tput, Pcell  scell beamtype subband ratio, mupair ration,all scell beamtype DFT
    step1:get ready for gnb
    step2:attach 4UEs
    step3:send little buffer for UEs and check logs
    step4:send full data and add scell and check logs

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    #WRN/.uplane    #WRN/L2-PS
	Set Test Variable    ${custom_error}
	Prepare gnb onair
	Airphone Cleanup Egate Console Log

step2:attach 4UEs
    Log To Console   \n-------------step2:attach UEs and get rnti---------------
    Start capture only gnb syslog in 'step2' file
    Attach SA UEs with f1ap    ue_start=1    ue_end=4
    Set 4UEs different pos
    [Teardown]   run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'

step3:send little buffer for UEs and check logs
    Log To Console   \n-------------step3:send little buffer for UEs and check logs---------------
    Start capture only gnb syslog in 'step3' file
    SA send little data buffer    ue_start=1    ue_end=4   data=15M
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=4    dl_target=15    ul_target=20
    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=tti_dft
    Collect AP egate log    step3
    [Teardown]   run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3' file '${custom_error}'

step4:send full data and add scell and check logs
    Log To Console   \n-------------send A1 add scell and check logs---------------
    Start capture only gnb syslog in 'step4' file
    SA send full data buffer    ue_start=1    ue_end=4   data=150M
    Wait '5s' for stable
    Send A1 event for UEs to add scell
    Collect ttitrace and Check    tti_tag=tti_step4_UE1_CA    ini_file=tti_rt_pair
    Collect AP egate log    step4
    [Teardown]  run keyword and continue on failure    Stop capture gnb and ap syslog in 'step4' file '${custom_error}'


Send A1 event for UE'${UE_ID}' to add scell
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=100
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr\r


Send A1 event for UEs to add scell
    [Arguments]     ${ue_start}=1    ${ue_end}=4
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=2 event\=A1 rs_type\=ssb srsrp_nr\=100
    END
    Wait '10s' for stable


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


Set ports power and creat file
    [Arguments]     ${profile_id}    ${port1_power}    ${port2_power}    ${port3_power}=-750    ${port4_power}=-750
    ${cmd}   Catenate    ul_mimo_srs_beam_pos_nr profile_id\=${profile_id} mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
    ...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=15 zenith\=0
    ...    srs_transmit_power_per_port\=${port1_power},${port2_power},${port3_power},${port4_power}
    airphone_execute_egate_command    ${cmd}

Collect bip and Check
    Start collect bip log
    Wait for '1s' to stop bip log with name'${BIP_TAG1}'

Add RD
    Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true

Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}    ${tag}=1
    Log To Console   ${ini_file}
	Start collect ttitrace    name=${tti_tag}_${tag}
    Wait for '1.5s' to stop ttitrace with name'${tti_tag}_${tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}_${tag}    ${ini_file}
    split_8322_tti    ${TEST_LOG_DIRECTORY()}/All/${tti_tag}_${tag}/tti_dl.csv

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode    name=${tti_tag}
    log to console  ${\n}---decode tti start---
    Decoder Tttirace From Pcap To Csv    ${pcap_path}    ${test_log_directory()}/All/${tti_tag}/tti

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

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
#       Stop collect UE f1ap    UE${num}_attach_f1ap_${tag}
#       Get Crnti and gnb_du_id from f1ap    UE${num}_attach_f1ap_${tag}    ${num}
    END

Airphone SA Stop Data
    [Arguments]     ${ue_start}=1    ${ue_end}=${UE_NUM_SA}
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        Airphone SA Stop Data Traffic     ${num}     bi    1
    END

Create SRS_pos profile
    airphone_execute_egate_command    ${PROFILE2}

set SA UEs Pos
    [Arguments]     ${ue_start}=1    ${ue_end}=5
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
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
        SA send mutiple trf ul data    ${num}    1    170M   1
    END

Set 4UEs different pos
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${SET_PROFILE2}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command    ${SET_PROFILE3}
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}
    airphone_execute_egate_command    ${PROFILE5}
    airphone_execute_egate_command    ${SET_PROFILE5}
