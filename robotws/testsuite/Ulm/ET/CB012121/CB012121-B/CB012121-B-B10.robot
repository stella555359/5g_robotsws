*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B10
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Yasir Mehmood
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

CB012121_B_B10_feature_de_activated_while_priority_timer_is_running
    [Documentation]    This test case verifies that feature_de_activated_while_priority_timer_is_running

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB012121

    activate SCF and bring tl onAir   scenario=B10

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start
    start wireshark trace
    open http session for delta commissioning
    Start Btslog

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    register UE and start PDU and send A2       ue_id=1
    send 2 times A3 with phycell_id 51 and 49   ue_id=1

    set actMeasurementStrategy to disabled

    send B2 and A3 with check                   ue_id=1
    release pdu session and deregister          ue_id=1
    Stop Btslog and save trace                  part=UE1

    set actMeasurementStrategy to priority

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval
    Start Btslog

    register UE and start PDU and send A2       ue_id=2
    send 2 times A3 with phycell_id 51 and 49   ue_id=2

    set actMeasurementStrategy to cellQuality

    send B2 and A3 with check                   ue_id=2
    release pdu session and deregister          ue_id=2
    Stop Btslog and save trace                 part=UE2

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    close http session for delta commissioning
    stop wireshark trace    wireshark_store=${resultDir}/wireshark.pcap
    Run Keyword And Warn On Failure         dcap tracing stop

    run keyword and continue on failure    check syslog file B_B10
    verify counter CB012121-B-B10

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
    update sw config to extend bestCellWaitTimer to 70secs


update sw config to extend bestCellWaitTimer to 70secs
    [Documentation]    [PRIVATE]    update sw config to extend bestCellWaitTimer to 70secs
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update flags for extending bestCellWaitTimer to 70secs
    Log To Console    0x890075=70000
    @{list_add_flags}   create list
    ...       0x890075=70000
    Update SW Config file on System Module   param_list=@{list_add_flags}
