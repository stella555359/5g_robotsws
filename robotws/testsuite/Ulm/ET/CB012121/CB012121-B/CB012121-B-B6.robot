*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B6
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Yasir Mehmood
...             Manual Tester: Yasir Mehmood
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

CB012121_B_B6_measurement_report_with_A1_received_priority_wait_timer_is_running
    [Documentation]    This test case verifies gNB behavior when A1 measurement report is received when priority wait timer is running

    ...       :Autor: Yasir Mehmood
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=common

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                  ue_id=1
    start PDU session            ue_id=1
    display measurement config   ue_id=1    log=1
    send A2                      ue_id=1
    display measurement config   ue_id=1    log=2

    send A3   ue_id=1  phycell_id=54  nrsrp_nr=75  nrsrq_nr=70  meas_id=6  log=1
    send A3 with 2 phycell ids   ue_id=1  meas_id=5  pci1=49  nrsrp_nr1=85  nrsrq_nr1=80  pci2=51  nrsrp_nr2=65
    ...                          nrsrq_nr2=60  log=1
    send A1  ue_id=1  srsrp_nr=121   srsrq_nr=121   meas_id=4   log=1

    release pdu session and deregister   ue_id=1
    Stop Btslog and save trace   part=UE1

    Log to console   \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    Collect and Filter last PM Counters file coam
    run keyword and continue on failure    check syslog file B_B6
    verify counter CB012121-B-B6

    [Teardown]   Perform Postconditions of Test Scenario CB012121


*** Keywords ***
Suite Setup CB012121-B
    [Documentation]    [PRIVATE]    Prepare TL 711A for CB012121-B
    ...       :Autor: Yasir Mehmood
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
    Update SCF B-common
    update iphy cell-2 GSCN
