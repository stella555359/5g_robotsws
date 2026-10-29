*** Settings ***
Force Tags    CB013024
...           STATE_CONFIGURED
...           CLOUD_5G_I_MP_AP_LOOO
...           VARIANT_PRIVATE_SANSA_CMWV_2TDD_3FDD_CA_5CCDL_2CCUL_GMC
...           RAN_5G    RAN_5G_TDD
...           TOOLS_PROFILE_WO_TTI
...           SBTS00


Documentation   This is a Robot Test Suite for feature CB013024 TC4
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Shruthi Shivaprasad
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB013024-commissioning.robot
Resource        CB013024-parameter-settings.robot
Resource        CB013024-keywords.robot
Resource        CB013024-keywords-egate.robot
Resource        CB013024-keywords-egate-verify.robot
Resource        CB013024-counter.robot

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


CB013024_A_ET_TC4_interBand_5CC_BCS0_BCS1_CA_n1A_n3A-n28A_n78C
    [Documentation]    CB013024_A_ET_TC4_interBand_5CC_BCS0_BCS1_CA_n1A_n3A-n28A_n78C
    ...       :Author: Shruthi Shivaprasad
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB013024

    activate SCF and bring tl onAir t1
    Check Wts In Active State

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log to console    \nwaiting for new measurement period to start
    wait for next measurement interval

    Start Wireshark Trace
    Register UE             ue_id=1
    Setup PDU Session    ue_id=1

    Start Traffic   run=dl   ue_id=1
    sleep   10s   reason=wait for stable traffic
    Get UE NR Throughput Pusch And Pdsch   ue_id=1
    sleep   3s   reason=wait to stop traffic

    Stop Traffic    ue_id=1
    Release Pdu Session And Deregister                  ue_id=1
    Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_t1.pcap

    Run Keyword And Warn On Failure         dcap tracing stop
    Log to console    \nwaiting for measurement period to stop
    wait for next measurement interval

    run keyword and continue on failure         Verify Egate Logs T1
    run keyword and continue on failure         Verify Counter CB013024

    [Teardown]   Perform Postconditions of Test Scenario CB013024


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
