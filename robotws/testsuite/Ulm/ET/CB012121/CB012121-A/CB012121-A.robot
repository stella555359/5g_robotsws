*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-A-GMC-commissioning.robot
Resource        CB012121-A-keywords-egate.robot
Resource        CB012121-A-keywords-egate-verify.robot
Resource        CB012121-A-wts.robot
Resource        CB012121-A-counter.robot
Resource        CB012121-A-parameter-settings.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../resources/SQD60/keywords-tracing.robot


Suite Setup       Suite Setup CB012121-A
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_A_B1_ALT1_feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    [Documentation]    This test case verifies the gNB behavior for feature_activation_interaction_with_mobility_profiles_best_cell_wait_timer_zero
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir     SCFC_CB012121_B1_ALT1

    Run Keyword And Warn On Failure   prepare for dcap tracing
    Run Keyword And Warn On Failure   dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE                    ue_id=1
    set amf indexToRFSP            indexToRFSP=12
    start PDU session              ue_id=1
    send A2 with srs_result        ue_id=1   meas_id=1   srsrp_nr=11   log=1
    send A3 to trigger handover    ue_id=1   log=1
    UE Deregister                  ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_rfsp12.pcap

    change location                ue_id=1

    Log to console    \nwaiting for next measurement period to start
    wait for next measurement interval

    register UE                    ue_id=1
    set amf indexToRFSP            indexToRFSP=24
    start PDU session              ue_id=1
    send A2 with srs_result        ue_id=1   meas_id=1   srsrp_nr=11   log=2
    send A3 to trigger handover    ue_id=1   log=2
    UE Deregister                  ue_id=1

    stop wireshark trace    wireshark_store=${resultDir}/wireshark_rfsp24.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure   dcap tracing stop

    verify counter CB012121-A t1
    verify egate logs t1

    [Teardown]   Perform Postconditions of Test Scenario CB012121



*** Keywords ***
Suite Setup CB012121-A
    [Documentation]    [PRIVATE]    Prepare TL 711A for CB012121-A
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
    Update wts file for CB012121-A-B1_ALT1
    Load wts file    ${resultBaseDir}/basic_wts_CB012121-A-B1_ALT1.cfg
    Update SCF B1_ALT1
    update iphy cell-2 GSCN
