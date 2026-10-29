*** Settings ***
Documentation
...

Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_menzheng    AP    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_lO_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_13071_case35.xml
${AIRPHONE_NAME}    iphy_case35.xml
${WTS_NAME}    wts_config_CB013071_case035.lua

${par_of_bsr_name_1}                BSR_AVHQB_6_H6_ALN45_ARP45_N01_COVE3593_00391_00001
${par_of_bsr_name_2}                BSR_AVHQB_6_H6_ALN45_ARP45_N01_COVE2595_00391_00001

@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${FILTER_f1ap}    itf_l2_ps_user_usersetupreq
@{titles_f1ap}    3gpp.rnti    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item
${FILTER}    DlData_CsiRsResourceL1sw_t.csiRsScramblingSequenceInt
@{titles}    DlData_CsiRsResourceL1sw_t.trsInfo    DlData_CsiRsResourceL1sw_t.startPrb    DlData_CsiRsResourceL1sw_t.numOfPrb
${BIP_TAG}    8322_bip
${BIP_TAG_1}    8322_bip_1
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'
...    NUMBER_OF_FILES=30
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=20 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=2 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=10 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS
...        multi_path_config=true num_of_nlos_paths=1 azimuth=0 zenith=0 srs_transmit_power_per_port=-200,-200,-200,-200

${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4


*** Test Cases ***
CB013071_E_B01_CASE035_32TRX_dual_band_SubbandBm_200Mhz_plus_4CC
    Get and Update BSR File    ${par_of_bsr_name_1}
    Get and Update BSR File    ${par_of_bsr_name_2}
    Prepare gnb onair
    Start capture gnb and ap syslog in 'SA_ue' file
    UE SA Register to cell1
    UE SA Register to cell2
    UE SA Register to cell3
    UE SA Register to cell4
    online change actDlSrsSubbandBm to false
    UE SA Register to cell1 again
    Check ttitrace
    Check ttitrace dft
    Stop capture gnb and ap syslog in 'SA_ue' file

*** Keywords ***
Add RD
    Add GNB swconfig    0x9D0000:3		#whether to skip FR1 CA UE on FDD SCell for slot (symbol 6) CB

UE SA Register to cell1
    UE from '1' to '4' SA Register
    Send DL and UL data
    Set UEs Pos
    check throughput from SA UE '1' to '4' with tp '600'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tticell1'
#    Start Bip Trace
#    Wait '1s' for stabible
#    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/bipcell1
    DeRegister UE from '1' to '4'

UE SA Register to cell1 again
    airphone_execute_egate_command	  ue_change_location cell\=1 id\=1-4
    UE from '1' to '4' SA Register
    Send DL and UL data
    check throughput from SA UE '1' to '4' with tp '600'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'ttidft'
    DeRegister UE from '1' to '4'

UE SA Register to cell2
    airphone_execute_egate_command	  ue_change_location cell\=2 id\=1-4
    UE from '1' to '4' SA Register
    Send DL and UL data
    check throughput from SA UE '1' to '4' with tp '470'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tticell2'
#    Start Bip Trace
#    Wait '1s' for stabible
#    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/bipcell2
    DeRegister UE from '1' to '4'

UE SA Register to cell3
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=1-4
    UE from '1' to '4' SA Register
    Send DL and UL data
    check throughput from SA UE '1' to '4' with tp '220'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tticell3'
#    Start Bip Trace
#    Wait '1s' for stabible
#    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/bipcell3
    DeRegister UE from '1' to '4'

UE SA Register to cell4
    airphone_execute_egate_command	  ue_change_location cell\=4 id\=1-4
    UE from '1' to '4' SA Register
    Send DL and UL data
    check throughput from SA UE '1' to '4' with tp '220'
    Start collect ttitrace
    Wait for '1s' to stop ttitrace with name'tticell4'
#    Start Bip Trace
#    Wait '1s' for stabible
#    Stop Bip Trace   ${TEST_LOG_DIRECTORY()}/All/bipcell4
    DeRegister UE from '1' to '4'

Send DL and UL data
    SA send data '4' UEs
    Wait '10s' for stabible

UE send RANK4
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0-1

SA DeRegister UE '${ue}'
    airphone_sa_detach    ue_id=${ue}    timeout=5

#==========SA=======================
UE from '${lo}' to '${hi}' SA Register
    FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
      airphone_cleanup_egate_console_log
      Log To Console   ${\n}-----register UE ${ue} ------
      SA Register UE ${ue}
    END

SA Register UE ${UE_ID}
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '5s' for stabible
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
#     airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=16


Get SA '${ue}' crnti in RRC log
    Log To Console   check UE RRC log to get ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_HO/egate_console.log.001   crnti: (\\d+)
    [return]     ${rnti_list[0]}

SA send data '${UE_NUM_SA}' UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM_SA}+1
        SA send mutiple trf dl data    ${num}    3    175M   ${num}
        SA send mutiple trf ul data    ${num}    1    50M    ${num}
    END

check throughput from SA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}	#167.7_168.6_251.9_189.3

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

#check tti
Check ttitrace
    Log To Console    Check Bler in ttiTrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_cell1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_cell1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_cell2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_cell2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_cell3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_cell3.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl_cell4.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_cell4.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Check ttitrace dft
    Log To Console    Check Bler in ttiTrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_dl.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Start collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Start collect '${bip_file}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=${bip_file}    options= -i any -C 300    remote_info=${executor_oam_vm}

Stop collect UE f1ap
    [Arguments]     ${bip_file}
    Log To Console    Stop collect '${bip_file}' tcpdump
    Stop Tcpdump    ${bip_file}    ${TEST_LOG_DIRECTORY()}/All/${bip_file}

check UE f1ap bip
    [Arguments]     ${bip_title}
    Log To Console   ${\n}---check bip---
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/${bip_title}/${bip_title}.csv    ${FILTER_f1ap}    ${titles_f1ap}
    Check Log With Au2anlysis    ${CURDIR}/ini/f1ap_case41.ini     i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}

Check startPrb and numOfPrb in BIP
    [Arguments]	${bip_title}
	Merge_pcaps    ${bip_title}
    run keyword and continue on failure    Convert BIP To CSV    ${test_log_directory()}/All/${bip_title}/bip_out.pcap
    ...    ${test_log_directory()}/All/${bip_title}/bip_check.csv    ${FILTER}    ${titles}
    run keyword and continue on failure    Check Log With Au2anlysis    ini_path=${CURDIR}/ini/startprb_numofprb.ini
    ...    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${bip_title}

Get And Validate Counters
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    ${time}    Evaluate    type(${remaining_time})
    ${remaining_time}     evaluate     ${remaining_time}+300
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
    ${value_M55308C29001}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29001    cell_id=1
    ${value_M55308C29003}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29003    cell_id=1
    ${value_M55308C00085}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C00085    cell_id=1
    ${value_M55308C29005}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55308C29005    cell_id=1
    should be true    ${value_M55308C00085} > ${value_M55308C29003}
    should be true    ${value_M55308C29003} > ${value_M55308C29001}
    should be true    ${value_M55308C29001} > 0
    should be true    ${value_M55308C29005} == 0

Merge_pcaps
    [Arguments]     ${bip_title}
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    cd ${test_log_directory()}/All/${bip_title};mergecap -w bip_out.pcap *.pcap    connection=bsh

online change actDlSrsSubbandBm to false
    Perform Online Change Parameter Value    MRBTS-1/NRBTS-1/NRCELL-1    actDlSrsSubbandBm    false    update
    Wait '30s' for stabible

Set UEs Pos
    airphone_execute_egate_command    ${PROFILE1}
    airphone_execute_egate_command    ${SET_PROFILE1}
    airphone_execute_egate_command    ${PROFILE2}
    airphone_execute_egate_command    ${SET_PROFILE2}
    airphone_execute_egate_command    ${PROFILE3}
    airphone_execute_egate_command    ${SET_PROFILE3}
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}