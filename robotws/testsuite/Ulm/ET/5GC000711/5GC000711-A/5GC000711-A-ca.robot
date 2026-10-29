*** Settings ***
Force Tags    5GC000711  5GC000711-A
...           STATE_CONFIGURED
...           CLOUD_5G_I_LO_AP_LO
...           VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AZQJ_GMC
...           RAN_5G    RAN_5G_TDD
...           SBTS00


Documentation   This is a Robot Test Suite for subfeature 5GC000711-A-ca
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        5GC000711-A-commissioning.robot
Resource        5GC000711-A-commissioning-ca.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        5GC000711-A-wts.robot
Resource        5GC000711-A-parameter-settings-ca.robot
Resource        5GC000711-A-verify-wireshark.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot

Suite Setup       Suite Setup 711A ca
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

5GC000711_A_Blind_SCell_addition_after_handover_from_LTE
    [Documentation]    This test scenario verifies the gNB behaviour for an incoming Handover from LTE connected to EPC with
    ...                blind SCells addition after handover completion
    ...       :Autor: Sylvia Schneider
    [Tags]   t16   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t16
    tc specific update and activate SCF CA and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session    ue_id=1
    start UDP traffic
    get bearer statistics   after_pdu_setup
    trigger handover to LTE              ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1a.pcap

    start wireshark trace
    trigger handover to 5G               ue_id=1    check=SCellIndex 1 activated successfully at airphone
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1b.pcap

    record traffic with wireshark
    reset bearer statistics
    get bearer statistics   after_handover_5G

    start wireshark trace
    register UE and start PDU session    ue_id=2
    trigger handover to LTE              ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2a.pcap

    start wireshark trace
    trigger handover to 5G               ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2b.pcap

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t16
    verify egate log handover 5G        ue_id=1
    verify traffic statistics
    verify wireshark traffic

    get resources taken after_test
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


5GC000711_A_Measurement_based_SCell_addition_after_handover_from_LTE
    [Documentation]    This test scenario verifies the gNB behaviour for an incoming Handover from LTE connected to EPC with establishment of
    ...                CA measurements (A1 based) after handover completion and S-Cell addition triggered by A1 measurements
    ...       :Autor: Sylvia Schneider
    [Tags]   t17   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731

    prepare counters and expected values t17
    tc specific update and activate SCF CA and bring tl onAir

    get resources taken before_test

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session    ue_id=1
    start UDP traffic
    get bearer statistics   after_pdu_setup
    trigger handover to LTE              A2_meas_id=1   B2_meas_id=4
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    trigger handover to 5G
    send A1 for Scell addition
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_part2.pcap

    record traffic with wireshark
    reset bearer statistics
    get bearer statistics   after_handover_5G

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    release UE

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark t17
    verify traffic statistics
    verify wireshark traffic

    get resources taken after_test
    no check of resource nbOfFreeCRNTI
    no check of resource postTimerWheel
    verify resource usage

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


*** Keywords ***
Suite Setup 711A ca
    [Documentation]    [PRIVATE]    Prepare TL 711A for 5GC000711-A-ca
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
    update iphy file ca
    Update wts file for TC 711A
    Update wts file for TC 711A ca
    Update SCF CA common part


update iphy file ca
    [Documentation]    [PRIVATE]    update iphy file ca
    ...       :Autor: Sylvia Schneider

    log to console    update iphy file
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>

    ${upd0}    Replace String Using Regexp    ${all_parts}[0]         GSCN>.*<\/GSCN>   GSCN>7880<\/GSCN>

    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>

    ${new contents}      catenate         SEPARATOR=</RE>   ${upd0}                    ${upd1}
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}

