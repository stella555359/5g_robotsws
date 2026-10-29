*** Settings ***
Force Tags    5GC000711  5GC000711-A
...           STATE_CONFIGURED
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
...           RAN_5G    RAN_5G_TDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature 5GC000711-A voice
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        5GC000711-A-commissioning.robot
Resource        5GC000711-A-commissioning-voice.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        5GC000711-A-wts.robot
Resource        5GC000711-A-parameter-settings-voice.robot
Resource        5GC000711-A-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot



Suite Setup       Suite Setup 711A voice
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


5GC000711_A_InterRAT_handover_from_LTE_for_voice_over_NR_call
    [Documentation]    This test case verifies the inter-RAT handover from LTE to 5G for a voice over NR call
    ...       :Autor: Sylvia Schneider
    [Tags]   t7   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t7
    activate voice SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session
    modify ue pdu session                ue_id=1
    start UDP traffic voice and get bearer statistics
    trigger handover to LTE              A2_meas_id=2   B2_meas_id=4
    trigger handover to 5G
    stop wireshark trace

    record traffic with wireshark
    reset bearer statistics and get bearer statistics
    stop UDP traffic

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t7
    verify traffic statistics voice
    verify wireshark traffic
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Voice_fallback_via_redirection_after_interRAT_HO_from_LTE
    [Documentation]    This test case verifies the voice fallback to LTE via redirection after incoming inter-RAT handover from LTE
    ...       :Autor: Sylvia Schneider
    [Tags]   t10   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t10
    activate voice SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    amf voice_fallback
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    trigger handover to 5G
    modify ue pdu session voice fallback   ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t10
    verify egate log pdu modify
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_InterRAT_handover_from_LTE_for_emergency_call
    [Documentation]    This test case verifies the inter-RAT handover from LTE to 5G for an emergency call
    ...       :Autor: Sylvia Schneider
    [Tags]   t11   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t11
    activate voice SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    modify ue pdu session                ue_id=1
    trigger handover to LTE              A2_meas_id=2   B2_meas_id=4
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    qosflow_modify and nr_rrc_setup
    register UE and start PDU session     ue_id=3
    modify ue pdu session                 ue_id=3
    trigger handover to LTE               ue_id=3    A2_meas_id=2   B2_meas_id=4
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3.pcap

    start wireshark trace
    trigger handover to 5G which fails    ue_id=1    cause=radio resources not available
    trigger handover to 5G                ue_id=3
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part4.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t11
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


*** Keywords ***
Suite Setup 711A voice
    [Documentation]    [PRIVATE]    Prepare TL 711A for 5GC000711-A
    ...       :Autor: Sylvia Schneider
    Create ips for simulated gnb
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for TC 711A
    Update wts file for TC 711A voice
    Update SCF voice common part
