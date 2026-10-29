# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    SBTS24R1
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_G1_case01_8D4U_AQQL_1208_100M_SBsize_cellband.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_with_rtPidCapacity.xml
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${WTS_NAME}    wts_8322_G1_TDD_eCPRI_cmwv_SANSA_1S_1CC.cfg
# ${BIP_TAG}    srs
# ${ue_id_1}    1
# 
# ${NLOSS_PROFIL1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-400,-400,-400,-400
# 
# *** Test Cases ***
# CB008322_G1_case01_bfSubbandSize0_100Mhz
#     [Documentation]
#     ...    this case check small prb and beamtype when chbw is 100Mhz，bfSubbandSise is cellband
#     ...    Number of PRBs in DL: 273
#     ...    Number of PRBs in UL: 273
#     ...    RBG Size: 16 & number of RBGs: 18
#     ...    when bfSubbandSise is cellband,the prb is 272,the mid-PRB of the BF sub-band is 135 (prb index from 0 start),the MaxDistPrbSbBeam is 134.
#     Prepare test and bts onair
#     attach sa UE1 and send dlul data
#     set rdSmallPrbLimitStartPrb 0 and rdSmallPrbLimitNumOfPrb 192
#     set rdMinNumPrbSbBeam 200 and rdMaxDistPrbSbBeam 135
#     Check no small PRB start from 0 alloc 192 PRBs and beam type should be RT beam with config_1
#     set rdMinNumPrbSbBeam 200 and rdMaxDistPrbSbBeam 134
#     Check small PRB start from 0 alloc 192 PRBs and beam type should be DFT beam with config_2
#     set rdSmallPrbLimitStartPrb 32 and rdSmallPrbLimitNumOfPrb 240
#     Check no small PRB start from 32 alloc 240 PRBs and beam type should be RT beam with config_3
#     set rdMinNumPrbSbBeam 241 and rdMaxDistPrbSbBeam 102
#     Check small PRB start from 32 alloc 240 PRBs and beam type should be DFT beam with config_4
#     set rdSmallPrbLimitStartPrb 32 and rdSmallPrbLimitNumOfPrb 256
#     Check small PRB start from 32 alloc 241 PRBs and beam type should be DFT or RT beam with config_5
# 
#     Detach SA UE'1'
# 
#     set rdSmallPrbLimitStartPrbOfInitialBWP 0 and rdSmallPrbLimitNumOfPrbOfInitialBWP 32
#     Start collect ttitrace
#     attach sa UE1 and send dlul data
#     Wait for '1s' to stop ttitrace with name'6_tti_initial_bwp_1ue'
#     set rdMinNumPrbSbBeam 241 and rdMaxDistPrbSbBeam 103
#     Check no small PRB start from 32 alloc 241 PRBs and beam type should be RT beam with config_6
#     Detach SA UE'1'
# 
#     set rdSmallPrbLimitStartPrbOfInitialBWP 15 and rdSmallPrbLimitNumOfPrbOfInitialBWP 32
#     Start collect ttitrace
#     run keyword and continue on failure    attach sa UE1 and send dlul data
#     Wait for '1s' to stop ttitrace with name'7_tti_initial_bwp_1ue'
#     Set test Variable    ${tti_title_tag}    7_tti_initial_bwp_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config7_initbwp.ini     i
#         ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
#     set rdSmallPrbLimitStartPrb 32 and rdSmallPrbLimitNumOfPrb 256
#     set rdMinNumPrbSbBeam 241 and rdMaxDistPrbSbBeam 102
#     Check small PRB start from 32 alloc 241 PRBs and beam type should be DFT or RT beam with config_7
#     Detach SA UE'1'
# 
#     #SOS report LOAPLO start test
#     #SOS report LOAPLO Stop test
# 
# *** Keywords ***
# Prepare test and bts onair
#     Active GNB L2 feature debug traces
#     Add gNB RD Parameter to swconfig
#     Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# Add gNB RD Parameter to swconfig
#     #Add GNB swconfig    0x600013:1      #9496 BOAM_RAT_ADAPT
#     #Add GNB swconfig    0x19040F:1      #9496 BOAM_FRONTHAUL
#     #Add GNB swconfig    0x88004b:0      #L1 FH: 9496-A official solution
#     #Add GNB swconfig    0x880031:14     #L1 FH: 3 by default; 14 for official solution
#     #Add GNB swconfig    0x42008E:1      #BOAM DCS
#     #Add GNB swconfig    0x5901E8:1      #CPRT rdActCB009496
#     #Add GNB swconfig    0x880012:1      #to catch history buffer in FH
#     #Add GNB swconfig    0x580556:65535  #rdStartPatternId
#     #Add GNB swconfig    0x580789:1      #rdEnableNiddFor8322 for enable macps nidd
#     Add GNB swconfig	0x580717:0		# rdPdcchApplyToSeparateStreams, default=true
# 
# attach sa UE1 and send dlul data
#     Attach SA ue to 5g cell    CA_P2_8x4_t2r4_n2    ${ue_id_1}    PDU_ID=${ue_id_1}    GW_ID=${ue_id_1}
#     SA UE'1' send '130M' with trf num'8' dl data and '20M' with trf num'1' ul data
#     Airphone Execute Egate Command    ${NLOSS_PROFIL1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# set rdSmallPrbLimitStartPrb ${StartPrb} and rdSmallPrbLimitNumOfPrb ${NumOfPrb}
#     Log To Console   ${\n}-----set rdSmallPrbLimitStartPrb=${StartPrb},rdSmallPrbLimitNumOfPrb=${NumOfPrb} ------
#     Execute Aashell Command     rad -mw 0x5805bd ${StartPrb}
#     Execute Aashell Command     rad -mw 0x5805be ${NumOfPrb}
#     Wait '2s' for stabible
# 
# set rdSmallPrbLimitStartPrbOfInitialBWP ${StartPrb} and rdSmallPrbLimitNumOfPrbOfInitialBWP ${NumOfPrb}
#     Log To Console   ${\n}-----set rdSmallPrbLimitStartPrbOfInitialBWP=${StartPrb},rdSmallPrbLimitNumOfPrbOfInitialBWP=${NumOfPrb} ------
#     Execute Aashell Command     rad -mw 0x5805c0 ${StartPrb}
#     Execute Aashell Command     rad -mw 0x5805c1 ${NumOfPrb}
#     Wait '2s' for stabible
# 
# set rdMinNumPrbSbBeam ${MinNumPrb} and rdMaxDistPrbSbBeam ${MaxDist}
#     Log To Console   ${\n}-----set rdMinNumPrbSbBeam=${MinNumPrb},rdMaxDistPrbSbBeam=${MaxDist} ------
#     Execute Aashell Command     rad -mw 0x5805ba ${MinNumPrb}
#     Execute Aashell Command     rad -mw 0x5805bb ${MaxDist}
#     Wait '2s' for stabible
# 
# Check no small PRB start from 0 alloc 192 PRBs and beam type should be RT beam with config_1
#     run keyword and ignore error    check SA UE'1' dl tput range is '610' to '660' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'1_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    1_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config1.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check small PRB start from 0 alloc 192 PRBs and beam type should be DFT beam with config_2
#     run keyword and ignore error    check SA UE'1' dl tput range is '610' to '660' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'2_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    2_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config2.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check no small PRB start from 32 alloc 240 PRBs and beam type should be RT beam with config_3
#     run keyword and ignore error    check SA UE'1' dl tput range is '640' to '670' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'3_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    3_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config3.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check small PRB start from 32 alloc 240 PRBs and beam type should be DFT beam with config_4
#     run keyword and ignore error    check SA UE'1' dl tput range is '600' to '810' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'4_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    4_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config4.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check small PRB start from 32 alloc 241 PRBs and beam type should be DFT or RT beam with config_5
#     run keyword and ignore error    check SA UE'1' dl tput range is '600' to '810' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'5_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    5_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config5.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check no small PRB start from 32 alloc 241 PRBs and beam type should be RT beam with config_6
#     run keyword and ignore error    check SA UE'1' dl tput range is '600' to '810' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'6_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    6_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config6.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check small PRB start from 32 alloc 241 PRBs and beam type should be DFT or RT beam with config_7
#     run keyword and ignore error    check SA UE'1' dl tput range is '600' to '810' and ul tput range is '10' to '29'
#     Start collect ttitrace
#     Wait for '2s' to stop ttitrace with name'7_tti_1ue'
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    7_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case01_dl_config7.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Check bler and pair ratio without tapering ${tti_tag}
#     Log To Console   ---check tti ---${\n}
#     Set test Variable    ${tti_title_tag}    ${tti_tag}
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_B_b5_case08_without_tapering_ul.ini     i
#     ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# Online change actCoverageNonCoherentUes ${targetValue}
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     Perform online change value    MRBTS-1/NRBTS-1    actCoverageNonCoherentUes    ${targetValue}    online
#     TAF_ADMIN.teardown admin    connection=online
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
# 
# 
# SA UE'${ue_id}' send '${dl_data_size}' with trf num'${dl_trf_num}' dl data and '${ul_data_size}' with trf num'${ul_trf_num}' ul data
#     SA send mutiple trf dl data    ${ue_id}    number=${dl_trf_num}   dl_data=${dl_data_size}    pdu_id=${ue_id}
#     SA send mutiple trf ul data    ${ue_id}    number=${ul_trf_num}   ul_data=${ul_data_size}    pdu_id=${ue_id}
# 
# SA send ue '${ue_id}' mutiple trf '${number}' for each '${ul_data}' UL data
#     SA send mutiple trf ul data    ${ue_id}    number=${number}   ul_data=${ul_data}    pdu_id=${ue_id}
#     Wait Throughput Timer    3s
# 
# collect ‘${tti_duration}' ttitrace with name'${tti_tag}'
#     Start collect ttitrace
#     Wait for '${tti_duration}' to stop ttitrace with name'${tti_tag}'
# 
# 
# Attach one SA UE'${ue_id}'
#     Log To Console   ${\n}-----register SA UE ${ue_id} ------
#     Attach SA ue to 5g cell    SRS_Ports_PerResource2    ${ue_id}    PDU_ID=${ue_id}    GW_ID=${ue_id}
# 
# check SA UE'${ue_id}' dl tput range is '${dl_low_Mb}' to '${dl_high_Mb}' and ul tput range is '${ul_low_Mb}' to '${ul_high_Mb}'
#     Log To Console    ..Check throughput UE${ue_id}
#     ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#     ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#     ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#     Log To Console    dl ${dl_tput_Mb}
#     Log To Console    ul ${ul_tput_Mb}
#     should be true    ${dl_tput_Mb}>=${dl_low_Mb}
#     should be true    ${dl_tput_Mb}<=${dl_high_Mb}
#     should be true    ${ul_tput_Mb}>=${ul_low_Mb}
#     should be true    ${ul_tput_Mb}<=${ul_high_Mb}
# 
# 
# check ue ${ue_id} ${dl_tput} range is ${dl_low} to ${dl_high} ${ul_tput} range is ${ul_low} to ${ul_high}
#     log to console    start to check throughput ${ue_id}
#     should be true    ${dl_tput}>${dl_low}
#     should be true    ${dl_tput}<${dl_high}
#     should be true    ${ul_tput}>${ul_low}
#     should be true    ${ul_tput}<${ul_high}
# 
# Wait for '${time}' to stop ttitrace with name'${tti_tag}'
#     sleep   ${time}
#     ${pcap_path}    Stop GNB Ttitrace With Streaming Mode
#     Decoder Tttirace From Pcap To Csv    ${pcap_path}      ${test_log_directory()}/All/${tti_tag}
# 
# Case Test Teardown
#     run keyword and continue on failure    Stop capture gnb and ap syslog in 'after_onair' file
#     Common Test Teardown
# 
# check ue been released or can not get dl ul tput than run SOS report stop test
#     Wait until keyword succeeds    600s    5s    check Ues been release or dl and ul no tput
# 
# check Ues been release or dl and ul no tput
#     ${status} =	Run Keyword And Return Status	check all ue has dl and ul throughput
#     Should Be True	  ${status} == False
#     Run Keyword If    ${status} == False    SOS report LOAPLO Stop test
# 
# check all ue has dl and ul throughput
#     Wait '10s' for stabible
#     : FOR    ${ue_id}    IN RANGE    1    ${UE_NUM}+1
#     \   Log To Console    Check throughput UE${ue_id}
#      \      ${dl_tput_kb}    ${ul_tput_kb}    Obtain one sa ue dl and ul throught    ${ue_id}   pdu_id= ${ue_id}
#      \      ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
#      \      ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
#      \      Log To Console    dl ${dl_tput_Mb}
#      \      Log To Console    ul ${ul_tput_Mb}
#      \      should be true    ${dl_tput_Mb}>1
#      \      should be true    ${ul_tput_Mb}>100
# 
# SOS report LOAPLO start test
#     Log To Console    Run SOS start test...
#     ${output}=    Run    /opt/wts/latest/startTest.sh >/tmp/startSOS.log
#     File Should Exist    /tmp/startSOS.log
#     Log To Console    End Run SOS report start test...
# 
# SOS report LOAPLO Stop test
#     Log To Console    Run SOS Stop test...
#     ${output}=    Run    /opt/wts/latest/stopTest.sh >/tmp/stopSOS.log
#     File Should Exist    /tmp/stopSOS.log
#     Log To Console    End Run SOS report Stop test.....
