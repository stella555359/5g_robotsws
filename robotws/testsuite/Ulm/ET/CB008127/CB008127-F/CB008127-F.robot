*** Settings ***
Force Tags    CB008127-F
...           STATE_CONFIGURED
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
...           RAN_5G    RAN_5G_TDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature CB008127-F
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        CB008127-F-commissioning.robot
Resource        CB008127-F-wts.robot
Resource        CB008127-F-parameter-settings.robot
Resource        CB008127-F-keywords.robot
Resource        CB008127-F-keywords-egate.robot
Resource        CB008127-F-keywords-egate-verify.robot
Resource        CB008127-F-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup CB008127-F
Suite Teardown    Suite Teardown CB008127-F

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008127_F_InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    [Documentation]    InterRAT_handover_for_VoNR_call_with_5QI_criterion_in_measurement_profiles
    ...       :Autor: Sylvia Schneider
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB008127-F

    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_F_common.cfg

    start wireshark trace
    Update SCF t1
    activate SCF and bring tl onAir t1
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    register UE                             ue_id=3
    start PDU session                       ue_id=3   pdu_id=1    gw_id=3    log=1
    display measurements of UE              ue_id=3   log=1

    send event A2 with srsrp_srsrq_nr       ue_id=3   meas_id=1   srsrp_srsrq_nr=11   log=1
    display measurements of UE              ue_id=3   log=2

    send pdu session modify                 ue_id=3   qosflows_to_add=2   check=Added QosFlow with QFI:2 fiveQI:5
    send pdu session modify                 ue_id=3   qosflows_to_add=3   check=Added QosFlow with QFI:3 fiveQI:1
    display measurements of UE              ue_id=3   log=3

    send B2                                 ue_id=3   meas_id=15   nrsrp_nr=30   nrsrq_nr=30
    trigger and check interRat handover     ue_id=3   check=Inter-eNB handover from ENB-4.1 to EXT_ENB-2.1 performed
    display measurements of UE              ue_id=3   log=4

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    remove IRF from profile MA_SA-2

    send event A2 with srsrp_srsrq_nr       ue_id=3   meas_id=1   srsrp_srsrq_nr=11   log=2
    display measurements of UE              ue_id=3   log=5

    send pdu session modify del             ue_id=3   qosflows_to_del=3    check=qfi 3
    display measurements of UE              ue_id=3   log=6

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    UE Deregister                           ue_id=3

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-F t1
    verify egate logs t1

    [Teardown]   Perform Postconditions of Test Scenario CB008127-F



CB008127_F_Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    [Documentation]    Reselection_of_measurement_profile_based_on_5QI_and_CA_capability_criterions
    ...       :Autor: Sylvia Schneider
    [Tags]    t2
    [Setup]   Perform Preconditions of Test Scenario CB008127-F

    upload wts cfg file     ${resultBaseDir}/basic_wts_CB008127_F_common.cfg

    start wireshark trace
    Update SCF t2
    activate SCF and bring tl onAir t2
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    register UE                             ue_id=4
    start PDU session                       ue_id=4   pdu_id=1    gw_id=4    log=1
    display measurements of UE              ue_id=4   log=1

    additional qosflow to activate          additional_qosflows_to_activate=2,3
    start PDU session                       ue_id=4   pdu_id=2    gw_id=5    log=2
    display measurements of UE              ue_id=4   log=2

    send event A2 with srsrp_srsrq_nr       ue_id=4   meas_id=5   srsrp_srsrq_nr=60   log=1
    display measurements of UE              ue_id=4   log=3

    modify IAF-3 value a2ThresholdRedirectSsbRsrp

    send A1                                 ue_id=4   meas_id=9
    display measurements of UE              ue_id=4   log=4

    release PDU session                     ue_id=4   pdu_id=2
    display measurements of UE              ue_id=4   log=5

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    UE Deregister                           ue_id=4

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-F t2
    verify egate logs t2

    [Teardown]   Perform Postconditions of Test Scenario CB008127-F


CB008127_F_Selection_of_measurement_profile_based_on_5QI_and_RedCap_criterions
    [Documentation]    Selection_of_measurement_profile_based_on_5QI_and_RedCap_criterions
    ...       :Autor: Sylvia Schneider
    [Tags]    t3
    [Setup]   Perform Preconditions of Test Scenario CB008127-F

    Update wts file for TC CB008127-F t3
    upload wts cfg file     ${resultDir}/basic_wts_CB008127_F_t3.cfg

    start wireshark trace
    Update SCF t3
    activate SCF and bring tl onAir t3
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    register UE                             ue_id=5
    start PDU session                       ue_id=5   pdu_id=1    gw_id=5    log=1
    display measurements of UE              ue_id=5   log=1

    send event A2 with srsrp_srsrq_nr       ue_id=5   meas_id=1   srsrp_srsrq_nr=60   log=1
    display measurements of UE              ue_id=5   log=2

    send pdu session modify                 ue_id=5   qosflows_to_add=3   check=Added QosFlow with QFI:2 fiveQI:1
    display measurements of UE              ue_id=5   log=3

    send B2 no handover executed            ue_id=5   meas_id=13   nrsrp_nr=30   nrsrq_nr=20
    send B2                                 ue_id=5   meas_id=13   nrsrp_nr=30   nrsrq_nr=30

    send rrc reconf handoverFailure         ue_id=5
    trigger and check interRat handover     ue_id=5   check=UE Context Release Requested
    display measurements of UE              ue_id=5   log=4

    send pdu session modify del             ue_id=5   qosflows_to_del=3    check=qfi 2
    display measurements of UE              ue_id=4   log=5

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap
    UE Deregister                           ue_id=5

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB008127-F t3
    verify egate logs t3

    [Teardown]   Perform Postconditions of Test Scenario CB008127-F



*** Keywords ***

Suite Setup CB008127-F
    [Documentation]    [PRIVATE]    Prepare TL for CB008127-F
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
    Update wts file for TC CB008127-F common
    Update SCF common
