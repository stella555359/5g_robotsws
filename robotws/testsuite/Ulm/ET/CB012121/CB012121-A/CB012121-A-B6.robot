*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
#-------------------------------------------------------------------------------------------------------------

Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-A-GMC-commissioning.robot
Resource        CB012121-A-B8-keywords-egate.robot
Resource        CB012121-A-keywords-egate-verify.robot
Resource        CB012121-A-wts.robot
Resource        CB012121-A-counter.robot
Resource        CB012121-A-parameter-settings.robot
Resource        CB012121-A-keywords-verify_syslog.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/btslog.robot
Resource        ../../../resources/Common/wts_ue.robot



Suite Setup       Suite Setup CB012121-A
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_A_B6_measurement_report_with_A1_best_cell_wait_timer_still_running
    [Documentation]    This test case verifies the measurement_report_with_A1_best_cell_wait_timer_still_running
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir           SCFC_CB012121_B6

    start wireshark trace
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                                    ue_id=1
    start PDU session                              ue_id=1
    display measurement config                     ue_id=1   log=1
    send A2                                        ue_id=1
    display measurement config                     ue_id=1   log=2


    send B2                                        ue_id=1
    send 3 times A3 at the same time

    send A1                                        ue_id=1
    display measurement config                     ue_id=1  log=3
    sleep   10s

    send A2                                        ue_id=1  meas_id=12    log=_2
    send A3         ue_id=1   phycell_id=52   nrsrp_nr=50   nrsrq_nr=45   meas_id=15   log=4
    sleep   15s

    release pdu session and deregister             ue_id=1
    Stop Btslog and save trace                     part=UE1

    Log to console    \nwaiting for measurement period to start
    wait for next measurement interval

    Start Btslog

    register UE                                    ue_id=2
    start PDU session                              ue_id=2
    display measurement config                     ue_id=2   log=1
    send A2                                        ue_id=2
    display measurement config                     ue_id=2   log=2

    send 1 time B2 and 2 times A3 at the same time
    sleep   10s

    send A1                                        ue_id=2
    display measurement config                     ue_id=2  log=1

    send A2                                        ue_id=2  meas_id=12    log=_2
    send A3         ue_id=2   phycell_id=52   nrsrp_nr=50   nrsrq_nr=45   meas_id=15   log=3
    sleep   15s

    release pdu session and deregister             ue_id=2
    Stop Btslog and save trace                     part=UE2

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap

    run keyword and continue on failure    check syslog file A_B6
    verify counter CB012121-A B6

    [Teardown]   Perform Postconditions of Test Scenario CB012121 without dcap



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
    Update wts file for CB012121-A-B8
    Load wts file    ${resultBaseDir}/basic_wts_CB012121-A-B8.cfg
    Update SCF B6
    update iphy cell-2 GSCN
