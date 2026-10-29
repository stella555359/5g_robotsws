*** Settings ***
Documentation    CB010708
Test Timeout    120 minutes
Suite Setup    Common Suite Setup
Suite Teardown    #Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_menzheng
...   CLOUD_5G_I_MP_AP_LO
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      scfc_10708_C1_case25.xml
${AIRPHONE_NAME}    10708C_iphy_TDD_eCPRI_7_2e.xml
${WTS_NAME}    10708basic_setup_TDD_eCPRI_7_2e_C1.cfg
@{LOG_NAME_LIST}    gnb_snapshot    sosreport    egatelog
${UE_ID}          1
${PDU_ID}         1
${GW_ID}          1
${SLICE_ID}       1
${UE_NUM}         2
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
${ECPRI72E}	Ecpri72eULDL
${BETAEC}	13
${XEC}	14
${PROFILE}    ul_ue_beam_pos_nr profile_id\=1 num_beam_paths\=2 azimuth\=0,20 zenith\=0,0 power\=-300,-300
${SET_PROFILE}    ue_testmode_set_nr id\=1 testmode\=ue_ul_beam_position profile_id\=1 action\=activate
${PROFILE1}    ul_ue_beam_pos_nr profile_id\=2 num_beam_paths\=2 azimuth\=-30,30 zenith\=0,0 power\=-300,-300
${SET_PROFILE1}    ue_testmode_set_nr id\=2 testmode\=ue_ul_beam_position profile_id\=2 action\=activate

*** Test Cases ***
CB010708_C1_case025_B102_one_SA_UE_UL_best_beam_determination_for_16RX_PUSCH_1208
    Prepare test
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
    Modify vendor file 72e and full commission for onair
    airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
    Attach ue1
    Attach ue2
    Check throughput
    Check ue1ue2 pair
    Detach SA UEs
    online change actUlMuMimoTapering
    Attach ue1
    Attach ue2
    Check throughput
    Check ue1ue2 pair again
    Detach SA UEs
    run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
Set UE1 position1
    Airphone Execute Egate Command    ${PROFILE}
    Airphone Execute Egate Command    ${SET_PROFILE}

Set UE2 position1
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}

online change actUlMuMimoTapering
    Log To Console    online change actUlMuMimoTapering...
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    parameter=actUlMuMimoTapering
    ...    operation=update    value=true    skip_parameter_relation_errors=True    should_activate=True    connection=online
    TAF_ADMIN.teardown admin    connection=online
    Wait '50s' for stabible

Attach ue1
    Set UE1 position1
    Attach SA UE1
    Internal UL data
    Internal DL data

Attach ue2
    Set UE2 position1
    Attach SA UE2
    Internal UE2 UL data
    Internal UE2 DL data

Detach SA UEs
    FOR    ${num}    IN RANGE    1    ${UE_NUM}+1
        airphone_sa_detach    ue_id=${num}
        Wait '3s' for stabible
    END

Check throughput
    run keyword and continue on failure    Check ue1 throughput
    run keyword and continue on failure    Check ue2 throughput

Check ue1ue2 pair
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti1'
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708C_case25_ul1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

Check ue1ue2 pair again
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti2'
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10708C_case25_ul2.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

check ue1 bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_ul_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case1_tti_dl_ue1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All
check ue2 bler
    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/10887case1_tti_ul_ue2.ini    log_need_to_check=i
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
    Add GNB swconfig    0x580816:0	#rdSuSinrFlag16RX default is true
    Add GNB swconfig    0x8000A6:0	#enabledNewCeFrameworkFlagInDu default is true

Check ue1 throughput
    Wait until keyword succeeds    60s    5s    Verify ue1 throughput
Verify ue1 throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>180000
	${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>450000
Check ue2 throughput
    Wait until keyword succeeds    60s    5s    Verify ue2 throughput
Verify ue2 throughput
    ${ul_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pusch    tput_type=ave
    should_be_true    ${ul_throughput_pcell}>180000
    ${dl_throughput_pcell}    airphone_get_throughput_on_specific_scell    ue_id=2    scell_id=0    type=pdsch    tput_type=ave
    should_be_true    ${dl_throughput_pcell}>450000
Attach SA UE1
    Airphone SA Attach    ue_id=${UE_ID}
    airphone_execute_egate_command    set_pdu_param ue\=1 pdu\=1 trf_type\=internal
    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
Attach SA UE2
    Airphone SA Attach    ue_id=2
    airphone_execute_egate_command    set_pdu_param ue\=2 pdu\=2 trf_type\=internal
    Airphone Pdu Session Setup    2    2    ${SLICE_ID}    2
Internal DL data
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=dl mbps\=75 seconds\=3000 trf_id\=4

Internal UE2 DL data
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=2
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=175 seconds\=3000 trf_id\=3
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=dl mbps\=75 seconds\=3000 trf_id\=4

Internal UL data
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 dir\=ul mbps\=75 seconds\=3000 trf_id\=2
Internal UE2 UL data
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=ul mbps\=175 seconds\=3000 trf_id\=1
    airphone_execute_egate_command    trf_data_start ue\=2 pdu\=2 dir\=ul mbps\=75 seconds\=3000 trf_id\=2
