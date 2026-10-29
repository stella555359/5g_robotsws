*** Settings ***
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    #Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_menzheng    CLOUD_5G_I_MP_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_TDD_eCPRI_72e_10982_case5.xml
${AIRPHONE_NAME}    iphy_TDD_eCPRI_7_2e_dlul.xml
${WTS_NAME}    basic_setup_TDD_eCPRI_7_2e_ho.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${COMAVALUE}    ${CURDIR}/coma/case18.txt
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${X2_CMD}         enb_x2_link_up enb\=1 target\=2
${DTX_CMD1}        ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=2 time_ue_stayed_in_cell\=97
${DTX_CMD2}        ue_history_information_list_add_ngran id\=1 cell_type\=large nrcgi\=311:489|0x01 gnb_id\=3 time_ue_stayed_in_cell\=98
${DTX_CMD3}        gnb_param id\=3 xn_listening_socket\=1 send_xn_setup\=true measEvent\=A3
${DTX_CMD4}        gnb_xn_link_up gnb\=3 target\=2
${DTX_CMD5}        ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=381 nrsrp_nr\=30 nrsrq_nr\=30
${DTX_CMD6}        ue_measurement_send_nr id\=1 meas_id\=1 event\=A3 srsrp_nr\=11 srsrq_nr\=11 phycell_id\=50 nrsrp_nr\=30 nrsrq_nr\=30
${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-200 sinr_target_pucch\=-200 noise_srs\=-1053
${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
${DELETE}       ue_srs_beam_pos_nr profile_id\=2 delete=true
${BIP_TAG}    srs
${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
@{titles}   DlData_DciInfo.patternId_item
${ECPRI72E}	Ecpri72eULDL
${BETAEC}	13
${XEC}	14

*** Test Cases ***
CB010982_F_case005_single_UE_L3_call_with_Handover
    Prepare test
    Modify vendor file 72e and full commission for onair
    airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
    Test ue1 rank1
    run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
    Stop capture gnb and ap syslog in 'after_onair' file      
                    
*** Keywords ***
Test ue1 rank1
    handover prepare
    Attach SA UE1
    SEND data to '1'
    run keyword and continue on failure    Check throughput
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure    check ue1 bler
    trigger to handover gnb3
    trigger to handover back gnb2
    run keyword and continue on failure    Check throughput
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti'
    run keyword and continue on failure    check ue1 bler
    Detach UE

trigger to handover gnb3
    airphone_execute_egate_command    ${DTX_CMD5}
    Wait '5s' for stabible
	
trigger to handover back gnb2
    airphone_execute_egate_command    ${DTX_CMD6}
    Wait '5s' for stabible
	
handover prepare
    airphone_execute_egate_command    ${DTX_CMD1}
    airphone_execute_egate_command    ${DTX_CMD2}
    airphone_execute_egate_command    ${DTX_CMD3}
    airphone_execute_egate_command    ${DTX_CMD4}
	
Attach SA UE1
    Airphone SA Attach    ue_id=${UE_ID}
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal     
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
	
check ue1 bler                    
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_ul_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_dl_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Modify vendor file 72e and full commission for onair
    [Arguments]    ${wait_bts_timeout}=2000    ${wait_rru_timeout}=800    ${wait_onair_timeout}=800
    Modify Swconfig for AP
    Start capture gnb and ap syslog in 'before_onair' file
    Change iphy rru version    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${AIRPHONE_NAME}
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} 'reboot'
    Wait '10s' for stable
    ${scfc_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/SCF/${SCFC_NAME}
    ${cfg_path}    Set variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}/WTS/${WTS_NAME}
    ${new_scfc}    GNB_BASE.Change Vlan Id In Scfc    ${scfc_path}    ${test_log_directory()}/full_commission/
    Configure TL VM ETH
    TAF_ADMIN.Setup Admin
    ${vendor_path}    Set Variable    ${test_log_directory()}/vendor_ini.xml
    TAF_ADMIN.Download Vendor File    ${vendor_path} 
    Modify Vendor betaec XML File    ${vendor_path}
    Modify Vendor xec XML File    ${vendor_path} 
    Modify Vendor 72e XML File    ${vendor_path}
    TAF_ADMIN.Set Vendor File    ${vendor_path}
    ${connission_status}    Run Keyword And Return Status    TAF_ADMIN.Perform Commissioning
    ...    bts_id=${GNB_IP}
    ...    scf_file=${new_scfc}
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=300     
    Log to console    Full Commissioning is ${connission_status}
    TAF_ADMIN.teardown admin
    Wait '120s' for stable
    Run Keyword And Ignore Error    Start collect 'cellsetup' tcpdump
    ${bts_status}=    Run Keyword And Return Status    Wait Unit Bts Configured    ${wait_bts_timeout}
    ${rru_status}=    Run Keyword And Return Status    Wait Until RRU Configured    ${wait_rru_timeout}
    ${onair_status}=    Run Keyword And Return Status    Start Wts And Wait Bts Until Onair     ${cfg_path}
    ...    timeout=${wait_onair_timeout}
    Stop capture gnb and ap syslog in 'before_onair' file
    Log To Console    BTS is onAir now
    Run Keyword And Ignore Error    Stop collect 'cellsetup' tcpdump

Modify Vendor 72e XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_list72e}    Set Variable    text|${ECPRI72E}|//*[@name\="actEcpri72e"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_list72e}    
Modify Vendor betaec XML File 
    [Arguments]    ${vendor_path}  
    ${vendor_listbetaec}    Set Variable    text|${BETAEC}|//*[@name\="betaEc"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listbetaec}      
Modify Vendor xec XML File 
    [Arguments]    ${vendor_path} 
    ${vendor_listxec}    Set Variable    text|${XEC}|//*[@name\="xEc"]  
    Modify Xml    ${vendor_path}    ${vendor_path}    ${vendor_listxec}       
Prepare test
    Add GNB swconfig    0x5801CB:0
	Configure TL VM ETH

Check throughput
    Wait until keyword succeeds    60s    5s    Verify throughput

Verify throughput
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>60000
    should_be_true    ${dl_throughput_pcell}>30000

SEND data to '${ue_id}'
    FOR    ${num}    IN RANGE    1    9	
       Airphone SA Start Data Traffic    ${ue_id}    DL    175M    pdu_id=${ue_id}    duration=6000s    trf_id=${num}   protocol=tcp
    END
    Airphone SA Start Data Traffic    ${ue_id}    UL    175M    pdu_id=${ue_id}    duration=6000s    trf_id=${num}   protocol=tcp
    Wait '5s' for stabible
	
Configure TL VM ETH
    Log To Console    Configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.138/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.139/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.141/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.142/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.143/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.2.92/24 dev eth4
    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.123/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.124/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.125/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.106/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.112/24 dev eth3
