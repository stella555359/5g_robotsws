*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    ${SWCONFIG_PARAM}    ${SCF_FILE}
...               AND    Suite Setup Copy WTS Config Files From QT
...               AND    Suite Setup Start WTS And Check OnAir
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD    FR1    Owner_Melwu
...               SBTS00    SBTS23R1    SBTS22R4
Resource          resources/5GC000545_resource.robot

*** Variables ***
${SWCONFIG_PARAM}                   0x580376=0x5;0x580377=0x2;0x59000c=0x1;0x59000d=0x1    #NSA ptrs flag 0x59000c/d
${SCF_PATH}                         ${CURDIR}/resources/config
${SCF_FILE}                         Delta_545_ET_C005.json
@{LOG_NAME_LIST}                    snapshot
${UE_ID}                            101
${UL_TPUT}                          50
${DATA_DURATION}                    600
${DIR_UL}                           ul
${LOCAL_WTS_DIR}                    ${CURDIR}/resources/wts
${WTS_CFG}                          wts_config_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.cfg
${CHECK_POINT_REGEXP_TPENABLED}     SEPARATOR=    UlData_PuschReceiveReq\\",\\"(?P<sfn>0x\\w+)\\",\\"(?P<slot>0x\\w+)\\",\\"(?P<TP_enable>1)\\",
...                                 \\"(?:0x\\w+)\\".*(\\n.*){1,10}UlData_PuschReceiveRespHarqU\\",+\\"(?P=sfn)\\",\\"(?P=slot)\\",
...                                 \\"(?:0x\\w+)\\",\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
${CHECK_POINT_REGEXP_TPDISABLED}    SEPARATOR=    UlData_PuschReceiveReq\\",\\"(?P<sfn>0x\\w+)\\",\\"(?P<slot>0x\\w+)\\",\\"(?P<TP_enable>0)\\",
...                                 \\"(?:0x\\w+)\\".*(\\n.*){1,10}UlData_PuschReceiveRespHarqU\\",
...                                 +\\"(?P=sfn)\\",\\"(?P=slot)\\",\\"(?:0x\\w+)\\",\\"(?P<harqU_crc>0)\\",\\"(?P<harqU_dtx>0)\\"
${PROFILE_ID}                       1
${GNB_ID}                           2
${CELL_ID}                          1
${BEARER_ID}                        2
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
5GC000545_ET_C005_Dynamic_Transform_Precoder_Switching_With_Pi2BPSK_PTRS_Enable_TDD_NSA
    UE Attach With NSA    ${UE_ID}
    ${ul_tpt}    NSA Get Average Throughput    ${UE_ID}    ${bearer_id}      ul	
	Save Egate Log      ${TEST_LOG_DIRECTORY}
    ${nsa_egate_tp_tag}    OperatingSystem.Grep File    ${TEST_LOG_DIRECTORY}/egate_console.log.001    transformPrecoder enabled
    BuiltIn.Should Be Equal      ${nsa_egate_tp_tag}    ${empty}   
    Trigger TP Enabled And Save GNB BIP Log
    Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-C${/}5GC000545-C_Enabled.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Enable
	Save Egate Log    ${TEST_LOG_DIRECTORY}
    ${nsa_egate_tp_tag}    OperatingSystem.Grep File    ${TEST_LOG_DIRECTORY}/egate_console.log.001    transformPrecoder enabled
    BuiltIn.Should Not Be Equal     ${nsa_egate_tp_tag}    ${empty}   
	Verify UL Not ACK Rate After TP Enabled
    NSA Get UL Tput After TP Enabled And Make Sure Larger Than 0    ${UE_ID}
	Trigger TP Disabled And Save GNB BIP Log
	Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-C${/}5GC000545-C_Disabled.ini    i
    ...    save_log_directory=${TEST_LOG_DIRECTORY}_TP_Disable
	Verify UL Not ACK Rate After TP Disabled
    NSA Get UL Tput After TP Disabled And Make Sure Larger Than 0    ${UE_ID}

*** Keywords ***
Trigger TP Enabled And Save GNB BIP Log    
    NSA Start UL Traffic And Decrease SINR TO Trigger TP Enabled    ${UE_ID}
	Start Gnb BIP Log    180
	Sleep    6s    reason=capture bip log
    Stop Gnb BIP Log    ${test_log_directory}_TP_Enable
    Convert BIP To CSV    ${test_log_directory}_TP_Enable     TP_Enable

Trigger TP Disabled And Save GNB BIP Log    
    Increase SINR Pathloss To Trigger TP Disabled    ${UE_ID}
	Start Gnb BIP Log    180
	Sleep    6s    reason=capture bip log
    Stop Gnb BIP Log    ${test_log_directory}_TP_Disable
    Convert BIP To CSV    ${test_log_directory}_TP_Disable     TP_Disable

UE Attach With NSA
    [Arguments]    ${ue_id}    
    NSA LTE Attach    ${ue_id}    
    Config Endc Parameter
    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    50
    Sleep    6s    reason=wait for traffic stable

NSA Get UL Tput After TP Enabled And Make Sure Larger Than 0
    [Arguments]    ${ue_id}
    ${ul_avg_enabled} =    NSA Get UE Average Traffic    ${ue_id}    2    ul
    Should Be True    ${ul_avg_enabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

NSA Get UL Tput After TP Disabled And Make Sure Larger Than 0
    [Arguments]    ${ue_id}
    ${ul_avg_disabled} =    NSA Get UE Average Traffic    ${ue_id}    2    ul
    Should Be True    ${ul_avg_disabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue

Judge Regular Matches List Not An Empty List
    [Arguments]    ${list}
    ${empty_list}    Create List
    ${judge_list}    Create List    ${empty_list}
    ${non_duplicates_matches_list}     Remove Duplicates    ${list}
    ${status}    Run Keyword And Return Status    Lists Should Be Equal    ${non_duplicates_matches_list}    ${judge_list}
    Should Be True    '${status}'!='True'
	
Convert BIP To CSV
    [Arguments]    ${bip_dir}    ${bip_tag_name}      
    ${filter}=    Set Variable    uldata_puschreceivereq||uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti
    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
    ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfPrb
    ...    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
    Convert BIP To CSV By MCShark   ${bip_dir}/5GBipL2L1_filtering_off.pcap*    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}
    