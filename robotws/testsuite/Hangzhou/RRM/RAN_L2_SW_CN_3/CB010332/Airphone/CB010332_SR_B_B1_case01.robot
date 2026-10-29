*** Settings ***
Documentation   update
Test Timeout    60 minutes
Suite Setup    Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown
Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LO    SBTS25R2
Resource    ../../resources/KISS/robot/common_resource.robot
Resource    ../../resources/sg10/internal_resource/internal_resource.robot


*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}      SCFC_10332_B_B1_4D4U_AKQJ.xml
${AIRPHONE_NAME}    IPHY_AKQJ_1CELL_MPAPLO.xml
@{LOG_NAME_LIST}    gnb_snapshot    egatelog
${WTS_NAME}    wts_10332_B_case1_MPAPLO.cfg
${BIP_TAG}    srs
${ue_id_1}    1
${filter_csv}   (uldata_srsreceiverespps || uldata_srsreceivereq || uldata_srsposreceivereq || uldata_srsposreceiverespps ||
  ...    itf_l2_ps_pos_meassetupreq_t || itf_l2_ps_pos_meassetupresp || uldata_addressreq || itf_l2_ps_pos_measabortreq ||
  ...    itf_l2_ps_pos_measabortresp || uldata_puschreceiverespps) && !(3gpp.rnti == 65535)
@{title_all}	3gpp.sfn   3gpp.slot   3gpp.rnti   itf_l2_ps_SrsResource.usage    UlData_srsPosReportRequest_t.numOfPrb
    ...    UlData_srsReceiveReqSubcell_t.srsSuMimoEnable    UlData_srsPosReport_t.timeOffsetPos_item    UlData_UePuschReceiveRespPs_t.ulRank

@{Rdparameter}
    ...    0x580556:0x834
    ...    0x5901EB:0
	...    0x5805ae:1


*** Test Cases ***
CB010332_SR_B_B1_case01_Single_UE_SRS_TOE_measurement_basicbeam_set1_L2_L1_interface
    [Documentation]
    ...    CB010332 basic srs test,nsa not support
    ...     https://confluence.ext.net.nokia.com/display/AirPhoneWTS/CB010332-R15+SRS+for+positioning+in+non-beamforming+deployments
    Prepare test
    airphone_cleanup_egate_console_log
    Start capture gnb and ap syslog in 'after_onair' file
    #SOS report LOAPLO start test
    step1:Check one SA UE1 with default cSRS 60
	#SOS report LOAPLO Stop test


*** Keywords ***
Prepare test
    #Active GNB L2 feature debug traces
    #Add GNB swconfig    @{Rdparameter}
	#Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
    Prepare gnb onair

step1:Check one SA UE1 with default cSRS 60
    attach sa UE'1' and send dlul data
    Start collect bip log
    run keyword and continue on failure    Wait for '1s' to stop bip log with name'bip_SA_ue1'
    Start collect ttitrace
	run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_SA_ue1'
	run keyword and continue on failure    check SA UE'1' dl tput range is '8' to '11' and ul tput range is '95' to '100'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_SA_ue1/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/bip_SA_ue1/bip_SA_ue1.csv    ${filter_csv}    ${title_all}
    #run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1
    Set test Variable    ${tti_title_tag}    bip_SA_ue1.csv
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pos_SA_ue1.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_SA_ue1
	Detach SA UE'1'

step2:Check one NSA UE11
	attach nsa UE11 and send dlul data
	Start collect bip log
	run keyword and continue on failure    Wait for '1s' to stop bip log with name'bip_NSA_ue11'
    Start collect ttitrace
	run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_NSA_ue11'
	run keyword and continue on failure    check NSA UE'11' dl tput range is '8' to '10' and ul tput range is '95' to '100'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_NSA_ue11/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/bip_NSA_ue11/bip_NSA_ue11.csv    ${filter_csv}    ${title_all}
	Set test Variable    ${tti_title_tag}    bip_NSA_ue11.csv
	run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pos_NSA_ue11.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_NSA_ue11
	Detach NSA UE'11'

step3:Check one SA UE2 with cSRS 20
    Online recommissioning with delta json file    ${CURDIR}/JSON/delta_cSRS_20.json
    Wait '15s' for stabible
    attach sa UE'2' and send dlul data
    Start collect bip log
    run keyword and continue on failure    Wait for '1s' to stop bip log with name'bip_SA_ue2'
    Start collect ttitrace
	run keyword and continue on failure    Wait for '2s' to stop ttitrace with name'tti_SA_ue2'
	run keyword and continue on failure    check SA UE'2' dl tput range is '9' to '10' and ul tput range is '95' to '100'
	run keyword and continue on failure   Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/bip_SA_ue2/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${TEST_LOG_DIRECTORY()}/All/bip_SA_ue2/bip_SA_ue2.csv    ${filter_csv}    ${title_all}
    #run keyword and continue on failure    check bler and beamtype is correct in ttitrace step1
    Set test Variable    ${tti_title_tag}    bip_NSA_ue11.csv
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/bip_pos_SA_ue2.ini     i
    ...    save_log_directory=${TEST_LOG_DIRECTORY()}/All/bip_SA_ue2
	Detach SA UE'2'

attach sa UE'${ue_id}' and send dlul data
    Attach SA ue to 5g cell    CA_P2_8x4_t2r4_n2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
	airphone_execute_egate_command	ue_precise_positioning_testmode_nr profile_id\=1 positioning_config_list\=1>500:-300
	airphone_execute_egate_command	ue_testmode_set_nr id\=${ue_id} testmode\=ue_precise_positioning profile_id\=1 action\=activate
    SA UE'${ue_id}' send '10M' with trf num'1' dl data and '80M' with trf num'2' ul data

attach nsa UE11 and send dlul data
    Airphone Nsa Attach    11     profile_id=None
    NSA send ue '11' mutiple trf '2' for each '80M' UL data
    NSA send ue '11' mutiple trf '1' for each '10M' DL data


Detach SA UE'${UE_ID}'
    airphone_sa_detach    ue_id=${UE_ID}    timeout=30

Detach NSA UE'${NSA_UE_ID}'
    Airphone NSA Detach    ${NSA_UE_ID}

Attach one NSA UE'${ue_id}'
    #airphone_cleanup_egate_console_log
    Log To Console   ${\n}-----Attach NSA UE ${ue_id} ------
    Airphone Nsa Attach    ${ue_id}     profile_id=None

SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num}' ul data
    SA send mutiple trf dl data    ${ue_id}    number=${dl_trf_num}   dl_data=${dl_data_size}    pdu_id=${ue_id}
    SA send mutiple trf ul data    ${ue_id}    number=${ul_trf_num}   ul_data=${ul_data_size}    pdu_id=${ue_id}

SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
    SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
    Wait Throughput Timer    3s

NSA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num}' ul data
   NSA send ue '${ue_id}' mutiple trf '${dl_trf_num}' for each '${dl_data_size}' DL data
   NSA send ue '${ue_id}' mutiple trf '${ul_trf_num}' for each '${ul_data_size}' UL data

collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
    Start collect ttitrace
    Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'

Multi UE NSA Attach with start ue id '${start_ue_id}' and ue num '${NSA_UE_NUM}'
    FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${NSA_UE_NUM}+1

    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register UE ${ue_id} ------

       Airphone Nsa Attach    ${ue_id}
        SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
        Wait '3s' for stabible
    END

Attach one SA UE'${ue_id}'
    Log To Console   ${\n}-----register SA UE ${ue_id} ------
    Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}

Multi UE SA Register with start ue id '${start_ue_id}' and ue num '${SA_UE_NUM}'
     FOR    ${ue_id}    IN RANGE    ${start_ue_id}    ${SA_UE_NUM}+1

    #   airphone_cleanup_egate_console_log
       Log To Console   ${\n}-----register SA UE ${ue_id} ------

        Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
        SA send dl and ul data    ${ue_id}    number=3    dl_data=175M    ul_data=20M    pdu_id=${ue_id}
        Wait '3s' for stabible
    END


check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
    Log To Console    ..Check throughput UE${ue_id}
    ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
    ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
    ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
    Log To Console    dl ${dl_tput_Mb}
    Log To Console    ul ${ul_tput_Mb}
    should be true    ${dl_tput_Mb}>=${dl_low_Mb}
    should be true    ${dl_tput_Mb}<=${dl_high_Mb}
    should be true    ${ul_tput_Mb}>=${ul_low_Mb}
    should be true    ${ul_tput_Mb}<=${ul_high_Mb}

check NSA UE'${UE_ID}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
    Log To Console    ..Check throughput UE${UE_ID}
    ${dl_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pdsch    tput_type=ave
    ${ul_pcell_kb}    airphone_get_throughput_on_specific_scell    ue_id=${UE_ID}    scell_id=8    type=pusch    tput_type=ave
    ${dl_tput_Mb}    evaluate    ${dl_pcell_kb}/1000
    ${ul_tput_Mb}    evaluate    ${ul_pcell_kb}/1000
    Log To Console    dl ${dl_tput_Mb}
    Log To Console    ul ${ul_tput_Mb}
    should be true    ${dl_tput_Mb}>=${dl_low_Mb}
    should be true    ${dl_tput_Mb}<=${dl_high_Mb}
    should be true    ${ul_tput_Mb}>=${ul_low_Mb}
    should be true    ${ul_tput_Mb}<=${ul_high_Mb}


check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
    log to console    start to check throughput ${ue_id}
    should be true    ${dl_tput}>${dl_low}
    should be true    ${dl_tput}<${dl_high}
    should be true    ${ul_tput}>${ul_low}
    should be true    ${ul_tput}<${ul_high}

Wait for '${time}' to stop ttitrace with name'${tti_tag}'
    sleep   ${time}
    ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
    Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}


Online change actUlMuMimoTapering ${tapering_switch}
    TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    Perform online change value    MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0    actUlMuMimoTapering    ${tapering_switch}    online
    TAF_ADMIN.teardown admin    connection=online


Check bler and cdm with ${tti_tag}
    Log To Console   ${\n}---check tti ---
    Set test Variable    ${tti_title_tag}    ${tti_tag}
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_C_b3_case03_ul.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

Check 4 nsa ue subcell with ${tti_tag}
    Log To Console   ${\n}---check tti ---
    Set test Variable    ${tti_title_tag}    ${tti_tag}
    run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_C_b3_case03_nsa_subcell_ul.ini     i
    ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All

Get all ue's rnti
    airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}/All/egate_UE_all   unzip=TRUE
    ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}/All/egate_UE_all/egate_console.log.001   crnti: (\\d+)
    Set test Variable    ${rnti_1}    ${rnti_list[0]}
    Set test Variable    ${rnti_2}    ${rnti_list[1]}
    Set test Variable    ${rnti_3}    ${rnti_list[2]}
    Set test Variable    ${rnti_4}    ${rnti_list[3]}
    Set test Variable    ${rnti_5}    ${rnti_list[4]}
    Set test Variable    ${rnti_6}    ${rnti_list[5]}
    Set test Variable    ${rnti_7}    ${rnti_list[6]}
    Set test Variable    ${rnti_8}    ${rnti_list[7]}

Case Test Teardown
    run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
    Common Test Teardown

check ue been released or can not get dl ul tput than run SOS report stop test
    Wait until keyword succeeds    600s    5s    check Ues been release or dl and ul no tput

check Ues been release or dl and ul no tput
    ${status} =	Run Keyword And Return Status	check all ue has dl and ul throughput
	Should Be True	  ${status} == False
	Run Keyword If    ${status} == False    SOS report LOAPLO Stop test


check all ue has dl and ul throughput
    Wait '10s' for stabible
    FOR    ${ue_id}    IN RANGE    1    ${UE_NUM}+1
         Log To Console    Check throughput UE${ue_id}
           ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
           ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
           Log To Console    dl ${dl_tput_Mb}
           Log To Console    ul ${ul_tput_Mb}
           should be true    ${dl_tput_Mb}>1
           should be true    ${ul_tput_Mb}>100
    END

NSA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}     UL    ${ul_data}    duration=6000s    trf_id=${num}    protocol=tcp
    END
    Wait Throughput Timer    1s

NSA send ue '${ue_id}' mutiple trf '${number}' for each '${dl_data}' DL data
    FOR    ${num}    IN RANGE    1    ${number}+1
        Airphone NSA Start Data Traffic    ${ue_id}     DL    ${dl_data}    duration=6000s    trf_id=${num}    protocol=tcp
    END
    Wait Throughput Timer    1s

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
