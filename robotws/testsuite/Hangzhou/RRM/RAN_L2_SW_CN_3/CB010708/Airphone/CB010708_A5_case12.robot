*** Settings ***
Documentation    CB010708C
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    #Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_ningyang     CLOUD_5G_I_MP_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      scfc_10708_A5_case12.xml
${AIRPHONE_NAME}    10708_iphy_TDD_eCPRI_7_2e.xml
${WTS_NAME}    10708basic_setup_TDD_eCPRI_7_2e_A5.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${X2_CMD}         enb_x2_link_up enb\=1 target\=2
${BIP_TAG}    72E
${FILTER}           dldata_pdcchsendreq&&!(3gpp.rnti==65535)
@{titles}   DlData_DciInfo.patternId_item
${ECPRI72E}	Ecpri72eULDL
${BETAEC}	13
${XEC}	14
${PROFILE}    ul_ue_beam_pos_nr profile_id\=1 num_beam_paths\=2 azimuth\=-20,20 zenith\=0,0 power\=-300,-300
${SET_PROFILE}    ue_testmode_set_nr id\=1 testmode\=ue_ul_beam_position profile_id\=1 action\=activate
${PROFILE1}    ul_ue_beam_pos_nr profile_id\=2 num_beam_paths\=2 azimuth\=-30,30 zenith\=0,0 power\=-300,-300
${SET_PROFILE1}    ue_testmode_set_nr id\=2 testmode\=ue_ul_beam_position profile_id\=2 action\=activate

*** Test Cases ***
CB010708_A5_case012_B102_8RX_IRC_reception_for_Rank1_Rank2_Rank1_PUSCH_with_SRS_based_Beamforming_one_UE_actFullPwrMode
    Add GNB swconfig     0x9D0000:5
    Add GNB swconfig     0x8000A6:0
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
    Modify vendor file 72e and full commission for onair
	airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
	Test ue2 rank2 pwr1
	Check counter value pwr1
	Detach UE '2'
	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
	sleep    60s
    Stop capture gnb and ap syslog in 'after_onair' file
*** Keywords ***
Set UE1 position1
    Airphone Execute Egate Command    ${PROFILE}
    Airphone Execute Egate Command    ${SET_PROFILE}
Set UE2 position1
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
Test ue2 rank2 pwr1
    Set UE2 position1
    Attach SA UE2 rank2
    Internal UE2 UL data
	Internal UE2 DL data
	run keyword and continue on failure    Check ue2 throughput
	Start collect ttitrace
	Wait for '2s' to stop ttitrace with name'ttiue2'
	run keyword and continue on failure    check ue2 bler
check ue1 bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708_tti_ul_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708_tti_dl_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check ue2 bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708_tti_ul_ue2.ini   log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
	check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708_tti_dl_ue2.ini   log_need_to_check=i
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
    #Modify Vendor 72e XML File    ${vendor_path}
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
    Add GNB swconfig     0x9D0000:15
Check throughput
    Wait until keyword succeeds    60s    5s    Verify ue1 throughput
Verify ue1 throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>100000
	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>900000
Check ue2 throughput
    Wait until keyword succeeds    60s    5s    Verify ue2 throughput
Verify ue2 throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>205000
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>900000
Attach SA UE1 rank1
    Airphone SA Attach    ue_id=${UE_ID}
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
Attach SA UE2 rank2
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal
    Airphone Pdu Session Setup    2    2    ${SLICE_ID}    2
Internal DL data
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=4
	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=5
	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=6
	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=100 seconds\=3000 trf_id\=7
Internal UE2 DL data
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=4
	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=5
	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=6
	airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=100 seconds\=3000 trf_id\=7
Internal UL data
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
Internal UE2 UL data
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=ul mbps\=100 seconds\=3000 trf_id\=2
Check counter value pwr0
    Wait until keyword succeeds    180s    30s    counter value pwr0
counter value pwr0
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01505      cell_id=1
	should be true    ${PM_counter_value_Pcell}==60
Check counter value pwr1
    Wait until keyword succeeds    180s    30s    counter value pwr1
counter value pwr1
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}
    ${PM_counter_value_Pcell}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55114C01502      cell_id=1
	should be true    ${PM_counter_value_Pcell}==60