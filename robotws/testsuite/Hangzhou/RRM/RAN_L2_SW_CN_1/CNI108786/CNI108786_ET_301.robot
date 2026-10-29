*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY}    swconfig_param=${SWCONFIG_PARAM}
#...                        AND    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${WTS_LOCAL}    wts_cfg_file=${WTS_CFG}
#...                        AND    Suite Setup Start WTS And Check OnAir With Egate Log
#Test Setup        Common Test Setup
#Suite Teardown    Common Suite Teardown
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    SBTS00    ST_SG11    CNI108786
##Resource          Resources/CNI108786_resource.robot
#Resource        ../CUDU_L2/common_setup_teardown.robot
#*** Variables ***
#${SWCONFIG_PARAM}                   0x580376=0x5;0x580377=0x2;0x59005a=1;0x59005b=1    # rdTransPrecodeHystThresh 0x580376,SA ptrs flag 0x59005a/b
#${SCF_PATH}                         ${CURDIR}/Config
#${SCF_FILE}                         FULL_SCFC_CNI108786_enable_SRS_enable.xml
#${WTS_CFG}                          CNI108786_LO_AP_LO.cfg
#${WTS_LOCAL}                        ${CURDIR}/Resources/wts
#${IPHY}                             ${CURDIR}/Resources/wts/iphy_CNI108786_LO_AP_LO.xml
#@{LOG_NAME_LIST}                    snapshot
#${UE_ID}                            51
#${UL_TPUT}                          50
#${PCELL_ID}                         3
#${DATA_DURATION}                    300
#${TP_ENABLE_CRC_NOK_RATE}           0.5
#${TP_DISABLE_CRC_NOK_RATE}          0.3
#${A2A_FOLDER}                       CNI108786_ET301
#${DIR_UL}                           ul
#${SRS_PORT2}                        nrofSRS\-Ports ports2
#${SRS_PORT1}                        nrofSRS\-Ports ports1
#${CHECK_POINT_REGEXP_TPENABLED}     SEPARATOR=    \\"UlData_PuschReceiveReq \\",\\"(?P<sfn>\\w+)\\",\\"(?P<slot>\\w+)\\",\\"(?P<rnti>\\w+)\\",
#...                                 \\"(?P<TP_enable>1)\\",.*(\\n.*){1,7}\\"UlData_PuschReceiveRespHarqU \\",\\"(?P=sfn)\\",
#...                                 \\"(?P=slot)\\",\\"(?P=rnti)\\",+\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
#${CHECK_POINT_REGEXP_TPDISABLED}    SEPARATOR=    \\"UlData_PuschReceiveReq \\",\\"(?P<sfn>\\w+)\\",\\"(?P<slot>\\w+)\\",\\"(?P<rnti>\\w+)\\",
#...                                 \\"(?P<TP_enable>0)\\",.*(\\n.*){1,7}\\"UlData_PuschReceiveRespHarqU \\",\\"(?P=sfn)\\",
#...                                 \\"(?P=slot)\\",\\"(?P=rnti)\\",+\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
#@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}
#
#
#*** Test Cases ***
#CNI108786-ET-301_Verify_Dyn_TP_Switching_With_MultiLayer_UlSuMimo_Adapative_Num_Of_SRS_Ports
#    [Tags]    Owner_***    CRT
#    SA UE Attach And Send UL Traffic
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    Trigger TP Enabled And Save GNB BIP Log
#    Egate Console Confirm TP Enabled And SRS PORT1
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    Verify UL Not ACK Rate After TP Enabled    max_crc_nok_rate=${TP_ENABLE_CRC_NOK_RATE}
#    Trigger TP Disabled And Save GNB BIP Log
#    Start And Stop Tti Trace        ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
#    Verify UL Not ACK Rate After TP Disabled    max_crc_nok_rate=${TP_DISABLE_CRC_NOK_RATE}
#    Egate Console Confirm TP Disabled And SRS PORT2
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/${A2A_FOLDER}${/}CNI108786_Enabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Enable
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/${A2A_FOLDER}${/}CNI108786_Disabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Disable
#    Decode TTITRACE LATEST LOG
#
#
#
#*** Keywords ***
#SA UE Attach And Send UL Traffic
#    SA 5G Attach    ${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${UL_Tput}    trf_id=1
#
#Trigger TP Enabled And Save GNB BIP Log
#    Start Gnb BIP Log    180
#    The Third Way To Adjust Pathloos And Sinr To Trigger TP Enabled    ${UE_ID}   ${PCELL_ID}
#    Sleep    6s    reason=wait for bip log collecting
#    Stop Gnb BIP Log    ${test_log_directory}_TP_Enable
#    Convert BIP To CSV    ${test_log_directory}_TP_Enable     TP_Enable
#
#Trigger TP Disabled And Save GNB BIP Log
#    Revert Pathloss And Sinr Based On The Third Way To Trigger TP Disabled    ${UE_ID}
#    Start Gnb BIP Log    180
#    Sleep    6s    reason=wait for bip log collecting
#    Stop Gnb BIP Log    ${test_log_directory}_TP_Disable
#    Convert BIP To CSV    ${test_log_directory}_TP_Disable     TP_Disable
#
#Judge Regular Matches List Not An Empty List
#    [Arguments]    ${list}
#    ${empty_list}    Create List
#    ${judge_list}    Create List    ${empty_list}
#    ${non_duplicates_matches_list}     Remove Duplicates    ${list}
#    ${status}    Run Keyword And Return Status    Lists Should Be Equal    ${non_duplicates_matches_list}    ${judge_list}
#    Should Be True    '${status}'!='True'
#
#Convert BIP To CSV
#    [Arguments]    ${bip_dir}    ${bip_tag_name}
#    ${filter}=    Set Variable    uldata_puschreceivereq||uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti
#    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
#    ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfPrb
#    ...    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
#    Convert BIP To CSV By MCShark   ${bip_dir}/5GBipL2L1_filtering_off.pcap*    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}
#
#
#Start And Stop Tti Trace
#    [Arguments]    ${ttitrace}
#    Start Ttitrace With Streaming Mode
#    Sleep    1s    reason=capture short ttitracelog
#    Stop Ttitrace    l2stream3_ttitrace    ${ttitrace}
#
#Decode TTITRACE LATEST LOG
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/1
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/2
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/3
#
#
#Egate Console Confirm TP Disabled And SRS PORT2
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_Disabled_SRS_port2
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/${A2A_FOLDER}${/}CNI108786_Disabled_SRS_port2.ini    p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/UE${UE_ID}_Disabled_SRS_port2
#
#
#Egate Console Confirm TP Enabled And SRS PORT1
#    Save Egate Log    ${TEST_LOG_DIRECTORY}/UE${UE_ID}_Enabled_SRS_port1
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/${A2A_FOLDER}${/}CNI108786_Enabled_SRS_port1.ini    p
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/UE${UE_ID}_Enabled_SRS_port1
#
#Verify UL Not ACK Rate After TP Enabled
#    [Arguments]    ${max_crc_nok_rate}=0.38
#    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}_TP_Enable    ${max_crc_nok_rate}
#
#Verify UL Not ACK Rate After TP Disabled
#    [Arguments]    ${max_crc_nok_rate}=0.3
#    Verify UL Not ACK Rate Less Than Target    ${test_log_directory}_TP_Disable    ${max_crc_nok_rate}
#
#
#The Third Way To Adjust Pathloos And Sinr To Trigger TP Enabled
#    [Arguments]    ${ue_id}=1    ${pcell_id}=1
#    ${pathloss}    Set Variable    50
#    ${pathloss_adjust_times}    Set Variable    3
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-800
#    ute_wtssim.Execute Egate Command
#    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=${pcell_id} testmode=ul_cell_noise profile_id=1 action=activate
#    Adjust PUSCH Pathloss     ue_id=${ue_id}    pusch_pathloss=${pathloss}    max_num_pusch_pathloss=${pathloss_adjust_times}
#    Sleep   6s    reason=wait for ul sinr adjust
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-500
#    Sleep   6s    reason=wait for senonds then to display ue UL througput
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_stats_nr id=${ue_id} type=pusch
#
#Revert Pathloss And Sinr Based On The Third Way To Trigger TP Disabled
#    [Arguments]    ${ue_id}=1
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=30
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-30
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1
#    Sleep   6s    reason=wait for ul sinr adjust
#
#Adjust PUSCH Pathloss
#    [Arguments]    ${ue_id}=1    ${pusch_pathloss}=80    ${max_num_pusch_pathloss}=8
#    : For    ${index_time}    IN RANGE    1    ${max_num_pusch_pathloss}+1
#    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pusch_pathloss}
#    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_sinr action=activate profile_id=1
#    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1
#    \    ${pusch_pathloss} =    Evaluate    ${pusch_pathloss}+10
#    \    Sleep    2s
