*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    owner_l3gao   AP    CRT
...    SBTS00    SBTS23R1    RAN_5G_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
Documentation     maxDlHarqTx=8
...               0x340000=15      # as PM counter period update to 15/15=1min

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${SCFC_NAME}      SCFC_8701_benchmark.xml
${SCFC_NAME}      SCFC_8701_benchmark_ULmimo.xml
${AIRPHONE_NAME}    IPHY_AEHC_1CELL_APLO.xml
${WTS_NAME}       wts_aehc_8701_aplo_nsa.cfg
@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM}         20
${EGATE_TAG}      MUmimo
${BIP_TAG}    mumumo_bip
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
@{Rdparameter}        #0x5806d7:1  # 89341
${TP_sum}    0
${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID


${TP_PEAK_DL}    750000  #750mbps
${TP_PEAK_UL}    80000   #80mbps

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=70 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=60 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=30 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=20 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=10 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-10 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-20 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-30 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-40 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-50 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-60 zenith\=40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE17}    ul_mimo_srs_beam_pos_nr profile_id\=17 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=-40 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE18}    ul_mimo_srs_beam_pos_nr profile_id\=18 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=35 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE19}    ul_mimo_srs_beam_pos_nr profile_id\=19 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=25 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE20}    ul_mimo_srs_beam_pos_nr profile_id\=20 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-25 zenith\=10 srs_transmit_power_per_port=-450,-450,-280,-280
${PROFILE21}    ul_mimo_srs_beam_pos_nr profile_id\=21 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-35 zenith\=-10 srs_transmit_power_per_port=-450,-450,-280,-280

*** Test Cases ***
CB008701_A_B4_case15_PMcounter_dlMuMaxNumLayerPerMuRbg_variblity_test
    step1:get ready for gnb
#    step2:attach UEs with Pos and get rnti
#    step3:send full buffer for UEs and check logs

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Get and Update BSR File    ${par_of_bsr_name}
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log

step2:attach UEs with Pos and get rnti
    Log To Console   \n-------------step2:attach UEs with Pos and get rnti---------------
    Create SRS_pos profile
	Attach '${UE_NUM}' SA UEs with f1ap
	set '${UE_NUM}' SA UEs Pos

step3:send full buffer for UEs and check logs
    Log To Console   \n-------------step3:send full buffer for UEs and check logs---------------
    SA '${UE_NUM}' UE Data buffer send
	run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=20
    Collect ttitrace and Check    tti_tag=benchmark_tti_step3    ini_file=8701_benchmark_1

Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}
	Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'${tti_tag}'
    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}    ${ini_file}
    check_cdm_group_and_dmrs_port_by_antenna_port_value     ${TEST_LOG_DIRECTORY()}/All/${tti_tag}/tti_dl.csv

Check ttitrace with ini
    [Arguments]     ${tti_tag}    ${ini_file}
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_tag}/

Check SA UE throughput
    [Arguments]     ${ue_start}    ${ue_end}
    Wait until keyword succeeds    48s    8s    Verify multi SA UEs throughput    ${ue_start}    ${ue_end}

Create SRS_pos profile
    FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
        airphone_execute_egate_command    ${PROFILE${num}}
    END

Verify multi SA UEs throughput
    [Arguments]     ${ue_start}    ${ue_end}
    ${UEs_TP_DL}   create list
    ${UEs_TP_UL}   create list
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        run keyword and continue on failure    should_be_true    ${dl_throughput_pcell}>11000
        run keyword and continue on failure    should_be_true    ${ul_throughput_pcell}>3000
        append to list    ${UEs_TP_DL}    ${dl_throughput_pcell}
        append to list    ${UEs_TP_UL}    ${ul_throughput_pcell}
        log to console    UE${ue_start} to UE${ue_end} DL_TP_result are ${UEs_TP_DL}
        log to console    UE${ue_start} to UE${ue_end} UL_TP_result are ${UEs_TP_UL}
    END

SA '${UE_NUM}' UE Data buffer send
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       SA send mutiple trf dl data    ${num}    1   130M    1   #peak 150mbps
       SA send mutiple trf ul data    ${num}    1   5M    1
    END

tti check
    [Arguments]    ${ini_file}    ${tti_file}
    run keyword and continue on failure    check_cdm_group_and_dmrs_port_by_antenna_port_value    ${TEST_LOG_DIRECTORY()}/All/${tti_file}/tti_dl.csv
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/${ini_file}.ini    log_need_to_check=i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All/${tti_file}/

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}/tti


Check 8 SA UE throughput
    [Arguments]     ${throughput}    ${rank1_yes}
    run keyword if   ${rank1_yes}==1     Wait until keyword succeeds    48s    8s    Verify 8 SA UEs throughput with UE1 rank1    ${throughput}
    run keyword if   ${rank1_yes}==0     Wait until keyword succeeds    48s    8s    Verify 8 SA UEs throughput     ${throughput}

Verify 8 SA UEs throughput
    [Arguments]    ${target_cell_throughput}
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pdsch    tput_type=ave
        ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${num}    scell_id=0    type=pusch    tput_type=ave
        should_be_true    ${dl_throughput_pcell}>(${target_cell_throughput}/8)
        ${TP_sum}    evaluate   ${TP_sum}+${dl_throughput_pcell}
        Run Keyword If    ${num}==${UE_NUM}   should be true   ${TP_sum}> ${target_cell_throughput}
    END


Airphone '${UE_NUM}' SA Stop Data Traffic
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Stop Data Traffic     ${num}     BI    ${num}
    END

Airphone '${UE_NUM}' SA Stop Data Traffic And Detach UE
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '4s' for stabible
    END


Create SRS_pos 20 profile
    FOR    ${num}    IN RANGE    2    ${UE_NUM}+2
        airphone_execute_egate_command    ${PROFILE${num}}
    END

set '${UE_NUM}' SA UEs Pos
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        ${num_r}    evaluate    ${num}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num_r}
    END

Add RD
    Add GNB swconfig    0x340000:3   #PMcounter

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