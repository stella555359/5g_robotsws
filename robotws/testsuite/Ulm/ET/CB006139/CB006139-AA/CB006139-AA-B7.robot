*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-AA
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Yasir Mehmood
...             Manual Tester: Yasir Mehmood
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

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB006139-AA-B7
Suite Teardown    Suite Teardown CB006139

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${port_trace}                         49151
${ip_trace}                           10.0.1.1


*** Test Cases ***

CB006139_AA_ET_TC06_B7_SCell_removed_from_SCell_Failed_to_Setup_List_after_SCell_Release

    [Documentation]    This test case verifies CB006139_AA_ET_TC06_B7_SCell_removed_from_SCell_Failed_to_Setup_List_after_SCell_Release
    ...       :Autor: Yasir Mehmood
    [Tags]   t1
    [Setup]   Perform Preconditions of Test Scenario CB006139

    CB006139-keywords.Start Netcat For Tracing

    CB006139-commissioning.Update SCF AA B7
    CB006139-commissioning.Activate SCF And Bring Tl onAir     CB006139-AA_B7_SCF_Start

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    CB006139-keywords-egate.csi_override_testmode_aa_b7
    CB006139-keywords-egate.set trf_type for pdu    ue_id=1   pdu_id=1

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval        additional-waiting-time=30s

    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1

    CB006139-keywords-egate.Start Dl Traffic trf_id1_2   run=id1_2
    Sleep   5s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput pusch And pdsch   ue_id=1   run=1
    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/oneShot_SCell_addition


    CB006139-commissioning.Set nrcell_6 MaxNumOfSCellAlloc To 250
    CB006139-keywords-egate.Stop Dl Traffic trf_id2
    CB006139-keywords-egate.Start Dl Traffic trf_id   id=1   mbps=50   run=2
    Sleep   10s   reason=wait for stable traffic

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp
    CB006139-keywords-egate.Testmode Activate Profile aa_t6  ue_id=1  scell_id=3  profile_id=2  check=sCellToReleaseList   run=1
    Sleep   10s   reason=wait for sCell release complete
    CB006139-keywords-egate.Testmode Activate Profile No Check aa_t6   ue_id=1   scell_id=3   profile_id=1
    Sleep   5s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput pusch And pdsch   ue_id=1   run=2
    CB006139-keywords-egate.Start Dl Traffic trf_id   id=1   mbps=175   run=3
    CB006139-keywords-egate.Start Dl Traffic trf_id2_3_4_5_6 t6
    Sleep   5s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput pusch And pdsch   ue_id=1   run=3
    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/SCell3_Rel_and_UeContextModFail

    CB006139-keywords-egate.Stop Dl Traffic
    CB006139-keywords-egate.Start Dl Traffic trf_id   id=1   mbps=50   run=4
    Sleep   10s   reason=wait for stable traffic

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp
    CB006139-keywords-egate.Testmode Activate Profile aa_t6  ue_id=1  scell_id=2  profile_id=2  check=sCellToReleaseList   run=1
    Sleep   10s   reason=wait for sCell release complete
    CB006139-keywords-egate.Testmode Activate Profile no check aa_t6   ue_id=1   scell_id=2   profile_id=1
    Sleep   5s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput pusch And pdsch   ue_id=1   run=4
    CB006139-keywords-egate.start Dl Traffic trf_id   id=1   mbps=175   run=5
    CB006139-keywords-egate.Start Dl Traffic trf_id2_3_4_5_6 t6
    Sleep   10s   reason=wait for stable traffic

    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval        additional-waiting-time=30s

    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/SCell2_Rel_PC55_BC5_Select
    CB006139-keywords-egate.Release Pdu Session And Deregister                  ue_id=1


    Run Keyword And Continue On Failure     CB006139-keywords.Stop Netact For Tracing

    Run Keyword And Continue On Failure     CB006139-counter.Verify Counter AA B7
    Run Keyword And Continue On Failure     CB006139-keywords-wireshark.Verify Wireshark CB006139 t6
    Run Keyword And Continue On Failure     CB006139-keywords-egate-verify.Verify Egate Logs t6

    [Teardown]   CB006139-keywords.Perform Postconditions Of Test Scenario CB006139




*** Keywords ***
Suite Setup CB006139-AA-B7
    [Documentation]    [PRIVATE]    Prepare TL CB006139-AA
    ...       :Autor: Yasir Mehmood
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From gNB
    gnb.Store Current Swconfig From gNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    CB006139-keywords-wts.Update Wts File For CB006139-AA-B7 t6
