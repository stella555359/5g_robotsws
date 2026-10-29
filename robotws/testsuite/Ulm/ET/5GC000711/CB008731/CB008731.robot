*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        CB008731-commissioning.robot
Resource        CB008731-wts.robot
Resource        CB008731-parameter-settings.robot
Resource        CB008731-parameter-definitions.robot
Resource        CB008731-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup CB008731
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008731_Partial_admission_control_for_interRAT_handover_from_LTE
    [Documentation]    This test case verifies the robust header compression
    ...       :Autor: Sylvia Schneider
    [Tags]    t2   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for 8731 t2
    Update SCF t2

    start wireshark trace
    activate SCF and bring tl onAir t2
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t2

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session   ue_id=1
    modify ue pdu session               ue_id=1    qosflows_to_add=4
    modify ue pdu session               ue_id=1    qosflows_to_add=5
    modify ue pdu session               ue_id=1    qosflows_to_add=6
    trigger handover to LTE             A2_meas_id=1   B2_meas_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    trigger handover to 5G which fails   ue_id=1   cause=radio resources not available
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    set actARPBasedAC to handovers
    trigger handover to 5G
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    release UE

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark 8731 t2

    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


CB008731_ARP_based_preemption_for_interRAT_HO_from_LTE
    [Documentation]    This test case verifies the preemption
    ...       :Autor: Sylvia Schneider
    [Tags]    t3   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for 8731 t3
    Update SCF t3

    start wireshark trace
    activate SCF and bring tl onAir t3
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t3

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session   ue_id=1
    modify ue pdu session               ue_id=1    qosflows_to_add=2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE                        ue_id=3
    smf param reset
    smf param additional_qosflows_to_activate
    start PDU session                  ue_id=3
    trigger handover to LTE            ue_id=3   A2_meas_id=1   B2_meas_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    register UE                        ue_id=2
    smf param reset
    start PDU session                  ue_id=2
    trigger handover to 5G             ue_id=3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    release UE

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark 8731 t3

    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

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

