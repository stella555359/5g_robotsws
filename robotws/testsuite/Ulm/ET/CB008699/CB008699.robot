*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008699
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB008699-commissioning.robot
Resource        CB008699-wts.robot
Resource        CB008699-parameter-settings.robot
Resource        CB008699-keywords.robot
Resource        CB008699-keywords-egate.robot
Resource        CB008699-keywords-traffic.robot
Resource        CB008699-keywords-wireshark.robot

Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/btslog.robot

Resource        ../resources/SQD60/keywords-tracing.robot

Library         ../../resources/Common/syslog_parser/syslog_parser.py


Suite Setup       Suite Setup CB008699
Suite Teardown    Suite Teardown CB008699

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${dir_syslog_parser}                  ${CURDIR}/../../resources/Common/syslog_parser

*** Test Cases ***


CB008699_A_Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Source_DRB_to_QoS_flow_mapping_missing_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t1   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t1_t5

    start wireshark trace
    activate SCF and bring tl onAir t1_t5
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t1_t5

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    ue change location
    set traffic type in egate
    register UE    1
    start PDU session
    start UDP traffic and get bearer statistics

    set ue history
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send XN handover preparation   action=modify_drb_qos_exclude_mapping
    send A3 measurement and save egate log    result=handover cancel    log_id=1
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    set parameter actFullRRCConfigurationSaHo to enabled
    start wireshark trace
    send A3 measurement and save egate log    result=handover successful ENB-3.1    log_id=2
    get time after handover
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap

    reset bearer statistics
    get bearer statistics    run=after_handover   delay=50s
    stop UDP traffic
    release UE
    get time after release
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Stop Btslog   target_dir=${resultDir}
    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008699
    verify wireshark CB008699 t1_t5
    verify traffic statistics
    verify egate log contains fullConfig true in egate_log_HO_log2
    verify syslog trace

    [Teardown]   Perform Postconditions of Test Scenario CB008699


CB008699_B_Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Unknown_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t2   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t2_t3

    start wireshark trace
    activate SCF and bring tl onAir t2_t3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t2

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    ue change location
    set traffic type in egate
    register UE    1
    start PDU session
    start UDP traffic and get bearer statistics

    set ue history
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send XN handover preparation   action=add_unsupported_extensions_nonCritical
    send A3 measurement and save egate log    result=handover successful ENB-3.1    log_id=1
    get time after handover
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    reset bearer statistics
    get bearer statistics    run=after_handover   delay=50s
    stop UDP traffic
    release UE
    get time after release
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008699
    verify wireshark CB008699 t2
    verify traffic statistics
    verify egate log contains fullConfig true in egate_log_HO_log1

    [Teardown]   Perform Postconditions of Test Scenario CB008699



CB008699_B_Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Unknown_critical_RRC_extension_detected_by_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t3   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t2_t3

    start wireshark trace
    activate SCF and bring tl onAir t2_t3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t3

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    start wireshark trace
    ue change location
    register UE    1
    start PDU session
    set ue history
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send XN handover preparation   action=add_unsupported_extensions_Critical
    send A3 measurement and save egate log    result=handover cancel    log_id=1
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    verify wireshark CB008699 t3

    [Teardown]   Perform Postconditions of Test Scenario CB008699



CB008699_A_Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Source_DRB_to_QoS_flow_mapping_not_supported_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t4   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t4

    start wireshark trace
    activate SCF and bring tl onAir t4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t4

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    ue change location   cell=2
    set traffic type in egate
    register UE    1
    start PDU session
    modify PDU session
    start UDP traffic and get bearer statistics t4
    set ue history
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send XN handover preparation   action=modify_drb_qos_incompatible_mapping
    send A3 measurement and save egate log    result=handover successful ENB-3.2    log_id=1
    get time after handover
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    reset bearer statistics
    get bearer statistics t4   run=after_handover   delay=50s
    stop UDP traffic
    release UE
    get time after release
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008699 t4
    verify wireshark CB008699 t4
    verify traffic statistics t4
    verify egate log contains fullConfig true in egate_log_HO_log1

    [Teardown]   Perform Postconditions of Test Scenario CB008699


CB008699_CNI_96896_Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Data_Forwarding_Info_is_missing_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t5   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t1_t5

    start wireshark trace
    activate SCF and bring tl onAir t1_t5
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t1_t5

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    ue change location
    set traffic type in egate
    register UE    1
    start PDU session
    start UDP traffic and get bearer statistics

    set ue history
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send XN handover preparation   action=modify_drb_qos_exclude_DataForward
    send A3 measurement and save egate log    result=handover cancel    log_id=1
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    set parameter actFullRRCConfigurationSaHo to enabled
    start wireshark trace
    send A3 measurement and save egate log    result=handover successful ENB-3.1    log_id=2
    get time after handover
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap

    reset bearer statistics
    get bearer statistics    run=after_handover   delay=50s
    stop UDP traffic
    release UE
    get time after release
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008699
    verify wireshark CB008699 t1_t5
    verify traffic statistics
    verify egate log contains fullConfig true in egate_log_HO_log2

    [Teardown]   Perform Postconditions of Test Scenario CB008699


CB008699_Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    [Documentation]    This test case verifies Force_full_RRC_configuration_at_target_gNB_during_Xn_handover
    ...       :Autor: Sylvia Schneider
    [Tags]    t6   CRT
    [Setup]   Perform Preconditions of Test Scenario CB008699
    Update SCF t6

    start wireshark trace
    activate SCF and bring tl onAir t6
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    check wts in active state
    set sib period for gnb3
    prepare counters and expected values t6

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    register UE and start PDU session   ue_id=1  cell=1
    register UE and start PDU session   ue_id=2  cell=1
    register UE and start PDU session   ue_id=3  cell=2
    register UE and start PDU session   ue_id=4  cell=2

    set ue history
    set ue enb param with ue history list for additional UEs

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    send A3 measurement for UE1 in cell1 and save egate log
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_handover_UE1.pcap

    set parameter actForceFullRRCConfigurationSaHo to enabled

    start wireshark trace
    send A3 measurement for UE2 in cell1 and save egate log
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_handover_UE2.pcap

    set parameter actForceFullRRCConfigurationSaHo to onlyXnHo

    start wireshark trace
    send A3 measurement for UE3 in cell2 and save egate log
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_handover_UE3.pcap

    set parameter actForceFullRRCConfigurationSaHo to onlyNgHo

    start wireshark trace
    send A3 measurement for UE4 in cell2 and save egate log
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_handover_UE4.pcap

    release UE

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008699 t6
    verify egate log CB008699 t6
    verify wireshark CB008699 t6

    [Teardown]   Perform Postconditions of Test Scenario CB008699
