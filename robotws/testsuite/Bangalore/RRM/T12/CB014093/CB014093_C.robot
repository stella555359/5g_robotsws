*** Settings ***
Documentation       :copyright: Nokia
...                 :author: Bhakti Patel
...                 :contact: bhakti.ka_patel@nokia.com
Resource            resources/CB014093_KW.robot
Suite Setup         Updated Suite Setup
Suite Teardown      Common Suite Teardown


*** Variables ***
${TOPOLOGY}         CLOUD_5G_O_E_AP_LOOO
${UE71}             71
${UE72}             72
${UE73}             73
${PATHLOSS_START}   110
${PATHLOSS_END}     130
${STEP}             5
${PCMAX}            30
${QFI1}             1
${QFI3}             3
${QFI2}             2
${QFI_ADD}          Added QosFlow with QFI
${pdu}              1


*** Test Cases ***
[1][1.0] CB014093_C_B2_1_Robustness_test_rapid_switching_of_actPusch12Sb10MhzFddLongPucch_with_Multi_UEs
    [Documentation]    Verifies RACH parameter online modification for SA capable UE in NR RRC_IDLE or RRC_INACTIVE state.
    [Tags]             QC_244123    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]            Prepare For CB014093 C
    Log To Console    \nStarting the case...
    Log To Console    \nFor UE 71
    amf_ue_ics_param
    ...    id=1
    ...    ue=71
    ...    trace_activation=on
    ...    trace_plmn=310:260
    ...    trace_ref_id=10
    ...    trace_rec_session_ref_id=20
    ...    trace_depth=medium
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1
    ...    tce_ip=10.0.1.1
    ...    core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=256
    ...    periodic_registration_update_timer=1:10min
    ...    plmn_id=310:260
    ...    tac_id=200
    UE Register Should Be Successful For SA    ${UE71}
    Validate TCP Traffic                       ${UE71}    ${QFI1}
    Modify PDU Session For UE To Add           ${UE71}    ${pdu}    ${QFI2}    ${QFI_ADD}
    ue_stats_nr                                id=${UE71}    type=pdsch,pusch    scell=0-1
    Validate TCP Traffic                       ${UE71}    ${QFI2}
    Modify PDU Session For UE To Add           ${UE71}    ${pdu}    ${QFI3}    ${QFI_ADD}
    Validate Traffic With RTP                  ${UE71}    ${QFI3}
    run keyword and ignore error      Verify Throughput Reduces As Pathloss Increases    ${UE71}
    run keyword and ignore error      Enable actUlDftSOfdm Value And Verify Egate
#    Disable actUlDftSOfdm Value And Verify Egate

    Log To Console    \nFor UE 72
    amf_ue_ics_param
    ...    id=1
    ...    ue=72
    ...    trace_activation=on
    ...    trace_plmn=310:260
    ...    trace_ref_id=10
    ...    trace_rec_session_ref_id=20
    ...    trace_depth=medium
    ...    ifaces_to_trace=NG-C,Xn-C,Uu,F1-C,E1
    ...    tce_ip=10.0.1.1
    ...    core_network_assistance_info=on
    ...    ue_identity_index_value=1
    ...    ue_specific_drx=256
    ...    periodic_registration_update_timer=1:10min
    ...    plmn_id=310:260
    ...    tac_id=200
    Start TTI_TRACE custom    53
    UE Register Should Be Successful For SA    ${UE72}
    Validate TCP Traffic                       ${UE72}    ${QFI1}
    RUN KEYWORD AND IGNORE ERROR      Disable actUlDftSOfdm Value And Verify Egate
    Stop ttitrace Collection    ${log_path}
    Common Convert Ttitrace From Pcap To Excelcsv     ${log_path}

    Log To Console    \nFor UE 73
    UE Register Should Be Successful For SA    ${UE73}
    Validate TCP Traffic                       ${UE73}    ${QFI1}
    RUN KEYWORD AND IGNORE ERROR      Disable actUlDftSOfdm Value And Verify Egate
    [Teardown]    Teardown For CB014093 C


*** Keywords ***
Enable actUlDftSOfdm Value And Verify Egate
    admin.Setup Admin
    Online NIDD Parameter Change
    ...    paramName=actUlDftSOfdm
    ...    paramValue=True
    ...    paramDst=MRBTS-1/NRBTS-1/NRCELL-4
    ...    skip_parameter_relation_errors=False
    admin.Teardown Admin
    ${output}=    wtsrunner.read_wtsemu_output_until_re
    ...    expected=transformPrecoder enabled
    ...    timeout=60
    ${output}=    Get Lines Matching Regexp
    ...    ${output}
    ...    transformPrecoder enabled
    ...    partial_match=${TRUE}
    Log To Console    \n${output}


Disable actUlDftSOfdm Value And Verify Egate
    admin.Setup Admin
    Online NIDD Parameter Change
    ...    paramName=actUlDftSOfdm
    ...    paramValue=False
    ...    paramDst=MRBTS-1/NRBTS-1/NRCELL-4
    ...    skip_parameter_relation_errors=False
    admin.Teardown Admin
    ${output}=    wtsrunner.read_wtsemu_output_until_re
    ...    expected=transformPrecoder disabled
    ...    timeout=60
    ${output}=    Get Lines Matching Regexp
    ...    ${output}
    ...    transformPrecoder disabled
    ...    partial_match=${TRUE}
    Log To Console    \n${output}
