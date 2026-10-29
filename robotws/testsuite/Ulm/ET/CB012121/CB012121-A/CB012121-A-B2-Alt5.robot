*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-A-GMC-commissioning.robot
Resource        CB012121-A-keywords-egate.robot
Resource        CB012121-A-keywords-egate-verify.robot
Resource        CB012121-A-wts.robot
Resource        CB012121-A-counter.robot
Resource        CB012121-A-parameter-settings.robot
Resource        CB012121-A-keywords-verify_syslog.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/btslog.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB012121-A
Suite Teardown    Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_A_B2_ALT5_after_intra_frequency_Handover_via_XN_best_cell_wait_timer_started
    [Documentation]    This test case verifies the gNB behavior A_B2_ALT5_after_intra_frequency_Handover_via_XN_best_cell_wait_timer_started
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir     SCFC_CB012121_B2-Alt5

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    Start Btslog
    start wireshark trace
    register UE                    ue_id=21   nwslice=1
    UE PDU Session Setup           ue_id=21   pdu=1   nwslice=1   gw=21
    display measurement config     ue_id=21   log=1

    send A2                        ue_id=21   meas_id=1   srsrp_nr=30    log=1
    display measurement config     ue_id=21   log=2

    send A3                        ue_id=21   phycell_id=52   meas_id=6  nrsrp_nr=50   nrsrq_nr=45  log=1
    send A3 and check              ue_id=21   phycell_id=50   meas_id=2  nrsrp_nr=50   nrsrq_nr=45  log=2
    ...   check=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    display measurement config     ue_id=21   log=3

    send A2                        ue_id=21   meas_id=11  srsrp_nr=30      log=2
    display measurement config     ue_id=21   log=4

    send A3                        ue_id=21   phycell_id=52   meas_id=15  nrsrp_nr=50   nrsrq_nr=45   log=3
    sleep     10s

    UE PDU Session Release         ue_id=21   pdu=1
    UE Deregister                  ue_id=21
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_1.pcap
    Stop Btslog and save trace   part=UE21

    Log to console    \nwaiting for next measurement period to start
    wait for next measurement interval

    Start Btslog
    start wireshark trace
    register UE                    ue_id=22   nwslice=1
    UE PDU Session Setup           ue_id=22   pdu=1   nwslice=1   gw=22
    display measurement config     ue_id=22   log=1

    send A2                        ue_id=22   meas_id=1   srsrp_nr=30    log=1
    display measurement config     ue_id=22   log=2

    send A3                        ue_id=22   phycell_id=52   meas_id=6  nrsrp_nr=50   nrsrq_nr=45  log=1
    send A3 and check              ue_id=22   phycell_id=50   meas_id=2  nrsrp_nr=50   nrsrq_nr=45  log=2
    ...   check=Intra-eNB handover from EXT_ENB-2.2 to EXT_ENB-2.1 performed
    display measurement config     ue_id=22   log=3

    send A2                        ue_id=22   meas_id=11  srsrp_nr=30      log=2
    display measurement config     ue_id=22   log=4

    send B2                        ue_id=22   meas_id=20
    sleep     10s

    UE PDU Session Release         ue_id=22   pdu=1
    UE Deregister                  ue_id=22
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_2.pcap
    Stop Btslog and save trace   part=UE22

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    run keyword and continue on failure    check syslog file A_B2_ALT5
    verify counter CB012121-A B2-Alt5

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
    Update wts file for CB012121-A-B2
    Load wts file    ${resultBaseDir}/basic_wts_CB012121-A-B2-Alt5.cfg
    Update SCF B2-Alt5
