*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
#Test Teardown    Common Test Teardown
Force Tags    owner_ning    AP    SBTS00    RAN_5G_TDD    RAN_5G    
...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8322_E4_case1_1cell.xml
${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_E4.xml
${WTS_NAME}    wts_8322_E4_SA_NSA_case1.cfg

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
${RRC_Attach}    rrc_attach
${RRC_data}    rrc_data
${BIP_TAG}      databip
${RRC_few_data}    fewdata
${RRC_more_data}    moredata
${RRC_muchmore_data}    muchmoredata
${RRC_decrease_data}    decreasedata			  
*** Test Cases ***
CB008322_E4_case001_Coexistence_with_multiple_BWP_BWP_change_base_DL_data_change
	#  Add RD
	Get and Update BSR File		par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
	Prepare gnb onair
	Start capture gnb and ap syslog in 'after_onair' file
	Airphone Cleanup Egate Console Log
	SA Register UE 1
	${ue1_rnti}    Get SA '1' crnti in RRC log
    set suite variable     ${ue1_rnti}
    Step1 few dl data bwp2
	Step2 more dl data bwp1
	Step3 muchmore dl data bwp1
	Step4 decrease dl data	
	Stop capture gnb and ap syslog in 'after_onair' file
*** Keywords ***
Step1 few dl data bwp2
    #Airphone Cleanup Egate Console Log
   #	Start collect bip log 
   # Start collect ttitrace
    Start few data to check bwp2
    Start collect bip log 
    Start collect ttitrace
  	Wait for '5s' to stop ttitrace with name'ttifewd'
	Wait for '0s' to stop bip log with name'bipfewd'
    Collect AP egate log    ${RRC_few_data}
	Check bwp2 setup in rrclog
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1            
Step2 more dl data bwp1
    Airphone Cleanup Egate Console Log
	#Start collect bip log 
#	Start collect ttitrace
    Start more data to check bwp1	
   	Start collect bip log 
	Start collect ttitrace
	Wait for '3s' to stop ttitrace with name'ttimored'
	Wait for '0s' to stop bip log with name'bipmored'
    Collect AP egate log    ${RRC_more_data}
    Check bwp1 setup in rrclog
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step2   
Step3 muchmore dl data bwp1
    Airphone Cleanup Egate Console Log
    Start muchmore data to check bwp1	
    Wait '2s' for stabible	
   	Start collect bip log 
	  Start collect ttitrace
	  Wait for '1s' to stop ttitrace with name'ttimuchmored'
  	Wait for '0s' to stop bip log with name'bipmuchmored'
    Collect AP egate log    ${RRC_muchmore_data}
	run keyword and continue on failure	   Wait Until Keyword Succeeds    60s    2s    check throughput
    run keyword and continue on failure    check bler and beamtype is correct in ttitrace step3  
check throughput
    Log To Console		=====tp=====
	${dl_throughput_pcell_sa}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
	run keyword and continue on failure    should be true    ${dl_throughput_pcell_sa}>=1090000 
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
Add RD
	#rdMinSrsUePeriodicity,default=80 slot(0x50)
	#Add GNB swconfig    0x5901E6:0x140
	#pdcch use best beam
	#Add GNB swconfig    0x580434:0
	#Add GNB swconfig    0x580556:0x834        #rdStartPatternId
	#Add GNB swconfig    0x5901EB:1      #rdForceEnablingWidebandTasSrs use
    #Add GNB swconfig    0x5805AE:1  
    #Add GNB swconfig     0x5805b0:80                                                                     
    #Add GNB swconfig     0x5805b1:80                                                                     
    #Add GNB swconfig     0x5805b2:50  
    #Add GNB swconfig    0x58076c:10
    #Add GNB swconfig    0x58076d:10  	
	#Add GNB swconfig    0x580763:2 
#==========SA=======================
SA Register UE ${UE_ID}
	Airphone_cleanup_egate_console_log
	Airphone SA Attach    ue_id=${UE_ID}
	Airphone Set Traffic Type    ${UE_ID}    ${UE_ID}    internal
	Airphone Pdu Session Setup   ${UE_ID}    ${UE_ID}    1    ${UE_ID}
	Wait '2s' for stabible	
	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${UE_ID}   unzip=TRUE
Start few data to check bwp2
    airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 cqi_mode\=fixed ri\=3 ri_mode\=fixed
    Airphone SA Start Data Traffic    ${UE_ID}   DL   50k   pdu_id=${UE_ID}   duration=3600   trf_id=1	
Start more data to check bwp1	
    Airphone SA Start Data Traffic    ${UE_ID}   DL   50M   pdu_id=${UE_ID}   duration=3600   trf_id=2
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


