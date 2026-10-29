*** Settings ***
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
${SCFC_NAME}      SCFC_11117_E2_case4.xml
${AIRPHONE_NAME}    IPHY_AEHC_11117_E2_case4.xml
${WTS_NAME}    wts_1117_E2_case4.cfg

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
${RRC_Attach}    rrc_attach
${RRC_data}    rrc_data
${BIP_TAG}      databip
${RRC_few_data}    fewdata
${RRC_more_data}    moredata
${RRC_muchmore_data}    muchmoredata
${RRC_decrease_data}    decreasedata	
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=0 zenith\=0 srs_transmit_power_per_port\=-350,-350,-350,-350
${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1		
${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1	
${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1	 
${filter_csv}   (uldata_srsreceivereq||uldata_srsreceiverespbwvps) && !(3gpp.rnti == 65535)
@{title_srsreceivereq}   3gpp.sfn   3gpp.slot   3gpp.rnti   
...   UlData_srsBwvReportRequest_t.rho 
@{title_srsreceiverespbwvps}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item
@{title_all}	3gpp.sfn   3gpp.slot   3gpp.rnti   UlData_srsBwvReport_t.sinr_item    UlData_srsBwvReportRequest_t.rho
...   UlData_srsBwvReport_t.correlation_item  
*** Test Cases ***
CB011117_E2_case004_Multi_UE_testing
    Add RD
 	Wts Execute Aashell Command   
	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
	Get and Update BSR File		par_of_bsr_name=BSR_AEHC_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log
	SA Register UE 1 to 3
    Set UE1 position1 to 3
	Step1 muchmore dl data
  Step2 stop and muchmore dl data again
	Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
Step2 stop and muchmore dl data again
    airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 dir\=dl 
    airphone_execute_egate_command    trf_data_stop ue\=2 pdu\=2 dir\=dl 
    airphone_execute_egate_command    trf_data_stop ue\=3 pdu\=3 dir\=dl 
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
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace 
check throughput
    Log To Console		=====tp=====
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=300000 
	${dl_throughput_pcell_sa2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=300000
	${dl_throughput_pcell_sa3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=300000
check bler and beamtype is correct in ttitrace                
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/E_c1_muchmore.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Add RD
	Add GNB swconfig     0x590287:1 
	Add GNB swconfig     0x59026A:1
	Add GNB swconfig     0x590284:1
    Add GNB swconfig     0x800098:1
#==========SA=======================
SA Register UE 1 to 3
    SA Register UE ${UE_ID}
	SA Register UE ${UE_ID2}
	SA Register UE ${UE_ID3}
SA Register UE ${UE_ID}
	Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible	
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start muchmore data
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=1	
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=2
    Airphone SA Start Data Traffic    ${UE_ID}   DL   175M   pdu_id=${UE_ID}   duration=3600   trf_id=3	
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=4
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=5		
    Airphone SA Start Data Traffic    ${UE_ID2}   DL   175M   pdu_id=${UE_ID2}   duration=3600   trf_id=6	
    Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID3}   duration=3600   trf_id=7	
	Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID3}   duration=3600   trf_id=8
	Airphone SA Start Data Traffic    ${UE_ID3}   DL   175M   pdu_id=${UE_ID3}   duration=3600   trf_id=9


DL and UL data to '${UE_ID}' for dl_trf ${num}
    Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
    FOR    ${i}    IN RANGE    1    ${num}+1
    	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${i}  
    END
    
    Airphone SA Start Data Traffic    ${UE_ID}   UL   50M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    Wait '4s' for stabible

check throughput from SA UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
	${cell_tp_ul}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
          ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
          Log To Console		ul ${ul_tput_Mb}
          ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
    END
    Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
    run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

Analyse odftbeam in rrclog
	check_log_with_au2anlysis    ${CURDIR}/ini/odftbeam.ini    p    save_log_directory=${TEST_LOG_DIRECTORY()}/All/${RRC_Attach}_egate
		
UE '${num}' send RANK3
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=2 ri_mode\=fixed
    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=csi_override action\=activate profile_id\=1 scell\=0	


Send '${UE_NUM}' SA UE and data buffer sent
	FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
       SA send mutiple trf dl data    ${num}    2    160M   ${num}
    END
    #   SA send mutiple trf ul data    ${num}    1    20M   ${num}

Get SA '${ue_id}' crnti in RRC log
    Log To Console   check UE RRC log to get all ue crnti
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001    crnti: (\\d+)
    [return]     ${rnti_list[0]}

Set UE1 position1 to 3
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
	Airphone Execute Egate Command    ${SET_PROFILE2}
	Airphone Execute Egate Command    ${SET_PROFILE3}
Step9 send data to wb low chal low T1 0dot01 mode0 
    Airphone Cleanup Egate Console Log
    Execute Aashell Command    rad -mw 0x58077d 90		#rdWbSrsVolatCorrThreshold,default=0.9
    Start collect bip log 
    Start collect ttitrace
  	Wait for '1s' to stop ttitrace with name'ttilowT1'
	Wait for '0s' to stop bip log with name'biplowT1'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biplowT1/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/biplowT1/biplowT1.csv    ${filter_csv}    ${title_all}
	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttilowT1_dl.csv
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_low_0dot01.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biplowT1	
Step10 high_chnl_volatilen high T1 0dot01 mode0	
    Airphone Cleanup Egate Console Log
    Execute Aashell Command    rad -mw 0x58077d 100		#rdWbSrsVolatCorrThreshold,default=0.9
	Start collect bip log 
    Start collect ttitrace
    	Start dl data small
	Wait for '1s' to stop ttitrace with name'ttihighT1'
	Wait for '0s' to stop bip log with name'biphighT1'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/biphighT1/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/biphighT1/biphighT1.csv    ${filter_csv}    ${title_all}	
	run keyword and continue on failure    split_8322_tti  	${TEST_LOG_DIRECTORY()}/All/ttihighT1_dl.csv
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_high_0dot01_mod0.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/biphighT1	
G7 mod0
   run keyword and continue on failure    Step10 high_chnl_volatilen high T1 0dot01 mode0
   run keyword and continue on failure    Step9 send data to wb low chal low T1 0dot01 mode0
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
