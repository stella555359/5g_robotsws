*** Settings ***
Documentation    Keywords for the CB013025_B_IWK1 test case

Library      ute_wtssim
Library      ta5g_tshark
Library      ta5g_throughput
Library      ta5g_egate
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/resources/airphone/L3_call.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T023/feature_resources/CB013025/resources/CB013025_keywords.robot


*** Variables ***
${CELL_ID}=     1    # ID of tested NR cell in mMIMO RU (AQQJ) with configured beamforming
${UE_ID}=       1    # ID of tested UE from EGATE configuration file connected to NR cell with cell tracing

*** Keywords ***
TC__CB013025_B_IWK1_Interaction_between_MBA_and_SBA_functionality_for_DoA_and_AoA_reporting_different_Trace_Recording_Session_types
    Activate Beamforming On Specific Position For One Subcell
    Attach SA UE And Establish PDU Session
    Exit Idle Mode And Start Data Traffic    ue_id=${UE_ID}

    Start Subscriber Trace And Wait For angleOfArrivalRecord Reports    reports_count=3
    Validate Trace Recording Session Elements SBA    filter=nsetapx.angleOfArrivalRecord        number_of_messages=1
    Validate Trace Recording Session Elements MBA    filter=nsetapx.directionOfArrivalRecord    number_of_messages=1
    Validate 2D DFT Beam Type
    Validate If Beam Params Are Coherent Across MBA And SBA Reports
    Validate Cell Trace Recording Session Is Reporting

    [Teardown]    Run Keywords
    ...           Stop Data Traffic    ues=${UE_ID}
    ...    AND    Stop Subscriber Trace    ue_id=${UE_ID}
    ...    AND    Deregister UE    ue_id=${UE_ID}


Activate Beamforming On Specific Position For One Subcell
    [Arguments]    ${ue_id}=${UE_ID}
    Log  \n==== Activate Beamforming On Specific Position For One Subcell ====  console=True
    ${beam_config_cmd}=    Catenate    ul_mimo_srs_beam_pos_nr    profile_id=1    mode=fixed    init_quad_pos=0    init_sub_quad_pos=0
    ...                        multi_path_config=true    num_of_nlos_paths=1    azimuth=0    zenith=0
    Execute Egate Cmd    cmd=${beam_config_cmd}
    Execute Egate Cmd    cmd=ue_testmode_set_nr id=${ue_id} testmode=ul_mimo_srs_beam_pos action=activate profile_id=1

Validate 2D DFT Beam Type
    Validate Beam Type    alias=${TCE_ALIAS}    beam_type=1

Start Subscriber Trace And Wait For angleOfArrivalRecord Reports
    [Arguments]    ${ue_id}=${UE_ID}    ${reports_count}=3
    Log  \n==== Start Subscriber Trace And Wait For angleOfArrivalRecord Reports ====  console=True
    Perform Action And Wait For Given Tshark Message Number    alias=${TCE_ALIAS}    packet_filter=nsetapx.DuVendorExtensionRecordDataType == 34
    ...    packet_number=${reports_count}    action=Start Subscriber Trace    ue_id=${ue_id}

Get SBA angleOfArrivalRecords Timestamps
    [Arguments]    ${alias}=${TCE_ALIAS}
    ${timestamps_regex}=    Catenate    //*[@name='nsetapx.angleOfArrivalRecord']/../../../../../*/*[@name='nsetapx.seconds']
    ...                               | //*[@name='nsetapx.angleOfArrivalRecord']/../../../../../*/*[@name='nsetapx.useconds']
    ${angleOfArrivalRecords_timestamps_list}=    Get Attribute Values From Tshark Messages
        ...    alias=${alias}
        ...    filter=nsetapx.DuVendorExtensionRecordDataType == 29 || nsetapx.DuVendorExtensionRecordDataType == 34
        ...    output_pdml_filepath=${OUTPUT_DIR}/TCE_reports_processed.pdml
        ...    element_xpath=${timestamps_regex}
        ...    attribute_xpath=.
        ...    attribute=show

    @{seconds_field}=    Set Variable    ${angleOfArrivalRecords_timestamps_list[::2]}
    @{useconds_field}=    Set Variable    ${angleOfArrivalRecords_timestamps_list[1::2]}
    @{reports_timestamp_keys}=    Evaluate    list(zip(${seconds_field}, ${useconds_field}))
    [Return]    ${reports_timestamp_keys}

Compare Beam Params In SBA And MBA Matching Reports
    [Arguments]    ${reports_timestamp_keys}    ${pdml_file_path}=${OUTPUT_DIR}/TCE_reports_processed.pdml
    FOR    ${reports_timestamp_key}    IN   @{reports_timestamp_keys}
        ${secodns}=    Set Variable    ${reports_timestamp_key[0]}
        ${useconds}=    Set Variable    ${reports_timestamp_key[1]}
        ${beamType_sba_regex}=  Catenate  //*[*[@name='nsetapx.seconds' and @show='${secodns}'] and *[@name='nsetapx.useconds' and
        ...                         @show='${useconds}']]/../*/*/*/*/*[@name='nsetapx.angleOfArrivalRecord']/*/*[@name='nsetapx.beamType']
        ${beamType_mba_regex}=  Catenate  //*[*[@name='nsetapx.seconds' and @show='${secodns}'] and *[@name='nsetapx.useconds' and
        ...                         @show='${useconds}']]/../*/*/*/*/*[@name='nsetapx.directionOfArrivalRecord']/*/*[@name='nsetapx.beamType']
        ${beamUsageTime_sba_regex}=  Catenate  //*[*[@name='nsetapx.seconds' and @show='${secodns}'] and *[@name='nsetapx.useconds' and
         ...                        @show='${useconds}']]/../*/*/*/*/*[@name='nsetapx.angleOfArrivalRecord']/*/*[@name='nsetapx.beamUsageTime']
        ${beamUsageTime_mba_regex}=  Catenate  //*[*[@name='nsetapx.seconds' and @show='${secodns}'] and *[@name='nsetapx.useconds' and
        ...                         @show='${useconds}']]/../*/*/*/*/*[@name='nsetapx.directionOfArrivalRecord']/*/*[@name='nsetapx.beamUsageTime']
        compare_elements_show_attribute_from_messages
        ...    first_pdml=${pdml_file_path}
        ...    second_pdml=${pdml_file_path}
        ...    first_xpath=${beamType_sba_regex}
        ...    second_xpath=${beamType_mba_regex}

        compare_elements_show_attribute_from_messages
        ...    first_pdml=${pdml_file_path}
        ...    second_pdml=${pdml_file_path}
        ...    first_xpath=${beamUsageTime_sba_regex}
        ...    second_xpath=${beamUsageTime_mba_regex}
    END

Validate If Beam Params Are Coherent Across MBA And SBA Reports
    Log  \n==== Validate If Beam Params Are Coherent Across MBA And SBA Reports ====  console=True
    ${angleOfArrivalRecords_timestamps_list}=    Get SBA angleOfArrivalRecords Timestamps    alias=${TCE_ALIAS}
    Compare Beam Params In SBA And MBA Matching Reports    reports_timestamp_keys=${angleOfArrivalRecords_timestamps_list}

Validate Cell Trace Recording Session Is Reporting
    Log  \n==== Validate Cell Trace Recording Session Is Reporting ====  console=True
    Verify Tshark For At Least Given Number Of Messages    alias=${TCE_ALIAS}  packet_filter=f1ap    number_of_messages=1
