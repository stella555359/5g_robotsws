*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown  #  Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown   # Common Test Teardown
Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G    
...   CLOUD_5G_I_BOO_AP_LOO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB008761_SCF_TFF.xml
${AIRPHONE_NAME}    iphy_CB008761_case1.xml
${WTS_NAME}    CB008761_case1.lua

@{LOG_NAME_LIST}    gnb_snapshot    ap_snapshot    egatelog    

${FILTER_f1ap}    (f1ap) && (nr-rrc.supportedSRS_TxPortSwitch)
@{titles_f1ap}    nr-rrc.supportedSRS_TxPortSwitch
${FILTER_1}    (dldata_pdcchsendreq) && !(3gpp.rnti == 65535)
${FILTER_2}    (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
${FILTER_3}    (dldata_csirssendreq) && (DlData_CsiRsResource_t.density == 1)
@{titles_1}    DlData_DciInfo.patternId_item
@{titles_2}    DlData_PdschGrant.patternId_item
@{titles_3}    DlData_CsiRsResource_t.patternId_item
&{GNBMIRRORINGCONFIGS}    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'
...   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'    NUMBER_OF_FILES=10
${UE_NUM}    4
${UE_ID}    1
${UE_ID2}    2
${UE_ID3}    3
${UE_ID4}    4
${RRC_Attach}    rrc_attach
${RRC_data}    rrc_data
${BIP_TAG}      databip
${RRC_few_data}    fewdata
${RRC_more_data}    moredata
${RRC_muchmore_data}    muchmoredata
${RRC_decrease_data}    decreasedata	
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 
...   test_type\=SRS multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1		 
${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbwvps) && !(3gpp.rnti == 65535)
@{title_srsreceivereq}   3gpp.sfn   3gpp.slot   3gpp.rnti   
...   UlData_srsBwvReportRequest_t.rho 
@{title_srsreceiverespbwvps}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item
@{title_all}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item    UlData_srsBwvReportRequest_t.rho
...   UlData_srsBwvReport_t.correlation_item  
*** Test Cases ***
CB008761-ET-L001_Activation of ML Engines and CB008761 with configuration plan file
    OperatingSystem.Run    sudo ip addr add 10.0.2.3/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.61/24 dev eth3
	Prepare gnb onair
	Start ErrWrn capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log
    change ue1 location
	SA Register UE 1
	Step1 muchmore dl data
	switch UE1 scell0 to cqi8 with profileid1
  switch UE1 scell0 to rank3 with profileid2
  switch UE1 scell0 to pathloss100 with profileid3
  switch UE1 scell0 to pmi10 with profileid4
  switch UE1 to phr40 with profileid5
   # Step2 stop and muchmore dl data again
	Stop ErrWrn capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
switch UE${UE_ID} to phr${PHR} with profileid${PROFILEID}
    airphone_execute_egate_command    
    ...   	phr_override_testmode_nr profile_id\=${PROFILEID} phr_mode\=fixed phr_start\=-23 phr_min\=-23 phr_max\=${PHR} phr_step_size\=1
    airphone_execute_egate_command  
    ...   	ue_testmode_set_nr id\=${UE_ID} phr_override\=phr action\=activate profile_id\=${PROFILEID}
	  Log To Console		=====ue${UE_ID} phr${PHR}=====     
switch UE${UE_ID} scell${SCELLID} to cqi${CQI} with profileid${PROFILEID}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${PROFILEID} cqi\=${CQI} cqi_mode\=fixed ri\=3 ri_mode\=fixed
    Wait '1s' for stabible
    airphone_execute_egate_command   
    ...   	ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${PROFILEID} scell\=${SCELLID}
    Wait '1s' for stabible
    Log To Console		=====ue${UE_ID} cqi${CQI} scell${SCELLID} =====
switch UE${UE_ID} scell${SCELLID} to rank${RANK} with profileid${PROFILEID}
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=${PROFILEID} cqi\=15 cqi_mode\=fixed ri\=${RANK} ri_mode\=fixed
    airphone_execute_egate_command   
    ...   	ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${PROFILEID} scell\=${SCELLID}	
	  Log To Console		=====ue${UE_ID} scell${SCELLID} rank${RANK}  =====
switch UE${UE_ID} scell${SCELLID} to pathloss${PATHLOSS} with profileid${PROFILEID}
    airphone_execute_egate_command    
    ...   	ul_sinr_testmode_nr profile_id\=${PROFILEID} pcmax\=33 pathloss\=${PATHLOSS} pusch_tx_power\=-851 srs_tx_power\=-851
    airphone_execute_egate_command    ue_testmode_set_nr id\=${UE_ID} testmode\=ul_sinr action\=activate profile_id\=${PROFILEID} scell\=${SCELLID}	
    Log To Console		=====ue${UE_ID} passloss${PATHLOSS} scell${SCELLID} =====
switch UE${UE_ID} scell${SCELLID} to pmi${PMI} with profileid${PROFILEID}
    airphone_execute_egate_command    
    ...   	csi_override_testmode_nr profile_id\=${PROFILEID} cqi_mode\=fixed cqi\=15 ri_mode\=fixed ri\=3 pmi_mode\=fixed pmi\=${PMI} 
    airphone_execute_egate_command  
    ...   	ue_testmode_set_nr id\=${UE_ID} testmode\=csi_override action\=activate profile_id\=${PROFILEID} scell\=${SCELLID}
	  Log To Console		=====ue${UE_ID} pmi${PMI} scell${SCELLID} =====
Keep position for time${TIME}
    Wait '${TIME}s' for stabible
	
Step2 stop and muchmore dl data again
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl 
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=1 dir\=dl 
    airphone_execute_egate_command    trf_data_stop ue\=3 pdu\=1 dir\=dl 
    Start muchmore data	
    run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
Step1 muchmore dl data
    Airphone Cleanup Egate Console Log
    Start muchmore data	
    Wait '2s' for stabible	
	  Start collect ttitrace
	  Wait for '1s' to stop ttitrace with name'ttimuchmored'
    Collect AP egate log    ${RRC_muchmore_data}
	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
    #run keyword and continue on failure    check bler and beamtype is correct in ttitrace 
check throughput
    Log To Console		=====tp=====
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000 
	${dl_throughput_pcell_sa2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
	${dl_throughput_pcell_sa3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
 	${dl_throughput_pcell_sa4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=100000
check bler and beamtype is correct in ttitrace                
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_c1_muchmore.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All


#==========SA=======================
change ue1 location
    airphone_execute_egate_command	  ue_change_location cell\=6 id\=1	
    #airphone_execute_egate_command	  ue_change_location cell\=6 id\=2
    #airphone_execute_egate_command	  ue_change_location cell\=6 id\=3	
    #airphone_execute_egate_command	  ue_change_location cell\=6 id\=4
SA Register UE 1 to 4
    SA Register UE ${UE_ID}
	SA Register UE ${UE_ID2}
	SA Register UE ${UE_ID3}
  SA Register UE ${UE_ID4}
SA Register UE ${UE_ID}
	Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    1    internal
	Airphone Pdu Session Setup   ${UE_ID}    1    1    ${UE_ID}
	Wait '2s' for stabible	
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start muchmore data
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1	
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3	
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=4
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=5
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=6
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2		
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3	
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=4
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=5
#    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=6
#    Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1	
#	Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#	Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3
#  Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=4
#  Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=5
#  Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=6
#  Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1	
#	Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
#	Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3
#  Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=4
#  Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=5
#  Airphone SA Start Data Traffic    ${UE_ID4}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=6
DL and UL data to '${UE_ID}' for dl_trf ${num}
    Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
    : FOR    ${i}    IN RANGE    1    ${num}+1
    \	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
    
    Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    Wait '4s' for stabible

check throughput from SA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
	${cell_tp_ul}	  evaluate	0
    : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
    \   Log To Console    Check throughput UE${num}
    \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
    \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    \      Log To Console		ul ${ul_tput_Mb}
    \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
    Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
    run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
    \   airphone_sa_detach    ue_id=${num}    timeout=5
    \   Wait '3s' for stabible

Analyse odftbeam in rrclog
	check_log_with_au2anlysis    ${CURDIR}/ini/odftbeam.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_Attach}_egate
		
UE '${num}' send RANK3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	


Send '${UE_NUM}' SA UE and data buffer sent
	: FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
    \   SA send mutiple trf dl data    ${num}    2    160M   ${num}
    #\   SA send mutiple trf ul data    ${num}    1    20M   ${num}

Get SA '${ue_id}' crnti in RRC log
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001    crnti: (\\d+)
    [return]     ${rnti_list[0]}

Set UE1 position1 to 3
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
	Airphone Execute Egate Command    ${SET_PROFILE2}
	Airphone Execute Egate Command    ${SET_PROFILE3}

Start dl data small
    Airphone SA Start Data Traffic    ${UE_ID}   DL   150M   pdu_id=${UE_ID}   duration=3600   trf_id=1
	Airphone SA Start Data Traffic    ${UE_ID}   DL   80M   pdu_id=${UE_ID}   duration=3600   trf_id=2
   # Airphone SA Start Data Traffic    ${UE_ID2}   DL   80M   pdu_id=${UE_ID2}   duration=3600   trf_id=1  
check bler and beamtype is correct in ttitrace step10                  
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/G7_step1.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	   
check throughput debug
    Wait '2s' for stabible
    Log To Console		==debug, if tp=0, check snapshot if "Ethernet link unstable" is env issue and report jira to ute cloud==
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=40000 	
