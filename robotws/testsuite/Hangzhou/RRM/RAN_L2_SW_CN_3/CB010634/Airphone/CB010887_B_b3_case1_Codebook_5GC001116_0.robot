*** Settings ***
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    #Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang    SBTS22R4    SBTS23R1
...   CLOUD_5G_I_MP_AP_LO    
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      scfc_10887_B_b3_case1_1116_0ms.xml
${AIRPHONE_NAME}    10887_iphy_TDD_eCPRI_7_2e.xml
${WTS_NAME}    basic_setup_TDD_eCPRI_7_2e.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${X2_CMD}         enb_x2_link_up enb\=1 target\=2
${DTX_CMD5}        ue_srs_beam_pos_nr profile_id\=3 srsMode\=fixed init_pos\=1
${DTX_CMD6}       ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=3
${DTX_CMD3}        cell_srs_beam_pos_nr profile_id\=1 num_of_ue_positions\=4 azimuth\=0,30,-30,60
${DTX_CMD4}       cell_testmode_set_nr cell_id\=1 gnb\=2 testmode\=cell_srs_beam_pos profile_id\=1 action\=activate
${DTX_CMD}        ue_srs_beam_pos_nr profile_id\=2 srsMode\=fixed init_pos\=1 dtx_start\=0 num_dtx\=10
${DTX_CMD1}       ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=2
${SINR_1}         ul_sinr_testmode_nr profile_id\=5 sinr_target_srs\=-200 sinr_target_pucch\=-200 noise_srs\=-1053
${SINR_2}         ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=5
${DELETE}       ue_srs_beam_pos_nr profile_id\=2 delete=true
${BIP_TAG}    72E
${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
@{titles}   DlData_DciInfo.patternId_item
${ECPRI72E}	Ecpri72eUL
${BETAEC}	13
${XEC}	14
${UE_ID1}          1
${UE_ID2}         2
${NLOSS_PROFIL1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=0 srs_transmit_power_per_port\=-400,-400,-400,-400

*** Test Cases ***
CB010887_B_b3_case1_Codebook_SRS_best_beam_determination_for_CSI_RS_PDSCH_PDCCH_SA_5GC001116_0
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
    Modify vendor file 72e and full commission for onair
	airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
    Attach SA ue to 5g cell    No_tas_SRS_Ports_PerResource2    ${UE_ID2}    PDU_ID=${UE_ID2}   GW_ID=${UE_ID2}
    SA send dl and ul data    ${UE_ID2}    number=6    dl_data=175M    ul_data=30M	    pdu_id=${UE_ID2}
    Airphone Execute Egate Command    ${NLOSS_PROFIL1}
    Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
    run keyword and continue on failure    Check ue2 throughput
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'ttiue2'
	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
    Stop capture gnb and ap syslog in 'after_onair' file      
                   
*** Keywords ***
check ue2 bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_ul_ue2.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All	
	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_dl_ue2.ini    log_need_to_check=i
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
    #Modify l1bypass
    #pdcch dftbeam
    Add GNB swconfig    0x580434:0
    Add GNB swconfig    0x450027:1
    Add GNB swconfig    0x5900B9:1
    
Check throughput
    Wait until keyword succeeds    60s    5s    Verify ue1 throughput

Check ue2 throughput
    Wait until keyword succeeds    60s    5s    Verify ue2 throughput

Verify ue2 throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>130000	
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>1000000



