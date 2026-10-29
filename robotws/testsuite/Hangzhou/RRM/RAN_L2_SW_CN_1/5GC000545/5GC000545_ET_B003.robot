*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    ${SWCONFIG_PARAM}    ${SCF_FILE}
#...               AND    Suite Setup Copy WTS Config Files From QT
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD    master_classicalbts_all    STATE_CONFIGURED
#...               Owner_j8shen    CRT    RAN_5G    RAN_5G_FDD    FR1    SBTS00
#Resource          resources/5GC000545_resource.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}                   0x580376=0x5;0x580377=0x2;0x59005a=1;0x59005b=1    # rdTransPrecodeHystThresh 0x580376,SA ptrs flag 0x59005a/b
#${SCF_PATH}                         ${CURDIR}/resources/config
#${SCF_FILE}                         Delta_545_ET_B003.json
#@{LOG_NAME_LIST}                    snapshot
#${UE_ID}                            51
#${UL_TPUT}                          50
#${PCELL_ID}                         3
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
#5GC000545_ET_B003_Dynamic_Transform_Precoder_Switching_With_QPSK_PTRS_Disable_FDD_SA
#    SA UE Attach And Send UL Traffic
#    Trigger TP Enabled And Save GNB BIP Log
#    Egate Console Confirm TP Enabled Keyword
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-B${/}5GC000545-B_Enabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Enable
#    Verify UL Not ACK Rate After TP Enabled    max_crc_nok_rate=${TP_ENABLE_CRC_NOK_RATE}
#    Trigger TP Disabled And Save GNB BIP Log
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-B${/}5GC000545-B_Disabled.ini    i
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