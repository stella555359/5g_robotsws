*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB006139-DA-B12
...             Team: 'MN RAN RD VRF ULM 2'
...             Author: Sylvia Schneider
...             Manual Tester: Wolfgang Greiner
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

CB006139_DA_ET_TC09_B12_StepWise_SCell_Addition_DL_UL_SCell_with_UL_Tx_Switching_Option_1
    [Documentation]    This test case verifies StepWise_SCell_Addition_DL_UL_SCell_with_UL_Tx_Switching_Option_1
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   Perform Preconditions Of Test Scenario CB006139

    CB006139-keywords-egate.Remove Egate Console Logs

    CB006139-keywords.Start Netcat For Tracing

    CB006139-commissioning.Update SCF DA B12
    CB006139-commissioning.Activate SCF And Bring Tl onAir     CB006139-DA_B12

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start


    CB006139-keywords-egate.Set trf_type For Pdu    ue_id=1   pdu_id=1

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval  additional-waiting-time=30s
    Save Date For Egate Log 1st

    CB006139-keywords-wireshark.Start Wireshark Trace
    CB006139-keywords-egate.Register UE             ue_id=1
    CB006139-keywords-egate.Start PDU Session       ue_id=1
    CB006139-keywords-wireshark.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_reg_pdu.pcap

    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=1
    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=2
    CB006139-keywords-egate.Start UL Traffic trf_id1    ue_id=1   mbps=15   run=1
    CB006139-keywords-egate.Delay   seconds=10   reason=wait for stable traffic
    CB006139-keywords-egate.Get UE NR Throughput PDSCH   ue_id=1   run=1
    CB006139-keywords-egate.Get UE NR Throughput PUSCH   ue_id=1   run=1

    CB006139-commissioning.Set NRCELL_5 maxNumOfSCellAlloc To 20

    CB006139-keywords-egate.Lower Dl Traffic For Several trf_ids   ue_id=1   num_of_trfIds=2   mbps=30   run=1
    CB006139-keywords-wireshark.Start TCE Trace eth3 sctp tcp
    CB006139-keywords-egate.csi_override_testmode     ri=3
    CB006139-keywords-egate.Testmode Activate Profile With Extended Timeout
    ...   ue_id=1   scell=3   profile_id=2  check=sCellToReleaseList  timeout=65  run=1

    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=3
    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=4
    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=5
    CB006139-keywords-egate.Start Upd Dl Traffic    trf_id=6
    CB006139-keywords-egate.Start UL Traffic trf_id1    ue_id=1   mbps=60   run=2

    CB006139-keywords-egate.Delay   seconds=60   reason=increase counter value M55118C00053
    CB006139-keywords-egate.Get UE NR Throughput PDSCH   ue_id=1   run=2
    CB006139-keywords-egate.Get UE NR Throughput PUSCH   ue_id=1   run=2
    CB006139-keywords-egate.Release Pdu Session And Deregister        ue_id=1

    CB006139-keywords-wireshark.Stop TCE Trace eth3 sctp tcp    save_dir=${resultDir}/TCE

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    CB006139-keywords-egate.Save Egate Logs    save_dir=${resultDir}/egate


    Run Keyword And Continue On Failure     CB006139-keywords.Stop Netact For Tracing

    Run Keyword And Continue On Failure     CB006139-DA-keywords-egate-verify.Verify Egate Logs DA B12
    Run Keyword And Continue On Failure     CB006139-counter.Verify Counter DA B12
    Run Keyword And Continue On Failure     CB006139-counter.Verify Counter M55118C00053
    Run Keyword And Continue On Failure     CB006139-keywords-wireshark.Verify Wireshark CB006139 DA_B12

    [Teardown]   Perform Postconditions Of Test Scenario CB006139




*** Keywords ***
Suite Setup CB006139-DA
    [Documentation]    [PRIVATE]    Prepare TL CB006139-DA
    ...       :Autor: Sylvia Schneider
    Create Test Suite Folders
    Get Test Variables And Upload Start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
    Update Wts File For DA B12
    Update Sw Config To Enable CP RT Debug Log And PCMD Records Bundling


Update Sw Config To Enable CP RT Debug Log And PCMD Records Bundling
    [Documentation]    [PRIVATE]    update sw config to enable CP RT debug log and PCMD records bundling
    ...       :Autor: Sylvia Schneider
    Log To Console    \n\n/ffs/run/swconfig.txt on gNB update sw config:
    Log To Console    \n---enable CP RT debug log 0x590072=1
    Log To Console    \n---enable PCMD records bundling 0xA40000=0
    @{list_add_flags}   Create List
    ...       0x590072=1
    ...       0xA40000=0
    Update SW Config file On System Module   param_list=@{list_add_flags}
