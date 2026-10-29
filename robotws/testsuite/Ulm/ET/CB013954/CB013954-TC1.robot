*** Settings ***

Documentation   This is a Robot Test Suite for feature CB013954 TC1
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Anja Becher
...             Needed Tags:
...             STATE_CONFIGURED
...             CLOUD_5G_I_MP_AP_LOOO
...             PRIVATE_SANSA_CMWV_TDD_FDD_CA_5CCDL_2CCUL
...             UPGRADE_UTF    NEW_AUTOMATION
...             TOOLS_PROFILE_WO_TTI
...             SBTS00
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB013954-commissioning.robot
Resource        CB013954-parameter-settings.robot
Resource        CB013954-keywords.robot
Resource        CB013954-keywords-egate.robot
Resource        CB013954-keywords-egate-verify.robot
Resource        CB013954-counter.robot

Resource        ../resources/SQD60/keywords-tracing.robot
Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/tshark.robot
Resource        ../../resources/Common/wts_ue.robot


Suite Setup       Suite Setup CB013954
Suite Teardown    CB013954-keywords.Suite Teardown CB013954

*** Variables ***
${LOGS_COLLECTED}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB013954_A_SE_TC01_CA_n40A_n71A
    [Documentation]    CB013954_A_SE_TC01_CA_n40A_n71A
    ...       :Author: Anja Becher
    [Tags]    t1
    [Setup]   CB013954-keywords.Perform Preconditions Of Test Scenario CB013954

    CB013954-keywords.Configure Additional IP Addresses On WTS Host
    CB013954-commissioning.Activate SCF And Bring Tl OnAir TC1
    CB013954-keywords-egate.Check Wts In Active State

    Run Keyword And Warn On Failure         keywords-tracing.Prepare For Dcap Tracing
    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    CB013954-keywords.Start Wireshark Trace
    CB013954-keywords-egate.Register UE  ue_id=2
    CB013954-keywords-egate.Setup PDU Session  ue_id=2

    CB013954-keywords-egate.Start Traffic TC1  run=dl   ue_id=2
    Sleep   10s   reason=wait for stable traffic
    CB013954-keywords-egate.Get UE NR Throughput Pusch And Pdsch   ue_id=2
    Sleep   3s   reason=wait to stop traffic

    CB013954-keywords-egate.Stop Traffic  ue_id=2
    CB013954-keywords-egate.Release Pdu Session And Deregister    ue_id=2
    CB013954-keywords.Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_t1.pcap

    Run Keyword And Warn On Failure         keywords-tracing.Dcap Tracing Stop
    Log To Console    \nwaiting for measurement period to stop
    keywordbook-480.Wait For Next Measurement Interval

    Run Keyword And Continue On Failure     CB013954-keywords-egate-verify.Verify Egate Logs TC1
    Run Keyword And Continue On Failure     CB013954-counter.Verify Counter CB013954 TC1

    [Teardown]   CB013954-keywords.Perform Postconditions Of Test Scenario CB013954


*** Keywords ***

Suite Setup CB013954
    [Documentation]    [PRIVATE]    Prepare TL for CB013954
    ...       :Autor: Shruthi
    keywordbook-480.Create Test Suite Folders
    keywordbook-480.Get Test Variables And Upload Start SCF
    ute_workarounds.UTE Cloud Workaround
    testline.Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From GNB
    gnb.Store Current Swconfig From GNB
    wts_ue.Store Current Swconfig From Airphone
    wts_ue.Store Current WTS Config
