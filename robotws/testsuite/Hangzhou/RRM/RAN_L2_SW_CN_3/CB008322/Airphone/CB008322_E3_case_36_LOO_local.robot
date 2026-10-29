*** Settings ***
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Force Tags        CRT    SBTS00   RAN_5G_TDD    RAN_5G   owner_l3gao    CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot

Documentation
...     srs sb-sl40  wb-sl80  frame 1116
...     step1:attach 2TDD UE1 ,then T+T+F 3CC UE2 ,then 2TDD UE3,UE4,UE5,scell no add,check srs resource
...                      2UE are cb+2tas  2UE are only code book ,1 UE is aperSRS
...     step2:push dl/ul little data for 5UEs ,check ack and beam id in pcell
...     step3:push full data for UE1 ,sb switch to wb,check ack and beam id in pcell
...                     UE1 1 sb-cb srs and 2 wb-tas srs
...     step4:trigger UE1 scell addition,check beam for pcell and scell
...                     UE1 1 sb-cb srs and 4 wb-tas srs ,due to slot conflict 1cb resued for tas
...     step5-step6 do same for UE2
...     step7:attach more 3ues ,1ue3cc 2ue 2cc sbsrs will exshaulted
...     step8:push dl/ul little data for 3UEs ,check ack and beam id in pcell
...     step9:overide UE1 UE2 bad RLQ ,switch WB srs to sbsrs ,UE1 sb-cb srs ,UE2 aperiodic cell-specific srs should be there
...     step10:push full data for UE3 UE4 and overide UE1 UE2 good RLQ
...                        UE3 UE4 UE1 swich to wb-srs ,UE2 no periodic srs
...     step11:push full data for UE5 UE6 UE7 ,UE5 will be WB srs
...     step12:trigger UE3 UE4 UE5 UE6 UE7 UE8 scell addition to be 2TDD 2CC

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
#${SCFC_NAME}      SCFC_8322_E3_case36_LOO.xml
${SCFC_NAME}      SCFC_8322_E3_case36_LOO_cwq.xml
${AIRPHONE_NAME}    IPHY_2AQQL_2FDD_E3_GL.xml
${WTS_NAME}    wts_8322_4cell_SA_NSA_2TDD_2FDD_case36.lua
@{LOG_NAME_LIST}    gnb_snapshot
${UE_NUM_SA}    1
${UE_NUM}    1

${FILTER_f1ap_srsModify}    itf_l2_ps_user_reconfigurationrequiredind||rrc||f1ap||itf_l2_ps_user_usermodifyreq
@{titles_tasSrsResourceInd}    3gpp.sfn    3gpp.slot    3gpp.rnti    itf_l2_ps_user_ReconfigurationRequiredInd_t.tasSrsResourceInd
...    itf_l2_ps_user_ReconfigurationRequiredInd_t.ueIdDu
${FILTER_f1ap_rrc_itl_l2ps}    f1ap||e1ap||rrc
...    ||itf_l2_ps_user_reconfigurationrequiredind||itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_usersetupreq
@{titles_duID_Crnti}    3gpp.sfn    3gpp.slot    3gpp.rnti    f1ap.GNB_DU_UE_F1AP_ID

${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=40 zenith\=30 srs_transmit_power_per_port\=-280,-280,-280,-280
@{TOOLS_LIST}    luashark    bip_script    common_config_golden    common_config_private    #mcshark    ttitrace_decode

${TP_PEAK_DL}    1300000  #1.1gbps
${TP_PEAK_UL}    150000   #211mbps

*** Test Cases ***
CB008322_E3_case36_subbandBeam_interwork_TDD_FDD_Mixed_CA_8X4mimo_CSIRS_reconfiguration_WB_before_Scelladdition
    step1:get ready for gnb
    step2:attach 5UEs and get rnti
    step3:send little buffer for UEs and check logs
    step4:send full buffer for T_T 2CC UE1 and check logs
    step5:send full buffer for T_F_T 3CC UE2 and check logs
    step6:attach 3UEs more and get rnti
    step7:bad RLQ for UE1_UE2 switch out wb_srs
    step8:UE3_UE4 full buffer and good RLQ for UE1_UE2
    step9:full data for UE5_to_UE7
    step10:tigger UE3_to_UE8 scell addition

*** Keywords ***
step1:get ready for gnb
    Log To Console   \n-------------step1:get ready for gnb---------------
	Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    ${custom_error}    Create list    ERR/.uplane    ERR/L2-PS    ERR/l1_application_rt    WRN/.uplane    #WRN/L2-PS
	Set Test Variable    ${custom_error}
	Prepare gnb onair
	Create SRS_pos profile
	Airphone Cleanup Egate Console Log

step2:attach 5UEs and get rnti
    Log To Console   \n-------------step2:attach UEs and get rnti---------------
    Start capture only gnb syslog in 'step2' file
	Attach SA UEs with f1ap    ue_start=1    ue_end=5
	set SA UEs Pos    ue_start=1    ue_end=5
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step2' file '${custom_error}'

step3:send little buffer for UEs and check logs
    Log To Console   \n-------------step3:send little buffer for UEs and check logs---------------
    Start capture only gnb syslog in 'step3' file
    SA send little data buffer    ue_start=1    ue_end=5   data=15M
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=5    dl_target=15000    ul_target=2000
    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case36_step3_tti
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step3' file '${custom_error}'
    Collect AP egate log    step3

step4:send full buffer for T_T 2CC UE1 and check logs
    Log To Console   \n-------------step4:send full buffer for UE1 and check logs---------------
    Start capture only gnb syslog in 'step4' file
    SA send full data buffer    ue_start=1    ue_end=1   data=150M
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=1    dl_target=15000    ul_target=2000
    Collect ttitrace and Check    tti_tag=tti_step4_UE1    ini_file=Case36_step4_tti
    Send A1 event for UE'1' to add scell
    Collect ttitrace and Check    tti_tag=tti_step4_UE1_CA    ini_file=Case36_step4_tti_CA
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step4' file '${custom_error}'
    Collect AP egate log    step4

step5:send full buffer for T_F_T 3CC UE2 and check logs
    Log To Console   \n-------------step5:send full buffer for T_F_T 3CC UE2 and check logs---------------
    Start capture only gnb syslog in 'step5' file
    SA send full data buffer    ue_start=2    ue_end=2   data=150M
	run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=2    ue_end=2    dl_target=15000    ul_target=2000
    Collect ttitrace and Check    tti_tag=tti_step5_UE1_UE2    ini_file=Case36_step5_tti
    Send A1 event for UE'2' to add scell
    Collect ttitrace and Check    tti_tag=tti_step5_UE1_UE2_CA    ini_file=Case36_step5_tti_CA
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step5' file '${custom_error}'
    Collect AP egate log    step5

step6:attach 3UEs more and get rnti
    Log To Console   \n-------------step2:attach UEs and get rnti---------------
    Start capture only gnb syslog in 'step6' file
    Start collect UE f1ap    step6_attach_3more_UEs
	Attach SA UEs with f1ap    ue_start=6    ue_end=8
	set SA UEs Pos    ue_start=6    ue_end=8
	SA send little data buffer    ue_start=6    ue_end=8   data=15M
	Stop collect UE f1ap    step6_attach_3more_UEs
    Collect ttitrace and Check    tti_tag=tti_step6_8UE    ini_file=Case36_step6_tti
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step6' file '${custom_error}'
    Collect AP egate log    step6

step7:bad RLQ for UE1_UE2 switch out wb_srs
    Log To Console   \n-------------step7:bad RLQ for UE1_UE2 switch out wb_srs---------------
    Start capture only gnb syslog in 'step7' file
    Start collect UE f1ap    step7_wbsrs_2_sbsrs
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank1
    Wait '5s' for stable
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank1
    Wait '5s' for stable
    Stop collect UE f1ap    step7_wbsrs_2_sbsrs
    Collect ttitrace and Check    tti_tag=tti_step7_wbsrs_2_sbsrs    ini_file=Case36_step7_tti
    run keyword and continue on failure	   Check non_CA SA UE throughput    ue_start=1    ue_end=8    dl_target=15000    ul_target=2000
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step7' file '${custom_error}'

step8:UE3_UE4 full buffer and good RLQ for UE1_UE2
    Log To Console   \n-------------step8:UE3_UE4 full buffer and good RLQ for UE1_UE2---------------
    Start capture only gnb syslog in 'step8' file
    Start collect UE f1ap    step8_UE3_4_1_wbsrs_2_sbsrs
    SA send full data buffer    ue_start=3    ue_end=4   data=120M
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank1
    Stop collect UE f1ap    step8_UE3_4_1_wbsrs_2_sbsrs
    Collect ttitrace and Check    tti_tag=step8_UE3_4_1_wbsrs_2_sbsrs    ini_file=Case36_step7_tti
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step8' file '${custom_error}'

step9:full data for UE5_to_UE7
    Log To Console   \n-------------step9:full data for UE5_to_UE7---------------
    Start capture only gnb syslog in 'step9' file
    Start collect UE f1ap    step9_UE5_wbsrs_2_sbsrs
    SA send full data buffer    ue_start=5    ue_end=7   data=120M
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank1
    airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank1
    Stop collect UE f1ap    step9_UE5_wbsrs_2_sbsrs
    Collect ttitrace and Check    tti_tag=step9_UE5_wbsrs_2_sbsrs    ini_file=Case36_step7_tti
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step9' file '${custom_error}'

step10:tigger UE3_to_UE8 scell addition
    Log To Console   \n-------------step10:tigger UE3_to_UE8 scell addition---------------
    Start capture only gnb syslog in 'step10' file
    Start collect UE f1ap    step10_scell_addition_for_all
    Send A1 event for UEs to add scell    ue_start=3    ue_end=8
    Stop collect UE f1ap    step10_scell_addition_for_all
    Collect ttitrace and Check    tti_tag=step10_scell_addition_for_all    ini_file=Case36_step7_tti
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'step10' file '${custom_error}'

Send A1 event for UE'${UE_ID}' to add scell
    airphone_execute_egate_command    ue_measurement_send_nr id\=${UE_ID} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=100
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0
    airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID} meas_obj_type\=nr\r


Send A1 event for UEs to add scell
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=1 event\=A1 rs_type\=ssb srsrp_nr\=100
    END
    Wait '10s' for stable



step5:override UE1 to rank1 and check logs
    Log To Console   \n-------------step5:override UE1 to rank1 and check logs---------------
    Start collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
    Airphone SA Stop Data    ue_start=6    ue_end=8
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank1
    Wait '5s' for stable
    Stop collect UE f1ap    step5_ue1_aperisrs_ue5RTbeam
    Check UE srs_switch from s1ap    step5_ue1_aperisrs_ue5RTbeam    Case27_step5_F1ap_1
    SA send data for UEs    ue_start=6    ue_end=8
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    ue_start=2    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case27_step5_tti
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8

step6:detach and reattach ue1 and check rrc
    Log To Console   \n-------------step6:detach and reattach ue1 and check rrc---------------
    Airphone SA Detach UE    1    1
    Attach SA UEs with f1ap    1    1
    SA send data for UEs    ue_start=1    ue_end=1
    run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case27_step6_tti
    Airphone SA Detach UE

step7:online change bfSubbandSize and run case again
    Log To Console   \n-------------step7:online change bfSubbandSize and run case again---------------
    Online change bfSubbandSize enabled
    Attach SA UEs with f1ap    ue_start=1    ue_end=18    tag=2
    SA send data for all 20UEs
	run keyword and continue on failure	   Check SA UE throughput    ue_start=1    ue_end=8
    Collect ttitrace and Check    tti_tag=tti_step3    ini_file=Case27_step7_tti    tag=2

Online change bfSubbandSize enabled
    Online recommissioning with delta json file    ${CONFIG_DIR_PATH}/${SW_BRANCH}/JSON/delta_8322_case27_16PRB.json
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    Wait '15s' for stable

step5:set 4port high power for UEs and check logs
    Log To Console   \n-------------step5:set 4port high power for UEs and check logs---------------
    Set ports power and creat file    profile_id=3    port1_power=-500    port2_power=-500    port3_power=-500    port4_power=-500
    FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
        Start collect UE f1ap    step5_srsModify_${num}
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
        Wait '2s' for stable
        Stop collect UE f1ap    step5_srsModify_${num}
    END
    Check UE srs_switch from s1ap    step5_srsModify_2    Case16_step5_F1ap_2
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=4
    Collect ttitrace and Check    tti_tag=tti_step5    ini_file=Case16_step5_tti



step6:set 2port low power for UEs and check logs
    Log To Console   \n-------------step6:set 2port low power for UEs and check logs---------------
    Set ports power and creat file    profile_id=4    port1_power=-500    port2_power=-500    port3_power=-750    port4_power=-750
    FOR    ${num}    IN RANGE    ${UE_NUM_SA}    0    -1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
        Wait '1s' for stable
    END
    Wait '4s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=4    UE2_layer=2
    Collect ttitrace and Check    tti_tag=tti_step6    ini_file=Case16_step6_tti

step7:override multi_rank and check logs
    Log To Console   \n-------------step7:override multi_rank and check logs---------------
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=1 ri_mode\=fixed
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=4 cqi\=15 cqi_mode\=fixed ri\=0 ri_mode\=fixed
    Log To Console   \n-------------step7:override rank3 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=2 scell\=0  #rank3
        Wait '1s' for stable
    END
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=3    UE2_layer=2
    Collect ttitrace and Check    tti_tag=tti_step7_1    ini_file=Case16_step7_tti_1
    Log To Console   \n-------------step7:override rank2 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=3 scell\=0  #rank2
        Wait '1s' for stable
    END
    Wait '5s' for stable
    run keyword and continue on failure	   Check SA UE throughput    UE1_layer=2    UE2_layer=2
    Collect ttitrace and Check    tti_tag=tti_step7_2    ini_file=Case16_step7_tti_2
    Log To Console   \n-------------step7:override rank1 and check logs---------------
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=4 scell\=0  #rank1
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
    Add GNB swconfig	0x340000:15    0x9D0000:15
    Add GNB swconfig	0x9D0000:15

Collect ttitrace and Check
    [Arguments]     ${tti_tag}    ${ini_file}    ${tag}=1
	Start collect ttitrace    name=${tti_tag}_${tag}
    Wait for '1s' to stop ttitrace with name'${tti_tag}_${tag}'
#    run keyword and continue on failure	   Check ttitrace with ini    ${tti_tag}_${tag}    ${ini_file}
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
    [Arguments]     ${ue_start}    ${ue_end}    ${dl_target}    ${ul_target}
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
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        Airphone SA Stop Data Traffic     ${num}     bi    1
    END

Create SRS_pos profile
    airphone_execute_egate_command    ${PROFILE2}

set SA UEs Pos
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
    END

SA send little data buffer
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=15M    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    1   ${data}   1    tcp
        SA send mutiple trf ul data    ${num}    1    30M   1
    END

SA send full data buffer
    [Arguments]     ${ue_start}=1    ${ue_end}=5    ${data}=170M    ${tag}=1
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        SA send mutiple trf dl data    ${num}    3   ${data}   1    tcp
        SA send mutiple trf ul data    ${num}    1    30M   1
    END