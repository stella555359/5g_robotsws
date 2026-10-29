*** Settings ***
Library    Collections
Library    DateTime
Library    OperatingSystem
Library    String
Library    taf.nms.netact    WITH NAME    nms_netact
Library    taf.sbts.oam.coam.admin    WITH NAME    admin
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.collectors.l1l2bip        WITH NAME      l1l2bip
Library    taf.collectors.core           WITH NAME      core
Library    taf.ul.mobile.ui.android    WITH NAME    mobile
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.hw.rf_attenuator.attenuator  WITH NAME  attenuator
Library    taf.transport.ssh    WITH NAME    SSH
# Library    ../Python/common_functions.py    WITH NAME   common_function
Library      taf.selenium.sbts    WITH NAME    selenium_sbts_anr
Library      ../python/admin_handler.py    WITH NAME   admin_connection
Library      ../python/Test_Verification_Handler.py    WITH NAME    Verify
Resource     Common_keywords.resource
Resource     logging_keywords.resource
Resource     selenium_sbts_wrapper.resource
Variables    variables/ANR_test_case_variables.py
Variables    variables/alarm_variables.py


*** Keywords ***
Rjio E2E 63 Mobility UE based ANR
    [Documentation]     ANR mobility scenario and requiring UE for Handover.
    ...    :attenuator used for Setup.
    [Arguments]    ${check_HO}=${False}    ${ue_index}=${0}
    ${alarm_status}  BuiltIn.Run Keyword And Return Status  Verify.Acitive_Alarm_Verification_Test  ${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'
    ...    FAIL    Unexpected Alarm found.!
    @{NRADJNRCELL_create_list}    BuiltIn.Create List
    @{NRREL_create_list}    BuiltIn.Create List
    Run Keyword And Continue On Failure    UE_keywords.Require UE
    FOR    ${port}    IN    @{Attenuator_Ports_1061_1063}
        Common_keywords.Set_attenuation_on_single_port  port=${port}
        ...    value=${value_in_dB}[-1]  Attenuator_device_config=${att}
        Sleep    2s
        BuiltIn.Log To Console    [ INFO ]: Attenuation value ${value_in_dB}[-1] set on port ${port}
    END
    FOR   ${index}   IN RANGE   0    1
        ${NRADJNRCELL_creat_status}    Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_63_Mobility_UE_based_ANR'
        ...    ANR_NRADJNRCELL_Verification
        BuiltIn.Set Test Variable   ${NRADJNRCELL_creat_status} 
        ${NRREL_creat_status}    Run Keyword If
        ...    '${TEST_NAME}' == 'Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor'    ANR_NRREL_Verification
        Set Test Variable    ${NRREL_creat_status}
        Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_63_Mobility_UE_based_ANR'
        ...    append to list    ${NRADJNRCELL_create_list}   ${NRADJNRCELL_creat_status}
        Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor'
        ...    append to list    ${NRREL_create_list}   ${NRREL_creat_status}
    END
    Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_63_Mobility_UE_based_ANR'
    ...    BuiltIn.Log To Console    [ INFO ]: NRADJNECELL List: ${NRADJNRCELL_create_list}
    Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor'    
    ...    BuiltIn.Log To Console    [ INFO ]: NRREL List: ${NRREL_create_list}
    Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_63_Mobility_UE_based_ANR'
    ...    Should Not Be Empty    ${NRADJNRCELL_create_list}
    # ...    common_function.get_item_in_list    item_list=${NRADJNRCELL_create_list}    item=${False}
    Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor'
    # ...    common_function.get_item_in_list    item_list=${NRREL_create_list}    item=${False}
    ...    Should Not Be Empty    ${NRREL_create_list}
    # Run Keyword If    '${TEST_NAME}' == 'Rjio E2E 63 Mobility UE based ANR'
    # ...    Should Be Equal    ${NRADJNRCELL_fail_status}    ${0}
    # Run Keyword If    '${TEST_NAME}' == 'Rjio_E2E_67_Mobility_UE_based_ANR_for_EUTRA_Neighbor'
    # ...    Should Be Equal    ${NRREL_fail_status}    ${0}
    [Teardown]    Run keywords    Common_keywords.set_attenuation_on_multi_port    ports=${Attenuator_Ports_1061_1063}
    ...    value=${value_in_dB}[-1]
    ...    Attenuator_device_config=${att}
    ...    AND    BuiltIn.Log To Console    [ INFO ]: ${TEST_NAME} : COMPLETED

ANR_NRREL_Verification
    [Documentation]    Functionality of ANR
    [Arguments]    ${NRREL}=${256}    ${ue_index}=${0} 
    selenium_sbts_wrapper.RJIO_Sbts_Login_And_Disable_Screen_Lock  
    @{empty_list}    Create List
    BuiltIn.Log To Console    \n[ INFO ]: Delete NR-NR neighbor Object If Exist
    FOR    ${NRCELL_id}    IN    @{NR_cell_ids}
        ${neighbor_NRREL}  selenium_sbts_anr.get_object_name_list
        ...        object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_id}/NRREL-${NRREL}
        ${neighbor_NRREL_length}    Get Length    ${neighbor_NRREL}
        Run Keyword if   ${neighbor_NRREL_length}!=${0}     admin_connection.delete_object_recommission
        ...    distname=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_id}/NRREL-${NRREL}
    END
    Wait until keyword succeeds    10min    30s    Common_keywords.Verify_all_cells_should_be_onair
    BuiltIn.Log To Console    [ INFO ]: All cells are verified on air status
    ${alarm_status}    BuiltIn.Run Keyword And Return Status    Verify.Acitive_Alarm_Verification_Test    ${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!  
    FOR   ${index}   IN RANGE   0    1
        Run Keyword If    '${mrbtsID}'=='${Required_MRBTSID}'    ANR_NR_to_EUTRA_Handover    
    END
    @{count_nrrel}    Create List    
    FOR    ${NRCELL_id}    IN    @{NR_cell_ids}
        ${NRREL_creat_status}    selenium_sbts_anr.get_object_name_list
        ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_id}/NRREL-${NRREL}
        Append To List    ${count_nrrel}    ${NRREL_creat_status}
    END
    ${neighbor_NRREL_length}    Get Length    ${count_nrrel}
    ${NRREL_create_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRREL_length}    ${0}
    Wait until keyword succeeds    10min    30s    Common_keywords.Verify_all_cells_should_be_onair
    BuiltIn.Log To Console    [ INFO ]: All cells are verified on air status
    ${alarm_status}  BuiltIn.Run Keyword And Return Status  Verify.Acitive_Alarm_Verification_Test  ${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'
    ...    FAIL    Unexpected Alarm found.!
    # under implementation. 
    @{counter_id_create_list}    BuiltIn.Create List    No_RRC_Reconfig_msg_rpt_NR_CGI
    ...    No_RRC_Measurement_rpt_NR_CGI
    @{counter_check_cell_list}    BuiltIn.Create List    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${NRCELL_id}
    Wait Until Keyword Succeeds    20min    5min    Verify.Verify_PM_Counter_Test
    ...    MRBTS=${BTS_name}    NRBTS=${NRBTS_NAME}
    ...    counter_id=${counter_id_create_list}
    ...    cell_ids=${counter_check_cell_list}

    [Return]    ${NRREL_create_status}
    [Teardown]    Run Keywords    selenium_sbts_wrapper.RJIO_Sbts_Logout_And_Close_Browser
    ...        AND   Run Keyword And Continue On Failure    Verify.Snapshot_Collection_test
    ...        snapshot_path=${TS_CASE_LOG_PATH}    test_name=${TEST_NAME}   
    ...    AND    Run Keyword And Continue On Failure    Verify.Im_Snapshot_Collection_test
    ...        im_snapshot_path=${TS_CASE_LOG_PATH}    test_name=${TEST_NAME}

ANR_NRADJNRCELL_Verification
    [Documentation]
    [Arguments]    ${NRADJNRCELL}=${12288}    ${ue_index}=${0} 

    selenium_sbts_wrapper.RJIO_Sbts_Login_And_Disable_Screen_Lock  
    @{empty_list}    Create List
    BuiltIn.Log To Console    \n[ INFO ]: Delete NR-NR neighbor Object If Exist
    ${neighbor_NRADJNRCELL}    selenium_sbts_anr.get_object_name_list
    ...        object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL}
    ${neighbor_NRADJNRCELL_length}    Get Length    ${neighbor_NRADJNRCELL}

    Run Keyword if   ${neighbor_NRADJNRCELL_length}!=${0}    admin_connection.delete_object_recommission
    ...    distname=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL} 
    Wait until keyword succeeds    10min    30s    Common_keywords.Verify_all_cells_should_be_onair
    BuiltIn.Log To Console    [ INFO ]: All cells are verified on air status
    ${alarm_status}    BuiltIn.Run Keyword And Return Status    Verify.Acitive_Alarm_Verification_Test    ${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!  
    FOR   ${index}   IN RANGE   0    1
        Run Keyword If    '${mrbtsID}'=='${Required_MRBTSID}'    ANR_NR_to_NR_Handover
    END
    ${neighbor_NRADJNRCELL}    selenium_sbts_anr.get_object_name_list    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRADJNRCELL-${NRADJNRCELL}
    ${neighbor_NRADJNRCELL_length}    Get Length    ${neighbor_NRADJNRCELL}
    ${NRADJNRCELL_creat_status}=    Run Keyword And Return Status
    ...    Should Not Be Equal    ${neighbor_NRADJNRCELL_length}    ${0}
    Wait until keyword succeeds    10min    30s    Common_keywords.Verify_all_cells_should_be_onair
    BuiltIn.Log To Console    [ INFO ]: All cells are verified on air status
    ${alarm_status}    BuiltIn.Run Keyword And Return Status    Verify.Acitive_Alarm_Verification_Test    ${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Run Keyword If    '${alarm_status}' == '${False}'     FAIL    Unexpected Alarm found.!  
    [Return]    ${NRADJNRCELL_creat_status}
    [Teardown]    Run Keywords    selenium_sbts_wrapper.RJIO_Sbts_Logout_And_Close_Browser
    ...        AND    Run Keyword And Continue On Failure    Verify.Snapshot_Collection_test
    ...        snapshot_path=${TS_CASE_LOG_PATH}    test_name=${TEST_NAME}     
    ...    AND    Run Keyword And Continue On Failure    Verify.Im_Snapshot_Collection_test
    ...        im_snapshot_path=${TS_CASE_LOG_PATH}    test_name=${TEST_NAME}

ANR_NR_to_NR_Handover
    [Documentation]    Keyword does the attach UE to Primary/Source Cell in BTS. Prefered cell id -0. 
    ...    Performing 2 iteration of attenuating the Radio signal for Handover purpose. 
    ...    : Constant is Setup attenuator. 
    [Arguments]    ${flag_call}=${False}    ${ue_index}=${0}

    BuiltIn.Log To Console    [ INFO ]: BTS 1061 Set PVA_port_1 is 0 db and attach UE.
    @{sliced_port_1}    Collections.Get Slice From List    ${Attenuator_Ports_1061_1063}    0    1
    @{sliced_port_8}    Collections.Get Slice From List    ${Attenuator_Ports_1061_1063}    -1   
    Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
    ...        value=${value_in_dB}[0]
    ...        Attenuator_device_config=${att}
    BuiltIn.Log To Console    [ INFO ]: Port 1 Seted to 0dB.
    Wait Until Keyword Succeeds    2 minute    20 s    UE_keywords.Attach Ue via taf ue    ue_alias=${ue_alias}
    BuiltIn.Log To Console    [ INFO ]: UE ATTACH and Start UDP Data.
    BuiltIn.Log To Console    [ INFO ]: Loop Started PVA_port_1 & port 8 
    FOR  ${i}  IN RANGE  0    2
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[7]
        ...        value=${value_in_dB}[0]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[1]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[2]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[3]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[0]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[7]
        ...        value=${value_in_dB}[1]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[7]
        ...        value=${value_in_dB}[2]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[7]
        ...        value=${value_in_dB}[3]
        ...        Attenuator_device_config=${att}
        Sleep    5s
    END
    # run keyword if    ${flag_call}==${True}    run keywords    Stop and download Logs from eNB(gnb1) to local    log_name=gnb.pcap    AND
    # ...     Check message with inter gnb HO on target    logname=gnb.pcap
    BuiltIn.Run Keyword And Continue On Failure    UE_keywords.Detach Ue via taf ue    ue_alias=${ue_alias}
    

ANR_NR_to_EUTRA_Handover
    [Documentation]    Keyword performing UE attach to sourcing Cell and attenuating the Radio Signals For handover. 

    BuiltIn.Log To Console    [ INFO ]: BTS 1061 Set PVA_port_1 is 0 db and attach UE.
    @{sliced_port_1}    Collections.Get Slice From List    ${Attenuator_Ports_1061_1063}    0    1
    @{sliced_port_8}    Collections.Get Slice From List    ${Attenuator_Ports_1061_1063}    -1   
    Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
    ...        value=${value_in_dB}[0]
    ...        Attenuator_device_config=${att}
    BuiltIn.Log To Console    [ INFO ]: Port 1 Seted to 0dB.
    Sleep    10 s
    Wait Until Keyword Succeeds    2 minute    20 s    UE_keywords.Attach Ue via taf ue    ue_alias=${ue_alias}
    BuiltIn.Log To Console    [ INFO ]: UE ATTACH and Start UDP Data.
    Sleep    5s
    BuiltIn.Log To Console    [ INFO ]: Loop Started PVA_port_1 & port 8 
    FOR  ${i}  IN RANGE  0    2
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[6]
        ...        value=${value_in_dB}[0]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[1]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[2]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[3]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[0]
        ...        value=${value_in_dB}[0]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[6]
        ...        value=${value_in_dB}[1]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[6]
        ...        value=${value_in_dB}[2]
        ...        Attenuator_device_config=${att}
        Sleep    5s
        Common_keywords.Set_attenuation_on_single_port    port=${Attenuator_Ports_1061_1063}[6]
        ...        value=${value_in_dB}[3]
        ...        Attenuator_device_config=${att}
        Sleep    5s
    END
    BuiltIn.Run Keyword And Continue On Failure    UE_keywords.Detach Ue via taf ue    ue_alias=${ue_alias}
