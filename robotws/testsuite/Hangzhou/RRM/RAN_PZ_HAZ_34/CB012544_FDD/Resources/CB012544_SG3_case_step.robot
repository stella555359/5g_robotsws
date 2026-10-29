*** Settings ***
Documentation    This is for feature CB012544 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jia-rebecca.liu@nokia-sbell.com
...              Squard: HZ SG3

Resource       ./CB012544_SG3_common_keyword.robot
Resource       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot


*** Keywords ***
# --------------------------------12544-A-----------------------------------------#
A_101_test
    A_101_modify_GNB3_output_configuration     Modify_Para_Online=${Modify_A_101}    gnb_index=${2}    connection=GNB3_OAM
    A_101_reset_and_check_GNB2_status     connection=GNB2_OAM    gnb_index=${1}
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=GNB2_OAM     gnb_index=${1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_101    gnb_index=${1}    times=10s
    ${A_101_BIP_02}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_101
    Check SIB Message Detail Information A101    file_path=${A_101_BIP_02}[0]
    [Teardown]     run keyword and ignore error     COAM Save snapshot via api     gnb_index=${1}

A_102_test
    A_102_Remove_NTP_for_GNB2_and_Rest    gnb_index=${1}    connection=GNB2_OAM    Delete_Mo_Online=${Delete_NTP_Mo}
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=GNB2_OAM     gnb_index=${1}
    Check Expect Alarm whether exist     Expect_alarm=4405    connection=GNB2_OAM     gnb_index=${1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_102    gnb_index=${1}    times=10s
    ${A_102_BIP_01}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_102
    Check SIB Message Detail Information A102    file_path=${A_102_BIP_01}[0]
    [Teardown]     Run Keywords
    ...            A_101_modify_GNB3_output_configuration    Modify_Para_Online=${Modify_A_101_covery}
    ...     AND    Reset site with BTS for 12544    gnb_index=${1}    connection=GNB2_OAM
    ...     AND    COAM Wait For Gnb Ready And Cell Setup    gnb_type='SA'    connection=GNB2_OAM    gnb_index=${1}

A_B_C_005_test_part1
    A_101_modify_GNB3_output_configuration     Modify_Para_Online=${Modify_A_101}    gnb_index=${2}    connection=GNB3_OAM
    sleep     5min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4153    connection=GNB2_OAM     gnb_index=${1}


A_B_C_005_test_part2
    [Arguments]     ${gnb_index}=${1}    ${connection}=GNB2_OAM
    Common Case TestLine Setup with singe BTS     gnb_index=${1}
    ...                                           ModifySCF_Aftercommission=True
    ...                                           Modify_Para_Online=${Online_modify_ABC_005_part2}
    Reset Site With BTS For 12544     gnb_index=${gnb_index}     connection=${connection}
    sleep     5min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4153    connection=GNB2_OAM     gnb_index=${1}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}

A_B_C_005_test_covery
    [Arguments]     ${gnb_index}=${1}    ${connection}=GNB2_OAM
    A_101_modify_GNB3_output_configuration     Modify_Para_Online=${Modify_A_101_covery}    gnb_index=${2}    connection=GNB3_OAM
    Common Case TestLine Setup with singe BTS     gnb_index=${1}
    ...                                           ModifySCF_Aftercommission=True
    ...                                           Modify_Para_Online=${Online_modify_ABC_005_part3}
    Reset Site With BTS For 12544     gnb_index=${gnb_index}     connection=${connection}
    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4153    connection=GNB2_OAM     gnb_index=${1}

A_B_002_test_part1
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${Online_Modify_A_B_002_p1}
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Delete_Para_Online_GNB2=${Online_Delete_A_B_002_p1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_01    gnb_index=${1}    times=10s
    ${A_B_002_BIP_01}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_01
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_01}[0]
    A_101_modify_GNB3_output_configuration     Modify_Para_Online=${Modify_A_101}    gnb_index=${2}    connection=GNB3_OAM
    A_101_reset_and_check_GNB2_status     connection=GNB2_OAM    gnb_index=${1}    current_snycmode=FreqSync
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}
    Check Expect Alarm whether exist     Expect_alarm=4405    connection=GNB2_OAM     gnb_index=${1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_02    gnb_index=${1}    times=10s
    ${A_B_002_BIP_02}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_02
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_02}[0]
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${Online_Modify_A_B_002_p2}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_03    gnb_index=${1}    times=10s
    ${A_B_002_BIP_03}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_03
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_03}[0]
    block unblock all cells action for 12544    gnb_index=${1}
    reset all cells action for 12544    gnb_index=${1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_04    gnb_index=${1}    times=10s
    ${A_B_002_BIP_04}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_04
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_04}[0]
    [Teardown]     Run Keywords
    ...     A_101_modify_GNB3_output_configuration    Modify_Para_Online=${Modify_A_101_covery}
    ...     AND    run keyword and ignore error     COAM Save snapshot via api     gnb_index=${1}
    ...     AND    sleep    30s        reason=wait for alarm raised.
    ...     AND    Check Expect Alarm whether exist     Expect_alarm=4001    connection=GNB2_OAM     gnb_index=${1}
    ...     AND    Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}
    ...     AND    Reset Site With BTS For 12544    gnb_index=${1}    connection=GNB2_OAM
    ...     AND    COAM Wait For Gnb Ready And Cell Setup    gnb_type='SA'    connection=GNB2_OAM    gnb_index=${1}

A_B_002_test_part2
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_05    gnb_index=${1}    times=10s
    ${A_B_002_BIP_05}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_05
    Check SIB Message Detail Information A101    file_path=${A_B_002_BIP_05}[0]     #edrx=idle
    A_101_modify_GNB3_output_configuration     Modify_Para_Online=${Modify_A_101}    gnb_index=${2}    connection=GNB3_OAM
    sleep     5min    reason=wait for alarm raised.
    Check Expect Alarm whether exist     Expect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}
    Collect Interface Mirroring Bip Collector from WEBUI     target_file_name=biplog_A_B_002_06    gnb_index=${1}    times=10s
    ${A_B_002_BIP_06}    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=biplog_A_B_002_06
    Check SIB Message Detail Information A102    file_path=${A_B_002_BIP_06}[0]      #no edrx IE
#    Prepare to caculate PM counter     period=start    gnb_index=${1}
    Adjust the HBTE attenuation value for 12544    gnb2_cell2_value=${20}
    ${wireshark_attach_AB002}      _UE_attach_and_enter_idle      tcpdump_collector_name=${AB002_wireshark_attach}    sleep_time=90s
#    Prepare to caculate PM counter     period=end    gnb_index=${1}
#    check counters for AB002
    _check_rrc_inactivity_in_wireshark
    ...                file_path=${wireshark_attach_AB002}    parameter_list=${drxDefaultPaging}    suspend_IE=nr-rrc.ran_PagingCycle
    _check_user_inactivity_in_wireshark     file_path=${wireshark_attach_AB002}
    ${wireshark_paging_AB002}     ${AB002_bip_paging}
    ...     _start_traffic_trigger_paging      get_ip_from_cpif=${wireshark_attach_AB002}
    ...                                        tcpdump_collector_name=${AB002_wireshark_paging}
    ...                                        target_file_name=AB002_BIP_paging_07
    ...                                        cellid=${nrcellid2}
    [Teardown]     Run Keywords
    ...     A_101_modify_GNB3_output_configuration    Modify_Para_Online=${Modify_A_101_covery}
    ...     AND    run keyword and ignore error     COAM Save snapshot via api     gnb_index=${1}
    ...     AND    sleep    180s    reason=wait for alarm clear.
    ...     AND    CB012544_SG3_case_step.Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4404    connection=GNB2_OAM     gnb_index=${1}
    ...     AND    CB012544_SG3_case_step.Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=4405    connection=GNB2_OAM     gnb_index=${1}
    ...     AND    CB012544_SG3_case_step.Check UnExpect Alarm Should Not Exsit     UnExpect_alarm=1898    connection=GNB2_OAM     gnb_index=${1}
    ...     AND    Common Case TestLine Setup     is_commission_for_second_gnb=True
    ...                                           scf_path=${scf_path_12544}
    ...                                           golden_scf_name_gnb2=${TL2_ID}_${release_info}.xml

check counters for AB002
    [Arguments]      ${counter_id}=${counter_id_AB002}
    ...              ${dic_path}=${counter_dic_path_AB002}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}      #M55119C02502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}      #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}      #M55331C00005



A_101_modify_GNB3_output_configuration
    [Arguments]      ${Modify_Para_Online}=${Modify_A_101}     ${gnb_index}=${2}     ${connection}=GNB3_OAM
    Wait until keyword succeeds    10min    5s     Connect to gnb coam via ssl     gnb_index=${gnb_index}     connection=${connection}
    COAM Update Several Parameters Via Rest Api     connection=${connection}
    ...                                      parameters_to_update_via_api=${Modify_Para_Online}    timeout=5min
    ...                                      skip_parameter_relation_errors=True
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

A_101_reset_and_check_GNB2_status
     [Arguments]      ${connection}=GNB2_OAM      ${gnb_type}='SA'     ${is_x2_check_from_gnb_needed}=${False}
     ...              ${gnb_index}=${1}    ${current_snycmode}=LoosePhaseAndTimeSync
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
    [Arguments]     ${gnb_index}=${0}     ${connection}=GNB_OAM    ${timeout}=600    ${detailed_output}=${False}
    ...    ${wait_for_reconnection}=${True}     ${graceful_cell_shutdown}=${None}
    Wait until keyword succeeds    10min    5s     Connect to gnb coam via ssl     gnb_index=${gnb_index}     connection=${connection}
    ${Reset_site_status}=    coam.reset_site    connection=${connection}    timeout=${timeout}    detailed_output=${detailed_output}
    ...    wait_for_reconnection=${wait_for_reconnection}    graceful_cell_shutdown=${graceful_cell_shutdown}
    [Return]    ${Reset_site_status}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check Expect Alarm whether exist
    [Arguments]     ${Expect_alarm}     ${connection}=GNB2_OAM     ${gnb_index}=${1}
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
    [Arguments]     ${UnExpect_alarm}     ${connection}=GNB2_OAM     ${gnb_index}=${1}
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
    [Arguments]     ${gnb_index}=${1}     ${connection}=GNB2_OAM      ${Delete_Mo_Online}=${Delete_OBJ_A102}
    Modify Parameters for Cases     gnb_index=${gnb_index}
    ...                             Delete_Mo_Online=${Delete_Mo_Online}
    ...                             connection=${connection}
    Check Expect Alarm whether exist     Expect_alarm=4153
#    CB012544_SG3_case_step.Reset site with BTS     gnb_index=${gnb_index}     connection=${connection}
    Wait until keyword succeeds    10min    5s     Connect to gnb coam via ssl     gnb_index=${1}     connection=${connection}
    ${snyc_mode}    coam.get_synchronization_information     timeout=60s    connection=${connection}
    should be true    '${snyc_mode}[syncMode]' == 'FreqSync'
    log to console    ${snyc_mode}[syncMode]
    [Teardown]     COAM Teardown gnb connections      connection=${connection}

Check SIB Message Detail Information A101
    [Documentation]     check after change sync to loose phase mode, edrx IE exist, same as C001
    [Arguments]    ${file_path}    ${filter_expression}=3gpp.subcellid == 0
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17
    ...                                                                     filter_expression=${filter_expression}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17
    ...                                                                 filter_expression=${filter_expression}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${filter_expression}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}

Check SIB Message Detail Information A102
    [Documentation]     check after change sync to loose phase mode, edrx IE exist, same as C001
    [Arguments]    ${file_path}    ${filter_expression}=3gpp.subcellid == 0
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17
    ...                                                                     filter_expression=${filter_expression}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17
    ...                                                                 filter_expression=${filter_expression}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${filter_expression}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Be Empty    ${eDRX_AllowedInactive_r17_value1}


block unblock all cells action for 12544
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${1}     ${connection_name}=GNB_OAM
    SiSo_common_keywords.Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    SiSo_common_keywords.Get cell list info    connection=${connection_name}
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    SiSo_common_keywords.Block all cells with BTS    rat=${upper_cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Check cell failed status    cell_type=${cell_type}
        ...    AND    log to console    \n**start check alarm**\n
#        ...    AND    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Get alarms to check
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544
        ...    AND    Sleep    5s    reason=wait for a while between block and unblock action.
        ...    AND    SiSo_common_keywords.Unblock all cells with BTS    rat=${upper_cell_type}
        ...    AND    SiSo_common_keywords.Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check cell status    cell_type=${cell_type}
#        ...    AND    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Get alarms to check
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

Get alarms to check for 12544
    [Arguments]     ${connection}=GNB_OAM
    ${activate_alarms}=    coam.get_active_alarms    connection=${connection}
    ${count_alarm}    Get length    ${activate_alarms}
#    Should be true    ${count_alarm}>=${1}    msg=Check cell status failed as total cell number is less than 1
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
#    SiSo_common_keywords.Connect with BTS    gnb_index=${gnb_index}    connection=${connection_2}
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
#    [Teardown]    Disconnect With BTS    connection=${connection_2}

reset all cells action for 12544
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${1}     ${connection_name}=GNB_OAM
    SiSo_common_keywords.Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    SiSo_common_keywords.Reset all cells with BTS
    ${cell_list}=    SiSo_common_keywords.Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    SiSo_common_keywords.Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check cell status    cell_type=${cell_type}
#        ...    AND    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Get alarms to check
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check for 12544
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}
# --------------------------------B_102-----------------------------------------#
B_102 set_actEdrx and check_sib for C001
    [Arguments]     ${target_file_name}=BIPlog_B102_idle
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C001}
    ${B_102_bip_C001}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ${dci_frame_number}    ${frame_time}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C001}
    ${final_pcap_file}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C001}    frame_time=${frame_time}
    Check SIB Message Detail Information C001    file_path=${final_pcap_file}    frame_time=${frame_time}


B_102 set_actEdrx and check_sib for C007
    [Arguments]     ${target_file_name}=B_102_bip_C007
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C007}
    ${B_102_BIP_C007}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ${dci_frame_number}    ${frame_time}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C007}
    ${final_pcap_file}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C007}    frame_time=${frame_time}
    Check SIB Message Detail Information C007    file_path=${final_pcap_file}    frame_time=${frame_time}
    [Teardown]


B_102 set_actEdrx and check_sib for C010
    [Arguments]     ${target_file_name}=BIPlog_B102_C010
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C010}
    ${B_102_BIP_C010}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ${dci_frame_number}    ${frame_time}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C010}
    ${final_pcap_file}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C010}    frame_time=${frame_time}
    Check SIB Message Detail Information C010    file_path=${final_pcap_file}    frame_time=${frame_time}

B_102 set_actEdrx and check_sib for C011
    [Arguments]     ${target_file_name}=BIPlog_B102_C011
    ...             ${parameters_to_update_via_api}=${Online_actEdrx_modify_C011}
    ${B_102_BIP_C011}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                                    Online_modify_actEdrx=${parameters_to_update_via_api}
    ${dci_frame_number}    ${frame_time}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_C011}
    ${final_pcap_file}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_C011}    frame_time=${frame_time}
    Check SIB Message Detail Information C011    file_path=${final_pcap_file}    frame_time=${frame_time}

B_102 set_actEdrx_none_Inactive and check_sib
    [Arguments]     ${target_file_name}=B_102_bip_none_inactive
    ${B_102_bip}    Online_modify_edrx_and_capture_bip_from_WEBEM     target_file_name=${target_file_name}
    ...                                                               Online_modify_actEdrx=${Online_actEdrx_idle_Inactive}
    builtin.set test variable     ${B_102_BIP_04}     ${B_102_bip}[0]
    ${dci_frame_number}    ${frame_time}    Run Keyword And Continue On Failure
    ...    Check DCI_1_0 Message On DlData_PdcchSendreq    file_path=${B_102_BIP_04}
    ${final_pcap_file}    Deal With Pcap File for frame_max    file_path=${B_102_BIP_04}    frame_time=${frame_time}
    Check SIB Message Detail Information 02    file_path=${final_pcap_file}    frame_time=${frame_time}
    [Teardown]

Online_modify_edrx_and_capture_bip_from_WEBEM
    [Arguments]     ${target_file_name}    ${Online_modify_actEdrx}
    ...             ${gnb_index}=${1}
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${Online_modify_actEdrx}
    ${bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    [Return]     ${bip_paging}[0]

# --------------------------------C_001-----------------------------------------#

C_001 check_user_inactivity_in_wireshark
    [Arguments]      ${file_path}
    ${user_inactivity}     Check user-inactivity in UEContextRR     file_path=${file_path}
    run keyword and continue on failure
    ...     should contain x times    ${user_inactivity}    radioNetwork: user-inactivity (20)     1
    run keyword and continue on failure
    ...     should not contain    ${user_inactivity}     radioNetwork: radio-connection-with-ue-lost (21)


C_001 check_logs
    [Arguments]      ${wireshark_attach_C001}      ${wireshark_paging_C001}     ${C_001_bip_paging}
    Check EDRX_Parameters in Registration     file_path=${wireshark_attach_C001}
    Check RedCapIndication in Registration     file_path=${wireshark_attach_C001}
    ${Paging_eDrx_cycle}     ${Paging_eDrx_window}     Check paging_info in paging_wireshark    file_path=${wireshark_paging_C001}
    run keyword and continue on failure
    ...     should be true    '${Paging_eDrx_cycle}' == 'hf2' and '${Paging_eDrx_window}' == 's6'
    Check GNB_IP in InitialcontexSetupResponse    file_path=${wireshark_paging_C001}
    ...                                           GNB_Address=${tl.gnbs[1].cu.oam_http_connection_details.addr}
    ${paging_tmsi}     Check paging_tmsi in bip    file_path=${C_001_bip_paging}    subcellid=${0}
    run keyword and continue on failure     Should Not Be Empty     ${paging_tmsi}
    [Teardown]     run keyword and ignore error     COAM Save snapshot via api     gnb_index=${1}

check counters for C_001
    [Arguments]      ${counter_id}=${counter_id_C001}
    ...              ${dic_path}=${counter_dic_path_C001}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #M55119C02502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}     #M55119C01501
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #M55331C00001

# --------------------------------C_003&D_002-----------------------------------------#
check counters for D_002
    [Arguments]      ${counter_id}=${counter_id_D002}
    ...              ${dic_path}=${counter_dic_path_D002}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${0}     #M55117C04503
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${0}     #M55331C00007
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #M55331C00001


EDA_04136786_steps
    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${online_modify_EDA_GNB1}
    ...                            ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${online_modify_EDA_GNB2}
    Prepare to caculate PM counter     period=start    gnb_index=${1}
    Adjust the HBTE attenuation value for 12544     gnb1_cell3_value=${10}
    ${eda_wireshark_gnb1}    _UE_attach_and_enter_idle    tcpdump_collector_name=${eda_wireshark_attach_gnb1}     gnb_index=${0}
    Start capture cpif_wireshark log on node     filename=${eda_wireshark_attach_gnb2}    gNB_index=${1}
    Adjust the HBTE attenuation value for 12544     gnb1_cell3_value=${10}    gnb2_cell2_value=${20}
    sleep    1s
    Adjust the HBTE attenuation value for 12544     gnb1_cell3_value=${127}    gnb2_cell2_value=${20}
    sleep    2s
    ${eda_wireshark_gnb2}    Stop and download the wiresharklog from master    filename=${eda_wireshark_attach_gnb2}    gNB_index=${1}
    Prepare to caculate PM counter     period=end    gnb_index=${1}
    [Teardown]     MTK60 UE Detach     ue_index=${2}

EDA_04136786_checkpoint
    [Arguments]     ${counter_id}=${counter_id_eda}    ${dic_path}=${counter_dic_path_eda}     ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${0}
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}
    [Teardown]     run keywords
    ...    Common Case TestLine Setup     ModifySCF_Aftercommission=True
    ...                            Modify_Para_Online=${online_recovery_EDA_GNB1}
    ...                            ModifySCF_Aftercommission_for_GNB2=True
    ...                            Modify_Para_Online_GNB2=${online_recovery_EDA_GNB2}
    ...    AND     Adjust the HBTE attenuation value for 12544     gnb2_cell1_value=${10}

D_002_check_logs
    [Arguments]     ${wireshark_paging_D002}
    ${cell1_hex}    translate cellid to hex     nrcellid_value=${nrcellid}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_D002}    cellid_hex=${cell1_hex}
    [Teardown]     run keyword
    ...     Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                                    Add_Para_Online_GNB2=${online_recovery_D002}

check counters for C_003
    [Arguments]      ${counter_id}=${counter_id_C003}
    ...              ${dic_path}=${counter_dic_path_C003}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}      #M55119C02502
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}      #M55117C04502
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}      #M55331C00005
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}      #M55119C01501
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}      #M55117C03001
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}      #M55331C00001
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${0}      #M55331C00005

C_003_check_logs
    [Arguments]      ${C_003_bip_paging}     ${wireshark_paging_C003}
    ${cell1_hex}    translate cellid to hex     nrcellid_value=${nrcellid}
    ${paging_tmsi_C003}    Check paging_tmsi in bip      file_path=${C_003_bip_paging}    subcellid=${0}
    BuiltIn.Should Not Be Empty     ${paging_tmsi_C003}
    Check GNB_IP in InitialcontexSetupResponse    file_path=${wireshark_paging_C003}
    ...                                           GNB_Address=${tl.gnbs[1].cu.oam_http_connection_details.addr}
    ${Paging_eDrx_cycle}     ${Paging_eDrx_window}
    ...     Check paging_info in paging_wireshark     file_path=${wireshark_paging_C003}
    should be true     '${Paging_eDrx_cycle}' == 'hf2' and '${Paging_eDrx_window}' == 's6'
    [Teardown]     Run keyword
    ...    Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                                   Modify_Para_Online_GNB2=${Recovery_C_003}
#    ...      Common Case TestLine Setup           is_commission_for_second_gnb=True
#    ...                                           scf_path=${scf_path_12544}
#    ...                                           golden_scf_name_gnb2=${TL2_ID}_${release_info}.xml

# --------------------------------C_007&C_008-----------------------------------------#
C007_Paging_command_get
    [Arguments]
    ...       ${tmsi_fake1_priority}=${1}     ${tmsi_fake2_priority}=${2}
    ...       ${tmsi_fake4_priority}=${3}     ${tmsi_fake5_priority}=${3}
    ${C007_fake_1}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=1 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake1}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off
    ...    priority=${tmsi_fake1_priority} nr_paging_edrx_cycle=hfquarter nr_paging_time_window=s1
    ${C007_fake_2}     Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=2 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake2} 5g_s_tmsi_num=1
    ...      tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake2_priority} drx_cycle_len=256
    ${C007_fake_3}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=3 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake3} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=0 drx_cycle_len=256
    ${C007_paging_1}    Catenate    amf_paging_start id=1 tai=001:01|270 ueid=1 nr_paging_edrx_cycle_value=hfquarter nr_paging_time_window_value=s4
    ${C007_fake_4}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=4 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake4} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake4_priority}  drx_cycle_len=256
    ${C007_fake_5}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=5 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake5}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake5_priority}
    ...    nr_paging_edrx_cycle=hfquarter nr_paging_time_window=s6
    ${paging_command_C007}     Catenate    SEPARATOR=\n
    ...       ${C007_fake_1}    ${C007_fake_2}    ${C007_fake_3}    ${C007_paging_1}    ${C007_fake_4}    ${C007_fake_5}
    log to console    ${paging_command_C007}
    [Return]    ${paging_command_C007}


check counters for C_007
    [Arguments]      ${counter_id}=${counter_id_C007}
    ...              ${dic_path}=${counter_dic_path_C007}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${6}     #'M55119C01501'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${4}     #'M55119C02501'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${3}     #'M55119C02502'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${3}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${6}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${4}     #'M55117C04501'
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${1}     #'M55331C00001'_cell1
    run keyword and continue on failure     should be true    ${counter_value[7]} == ${3}     #'M55331C00002'_cell1
    run keyword and continue on failure     should be true    ${counter_value[8]} == ${0}     #'M55331C00003'_cell1
    run keyword and continue on failure     should be true    ${counter_value[9]} == ${0}     #'M55331C00005'_cell1
    run keyword and continue on failure     should be true    ${counter_value[10]} == ${3}     #'M55331C00006'_cell1
    run keyword and continue on failure     should be true    ${counter_value[11]} == ${1}     #'M55331C00001'_cell2
    run keyword and continue on failure     should be true    ${counter_value[12]} == ${3}     #'M55331C00002'_cell2
    run keyword and continue on failure     should be true    ${counter_value[13]} == ${1}     #'M55331C00003'_cell2
    run keyword and continue on failure     should be true    ${counter_value[14]} == ${2}     #'M55331C00005'_cell2
    run keyword and continue on failure     should be true    ${counter_value[15]} == ${1}     #'M55331C00006'_cell2


C_007 check_logs
    [Arguments]     ${wireshark_paging_C007}     ${C_007_bip_paging}
    ...             ${tmsi_fake1_priority}=priolevel1     ${tmsi_fake2_priority}=priolevel2
    ...             ${tmsi_fake4_priority}=priolevel3     ${tmsi_fake5_priority}=priolevel3
    ...             ${M60_Hashed_UE_ID}=2c68
    comment    --translate tmsi to hex--
    ${fiveG_S_TMSI_fake1}    Convert To Hex    ${tmsi_fake1}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake2}    Convert To Hex    ${tmsi_fake2}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake3}    Convert To Hex    ${tmsi_fake3}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake4}    Convert To Hex    ${tmsi_fake4}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake5}    Convert To Hex    ${tmsi_fake5}     prefix=0041000    length=5
    ${fiveG_S_TMSI_paging}     Convert To Hex    ${tmsi_paging}     prefix=0041000    length=5
    comment    --get priority level from log--
    ${fake1_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake1}
    ${fake2_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake2}
    ${fake3_paging_priority}    run keyword and return status
    ...    Check paging_priority in wireshark    file_path=${wireshark_paging_C007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake3}
    ${fake4_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake4}
    ${fake5_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake5}
    ${hashed_UE_ID}     Check HashID in paging_wireshark    file_path=${wireshark_paging_C007}
    ...                                                     filter_expression=f1ap.Paging_element and f1ap.fiveG_S_TMSI == ${fiveG_S_TMSI_paging}
    comment    --check priority level as expect--
    run keyword and continue on failure     should be true     '${fake1_paging_priority}' == '${tmsi_fake1_priority}'
    run keyword and continue on failure     should be true     '${fake2_paging_priority}' == '${tmsi_fake2_priority}'
    run keyword and continue on failure     should be true     '${fake3_paging_priority}' == 'False'
    run keyword and continue on failure     should be true     '${fake4_paging_priority}' == '${tmsi_fake4_priority}'
    run keyword and continue on failure     should be true     '${fake5_paging_priority}' == '${tmsi_fake5_priority}'
    run keyword and continue on failure     should be true     '${hashed_UE_ID}' == '${M60_Hashed_UE_ID}'
    comment    -- check tmsi list in bip as expect--
    ${paging_tmsi_list_cell1}    Check paging_tmsi in bip      file_path=${C_007_bip_paging}    subcellid=${0}
    ${paging_tmsi_num_cell1}    get length    ${paging_tmsi_list_cell1}
    ${cell1_tmsi_list}=    create list    ${fiveG_S_TMSI_fake4}    ${fiveG_S_TMSI_fake3}    ${fiveG_S_TMSI_fake2}
    run keyword and continue on failure    lists should be equal     ${paging_tmsi_list_cell1}    ${cell1_tmsi_list}
    ${paging_tmsi_list_cell2}    Check paging_tmsi in bip      file_path=${C_007_bip_paging}    subcellid=${1}
    ${paging_tmsi_num_cell2}    get length   ${paging_tmsi_list_cell2}
    ${cell2_tmsi_list}=    create list    ${fiveG_S_TMSI_fake1}    ${fiveG_S_TMSI_fake2}    ${fiveG_S_TMSI_fake5}
    run keyword and continue on failure    lists should be equal     ${paging_tmsi_list_cell2}    ${cell2_tmsi_list}
    [Teardown]     Run Keyword
    ...     Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                                    Modify_Para_Online_GNB2=${Online_Recovery_C007}


D005_Paging_command_get
    [Arguments]
    ...       ${tmsi_fake1_priority}=${1}     ${tmsi_fake2_priority}=${2}
    ...       ${tmsi_fake4_priority}=${3}     ${tmsi_fake5_priority}=${3}
    ${D005_fake_1}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=1 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake1}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off
    ...    priority=${tmsi_fake1_priority} nr_paging_edrx_cycle=hfquarter nr_paging_time_window=s1
    ${D005_fake_2}     Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=2 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake2} 5g_s_tmsi_num=1
    ...      tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake2_priority} drx_cycle_len=256
    ${D005_fake_3}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=3 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake3} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=0 drx_cycle_len=256
    ${D005_fake_4}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=4 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake4} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake4_priority}  drx_cycle_len=256
    ${D005_fake_5}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=5 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake5}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake5_priority}
    ...    nr_paging_edrx_cycle=hfquarter nr_paging_time_window=s1
    ${paging_command_D005}     Catenate    SEPARATOR=\n
    ...       ${D005_fake_1}    ${D005_fake_2}    ${D005_fake_3}     ${D005_fake_4}    ${D005_fake_5}
    log to console    ${paging_command_D005}
    [Return]    ${paging_command_D005}

D005_start_simulator_and_traffic_failed
    [Arguments]     ${target_file_name}    ${paging_command}    ${dl_port}    ${ue_addr}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_paging}
    ...             ${gnb_index}=${1}
    ...             ${action_mode}=tput_paging
    ...             ${Simulation_IP}=${AMF_IPaddr}
    ...             ${dl_time}=300
    ...             ${dl_traffic}=1M
    ...             ${dl_length}=1024B
    ...             ${ue_index}=${1}
    ...             ${target_throughput}=0
    ...             ${cellid}=${nrcellid}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gNB_index}
    Prepare to caculate PM counter     period=start
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    start_traffic_and_paging     action_mode=${action_mode}    Simulation_IP=${Simulation_IP}
    ...                          paging_command=${paging_command}    dl_port=${dl_port}
    ...                          ue_addr=${ue_addr}     dl_time=${dl_time}
    ...                          dl_throughput=${dl_traffic}    dl_length=${dl_length}
    ${C_001_bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    ${check_tput_result}    run keyword and return status
    ...     Check tput for MTK60     ue_index=${ue_index}     target_throughput=${target_throughput}     cellid=${cellid}
    Prepare to caculate PM counter       period=end
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    ...    AND    Run keyword and ignore error     Stop Bip Log Via Interface Mirroring Collector from WEBUI     target_file_name=${target_file_name}
    ...    AND    Close the iperf process on APPserver    port=${DL_PORT}
    ...    AND    MTK60 UE Detach     ue_index=${2}
    [Return]     ${cpif_log_path}     ${C_001_bip_paging}[0]     ${check_tput_result}

check counters for D_005
    [Arguments]      ${counter_id}=${counter_id_D005}
    ...              ${dic_path}=${counter_dic_path_D005}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${5}     #'M55119C01501'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${4}     #'M55119C02501'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${2}     #'M55119C02502'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${3}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${6}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${4}     #'M55117C04501'
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${1}     #'M55331C00001'_cell1
    run keyword and continue on failure     should be true    ${counter_value[7]} == ${3}     #'M55331C00002'_cell1
    run keyword and continue on failure     should be true    ${counter_value[8]} == ${0}     #'M55331C00003'_cell1
    run keyword and continue on failure     should be true    ${counter_value[9]} == ${1}     #'M55331C00005'_cell1
    run keyword and continue on failure     should be true    ${counter_value[10]} == ${1}     #'M55331C00006'_cell1
    run keyword and continue on failure     should be true    ${counter_value[11]} == ${0}     #'M55331C00007'_cell1
    run keyword and continue on failure     should be true    ${counter_value[12]} == ${0}     #'M55331C00008'_cell1
    run keyword and continue on failure     should be true    ${counter_value[13]} == ${1}     #'M55331C00001'_cell2
    run keyword and continue on failure     should be true    ${counter_value[14]} == ${3}     #'M55331C00002'_cell2
    run keyword and continue on failure     should be true    ${counter_value[15]} == ${1}     #'M55331C00003'_cell2
    run keyword and continue on failure     should be true    ${counter_value[16]} == ${2}     #'M55331C00005'_cell2
    run keyword and continue on failure     should be true    ${counter_value[17]} == ${1}     #'M55331C00006'_cell2
    run keyword and continue on failure     should be true    ${counter_value[18]} == ${0}     #'M55331C00007'_cell2
    run keyword and continue on failure     should be true    ${counter_value[19]} == ${1}     #'M55331C00008'_cell2


D_005 check_logs
    [Arguments]     ${wireshark_paging_D005}    ${D_005_bip_paging}
    ...             ${tmsi_fake1_priority}=priolevel1     ${tmsi_fake2_priority}=priolevel2
    ...             ${tmsi_fake4_priority}=priolevel3     ${tmsi_fake5_priority}=priolevel3
    comment    --translate tmsi to hex--
    ${fiveG_S_TMSI_fake1}    Convert To Hex    ${tmsi_fake1}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake2}    Convert To Hex    ${tmsi_fake2}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake3}    Convert To Hex    ${tmsi_fake3}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake4}    Convert To Hex    ${tmsi_fake4}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake5}    Convert To Hex    ${tmsi_fake5}     prefix=0041000    length=5
    ${fiveG_S_TMSI_paging}     Convert To Hex    ${tmsi_paging}     prefix=0041000    length=5
    comment    --get priority level from log--
    ${fake1_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake1}
    ${fake2_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake2}
    ${fake3_paging_priority}    run keyword and return status
    ...      Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake3}
    ${fake4_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake4}
    ${fake5_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake5}
    comment    --check priority level as expect--
    run keyword and continue on failure     should be true     '${fake1_paging_priority}' == '${tmsi_fake1_priority}'
    run keyword and continue on failure     should be true     '${fake2_paging_priority}' == '${tmsi_fake2_priority}'
    run keyword and continue on failure     should be true     '${fake3_paging_priority}' == 'False'
    run keyword and continue on failure     should be true     '${fake4_paging_priority}' == '${tmsi_fake4_priority}'
    run keyword and continue on failure     should be true     '${fake5_paging_priority}' == '${tmsi_fake5_priority}'
    comment    -- check tmsi list in bip as expect--
    ${paging_tmsi_list_1}     Check paging_tmsi in bip      file_path=${D_005_bip_paging}    subcellid=1
    ${paging_tmsi_list_0}     Check paging_tmsi in bip      file_path=${D_005_bip_paging}    subcellid=0
    ${cell1_tmsi_list}=    create list    ${fiveG_S_TMSI_fake5}    ${fiveG_S_TMSI_fake4}
    ${cell2_tmsi_list}=    create list    ${fiveG_S_TMSI_fake1}    ${fiveG_S_TMSI_fake2}    ${fiveG_S_TMSI_fake5}
    run keyword and continue on failure    lists should be equal    ${cell1_tmsi_list}    ${paging_tmsi_list_0}
    run keyword and continue on failure    lists should be equal    ${cell2_tmsi_list}    ${paging_tmsi_list_1}
    [Teardown]     Run Keyword
    ...     Common Case TestLine Setup     ModifySCF_Aftercommission_for_GNB2=True
    ...                                    Modify_Para_Online_GNB2=${Online_Recovery_D005}





# --------------------------------C_010&D_007-----------------------------------------#
C010_Paging_command_get
    [Arguments]
    ...       ${tmsi_fake1_priority}=${1}     ${tmsi_fake2_priority}=${2}
    ...       ${tmsi_fake4_priority}=${3}     ${tmsi_fake5_priority}=${3}
    ${C010_fake_1}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=1 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake1}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off drx_cycle_len=128
    ...    priority=${tmsi_fake1_priority} nr_paging_edrx_cycle=hf2 nr_paging_time_window=s20
    ${C010_fake_2}     Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=2 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake2} 5g_s_tmsi_num=1
    ...      tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake2_priority} drx_cycle_len=128
    ${C010_fake_3}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=3 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake3} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=0  drx_cycle_len=128
    ${C010_paging_1}    Catenate    amf_paging_start id=1 tai=001:01|270 ueid=1 nr_paging_edrx_cycle_value=hf2 nr_paging_time_window_value=s20
    ...                             drx_cycle_value=128
    ${C010_fake_4}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=4 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake4} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake4_priority} drx_cycle_len=128
    ${C010_fake_5}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=5 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake5}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake5_priority}
    ...    drx_cycle_len=128 nr_paging_edrx_cycle=hf2 nr_paging_time_window=s20
    ${paging_command_C010}     Catenate     SEPARATOR=\n
    ...       ${C010_fake_1}     ${C010_fake_2}    ${C010_fake_3}    ${C010_paging_1}    ${C010_fake_4}    ${C010_fake_5}
    log to console    ${paging_command_C010}
    [Return]    ${paging_command_C010}



check counters for C_010
    [Arguments]      ${counter_id}=${counter_id_C007}
    ...              ${dic_path}=${counter_dic_path_C007}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${6}     #'M55119C01501'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${4}     #'M55119C02501'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${3}     #'M55119C02502'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${3}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${6}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${4}     #'M55117C04501'
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${2}     #'M55331C00001'_cell1
    run keyword and continue on failure     should be true    ${counter_value[7]} == ${1}     #'M55331C00002'_cell1
    run keyword and continue on failure     should be true    ${counter_value[8]} == ${0}     #'M55331C00003'_cell1
    run keyword and continue on failure     should be true    ${counter_value[9]} == ${3}     #'M55331C00005'_cell1
    run keyword and continue on failure     should be true    ${counter_value[10]} == ${0}     #'M55331C00006'_cell1
    run keyword and continue on failure     should be true    ${counter_value[11]} == ${2}     #'M55331C00001'_cell2
    run keyword and continue on failure     should be true    ${counter_value[12]} == ${0}     #'M55331C00002'_cell2
    run keyword and continue on failure     should be true    ${counter_value[13]} == ${0}     #'M55331C00003'_cell2
    run keyword and continue on failure     should be true    ${counter_value[14]} == ${3}     #'M55331C00005'_cell2
    run keyword and continue on failure     should be true    ${counter_value[15]} == ${0}     #'M55331C00006'_cell2
    [Teardown]     run keyword and ignore error     MTK60 UE Detach     ue_index=${2}

C_010 check_logs
    [Arguments]     ${tmsi_fake1_priority}=priolevel1     ${tmsi_fake2_priority}=priolevel2
    ...             ${tmsi_fake4_priority}=priolevel3     ${tmsi_fake5_priority}=priolevel3
    comment    --translate tmsi to hex--
    ${fiveG_S_TMSI_fake1}    Convert To Hex    ${tmsi_fake1}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake2}    Convert To Hex    ${tmsi_fake2}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake3}    Convert To Hex    ${tmsi_fake3}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake4}    Convert To Hex    ${tmsi_fake4}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake5}    Convert To Hex    ${tmsi_fake5}     prefix=0041000    length=5
    ${fiveG_S_TMSI_paging}     Convert To Hex    ${tmsi_paging}     prefix=0041000    length=5
    comment    --get priority level from log--
    ${fake1_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C010}    fiveG_S_TMSI=${fiveG_S_TMSI_fake1}
    ${fake2_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C010}    fiveG_S_TMSI=${fiveG_S_TMSI_fake2}
    ${fake3_paging_priority}    run keyword and return status
    ...    Check paging_priority in wireshark    file_path=${wireshark_paging_C010}    fiveG_S_TMSI=${fiveG_S_TMSI_fake3}
    ${fake4_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C010}    fiveG_S_TMSI=${fiveG_S_TMSI_fake4}
    ${fake5_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_C010}    fiveG_S_TMSI=${fiveG_S_TMSI_fake5}
    comment    --check priority level as expect--
    run keyword and continue on failure     should be true     '${fake1_paging_priority}' == '${tmsi_fake1_priority}'
    run keyword and continue on failure     should be true     '${fake2_paging_priority}' == '${tmsi_fake2_priority}'
    run keyword and continue on failure     should be true     '${fake3_paging_priority}' == 'False'
    run keyword and continue on failure     should be true     '${fake4_paging_priority}' == '${tmsi_fake4_priority}'
    run keyword and continue on failure     should be true     '${fake5_paging_priority}' == '${tmsi_fake5_priority}'
    comment    -- check tmsi list in bip as expect--
    ${paging_tmsi_list_cell1}    Check paging_tmsi in bip      file_path=${C_010_bip_paging}    subcellid=${0}
    ${paging_tmsi_num_cell1}    get length    ${paging_tmsi_list_cell1}
    ${cell1_tmsi_list}=    create list
    ...    ${fiveG_S_TMSI_fake1}    ${fiveG_S_TMSI_fake2}    ${fiveG_S_TMSI_fake4}    ${fiveG_S_TMSI_fake5}    ${fiveG_S_TMSI_paging}
    run keyword and continue on failure    lists should be equal     ${paging_tmsi_list_cell1}    ${cell1_tmsi_list}
    ${paging_tmsi_list_cell2}    Check paging_tmsi in bip      file_path=${C_010_bip_paging}    subcellid=${1}
    ${paging_tmsi_num_cell2}    get length   ${paging_tmsi_list_cell2}
    ${cell2_tmsi_list}=    create list    ${fiveG_S_TMSI_fake3}    ${fiveG_S_TMSI_fake2}
    ...        ${fiveG_S_TMSI_fake1}     ${fiveG_S_TMSI_fake5}    ${fiveG_S_TMSI_fake4}    ${fiveG_S_TMSI_paging}
    run keyword and continue on failure    lists should be equal     ${paging_tmsi_list_cell2}    ${cell2_tmsi_list}
    [Teardown]     run keyword and ignore error     MTK60 UE Detach     ue_index=${2}

D007_Paging_command_get
    [Arguments]
    ...       ${tmsi_fake1_priority}=${1}     ${tmsi_fake2_priority}=${2}
    ...       ${tmsi_fake4_priority}=${3}     ${tmsi_fake5_priority}=${3}
    ${D007_fake_1}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=1 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake1}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off drx_cycle_len=256
    ...    priority=${tmsi_fake1_priority} nr_paging_edrx_cycle=hf2 nr_paging_time_window=s20
    ${D007_fake_2}     Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=2 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake2} 5g_s_tmsi_num=1
    ...      tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake2_priority} drx_cycle_len=256
    ${D007_fake_3}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=3 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake3} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=0 nr_paging_edrx_cycle=hf2
    ...    nr_paging_time_window=s20 drx_cycle_len=256
    ${D007_fake_4}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=4 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake4} 5g_s_tmsi_num=1
    ...    tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake4_priority}  drx_cycle_len=256
    ${D007_fake_5}    Catenate    amf_fake_paging_start amf=1 gnbs=2 session_id=5 tai=001:01|270 5g_s_tmsi=1:1:${tmsi_fake5}
    ...    5g_s_tmsi_num=1 tmsi_offset=32 burst_size=1 burst_period=100 burst_limit=1 tmsi_shuffle=off priority=${tmsi_fake5_priority}
    ...    nr_paging_edrx_cycle=hf2 nr_paging_time_window=s20
    ${paging_command_D007}     Catenate    SEPARATOR=\n
    ...       ${D007_fake_1}    ${D007_fake_2}    ${D007_fake_3}     ${D007_fake_4}    ${D007_fake_5}
    log to console    ${paging_command_D007}
    [Return]    ${paging_command_D007}

check counters for D_007
    [Arguments]      ${counter_id}=${counter_id_D005}
    ...              ${dic_path}=${counter_dic_path_D005}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${5}     #'M55119C01501'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${4}     #'M55119C02501'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${3}     #'M55119C02502'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${4}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${6}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${4}     #'M55117C04501'
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${1}     #'M55331C00001'_cell1
    run keyword and continue on failure     should be true    ${counter_value[7]} == ${3}     #'M55331C00002'_cell1
    run keyword and continue on failure     should be true    ${counter_value[8]} == ${1}     #'M55331C00003'_cell1
    run keyword and continue on failure     should be true    ${counter_value[9]} == ${2}     #'M55331C00005'_cell1
    run keyword and continue on failure     should be true    ${counter_value[10]} == ${1}     #'M55331C00006'_cell1 cell1=idle,mtk60 not edrx ue
    run keyword and continue on failure     should be true    ${counter_value[11]} == ${0}     #'M55331C00007'_cell1
    run keyword and continue on failure     should be true    ${counter_value[12]} == ${0}     #'M55331C00008'_cell1
    run keyword and continue on failure     should be true    ${counter_value[13]} == ${1}     #'M55331C00001'_cell2
    run keyword and continue on failure     should be true    ${counter_value[14]} == ${3}     #'M55331C00002'_cell2
    run keyword and continue on failure     should be true    ${counter_value[15]} == ${0}     #'M55331C00003'_cell2
    run keyword and continue on failure     should be true    ${counter_value[16]} == ${1}     #'M55331C00005'_cell2
    run keyword and continue on failure     should be true    ${counter_value[17]} == ${3}     #'M55331C00006'_cell2
    run keyword and continue on failure     should be true    ${counter_value[18]} == ${1}     #'M55331C00007'_cell2
    run keyword and continue on failure     should be true    ${counter_value[19]} == ${0}     #'M55331C00008'_cell2

D_007 check_logs
    [Arguments]     ${wireshark_paging_D007}    ${D_007_bip_paging}
    ...             ${tmsi_fake1_priority}=priolevel1     ${tmsi_fake2_priority}=priolevel2
    ...             ${tmsi_fake4_priority}=priolevel3     ${tmsi_fake5_priority}=priolevel3
    comment    --translate tmsi to hex--
    ${fiveG_S_TMSI_fake1}    Convert To Hex    ${tmsi_fake1}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake2}    Convert To Hex    ${tmsi_fake2}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake3}    Convert To Hex    ${tmsi_fake3}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake4}    Convert To Hex    ${tmsi_fake4}     prefix=0041000    length=5
    ${fiveG_S_TMSI_fake5}    Convert To Hex    ${tmsi_fake5}     prefix=0041000    length=5
    ${fiveG_S_TMSI_paging}     Convert To Hex    ${tmsi_paging}     prefix=0041000    length=5
    comment    --get priority level from log--
    ${fake1_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake1}
    ${fake2_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake2}
    ${fake3_paging_priority}    run keyword and return status
    ...      Check paging_priority in wireshark    file_path=${wireshark_paging_D005}    fiveG_S_TMSI=${fiveG_S_TMSI_fake3}
    ${fake4_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake4}
    ${fake5_paging_priority}    Check paging_priority in wireshark    file_path=${wireshark_paging_D007}    fiveG_S_TMSI=${fiveG_S_TMSI_fake5}
    comment    --check priority level as expect--
    run keyword and continue on failure     should be true     '${fake1_paging_priority}' == '${tmsi_fake1_priority}'
    run keyword and continue on failure     should be true     '${fake2_paging_priority}' == '${tmsi_fake2_priority}'
    run keyword and continue on failure     should be true     '${fake3_paging_priority}' == 'False'
    run keyword and continue on failure     should be true     '${fake4_paging_priority}' == '${tmsi_fake4_priority}'
    run keyword and continue on failure     should be true     '${fake5_paging_priority}' == '${tmsi_fake5_priority}'
    ${cell2_hex}    translate cellid to hex     nrcellid_value=${nrcellid2}
    comment    -- check tmsi list in bip as expect--
    ${paging_tmsi_list_1}     Check paging_tmsi in bip      file_path=${D_007_bip_paging}    subcellid=1
    ${paging_tmsi_list_0}     Check paging_tmsi in bip      file_path=${D_007_bip_paging}    subcellid=0
    ${cell1_paing_list}     create list    ${fiveG_S_TMSI_fake1}    ${fiveG_S_TMSI_fake2}    ${fiveG_S_TMSI_fake5}
    ${cell2_paing_list}     create list    ${fiveG_S_TMSI_fake4}    ${fiveG_S_TMSI_fake2}
    run keyword and continue on failure     lists should be equal    ${cell1_paing_list}     ${paging_tmsi_list_0}
    run keyword and continue on failure     lists should be equal    ${cell2_paing_list}     ${paging_tmsi_list_1}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_D007}    cellid_hex=${cell2_hex}

# --------------------------------C_011-----------------------------------------#
C011_Paging_command_get
    [Arguments]     ${warning_msg}=C011_warning

    ${C011_paging_1}    Catenate    amf_paging_start id=1 tai=001:01|270 ueid=1 nr_paging_edrx_cycle_value=hfhalf nr_paging_time_window_value=s2
    ${C011_broadcast_2}     Catenate    cbs_broadcast_start amf=1 type=etws_prim_sec etws_warn_type=1 concurrent=on repetition=indefinite
    ...                                 warning_msg=${warning_msg}
    ${paging_command_C011}     Catenate    SEPARATOR=\n
    ...       ${C011_paging_1}     ${C011_broadcast_2}
    log to console    ${paging_command_C011}
    [Return]    ${paging_command_C011}

C011 check_logs
    [Arguments]     ${C_011_bip_paging}
    run keyword and continue on failure     Check short_message in bip    file_path=${C_011_bip_paging}
    ${warning_message}     Check warning_request in wireshark    file_path=${wireshark_paging_C011}
    log to console     ${warning_message}
    run keyword and continue on failure     Should Be True    '${warning_message}' == 'C011_warning'


# --------------------------------D_001-----------------------------------------#

D001_start_traffic_and_capture_bip
    [Arguments]     ${target_file_name}    ${dl_port}    ${ue_addr}
    ...             ${tcpdump_collector_name}=${C_001_wireshark_paging}
    ...             ${gnb_index}=${1}
    ...             ${Simulation_IP}=${AMF_IPaddr}
    ...             ${dl_time}=300
    ...             ${dl_traffic}=1M
    ...             ${dl_length}=1024B
    ...             ${ue_index}=${1}
    ...             ${target_throughput}=1
    ...             ${cellid}=${nrcellid}
    Start capture wireshark log on master     filename=${tcpdump_collector_name}    gNB_index=${gNB_index}
    Prepare to caculate PM counter     period=start
    Start Interface Mirroring Bip Collector     target_file_name=${target_file_name}    gnb_index=${gnb_index}
    start_traffic_via_simulator     Simulation_IP=${Simulation_IP}    dl_port=${dl_port}    ue_addr=${ue_addr}
    ...                             dl_time=${dl_time}     dl_throughput=${dl_traffic}    dl_length=${dl_length}

    ${C_001_bip_paging}    Stop and collect Bip Log Via Interface Mirroring Collector from WEBUI      target_file_name=${target_file_name}
    Check tput for MTK60     ue_index=${ue_index}     target_throughput=${target_throughput}     cellid=${cellid}
    Prepare to caculate PM counter       period=end
    [Teardown]     Run Keywords
    ...    Stop and download the wiresharklog from master    filename=${tcpdump_collector_name}    gNB_index=${gnb_index}
#    ...    AND    Run keyword and ignore error     Stop Bip Log Via Interface Mirroring Collector from WEBUI     target_file_name=${target_file_name}
    ...    AND    Close the iperf process on APPserver    port=${DL_PORT}
    ...    AND    MTK60 UE Detach     ue_index=${2}
    [Return]     ${cpif_log_path}     ${C_001_bip_paging}[0]

check counters for D_001
    [Arguments]      ${counter_id}=${counter_id_D001}
    ...              ${dic_path}=${counter_dic_path_D001}
    ...              ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #'M55117C04502'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #'M55117C04503'
    run keyword and continue on failure     should be true    ${counter_value[2]} == ${1}     #'M55331C00005'
    run keyword and continue on failure     should be true    ${counter_value[3]} == ${1}     #'M55331C00007'
    run keyword and continue on failure     should be true    ${counter_value[4]} == ${1}     #'M55117C03001'
    run keyword and continue on failure     should be true    ${counter_value[5]} == ${1}     #'M55331C00001'
    run keyword and continue on failure     should be true    ${counter_value[6]} == ${1}     #'M55331C00001'


D_001 check_logs
    [Arguments]     ${wireshark_attach_D001}    ${wireshark_paging_D001}    ${D_001_bip_paging}
    ${ue_capability_item}    Check UE_capability in wireshark    file_path=${wireshark_attach_D001}
    run keyword and continue on failure     Should Be True    '${ue_capability_item}' == 'supported'
    ${cell1_hex}    translate cellid to hex     nrcellid_value=${nrcellid}
    ${paging_tmsi_list_1}     Check paging_tmsi in bip      file_path=${D_001_bip_paging}    subcellid=1
    ${paging_tmsi_list_0}     Check paging_tmsi in bip      file_path=${D_001_bip_paging}    subcellid=0
    Check SIB Message Detail Information D001    file_path=${D_001_bip_paging}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_D001}    cellid_hex=${cell1_hex}

A_B_C_005_checkpoint
    [Arguments]     ${ABC005_bip_paging_part1}    ${wireshark_paging_ABC005_part1}
    ...    ${counter_id}=${counter_id_ABC005}    ${dic_path}=${counter_dic_path_ABC005}    ${gnb_index}=${1}
    sleep    60    reason=wait for counter count.
    ${counter_value}    Get the PM counter    counter_id=${counter_id}   dic_path=${dic_path}    timeout=300    gnb_index=${gnb_index}
    run keyword and continue on failure     should be true    ${counter_value[0]} == ${1}     #'M55331C00007'
    run keyword and continue on failure     should be true    ${counter_value[1]} == ${1}     #'M55331C00004'
    Check SIB Message Detail Information A102    file_path=${ABC005_bip_paging_part1}
    ${cell1_hex}    translate cellid to hex     nrcellid_value=${nrcellid}
    ${mt_access}     Check rrc_resume in wireshark after paging     file_path=${wireshark_paging_ABC005_part1}    cellid_hex=${cell1_hex}

Check SIB Message Detail Information D001
    [Documentation]     check after recovery from ABC005, EDRX IE should all exist.
    [Arguments]    ${file_path}
    Setup the Pcap File   file_path=${file_path}    filter=nr-rrc
    ${eDRX_AllowedInactive_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedInactive_r17    filter_expression=${None}
    ${eDRX_AllowedIdle_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.eDRX_AllowedIdle_r17    filter_expression=${None}
    ${hyperSFN_r17_value1}    Get Field Value From PCAP_file    field_name=nr-rrc.hyperSFN_r17    filter_expression=${None}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedIdle_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${hyperSFN_r17_value1}
    Run Keyword And Continue On Failure    Should Not Be Empty    ${eDRX_AllowedInactive_r17_value1}
