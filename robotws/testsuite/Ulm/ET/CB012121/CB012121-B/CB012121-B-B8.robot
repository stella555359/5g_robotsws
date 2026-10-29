*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B8
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
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

CB012121_B_B8_ALT1_gNB_receives_new_priority_from_OAM
    [Documentation]    This test case verifies that gNB receives new priority from OAM

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=common

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace
    open http session for delta commissioning
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE                  ue_id=1
    start PDU session            ue_id=1
    display measurement config   ue_id=1    log=1
    send A2                      ue_id=1
    display measurement config   ue_id=1    log=2

    set a3a5Priority to 60 for NRCELL-1 NRHOIF-3

    send A3  ue_id=1   phycell_id=55   nrsrp_nr=75   nrsrq_nr=70   meas_id=7   log=1
    send A3 with 2 phycell ids and check   ue_id=1  meas_id=5  pci1=51  nrsrp_nr1=65  nrsrq_nr1=60  pci2=49  nrsrp_nr2=85
    ...   nrsrq_nr2=80  log=1  check=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed

    release pdu session and deregister    ue_id=1
    Stop Btslog and save trace   part=UE1

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    close http session for delta commissioning
    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    run keyword and continue on failure    check syslog file B_B8
    verify counter CB012121-B-B8

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
    Update SCF B-common
    update iphy cell-2 GSCN
