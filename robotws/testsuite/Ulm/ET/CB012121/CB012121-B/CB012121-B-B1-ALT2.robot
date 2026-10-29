*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B1-Alt2
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

CB012121_B_B1_ALT2_Priority_of_frequency_not_relevant_when_ony_one_frequency_is_configured_in the_UE
    [Documentation]    This test case verifies that priority of frequency is not relevant when only one frequency is configured in the UE.

    ...       :Autor: Yasir Mehmood
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=B1-Alt2

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

    Send A3 With 2 Phycell Ids And Check  ue_id=1  meas_id=5  pci1=49  nrsrp_nr1=85  nrsrq_nr1=80  pci2=51  nrsrp_nr2=65
    ...  nrsrq_nr2=60  log=1  check=Inter-eNB handover from EXT_ENB-2.1 to ENB-3.2 performed

    release pdu session and deregister   ue_id=1
    Stop Btslog and save trace   part=UE1

    Log to console   \nwaiting for measurement period to stop
    wait for next measurement interval

    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    Collect and Filter last PM Counters file coam
    run keyword and continue on failure    check syslog file B_B1_Alt2
    verify counter CB012121-B-B1-Alt2

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
    Update SCF B-B1-Alt2
    update iphy cell-2 GSCN
