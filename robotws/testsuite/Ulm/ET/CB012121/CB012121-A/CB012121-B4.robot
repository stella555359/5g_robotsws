*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A-B4
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author robot scripts: Sylvia Schneider
...             Manual tester: Satoshi Machii
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-A-GMC-commissioning.robot
Resource        CB012121-A-wts.robot
Resource        CB012121-A-keywords-egate.robot
Resource        CB012121-A-keywords-egate-verify.robot
Resource        CB012121-A-counter.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup CB012121-A
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB012121_A_B4_no_handover_preparation_after_best_cell_wait_timer_expiry
    [Documentation]    CB012121_A_B4_no_handover_preparation_after_best_cell_wait_timer_expiry
    ...       :Autor: Sylvia Schneider
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    start wireshark trace
    activate SCF and bring tl onAir     SCFC_CB012121_B4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Continue On Failure   prepare for dcap tracing
    Run Keyword And Continue On Failure   dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    register UE                                       ue_id=1
    start PDU session rrcReconfigurationComplete      ue_id=1   pdu_id=1    gw_id=1

    send event A2 with srsrp_srsrq_nr                 ue_id=1   meas_id=1   srsrp_srsrq_nr=11

    send event A3                                     ue_id=1  meas_id=6   phycell_id=55   nrsrp_nr=85   log=1
    send event A3                                     ue_id=1  meas_id=5   phycell_id=54   nrsrp_nr=90   log=2

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    UE Deregister                                     ue_id=1
    Run Keyword And Continue On Failure   dcap tracing stop

    verify egate logs B4
    verify counter CB012121-A B3 and B4    counter_expectedValue=2

    [Teardown]   Perform Postconditions of Test Scenario CB012121


*** Keywords ***

Suite Setup CB012121-A
    [Documentation]    [PRIVATE]    Prepare TL for CB012121-B4
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
    Update wts file for CB012121-A-B8
    Load wts file    ${resultBaseDir}/basic_wts_CB012121-A-B8.cfg
    Update SCF B4
    update iphy cell-2 GSCN
