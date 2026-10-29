*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-DA-B3
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
...             Manual Tester: Bernhard Kukla
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB006139-common/CB006139-keywords.robot
Resource        ../CB006139-common/CB006139-commissioning.robot
Resource        ../CB006139-common/CB006139-counter.robot
Resource        ../CB006139-common/CB006139-keywords-egate.robot
Resource        ../CB006139-common/CB006139-parameter-settings.robot
Resource        ../CB006139-common/CB006139-keywords-wireshark.robot
Resource        ../CB006139-common/CB006139-keywords-wts.robot
Resource        ../CB006139-common/CB006139-keywords-egate-verify.robot
Resource        ../CB006139-common/CB006139-DA-keywords-egate-verify.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB006139-DA
Suite Teardown    Suite Teardown CB006139

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${port_trace}                         49151
${ip_trace}                           10.0.1.1

*** Test Cases ***

CB006139_DA_ET_TC03_B3_StepWise_SCell_Addition_with_CSI_RS_downgrade_in_existing_SCell
    [Documentation]    This test case verifies StepWise_SCell_Addition_with_CSI_RS_downgrade_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB006139

    remove egate console logs

    Start Netcat for tracing

    Update SCF DA B3
    Update wts file for DA B3
    activate SCF and bring tl onAir     CB006139-DA_B3

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    csi_override_testmode
    set trf_type for pdu    ue_id=1   pdu_id=1
    set trf_type for pdu    ue_id=2   pdu_id=1

    ue_change_location      ue_id=1
    ue_change_location      ue_id=2

    Log To Console    \nwaiting for new measurement period to start
    wait for next measurement interval

    start wireshark trace
    register UE             ue_id=1
    start PDU session       ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE1.pcap

    start dl traffic trf_id1_2   run=UE1   ue_id=1
    get ue NR throughput pdsch   ue_id=1   run=1
    get ue NR throughput pusch   ue_id=1   run=1

    start wireshark trace
    register UE             ue_id=2
    start PDU session       ue_id=2
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE2.pcap

    start dl traffic trf_id1_2   run=UE2   ue_id=2
    start ul traffic trf_id1     ue_id=2   mbps=15   run=1
    get ue NR throughput pdsch   ue_id=2   run=1
    get ue NR throughput pusch   ue_id=2   run=1

    release pdu session and deregister                  ue_id=1
    stop all DL traffic UE2 no check

    start TCE trace eth3 sctp tcp

    testmode activate profile  ue_id=2   profile_id=2  scell=2   check=sCellToReleaseList   run=1
    get ue NR throughput pdsch   ue_id=2   run=2
    get ue NR throughput pusch   ue_id=2   run=2

    start dl traffic for 8 trf_ids
    delay   seconds=10   reason=wait for stable traffic
    get ue NR throughput pdsch   ue_id=2   run=3
    get ue NR throughput pusch   ue_id=2   run=3

    stop TCE trace eth3 sctp tcp    save_dir=${resultDir}/TCE

    release pdu session and deregister                  ue_id=2

    Log To Console    \nwaiting for measurement period to stop
    wait for next measurement interval

    save egate logs    save_dir=${resultDir}/egate

    Run Keyword And Continue On Failure     Stop Netact for tracing

    Run Keyword And Continue On Failure    verify wireshark CB006139 DA_B3
    Run Keyword And Continue On Failure    verify egate logs DA_B3
    Run Keyword And Continue On Failure    Verify Counter DA B3

    [Teardown]   Perform Postconditions of Test Scenario CB006139





*** Keywords ***
Suite Setup CB006139-DA
    [Documentation]    [PRIVATE]    Prepare TL CB006139-AA
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
