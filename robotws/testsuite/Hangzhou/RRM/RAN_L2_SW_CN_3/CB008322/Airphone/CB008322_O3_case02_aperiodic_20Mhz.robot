*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8322_O3_case02_8D4U_AQQL_1208_20M_SBsize_8prb.xml
${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_20M_8x4_with_rtPidCapacity.xml
@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${WTS_NAME}    wts_8322_SA_NSA_20M.cfg
${BIP_TAG}    srs
${ue_id_1}    1

${NLOSS_PROFIL1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-400,-400,-400,-400

*** Test Cases ***
CB008322_O3_case02_aperiodic_codebook_SRS_port_adaption_20Mhz
    [Documentation]
    ...    cb008322 AP debug log
    Prepare test and bts onair
    airphone_cleanup_egate_console_log
	attach sa UE1 and send dlul data
	Wait '1s' for stabible
	run keyword and continue on failure    check SA UE'1' dl tput range is '160' to '180' and ul tput range is '20' to '25'
	step1:Set pathloss to triger ue ul rank switch to 1 port and check log
    step2:Triger ue switch from WB SRS to SB SRS by little data and check log
    step3:Triger ue switch from SB SRS to WB SRS by big data and check log
    step4:Set pathloss to triger ue ul rank switch to 2 port and check log
    run keyword and continue on failure    check SA UE'1' dl tput range is '160' to '180' and ul tput range is '20' to '25'


*** Keywords ***
Prepare test and bts onair
    Active GNB L2 feature debug traces
    Add gNB RD Parameter to swconfig
    Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
    Prepare gnb onair
    airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file

Add gNB RD Parameter to swconfig
    Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true

attach sa UE1 and send dlul data
    Attach SA ue to 5g cell    CA_P2_8x4_t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
    SA UE'1' send '170M' with trf num'1' dl data and '40M' with trf num'1' ul data
    Airphone Execute Egate Command    ${NLOSS_PROFIL1}
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    Stop egate log and unzip with name'step0_ue_attach'

SA ue rank switch
	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
    Wait '1s' for stabible
	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=2
	Wait '1s' for stabible
	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=1
	Wait '1s' for stabible
	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=3 

step1:Set pathloss to triger ue ul rank switch to 1 port and check log
    airphone_cleanup_egate_console_log
    Start collect ttitrace
	Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 pathloss\=130
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
	Wait '6s' for stabible
	Wait for '1s' to stop ttitrace with name'tti1_rank2_to_rank1'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_step1_to_rank1   unzip=TRUE
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/O3_case2_rrc_step1_to_rank1.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_step1_to_rank1


step2:Triger ue switch from WB SRS to SB SRS by little data and check log
    airphone_cleanup_egate_console_log
    Start collect ttitrace
    airphone_sa_stop_data_traffic    ue_id=${ue_id_1}   pdu_id=${ue_id_1}   direction=dl
    SA send mutiple trf dl data    ${ue_id_1}    number=1   dl_data=10M    pdu_id=${ue_id_1}
    Wait for '3s' to stop ttitrace with name'tti2_rank1_reconfig_to_sbsrs'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_step2_to_sbsrs   unzip=TRUE
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/O3_case2_rrc_step2_to_sbsrs.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_step2_to_sbsrs

step3:Triger ue switch from SB SRS to WB SRS by big data and check log
    airphone_cleanup_egate_console_log
    Start collect ttitrace
    airphone_sa_stop_data_traffic    ue_id=${ue_id_1}   pdu_id=${ue_id_1}   direction=dl
    SA send mutiple trf dl data    ${ue_id_1}    number=1   dl_data=170M    pdu_id=${ue_id_1}
    Wait for '3s' to stop ttitrace with name'tti3_rank1_reconfig_to_wbsrs'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_step3_to_wbsrs   unzip=TRUE
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/O3_case2_rrc_step3_to_wbsrs.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_step3_to_wbsrs

step4:Set pathloss to triger ue ul rank switch to 2 port and check log
    airphone_cleanup_egate_console_log
    Start collect ttitrace
	Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 pathloss\=80
	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=2 scell\=0
	Wait '6s' for stabible
	Wait for '1s' to stop ttitrace with name'tti4_wbsrs_reconfig_to_rank2'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_step4_to_rank2   unzip=TRUE
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/O3_case2_rrc_step4_to_rank2.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_step4_to_rank2

Online change actCoverageNonCoherentUes ${targetValue}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1    actCoverageNonCoherentUes    ${targetValue}    online
    TAF_ADMIN.teardown admin    connection=online

Detach SA UE'${UE_ID}'
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30

SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num}' ul data
    SA send mutiple trf dl data    ${ue_id}    number=${dl_trf_num}   dl_data=${dl_data_size}    pdu_id=${ue_id}
    SA send mutiple trf ul data    ${ue_id}    number=${ul_trf_num}   ul_data=${ul_data_size}    pdu_id=${ue_id}

SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
    SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
    Wait Throughput Timer    3s

collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
    Start collect ttitrace
    Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'

Attach one SA UE'${ue_id}'
    Log To Console   ${\n}-----register SA UE ${ue_id} ------
    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}

check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
    Log To Console    ..Check throughput UE${ue_id}
    ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
    ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    Log To Console    dl ${dl_tput_Mb}
    Log To Console    ul ${ul_tput_Mb}
    should be true    ${dl_tput_Mb}>=${dl_low_Mb}
    should be true    ${dl_tput_Mb}<=${dl_high_Mb}
    should be true    ${ul_tput_Mb}>=${ul_low_Mb}
    should be true    ${ul_tput_Mb}<=${ul_high_Mb}

check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
    log to console    start to check throughput ${ue_id}
    should be true    ${dl_tput}>${dl_low}
    should be true    ${dl_tput}<${dl_high}
    should be true    ${ul_tput}>${ul_low}
    should be true    ${ul_tput}<${ul_high}

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}

check ue been released or can not get dl ul tput than run SOS report stop test
    Wait until keyword succeeds    600s    5s    check Ues been release or dl and ul no tput

check Ues been release or dl and ul no tput
    ${status} =	Run Keyword And Return Status	check all ue has dl and ul throughput
    Should Be True	  ${status} == False
    Run Keyword If    ${status} == False    SOS report LOAPLO Stop test

check all ue has dl and ul throughput
    Wait '10s' for stabible
    FOR    ${ue_id}    IN RANGE    1    ${UE_NUM}+1
       Log To Console    Check throughput UE${ue_id}
           ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
           ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
           ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
           Log To Console    dl ${dl_tput_Mb}
           Log To Console    ul ${ul_tput_Mb}
           should be true    ${dl_tput_Mb}>1
           should be true    ${ul_tput_Mb}>100
    END

SOS report LOAPLO start test
    Log To Console    Run SOS start test...
    ${output}=    Run    /opt/wts/latest/startTest.sh >/tmp/startSOS.log
    File Should Exist    /tmp/startSOS.log
    Log To Console    End Run SOS report start test...

SOS report LOAPLO Stop test
    Log To Console    Run SOS Stop test...
    ${output}=    Run    /opt/wts/latest/stopTest.sh >/tmp/stopSOS.log
    File Should Exist    /tmp/stopSOS.log
    Log To Console    End Run SOS report Stop test.....
