# *** Settings ***
# Test Timeout    60 minutes
# Suite Setup    Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup    Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    CLOUD_5G_I_MP_AP_LOOO
# Resource    ../../resources/KISS/robot/common_resource.robot
# Resource    ../../resources/sg10/internal_resource/internal_resource.robot
# 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# ${SCFC_NAME}      SCFC_8322_G1_case05_3cc_ABIP.xml
# ${AIRPHONE_NAME}    IPHY_4T.xml
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${WTS_NAME}    wts_8322_G1_TDD_eCPRI_cmwv_SANSA_3cc_4T.cfg
# ${BIP_TAG}    srs
# ${ue_id_1}    1
# 
# ${NLOSS_PROFIL1}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 test_type\=SRS
# ...   multi_path_config\=true num_of_nlos_paths\=1 azimuth\=-70 zenith\=40 srs_transmit_power_per_port\=-400,-400,-400,-400
# 
# *** Test Cases ***
# CB008322_G1_case05_bfSubbandSize128_60Mhz_RAT1
#     [Documentation]
#     ...    this case check small prb and beamtype when chbw is 100Mhz，bfSubbandSise is cellband
#     ...    Number of PRBs in DL: 162
#     ...    Number of PRBs in UL: 162
#     ...    RBG Size: 16 & number of RBGs: 11
#     ...    when bfSubbandSise is cellband,the prb is 272,the mid-PRB of the BF sub-band is 135 (prb index from 0 start),the MaxDistPrbSbBeam is 134.
#     Prepare test and bts onair
#     attach sa UE1 and send dlul data
#     set rdMinNumPrbSbBeam 49 and rdMaxDistPrbSbBeam 6
#     override to rank1
#     triger Scell addition and rat1 shedule rt beam config_1
#     Detach SA UE'1'
#     set rdMinNumPrbSbBeam 49 and rdMaxDistPrbSbBeam 5
#     attach sa UE1 and send dlul data
#     override to rank1
#     triger Scell addition and rat1 shedule dft beam for small prb config_2
#     Detach SA UE'1'
# 
# *** Keywords ***
# Prepare test and bts onair
#     set sctp rto time
#     Active GNB L2 feature debug traces
#     Add gNB RD Parameter to swconfig
#     Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Prepare gnb onair
#     airphone_cleanup_egate_console_log
#     Start capture gnb and ap syslog in 'after_onair' file
# 
# set sctp rto time
#     ${output}=    Run    sudo sysctl -w net.sctp.rto_min=100
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
#     Airphone SA Attach    ue_id=${ue_id_1}
#     Airphone Set Traffic Type    ${ue_id_1}    ${ue_id_1}    internal
#     Airphone Pdu Session Setup   ${ue_id_1}    ${ue_id_1}    1    ${ue_id_1}
#     Wait '3s' for stabible
#     SA UE'1' send '130M' with trf num'5' dl data and '20M' with trf num'1' ul data
#     Airphone Execute Egate Command    ${NLOSS_PROFIL1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# override to rank1
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15 ri\=0
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     Wait '1s' for stabible
# 
# scell A1 addition
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement_send_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=120
#     Wait '4s' for stabible
# 
# triger Scell addition and rat1 shedule rt beam config_1
#     Start collect ttitrace
#     scell A1 addition
#     Wait for '1s' to stop ttitrace with name'1_tti_1ue'
#     Set test Variable    ${tti_title_tag}    1_tti_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case05_dl_RAT1_rt.ini     i
#         ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# triger Scell addition and rat1 shedule dft beam for small prb config_2
#     Start collect ttitrace
#     scell A1 addition
#     Wait for '1s' to stop ttitrace with name'2_tti_bwp_1ue'
#     Set test Variable    ${tti_title_tag}    2_tti_bwp_1ue_dl.csv
#     run keyword and continue on failure    Check Log With Au2anlysis    ${CURDIR}/ini/tti_G1_case05_dl_RAT1_dft.ini     i
#         ...   save_log_directory=${TEST_LOG_DIRECTORY()}/All
# 
# set rdMinNumPrbSbBeam ${MinNumPrb} and rdMaxDistPrbSbBeam ${MaxDist}
#     Log To Console   ${\n}-----set rdMinNumPrbSbBeam=${MinNumPrb},rdMaxDistPrbSbBeam=${MaxDist} ------
#     Execute Aashell Command     rad -mw 0x5805ba ${MinNumPrb}
#     Execute Aashell Command     rad -mw 0x5805bb ${MaxDist}
#     Wait '2s' for stabible
# 
# Detach SA UE'${UE_ID}'
#     airphone_sa_detach    ue_id=${UE_ID}    timeout=30
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
