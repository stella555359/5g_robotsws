*** Settings ***

Documentation   This is a Robot Test Suite for subfeature CB012121-A-B13
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
...             Manual Tester: Satoshi Machii
#-------------------------------------------------------------------------------------------------------------
Resource        ../../5GC000480/keywordbook-480.robot
Resource        ../CB012121-common/CB012121-keywords.robot
Resource        CB012121-A-B13-commissioning.robot
Resource        CB012121-A-B13-keywords-egate.robot
Resource        CB012121-A-B13-wts.robot
Resource        CB012121-A-B13-counter.robot

Resource        ../../../resources/Common/commissioning.robot
Resource        ../../../resources/Common/btslog.robot
Resource        ../../../resources/Common/wts_ue.robot
Resource        ../../resources/SQD60/keywords-tracing.robot



Suite Setup       Suite Setup CB012121-A
Suite Teardown    CB012121-keywords.Suite Teardown CB012121

*** Variables ***
${logs_collected}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB012121_A_B13_ALT1_ANR_not_triggered_due_to_unknown_PCI_second_PCI_is_used
    [Documentation]    This test case verifies that ANR is not triggered due to unknown PCI second PCI is used
    ...       :Autor: Sylvia Schneider
    [Tags]   t1
    [Setup]   CB012121-keywords.Perform Preconditions of Test Scenario CB012121

    CB012121-A-B13-commissioning.Activate SCF And Bring Tl onAir

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    keywordbook-480.Wait For Next Measurement Interval

    CB012121-keywords.Start Wireshark Trace

    CB012121-A-B13-keywords-egate.register UE
    CB012121-A-B13-keywords-egate.Start PDU Session

    Sleep  2s   Wait before A2
    CB012121-A-B13-keywords-egate.Send A2
    CB012121-A-B13-keywords-egate.Send 3times A3

    CB012121-keywords.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark.pcap

    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    CB012121-A-B13-keywords-egate.Release Pdu Session And Deregister

    CB012121-A-B13-counter.Verify Counter CB012121-A-B13

    [Teardown]   CB012121-keywords.Perform Postconditions Of Test Scenario CB012121 Dcap



*** Keywords ***
Suite Setup CB012121-A
    [Documentation]    [PRIVATE]    Prepare TL 711A for CB012121-A
    ...       :Autor: Sylvia Schneider
    CB012121-A-B13-wts.Create Ips For Simulated gnb
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get test variables and upload start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    get version mcc mnc from gNB SCF    ${current_SCF_gnb}
    gnb.Store Current swconfig from gNB
    wts_ue.Store Current swconfig from Airphone
    wts_ue.Store Current WTS Config
    CB012121-A-B13-wts.Update Wts File For CB012121-A-B13
    CB012121-A-B13-wts.Load Wts File    ${resultBaseDir}/basic_wts_CB012121-A-B13.cfg
    CB012121-A-B13-commissioning.Update SCF A-B13
    Update Iphy Cell-2 GSCN


Update Iphy Cell-2 GSCN
    [Documentation]    [PRIVATE]    update iphy cell-2 GSCN
    ...       :Autor: Sylvia Schneider

    Log To Console    update iphy file
    ${ACU_alias}    connect.Connect To Airphone Common Unit
    ssh.Execute    cp /ffs/run/simmode/new_iphy.xml /ffs/run/simmode/new_iphy_orig.xml    connection=${ACU_alias}
    ssh.Download File    /rom/simmode/new_iphy.xml    ${resultBaseDir}/new_iphy.xml    connection=${ACU_alias}

    ${contents}    Get File    ${resultBaseDir}/new_iphy.xml
    ${all_parts}    Split String      ${contents}     </RE>
    ${upd1}    Replace String Using Regexp    ${all_parts}[1]         GSCN>.*<\/GSCN>   GSCN>8008<\/GSCN>
    ${new contents}      Catenate         SEPARATOR=</RE>   ${all_parts}[0]            ${upd1}
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[2]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[3]
    ${new contents}      Catenate         SEPARATOR=</RE>   ${new contents}            ${all_parts}[4]
    Create File    ${resultBaseDir}/new_iphy_upd.xml    ${new contents}
    ssh.Upload File       ${resultBaseDir}/new_iphy_upd.xml    /rom/simmode/new_iphy.xml   connection=${ACU_alias}
