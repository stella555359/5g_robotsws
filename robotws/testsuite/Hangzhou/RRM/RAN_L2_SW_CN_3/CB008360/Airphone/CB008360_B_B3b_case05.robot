*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_zhang		SBTS23R1
...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_8360_B_case5_1208_100M.xml
${AIRPHONE_NAME}    IPHY_AEQB_1CELL_2subcell_case5.xml

${L1BYP_XML}    L1By_8360_B_case5.xml	
${WTS_NAME}    wts_8360_B_case5.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
&{GNBMIRRORINGCONFIGS}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
...    NUMBER_OF_FILES=30
${FILTER_2}    (uldata_puschreceivereq) && !(3gpp.rnti == 65535)
@{titles_2}    3gpp.sfn	  3gpp.slot	3gpp.rnti   UlData_puschReceiveReqGrant_t.numOfLayers	3gpp.subcellid	UlData_puschReceiveReqGrant_t.pairedUe
...	UlData_puschReceiveReqGrant_t.numOfPrb		UlData_puschReceiveReqGrant_t.startPrb		UlData_eCpriConfigStruct_t.patternId_item
...	UlData_eCpriFcpSectionConfig_t.fcpAddPatternId_item

*** Test Cases ***
CB008360_B_B3b_case05_four_rank1_Ues_Max_4Layer_with_retransmission_without_tapering
	Upload airphone l1bypass to iphy
	Add RD param
	Prepare gnb onair
	
	check no bler before bler testmode US1	
	trigger ul bler 4 rank1 UE
	
	check no bler before bler testmode US2
	trigger ul bler rank1 and rank2
	
	check no bler before bler testmode US3
	trigger ul bler 2 rank2
	
	test_rdUlMuReceiverBeamUsedOverlappingPRB_in_MUreceiver
	
*** Keywords ***
Add RD param
#rdUlMuReceiverBeamUsedOverlappingPRB
	Add GNB swconfig	 0x58058c:1
check tti no bler
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti'
	
	Log To Console   ${\n}---check tti---
	Set test Variable    ${tti_title_tag}		tti_ul.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

check no bler before bler testmode US1
	UE from '1' to '4' SA Register and check
	run keyword and continue on failure		check tti no bler
	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '1' to '4' with tp '280'
	DeRegister UE from '1' to '4'

#1
trigger ul bler 4 rank1 UE
	Log To Console   ${\n}<<US1-----UE1234_bler_SA_R11----->>
	Start capture gnb and ap syslog in '1' file	
	UE from '1' to '4' SA Register and check
	
	Log To Console   ${\n}---trigger ul bler: 4 rank1 UE---
	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=500,500
	Start collect ttitrace
	airphone_execute_egate_command	ue_testmode_set_nr id\=1,2 scell\=0 testmode\=bler profile_id\=1 action\=activate
	airphone_execute_egate_command	ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=1 action\=activate
	airphone_execute_egate_command	ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=1 action\=activate
	Wait for '2s' to stop ttitrace with name'tti_UE1234_bler_SA_R11'
	airphone_execute_egate_command	ue_testmode_set_nr id\=1-4 scell\=0 testmode\=bler profile_id\=1 action\=deactivate

	DeRegister UE from '1' to '4'
	Stop capture gnb and ap syslog in '1' file
	Log To Console   ${\n}---check tti---
	Set test Variable    ${tti_title_tag}		tti_UE1234_bler_SA_R11_ul.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_234UE.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

check no bler before bler testmode US2
	UE from '4' to '5' SA Register and check
	run keyword and continue on failure		check tti no bler
	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '4' to '5' with tp '210'
	DeRegister UE from '4' to '5'
	
#2
trigger ul bler rank1 and rank2 
	Log To Console   ${\n}<<US3-----UE45_bler_SA_R12----->>
	Start capture gnb and ap syslog in '2' file	
	UE from '4' to '5' SA Register and check
	
	Log To Console   ${\n}---trigger ul bler: rank1 + rank2 :UE4,5---
	airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=400,400	
	Wait '1s' for stabible	
	airphone_execute_egate_command	ue_testmode_set_nr id\=4,5 scell\=0 testmode\=bler profile_id\=1 action\=activate
	Wait '1s' for stabible	
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_UE45_bler_SA_R12'	
	airphone_execute_egate_command	ue_testmode_set_nr id\=4,5 scell\=0 testmode\=bler profile_id\=1 action\=deactivate
	DeRegister UE from '4' to '5'
	Stop capture gnb and ap syslog in '2' file

	Log To Console   ${\n}---check tti---
	Set test Variable    ${tti_title_tag}	tti_UE45_bler_SA_R12_ul.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_rank12.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

check no bler before bler testmode US3
	UE from '5' to '6' SA Register and check
	run keyword and continue on failure		check tti no bler
	run keyword and continue on failure 	Wait Until Keyword Succeeds    30s    2s   check throughput from UE '5' to '6' with tp '280'
	DeRegister UE from '5' to '6'

#3
trigger ul bler 2 rank2	
	Log To Console   ${\n}<<US4-----UE56_bler_SA_R22----->>
	Start capture gnb and ap syslog in '3' file	
	UE from '5' to '6' SA Register and check	

	airphone_execute_egate_command	bler_testmode_nr profile_id\=2 ul_bler\=400,400
	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=2 action\=activate
	Wait '1s' for stabible	
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_UE56_bler_SA_R22'	
	airphone_execute_egate_command	ue_testmode_set_nr id\=5,6 scell\=0 testmode\=bler profile_id\=2 action\=deactivate
	DeRegister UE from '5' to '6'
	Stop capture gnb and ap syslog in '3' file
	
	Log To Console   ${\n}---check tti---
	Set test Variable    ${tti_title_tag}	tti_UE56_bler_SA_R22_ul.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_rank22.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

UE from '${lo}' to '${hi}' SA Register and check
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}--register UE ${num} --
       Airphone SA Attach    ue_id=${num}
       #set_pdu_param ue=1 pdu=1 trf_type=internal
       #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '3s' for stabible
       UL data to '${num}'
    #   get UE '${num}' rnti in RRC log
	END

get UE '${ue_id}' rnti in RRC log
    Log To Console   ${\n}===get UE'${ue_id}' rnti===
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE

    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
    run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
    run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
    run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
    run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
    run keyword if    ${ue_id}==5   Set test Variable	 ${rnti_5} 	${rnti_list[0]}
    run keyword if    ${ue_id}==6   Set test Variable	 ${rnti_6} 	${rnti_list[0]}
UL data to '${UE_ID}'  
    Airphone SA Start Data Traffic    ${UE_ID}    UL   150M   pdu_id=${UE_ID}   duration=7200   trf_id=1
    Wait '4s' for stabible
    ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave   
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}

#check throughput
check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
	Wait '3s' for stabible
	${cell_tp_ul}	  evaluate	0
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       Log To Console    Check throughput UE${num}
          ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
          ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
          Log To Console		ul ${ul_tput_Mb}    
          ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
    END
    Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
    run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}

DeRegister UE from '${low}' to '${hi}'
    FOR    ${num}    IN RANGE    ${low}    ${hi}+1
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible
    END

#5
test_rdUlMuReceiverBeamUsedOverlappingPRB_in_MUreceiver
    #UE3,UE4 are in MU receiver(in one subcell)UE3 will have additional patternid=UE4's 2nd best patternid.
    #If this RD parameter is set to true, the beam of unused prb for UE with smaller prb in the MU-IRC receiver will
    #set as 2nd best beam of UE with larger prb. If this RD parameter is set to false, the beam of unused prb for
    #UE with smaller prb in the MU-IRC receiver will set as 1st best beam of UE with smaller prb.
	Log To Console   ${\n}<<US5-----rdUlMuReceiverBeamUsedOverlappingPRB--rank1x2_rank2x1--->>
	UE from '3' to '5' SA Register and check_1

	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti_UE345_R112'

	#get big PRB UE4's 2ndBestBeam
    ${val}    read_csv_columns    ${TEST_LOG_DIRECTORY()}/All/tti_UE345_R112_ul.csv
    ...     rnti    ulBeamData.ulSrsBm2ndBestBeamPatternId    filter=rnti=${rnti_4}
    ${UE4_2nd_patternid_str}    set variable    ${val}[1][0]
    ${UE4_2nd_patternid}    Evaluate    int(${UE4_2nd_patternid_str})
    Log To Console   ${\n}---UE4_2nd_patternid_${UE4_2nd_patternid}---

    ${val_1}    read_csv_columns    ${TEST_LOG_DIRECTORY()}/All/tti_UE345_R112_ul.csv
    ...     rnti    ulBeamData.ulSrsBm2ndBestBeamPatternId    filter=rnti=${rnti_3}
    ${UE3_2nd_patternid_str}    set variable    ${val_1}[1][0]
    ${UE3_2nd_patternid}    Evaluate    int(${UE3_2nd_patternid_str})
    Log To Console   ${\n}---UE3_2nd_patternid_${UE3_2nd_patternid}---

	Start collect bip log
    Wait for '1s' to stop bip log with name'BIP'
    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP/tcpdump_L2L1_bip_filtering_off.pcap00
    ...    ${TEST_LOG_DIRECTORY()}/All/BIP/bip_pusch.csv    ${FILTER_2}    ${titles_2}

    DeRegister UE from '3' to '5'

#though UE3 has smaller ul data, but UE3 not always has smaller PRB.
#so when UE3 has smaller PRB, UE3 will has additional patternid= UE4's 2nd patternid.
#so when UE4 has smaller PRB, UE4 will has additional patternid= UE3's 2nd patternid.
	Log To Console   ${\n}---check bip_pusch---
	Set test Variable    ${tti_title_tag}		${TEST_LOG_DIRECTORY()}/All/BIP/bip_pusch.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_PRBoverlapping.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

UE from '${lo}' to '${hi}' SA Register and check_1
	FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
	   airphone_cleanup_egate_console_log
	   Log To Console   ${\n}--register UE ${num} --
	   Airphone SA Attach    ue_id=${num}
	  #set_pdu_param ue=1 pdu=1 trf_type=internal
	  #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
	   Airphone Set Traffic Type    ${num}    ${num}    internal
	   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
	   Wait '3s' for stabible
	   UL data to '${num}'_1
	   get UE '${num}' rnti in RRC log
	END

UL data to '${UE_ID}'_1
    run keyword if   ${UE_ID}==3		 Airphone SA Start Data Traffic    ${UE_ID}    UL   30M   pdu_id=${UE_ID}   duration=7200   trf_id=1
    run keyword if   ${UE_ID}==4		 Airphone SA Start Data Traffic    ${UE_ID}    UL   35M   pdu_id=${UE_ID}   duration=7200   trf_id=1
    run keyword if   ${UE_ID}==5		 Airphone SA Start Data Traffic    ${UE_ID}    UL   70M   pdu_id=${UE_ID}   duration=7200   trf_id=1
    Wait '4s' for stabible
    ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
