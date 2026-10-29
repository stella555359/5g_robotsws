*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731 voice
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

Library         DateTime

Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        CB008731-commissioning-voice.robot
Resource        CB008731-verify-counter.robot
Resource        CB008731-verify-wireshark.robot
Resource        CB008731-keywords-traffic.robot
Resource        CB008731-wts.robot
Resource        CB008731-parameter-settings-voice.robot
Resource        CB008731-parameter-definitions.robot

Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup CB008731
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008731_InterRAT_handover_from_LTE_with_ROHC_for_VoNR_call
    [Documentation]    This test case verifies the robust header compression
    ...       :Autor: Sylvia Schneider
    [Tags]    t1   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for TC CB008731 voice t1
    Update SCF t1
    start wireshark trace
    activate SCF and bring tl onAir t1
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t1

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session
    modify ue pdu session                ue_id=1
    start UDP traffic voice and get bearer statistics
    trigger handover to LTE              A2_meas_id=2   B2_meas_id=4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    Log To Console    \nwaiting for next measurement period to start
    wait for next measurement interval
    Save Date For Egate Log 2ndPeriod

    start wireshark trace
    trigger handover to 5G
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    record traffic with wireshark
    reset bearer statistics and get bearer statistics
    keep traffic running
    stop UDP traffic

    release UE
    get time after release
    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm counter file and filter last 2 PM Counters file coam
    verify counters of 1st measurement period t1
    verify counter of 2nd measurment period t1
    verify wireshark 8731 t1
    verify traffic statistics voice
    verify wireshark traffic

    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


CB008731_InterRAT_handover_from_LTE_with_high_priority_access
    [Documentation]    This test case verifies the high priority access
    ...       :Autor: Sylvia Schneider
    [Tags]    t4   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for TC CB008731 voice t4
    Update SCF t4
    start wireshark trace
    activate SCF and bring tl onAir t4
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t4

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session   ue_id=1
    modify ue pdu session               ue_id=1
    trigger handover to LTE             A2_meas_id=2   B2_meas_id=4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    qosflow_modify and nr_rrc_setup high priority access
    register UE and start PDU session   ue_id=3
    modify ue pdu session               ue_id=3
    trigger handover to LTE             ue_id=3    A2_meas_id=2   B2_meas_id=4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    Log To Console    \nwaiting for next measurement period to start
    wait for next measurement interval
    Save Date For Egate Log 2ndPeriod

    start wireshark trace
    trigger handover to 5G which fails   ue_id=1   cause=radio resources not available
    trigger handover to 5G   ue_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap

    keep traffic running
    modify ue pdu session del qosflows    ue_id=3
    UE Deregister                         ue_id=3
    get time after release

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    release UE

    collect pm counter file and filter last 2 PM Counters file coam
    verify counters of 1st measurement period t4
    verify counter of 2nd measurment period t4
    verify wireshark 8731 t4

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


CB008731_InterRAT_HO_from_LTE_with_GBR_services_for_non_voice_bearer
    [Documentation]    This test case verifies GBR services for non voice bearer
    ...       :Autor: Sylvia Schneider
    [Tags]    t5   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for TC CB008731 voice t5
    Update SCF t5
    start wireshark trace
    activate SCF and bring tl onAir t5
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t5

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session   ue_id=1
    modify ue pdu session               ue_id=1    qosflows_to_add=2
    modify ue pdu session               ue_id=1    qosflows_to_add=3
    start UDP traffic voice for 8731 t5 ue1 and get bearer statistics
    trigger handover to LTE             ue_id=1    A2_meas_id=2   B2_meas_id=4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and prepare traffic and start PDU session   ue_id=2
    modify ue pdu session                ue_id=2   qosflows_to_add=4
    start UDP traffic voice for 8731 t5 ue2 and get bearer statistics
    trigger handover to LTE              ue_id=2    A2_meas_id=1   B2_meas_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    Log To Console    \nwaiting for next measurement period to start
    wait for next measurement interval
    Save Date For Egate Log 2ndPeriod

    start wireshark trace
    trigger handover to 5G     ue_id=1
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    start wireshark trace
    trigger handover to 5G     ue_id=2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap

    start wireshark trace
    reset bearer statistics  ue_id=1
    reset bearer statistics  ue_id=2
    keep traffic running
    get 8731 t5 u1 voice bearer statistics   run=end
    get 8731 t5 u2 voice bearer statistics   run=end
    stop UDP traffic    ue_id=1
    stop UDP traffic    ue_id=2
    release UE
    get time after release
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part5.pcap

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify counter of last measurment period t5
    verify wireshark 8731 t5
    verify traffic statistics t5

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


*** Keywords ***
Suite Setup CB008731
    [Documentation]    [PRIVATE]    Prepare TL for CB008731
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
    Update wts file for TC CB008731 common part


get time after release
    [Documentation]    [PRIVATE]    get time after release
    ...       :Autor: Sylvia Schneider
    ${act_time}     DateTime.Get Current Date
    Set Test Variable    ${time_release}    ${act_time}
    Log To Console    actual time was saved to parameter time_release "${time_release}"


keep traffic running
    [Documentation]    [PRIVATE]    keep traffic running
    ...       :Autor: Sylvia Schneider
    Sleep    60s   reason=keep traffic running

