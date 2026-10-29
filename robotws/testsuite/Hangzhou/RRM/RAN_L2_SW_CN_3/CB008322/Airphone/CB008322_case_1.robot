*** Settings ***
Documentation    CB008322
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G
...   CLOUD_5G_I_MP_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB008322_case_1.xml
${AIRPHONE_NAME}    IPHY_2AQQL.xml
${WTS_NAME}    wts_8322_case1.cfg

${UE_NUM}    8
${UE_ID}    1
${UE_ID2}    2
${UE_ID3}    3
${UE_ID4}    4
${UE_ID5}    5
${UE_ID6}    6
${UE_ID7}    7
${UE_ID8}    8
${RRC_Attach}    rrc_attach
${RRC_data}    rrc_data
${BIP_TAG}      databip
${RRC_few_data}    fewdata
${RRC_more_data}    moredata
${RRC_muchmore_data}    muchmoredata
${RRC_decrease_data}    decreasedata
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
${SET_PROFILE1}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbwvps) && !(3gpp.rnti == 65535)
@{title_srsreceivereq}   3gpp.sfn   3gpp.slot   3gpp.rnti
...   UlData_srsBwvReportRequest_t.rho
@{title_srsreceiverespbwvps}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item
@{value_list_level_sb_cell_1}
@{value_list_level_cell_1}
*** Test Cases ***
CB008322_E4_case001_Coexistence_with_multiple_BWP_BWP_change_base_DL_data_change
  Add GNB swconfig     0x9D0000:15
  Add GNB swconfig     0x590072:1
	Wts Execute Aashell Command
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log
	SA Register UEs from 1 to 8
	Start dl data
 	Send A1 event for UEs to add scell
  Wait '15s' for stabible
 	check throughput
 	Start collect ttitrace
	Wait for '0.5s' to stop ttitrace with name'tti'
	run keyword and continue on failure    check bler and beamtype is correct in ttitrace
  airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/   unzip=TRUE
  run keyword and continue on failure     	check_log_with_au2anlysis      ini_path=${CURDIR}/ini/ue_cell_specific_csirs.ini
  ...    log_need_to_check=p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/
  Check SRS counter
  DeRegister UE from 1 to 8
  Check BWP
	Stop capture gnb and ap syslog in 'after_onair' file
*** Keywords ***
#==========SA=======================
Start few data to check bwp2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    Airphone SA Start Data Traffic    ${UE_ID}   DL   10k   pdu_id=${UE_ID}   duration=3600   trf_id=1
Start more data to check bwp1
    Airphone SA Start Data Traffic    ${UE_ID}   DL   30M   pdu_id=${UE_ID}   duration=3600   trf_id=2
Start muchmore data to check bwp1
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=4
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=5
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=6
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=7
	Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=8
	Airphone SA Start Data Traffic    ${UE_ID}   DL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=9
Dcrease data
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=2
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=3
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=4
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=5
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=6
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=7
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=8
	airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl trf_id\=9
Get SA '${ue_id}' crnti in RRC log
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001    crnti: (\\d+)
    [return]     ${rnti_list[0]}
Step1 few dl data bwp2
    Start few data to check bwp2
    #Start collect bip log
    Start collect ttitrace
  	Wait for '5s' to stop ttitrace with name'ttifewd'
	#Wait for '0s' to stop bip log with name'bipfewd'
    Collect AP egate log    ${RRC_few_data}
	Check bwp2 setup in rrclog
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1
Step2 more dl data bwp1
    Airphone Cleanup Egate Console Log
    Start more data to check bwp1
   #	Start collect bip log
	Start collect ttitrace
	Wait for '3s' to stop ttitrace with name'ttimored'
	#Wait for '0s' to stop bip log with name'bipmored'
    Collect AP egate log    ${RRC_more_data}
    Check bwp1 setup in rrclog
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step2
Step3 muchmore dl data bwp1
    Airphone Cleanup Egate Console Log
    Start muchmore data to check bwp1
    Wait '2s' for stabible
   	#Start collect bip log
	  Start collect ttitrace
	  Wait for '1s' to stop ttitrace with name'ttimuchmored'
  #	Wait for '0s' to stop bip log with name'bipmuchmored'
    Collect AP egate log    ${RRC_muchmore_data}
	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput bwp
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step3
check throughput bwp
    Log To Console		=====tp=====
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=500000
Step4 decrease dl data
    Airphone Cleanup Egate Console Log
    Dcrease data
	Start collect bip log
	Start collect ttitrace
	Wait for '3s' to stop ttitrace with name'ttidecrease'
	Wait for '0s' to stop bip log with name'bipdecrease'
    Collect AP egate log    ${RRC_decrease_data}
	Check switch to bwp2 in rrclog
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step4
Check bwp1 setup in rrclog
	run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/rrc_to_bwp1.ini
	...    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_more_data}_egate
Check bwp2 setup in rrclog
	run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/rrc_to_bwp2.ini
    ...    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_few_data}_egate
Check switch to bwp2 in rrclog
	run keyword and continue on failure    check_log_with_au2anlysis    ${CURDIR}/ini/rrc_sto_bwp2.ini
    ...    log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_decrease_data}_egate
check bler and beamtype is correct in ttitrace step1
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_case1_few.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and beamtype is correct in ttitrace step2
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_case1_more.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and beamtype is correct in ttitrace step3
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_c1_muchmore.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and beamtype is correct in ttitrace step4
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_c1_decrease.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and beamtype is correct in ttitrace step5
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_DFP.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check bler and beamtype is correct in ttitrace step6
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/c17_2UE_R2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
Check BWP
	Airphone Cleanup Egate Console Log
	SA Register BWPUE 1
	${ue1_rnti}    Get SA '1' crnti in RRC log
    set suite variable     ${ue1_rnti}
    Step1 few dl data bwp2
	Step2 more dl data bwp1
	Step3 muchmore dl data bwp1
	Step4 decrease dl data
SA Register UE ${UE_ID}
	#Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible
	#airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
SA Register BWPUE ${UE_ID}
	Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start dl data
#    Airphone SA Start Data Traffic    ${UE_ID}   DL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   100M   pdu_id=${UE_ID2}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID3}   DL   100M   pdu_id=${UE_ID3}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID4}   DL   100M   pdu_id=${UE_ID4}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID5}   DL   100M   pdu_id=${UE_ID5}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID6}   DL   100M   pdu_id=${UE_ID6}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID7}   DL   100M   pdu_id=${UE_ID7}   duration=3600   trf_id=1
#	  Airphone SA Start Data Traffic    ${UE_ID8}   DL   100M   pdu_id=${UE_ID8}   duration=3600   trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID}   DL   100M   pdu_id=${UE_ID}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   100M   pdu_id=${UE_ID2}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID3}   DL   100M   pdu_id=${UE_ID3}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID4}   DL   100M   pdu_id=${UE_ID4}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID5}   DL   100M   pdu_id=${UE_ID5}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID6}   DL   100M   pdu_id=${UE_ID6}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID7}   DL   100M   pdu_id=${UE_ID7}   duration=3600   trf_id=2
	  Airphone SA Start Data Traffic    ${UE_ID8}   DL   100M   pdu_id=${UE_ID8}   duration=3600   trf_id=2
check throughput
    Wait '8s' for stabible
    Log To Console		=====tp=====
	${t1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
  ${t2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
  ${t3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pdsch    tput_type=ave
  ${t4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pdsch    tput_type=ave
  ${t5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=0    type=pdsch    tput_type=ave
  ${t6}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=0    type=pdsch    tput_type=ave
  ${t7}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=0    type=pdsch    tput_type=ave
  ${t8}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=0    type=pdsch    tput_type=ave
 	${t11}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
  ${t12}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=1    type=pdsch    tput_type=ave
  ${t13}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=1    type=pdsch    tput_type=ave
  ${t14}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=1    type=pdsch    tput_type=ave
  ${t15}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=1    type=pdsch    tput_type=ave
  ${t16}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=1    type=pdsch    tput_type=ave
  ${t17}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=1    type=pdsch    tput_type=ave
  ${t18}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=1    type=pdsch    tput_type=ave
	should be true    ${t1}+${t2}+${t3}+${t4}+${t5}+${t6}+${t7}+${t8}+${t11}+${t12}+${t13}+${t14}+${t15}+${t16}+${t17}+${t18}>960000
Set UE3 position1
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
check bler and beamtype is correct in ttitrace
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/4UE_RT.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
Send A1 event for UEs to add scell
    [Arguments]     ${ue_start}=1    ${ue_end}=8
    FOR    ${num}    IN RANGE    ${ue_start}    ${ue_end}+1
        airphone_execute_egate_command    ue_measurement_send_nr id\=${num} meas_id\=3 event\=A1 rs_type\=ssb srsrp_nr\=100
    END
    Wait '10s' for stable
#===========================SA======t2r4===================
test_SA_UE5_t2r4
	UE5_get_tti_buffer_lo_hi
	DeRegister UE from '5' to '5'
	deactive p5
	run keyword and continue on failure    check_G14_rdIncludeHighVolatileUe_single_UE
	...   ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1_case1/UE5_US1_case1_gnb.tar.gz
    ...   ${TEST_LOG_DIRECTORY()}/All/G14_case1_tti_UE5_to_WB_dl_split.csv
    ...   rdIncludeHighVolatileUe=1   numWbSrsConfigSample=5
    ...   rlqGoodPercentage=100   prbSampleHighLowPercentage=60

UE5_get_tti_buffer_lo_hi
	Log To Console   ${\n}--SA_t2r4---US1---buffer_lo_to_hi-----
	Start capture gnb and ap syslog in 'UE5_US1_case1' file
	airphone_cleanup_egate_console_log
	SA Register UE '5'
	Airphone Execute Egate Command    ${PROFILE5_31}
	Airphone Execute Egate Command    ${SET_PROFILE5}
	RANK'0'_CQI'15'_override_to_UE'5'_profile'5'
	DL and UL data to '5' for dl_trf '2'	# 2x165M
	Start collect ttitrace
	FOR    ${i}    IN RANGE    1    100
		Airphone Execute Egate Command    ${PROFILE5_31}
		Airphone Execute Egate Command    ${PROFILE5_13}
		Run Keyword If   ${i}==1 	RANK'3'_CQI'15'_override_to_UE'5'_profile'5'
    END
	Wait for '0s' to stop ttitrace with name'G14_case1_tti_UE5_to_WB'
	get_egate_log_UE'tti_UE5_to_WB'
	Stop capture gnb and ap syslog in 'UE5_US1_case1' file
	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from SA UE '5' to '5' with tp '330'
	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/G14_case1_tti_UE5_to_WB_dl.csv

copy_tti
	run keyword and continue on failure    check_SB_to_WB_tti   ${TEST_LOG_DIRECTORY()}/All/tti_UE5_buffer_lo_2_hi_dl_split.csv
	...    ${TEST_LOG_DIRECTORY()}/All/syslog_UE5_US1/UE5_US1_gnb.tar.gz   rdNumSrsCheck=10   rdSrsRlqGoodPercent=20   rdSrsBufPercent=60

	Set test Variable    ${tti_title_tag}		tti_UE5_buffer_lo_2_hi_dl.csv
	Set test Variable    ${ratio}    0.999
	run keyword and continue on failure     check_log_with_au2anlysis
	...    ini_path=${CURDIR}/ini/tti_dl_bler_ratio.ini    log_need_to_check=i   save_log_directory=${TEST_LOG_DIRECTORY()}/All/

Set UE5 P5
	Airphone Execute Egate Command    ${PROFILE5}
	Airphone Execute Egate Command    ${SET_PROFILE5}
Set UE5 power_bad
	Airphone Execute Egate Command    ${PROFILE5_power_bad}
	Airphone Execute Egate Command    ${SET_PROFILE5}
Set UE5 power_good
	Airphone Execute Egate Command    ${PROFILE5}
	#Airphone Execute Egate Command    ${SET_PROFILE5}
deactive p5
	Airphone Execute Egate Command    ${deactive_P5}
#===================end=====t2r4=================================
RANK1_4UE
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=4 cqi\=${cqi} cqi_mode\=fixed ri\=${rank} ri_mode\=fixed
	Airphone Execute Egate Command	ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id} scell\=${scell}
delete_Rank_override_UE'${ue_id}'
	Airphone Execute Egate Command	csi_override_testmode_nr profile_id\=${ue_id} delete\=true
get_egate_log_UE'${ue_id}'
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
get_tti_UE'${ue_id}'
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_${ue_id}'
	split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/tti_${ue_id}_dl.csv
#==========SA=======================
SA Register UE '${UE_ID}'
	Log To Console   ${\n}-----register UE ${UE_ID} ------
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible
SA Register UEs from ${lo} to ${hi}
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
	    #airphone_cleanup_egate_console_log
     	Log To Console   ${\n}-----register UE ${ue} ------
     	SA Register UE ${ue}
      Wait '1s' for stabible
      Airphone SA Start Data Traffic    ${ue}   DL   175M   pdu_id=${ue}   duration=3600   trf_id=1
      #airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}   unzip=TRUE
	 END
DeRegister UE from ${lo} to ${hi}
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END
#===========NSA======================
NSA Attach UE from '${lo}' to '${hi}'
	FOR    ${ue}    IN RANGE    ${lo}    ${hi}+1
	    Log To Console   ${\n}--Attach NSA UE ${ue} --
	#    airphone_cleanup_egate_console_log
		Airphone Nsa Attach     ${ue}    profile_id=None
		Wait '2s' for stabible
	#\	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue}_attach   unzip=TRUE
	END
check throughput from NSA UE '${low}' to '${hi}' with tp '${dl_cell_tp}'
    ${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		${pcell_tp}	Get cell dl throught	${num}    8
		${dl_tput_Mb}    evaluate    ${pcell_tp}/1000
		Log To Console    UE${num}_ul_tp ${dl_tput_Mb}M--
	   ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
	Log To Console		=====ul_cell_tp ${cell_tp_dl}=====
	run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

Dettach UE from '${low}' to '${hi}'
	FOR    ${num}    IN RANGE    ${low}    ${hi}+1
		Airphone NSA Detach    ue_id= ${num}
	   Wait '3s' for stabible
    END
Check SRS counter
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    Wait Throughput Timer    ${remaining_time}
    Wait Throughput Timer    180s
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
	FOR    ${i}    IN RANGE     178     203
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55371C00${index}    cell_id=1
	     append to list     ${value_list_level_cell_1}   ${value}
    END
    log     ${value_list_level_cell_1}
    #Capture ttitrace    ${save_log}
	${SINR_LEVEL_value_cell_1}    Evaluate    sum(${value_list_level_cell_1})
    should be true    ${SINR_LEVEL_value_cell_1} > 10000