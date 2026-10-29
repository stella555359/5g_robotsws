# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# #Force Tags        CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD    AP    CRT    SBTS00    RAN_5G    owner_zhang
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_10659_1cell_FDD_DSS_case41.xml
# ${AIRPHONE_NAME}    AP_iphy_10659_1cell_FDD_DSS_case38.xml
# ${WTS_NAME}        wts_10659_1cell_FDD_DSS_case38.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${bler_testmode_nr_profile_1}    bler_testmode_nr profile_id\=1 ul_bler_bit_error\=200,200,200,200,0,0,0,0 ul_bler_bit_error_periodicity\=3 
# ...        ul_bler_bit_error_duration\=0
# 
# *** Test Cases ***
# #64Qam
# CB010659_A_b6_case41_FDD_DSS_CB007738
# 	Add RD param MCS16
# 	Prepare gnb onair	
# 	set DSS commands
# 	test case41
# 	
# *** Keywords ***
# Add RD param MCS16	
# 	#MCS=16; Qm=4; reserved MCS=30
# 	Add GNB swconfig	 0x580010:0x10000
# 
# set DSS commands
# 	Log To Console   ${\n}---Wait for 60s before DSS commands----
# 	Wait '30s' for stabible
# 	${cmd_string}    Get File    ${CONFIG_DIR_PATH}${/}${SW_BRANCH}${/}WTS${/}DSS_commands_case41.txt    encoding=UTF-8    encoding_errors=strict
# 	@{cmd_list}    Split String    ${cmd_string}    \n
# 	${cmds_num}    Evaluate    len(@{cmd_list})
# 	Log To Console    ${cmds_num}
# 	: FOR     ${i}    IN RANGE    ${cmds_num}
# 	\    Log To Console     @{cmd_list}[${i}]
# 	\    airphone_execute_egate_command    @{cmd_list}[${i}]
# 	\    Wait '2s' for stabible
# 	airphone_execute_egate_command    command=enb_crm_status enb=1 cell=1    pass_regexp=DMS3
# 	
# Trigger ul bler
# 	Log To Console   ${\n}---FDD ul bler---
#     airphone_execute_egate_command	${bler_testmode_nr_profile_1}
#     airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=activate
#     Wait '2s' for stabible
# deactive ul bler
# 	airphone_execute_egate_command	ue_testmode_set_nr id\=1 testmode\=bler profile_id\=1 action\=deactivate    
# 
# test case41
# 	Start capture gnb and ap syslog in 'sys_case41' file
# 	Register_UE1
# 	check tti no bler_with_passratio_'1'
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '1' with tp range '12' to '15'
# 	Trigger ul bler	
# 	run keyword and continue on failure    Wait Until Keyword Succeeds    20s    2s   check throughput from UE '1' to '1' with tp range '6' to '10'
# 	check tti after bler
# 	deactive ul bler
# 	DeRegister UE from '1' to '1'
# 	run keyword and continue on failure    Stop capture gnb and ap syslog in 'sys_case41' file
# 	
# Register_UE1	
# 	UE from '1' to '1' SA Register
# 	send ul data '40M' from UE '1' to '1' 	
# 		
# check tti after bler
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler_case41'
# 	
# 	Log To Console   ${\n}---check tti after bler---
# 	Set test Variable    ${tti_title_tag}		tti_bler_case41_ul.csv
# 	#(0-9)-29;(10-16)-30;(17-28)-31
# 	Set test Variable    ${reserved_MCS}	30
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_case41.ini   i	
# 	...   save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 	
# 	#run keyword and continue on failure   Check reserved mcs in ttitrace is correct   tti_bler_case41
# 	run keyword and continue on failure   check_reTx_status_and_reservedMCS   ${TEST_LOG_DIRECTORY()}/All/tti_bler_case41_ul.csv   0.75   0.5
# 	run keyword and continue on failure   check_maxCodeRatePRB   ${TEST_LOG_DIRECTORY()}/All/tti_bler_case41_ul.csv   0.97
# 	
# UE from '${lo}' to '${hi}' SA Register
#     : FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     #\   airphone_cleanup_egate_console_log
#     \   Log To Console   ${\n}-----register UE ${num} ------
# 
#     \   Airphone SA Attach    ue_id=${num}
#        #set_pdu_param ue=1 pdu=1 trf_type=internal
#        #Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     \   Airphone Set Traffic Type    ${num}    ${num}    internal
#     \   Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
#     \   Wait '2s' for stabible
#     #\   get UE '${num}' rnti in RRC log
# 
# send ul data '${ul_data}' from UE '${lo}' to '${hi}'  
# 	: FOR    ${num}    IN RANGE    ${lo}    ${hi}+1
#     \   DL and UL data '${ul_data}' to '${num}'    
# DL and UL data '${ul_data}' to '${UE_ID}'
#     Airphone SA Start Data Traffic    ${UE_ID}    DL   20M   pdu_id=${UE_ID}   duration=3600   trf_id=1
#     Airphone SA Start Data Traffic    ${UE_ID}    UL   ${ul_data}   pdu_id=${UE_ID}   duration=7200   trf_id=1
#     Wait '2s' for stabible
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${UE_ID}  	pdu_id= ${UE_ID}
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console		UE${UE_ID}_ul ${ul_tput_Mb}
# 
# #check throughput
# check throughput from UE '${low}' to '${hi}' with tp range '${ul_cell_tp_lo}' to '${ul_cell_tp_hi}'
# 	Wait '3s' for stabible
# 	${cell_tp_ul}	  evaluate	0
# 	: FOR    ${num}    IN RANGE    ${low}    ${hi}+1
# 	\   Log To Console    Check throughput UE${num}
# 	\      ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
# 	\      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
# 	\      Log To Console		ul ${ul_tput_Mb}    
# 	\      ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}    
# 	Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
# 	should be true    ${cell_tp_ul}>=${ul_cell_tp_lo}
# 	should be true    ${cell_tp_ul}<=${ul_cell_tp_hi}
# DeRegister UE from '${low}' to '${hi}'
#     : FOR    ${num}    IN RANGE    ${low}    ${hi}+1
#     \   airphone_sa_detach    ue_id=${num}    timeout=5
#     \   Wait '3s' for stabible
# 
# check tti no bler_with_passratio_'${pass_ratio}'
# 	Start collect ttitrace
# 	Wait for '3s' to stop ttitrace with name'tti'
# 	
# 	Log To Console   ${\n}---check tti---
# 	Set test Variable    ${tti_title_tag}		tti_ul.csv
# 	Set test Variable    ${pass_ratio_ini}		${pass_ratio}
# 	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_ul_check_bler_ratio.ini   i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# #----------------------on air for DSS------------------------  
# Prepare gnb onair
# 	Log to console    -----zs---Prepare gnb onair------zs------
#     Check GPS status enable
#     ${status0}    ${msg0}    Run Keyword And Ignore Error    Variable Should Exist    ${GNB_SWCONFIG_NAME}
#     ${status1}    ${msg1}    Run Keyword And Ignore Error    Variable Should Exist    ${AP_SWCONFIG_NAME}
#     Run Keyword If    '${status0}'=='PASS'    Put swconfig file to gnb    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${GNB_SWCONFIG_NAME}
# #    ...    ELSE    Modify Swconfig for gnb
#     Run Keyword If    '${status1}'=='PASS'    Airphone Upload Swconfig    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SWCONFIG/${AP_SWCONFIG_NAME}
#     ...    ELSE    Modify Swconfig for AP
#     Start capture gnb and ap syslog in 'before_onair' file
#     Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
#     ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
# #    ${cfg_path}    Run Keyword If    '${FCT_BOARD_TYPE}' == 'ASIB'    Set variable    ${CURDIR}/../../KISS/cfg/${ABIO_CFG}
# #    ...    ELSE    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     ${ret}    Evaluate Xml Xpath    ${scfc_path}    count(//*[@name\='carrierAggregationSupportList']/p)
#     ${type}    Run Keyword If    ${ret} == 1    Read Xml     ${scfc_path}    text|//*[@name\='carrierAggregationSupportList']/p
#     ...    ELSE    Get carrierAggregation value    ${ret}    ${scfc_path}
# #    Run Keyword If    'Nsa' in '${type}'    Configure NSA TL VM ETH
#     Configure TL VM ETH
#     
#     Perform Full Commission And Reach Onair     ${scfc_path}    ${cfg_path}    2000    False    800    800
#     
#     Run Keyword If    'Nsa' in '${type}' and 'ABIL' in ${ASP_BOARD_TYPE}   Establish enb x2 link
#     Stop capture gnb and ap syslog in 'before_onair' file
#     Log To Console    BTS is onAir now
#     Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
# 
# Perform Full Commission And Reach Onair
#     [Arguments]     ${scfc}      ${wts_config}    ${wait_onair_timeout}    ${reset_after_commission}
#     ...             ${wait_bts_timeout}    ${wait_rru_timeout}
#     Log to console    -----zs---Perform Full Commissioning And Reach Onair start----zs-----
#     ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc}    ${test_log_directory()}/full_commission/
#     ${connission_status}    Run Keyword And Return Status    Perform Full Commission     ${new_scfc}
#     Log to console    Full Commissioning is ${connission_status}
#     Wait '100s' for stable
#     Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
#     Run Keyword If    '${connission_status}' == 'False'    Hard reboot env
#     Run Keyword If    '${connission_status}' == 'True' and '${reset_after_commission}'=='True'     Reboot gnb and ap via ssh
#     
#     ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}       
#     ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${wts_config}
#          ...    timeout=${wait_onair_timeout}
#          
# Start WTS And Wait BTS Until Onair
#     [Arguments]    ${cfg_file}=${None}    ${reload}=${True}    ${timeout}=1500
#     [Documentation]    This keyword is used to wait bts on air until timeout happened, default timeout is 1500 seconds.
#     ...    | Input Parameters | Man. | Description |
#     ...    | ${cfg_file} | No | wts config file, default is get from gerrit store in /opt/wts/latetst/ |
#     ...    | ${reload} | No | load lua cfg file or not, default is to load |
#     ...    | ${timeout} | No | timeout, default is 1500 |
#     ...    Examples:
#     ...    | Start Wts And Wait Bts Until Onair | /opt/wts/latest/basic_fullstack_nsa_call_tdd_cmwv.cfg |
#     Log To Console    ${\n}----zs-Start WTS And Wait BTS Until Onair...--zs--
#     ${nrbts_distname}=    Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get NRBTS DistName
#     Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Backup Scf    ${TEST_LOG_DIRECTORY()}    before_onair_scf.xml
#     Run Keyword If    '${GNBCUTYPE}'=='${EMPTY}'    Get GNB Type    ${TEST_LOG_DIRECTORY()}/before_onair_scf.xml    ${nrbts_distname}
#     ${gnb}=    String.Convert To Lowercase    ${GNBCUTYPE}
#     ${cfg_file}=    Run Keyword If    '${cfg_file}' == '${None}'    Set Variable    ${WTS_CFG_FULL_PATH}
#     ...             ELSE              Set Variable    ${cfg_file}
#     Airphone Start Wtssim With Cfg File    ${cfg_file}    ${reload}
#     
#     Wait Until Keyword Succeeds    300    5    Verify BTS Is Onair
#     
#     
