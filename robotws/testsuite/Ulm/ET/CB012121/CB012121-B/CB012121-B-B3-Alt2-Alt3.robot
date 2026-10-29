*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B3-Alt2-Alt3
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
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

CB012121_B_B3_ALT2_several_measurements_received_with_same_priority_received_measurement_with_best_rsrp_selected
    [Documentation]    This test case verifies that several_measurements_received_with_same_priority_received_measurement_with_best_rsrp_selected

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=B3-Alt2-Alt3

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace
    open http session for delta commissioning
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE and start PDU and send A2       ue_id=1
    send A3 and B2 and A3                       ue_id=1
    send A3 to trigger intra-eNB handover with a3MeasEnabled    ue_id=1   a3MeasEnabled=rsrp

    release pdu session and deregister          ue_id=1
    Stop Btslog and save trace                  part=UE1

    set a3MeasEnabled to rsrq

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    Start Btslog

    register UE and start PDU and send A2       ue_id=2
    send A3 and B2 and A3                       ue_id=2
    send A3 to trigger intra-eNB handover with a3MeasEnabled    ue_id=2   a3MeasEnabled=rsrq

    release pdu session and deregister          ue_id=2
    Stop Btslog and save trace                  part=UE2


    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    close http session for delta commissioning
    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    run keyword and continue on failure    check syslog file B_B3-Alt2-Alt3
    verify counter CB012121-B-B3-Alt2-Alt3

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
    Update SCF B-B3-Alt2-Alt3
    update iphy cell-2 GSCN
