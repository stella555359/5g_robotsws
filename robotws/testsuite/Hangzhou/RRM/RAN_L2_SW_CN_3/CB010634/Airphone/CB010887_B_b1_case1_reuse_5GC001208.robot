*** Settings ***
Documentation    CB010887
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
${SCFC_NAME}      scfc_10887_B_b1_case1_1208.xml
${AIRPHONE_NAME}    10887_iphy_TDD_eCPRI_7_2e.xml
${WTS_NAME}    wts_1086_7_TAS_LO.cfg
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
${ECPRI72E}	Ecpri72eULDL
${BETAEC}	13
${XEC}	14
${disableold1}    ul_ue_beam_pos_nr profile_id\=3 num_beam_paths\=0
${disableold2}    ue_testmode_set_nr id\=2 testmode\=ue_ul_beam_position profile_id\=3 action\=activate

${NLOSS_PROFIL1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-15 zenith\=0 srs_transmit_power_per_port\=-400,-400,-400,-400

*** Test Cases ***
CB010887_B_b1_case1_Single_UE_with_TAS_t2r4_reuse_codebook_SRS_resource_SA_5GC001208
    Get and Update BSR File    par_of_bsr_name=BSR_AVQL_2_H2_ALN60_ARP60_P00_COVERAGE_00420_00002
    Modify vendor file 72e and full commission for onair
	airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
    Different TAS UE SA Register and check
	run keyword and continue on failure    airphone_collect_egate_log_files    ${TEST_LOG_DIRECTORY()}/All    unzip=TRUE
    Stop capture gnb and ap syslog in 'after_onair' file

*** Keywords ***
#UE Id=1 SA t1r2_n1
#UE Id=2 SA t1r4_n1
#UE Id=3 SA t2r4_n2
#UE Id=4 SA t1r4-t2r4_n2
#UE Id=5 SA t1r1_n1
#UE Id=6 SA t2r2_n2
#UE Id=7 SA t4r4_n4
Different TAS UE SA Register and check
    Airphone Execute Egate Command    ${NLOSS_PROFIL1}
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1-7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3

    FOR    ${num}    IN RANGE    1    8
       airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${num} ------
    #tcpdump for f1ap:TxSwitch
       Start collect UE'${num}' tcpdump
       Airphone Execute Egate Command    ul_ue_beam_pos_nr profile_id\=3 num_beam_paths\=0
       Airphone Execute Egate Command    ue_testmode_set_nr id\=${num} testmode\=ue_ul_beam_position profile_id\=3 action\=activate
       Airphone SA Attach    ue_id=${num}
       Airphone Set Traffic Type    ${num}    ${num}    internal
       Airphone Pdu Session Setup    ${num}    ${num}    1    ${num}
       Wait '2s' for stabible
       Stop collect UE'${num}' tcpdump
    #   Check UE'${num}' TxSwitch in attach_tcpdump

       DL and UL data to '${num}'
       run keyword and continue on failure 	Wait Until Keyword Succeeds    3s    2s     check '${num}' throughput

       Check '${num}' PatternId and Bler in ttiTrace
    #   collect and check '${num}' BIP

       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stabible

       check UE '${num}' SRS in RRC log
    END

Check '${UE_ID}' PatternId and Bler in ttiTrace
    Log To Console    Check PatternId and Bler in ttiTrace: UE ${UE_ID}
    Start collect ttitrace
    Wait for '2s' to stop ttitrace with name'tti_UE_${UE_ID}'

    Set test Variable  ${best_patternId}	1343
    Set test Variable  ${1st_patternId}	1343
    Set test Variable  ${2nd_patternId}	1335

    Log To Console    Check ttitrace DL
    Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_dl.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_B_b1_case3_H30_MOAPLO.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

    Log To Console    Check ttitrace UL
    Set test Variable    ${tti_title_tag}		tti_UE_${UE_ID}_ul.csv
    run keyword and continue on failure     check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_ul_B_b1_case3_H30_MOAPLO.ini    log_need_to_check=i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All

#check RRC
check UE '${ue_id}' SRS in RRC log
    Log To Console   check UE ${ue_id} SRS in RRC log
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}   unzip=TRUE
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/RRC_ue${ue_id}_B_b1_case3.ini    log_need_to_check=p
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/egate_UE_${ue_id}

check '${UE_ID}' throughput
     Log To Console    Check throughput UE${UE_ID}
     #${pcell_tp}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave
     #should be true    ${pcell_tp}>300
     ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pusch    tput_type=ave
     ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${UE_ID}    0    type=pdsch    tput_type=ave
     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
     Log To Console		dl ${dl_tput_Mb}
     Log To Console		ul ${ul_tput_Mb}
     Run Keyword If   '${UE_ID}'=='1' or '${UE_ID}'=='5' or '${UE_ID}'=='6'		should be true    ${dl_tput_Mb}>500
     Run Keyword If   '${UE_ID}'=='1' or '${UE_ID}'=='5' or '${UE_ID}'=='6' or '${UE_ID}'=='2'    should be true    ${ul_tput_Mb}>80
     Run Keyword If   '${UE_ID}'!='1' and '${UE_ID}'!='5' and '${UE_ID}'!='6'	should be true    ${dl_tput_Mb}>900
     Run Keyword If   '${UE_ID}'!='1' and '${UE_ID}'!='5' and '${UE_ID}'!='6' and '${UE_ID}'!='2'	should be true    ${ul_tput_Mb}>180

collect and check '${ue_id}' BIP
    Start collect bip log
    Wait for '1s' to stop bip log with name'BIP_ue_${ue_id}'

    #   Check PatternId in bip
    Log To Console   Check PatternId in bip

    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
    ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdcch.csv    ${FILTER_1}    ${titles_1}

    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
    ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_pdsch.csv    ${FILTER_2}    ${titles_2}

    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/tcpdump_L2L1_bip_filtering_off.pcap00
    ...    ${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}/bip_csi.csv    ${FILTER_3}    ${titles_3}

	Set test Variable    ${pdcch_patternId}    1313
	#rank 3/4 UE
	Set test Variable   ${csi_patternid}   1043,1043,1049,1049
	Set test Variable   ${csi_patternid}   1043,1043,1049,1049
	Set test Variable   ${pdsch_patternid}   1043,1049
	#rank 1/2 UE
	Run Keyword If    '${ue_id}'=='1' or '${ue_id}'=='5' or '${ue_id}'=='6'    Set test Variable    ${pdsch_patternid}   1043

    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdcch_patternId_1024_case3.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}

    #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pdsch_patternId_1024_case3.ini     i
    #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}

    #run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_csi_patternId_1024_case3.ini     i
    #...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/BIP_ue_${ue_id}

    Log To Console   Check PatternId in bip finisged

#tcpdump
Start collect UE'${ue_id}' tcpdump
    Log To Console    Start collect UE'${ue_id}' tcpdump
    ${executor_oam_vm}    Create Dictionary    host=192.168.255.1    user=toor4nsn    password=oZPS0POrRieRtu
    Start Tcpdump    name=tcp_attach_ue${ue_id}    options= -i any -C 100   remote_info=${executor_oam_vm}

Stop collect UE'${ue_id}' tcpdump
    Log To Console    Stop collect UE'${ue_id}' tcpdump
    Stop Tcpdump    tcp_attach_ue${ue_id}    ${TEST_LOG_DIRECTORY()}/All/tcpdump

Check UE'${ue_id}' TxSwitch in attach_tcpdump
    Log To Console   Check UE'${ue_id}' TxSwitch
    Run Keyword And ignore error    Convert BIP To CSV
    ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/tcp_attach_ue${ue_id}.pcap
    ...    ${TEST_LOG_DIRECTORY()}/All/tcpdump/f1ap.csv    ${FILTER_f1ap}    ${titles_f1ap}

    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tcpdump_attach_ue${ue_id}_B_b1_case3.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/tcpdump

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


DL and UL data to '${UE_ID}'
    Log To Console    DL*4 and UL*3 data  to UE ${UE_ID}
    FOR    ${num}    IN RANGE    1    10
    	Airphone SA Start Data Traffic    ${UE_ID}   DL   165M   pdu_id=${UE_ID}   duration=3600   trf_id=${num}
    END
    Airphone SA Start Data Traffic    ${UE_ID}   UL   175M    pdu_id=${UE_ID}   duration=3600   trf_id=1
    Airphone SA Start Data Traffic    ${UE_ID}   UL   80M    pdu_id=${UE_ID}   duration=3600   trf_id=2
    Wait '3s' for stabible

SOS report LOAPLO start test
    Log To Console    Run SOS start test...
    ${output}=    Run    /opt/wts/latest/startTest.sh >/tmp/startSOS.log
	File Should Exist    /tmp/startSOS.log
	Log To Console    End Run SOS report start test...

SOS report LOAPLO Stop test
    Log To Console    Run SOS Stop test...
    ${output}=    Run    /opt/wts/latest/stopTest.sh >/tmp/stopSOS.log
	File Should Exist    /tmp/stopSOS.log
	Log To Console    End Run SOS report Stop test.....
