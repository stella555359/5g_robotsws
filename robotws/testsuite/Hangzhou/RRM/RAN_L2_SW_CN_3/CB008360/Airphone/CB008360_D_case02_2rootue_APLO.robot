# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# #Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     SBTS23R1
# ...   CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# 
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC8360_D_case02_APLO.xml
# ${AIRPHONE_NAME}    IPHY_AEQE_1CELL_8D8U_LOAPLO.xml
# ${WTS_NAME}    wts_8360_case1_LOAPLO.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case4.txt
# ${UE_TOTALNUM}    4
# ${UE_NUM}         4
# ${UE_ID}          1
# ${UE_ID2}          2
# ${UE_ID3}          3
# ${UE_ID4}          4
# ${UE_ID5}          5
# ${UE_ID6}          6
# ${UE_ID7}          7
# ${UE_ID8}          8
# ${SLICE_ID}       1
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 trigger_puxch_update\=0
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 trigger_puxch_update\=0
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${deactive_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
# ${deactive_PROFILE2}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2
# ${deactive_PROFILE3}    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=3
# ${deactive_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4
# *** Test Cases ***
# CB008360_D_B1b_case02_Retrans_UEs_paired_with_Retrans_UEs_with_actAdaptiveReTxResMCS_true
#     Get and Update BSR File    par_of_bsr_name=BSR_AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
#     Prepare gnb onair
#     Start capture gnb and ap syslog in 'after_onair_nobler' file
#     airphone_cleanup_egate_console_log
#     Set multiue traffic type to internal
#     Attach '4' ue to 5g cell
# 	  Set ue position
#     Internal send data
#   	run keyword and continue on failure    check throughput	
#     Start collect ttitrace
#     #Start collect bip log
# 	Wait for '2s' to stop ttitrace with name'tti'
# 	#Wait for '0s' to stop bip log with name'bip'
# 	run keyword and continue on failure     check bler and pair is correct in ttitrace
# 	Stop capture gnb and ap syslog in 'after_onair_nobler' file
# 	Start capture gnb and ap syslog in 'after_onair_bler' file
# 	Internal send data 20M
# 	send bler to ue1ue2
#   Internal send data
# 	send bler to ue1ue2ue3ue4
#   run keyword and continue on failure       DeRegister UE from '1' to '4'	
# 	run keyword and continue on failure       deactive profile1234
#   Stop capture gnb and ap syslog in 'after_onair_bler' file
# *** Keywords ***
# Prepare test
#     #Active GNB L2 feature debug traces
#     Modify l1bypass
#     Modify 8360 Swconfig
# Verify throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell1}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID2}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell2}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID3}    scell_id=0    type=pusch    tput_type=ave
#     ${ul_throughput_pcell3}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID4}    scell_id=0    type=pusch    tput_type=ave
#     #${ul_throughput_pcell4}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID5}    scell_id=0    type=pusch    tput_type=ave
#     #${ul_throughput_pcell5}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID6}    scell_id=0    type=pusch    tput_type=ave
#     #${ul_throughput_pcell6}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID7}    scell_id=0    type=pusch    tput_type=ave
#     #${ul_throughput_pcell7}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID8}    scell_id=0    type=pusch    tput_type=ave
#     run keyword and continue on failure     should_be_true     ${ul_throughput_pcell}+${ul_throughput_pcell1}
# 	...    +${ul_throughput_pcell2}+${ul_throughput_pcell3}>120000
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify throughput
# Internal send data
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    UL    80M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     #\    Wait '5s' for stabible
# Internal send data 20M
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone SA Start Data Traffic    ${num}    UL    20M    pdu_id=${num}    duration=6000s
#     \    ...    trf_id=${num}
#     #\    Wait '5s' for stabible	
# Modify l1bypass
#     copy_file    ${COMAVALUE}    ${test_log_directory()}/coma.py
#     Import Variables    ${test_log_directory()}/coma.py
#     ${extra_modify}    create list
# 	#...    text|0|//enable_5GC002396
#     ...    text|28|//*[@TestProfile\="Profile-1"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-1"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//SrsTestParams//ulPmiRank1Sinr
#     ...    text|28|//*[@TestProfile\="Profile-2"]//PuschTestParams//ulPmiRank1Sinr
#     ...    text|0|//*[@TestProfile\="Profile-1"]//PuschTestParams//puschNumCountSwitchProfile
#     ...    text|0|//*[@TestProfile\="Profile-2"]//PuschTestParams//puschNumCountSwitchProfile
#     Modify airphone l1bypass coma value for eight ue
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex2}    ${Vindex0}
#     ...    ${Hindex6}    ${Vindex0}    ${Hindex6}    ${Vindex0}
#     ...    ${Hindex6}    ${Vindex0}    ${Hindex8}    ${Vindex0}
#     ...    ${Hindex0}    ${Vindex0}    ${Hindex0}    ${Vindex0}
#     ...    ${Hindex3}    ${Vindex0}    ${Hindex3}    ${Vindex0}
#     ...    ${Hindex6}    ${Vindex0}    ${Hindex6}    ${Vindex0}
#     ...    ${Hindex9}    ${Vindex0}    ${Hindex9}    ${Vindex0}
#     ...    srsNumCountSwitchProfile1=0    p1_rank=1    p2_rank=1    p1_sinr=28    p2_sinr=28
#     ...    extra_modify=${extra_modify}
# Modify 8360 Swconfig
#     #Add AP swconfig    0x70690:1
# 	#control UE rank reported by pusch
# 	Add GNB swconfig    0x58037C:1
# 	#enble 8360-B
# 	#Add GNB swconfig    0x590192:1
# 	# enable_rdNewTddCellSlotModel of CB008940
# 	#Add GNB swconfig    0x420062:1
# 	#enable simple reTx pair
# 	Add GNB swconfig	 0x580550:7
# 	#enable rdactUlMuMimoEnhance
# 	#Add GNB swconfig     0x58054F:1	
# Attach '${uenum}' ue to 5g cell
#     : FOR    ${num}    IN RANGE    1    ${uenum}+1
#     \    Airphone SA Attach    ue_id=${num}
#     \    Wait '2s' for stabible
#     \    Airphone Pdu Session Setup    ${num}    ${num}    ${SLICE_ID}    ${num}
#     \    Wait '3s' for stabible	
# 
# Set multiue traffic type to internal
#     : FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
#     \    Airphone Set Traffic Type    ${num}    ${num}    internal
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
# 
# get UE '${ue_id}' rnti in RRC log
#     Log To Console   ${\n}===get UE'${ue_id}' rnti===
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
# 
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}/egate_console.log.001   crnti: (\\d+)
#     run keyword if    ${ue_id}==1   Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==2   Set test Variable	 ${rnti_2} 	${rnti_list[0]}
#     run keyword if    ${ue_id}==3   Set test Variable	 ${rnti_3} 	${rnti_list[0]}
# 
# Online change actAdaptiveReTxResMCS
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1    actAdaptiveReTxResMCS     true    online
#     Wait '2s' for stabible
#     TAF_ADMIN.teardown admin    connection=online    
# check bler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_ul_D_case02_nobler.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check initretransbler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check retransbler and pair is correct in ttitrace                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2re.ini    log_need_to_check=i    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# check port is correct in ttitrace    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_d_case2_port.ini    log_need_to_check=i    
# 	...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# send bler to ue1
#     airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
#     Wait '1s' for stabible 	
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	Wait '1s' for stabible 
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ue1bler'
# 	run keyword and continue on failure    check initretransbler and pair is correct in ttitrace	
# send bler to ue1ue2
#     airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=100,100
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=2 ul_bler\=100,100
# 	Wait '1s' for stabible 
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     Wait '2s' for stabible 	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ue1ue2bler'
# 	run keyword and continue on failure    check initretransbler and pair is correct in ttitrace		
# send bler to ue1ue2ue3
#     airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=40,40
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=2 ul_bler\=40,40
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=3 ul_bler\=40,40
# 	Wait '1s' for stabible 
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=3 action\=activate
#     Wait '2s' for stabible 	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ue1ue2ue3bler'
# 	#run keyword and continue on failure    check bler and pair is correct in ttitrace		
# send bler to ue1ue2ue3ue4
#     airphone_execute_egate_command	bler_testmode_nr profile_id\=1 ul_bler\=500,500
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=2 ul_bler\=500,500
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=3 ul_bler\=500,500
# 	airphone_execute_egate_command	bler_testmode_nr profile_id\=4 ul_bler\=500,500
# 	Wait '1s' for stabible 
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=1 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=2 scell\=0 testmode\=bler profile_id\=2 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=3 scell\=0 testmode\=bler profile_id\=3 action\=activate
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=4 scell\=0 testmode\=bler profile_id\=4 action\=activate
#     Wait '2s' for stabible 	
#     Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ue1234bler'
# 	run keyword and continue on failure    check retransbler and pair is correct in ttitrace
#     ${passed}    Run Keyword And Return Status     check port is correct in ttitrace   
#     Run Keyword If    ${passed}    fail	
#     airphone_execute_egate_command    bler_testmode_nr profile_id\=1 delete\=yes	
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=2 delete\=yes
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=3 delete\=yes
# 	airphone_execute_egate_command    bler_testmode_nr profile_id\=4 delete\=yes
# Set ue position
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Wait '2s' for stabible
#     Airphone Execute Egate Command    ${PROFILE4}
#     Airphone Execute Egate Command    ${SET_PROFILE4}
# 
# 
# deactive profile1234
# 	Airphone Execute Egate Command    ${deactive_PROFILE1}
# 	Airphone Execute Egate Command    ${deactive_PROFILE2}
# 	Airphone Execute Egate Command    ${deactive_PROFILE3}
# 	Airphone Execute Egate Command    ${deactive_PROFILE4}  
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible