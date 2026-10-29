*** Settings ***
Documentation    This is for feature CB012544 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3

Resource       ./CB012544_SG3_common_keyword.robot
Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot


*** Keywords ***
# --------------------------------12544-A-----------------------------------------#
A_101_test_VM
    change_sync_output_configuration_VM    Modify_Para_Online=${Disable_output_sync}
    A_101_reset_and_check_GNB2_status     connection=GNB1_OAM    gnb_index=${0}
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=GNB1_OAM     gnb_index=${0}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_101    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_101_BIP_02}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_101
    ...                                                                        target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A101    file_path=${A_101_BIP_02}[0]
    [Teardown]     run keyword and ignore error     COAM Save snapshot via api     gnb_index=${0}
    ...                                                                            log_path=${TS_CASE_LOG_PATH}/

change_sync_output_configuration_VM
    [Arguments]      ${Modify_Para_Online}     ${enb_index}=${0}     ${connection}=ENB_OAM
    ...    ${enb_host}=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${enb_username}=${tl.gnbs[${enb_index}].cu.oam_http_connection_details.username}
    ...    ${enb_password}=${tl.gnbs[${enb_index}].cu.oam_http_connection_details.password}
    Wait until keyword succeeds    10min    5s    coam.connect_to    bts_host=${enb_host}    bts_port=${443}
    ...    username=${enb_username}    password=${enb_password}    name=${connection}
    COAM Update Several Parameters Via Rest Api     connection=${connection}
    ...                                      parameters_to_update_via_api=${Modify_Para_Online}    timeout=5min
    ...                                      skip_parameter_relation_errors=True
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

A_102_test_VM
    A_102_Remove_NTP_for_GNB2_and_Rest    gnb_index=${0}    connection=GNB1_OAM    Delete_Mo_Online=${Delete_NTP_Mo_VM}
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=GNB1_OAM     gnb_index=${0}
    Check Expect Alarm whether exist     Expect_alarm=4405    connection=GNB1_OAM     gnb_index=${0}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_102    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_102_BIP_01}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_102
    ...                                                                        target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_102_BIP_01}[0]
    [Teardown]     Run Keywords
    ...            change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    ...     AND    Reset site with BTS for 12544    gnb_index=${0}    connection=GNB1_OAM
    ...     AND    COAM Wait For Gnb Ready And Cell Setup    gnb_type='SA'    connection=GNB1_OAM    gnb_index=${0}

A_B_C_005_test_part1_VM
    change_sync_output_configuration_VM    Modify_Para_Online=${Disable_output_sync}
    sleep     6min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB1_OAM     gnb_index=${0}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4153    connection=GNB1_OAM     gnb_index=${0}
    [Teardown]    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}

A_B_C_005_test_part2_VM
    [Arguments]     ${gnb_index}=${0}    ${connection}=GNB1_OAM
    Common Case TestLine Setup with singe BTS     gnb_index=${gnb_index}
    ...                                           ModifySCF_Aftercommission=True
    ...                                           Modify_Para_Online=${Online_modify_ABC_005_part2_VM}
    Reset Site With BTS For 12544     gnb_index=${gnb_index}     connection=${connection}
    sleep     5min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=${connection}     gnb_index=${gnb_index}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4404    connection=${connection}     gnb_index=${gnb_index}
    [Teardown]    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}

A_B_C_005_test_covery_VM
    [Arguments]     ${gnb_index}=${0}    ${connection}=GNB1_OAM
    change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    Common Case TestLine Setup with singe BTS     gnb_index=${gnb_index}
    ...                                           ModifySCF_Aftercommission=True
    ...                                           Modify_Para_Online=${Online_modify_ABC_005_part3_VM}
    Reset Site With BTS For 12544     gnb_index=${gnb_index}     connection=${connection}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4153    connection=${connection}     gnb_index=${gnb_index}
    [Teardown]    run keyword and ignore error    COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}

A_B_002_test_part1_VM
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Online_Modify_A_B_002_p1_VM}
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Delete_Para_Online=${Online_Delete_A_B_002_p1_VM}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_01    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_01}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_01
    ...                                                                          target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_01}[0]
    change_sync_output_configuration_VM    Modify_Para_Online=${Disable_output_sync}
    A_101_reset_and_check_GNB2_status     connection=GNB0_OAM    gnb_index=${0}    current_snycmode=FreqSync
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB0_OAM     gnb_index=${0}
    Check Expect Alarm whether exist     Expect_alarm=4405    connection=GNB0_OAM     gnb_index=${0}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_02    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_02}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_02
    ...                                                                          target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_02}[0]
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Online_Modify_A_B_002_p2_VM}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_03    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_03}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_03
    ...                                                                          target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_03}[0]
    block unblock all cells action for 12544    gnb_index=${0}
    reset all cells action for 12544    gnb_index=${0}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_04    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_04}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_04
    ...                                                                          target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_04}[0]
    [Teardown]     Run Keywords
    ...     change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    ...     AND    run keyword and ignore error     COAM Save snapshot via api     gnb_index=${0}    log_path=${TS_CASE_LOG_PATH}/
    ...     AND    sleep    30s        reason=wait for alarm raised.
    ...     AND    Check Expect Alarm whether exist     Expect_alarm=4001    connection=GNB1_OAM     gnb_index=${0}
    ...     AND    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4404    connection=GNB1_OAM     gnb_index=${0}
    ...     AND    Reset Site With BTS For 12544    gnb_index=${0}    connection=GNB1_OAM
    ...     AND    COAM Wait For Gnb Ready And Cell Setup    gnb_type='SA'    connection=GNB1_OAM    gnb_index=${0}

A_B_002_test_part2_VM
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_05    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_05}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_05
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information AB002    file_path=${A_B_002_BIP_05}[0]
    change_sync_output_configuration_VM    Modify_Para_Online=${Disable_output_sync}
    sleep     5min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB1_OAM     gnb_index=${0}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_06    gnb_index=${0}    times=10s
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    ${A_B_002_BIP_06}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_06
    ...                                                      target_dir=${TS_CASE_LOG_PATH}/
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_06}[0]      #no edrx IE
    ${wireshark_attach_AB002}      _UE_attach_and_enter_idle_VM      tcpdump_collector_name=${AB002_wireshark_attach}    sleep_time=90s
    _check_rrc_inactivity_in_wireshark
    ...                file_path=${wireshark_attach_AB002}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    ...                dist_name=MRBTS-${global_bts_ID}/NRBTS-${MRBTS_ID}    gnb_index=${0}
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_AB002}
    ${wireshark_paging_AB002}     ${AB002_bip_paging}
    ...     _start_traffic_trigger_paging_VM      get_ip_from_cpif=${wireshark_attach_AB002}
    ...                                           tcpdump_collector_name=${AB002_wireshark_paging}
    ...                                           target_file_name=AB002_BIP_paging_07
    ...                                           cellid=${nrcellid3}
    [Teardown]     Run Keywords
    ...     change_sync_output_configuration_VM    Modify_Para_Online=${Recovery_output_sync}
    ...     AND    run keyword and ignore error     COAM Save snapshot via api     gnb_index=${0}
    ...     AND    sleep    180s    reason=wait for alarm clear.
    ...     AND    CB012544_SG3_case_step_cloud_vm.Check UnExpect Alarm Should Not Exsit
    ...               UnExpect_alarm=4404    connection=GNB1_OAM     gnb_index=${0}
    ...     AND    CB012544_SG3_case_step_cloud_vm.Check UnExpect Alarm Should Not Exsit
    ...               UnExpect_alarm=4405    connection=GNB1_OAM     gnb_index=${0}
    ...     AND    CB012544_SG3_case_step_cloud_vm.Check UnExpect Alarm Should Not Exsit
    ...               UnExpect_alarm=1898    connection=GNB1_OAM     gnb_index=${0}
    ...     AND    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...                                          scf_dir_path=${SUITE_LOG_PATH}
    ...                                          scf_path=${Golden_SCF_Path}
    ...                                          golden_scf_name=SCF_${stream}.xml
    ...                                          ParameterToDelete=${delete_for_FDD}
    ...                                          ParamterToModify=${modify_for_FDD}
    ...                                          ListToAdd=${addlist_for_FDD}

A_101_reset_and_check_GNB2_status
     [Arguments]      ${connection}=GNB1_OAM      ${gnb_type}='SA'     ${is_x2_check_from_gnb_needed}=${False}
     ...              ${gnb_index}=${0}    ${current_snycmode}=LoosePhaseAndTimeSync
     Reset site with BTS for 12544     gnb_index=${gnb_index}     connection=${connection}
     COAM Wait for gnb ready and cell setup        connection=${connection}
     ...                                           gnb_type=${gnb_type}
     ...                                           is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
     ...                                           gnb_index=${gnb_index}
     ${snyc_mode}    coam.get_synchronization_information     timeout=60s    connection=${connection}
     should be true    '${snyc_mode}[syncMode]' == '${current_snycmode}'
     log to console    ${snyc_mode}[syncMode]
     [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Reset site with BTS for 12544
    [Documentation]    Reset site with the BTS.
    ...    Site reset status. Examples of returned statuses: ‘Requested’, ‘Accepted’, ‘Waiting for response’,
    ...    ‘Completed’, ‘Rejected’ or dict response if detailed_output is set to True.
    [Arguments]     ${gnb_index}=${0}     ${connection}=GNB1_OAM    ${timeout}=600    ${detailed_output}=${False}
    ...    ${wait_for_reconnection}=${True}     ${graceful_cell_shutdown}=${None}
    Wait until keyword succeeds    10min    5s     Connect to gnb coam via ssl     gnb_index=${gnb_index}     connection=${connection}
    ${Reset_site_status}=    coam.reset_site    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    ...    wait_for_reconnection=${wait_for_reconnection}    graceful_cell_shutdown=${graceful_cell_shutdown}
    [Return]    ${Reset_site_status}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Expect Alarm whether exist
    [Arguments]     ${Expect_alarm}     ${connection}=GNB1_OAM     ${gnb_index}=${0}
    Connect to gnb coam via ssl     connection=${connection}     gnb_index=${gnb_index}
    @{alarm_list}    COAM Get active alarms    connection=${connection}
    ${check_alarm_list}    create list
    FOR    ${alarms}    IN    @{alarm_list}
        ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
        append to list    ${check_alarm_list}    ${alarms_tmp}
    END
    List Should Contain Value    ${check_alarm_list}    ${Expect_alarm}
    [Teardown]     COAM Teardown gnb connections      connection=${connection}

Check UnExpect Alarm Should Not Exsit
    [Arguments]     ${UnExpect_alarm}     ${connection}=GNB1_OAM     ${gnb_index}=${0}
    Connect to gnb coam via ssl     connection=${connection}     gnb_index=${gnb_index}
    @{alarm_list}    COAM Get active alarms    connection=${connection}
    ${check_alarm_list}    create list
    FOR    ${alarms}    IN    @{alarm_list}
       ${alarms_tmp}    Convert To String    ${alarms}[additionalFaultID]
       append to list    ${check_alarm_list}    ${alarms_tmp}
    END
    List Should Not Contain Value    ${check_alarm_list}    ${UnExpect_alarm}
    [Teardown]     COAM Teardown gnb connections      connection=${connection}

A_102_Remove_NTP_for_GNB2_and_Rest
    [Arguments]     ${gnb_index}=${0}     ${connection}=GNB1_OAM      ${Delete_Mo_Online}=${Delete_OBJ_A102}
    Modify Parameters for Cases     gnb_index=${gnb_index}
    ...                             Delete_Mo_Online=${Delete_Mo_Online}
    ...                             connection=${connection}
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=${connection}    gnb_index=${gnb_index}
    Wait until keyword succeeds    10min    5s     Connect to gnb coam via ssl     gnb_index=${gnb_index}     connection=${connection}
    ${snyc_mode}    coam.get_synchronization_information     timeout=60s    connection=${connection}
    should be true    '${snyc_mode}[syncMode]' == 'FreqSync'
    log to console    ${snyc_mode}[syncMode]
    [Teardown]     COAM Teardown gnb connections    connection=${connection}

Check SIB Message Detail Information A101
    [Documentation]     check after change sync to loose phase mode, edrx IE exist, idle
    [Arguments]    ${file_path}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17
    ...                                                                     filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17
    ...                                                                 filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}

Check SIB Message Detail Information AB002
    [Documentation]     check after change sync to loose phase mode, edrx IE exist, idle
    [Arguments]    ${file_path}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17
    ...                                                                     filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17
    ...                                                                 filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}

Check SIB Message Detail Information A102
    [Documentation]     check after change sync to loose phase mode, edrx IE exist, none
    [Arguments]    ${file_path}    ${subcellid}=${0}
    Setup the Pcap File   file_path=${file_path}    filter=dldata_pdschpayloadtbsendreql1sw && 3gpp.rnti == 65535 && 3gpp.subcellid == ${subcellid}
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17
    ...                                                                     filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17
    ...                                                                 filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}


block unblock all cells action for 12544
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}     ${connection_name}=GNB1_OAM
    SiSo_common_keywords.Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    SiSo_common_keywords.Get cell list info    connection=${connection_name}
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    SiSo_common_keywords.Block all cells with BTS    rat=${upper_cell_type}    connection=${connection_name}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Check cell failed status    cell_type=${cell_type}
        ...                                                                                                          connection=${connection_name}
        ...    AND    log to console    \n**start check alarm**\n
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544    connection=${connection_name}
        ...    AND    Sleep    5s    reason=wait for a while between block and unblock action.
        ...    AND    SiSo_common_keywords.Unblock all cells with BTS    rat=${upper_cell_type}    connection=${connection_name}
        ...    AND    SiSo_common_keywords.Check X2 link status from GNB    connection=${connection_name}
        ...    AND    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check cell status    cell_type=${cell_type}
        ...                                                                                                    connection=${connection_name}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544    connection=${connection_name}
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

Get alarms to check for 12544
    [Arguments]     ${connection}=GNB1_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
    FOR  ${alarm}  IN  @{activate_alarms}
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
        Run keyword    Should Not be equal as strings    '${alarm}[faultId]'    '1811'
                                      ...  msg=Current alarm faultId is equal 1811
    END
    ${history_alarms}=    coam.get_historic_alarms    timeout=${300}    connection=${connection}    load_history=${False}
    FOR  ${fault}  IN  @{history_alarms}
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '10'
                                      ...  msg=Current alarm faultId is equal 10
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4527'
                                      ...  msg=Current alarm faultId is equal 4527
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1900'
                                      ...  msg=Current alarm faultId is equal 1900
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6450'
                                      ...  msg=Current alarm faultId is equal 6450
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '16'
                                      ...  msg=Current alarm faultId is equal 16
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1806'
                                      ...  msg=Current alarm faultId is equal 1806
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1868'
                                      ...  msg=Current alarm faultId is equal 1868
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4352'
                                      ...  msg=Current alarm faultId is equal 4352
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4383'
                                      ...  msg=Current alarm faultId is equal 4383
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6911'
                                      ...  msg=Current alarm faultId is equal 6911
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4590'
                                      ...  msg=Current alarm faultId is equal 4590
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4681'
                                      ...  msg=Current alarm faultId is equal 4681
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2087'
                                      ...  msg=Current alarm faultId is equal 2087
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1815'
                                      ...  msg=Current alarm faultId is equal 1815
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '248'
                                      ...  msg=Current alarm faultId is equal 248
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '250'
                                      ...  msg=Current alarm faultId is equal 250
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '6502'
                                      ...  msg=Current alarm faultId is equal 6502
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4341'
                                      ...  msg=Current alarm faultId is equal 4341
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1850'
                                      ...  msg=Current alarm faultId is equal 1850
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4539'
                                      ...  msg=Current alarm faultId is equal 4539
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4663'
                                      ...  msg=Current alarm faultId is equal 4663
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '9100'
                                      ...  msg=Current alarm faultId is equal 9100
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4261'
                                      ...  msg=Current alarm faultId is equal 4261
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '7516'
                                      ...  msg=Current alarm faultId is equal 7516
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '23'
                                      ...  msg=Current alarm faultId is equal 23
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '2056'
                                      ...  msg=Current alarm faultId is equal 2056
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1907'
                                      ...  msg=Current alarm faultId is equal 1907
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1981'
                                      ...  msg=Current alarm faultId is equal 1981
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1920'
                                      ...  msg=Current alarm faultId is equal 1920
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '4547'
                                      ...  msg=Current alarm faultId is equal 4547
        Run keyword    Should Not be equal as strings    '${fault}[faultId]'    '1811'
                                      ...  msg=Current alarm faultId is equal 1811
    END

reset all cells action for 12544
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}     ${connection_name}=GNB1_OAM
    SiSo_common_keywords.Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    SiSo_common_keywords.Reset all cells with BTS    connection=${connection_name}
    ${cell_list}=    SiSo_common_keywords.Get cell list info    connection=${connection_name}
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    SiSo_common_keywords.Check X2 link status from GNB    connection=${connection_name}
        ...    AND    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check cell status    cell_type=${cell_type}
        ...                                                                                                    connection=${connection_name}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544    connection=${connection_name}
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}
# --------------------------------B_102-----------------------------------------#
B_102 set_actEdrx and check_sib for C003 VM
    [Documentation]    for TL362, CELL1 from idle to none; CELL3 from idle+inactive to idle
    [Arguments]     ${target_file_name}=BIPlog_B102_inactive
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C003_VM}
    ${B_102_bip_C003}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ...                                                                    target_dir=${TS_CASE_LOG_PATH}
    ${dci_frame_number_cell3}    ${frame_time_cell3}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C003}
    ${final_pcap_file_cell3}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C003}    frame_time=${frame_time_cell3}
    Check SIB Message Detail Information C003    file_path=${final_pcap_file_cell3}    frame_time=${frame_time_cell3}    subcellid=${2}
    ${dci_frame_number_cell1}    ${frame_time_cell1}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C003}
    ${final_pcap_file_cell1}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C003}    frame_time=${frame_time_cell1}
    Check SIB Message Detail Information D002     file_path=${final_pcap_file_cell1}    frame_time=${frame_time_cell1}

B_102 set_actEdrx and check_sib for D001 VM
    [Documentation]    for TL362, CELL1 from idle to idle+inactive; CELL3 from none to idle+inactive
    [Arguments]     ${target_file_name}=BIPlog_B102_idleinactive
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_D001_VM}
    ${B_102_bip_D001}    Online_modify_edrx_and_capture_bip_from_WEBEM_for_VM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ...                                                                    target_dir=${TS_CASE_LOG_PATH}/
    ${dci_frame_number_cell3}    ${frame_time_cell3}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_D001}
    ${final_pcap_file_cell3}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_D001}    frame_time=${frame_time_cell3}
    Check SIB Message Detail Information D001    file_path=${final_pcap_file_cell3}    frame_time=${frame_time_cell3}


B_102 set_actEdrx and check_sib for C001 VM
    [Documentation]    for TL362, CELL1 from idle+inactive to none; CELL3 from none to idle
    [Arguments]     ${target_file_name}=BIPlog_B102_idle
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C001_VM}
    ${B_102_bip_C001}    Online_modify_edrx_and_capture_bip_from_WEBEM_for_VM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ...                                                                    target_dir=${TS_CASE_LOG_PATH}/
    ${dci_frame_number_cell3}    ${frame_time_cell3}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C001}    subcellid=${0}
    ${final_pcap_file_cell3}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C001}    frame_time=${frame_time_cell3}
    Check SIB Message Detail Information C001    file_path=${final_pcap_file_cell3}    frame_time=${frame_time_cell3}    subcellid=${0}

Online_modify_edrx_and_capture_bip_from_WEBEM_for_VM
    [Arguments]     ${target_file_name}    ${Online_modify_actEdrx}
    ...             ${gnb_index}=${0}    ${target_dir}=${epc_log_path}
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${Online_modify_actEdrx}
    ${bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI   target_dir=${target_dir}
    ...                                                                                      target_file_name=${target_file_name}
    [Return]     ${bip_paging}[0]
# --------------------------------C_001-----------------------------------------#

C_001 check_user_inactivity_in_wireshark
    [Arguments]      ${file_path}
    ${user_inactivity}     Check user-inactivity in UEContextRR     file_path=${file_path}
    run keyword and continue on failure
    ...     should contain x times    ${user_inactivity}    radioNetwork: user-inactivity (20)     1
    run keyword and continue on failure
    ...     should not contain    ${user_inactivity}     radioNetwork: radio-connection-with-ue-lost (21)

C_001 check_logs vm
    [Arguments]      ${wireshark_attach_C001}      ${wireshark_paging_C001}     ${C_001_bip_paging}
    ...              ${gnb_index}=${0}
    Check EDRX_Parameters in Registration     file_path=${wireshark_attach_C001}
    Check RedCapIndication in Registration     file_path=${wireshark_attach_C001}
    ${Paging_eDrx_cycle}     ${Paging_eDrx_window}     Check paging_info in paging_wireshark    file_path=${wireshark_paging_C001}
    run keyword and continue on failure
    ...     should be true    '${Paging_eDrx_cycle}' == 'hf2' and '${Paging_eDrx_window}' == 's1'
    Check GNB_IP in InitialcontexSetupResponse    file_path=${wireshark_paging_C001}
    ...                                           GNB_Address=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ${paging_tmsi}     Check paging_tmsi in bip    file_path=${C_001_bip_paging}    subcellid=${0}
    run keyword and continue on failure     Should Not Be Empty     ${paging_tmsi}
    [Teardown]     run keyword and ignore error     COAM Save snapshot via api    log_path=${TS_CASE_LOG_PATH}

check counters for C_001 VM
    [Arguments]      ${counter_id}=${counter_id_C001_VM}
    ...              ${dic_path}=${counter_dic_path_C001_VM}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #M55119C02502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}     #M55119C01501
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #M55331C00001

# --------------------------------C_003&D_002-----------------------------------------#
check counters for D_002 vm
    [Arguments]      ${counter_id}=${counter_id_D002_VM}
    ...              ${dic_path}=${counter_dic_path_D002_VM}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${0}     #M55117C04503
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${0}     #M55331C00007
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #M55331C00001

D_002_check_logs_VM
    [Arguments]     ${wireshark_paging_D002}
    ${cell3_hex}    translate cellid to hex     nrcellid_value=${nrcellid3}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_D002}    cellid_hex=${cell3_hex}
    [Teardown]     run keyword
    ...     Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                                    Add_Para_Online=${online_recovery_D002_VM}

check counters for C_003 VM
    [Arguments]      ${counter_id}=${counter_id_C003_VM}
    ...              ${dic_path}=${counter_dic_path_C003_VM}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}      #M55119C02502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}      #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}      #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}      #M55119C01501
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}      #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}

C_003_check_logs_VM
    [Arguments]      ${C_003_bip_paging}     ${wireshark_paging_C003}
    ${cell3_hex}    translate cellid to hex     nrcellid_value=${nrcellid3}
    ${paging_tmsi_C003}    Check paging_tmsi in bip      file_path=${C_003_bip_paging}    subcellid=${0}
    BuiltIn.Should Not Be Empty     ${paging_tmsi_C003}
    Check GNB_IP in InitialcontexSetupResponse    file_path=${wireshark_paging_C003}
    ...                                           GNB_Address=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ${Paging_eDrx_cycle}     ${Paging_eDrx_window}
    ...     Check paging_info in paging_wireshark     file_path=${wireshark_paging_C003}
    should be true     '${Paging_eDrx_cycle}' == 'hf2' and '${Paging_eDrx_window}' == 's1'
    [Teardown]     Run keyword
    ...    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                                   Modify_Para_Online=${Recovery_C_003_VM}

# --------------------------------D_001-----------------------------------------#
check counters for D_001 VM
    [Arguments]      ${counter_id}=${counter_id_D001_VM}
    ...              ${dic_path}=${counter_dic_path_D001_VM}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #'M55117C04503'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #'M55331C00005'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}     #'M55331C00007'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #'M55331C00001'

D_001 check_logs VM
    [Arguments]     ${wireshark_attach_D001}    ${wireshark_paging_D001}    ${D_001_bip_paging}
    ${ue_capability_item}    Check UE_capability in wireshark    file_path=${wireshark_attach_D001}
    run keyword and continue on failure     Should Be True    '${ue_capability_item}' == 'supported'
    ${cell3_hex}    translate cellid to hex     nrcellid_value=${nrcellid3}
#    ${paging_tmsi_list_1}     Check paging_tmsi in bip      file_path=${D_001_bip_paging}    subcellid=1
    ${paging_tmsi_list_0}     Check paging_tmsi in bip      file_path=${D_001_bip_paging}    subcellid=0
    Check SIB Message Detail Information D001 new    file_path=${D_001_bip_paging}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_D001}    cellid_hex=${cell3_hex}

A_B_C_005_checkpoint_VM
    [Arguments]     ${ABC005_bip_paging_part1}    ${wireshark_paging_ABC005_part1}
    ...    ${counter_id}=${counter_id_ABC005_VM}    ${dic_path}=${counter_dic_path_ABC005_VM}    ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #'M55331C00007'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #'M55331C00004'
    Check SIB Message Detail Information A102    file_path=${ABC005_bip_paging_part1}
    ${cell3_hex}    translate cellid to hex     nrcellid_value=${nrcellid3}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_ABC005_part1}    cellid_hex=${cell3_hex}

Check SIB Message Detail Information D001 new
    [Documentation]     check after recovery from ABC005, EDRX IE should all exist.
    [Arguments]    ${file_path}
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}

###------------------------------------------9384---------------------------------------------------###
check counters for 12bit
    [Arguments]      ${counter_id}=${counter_id_9384_12bit}
    ...              ${dic_path}=${counter_dic_path_9384_12bit}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #M55166C00011
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #M55166C00012
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #M55138C00057
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${0}     #M55166C00014
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${0}     #M55166C00015
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${0}     #M55166C00016
    run keyword and continue on failure     should be true    ${counter_value[6]} > ${100}    #M55138C00056
    run keyword and continue on failure     should be true    ${counter_value[7]} == ${1}     #M55166C00013 for release check

check wireshark log for IE and 12bit
    [Arguments]    ${wireshark_IE_check}    ${wireshark_attach_12bit}
    Check IE from server request msg    file_path=${wireshark_IE_check}
    Check SN length    file_path=${wireshark_attach_12bit}


Check IE from server request msg
    [Documentation]    Author:jia-rebecca.liu@nokia-sbell.com
    [Arguments]    ${file_path}    ${TMSI_index}=5
    ${TMSI_IE_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//_[${TMSI_index}]/ngap.ProtocolIE_Field_element/ngap.value_element/ngap.FiveG_S_TMSI_element
    ...            attribute_name=showname
    ${TMSI_IE}     String.Split String     ${TMSI_IE_pre}[0]    ${SPACE}
    should contain    ${TMSI_IE}[0]     FiveG-S-TMSI
    ${REDCAP_index}    Evaluate    ${TMSI_index}+1
    ${RedCapIndication_pre}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=ngap
    ...            filter_expression=ngap.initiatingMessage_element
    ...            xpath=.//_[${REDCAP_index}]/ngap.ProtocolIE_Field_element/ngap.value_element/ngap.RedCapIndication
    ...            attribute_name=showname
    ${RedCapIndication}     String.Split String     ${RedCapIndication_pre}[0]    ${SPACE}
    should contain    ${RedCapIndication}[1]     redcap

Check SN length
    [Arguments]    ${file_path}
    Log    PDCP SN length check
    ${pdcp_ul_sn_length}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.procedureCode == 12
    ...            xpath=.//nr-rrc.pdcp_SN_SizeDL
    ...            attribute_name=show
    should be equal    ${pdcp_ul_sn_length[0]}    0
    ${pdcp_dl_sn_length}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.procedureCode == 12
    ...            xpath=.//nr-rrc.pdcp_SN_SizeUL
    ...            attribute_name=show
    should be equal    ${pdcp_dl_sn_length[0]}    0
    Log    RLC SN length check
    ${rlc_am_ul_sn_length}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.procedureCode == 12
    ...            xpath=.//nr-rrc.ul_AM_RLC_element/nr-rrc.sn_FieldLength
    ...            attribute_name=show
    should be equal    ${rlc_am_ul_sn_length[0]}    0
    ${rlc_am_dl_sn_length}    Check Target Item Value on cpif_Tcpdump log    file_path=${file_path}
    ...            filter=f1ap
    ...            filter_expression=f1ap.procedureCode == 12
    ...            xpath=.//nr-rrc.dl_AM_RLC_element/nr-rrc.sn_FieldLength
    ...            attribute_name=show
    should be equal    ${rlc_am_dl_sn_length[0]}    0

Check RLC AM SN length
    [Arguments]    ${logname}    ${length_id}
    ...    ${message_filter}=f1ap.procedureCode == 12
    ...    ${xpath1}=.//${12b_xpath1}${12b_xpath2}${12bit_ul_xpath}
    ...    ${xpath2}=.//${12b_xpath1}${12b_xpath2}${12bit_dl_xpath}
    Log    RLC AM SN length check
    ${rlc_am_ul_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath1}
    should be equal    ${rlc_am_ul_sn_length[0]}    ${length_id}
    ${rlc_am_dl_sn_length}=    Check wireshark log    logname=${logname}    message_filter=${message_filter}    xpath=${xpath2}
    should be equal    ${rlc_am_dl_sn_length[0]}    ${length_id}

check counter for failure scenario
    [Arguments]      ${counter_id}=${counter_id_failure_scenario}
    ...              ${dic_path}=${counter_dic_path_failure_scenario}
    ...              ${gnb_index}=${0}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${counter_value[1]}     #M55166C00011 == #M55166C00015

