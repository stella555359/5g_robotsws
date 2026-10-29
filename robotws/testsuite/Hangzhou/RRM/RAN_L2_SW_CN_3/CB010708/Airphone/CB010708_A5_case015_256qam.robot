# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    SBTS00    OPTION_RELATED_ARTIFACTS_5G    owner_zhaoxu    CLOUD_5G_I_MP_AP_LO    
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# #Library     ${CURDIR}/config/CB010708_mcs_table_check_256QAM.py
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}        scfc_CB010708_A5_case015_ul256qam.xml
# ${AIRPHONE_NAME}    iphy_CB010708_TDD_eCPRI_7_2e_srsbeam.xml
# ${WTS_NAME}         wts_CB010708_basic_setup_TDD_eCPRI_7_2e.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${X2_CMD}         enb_x2_link_up enb\=1 target\=2
# ${DTX_CMD5}        ue_srs_beam_pos_nr profile_id\=3 srsMode\=fixed init_pos\=1
# ${DTX_CMD6}       ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
# ${DTX_CMD3}        cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions\=4 azimuth\=0,30,-30,60
# ${DTX_CMD4}       cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=cell_srs_beam_pos profile_id\=1 action\=activate
# ${DTX_CMD}        ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=1 dtx_start\=0 num_dtx\=10
# ${DTX_CMD1}       ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
# ${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-200 sinr_target_pucch\=-200 noise_srs\=-1053
# ${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
# ${DELETE}       ue_srs_beam_pos_nr profile_id\=2 delete=true
# 
# ${BIP_TAG}    72E
# ${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
# @{titles}   DlData_DciInfo.patternId_item
# ${ECPRI72E}	   Ecpri72eUL
# ${BETAEC}	13
# ${XEC}	  14
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type\=SRS
# ...    srs_transmit_power_per_port\=-350,-350,-350,-350
# ${SET_PROFILE1}    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1	
# *** Test Cases ***
# CB010708_A5_case015_B102_8RX_IRC_reception_for_Rank1_Rank2_Rank1_PUSCH_with_SRS_based_Beamforming_multi_UE_Link_adaption
#     Get and Update BSR File    par_of_bsr_name=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
#     Modify vendor file 72e and full commission for onair
# 	airphone_cleanup_egate_console_log
#     Test ue1 rank1
# 	Ue1 trigger pathloss
# 	Ue1 trigger UL bler
# 	Ue1 detach
# 	Test ue2 rank2
# 	Ue2 trigger pathloss
# 	Ue2 trigger UL bler
# 	Ue2 Clear UL bler and detach UE
# 	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
# 	sleep    60s
#     
#                    
# *** Keywords ***
# Set UE2 position1
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ${SET_PROFILE1}
# Test ue1 rank1
#     Start capture gnb and ap syslog in 'ue1_attach' file
#     Attach SA UE1 rank1
#     Internal UL data
# 	Internal DL data
#     run keyword and continue on failure    Check throughput
#     Run Keyword And Ignore Error    Start collect 'ue1_attach' tcpdump
#     Wait '2s' for stable	
#     Run Keyword And Ignore Error    Stop collect 'ue1_attach' tcpdump	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_1'
# 	Stop capture gnb and ap syslog in 'ue1_attach' file  
# 
# 
# 
# Ue1 trigger pathloss 
#     Start capture gnb and ap syslog in 'ue1_pathloss' file
# 	Start collect ttitrace	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 pathloss\=105
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=1 scell\=0 action\=activate
#     Wait '1s' for stable	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 pathloss\=110
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=2 scell\=0 action\=activate
#     Wait '1s' for stable		
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 pathloss\=117
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=3 scell\=0 action\=activate
#     Wait '1s' for stable	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=4 pathloss\=121
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=4 scell\=0 action\=activate
#     Wait '1s' for stable
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 pathloss\=125
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=5 scell\=0 action\=activate		
# 	Wait for '1s' to stop ttitrace with name'tti_pathloss'				
#     Wait '15s' for stable	
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0	
# 	#Start collect ttitrace
# 	#Wait for '2s' to stop ttitrace with name'tti_pathloss'	
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_pathloss_ul.csv    19
#     Stop capture gnb and ap syslog in 'ue1_pathloss' file  
# 
# 
# Ue1 trigger UL bler
#     Start capture gnb and ap syslog in 'ue1_ul_bler' file
# 	#clear pathloss
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=4 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 delete\=1	
#     Wait '10s' for stable	
#     Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=6 pusch_tx_mix_ratio\=80 srs_tx_mix_ratio\=80
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_switch_nr action\=activate profile_id\=6
#     Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=7 noise_pusch\=-450 noise_srs\=-450
#     Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=7 action\=activate
#     Wait '15s' for stable
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_bler'	
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_bler_ul.csv    19
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}ue1_ul_bler${/}   unzip=TRUE
#     Stop capture gnb and ap syslog in 'ue1_ul_bler' file  
# 
# Ue1 detach
#     Start capture gnb and ap syslog in 'ue1_detach' file
#     Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=6 delete\=1 
#     Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=7 delete\=1 
#     Wait '15s' for stable
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0	
# 	Detach UE
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}ue1_detach${/}   unzip=TRUE
#     Stop capture gnb and ap syslog in 'ue1_detach' file  
# 
# 
# Test ue2 rank2
#     Start capture gnb and ap syslog in 'ue2_attach' file
#     Attach SA UE2 rank2
#     Set UE2 position1
#     Internal UE2 UL data
# 	Internal UE2 DL data
# 	run keyword and continue on failure    Check ue2 throughput
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_ue2_attach'
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_ue2_attach_ul.csv    19
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}ue2_attach${/}   unzip=TRUE	
#     Stop capture gnb and ap syslog in 'ue2_attach' file  
# 
# Ue2 trigger pathloss 
#     Start capture gnb and ap syslog in 'ue2_pathloss' file
# 	Start collect ttitrace	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 pathloss\=105
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=1 scell\=0 action\=activate
#     Wait '1s' for stable	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 pathloss\=110
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=2 scell\=0 action\=activate
#     Wait '1s' for stable		
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 pathloss\=117
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=3 scell\=0 action\=activate
#     Wait '1s' for stable	
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=4 pathloss\=121
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=4 scell\=0 action\=activate
#     Wait '1s' for stable
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 pathloss\=125
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_sinr profile_id\=5 scell\=0 action\=activate	
# 	Wait for '1s' to stop ttitrace with name'tti_pathloss_ue2'		
#     Wait '15s' for stable	
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2   scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0	
# 	#Start collect ttitrace
# 	#Wait for '2s' to stop ttitrace with name'tti_pathloss'	
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_pathloss_ue2_ul.csv    19
#     Stop capture gnb and ap syslog in 'ue2_pathloss' file  
# 
# 
# Ue2 trigger UL bler
#     Start capture gnb and ap syslog in 'ue2_bler' file
# 	#clear pathloss
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=1 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=2 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=4 delete\=1
#     Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=5 delete\=1		
#     Wait '10s' for stable		
#     Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=9 pusch_tx_mix_ratio\=80 srs_tx_mix_ratio\=80
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_switch_nr action\=activate profile_id\=9
#     Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=10 noise_pusch\=-450 noise_srs\=-450
#     Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=10 action\=activate
#     Wait '15s' for stable
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2   scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0	
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_ue2_bler'	
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_ue2_bler_ul.csv    19
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}ue2_bler${/}   unzip=TRUE		
#     Stop capture gnb and ap syslog in 'ue2_bler' file 
# 
# 
# Ue2 Clear UL bler and detach UE
#     Start capture gnb and ap syslog in 'ue2_clear_bler' file
#     Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=9 delete\=1 
#     Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=10 delete\=1 
#     Wait '15s' for stable
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2   scell_id=0    type=pusch    tput_type=ave
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>0
#     should_be_true    ${ul_throughput_pcell}>0		
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti_ue2_clear_bler'	
# 	run keyword and continue on failure    CB010708_check_mcs_sinr_256qam    ${TEST_LOG_DIRECTORY()}/All/tti_ue2_clear_bler_ul.csv    19
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}ue2_clear_bler${/}   unzip=TRUE		
#     Stop capture gnb and ap syslog in 'ue2_clear_bler' file  
# 	Detach UE '2'
# 
# 
# 
# 
# Modify vendor file 72e and full commission for onair
#     [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
#     Modify Swconfig for AP
#     Start capture gnb and ap syslog in 'before_onair' file
#     Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
#     OperatingSystem.Run And Return Rc And Output
#     ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
#     Wait '10s' for stable
#     ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
#     ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
#     ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
#     Configure TL VM ETH
#     TAF_ADMIN.Setup Admin
#     ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
#     TAF_ADMIN.Download Vendor File    ${vendor_path} 
#     Modify Vendor betaec XML File    ${vendor_path}
#     Modify Vendor xec XML File    ${vendor_path} 
#     Modify Vendor 72e XML File    ${vendor_path}
#     TAF_ADMIN.Set Vendor File    ${vendor_path}
#     ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
#     ...    bts_id=${GNB_IP}
#     ...    scf_file=${new_scfc}
#     ...    skip_parameter_relation_errors=True
#     ...    should_activate=True
#     ...    timeout=300     
#     Log to console    Full Commissioning is ${connission_status}
#     TAF_ADMIN.teardown admin
#     Wait '120s' for stable
#     Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
#     ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
#     ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
#     ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
#     ...    timeout=${wait_onair_timeout}
#     Stop capture gnb and ap syslog in 'before_onair' file
#     Log To Console    BTS is onAir now
#     Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump
# 
# Modify Vendor 72e XML File 
#     [Arguments]    ${vendor_path} 
#     ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}    
# Modify Vendor betaec XML File 
#     [Arguments]    ${vendor_path}  
#     ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}      
# Modify Vendor xec XML File 
#     [Arguments]    ${vendor_path} 
#     ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]  
#     Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}       
# Prepare test
#     #Modify l1bypass
#     #pdcch dftbeam
#     Add GNB swconfig    0x580434:0
#     Add GNB swconfig    0x450027:1
#     Add GNB swconfig    0x5900B9:1
# Check throughput
#     Wait until keyword succeeds    60s    5s    Verify ue1 throughput
# Verify ue1 throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>60000
# 	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1000000
# Check ue2 throughput
#     Wait until keyword succeeds    60s    5s    Verify ue2 throughput
# Verify ue2 throughput
#     ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pusch    tput_type=ave
#     should_be_true    ${ul_throughput_pcell}>130000	
#     ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
#     should_be_true    ${dl_throughput_pcell}>1000000	
# Attach SA UE1 rank1
#     Airphone SA Attach    ue_id=${UE_ID}
#     airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal     
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# Attach SA UE2 rank2
#     Airphone SA Attach    ue_id=2
#     airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal     
#     Airphone Pdu Session Setup    2    2    ${SLICE_ID}    2	
# Internal DL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=4
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=5
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=6
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=100 seconds\=3000 trf_id\=7
# Internal UE2 DL data
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
# 	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=4
# 	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=5
# 	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=6
# 	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=100 seconds\=3000 trf_id\=7	
# Internal UL data
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
# Internal UE2 UL data
#     airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
