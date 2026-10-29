*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-B-B17
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Wolfgang Greiner
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../CB012121-common/CB012121-keywords.robot
Resource        CB012121-B-commissioning.robot
Resource        CB012121-B-keywords-egate.robot
Resource        CB012121-B-B17-keywords-pcmd.robot
Resource        CB012121-B-B17-verify-wireshark-pcmd.robot
Resource        CB012121-B-wts.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB012121-B-B17
Suite Teardown    CB012121-keywords.Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_B_B17_Measurement Prioritization_in_Coverage_based_Mobility_B2 measurment_reporting_in_PCMD_content
    [Documentation]    This test case verifies Measurement Prioritization_in_Coverage_based_Mobility_B2 measurment_reporting_in_PCMD_content

    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   CB012121-keywords.Perform Preconditions Of Test Scenario CB012121

    CB012121-B-B17-keywords-pcmd.Start Netcat For Tracing
    CB012121-B-commissioning.Activate SCF And Bring Tl onAir   scenario=B17

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    CB012121-keywords.Start Wireshark Trace
    CB012121-B-B17-keywords-pcmd.Start Pcmd Trace    collector=pcmd_trace_B17

    CB012121-B-keywords-egate.Register UE                  ue_id=1
    CB012121-B-keywords-egate.Start PDU Session            ue_id=1
    Sleep  2s   Wait before A2
    CB012121-B-keywords-egate.Send A2 With srs_result      ue_id=1
    CB012121-B-keywords-egate.Send B2                      ue_id=1
    Sleep  2s

    CB012121-B-B17-keywords-pcmd.Stop Pcmd Trace     collector=pcmd_trace_B17
    CB012121-keywords.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark.pcap

    wts_ue.UE Deregister                ue_id=1

    Run Keyword And Continue On Failure   CB012121-B-B17-keywords-pcmd.Stop Netact For Tracing

    CB012121-B-B17-verify-wireshark-pcmd.Verify Wireshark Pcmd CB012121-B-B17

    [Teardown]   CB012121-keywords.Perform Postconditions Of Test Scenario CB012121 Dcap



*** Keywords ***
Suite Setup CB012121-B-B17
    [Documentation]    [PRIVATE]    Prepare TL 711A for CB012121-B-B17
    ...       :Autor: Sylvia Schneider
    CB012121-B-wts.Create Ips For Simulated gnb
    CB012121-B-B17-keywords-pcmd.Create Ip For Pcmd
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From gNB
    CB012121-keywords.Get Version mcc mnc From gNB SCF    ${current_SCF_gnb}
    gnb.Store Current Swconfig From gNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
    CB012121-B-wts.Update Wts File For CB012121-B-B17
    CB012121-B-wts.Load Wts File    scenario=B17
    CB012121-B-commissioning.Update SCF B-B17
    CB012121-B-wts.Update Iphy Cell-2 GSCN
