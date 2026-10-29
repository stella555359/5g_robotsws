# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G   owner_yuqq
# ...   CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}    SCFC_CB007113_case5.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_3CELL.xml
# ${L1BYP_XML}    L1By_7113_I_case789.xml	
# ${WTS_NAME}    wts_7113_I_3.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${NSA_UE_NUM}         3
# ${UE_NUM}        6
# ${UE_ID1}          1
# ${UE_ID2}          2
# ${EGATE_TAG}      MUmimo
# ${BIP_TAG}    mumumo_bip
# ${tti_tag}    ttitrace
# ${sys_tag}    sys
# ${tti_bler}   startdlber
# ${tti_stopbler}    stopdlbler
# @{VENDOR_PARAMETER_C32}	maxNumLayerPrbL1Sp:230	   maxNumStreamPrbL1Sp:460	  maxNumWbStreamPrbL1Sp:460
# @{VENDOR_PARAMETER_C64}	maxNumLayerPrbL1Sp:460	   maxNumStreamPrbL1Sp:920	  maxNumWbStreamPrbL1Sp:920
# 
# *** Test Cases ***
# CB007113_I_2_case5_MUMIMO_3layers_with_UL_PRB_pooling_activated_3rank1ue_with_retran
#     Upload airphone l1bypass to iphy
# 	Add RD param
# #   Active GNB L2 feature debug traces	
# #	Prepare gnb onair
# 	Modify vendor file and full commission for onair
# 
# 	Execute AP Command before attach
#     Start capture gnb and ap syslog in '${sys_tag}' file
#     Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     Wait '25s' for stable
# 	
# 	UE send ul bler
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti1'
# 	
#     Attach UE '1' to cell '2'
#     Attach UE '2' to cell '3'
# 	
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti2'
# 
#     Attach UE '3' to cell '2'
#     Attach UE '4' to cell '3'
# 
#     Start collect ttitrace
#     Wait for '3s' to stop ttitrace with name'tti3'
# 	
# #	run keyword and continue on failure 	check pair in ttitrace
# 	
# 	Airphone NSA Stop Data Traffic And Detach UE
#     Stop capture gnb and ap syslog in '${sys_tag}' file
# 
# 	
# *** Keywords ***
# Prepare test
# #    Active GNB L2 feature debug traces
#     Modify l1bypass
#     Add RD param
# 
# Add RD param
# 	Add GNB swconfig	 0x420068:6
# 	#act inter subpool
# 	Add GNB swconfig	 0x580612:1
# 
# 	#enable ADMIN developer
# 	Add GNB swconfig	 0x450027:1
# 	# Admin developement account
# 	Add GNB swconfig	 0x45000A:1
# 	Add GNB swconfig    0x340000:15
# 
# 	#enable AP log
# 	Add AP swconfig    0x1003F:2
# 	Add AP swconfig    0x10042:0xC0A8C87E
# 
# 
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
#     ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|16|//ComaMultiplier
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex24}    ${Vindex9}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex9}    ${Vindex8}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex12}    ${Vindex6}    ${Hindex8}    ${Vindex3}
#     ...    ${Hindex8}    ${Vindex3}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex10}    ${Vindex9}    ${Hindex9}    ${Vindex8}
#      ...    ${Hindex24}    ${Vindex9}    ${Hindex24}    ${Vindex9}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex17}    ${Vindex6}
#     ...    ${Hindex17}    ${Vindex6}    ${Hindex0}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=2    p2_rank=2    p1_sinr=33    p2_sinr=33
#     ...    extra_modify=${extra_modify}
# 
# check pair in ttitrace                   
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_CB007113_case3_bler.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti1_ul.csv       50      19	
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti2_ul.csv       50      19
# 	7113_check_file.Check 7113 Cell Rachslot     ${TEST_LOG_DIRECTORY()}/All/tti3_ul.csv       50      19	
# 	
# UE send ul bler
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 ul_bler\=400,400
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=8 testmode\=bler profile_id\=1 action\=activate id\=15
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=8 testmode\=bler profile_id\=1 action\=activate id\=16
#     airphone_execute_egate_command    ue_testmode_set_nr scell\=8 testmode\=bler profile_id\=1 action\=activate id\=17
# 	
# Execute AP Command before attach
#     airphone_cleanup_egate_console_log
#     Airphone Setup X2 Connection
# 
# Attach '${NSA_UE_NUM}' NSA UE and data buffer sent
#     : FOR    ${num}    IN RANGE    15    ${NSA_UE_NUM}+15
#     \   airphone_cleanup_egate_console_log
#     \   Airphone Nsa Attach    ${num}    profile_id=None
#     \   Wait '3s' for stabible
#     \   Collect AP egate log    ${EGATE_TAG}_${num}
# #    \   run keyword and continue on failure     check_SRS_resource_and_PDSCH_scramblingID   ${EGATE_TAG}_${num}
# #    \   NSA send ue '${num}' mutiple trf '5' for each '150M' DL data
#     \   NSA send ue '${num}' mutiple trf '1' for each '15M' UL data
# 
# Airphone NSA Stop Data Traffic And Detach UE
#     : FOR    ${num}    IN RANGE    15    ${NSA_UE_NUM}+15
#     \    Airphone NSA Stop Data Traffic   ${num}    BI
#     \    Airphone NSA Detach    ${num}
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
# 
# Attach UE '${ue_id}' to cell '${cell_id}'
#     airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
#     Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
#     Wait '3s' for stabible
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=2
#     #Airphone SA Start Data Traffic    ${ue_id}    DL   50M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${ue_id}    scell_id=0    type=pusch    tput_type=ave
# Attach Rank2 UE and Rank1 UE to cell1
#     Attach UE '1' to cell '1'
#     Attach UE '5' to cell '1'
#     Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti1'
# 
# Attach UE3 and UE4 to cell2 and cell3
#     Attach UE '6' to cell '2'
#     Attach UE '7' to cell '3'
# 
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=5    scell_id=0    type=pusch    tput_type=ave
#     Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti2'
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
# test_BG_UE
# 	Start capture gnb and ap syslog in '1' file
# 	Bachgroud UE '8' SA Register to cell '2' 
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_BG_UE8_cell2'
#      Stop capture gnb and ap syslog in '1' file
#      
# 	Bachgroud UE '9' SA Register to cell '3' 
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_BG_UE8_cell2_UE9_cell3'
# Internal send data
#     : FOR    ${num}    IN RANGE    1    3
#     \    Airphone SA Start Data Traffic    ${num}    UL    160M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     #\    Wait '5s' for stabible
# #1
# test_4_rank1_2_backgroud_UE
# 	Log To Console   ${\n}<<----test_4_rank1_2_backgroud_UE----->>
# 	UE from '1' to '4' SA Register and check
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '4' with tp '397'
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_UE1234_before_BG'
#      run keyword and continue on failure 	check tti'tti_UE1234_before_BG' no bler
#      Start capture gnb and ap syslog in '1' file
# 	Bachgroud UE '8' SA Register to cell '2' 
# 	Bachgroud UE '9' SA Register to cell '3' 
# 	Bachgroud UE '10' SA Register to cell '3'
# 	Stop capture gnb and ap syslog in '1' file
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '4' with tp '426'
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '8' to '8' with tp '74'
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    10s    2s   check throughput from UE '9' to '10' with tp '192'
# 	
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_after_BG_UE_attach'
#      run keyword and continue on failure 	check tti'tti_after_BG_UE_attach' no bler
#          
# 	DeRegister UE from '8' to '10'
# 	run keyword and continue on failure 	Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '4' with tp '397'
# 	Start collect ttitrace
#      Wait for '2s' to stop ttitrace with name'tti_detach_BG_UE'
#      run keyword and continue on failure 	check tti'tti_detach_BG_UE' no bler
#      
# 	DeRegister UE from '1' to '4'
# 	
# 	#Set test Variable    ${tti_title_tag}		tti_UE1234_ul.csv
# 	#run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_case5_simple_reTx_pair_2UE.ini     i
#     #...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# UE from '${lo}' to '${hi}' SA Register and check 
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}--register UE ${num} --
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '3s' for stabible
#     \   UL data to '${num}'
#     #\   get UE '${num}' rnti in RRC log
# 
# Bachgroud UE '${ue_id}' SA Register to cell '${cell_id}'      
#     Log To Console   ${\n}--register UE ${ue_id} to cell${cell_id} --
#     
#     airphone_execute_egate_command	ue_change_location cell\=${cell_id} id\=${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     #set_pdu_param ue=1 pdu=1 trf_type=internal
#     #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     Airphone Set Traffic Type    ${ue_id}    ${ue_id}    internal
#     Airphone Pdu Session Setup   ${ue_id}    ${ue_id}    1    ${ue_id}
#     Wait '3s' for stabible
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${ue_id}    UL   160M   pdu_id=${ue_id}   duration=7200   trf_id=2
#     #Airphone SA Start Data Traffic    ${ue_id}    DL   50M   pdu_id=${ue_id}   duration=7200   trf_id=1
#     Wait '3s' for stabible  
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${ue_id}    0    type=pusch    tput_type=ave   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${ue_id}_ul ${ul_tput_Mb}    
#     
# UL data to '${UE_ID}'  
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   160M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   50M   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '4s' for stabible
#     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave   
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp '${ul_cell_tp}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   Log To Console    Check throughput UE${num}
#     \      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
#     \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     \      Log To Console		ul ${ul_tput_Mb}    
#     \      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
#     Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
#     run keyword and continue on failure    should be true    ${cell_tp_ul}>${ul_cell_tp}
# 
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
#     
# check tti'${tti_title}' no bler		
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		${tti_title}_ul.csv
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_no_bler.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==4   Set test Variable	 ${rnti_4} 	${rnti_list[0]}
