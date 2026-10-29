*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-CG
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
...             Manual Tester: Bernhard Kukla
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot

Resource        ../CB006139-common/CB006139-keywords.robot
Resource        CB006139-CG-commissioning.robot
Resource        CB006139-CG-keywords-egate-verify.robot
Resource        ../CB006139-common/CB006139-counter.robot
Resource        ../CB006139-common/CB006139-keywords-egate.robot
Resource        ../CB006139-common/CB006139-parameter-settings.robot
Resource        ../CB006139-common/CB006139-keywords-wireshark.robot
Resource        ../CB006139-common/CB006139-keywords-wts.robot
Resource        ../CB006139-common/CB006139-keywords-egate-verify.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/snapshot.robot
Resource        ../../../resources/Common/tcpdump.robot
Resource        ../../../resources/Common/tshark.robot
Resource        ../../../resources/Common/wts_ue.robot

Resource        ../../resources/SQD60/keywords-tracing.robot


Suite Setup       Suite Setup CB006139-CG
Suite Teardown    Suite Teardown CB006139-CG


*** Variables ***
${XN_TRACE_RUNNING}                     False


*** Test Cases ***


CB006139_CG_ET_TC10_InterGnb_Measurement_Based_Stepwise_SCell_Addition_Robustness_Test
    [Documentation]    This test case verifies InterGnb_Measurement_Based_Stepwise_SCell_Addition_Robustness_Test
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   CB006139-keywords.Perform Preconditions Of Test Scenario CB006139

    CB006139-keywords-egate.Remove Egate Console Logs

    CB006139-CG-commissioning.Update SCF CG Prime gNB
    Run Keyword And Warn On Failure          Start Wireshark On Xn Interface
    CB006139-CG-commissioning.Bring NRBTS-1 And NRBTS-2 To onAir

    Run Keyword And Warn On Failure         Prepare For DCAP Tracing
    Run Keyword And Warn On Failure         DCAP Tracing Start


    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu_UE1.pcap

    Add PCI56 And PCI57 Via A1 Report
    Add PCI55 Via A4 Report
    Release PCI 57 Via A2 Report
    Add PCI54 Via A4 Report

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s

    Release PCI 54 Via A2 Report
    Add Again PCI54 Via A4 Report

    Reduce DL Traffic
    Handover To PCI 54 Via A4 Report


    CB006139-keywords-egate.Stop Traffic And Release Pdu And Deregister UE1

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    Run Keyword And Warn On Failure         Stop Wireshark On Xn Interface
    CB006139-keywords-egate.Save Egate Logs    save_dir=${resultDir}/egate

    Run Keyword And Continue On Failure    CB006139-counter.Verify Counter CB006139 CG
    Run Keyword And Continue On Failure    CB006139-CG-keywords-egate-verify.Verify Egate Logs CG

    [Teardown]   Perform Postconditions Of Test Scenario CB006139-CG





*** Keywords ***
Suite Setup CB006139-CG
    [Documentation]    [PRIVATE]    Prepare TL CB006139-CG
    ...       :Autor: Sylvia Schneider
    keywordbook-480.Create Test Suite Folders
    ${allGlobalVariables} =    Get Variables
    ${gnb_sw_version_1st}    testline.Fetch Current GNB SW Version    gnb_id=0
    Log To Console   sw version 1st GNB with gnb_id 0: ${gnb_sw_version_1st}
    ${gnb_sw_version_2nd}    testline.Fetch Current GNB SW Version    gnb_id=1
    Log To Console   sw version 2nd GNB with gnb_id 1: ${gnb_sw_version_2nd}
    gnb.Get SCF From GNB With COAM          gnbScfName=SCFC_start_1st.xml   resultConfigDir=${resultBaseDir}   gnb_id=0
    gnb.Get SCF From GNB With COAM          gnbScfName=SCFC_start_2nd.xml   resultConfigDir=${resultBaseDir}   gnb_id=1
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos


Suite Teardown CB006139-CG
    [Documentation]    [PRIVATE]    Suite Teardown CB006139-CG
    ...       :Autor: Sylvia Schneider
    IF    '${PREV_TEST STATUS}'=='PASS'    RETURN
    Log To Console   collect snapshot of primary gNB
    snapshot.Collect Snapshot From GNB    target_dir=${resultBaseDir}   gnb_id=0
    Log To Console   collect snapshot of external gNB
    snapshot.Collect Snapshot From GNB    target_dir=${resultBaseDir}   gnb_id=1
    Log To Console   collect sosreport
    wts_ue.Collect SOS Report Logs      target_dir=${resultBaseDir}
    wts_ue.Teardown Egate Connection For Airphone
    wts_ue.Teardown Edaemon Connection For Airphone    edaemon_alias=edaemon


Perform Postconditions Of Test Scenario CB006139-CG
    [Documentation]    [PRIVATE]    postconditions for CB006139-CG
    ...       :Autor: Sylvia Schneider
    Set SCOUT TC ID For Reporting
    CB006139-keywords-wireshark.Stop Wireshark Trace     wireshark_store=${resultDir}/wireshark_test_teardown.pcap
    Stop Wireshark On Xn Interface Error Case
    DCAP Tracing Stop
    End DCAP Tracing And Collect Traces


Add PCI56 And PCI57 Via A1 Report
    [Documentation]    [PRIVATE]    Add PCI56 And PCI57 Via A1 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Delay   10    wait before A1 start
    CB006139-keywords-egate.Display Measurements    run=1
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=3 event=A1 srsrp_nr=100
    ${check}  Set Variable   rrcReconfigurationComplete
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A1_add_56_57.txt    ${output_egate}
    Log To Console  send A1 saved in egate_event_A1_add_56_57.txt

    CB006139-keywords-egate.Delay   10    wait after A1 start

    CB006139-keywords-egate.Start Dl Traffic For Several trf_ids   ue_id=1   num_of_trfIds=5   mbps=175   run=1
    CB006139-keywords-egate.Start Ul Traffic trf_id1               ue_id=1                     mbps=20    run=1
    CB006139-keywords-egate.Delay   5    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=1


Add PCI55 Via A4 Report
    [Documentation]    [PRIVATE]    Add PCI55 Via A4 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Delay   62    wait for A4 active
    CB006139-keywords-egate.Display Measurements    run=2
    ${A4_meas_id}   CB006139-keywords-egate.Get Measurement Id    meas_file_id=2   ObjectId=3   ReportCfgId=4
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=${A4_meas_id} event=A4 srsrp_nr=100 phycell_id=55 nrsrp_nr=50
    ${check}  Set Variable   PhysCellId:55. SCellIndex 3 activated successfully at airphone
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A4_add_55.txt    ${output_egate}
    Log To Console  send A4 saved in egate_event_A4_add_55.txt
    CB006139-keywords-egate.Delay   5    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=2


Release PCI 57 Via A2 Report
    [Documentation]    [PRIVATE]    Release PCI 57 Via A2 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Display Measurements    run=3
    ${A2_meas_id}   CB006139-keywords-egate.Get Measurement Id    meas_file_id=3   ObjectId=5   ReportCfgId=6
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=${A2_meas_id} event=A2 srsrp_nr=20 scell=2
    ${check}  Set Variable   sCellToReleaseList
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A2_release_57.txt    ${output_egate}
    Log To Console  send A2 saved in egate_event_A2_release_57.txt


Add PCI54 Via A4 Report
    [Documentation]    [PRIVATE]    Add PCI54 Via A4 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Delay   58    wait for A4 active
    CB006139-keywords-egate.Display Measurements    run=4
    ${A4_meas_id}   CB006139-keywords-egate.Get Measurement Id    meas_file_id=4   ObjectId=2   ReportCfgId=4
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=${A4_meas_id} event=A4 srsrp_nr=100 phycell_id=54 nrsrp_nr=40
    ${check}  Set Variable   PhysCellId:54. SCellIndex 2 activated successfully at airphone
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A4_add_54.txt    ${output_egate}
    Log To Console  send A4 saved in egate_event_A4_add_54.txt
    CB006139-keywords-egate.Delay   5    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=3


Release PCI 54 Via A2 Report
    [Documentation]    [PRIVATE]    Release PCI 54 Via A2 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Delay   60    wait for max A4 retries end
    CB006139-keywords-egate.Display Measurements    run=5
    ${A2_meas_id}   CB006139-keywords-egate.Get Measurement Id    meas_file_id=5   ObjectId=2   ReportCfgId=6
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=${A2_meas_id} event=A2 srsrp_nr=20 scell=2
    ${check}  Set Variable   sCellToReleaseList
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A2_release_54.txt    ${output_egate}
    Log To Console  send A2 saved in egate_event_A2_release_54.txt


Add Again PCI54 Via A4 Report
    [Documentation]    [PRIVATE]    Add Again PCI54 Via A4 Report
    ...       :Autor: Sylvia Schneider
    FOR   ${loop}    ${wait_sec}    IN
    ...   1          30
    ...   2          10
    ...   3          10
    ...   4          10
       CB006139-keywords-egate.Delay   ${wait_sec}    wait ${wait_sec} for A4 active
       CB006139-keywords-egate.Display Measurements    run=6
       ${A4_meas_id}   CB006139-keywords-egate.Get Measurement Id    meas_file_id=6  ObjectId=2   ReportCfgId=9
       ${meas_id_found}   Run Keyword and Return Status    Should Not Be Empty    ${A4_meas_id}
       IF    '${meas_id_found}' == 'True'    BREAK
    END
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=${A4_meas_id} event=A4 srsrp_nr=100 phycell_id=54 nrsrp_nr=40
    ${check}  Set Variable   PhysCellId:54. SCellIndex 2 activated successfully at airphone
    Log To Console    execute on wts: ${cmd}
    Log To Console    check: ${check}
    ${output_egate}  ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    OperatingSystem.Create File    ${resultDir}/egate_event_A4_add_54.txt    ${output_egate}
    Log To Console  send A4 saved in egate_event_A4_add_54.txt
    CB006139-keywords-egate.Delay   5    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=4


Reduce DL Traffic
    [Documentation]    [PRIVATE]    Reduce DL Traffic
    ...       :Autor: Sylvia Schneider
    Stop Dl Traffic
    Start Dl Traffic trf_id_1
    CB006139-keywords-egate.Delay   5    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=5


Handover To PCI 54 Via A4 Report
    [Documentation]    [PRIVATE]    Handover To PCI 54 Via A4 Report
    ...       :Autor: Sylvia Schneider
    CB006139-keywords-egate.Delay   50    wait for A4 active
    ${cmd}    Set Variable   ue_measurement_send_nr id=1 meas_id=3 event=A4 srsrp_nr=100 phycell_id=54 nrsrp_nr=50
    ${check}  Set Variable   Inter-eNB handover from EXT_ENB-2.4 to EXT_ENB-3.5 performed
    Log To Console    execute on wts: ${cmd}
    Log To Console    check on wts: "${check}"
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${cmd}
    ...    return_output=True
    ...    pass_regexp=${check}
    ...    alias=ap_egate
    Sleep     2s   wait for all data sent
    OperatingSystem.Create File    ${resultDir}/egate_handover_54_A4.txt    ${output_egate}

    CB006139-keywords-egate.Display Cell Info
    CB006139-keywords-egate.Delay   10    wait for stable traffic
    CB006139-keywords-egate.Get Ue NR Separate Throughput Pusch And Pdsch   ue_id=1   run=6


Start Wireshark On Xn Interface
    [Documentation]    [PRIVATE]    Start Wireshark On Xn Interface
    ...       :Autor: Sylvia Schneider
    CB006139-CG-commissioning.Get vlanId From VLANIF For BR Interface
    CB006139-keywords.Check All Radio Units Online
    Log To Console    \nstart XN trace on gnb interface br0.${vlanId} for sctp messages

    ${COLLECTOR_XN_WS}    tcpdump.Start TCPDump On GNB Common Unit    options=-i br0.${vlanId} sctp
    Set Test Variable     ${COLLECTOR_XN_WS}
    Set Test Variable     ${XN_TRACE_RUNNING}    True


Stop Wireshark On Xn Interface
    [Documentation]    [PRIVATE]    Stop Wireshark On Xn Interface
    ...       :Autor: Sylvia Schneider
    Log To Console    \nstop XN trace on gnb interface br0.${vlanId} for sctp messages and save in ${resultDir}/Xn_tcpdump.pcap
    tcpdump.Stop TCPDump On GNB Common Unit
    ...   collector=${COLLECTOR_XN_WS}
    ...   target_dir=${resultDir}
    ...   tcpdump_filename=Xn_tcpdump.pcap
    Set Test Variable     ${XN_TRACE_RUNNING}    False


Stop Wireshark On Xn Interface Error Case
    [Documentation]    [PRIVATE]    Stop Wireshark On Xn Interface Error Case
    ...       :Autor: Sylvia Schneider
    IF    '${XN_TRACE_RUNNING}' == 'False'   RETURN
    Log To Console    \nstop XN trace on gnb interface br0.${vlanId} for sctp messages and save in ${resultBaseDir}/Xn_tcpdump_errorCase.pcap
    tcpdump.Stop TCPDump On GNB Common Unit
    ...   collector=${COLLECTOR_XN_WS}
    ...   target_dir=${resultBaseDir}
    ...   tcpdump_filename=Xn_tcpdump_errorCase.pcap
