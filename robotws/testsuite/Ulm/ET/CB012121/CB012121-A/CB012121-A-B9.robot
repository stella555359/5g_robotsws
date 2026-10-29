*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB012121-common/CB012121-keywords.robot

Resource        CB012121-A-GMC-commissioning.robot
Resource        CB012121-A-B9-keywords-egate.robot
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

CB012121_A_B9_after_feature_deactivation_best_cell_wait_timer_running
    [Documentation]    This test case verifies the gNB behavior A_B9_after_feature_deactivation_best_cell_wait_timer_running
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir     SCFC_CB012121_B9

    start wireshark trace
    open http session for delta commissioning

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    Start Btslog

    register 2 UEs
    setup PDU sessions for 2 UEs
    display measurement config for 2 UEs

    trigger meas reconfig for intra-freq inter-freq and interRat

    send A3 to start measurementReportPrioritizationTimer for INTER-FREQ HO
    set actMeasurementStrategy to disabled
    send A3 for 2 UEs A_B9

    release PDU session 2 UEs
    deregister 2 UEs

    Stop Btslog and save trace   part=UE1_UE2

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    close http session for delta commissioning
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_1.pcap

    run keyword and continue on failure    check syslog file A_B9
    verify counter CB012121-A B9

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
    Update wts file for CB012121-A-B2-Alt4
    Load wts file    ${resultBaseDir}/basic_wts_CB012121-A-B2-Alt4.cfg
    Update SCF B9
    update iphy cell-2 GSCN
    update sw config to extend bestCellWaitTimer to 70secs


update sw config to extend bestCellWaitTimer to 70secs
    [Documentation]    [PRIVATE]    update sw config to extend bestCellWaitTimer to 70secs
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update flags for extending bestCellWaitTimer to 70secs
    Log To Console    0x890075=70000
    @{list_add_flags}   create list
    ...       0x890075=70000
    Update SW Config file on System Module   param_list=@{list_add_flags}
