# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    #Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS22R4    SBTS23R1
# ...   CLOUD_5G_I_MP_AP_LO    
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      scfc_10634_case1.xml
# ${AIRPHONE_NAME}    iphy_TDD_eCPRI_7_2e.xml
# ${WTS_NAME}    basic_setup_TDD_eCPRI_7_2e.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
# ${COMAVALUE}    ${CURDIR}/coma/case18.txt
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
# ${BIP_TAG}    72E
# ${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
# @{titles}   DlData_DciInfo.patternId_item
# ${ECPRI72E}	Ecpri72eUL
# ${BETAEC}	13
# ${XEC}	14
# *** Test Cases ***
# CB010634_C2_case1_UL_SU_MIMO_adaption
# 
#     Modify vendor file 72e and full commission for onair
# 	airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
#     Test ue1 rank1
# 	Test ue2 rank2
# 	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
#     Stop capture gnb and ap syslog in 'after_onair' file      
#                    
# *** Keywords ***
# Test ue1 rank1
#     Attach SA UE1 rank1
#     Internal UL data
# 	Internal DL data
#     run keyword and continue on failure    Check throughput
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'tti'
#     check ue1 bler
# 	Detach UE
# Test ue2 rank2
#     Attach SA UE2 rank2
#     Internal UE2 UL data
# 	Internal UE2 DL data
# 	run keyword and continue on failure    Check ue2 throughput
# 	Start collect ttitrace
# 	Wait for '2s' to stop ttitrace with name'ttiue2'
#     check ue2 bler
# check ue1 bler                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_ul_ue1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_dl_ue1.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
# check ue2 bler                    
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_ul_ue2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
# 	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_dl_ue2.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
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
