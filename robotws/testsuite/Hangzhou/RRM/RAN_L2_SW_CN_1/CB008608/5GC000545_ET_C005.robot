*** Settings ***
Documentation    ...
#Resource          ../CUDU_L2_AIC/common_aic_setup_teardown.robot
#Resource          resources/5GC000545_resource.robot
#Force Tags        CLOUD_5GC_dR2.0_1vDU_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    RAN_5G    RAN_5G_TDD
#...                FR1    Owner_melwu     master_vDU     SBTS00    SBTS23R1
#Suite Setup       Run Keywords    Common Suite Setup
#...               AND    Update Aic GNB     VDU_SCFC_PATH=${CONFIG_FILE_PATH}/${BRANCH}/${545_VDU_SCFC_PATH}
#...               AND    Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown    debug
#Test Setup        Create Test Directory
#Test Teardown     Common Test Teardown    debug
#
#
#*** Variables ***
#${CONFIG_FILE_PATH}         ${CURDIR}/config
#${545_VDU_SCFC_PATH}       545_vdu_scfc.xml
#${GNB_INDEX}        0
#${LOCAL_WTS_DIR}    ${CURDIR}/config
#${WTS_CFG}          basic_setup_hz_545.cfg
#${ENB_ID}           1
#${GNB_ID}           2
#${UE_ID}            11
#${PROFILE_ID}                   1
#${CELL_ID}                      1
#${BEARER_ID}                    2
#
#*** Test Cases ***
#5GC000545_ET_C005_Dynamic_Transform_Precoder_Switching_With_Pi2BPSK_PTRS_Enable_TDD_NSA
#    NSA LTE Attach    ${UE_ID}     ${profile_id}
#	Config Endc Parameter
#	NSA 5G Attach     ${ue_id}    ${gnb_id}    ${CELL_ID}    ${bearer_id}
#    NSA Start UL Traffic    ${ue_id}    ${bearer_id}    5
#    Sleep    6s    reason=wait for traffic stable
#    ${ul_tpt}    NSA Get Average Throughput    ${ue_id}    ${bearer_id}      ul
#	Save Egate Log      ${TEST_LOG_DIRECTORY}
#    ${nsa_egate_tp_tag}    OperatingSystem.Grep File    ${TEST_LOG_DIRECTORY}/egate_console.log.001    transformPrecoder enabled
#    BuiltIn.Should Be Equal      ${nsa_egate_tp_tag}    ${empty}
#    Trigger TP Enabled And Save GNB BIP Log
#    Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-C${/}5GC000545-C_Enabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/_TP_Enable
#	Save Egate Log    ${TEST_LOG_DIRECTORY}
#    ${nsa_egate_tp_tag}    OperatingSystem.Grep File    ${TEST_LOG_DIRECTORY}/egate_console.log.001    transformPrecoder enabled
#    BuiltIn.Should Not Be Equal     ${nsa_egate_tp_tag}    ${empty}
#	Verify UL Not ACK Rate After TP Enabled
#    NSA Get UL Tput After TP Enabled And Make Sure Larger Than 0
#	Trigger TP Disabled And Save GNB BIP Log
#	Check Log With Au2anlysis    ${CURDIR}${/}A2A/5GC000545-C${/}5GC000545-C_Disabled.ini    i
#    ...    save_log_directory=${TEST_LOG_DIRECTORY}/_TP_Disable
#	Verify UL Not ACK Rate After TP Disabled
#    NSA Get UL Tput After TP Disabled And Make Sure Larger Than 0
#
#
#*** Keywords ***
#Trigger TP Enabled And Save GNB BIP Log
#    NSA Start UL Traffic And Decrease SINR TO Trigger TP Enabled
#	Sleep      2s
#	Start BIP Log     L1BIPL1
#	Sleep      2s     reason=capture bip of enable
#    Stop BIP Log    L1BIPL1     ${test_log_directory}/_TP_Enable
#	Convert BIP To CSV    ${test_log_directory}/_TP_Enable     TP_Enable
#
#Trigger TP Disabled And Save GNB BIP Log
#    Increase SINR Pathloss To Trigger TP Disabled
#	Sleep      10s
#	Start BIP Log      L1BIPL1
#	Sleep      10s     reason=capture bip of disable
#    Stop BIP Log     L1BIPL1     ${test_log_directory}/_TP_Disable
#    Convert BIP To CSV    ${test_log_directory}/_TP_Disable     TP_Disable
#UE Attach With NSA
#    [Arguments]    ${ue_id}
#    NSA LTE Attach    ${ue_id}
#    Config Endc Parameter
#    NSA 5G Attach    ${ue_id}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start UL Traffic    ${ue_id}    ${BEARER_ID}    50
#    Sleep    6s    reason=wait for traffic stable
#
#NSA Get UL Tput After TP Enabled And Make Sure Larger Than 0
#    ${ul_avg_enabled} =    NSA Get Average Throughput    11    2    ul
#    Should Be True    ${ul_avg_enabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue
#
#NSA Get UL Tput After TP Disabled And Make Sure Larger Than 0
#    ${ul_avg_disabled} =    NSA Get Average Throughput    11    2    ul
#    Should Be True    ${ul_avg_disabled}>0    Not care throughput but check tput>0 to avoid ue release abnormal issue
#
#Judge Regular Matches List Not An Empty List
#    [Arguments]    ${list}
#    ${empty_list}    Create List
#    ${judge_list}    Create List    ${empty_list}
#    ${non_duplicates_matches_list}     Remove Duplicates    ${list}
#    ${status}    Run Keyword And Return Status    Lists Should Be Equal    ${non_duplicates_matches_list}    ${judge_list}
#    Should Be True    '${status}'!='True'
#
#
#Get Match List From BIP Csv File
#    [Arguments]    ${bip_csv_log}    ${check_point_regexp}
#    [Documentation]    This keyword is to get match list from bip csv log with the specified regexp.
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${bip_csv_log} | Yes | the file path for bip csv log |
#    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
#    ...
#    ...    Examples:
#    ...    | ${dl_check_point_regexp} | Set Variable | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
#    ...    | Get Match List From BIP Csv File | /home/ute/tcpdumpL2L1_filtering_off_dl_nack.csv | ${dl_check_point_regexp} |
#    ...
#    Log To Console    \nGet Match List From BIP Csv File...
#    ${csv_content}    OperatingSystem.Get File    ${bip_csv_log}
#    @{group_list}    Get Regexp Group List    ${check_point_regexp}
#    @{match_list}    String.Get Regexp Matches    ${csv_content}    ${check_point_regexp}    @{group_list}
#    [Return]    @{match_list}
#
#
#Get Regexp Group List
#    [Arguments]    ${check_point_regexp}
#    [Documentation]    This keyword is to get group name form the specified regexp
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | ${check_point_regexp} | Yes | the regexp for the check point |
#    ...
#    ...    Examples:
#    ...    | @{group_list} | Get Regexp Group List | UlData_PucchReceiveRespHarqD\\",+\\"(?P<NACK>0x\\d+)\\" |
#    ...
#    # @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>
#    # ${group_count}    Get Length    ${group_list}
#    # ${group_count_list}    Evaluate    range(1,${group_count}+1)
#    @{group_list}    String.Get Regexp Matches    ${check_point_regexp}    \\(\\?P\\<(\\w+)\\>    1
#    [Return]    @{group_list}
#
#NSA Start UL Traffic And Decrease SINR TO Trigger TP Enabled
#    [Arguments]    ${max_num_pathloss}=5
#    ${init_pathloss} =    Set Variable    60
#    FOR    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#        ${init_pathloss} =    Evaluate    ${init_pathloss}+10
#        Adjust Sinr Target Pathloss Step By Step    11    ${init_pathloss}
#        Sleep    5s    reason=wait for pathloss up
#    END
#    ute_wtssim.Execute Egate Command    cmd=ue_disp id=${ue_id}
#
#
#Adjust Sinr Target Pathloss Step By Step
#    [Arguments]    ${ue_id}=11    ${sinr_target_pathloss}=60
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1 scell=5
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ul_sinr_testmode_nr profile_id=1
#
#
#Increase SINR Pathloss To Trigger TP Disabled
#    Adjust Sinr Target Pathloss Step By Step    1    90
#    Sleep    3s    reason=wait for pathloss down
#    Adjust Sinr Target Pathloss Step By Step    1    80
#    Sleep    3s    reason=wait for pathloss down
#    Adjust Sinr Target Pathloss Step By Step    1    70
#
#
#Convert BIP To CSV
#    [Arguments]    ${bip_dir}    ${bip_tag_name}
#    ${filter}=    Set Variable    uldata_puschreceivereq||uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti
#    ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
#    ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfPrb
#    ...    UlData_UePuschReceiveRespHarqU_t.crc    UlData_UePuschReceiveRespHarqU_t.dtx
#    Convert BIP To CSV By MCShark   ${bip_dir}/l1bipl1.pcap    ${bip_dir}/Bip_${bip_tag_name}.csv    ${filter}    ${csv_title_list}