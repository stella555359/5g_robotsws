*** Settings ***
Force Tags    5GC000711  5GC000711-A
...           STATE_CONFIGURED
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
...           RAN_5G    RAN_5G_TDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature 5GC000711-A 2gnb
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        5GC000711-A-commissioning.robot
Resource        5GC000711-A-commissioning-2gnb.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        5GC000711-A-wts.robot
Resource        5GC000711-A-parameter-settings-2gnb.robot
Resource        5GC000711-A-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup 711A 2gnb
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

5GC000711_A_InterRAT_handover_from_LTE_with_RFSP_and_mobility_profiles
    [Documentation]    This test case verifies the gNB behavior for an inter-RAT handover from LTE to 5G with RFSP and mobility profiles
    ...       :Autor: Sylvia Schneider
    [Tags]   t8   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t8
    activate 2gnb SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session
    trigger handover to LTE   A2_meas_id=1   B2_meas_id=4
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_ho1.pcap

    start wireshark trace
    activate rfsp and mobilityProfile
    amf dl_nas_transport indexToRFSP
    trigger handover to 5G
    trigger inter gnb handover
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_ho2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t8
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_InterRAT_handover_from_LTE_with_mobility_restriction_list
    [Documentation]    This test case verifies the gNB behavior for an inter-RAT handover from LTE to 5G with mobility restriction list
    ...       :Autor: Sylvia Schneider
    [Tags]   t9   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t9
    activate 2gnb SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session
    trigger handover to LTE   A2_meas_id=1   B2_meas_id=4
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    amf mobility_restriction_list
    trigger handover to 5G
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    trigger inter gnb handover which fails
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3.pcap

    start wireshark trace
    trigger inter gnb handover
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part4.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t9
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


*** Keywords ***
Suite Setup 711A 2gnb
    [Documentation]    [PRIVATE]    Prepare TL 711A for 5GC000711-A 2gnb
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
    Update wts file for TC 711A 2gnb
    Update SCF 2gnb
