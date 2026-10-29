*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B8
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Satoshi Machii
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../CB012121-common/CB012121-keywords.robot
Resource        ../CB012121-common/CB012121-keywords-verify_syslog.robot
Resource        CB012121-B-commissioning.robot
Resource        CB012121-B-keywords-egate.robot
Resource        CB012121-B-wts.robot
Resource        CB012121-B-counter.robot
Resource        CB012121-B-parameter-settings.robot
Resource        CB012121-B-keywords-verify_syslog.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/btslog.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB012121-B
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_B_B14_ALT1_ANR_not_activated_measurement_report_with_unknown_PCI_and_second_with_known_PCI_received
    [Documentation]    This test case verifies NR_not_activated_measurement_report_with_unknown_PCI_and_second_with_known_PCI_received

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=B14

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                  ue_id=1
    start PDU session            ue_id=1
    send A2 with srs_result      ue_id=1
    send 3 times A3 and check HO
    release pdu session and deregister    ue_id=1

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    verify counter CB012121-B-B14

    [Teardown]   Perform Postconditions of Test Scenario CB012121



*** Keywords ***
Suite Setup CB012121-B
    [Documentation]    [PRIVATE]    Prepare TL 711A for CB012121-B
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
    Update SCF B-B14
    update iphy cell-2 GSCN
