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

CB012121_A_B8_after_feature_deactivation_best_cell_wait_timer_not_running
    [Documentation]    This test case verifies the gNB behavior A_B8_after_feature_deactivation_best_cell_wait_timer_not_running
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir     SCFC_CB012121_common

    start wireshark trace
    open http session for delta commissioning
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE and setup PDU session and send A2 and disp measurements    ue_id=1
    send B2 and 3 times A3    ue_id=1   run=1   check=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed
    release pdu session and deregister    ue_id=1

    register UE and setup PDU session and send A2 and disp measurements    ue_id=2
    set actMeasurementStrategy to disabled
    send B2 and 1 time A3    ue_id=2   run=2   check=Inter-eNB handover from EXT_ENB-2.1 to ENB-5.1 performed
    release pdu session and deregister    ue_id=2

    set actMeasurementStrategy to cellQuality

    Log to console    \nwaiting for measurement period to start
    wait for next measurement interval

    Stop Btslog and save trace   part=UE1_UE2
    Start Btslog

    register UE and setup PDU session and send A2 and disp measurements    ue_id=3
    set actMeasurementStrategy to priority
    send B2 and 2 times A3 and delayed A3    ue_id=3   run=3   check=Inter-eNB handover from EXT_ENB-2.1 to ENB-5.2 performed
    release pdu session and deregister    ue_id=3
    Stop Btslog and save trace   part=UE3

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    close http session for delta commissioning
    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap

    run keyword and continue on failure    check syslog file A_B8
    verify counter CB012121-A B8

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
    Update SCF common
    update iphy cell-2 GSCN
    update sw config to extend bestCellWaitTimer to 60secs


update sw config to extend bestCellWaitTimer to 60secs
    [Documentation]    [PRIVATE]    update sw config to extend bestCellWaitTimer to 60secs
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update flags for extending bestCellWaitTimer to 60secs
    Log To Console    0x890075=60000
    @{list_add_flags}   create list
    ...       0x890075=60000
    Update SW Config file on System Module   param_list=@{list_add_flags}
