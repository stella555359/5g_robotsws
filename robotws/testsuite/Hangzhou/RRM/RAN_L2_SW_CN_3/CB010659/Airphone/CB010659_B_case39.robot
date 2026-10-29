*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     
...   CLOUD_5G_I_LO_AP_LOOO_SANSA_FS_ECPRI_CMWV_TDD
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***

${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      CB010659_case39_aplo.xml
${AIRPHONE_NAME}    IPHY_AEQE_3CELL_ABIO.xml
${WTS_NAME}    3cell_rank2.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${COMAVALUE}    ${CURDIR}/coma/case4.txt
${UE_TOTALNUM}    4
${UE_NUM}         2
${UE_ID}          1
${UE_ID2}          2
${UE_ID3}          3
${UE_ID4}          4
${UE_ID5}          5
${UE_ID6}          6
${UE_ID7}          7
${UE_ID8}          8
${SLICE_ID}       1
${X2_CMD}         enb_x2_link_up enb\=1 target\=2

@{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:400	   maxNumStreamPrbL1Sp:800	  maxNumWbStreamPrbL1Sp:800
@{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:800	   maxNumStreamPrbL1Sp:1600	  maxNumWbStreamPrbL1Sp:1600
${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 trigger_puxch_update\=0
${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0
${SET_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2

${deactive_PROFILE1}    ue_testmode_set_nr id\=11 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
${deactive_PROFILE2}    ue_testmode_set_nr id\=12 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
${SET_SAPROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
${SET_SAPROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
${SET_SAPROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
${SET_SAPROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
${SET_SAPROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
${SET_SAPROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
${deactive_SAPROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
${deactive_SAPROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
${deactive_SAPROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
${deactive_SAPROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
${deactive_SAPROFILE5}    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=5
${deactive_SAPROFILE6}    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=6
*** Test Cases ***
CB010659_B_case39_TDD_IWK_CB007113_I_UL_PRB_pooling
     Add RD param MCS20
     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
     Prepare gnb onair
     Start capture gnb and ap syslog in 'after_onair_nobler' file
     airphone_cleanup_egate_console_log
     Set multiue traffic type to internal
	 Attach 2ue to mumimocell and check pair
     run keyword and continue on failure     check throughput
	 change ue5to8 location
     Attach '2' ue to 5g cell2
     Internal send ue5to6 data 
     Attach '2' ue to 5g cell3
     Internal send ue7to8 data 	
     Internal resend data
	 trigger bler
     Start collect ttitrace    lcr_cell_id=1
	 Wait for '2s' to stop ttitrace with name'ue1ue2bler'
	 run keyword and continue on failure    check bler and pair in ttitrace
     run keyword and continue on failure    Get throughputbler
     Stop egate log and unzip with name'egate'	
	 Stop capture gnb and ap syslog in 'after_onair_nobler' file
                 

*** Keywords ***
Add RD param MCS20
	#rdActUlAdaptiveReTxResMcsWithMuMimo   
	#Add GNB swconfig	 0x58061A:1
	#rdSupportedUlMCS RAD param MCS=20
	Add GNB swconfig	 0x580010:0x100000

trigger bler
	Log To Console   ${\n}---trigger ul bler---
	#sinr=-460
	#Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=7 sinr_target_pusch\=-370
	#Airphone Execute Egate Command	ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=7 action\=activate
	Airphone Execute Egate Command	ul_sinr_testmode_nr profile_id\=8 sinr_target_pusch\=-340
	Airphone Execute Egate Command	ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=8 action\=activate 
	Wait '2s' for stabible
Prepare test
    #Active GNB L2 feature debug traces
    Modify l1bypass
    Modify 7113 Swconfig
Verify throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
    #${ul_throughput_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=1    type=pusch    tput_type=ave
    #${ul_throughput_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=1    type=pusch    tput_type=ave
    #${ul_throughput_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=2    type=pusch    tput_type=ave
    #${ul_throughput_pcell5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=2    type=pusch    tput_type=ave
    run keyword and continue on failure     should_be_true     ${ul_throughput_pcell}+${ul_throughput_pcell1}>180000
Get throughputbler
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=0    type=pusch    tput_type=ave
    ${ul_throughput_pcell5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=0    type=pusch    tput_type=ave
    #run keyword and continue on failure     should_be_true     ${ul_throughput_pcell}+${ul_throughput_pcell1}>100000
Check throughput
    Wait until keyword succeeds    60s    5s    Verify throughput
Check throughputbler
    Wait until keyword succeeds    60s    5s    Verify throughputbler    
Internal send data
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        Airphone SA Start Data Traffic    ${num}    UL    100M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
        Airphone SA Start Data Traffic    ${num}    DL    10M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}    
        Wait '5s' for stabible	
    END
Internal resend data
    #FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
    #    Airphone SA Start Data Traffic    ${num}    UL    60M    pdu_id=${num}    duration=6000s
    #    ...    trf_id=${num}
    #    Airphone SA Start Data Traffic    ${num}    DL    10M    pdu_id=${num}    duration=6000s
    #    ...    trf_id=${num}    
    #    Wait '5s' for stabible	
    Airphone SA Start Data Traffic    1    UL    50M    pdu_id=1   duration=6000s
        ...    trf_id=1  
    Wait '3s' for stabible	 
Internal send ue5to8 data 
    FOR    ${num}    IN RANGE    5    ${UE_NUM}+7
        Airphone SA Start Data Traffic    ${num}    UL    175M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
    END
    #    Wait '5s' for stabible	
Internal send ue5to6 data 
    FOR    ${num}    IN RANGE    5    ${UE_NUM}+5
        Airphone SA Start Data Traffic    ${num}    UL    100M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
        Airphone SA Start Data Traffic    ${num}    DL    5M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}    
    END
    #    Wait '5s' for stabible		
Internal send ue7to8 data 
    FOR    ${num}    IN RANGE    7    ${UE_NUM}+7
        Airphone SA Start Data Traffic    ${num}    UL    100M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}
        Airphone SA Start Data Traffic    ${num}    DL    5M    pdu_id=${num}    duration=6000s
        ...    trf_id=${num}   
    END
    #    Wait '5s' for stabible		

Modify 7113 Swconfig
   Add AP swconfig    0x1003F:2
   Add AP swconfig    0x10042:0xC0A8C87E
   #Add GNB swconfig    0x420068:6 # rdTddPoolingFeaturesEnable
   Add GNB swconfig    0x580612:1
   Add GNB swconfig    0x340000:15 
   #Add GNB swconfig    0x58054D:8
   #enable ADMIN developer
   Add GNB swconfig     0x450027:1
   #Admin developement account
    Add GNB swconfig     0x45000A:1
	
Attach 2nsaue to mumimocell and check tti
    Attach '2' nsaue to 5g cell
	Set ue12 position
    #NSA send few data 2NSAUE
	#Start collect ttitrace
	#Wait for '2s' to stop ttitrace with name'notpairtti'
	#run keyword and continue on failure     check bler and nopair in ttitrace	
Attach 2ue to mumimocell and check pair	
    Attach '2' ue to 5g cell
    Set saue12 position
    Internal send data
	 Start collect ttitrace
	 Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure     check pair in ttitrace	
Send more data nsaue and check tti

	NSA send data 2NSAUE
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure     check bler and pair in ttitrace	
Send more data and check tti

	Internal send data
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure     check bler and pair in ttitrace			
Attach '${uenum}' ue to 5g cell
    FOR    ${num}    IN RANGE    1    ${uenum}+1
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
        Wait '3s' for stabible	
    END
Attach '${uenum}' nsaue to 5g cell
    airphone_cleanup_egate_console_log
    airphone_execute_egate_command    ${X2_CMD}
    Airphone Nsa Attach    11
    Airphone Nsa Attach    12
Attach '4' ue to 5g cell2 and cell3
    FOR    ${num}    IN RANGE    5    ${uenum}+7
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
    END
Attach '2' ue to 5g cell2
    FOR    ${num}    IN RANGE    5    ${uenum}+5
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}	
    END
Attach '2' ue to 5g cell3
    FOR    ${num}    IN RANGE    7    ${uenum}+7
        Airphone SA Attach    ue_id=${num}
        Wait '2s' for stabible
        Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}		
    END
Set multiue traffic type to internal
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+7
        Airphone Set Traffic Type    ${num}    ${num}    internal
    END
NSA send data 2NSAUE
    airphone_execute_egate_command     trf_data_start ue\=11 id\=2 dir\=ul mbps\=170 trf_id\=1
    airphone_execute_egate_command     trf_data_start ue\=12 id\=2 dir\=ul mbps\=170 trf_id\=1
	  airphone_execute_egate_command     trf_data_start ue\=11,12 id\=2 dir\=dl mbps\=10 trf_id\=1
UE from '${lo}' to '${hi}' SA Register and check 
    FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
       airphone_cleanup_egate_console_log
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
check pair in ttitrace                   
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_CB007113_case3.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	  run keyword and continue on failure    7113_check_file.check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/tti_ul.csv       50      19			
 	
check initretransbler and pair is correct in ttitrace                    
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check retransbler and pair is correct in ttitrace                    
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2re.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
check port is correct in ttitrace    
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2_port.ini    log_need_to_check=i    
	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
change ue5to8 location
    airphone_execute_egate_command	  ue_change_location cell\=2 id\=5	
    airphone_execute_egate_command	  ue_change_location cell\=2 id\=6
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=7	
    airphone_execute_egate_command	  ue_change_location cell\=3 id\=8

check bler and pair in ttitrace                    
    run keyword and continue on failure    7113_check_file.check_7113_cell_rachslot     ${TEST_LOG_DIRECTORY()}/All/ue1ue2bler_ul.csv 
	...    50      19			
	Log To Console   ${\n}---check tti----
	#Set test Variable    ${tti_title_tag}	  ue1ue2bler_ul.csv
	Set test Variable    ${reserved_MCS}	31
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_CB007113_case3_bler.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All		
Set ue position
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
    Wait '2s' for stabible
deactive profile12
	Airphone Execute Egate Command    ${deactive_SAPROFILE1}
	Airphone Execute Egate Command    ${deactive_SAPROFILE2}
 	#Airphone Execute Egate Command    ${deactive_SAPROFILE3}
	#Airphone Execute Egate Command    ${deactive_SAPROFILE4}
 #	Airphone Execute Egate Command    ${deactive_SAPROFILE5}
#	Airphone Execute Egate Command    ${deactive_SAPROFILE6}
Set saue12 position
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_SAPROFILE1}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_SAPROFILE2}
Set saue56 position      
    Airphone Execute Egate Command    ${PROFILE3}    
    Airphone Execute Egate Command    ${SET_SAPROFILE3}  
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE4}
    Airphone Execute Egate Command    ${SET_SAPROFILE4}
Set saue78 position      
    Airphone Execute Egate Command    ${PROFILE5}
    Airphone Execute Egate Command    ${SET_SAPROFILE5}
    Wait '2s' for stabible
    Airphone Execute Egate Command    ${PROFILE6}
    Airphone Execute Egate Command    ${SET_SAPROFILE6}       
Online change actAdaptiveReTxResMcs to ${value}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actAdaptiveReTxResMcs    ${value}    online
    TAF_ADMIN.teardown admin    connection=online
    Wait '10s' for stabible
Online change actAdaptiveReTxResMcsEnh to ${value}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1   actAdaptiveReTxResMcsEnh    ${value}    online
    TAF_ADMIN.teardown admin    connection=online
    Wait '10s' for stabible	
