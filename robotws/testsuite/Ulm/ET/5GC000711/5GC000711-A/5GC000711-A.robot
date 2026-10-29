*** Settings ***
Force Tags    5GC000711  5GC000711-A
...           STATE_CONFIGURED
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
...           SBTS24R3__WITH__VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ
...           RAN_5G    RAN_5G_TDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature 5GC000711-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        5GC000711-A-commissioning.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        5GC000711-A-wts.robot
Resource        5GC000711-A-parameter-settings.robot
Resource        5GC000711-A-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup 711A
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

5GC000711_A_Successful_interRAT_HO_from_LTE_to_5G_without_data_forwarding
    [Documentation]    This test case verifies the gNB behavior for an inter-RAT handover from LTE to 5G without data forwarding
    ...       :Autor: Sylvia Schneider
    [Tags]   t1   CIT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t1
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session
    start UDP traffic
    get bearer statistics   after_pdu_setup
    trigger handover to LTE
    trigger handover to 5G
    stop wireshark trace

    record traffic with wireshark
    reset bearer statistics
    get bearer statistics   after_handover_5G
    stop UDP traffic
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t1
    verify traffic statistics
    verify wireshark traffic
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Cancellation_of_interRAT_handover_from_LTE
    [Documentation]    This test case verifies the cancellation of a handover preparation by source LTE side
    ...       :Autor: Sylvia Schneider
    [Tags]   t2   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t2
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session   ue_id=1
    trigger handover to LTE
    amf ng_handover_request                 ue_id=1    action=send_alternate_response
    trigger handover to 5G which is cancelled and check  ue_id=1   cause=Received UE Context Release Complete from GNB-2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_UE1.pcap

    start wireshark trace
    register UE and start PDU session   ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_UE2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t2
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Rejection_of_interRAT_handover_from_LTE
    [Documentation]    This test case verifies the rejection of an IRAT Handover preparation request by gNB
    ...       :Autor: Sylvia Schneider
    [Tags]   t3   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t3
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    trigger handover to 5G which fails   ue_id=1   cause=radio resources not available
    deregister UE                        ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    amf override_ie                      ue_id=1   nwslice=0xd143b
    trigger handover to 5G which fails   ue_id=1   cause=slice not supported
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3.pcap

    start wireshark trace
    amf reset_ie                         ue_id=1
    trigger handover to 5G               ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part4.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t3
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Abort_of_handover_due_to_expiry_of_supervision_timer
    [Documentation]   This test case verifies the abort of a prepared handover due to expiry of the supervision timer for the execution phase in gNB
    ...       :Autor: Sylvia Schneider
    [Tags]   t4   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t4
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    amf ng_handover_request                 ue_id=1    action=ignore
    trigger handover to 5G which is cancelled and check  ue_id=1   cause=T_NG_RELOC_Prep Timeout. Handover procedure is aborted
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t4
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Activation_and_deactivation_of_feature_5GC000711
    [Documentation]    This test case verifies the activation and deactivation of the feature 5GC000711
    ...       :Autor: Sylvia Schneider
    [Tags]   t5   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t5
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    trigger handover to 5G which fails   ue_id=1   cause=ho target not allowed
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    set parameters to enable handover
    trigger handover to 5G               ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t5
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_RRC_Re_Establishment_request_for_IRAT_HO_from_LTE
    [Documentation]    This test case verifies the the handling of RRC Connection Re-Establishment request received at the Target cell
    ...        of a prepared IRAT handover from LTE
    ...       :Autor: Sylvia Schneider
    [Tags]   t6   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t6
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    send rrc reconfiguration reestablish
    trigger handover to 5G               ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t6
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_DL_NAS_message_transfer_during_IRAT_HO_from_LTE
    [Documentation]    This test case verifies the DL NAS message transfer during an incoming inter-RAT handover from LTE
    ...       :Autor: Sylvia Schneider
    [Tags]   t12   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t12
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    amf ng_handover_request              ue_id=1    action=dl_nas
    trigger handover to 5G               ue_id=1    check=dedicatedNAS-Message .7E0054
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t12
    verify egate log handover 5G
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_PDU_session_setup_release_modification_during_IRAT_HO_from_LTE
    [Documentation]    This test case verifies the interaction between PDU Session Management Procedures and incoming Handover from LTE
    ...       :Autor: Sylvia Schneider
    [Tags]   t13   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t13
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE              ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1a.pcap
    start wireshark trace
    amf ng_handover_request              ue_id=1    action=pdu_setup
    trigger handover to 5G               ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1b.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    trigger handover to LTE              ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2a.pcap
    start wireshark trace
    amf ng_handover_request              ue_id=2    action=pdu_release
    trigger handover to 5G               ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2b.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=3
    trigger handover to LTE              ue_id=3
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3a.pcap
    start wireshark trace
    amf ng_handover_request              ue_id=3    action=pdu_modification
    trigger handover to 5G               ue_id=3
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3b.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t13
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Successful_location_reporting_at_incoming_IRAT_HO_from_LTE
    [Documentation]    This test scenario verifies successful Location Reporting requested at incoming inter-RAT Handover from LTE
    ...       :Autor: Sylvia Schneider
    [Tags]   t14   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t14
    tc specific update and activate SCF and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session    ue_id=1
    trigger handover to LTE              ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1a.pcap
    start wireshark trace
    amf ng_handover_request location_request        ue_id=1    action=change cell
    trigger handover to 5G               ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1b.pcap

    start wireshark trace
    register UE and start PDU session    ue_id=2
    trigger handover to LTE              ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2a.pcap
    start wireshark trace
    area of interest configuration
    amf ng_handover_request location_request        ue_id=2    action=ue presence
    trigger handover to 5G               ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2b.pcap

    start wireshark trace
    set actLocationReportingSA to false
    register UE and start PDU session    ue_id=3
    trigger handover to LTE              ue_id=3
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3a.pcap
    start wireshark trace
    amf ng_handover_request location_request        ue_id=3    action=change cell
    trigger handover to 5G               ue_id=3
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part3b.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t14
    get resources taken after_test
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


*** Keywords ***
Suite Setup 711A
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
    Update SCF common part

