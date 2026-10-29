*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B4
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author robot scripts: Sylvia Schneider
...             Manual tester: Satoshi Machii
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-B-commissioning.robot
Resource        CB012121-B-wts.robot
Resource        CB012121-B-counter.robot
Resource        CB012121-B-parameter-settings.robot
Resource        CB012121-B-keywords-egate.robot
Resource        CB012121-B-keywords-egate-verify.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup CB012121-B
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB012121_B_B4_no_handover_started_after_priority_timer_expiry_due_to_not_allowed_pci
    [Documentation]    CB012121_B_B4_no_handover_started_after_priority_timer_expiry_due_to_not_allowed_pci
    ...       :Autor: Sylvia Schneider
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    start wireshark trace
    activate SCF and bring tl onAir   scenario=B4
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_tl_up.pcap
    check wts in active state

    Run Keyword And Continue On Failure   prepare for dcap tracing
    Run Keyword And Continue On Failure   dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace

    register UE              ue_id=1
    start PDU session        ue_id=1   check=rrcReconfigurationComplete

    send A2 with srs_result  ue_id=1
    send 2 times event A3 within 10 seconds

    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure   dcap tracing stop
    UE Deregister                           ue_id=1

    verify counter CB012121-B-B4
    verify egate logs B-B4

    [Teardown]   Perform Postconditions of Test Scenario CB012121


*** Keywords ***

Suite Setup CB012121-B
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
    Update wts file for CB012121-B-common
    Load wts file    scenario=common
    Update SCF B-B4
    update iphy cell-2 GSCN
