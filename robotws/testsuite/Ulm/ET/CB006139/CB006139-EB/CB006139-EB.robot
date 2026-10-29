*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-EB
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
...             Manual Tester: Bernhard Kukla
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB006139-common/CB006139-keywords.robot
Resource        CB006139-EB-commissioning.robot
Resource        ../CB006139-common/CB006139-counter.robot
Resource        ../CB006139-common/CB006139-keywords-egate.robot
Resource        ../CB006139-common/CB006139-parameter-settings.robot
Resource        ../CB006139-common/CB006139-keywords-wireshark.robot
Resource        ../CB006139-common/CB006139-keywords-wts.robot
Resource        ../CB006139-common/CB006139-keywords-egate-verify.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/snapshot.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/wts_ue.robot

Resource        ../../resources/SQD60/keywords-tracing.robot


Suite Setup       Suite Setup CB006139-EB
Suite Teardown    Suite Teardown CB006139-EB


*** Test Cases ***



CB006139_EB_ET_TC12_InterGnb_SCell_Addition_CsiRs_Downgrade_MIMO_Robustness_Test
    [Documentation]    This test case verifies InterGnb_SCell_Addition_CsiRs_Downgrade_MIMO_Robustness_Test
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions Of Test Scenario CB006139

    Remove Egate Console Logs

    CB006139-EB-commissioning.Set NRBTS-2 NRCELL-7 maxNumOfSCellAlloc To 1
    CB006139-EB-commissioning.Bring NRBTS-1 And NRBTS-2 To OnAir


    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.DCAP Tracing Start


    CB006139-keywords-egate.csi_override_testmode
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1
    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=2   pdu_id=1

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s
    CB006139-counter.Save Date For Egate Log 1st

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=2
    CB006139-keywords-egate.Start PDU Session       ue_id=2
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE2.pcap

    CB006139-keywords-egate.Start DL Traffic To Activate Scell 1 And 2 And 3
    CB006139-keywords-egate.Start UL Traffic trf_id1    ue_id=2   mbps=10    run=1
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch    ue_id=2   run=1

    CB006139-keywords-egate.Stop All DL Traffic UE2 No Check

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Testmode Activate Profile With Extended Timeout
    ...         ue_id=2   scell=3   profile_id=2  check=sCellToReleaseList  timeout=20  run=1
    CB006139-keywords-egate.Testmode Activate Profile No Check    ue_id=2   scell=3  profile_id=1
    CB006139-keywords-egate.Testmode Activate Profile With Extended Timeout
    ...         ue_id=2   scell=1   profile_id=2  check=sCellToReleaseList  timeout=20  run=2
    CB006139-keywords-egate.Testmode Activate Profile No Check    ue_id=2   scell=1  profile_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_testmode_UE2.pcap

    CB006139-keywords-egate.Delay   seconds=60   reason=wait

    CB006139-keywords-egate.Start DL Traffic For CSI-RS Downgrade
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch    ue_id=2   run=2

    CB006139-keywords-egate.Stop All DL Traffic UE2 No Check

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s
    CB006139-counter.Save Date For Egate Log 2nd

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE1.pcap

    CB006139-keywords-egate.Start DL Traffic To Activate Scell With MIMO Reconfiguration   run=3
    CB006139-keywords-egate.Start UL Traffic trf_id1    ue_id=1   mbps=10    run=2

    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pdsch And Pusch    ue_id=1   run=3
    CB006139-keywords-egate.Stop Traffic And Release Pdu And Deregister UE2

    CB006139-keywords-egate.Stop All DL Traffic UE1 No Check

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Testmode Activate Profile With Extended Timeout
    ...         ue_id=1   scell=2   profile_id=2  check=sCellToReleaseList  timeout=60  run=3
    CB006139-keywords-egate.Testmode Activate Profile No Check    ue_id=1   scell=2  profile_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_testmode_UE1.pcap
    CB006139-keywords-egate.Start DL Traffic To Activate Scell With MIMO Reconfiguration   run=4

    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch    ue_id=1   run=4

    CB006139-keywords-egate.Stop Traffic And Release Pdu And Deregister UE1

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    CB006139-keywords-egate.Save Egate Logs    save_dir=${resultDir}/egate

    CB006139-counter.Collect PM Counter Of 2 GNBs
    Run Keyword And Continue On Failure    CB006139-counter.Verify EB Counter
    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs EB Throughput

    Run Keyword And Continue On Failure    CB006139-keywords-egate-verify.Verify Egate Logs EB

    [Teardown]   Perform Postconditions Of Test Scenario CB006139-EB





*** Keywords ***
Suite Setup CB006139-EB
    [Documentation]    [PRIVATE]    Prepare TL CB006139-EB
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create Test Suite Folders
    ${allGlobalVariables} =    Get Variables
    ${gnb_sw_version_1st}   testline.Fetch Current GNB SW Version    gnb_id=0
    Log To Console   sw version 1st GNB with gnb_id 0: ${gnb_sw_version_1st}
    ${gnb_sw_version_2nd}   Fetch Current GNB SW Version    gnb_id=1
    Log To Console   sw version 2nd GNB with gnb_id 1: ${gnb_sw_version_2nd}
    gnb.Get SCF From GNB With COAM      gnbScfName=SCFC_start_1st.xml   resultConfigDir=${resultBaseDir}   gnb_id=0
    gnb.Get SCF From GNB With COAM      gnbScfName=SCFC_start_2nd.xml   resultConfigDir=${resultBaseDir}   gnb_id=1
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos


Suite Teardown CB006139-EB
    [Documentation]    [PRIVATE]    Suite Teardown CB006139-EB
    ...       :Autor: Sylvia Schneider
    IF    '${PREV_TEST STATUS}'=='PASS'    RETURN
    Log To Console   collect snapshot of primary gNB
    snapshot.Collect Snapshot From GNB    target_dir=${resultBaseDir}   gnb_id=0
    Log To Console   collect snapshot of external gNB
    snapshot.Collect Snapshot From GNB    target_dir=${resultBaseDir}   gnb_id=1
    Log To Console   collect sosreport
    wts_ue.Collect Sos Report Logs      target_dir=${resultBaseDir}
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon


Perform Postconditions Of Test Scenario CB006139-EB
    [Documentation]    [PRIVATE]    postconditions for CB006139-EB
    ...       :Autor: Sylvia Schneider
    reporting.Set SCOUT TC ID For Reporting
    CB006139-keywords-wireshark.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    keywords-tracing.Dcap Tracing Stop
    keywords-tracing.End DCAP Tracing And Collect Traces
