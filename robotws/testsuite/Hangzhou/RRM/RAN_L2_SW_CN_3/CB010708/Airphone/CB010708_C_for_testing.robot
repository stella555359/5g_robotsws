# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB010708_C_for_testing
# ...
# 
# Test Timeout    60 minutes
# Suite Setup        Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup         Common Test Setup
# Test Teardown      Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin    CLOUD_5G_I_MP_AP_LO
# 
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library     ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}          scfc_10708_C.xml
# ${AIRPHONE_NAME}      10708_iphy_TDD_eCPRI_7_2e_DLUL72e.xml
# ${WTS_NAME}           10887basic_setup_TDD_eCPRI_7_2e.cfg
# @{LOG_NAME_LIST}    egatelog
# #sosreport    gnb_snapshot
# 
# ${ECPRI72E}	   Ecpri72eUL
# ${BETAEC}	   13
# ${XEC}	       14
# 
# ${PROFILE1}    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0,1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
# ${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach
# 
# ${PROFILE2}    ul_ue_beam_pos_nr profile_id=2 power=-200,-200,-200,-200,-200,-200,-200,-200
# ${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=2
# 
# ${PROFILE3}    ul_ue_beam_pos_nr profile_id=3 power=-600,-600,-600,-600,-600,-600,-600,-600
# ${SET_PROFILE3}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position action=activate profile_id=3
# 
# ${PROFILE4}    ul_ue_beam_pos_nr profile_id=1 num_beam_paths=2 azimuth=-70,70 zenith=-40,40 power=-849,-130
# ${SET_PROFILE4}    ue_testmode_set_nr id=1 testmode=ul_ue_beam_pos_nr action=activate profile_id=4
# 
# ${PROFILE5}    ul_ue_beam_pos_nr profile_id=5 num_beam_paths=0
# ${SET_PROFILE5}    ue_testmode_set_nr id=1 testmode=ue_ul_beam_position profile_id=5 action=activate
# 
# ${PROFILE6}    ul_ue_beam_pos_nr profile_id=6 num_beam_paths=0
# ${SET_PROFILE6}    ue_testmode_set_nr id=2 testmode=ue_ul_beam_position profile_id=6 action=activate
# 
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=UL_MIMO
# ${SET_PROFILE8}    ue_testmode_set_nr id=1 testmode=ul_mimo_srs_beam_pos action=activate profile_id=8
# 
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=UL_MIMO
# ${SET_PROFILE9}    ue_testmode_set_nr id=2 testmode=ul_mimo_srs_beam_pos action=activate profile_id=9
# 
# ${pattern1}    CA_P2_8x4_t2r4_n2
# 
# *** Test Cases ***
# CB010708_C_for_testing
#     Step1:Commission configurations on WebUI
#     Step2:Attach UE1
#     #Step3:Send DL data
#     #Step4:Send UL data
#     #Step5:Fall back to SSB
#     #Step6:Back to DFT
# 	#Step7:repeat
# 
# *** Keywords ***
# Step1:Commission configurations on WebUI
#     Get and Update BSR File    par_of_bsr_name=BSR_AVQL_8_H8_ALN60_ARP60_P00_COVERAGE_00426_00002
#     Modify vendor file 72e and full commission for onair
# 
# Step2:Attach UE1
#     Start capture GNB and AP Syslog in 'Step2_attach' File	
#     ${capacity_units}=  Create List    ABIO
#     Configure Bip Collection   l1_type=FS
#     ...                        gNB_common_unit=ASIB
#     ...                        gNB_capacity_units=${capacity_units}
#     ...                        use_script=True
#     ...                        script_parameters=--bb_slot_1='true' --bb_slot_2='false' --bb_slot_3='false'
# 
#     Airphone Execute Egate Command    ${PROFILE5}
#     Airphone Execute Egate Command    ${SET_PROFILE5}
#     Airphone Execute Egate Command    ${PROFILE6}
#     Airphone Execute Egate Command    ${SET_PROFILE6}
# 	
# 	#Airphone Execute Egate Command    ${PROFILE8}
#     #Airphone Execute Egate Command    ${SET_PROFILE8}  
#     #Airphone Execute Egate Command    ${PROFILE9}
#     #Airphone Execute Egate Command    ${SET_PROFILE9}
# 
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     : FOR    ${i}    IN RANGE    1    3
#     \    run keyword and continue on failure    Attach UE to cell1    ${i}    ${pattern1}
#     \    run keyword and continue on failure    Send trf for UE    ${i}    UL    150M    1
#     Wait '1s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 	
# Step3:Send DL data
#     Start capture GNB and AP Syslog in 'Step3_Send_DL_data' File	
#     run keyword and continue on failure    Send trf for UE    1    DL    150M    8
#     Wait '50s' for stable
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Send_DL_data
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_dl_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_ul_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#     ${PUCCH_F1_nonDTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C14001    cell_id=1
#     ${PUCCH_F1_DTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C13001    cell_id=1
#     ${PUCCH_F3_nonDTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C17001    cell_id=1
#     ${PUCCH_F3_DTX}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55303C18001    cell_id=1
#     #${PUCCH_F1_DTX_ratio}    evaluate    ${PUCCH_F1_DTX}/(${PUCCH_F1_DTX}+${PUCCH_F1_nonDTX})
#     ${PUCCH_F3_DTX_ratio}    evaluate    ${PUCCH_F3_DTX}/(${PUCCH_F3_DTX}+${PUCCH_F3_nonDTX})
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step3_Send_DL_data' File
# 
# Step4:Send UL data
#     Start capture GNB and AP Syslog in 'Step4_Send_UL_data' File	
#     run keyword and continue on failure    Send trf for UE    1    UL    150M    1
#     Wait '50s' for stable
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Send_UL_data
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_dl_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_ul_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step4_Send_UL_data' File
# 	
# Step5:Fall back to SSB
#     Start capture GNB and AP Syslog in 'Step5_SSB' File	
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    ${PROFILE3}
#     Airphone Execute Egate Command    ${SET_PROFILE3}
#     Stop UE Traffic    1    UL
#     run keyword and continue on failure    Send trf for UE    1    UL    20M    1
#     Wait '1s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_SSB
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step5_dl_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step5_ul_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step5_SSB' File
# 
# Step6:Back to DFT
#     Start capture GNB and AP Syslog in 'Step6_DFT' File	
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    ${PROFILE2}
#     Airphone Execute Egate Command    ${SET_PROFILE2}
#     run keyword and continue on failure    Send trf for UE    1    UL    150M    1
#     Wait '1s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_DFT
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_dl_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_ul_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step6_DFT' File
# 
# Step7:repeat
#     Start capture GNB and AP Syslog in 'Step7_repeat' File	
#     : FOR    ${i}    IN RANGE    1    10
# 	\    Detach UE    1
# 	\    Wait '1s' for stable
#     #\    run keyword and continue on failure    2Attach UE to cell1    1
#     \    run keyword and continue on failure    Attach UE to cell1    1    ${pattern1}
#     \    run keyword and continue on failure    Send trf for UE    1    DL    150M    8
#     \    run keyword and continue on failure    Send trf for UE    1    UL    150M    1
# 	\    Wait '1s' for stable
#     \    Airphone Execute Egate Command    ${PROFILE3}
#     \    Airphone Execute Egate Command    ${SET_PROFILE3}
# 	\    Wait '1s' for stable
#     \    Airphone Execute Egate Command    ${PROFILE2}
#     \    Airphone Execute Egate Command    ${SET_PROFILE2}
#     #Wait '60s' for stable
#     Start Bip Trace
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_repeat
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Bip Trace   target_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_dl_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/CB010708_B1_case019_step3_ul_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#     ${DL_tput_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
# 	${UL_tput_cell1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002    cell_id=1
#     ${DL_tput}    evaluate    ${DL_tput_cell1}*8/1024/1024
#     ${UL_tput}    evaluate    ${UL_tput_cell1}*8/1024/1024
#     Build excel table for CB010708 KPI vs
#     modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB010708_kpi.xls    Sheet1    1    1    ${DL_tput}
#     modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB010708_kpi.xls    Sheet1    1    2    ${UL_tput}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step7_repeat' File
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
# 
# Attach UE to cell1
#     [Arguments]    ${ue_id}    ${pattern}
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     ${pdu_id}    evaluate    ${ue_id}%10+1
#     ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
#     #${newNum}=    evaluate    ${ue_id}+8
#     Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
#     Wait '1s' for stable
# 	
# 2Attach UE to cell1
#     [Arguments]    ${ue_id}
#     #${ue_ability}    Obtain Ue Capability    ${pattern}
#     ${attach_status}=    run keyword and return status    Airphone SA Attach    ue_id=${ue_id}    timeout=60
#     Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     ${pdu_id}    evaluate    ${ue_id}%10+1
#     ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${pdu_id}
#     #${newNum}=    evaluate    ${ue_id}+8
#     Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    5
# 
# Send trf for UE
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone SA Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    pdu_id=1    duration=10800s    trf_id=${num}
# 	
# Stop UE Traffic
#     [Arguments]    ${ue_id}    ${DLorUL}
#     airphone_sa_stop_data_traffic    ${ue_id}    ${DLorUL}
# 	
# Attach UE to cell NSA
#     [Arguments]    ${ue_id}    ${pattern}
#     ${ue_ability}    Obtain Ue Capability    ${pattern}
#     ${attach_status}=    run keyword and return status    Airphone NSA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     Run Keyword If    '${attach_status}'=='False'    Airphone SA Attach    ue_id=${ue_id}    timeout=60    ue_capability=${ue_ability}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     ${pdu_status}=    run keyword and return status    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     ${newNum}=    evaluate    ${ue_id}+8
#     Run Keyword If    '${pdu_status}'=='False'    Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '1s' for stable
# 
# Send trf for UE NSA
#     [Arguments]    ${ue_id}    ${DLorUL}    ${mbps}    ${number}
#     : FOR    ${num}    IN RANGE    1    ${number}+1
#     \    Airphone Nsa Start Data Traffic    ${ue_id}    ${DLorUL}    ${mbps}    trf_id=${num}    bearer_id=2    duration=3600
# 	
# Detach UE
#     [Arguments]    ${ue_id}
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30
# 
# Build excel table for CB010708 KPI vs
#     modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB010708_kpi.xls    Sheet1    1    0    beamSet_x
#     modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB010708_kpi.xls    Sheet1    0    1    DL_tput
#     modify_excel_cell    ${TEST_LOG_DIRECTORY()}/All/CB010708_kpi.xls    Sheet1    0    2    UL_tput
