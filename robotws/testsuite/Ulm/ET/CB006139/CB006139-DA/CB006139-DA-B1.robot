*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-DA-B1
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
...             Manual Tester: Ronald Danke
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

CB006139_DA_ET_TC01_B1_StepWise_SCell_Addition_with_DL_maximum_MIMO_layer_change_in_existing_SCell
    [Documentation]    This test case verifies SStepWise_SCell_Addition_with_DL_maximum_MIMO_layer_change_in_existing_SCell
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB006139

    prepare egate log and start netcat for TCE trace

    update SCF and bring TL onAir

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    set trf_type for pdu    ue_id=1   pdu_id=1
    open http session for commissioning

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval  additional-waiting-time=30s

    register UE and start PDU session

    CSI override setup for good and bad RLQ

    start TCE trace eth3 sctp tcp

    trigger SCellAddition with DL traffic

    start UL traffic and get throughput
    reduce traffic for 2 trf_ids and get throughput

    initiate gNB releases the SCell 2 due to bad RLQ
    set SCell 2 profile 1 and get throughput run3

    set NRCELL-4 and NRCELL-6 maxNumOfSCellAlloc to 0
    Increase the DL data transmission to trigger SCell Addition and get throughput

    reduce traffic for 8 trf_ids and get throughput
    initiate gNB releases 1st Scell of 2 SCells due to bad RLQ

    set SCell 2 profile 1 and get throughput run6

    initiate gNB releases 2nd Scell of 2 SCells due to bad RLQ
    set SCell 4 profile 1 and get throughput run7

    wait for F5 timer expiry and increase the DL data transmission to trigger SCell Addition

    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    stop all traffic and stop TCE trace and store egate log and deregister
    close http session for commissioning

    Run Keyword And Continue On Failure     Stop Netact for tracing

    Run Keyword And Continue On Failure     verify wireshark CB006139 DA_B1
    Run Keyword And Continue On Failure     verify egate logs DA B1
    Run Keyword And Continue On Failure     Verify Counter DA B1


    [Teardown]   Perform Postconditions of Test Scenario CB006139




*** Keywords ***
Suite Setup CB006139-DA
    [Documentation]    [PRIVATE]    Prepare TL CB006139-DA
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update wts file for DA B1


prepare egate log and start netcat for TCE trace
    [Documentation]    [PRIVATE]    prepare egate log and start netcat for TCE trace
    ...       :Autor: Sylvia Schneider
    remove egate console logs
    Start Netcat for tracing


update SCF and bring TL onAir
    [Documentation]    [PRIVATE]    update SCF and bring TL onAir
    ...       :Autor: Sylvia Schneider
    Update SCF DA B1
    activate SCF and bring tl onAir     CB006139-DA_B1


register UE and start PDU session
    [Documentation]    [PRIVATE]    register UE and start PDU session
    ...       :Autor: Sylvia Schneider
    start wireshark trace
    register UE             ue_id=1
    start PDU session       ue_id=1
    stop wireshark trace    wireshark_store=${resultDir}/wireshark_reg_pdu.pcap


CSI override setup for good and bad RLQ
    [Documentation]    [PRIVATE]    CSI override setup for good and bad RLQ
    ...       :Autor: Sylvia Schneider
    csi_override_testmode    profile_id=2  cqi=1    ri=3


trigger SCellAddition with DL traffic
    [Documentation]    [PRIVATE]    trigger SCellAddition with DL traffic
    ...       :Autor: Sylvia Schneider
    start dl traffic trf_id1_2  run=1


start UL traffic and get throughput
    [Documentation]    [PRIVATE]    start UL traffic and get throughput
    ...       :Autor: Sylvia Schneider
    start ul traffic trf_id1    ue_id=1   mbps=12    run=1
    delay   seconds=10   reason=wait for stable traffic
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=1


reduce traffic for 2 trf_ids and get throughput
    [Documentation]    [PRIVATE]    reduce traffic for 2 trf_ids and get throughput
    ...       :Autor: Sylvia Schneider
    lower dl traffic for several trf_ids   ue_id=1  num_of_trfIds=2  mbps=10  run=1
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=2


initiate gNB releases the SCell 2 due to bad RLQ
    [Documentation]    [PRIVATE]    initiate gNB releases the SCell 2 due to bad RLQ
    ...       :Autor: Sylvia Schneider
    testmode activate profile with extended timeout             ue_id=1   scell=2   profile_id=2  check=sCellToReleaseList   timeout=20  run=1


set SCell ${scell} profile 1 and get throughput run${run}
    [Documentation]    [PRIVATE]    set SCell profile 1 and get throughput
    ...       :Autor: Sylvia Schneider
    testmode activate profile no check    ue_id=1   scell=${scell}   profile_id=1
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=${run}


Increase the DL data transmission to trigger SCell Addition and get throughput
    [Documentation]    [PRIVATE]    Increase the DL data transmission to trigger SCell Addition and get throughput
    ...       :Autor: Sylvia Schneider
    start dl traffic for several trf_ids  ue_id=1  num_of_trfIds=8   mbps=175  run=_1
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=4


reduce traffic for 8 trf_ids and get throughput
    [Documentation]    [PRIVATE]    reduce traffic for 8 trf_ids and get throughput
    ...       :Autor: Sylvia Schneider
    lower dl traffic for several trf_ids   ue_id=1  num_of_trfIds=8  mbps=7  run=2
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=5


initiate gNB releases 1st Scell of 2 SCells due to bad RLQ
    [Documentation]    [PRIVATE]    initiate gNB releases 1st Scell of 2 SCells due to bad RLQ
    ...       :Autor: Sylvia Schneider
    testmode activate profile with extended timeout             ue_id=1   scell=2   profile_id=2  check=sCellToReleaseList   timeout=20  run=2


initiate gNB releases 2nd Scell of 2 SCells due to bad RLQ
    [Documentation]    [PRIVATE]    initiate gNB releases 2nd Scell of 2 SCells due to bad RLQ
    ...       :Autor: Sylvia Schneider
     testmode activate profile with extended timeout             ue_id=1   scell=4   profile_id=2  check=sCellToReleaseList   timeout=20  run=3


wait for F5 timer expiry and increase the DL data transmission to trigger SCell Addition
    [Documentation]    [PRIVATE]    wait for F5 timer expiry and increase the DL data transmission to trigger SCell Addition
    ...       :Autor: Sylvia Schneider
    delay   seconds=30   reason=wait for F5 timer expiry
    start dl traffic for several trf_ids  ue_id=1  num_of_trfIds=8   mbps=175   run=_2
    delay   seconds=10   reason=wait for SCell Addition
    get ue NR separate throughput pusch and pdsch   ue_id=1   run=8


stop all traffic and stop TCE trace and store egate log and deregister
    [Documentation]    [PRIVATE]    stop all traffic and stop TCE trace and store egate log and deregister
    ...       :Autor: Sylvia Schneider
    stop all traffic for UE no check       ue_id=1
    stop TCE trace eth3 sctp tcp    save_dir=${resultDir}/TCE
    save egate logs    save_dir=${resultDir}/egate
    Run Keyword And Continue On Failure     release pdu session and deregister        ue_id=1

