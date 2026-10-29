*** Settings ***

Documentation   This is a Robot Test Suite for feature CB013024 TC1
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Anja Becher
...           Needed Tags:
...           STATE_CONFIGURED
...           CLOUD_5G_I_MP_AP_LOOO
...           SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...           RAN_5G    RAN_5G_TDD
...           TOOLS_PROFILE_WO_TTI
...           SBTS00
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB013024-commissioning.robot
Resource        CB013024-parameter-settings-TC1.robot
Resource        CB013024-keywords.robot
Resource        CB013024-keywords-egate.robot
Resource        CB013024-keywords-egate-verify.robot
Resource        CB013024-counter-TC1.robot

Resource        ../resources/SQD60/keywords-tracing.robot
Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/tshark.robot
Resource        ../../resources/Common/wts_ue.robot
Resource        ../resources/SQD60/keywords-tracing.robot

Suite Setup       Suite Setup CB013024
Suite Teardown    Suite Teardown CB013024

*** Variables ***
${LOGS_COLLECTED}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB013024_A_ET_TC1_interBand_2CC_BCS0_CA_n25A_n41A
    [Documentation]    CB013024_A_ET_TC1_interBand_2CC_BCS0_CA_n25A_n41A
    ...       :Author: Anja Becher
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB013024

    Configure Additional IP Addresses On WTS Host
    activate SCF and bring tl onAir TC1
    Check Wts In Active State

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    Start Wireshark Trace
    Register UE  ue_id=8
    Setup PDU Session  ue_id=8

    Start Traffic TC1  run=dl   ue_id=8
    sleep   10s   reason=wait for stable traffic
    Get UE NR Throughput Pusch And Pdsch   ue_id=8
    sleep   3s   reason=wait to stop traffic

    Stop Traffic  ue_id=8
    Release Pdu Session And Deregister                  ue_id=8
    Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_t1.pcap

    Run Keyword And Warn On Failure         dcap tracing stop
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    Run Keyword And Continue On Failure         Verify Egate Logs TC1
    Run Keyword And Continue On Failure         Verify Counter CB013024 TC1

    [Teardown]   Perform Postconditions Of Test Scenario CB013024


*** Keywords ***

Suite Setup CB013024
    [Documentation]    [PRIVATE]    Prepare TL for CB013024
    ...       :Autor: Shruthi Shivaprasad
    Create Test Suite Folders
    Get test variables and upload start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF from gNB
    gnb.Store Current swconfig from gNB
    Store Current swconfig from Airphone
    Store Current WTS Config
