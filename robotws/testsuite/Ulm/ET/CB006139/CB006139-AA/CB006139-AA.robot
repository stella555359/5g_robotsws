*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-AA
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

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB006139-AA
Suite Teardown    Suite Teardown CB006139

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}
${port_trace}                         49151
${ip_trace}                           10.0.1.1

*** Test Cases ***



CB006139_AA_ET_TC02_B2_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_deactivation
    [Documentation]    This test case verifies Buffer_based_step_wise_NR_FR1_SCell_addition_feature_deactivation
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   CB006139-keywords.Perform Preconditions Of Test Scenario CB006139

    CB006139-keywords.Start Netcat For Tracing

    CB006139-commissioning.Update SCF AA t1
    CB006139-commissioning.Activate SCF And Bring Tl OnAir     CB006139-AA_t1

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    CB006139-keywords-egate.csi_override_testmode
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1

    Register And Start Traffic And Activate Buffer Monitoring And Deregister  monitoring=DL_buffer_monitoring_activated

    CB006139-commissioning.Set actBufferBasedSCellAddition To oneShot_Dl_Fr1
    CB006139-keywords-egate.Testmode Activate Profile No Check  ue_id=1   scell=1   profile_id=1

    Register And Start Traffic And Activate Buffer Monitoring And Deregister  monitoring=DL_buffer_monitoring_deactivated

    Run Keyword And Continue On Failure    CB006139-keywords.Stop Netact For Tracing

    Run Keyword And Continue On Failure    CB006139-keywords-wireshark.Verify Wireshark CB006139 t1
    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs t1

    [Teardown]   CB006139-keywords.Perform Postconditions Of Test Scenario CB006139



CB006139_AA_ET_TC01_B1_ALT1_Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    [Documentation]    This test case verifies Buffer_based_step_wise_NR_FR1_SCell_addition_feature_activation
    ...       :Autor: Sylvia Schneider
    [Tags]   t2
    [Setup]   CB006139-keywords.Perform Preconditions Of Test Scenario CB006139

    CB006139-keywords.Start Netcat For Tracing

    CB006139-commissioning.Update SCF AA t2
    CB006139-commissioning.Activate SCF And Bring Tl OnAir     CB006139-AA_t2

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    CB006139-keywords-egate.csi_override_testmode
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu.pcap

    CB006139-keywords-egate.Start Dl Traffic trf_id1_2   run=id1_2
    Sleep   10s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=1

    CB006139-commissioning.Set actBufferBasedSCellAddition To oneShot_stepWise_Dl_Fr1
    CB006139-keywords-egate.Stop Dl Traffic trf_id2

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp
    CB006139-keywords-egate.Testmode Activate Profile  ue_id=1   profile_id=2  scell=1   check=sCellToReleaseList   run=1
    Sleep   10s   reason=wait for sCell release complete
    CB006139-keywords-egate.Testmode Activate Profile No Check  ue_id=1   scell=1   profile_id=1
    Sleep   10s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=2
    Sleep   40s

    Log To Console    \nwaiting for next measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    CB006139-keywords-egate.Start Dl Traffic trf_id2_3_4_5
    Sleep   10s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=3

    CB006139-keywords-egate.Release Pdu Session And Deregister                  ue_id=1
    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/TCE

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    Run Keyword And Continue On Failure    CB006139-keywords.Stop Netact For Tracing

    Run Keyword And Continue On Failure    CB006139-counter.Verify Counter CB006139 t2
    Run Keyword And Continue On Failure    CB006139-keywords-wireshark.Verify Wireshark CB006139 t2
    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs t2

    [Teardown]   CB006139-keywords.Perform Postconditions Of Test Scenario CB006139



CB006139_AA_ET_TC14_B12_Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    [Documentation]    This test case verifies Step_wise_SCell_Addition_with_FS_2CC_UL_chosen_over_FS_1CC_UL
    ...       :Autor: Sylvia Schneider
    [Tags]   t3
    [Setup]   CB006139-keywords.Perform Preconditions Of Test Scenario CB006139

    CB006139-keywords-egate.Remove Egate Console Logs

    CB006139-keywords.Start Netcat For Tracing

    CB006139-commissioning.Update SCF AA t3
    CB006139-keywords-wts.Update Wts File For AA t3
    CB006139-commissioning.Activate SCF And Bring Tl OnAir     CB006139-AA_t3

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    CB006139-keywords-egate.csi_override_testmode
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=2   pdu_id=1

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s
    CB006139-counter.Save Date For Egate Log 1st

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE1.pcap

    CB006139-keywords-egate.Start Dl Traffic trf_id1_2   run=UE1_id1_2   ue_id=1
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=1

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=2
    CB006139-keywords-egate.Start PDU Session       ue_id=2
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE2.pcap

    CB006139-keywords-egate.Start Dl Traffic trf_id1_2   run=UE2_id1_2_run1   ue_id=2
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=2   run=1
    CB006139-keywords-egate.Stop All Traffic For UE No Check       ue_id=2
    CB006139-keywords-egate.Start Ul Traffic trf_id1     ue_id=2   mbps=50   run=1

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp

    CB006139-keywords-egate.Testmode Activate Profile  ue_id=2   profile_id=2  scell=1   check=sCellToReleaseList   run=1
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for sCell release complete
    CB006139-keywords-egate.Testmode Activate Profile No Check  ue_id=2   scell=1   profile_id=1
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=2   run=2

    CB006139-keywords-egate.Release Pdu Session And Deregister                  ue_id=1
    CB006139-keywords-egate.Delay   seconds=60   reason=wait

    CB006139-keywords-egate.Start Dl Traffic trf_id1_1_2_3_4_5_6 t3 run1
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pdsch   ue_id=2   run=3
    CB006139-keywords-egate.Get Ue NR Throughput Pusch   ue_id=2   run=3

    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/TCE_part1
    CB006139-keywords-egate.Delay   seconds=2  reason=wait for trace stop
    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp

    CB006139-keywords-egate.Stop All DL Traffic UE2
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for sCell release complete
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=2   run=4

    Log To Console    \nwaiting for next measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s
    CB006139-counter.Save Date For Egate Log 2nd

    CB006139-commissioning.Set fr1UlCaPreferred To ulCaPreferred

    Run Keyword And Continue On Failure    CB006139-keywords-egate.Start Dl Traffic trf_id1_1_2_3_4_5_6 t3 run2
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pdsch   ue_id=2   run=5
    CB006139-keywords-egate.Get Ue NR Throughput Pusch   ue_id=2   run=5

    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/TCE_part2
    CB006139-keywords-egate.Delay   seconds=30   reason=enlarge duration counter values
    CB006139-keywords-egate.Release Pdu Session And Deregister                  ue_id=2

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    CB006139-keywords-egate.Save Egate Logs    save_dir=${resultDir}/egate

    Run Keyword And Continue On Failure    CB006139-keywords.Stop Netact For Tracing

    Run Keyword And Continue On Failure    CB006139-counter.Verify Counter CB006139 t3
    Run Keyword And Continue On Failure    CB006139-keywords-wireshark.Verify Wireshark CB006139 t3
    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs t3
    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs t3 Throughput

    Run Keyword And Continue On Failure    CB006139-counter.Verify Duration Counter

    [Teardown]   CB006139-keywords.Perform Postconditions Of Test Scenario CB006139





*** Keywords ***
Suite Setup CB006139-AA
    [Documentation]    [PRIVATE]    Prepare TL CB006139-AA
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    gnb.Store Current SCF From GNB
    gnb.Store Current Swconfig From GNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config


Register And Start Traffic And Activate Buffer Monitoring And Deregister
    [Documentation]    [PRIVATE]    Register And Start Traffic And Activate Buffer Monitoring And Deregister
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${monitoring}
    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_${monitoring}.pcap

    CB006139-keywords-egate.Start Dl Traffic trf_id1_2   run=${monitoring}
    Sleep   10s   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=${monitoring}_1

    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp
    CB006139-keywords-egate.Testmode Activate Profile  ue_id=1   profile_id=2  scell=1   check=sCellToReleaseList   run=${monitoring}
    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/TCE_${monitoring}
    CB006139-keywords-egate.Get Ue NR Throughput Pusch And Pdsch   ue_id=1   run=${monitoring}_2

    CB006139-keywords-egate.Release Pdu Session And Deregister                  ue_id=1

