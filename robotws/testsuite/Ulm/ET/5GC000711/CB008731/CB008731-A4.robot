*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB008731 A4
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------
Library         DateTime

Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../../5GC000480/keywordbook-480-resourceUsage.robot
Resource        ../common_711A_8731/keywords.robot
Resource        ../common_711A_8731/keywords-wts.robot
Resource        ../common_711A_8731/keywords-traffic.robot
Resource        ../common_711A_8731/keywords-wireshark.robot
Resource        ../common_711A_8731/verify-counter.robot
Resource        ../common_711A_8731/parameter-definitions.robot
Resource        CB008731-commissioning-A4.robot
Resource        CB008731-verify-counter.robot
Resource        CB008731-verify-wireshark.robot
Resource        CB008731-keywords-traffic.robot
Resource        CB008731-wts.robot
Resource        CB008731-parameter-settings-A4.robot
Resource        CB008731-parameter-definitions.robot

Resource        ../../resources/SQD60/keywords-tracing.robot
Resource        ../../../resources/Common/commissioning.robot


Suite Setup       Suite Setup CB008731
Suite Teardown    Suite Teardown 711A 8731

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***


CB008731_A1_based_traffic_steering_to_preferred_NR_layer_after_IRAT_HO_from_LTE
    [Documentation]    This test case verifies the A1_based_traffic_steering
    ...       :Autor: Sylvia Schneider
    [Tags]    t6   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for TC CB008731 t6
    Update SCF t6
    start wireshark trace
    activate SCF and bring tl onAir t6
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t6

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and prepare traffic and start PDU session
    start UDP traffic t6 and get bearer statistics
    trigger handover to LTE              A2_meas_id=1   B2_meas_id=6
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    Log To Console    \nwaiting for next measurement period to start
    wait for next measurement interval
    Save Date For Egate Log 2ndPeriod

    start wireshark trace
    trigger handover to 5G
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    send A1
    send A4 with meas_id 6
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    start wireshark trace
    reset bearer statistics  ue_id=1
    keep traffic running
    get 8731 t6 bearer statistics   run=end
    stop UDP traffic
    release UE
    get time after release
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part4.pcap
    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify counter of last measurment period t6
    verify wireshark 8731 t6
    verify traffic statistics t6

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace


CB008731_Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    [Documentation]    This test case verifies the Periodic_A4_based_mobility_after_interRAT_HO_from_LTE
    ...       :Autor: Sylvia Schneider
    [Tags]    t7   CRT
    [Setup]   Perform Preconditions of Test Scenario 711A 8731
    Update wts file for TC CB008731 t6
    Update SCF t7
    start wireshark trace
    activate SCF and bring tl onAir t7
    stop wireshark trace for setup
    check wts in active state
    prepare counters and expected values t7

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE and start PDU session
    trigger handover to LTE              A2_meas_id=1   B2_meas_id=5
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part1.pcap

    start wireshark trace
    trigger handover to 5G
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part2.pcap

    start wireshark trace
    wait until A4 configured in UE
    send A4 with meas_id 5
    stop wireshark trace   wireshark_store=${resultDir}/wireshark_part3.pcap

    release UE

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Warn On Failure         dcap tracing stop

    collect pm file and verify counter values
    verify wireshark 8731 t7

    [Teardown]   Perform Postconditions of Test Scenario 711A 8731 trace



*** Keywords ***
Suite Setup CB008731
    [Documentation]    [PRIVATE]    Prepare TL for CB008731
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
    update A4 gscn in iphy file
    Update wts file for TC CB008731 common part
    Update SCF common part


get time after ${action}
    [Documentation]    [PRIVATE]    get time after handover, release
    ...       :Autor: Sylvia Schneider
    ${act_time}     DateTime.get current date
    Set Test Variable    ${time_${action}}    ${act_time}
    Log To Console    actual time was saved to parameter time_${action} "${time_${action}}"


keep traffic running
    [Documentation]    [PRIVATE]    keep traffic running
    ...       :Autor: Sylvia Schneider
    Sleep    60s   reason=keep traffic running


wait until A4 configured in UE
    [Documentation]    [PRIVATE]    wait until A4 configured in UE
    ...       :Autor: Sylvia Schneider
    Sleep    6s   reason=wait until A4 configured in UE


update A4 gscn in iphy file
    [Documentation]    [PRIVATE]    update gscn in iphy file
    ...       :Autor: Sylvia Schneider
    Log To Console    update /ffs/run/simmode/new_iphy.xml, cell2 GSCN to 7995
    ${ACU_alias}    Connect to Airphone Common Unit
    ssh.Execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}
    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd1}    Replace String Using Regexp          ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>7995<\/GSCN>

    ${new contents}      Catenate         SEPARATOR=</RE>   ${all_parts}[0]    ${upd1}
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[2]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[3]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}    ${all_parts}[4]

    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}
