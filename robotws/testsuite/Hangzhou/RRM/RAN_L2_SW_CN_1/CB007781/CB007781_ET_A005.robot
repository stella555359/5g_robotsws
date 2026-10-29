*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    ${SWCONFIG_PARAM}    ${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_BLLL_AP_LOO    FR1    CRT    RAN_5G_FDD    Owner_fanjin
#...               SBTS00    SBTS23R1    SBTS22R4    RAN_5G
#Resource          resources/CB007781_resource.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}                   0x580376=0x5;0x580377=0x2;    #rdTransPrecodeHystThresh 0x580376
#${SCF_PATH}                         ${CURDIR}/resources/config
#${DELTA_FILE}                       ${CURDIR}/resources/config/Delta_7781_ET_A005.json
#${LOCAL_WTS_DIR}                    ${CURDIR}/resources/wts
#${WTS_CFG}                          basic_setup_CB007781.cfg
#@{LOG_NAME_LIST}                    snapshot
#${UE_ID}                            1
#${UL_TPUT}                          50
#${DATA_DURATION}                    300
#${TP_ENABLE_CRC_NOK_RATE}           0.5
#${TP_DISABLE_CRC_NOK_RATE}          0.3
#${DIR_UL}                           ul
#${CHECK_POINT_REGEXP_TPENABLED}     SEPARATOR=    \\"UlData_PuschReceiveReq \\",\\"(?P<sfn>\\w+)\\",\\"(?P<slot>\\w+)\\",\\"(?P<rnti>\\w+)\\",
#...                                 \\"(?P<TP_enable>1)\\",.*(\\n.*){1,7}\\"UlData_PuschReceiveRespHarqU \\",\\"(?P=sfn)\\",
#...                                 \\"(?P=slot)\\",\\"(?P=rnti)\\",+\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
#${CHECK_POINT_REGEXP_TPDISABLED}    SEPARATOR=    \\"UlData_PuschReceiveReq \\",\\"(?P<sfn>\\w+)\\",\\"(?P<slot>\\w+)\\",\\"(?P<rnti>\\w+)\\",
#...                                 \\"(?P<TP_enable>0)\\",.*(\\n.*){1,7}\\"UlData_PuschReceiveRespHarqU \\",\\"(?P=sfn)\\",
#...                                 \\"(?P=slot)\\",\\"(?P=rnti)\\",+\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
#
#*** Test Cases ***
#CB007781_ET_A005_Dynamic_Transform_Precoder_Switching_With_Pi2BPSK_PTRS_Enable_FDD_SA
#    SA UE Attach And Send UL Traffic
#    Trigger TP Enabled And Save GNB BIP Log
#    Egate Console Confirm TP Enabled Keyword
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007781${/}CB007781_Enabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Enable
#    Verify UL Not ACK Rate After TP Enabled    max_crc_nok_rate=${TP_ENABLE_CRC_NOK_RATE}
#    Trigger TP Disabled And Save GNB BIP Log
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/CB007781${/}CB007781_Disabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Disable
#    Verify UL Not ACK Rate After TP Disabled    max_crc_nok_rate=${TP_DISABLE_CRC_NOK_RATE}
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
#    The Third Way To Adjust Pathloos And Sinr To Trigger TP Enabled
#    Sleep    6s    reason=wait for bip log collecting
#    Stop Gnb BIP Log    ${test_log_directory}_TP_Enable
#    Convert BIP To CSV    ${test_log_directory}_TP_Enable     TP_Enable
#
#Trigger TP Disabled And Save GNB BIP Log
#    Revert Pathloss And Sinr Based On The Third Way To Trigger TP Disabled
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
#The Third Way To Adjust Pathloos And Sinr To Trigger TP Enabled
#    ${pathloss}    Set Variable    50
#    ${pathloss_adjust_times}    Set Variable    3
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_cell_noise_testmode_nr profile_id=1 noise_pusch=-800
#    ute_wtssim.Execute Egate Command
#    ...    cmd=cell_testmode_set_nr gnb=2 cell_id=12 testmode=ul_cell_noise profile_id=1 action=activate
#    Adjust PUSCH Pathloss     pusch_pathloss=${pathloss}    max_num_pusch_pathloss=${pathloss_adjust_times}
#    Sleep   6s    reason=wait for ul sinr adjust
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-500
#    Sleep   6s    reason=wait for senonds then to display ue UL througput
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_stats_nr id=1 type=pusch
#
#Revert Pathloss And Sinr Based On The Third Way To Trigger TP Disabled
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=30
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 sinr_target_pusch=-30
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
#    Sleep   6s    reason=wait for ul sinr adjust
#
#Egate Console Confirm TP Enabled Keyword
#    ute_wtssim.Execute Egate Command    sim_log_set flush
#    OperatingSystem.Run    cp /opt/iphy/latest/egate_console.log ${output_dir}/egate_console.log
#    ${egate_tp_tag}    OperatingSystem.Grep File    ${output_dir}/egate_console.log    transformPrecoder enabled
#    Should Not Be Empty    ${egate_tp_tag}
#
#Adjust PUSCH Pathloss
#    [Arguments]    ${pusch_pathloss}=80    ${max_num_pusch_pathloss}=8
#    : For    ${index_time}    IN RANGE    1    ${max_num_pusch_pathloss}+1
#    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${pusch_pathloss}
#    \    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=1 testmode=ul_sinr action=activate profile_id=1
#    \    ute_wtssim.Execute Egate Command    cmd=ul_sinr_testmode_nr profile_id=1
#    \    ${pusch_pathloss} =    Evaluate    ${pusch_pathloss}+10
#    \    Sleep    2s
