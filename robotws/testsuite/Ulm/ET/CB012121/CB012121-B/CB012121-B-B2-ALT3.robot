*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B2-Alt3
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../CB012121-common/CB012121-keywords.robot
Resource        ../CB012121-common/CB012121-keywords-verify_syslog.robot
Resource        CB012121-B-commissioning.robot
Resource        CB012121-B-keywords-egate.robot
Resource        CB012121-B-B10-keywords-egate.robot
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

CB012121_B_B2_ALT3_after_inter_frequency_Handover_via_XN_priority_wait_timer_started
    [Documentation]    This test case verifies that after_inter_frequency_Handover_via_XN_priority_wait_timer_started

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=B10

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                  ue_id=21
    start PDU session            ue_id=21
    display measurement config   ue_id=21    log=1
    send A2                      ue_id=21    log=_1
    display measurement config   ue_id=21    log=2

    send A3    ue_id=21   phycell_id=55   nrsrp_nr=60   nrsrq_nr=45   meas_id=7   log=1
    sleep  4s

    send A3 and check   ue_id=21   phycell_id=50   nrsrp_nr=50   nrsrq_nr=50  meas_id=5
    ...   check=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed  timeout=15   log=2
    display measurement config   ue_id=21    log=3

    send A2                      ue_id=21   meas_id=11   log=_2
    display measurement config   ue_id=21    log=3

    send B2 nrsrq_nr             ue_id=21
    sleep  4s

    send A3 and check   ue_id=21   phycell_id=49   nrsrp_nr=55   nrsrq_nr=45  meas_id=15
    ...   check=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed  timeout=15   log=3
    display measurement config   ue_id=21    log=3

    release pdu session and deregister          ue_id=21
    Stop Btslog and save trace                 part=UE21

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    run keyword and continue on failure    check syslog file B_B2-Alt3
    verify counter CB012121-B-B2-Alt3

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
    Update SCF B-B10
    update iphy cell-2 GSCN
