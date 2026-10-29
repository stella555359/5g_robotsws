*** Settings ***

Documentation   This is a Robot Test Suite for feature CB013024 TMO
...             Team: 'MN RAN RD VRF ULM4'
...             Author: Anja Becher
...             Needed Tags:
...             STATE_CONFIGURED
...             CLOUD_5G_I_MP_AP_LOOO
...             SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_GMC
...             RAN_5G    RAN_5G_TDD
...             TOOLS_PROFILE_WO_TTI
...             SBTS00
#-------------------------------------------------------------------------------------------------------------
Resource        ../5GC000480/keywordbook-480.robot

Resource        CB013024-commissioning.robot
Resource        CB013024-parameter-settings-TC1.robot
Resource        CB013024-keywords.robot
Resource        CB013024-keywords-egate.robot
Resource        CB013024-keywords-egate-verify.robot
Resource        CB013024-counter-TC1.robot

Resource        ../resources/SQD60/keywords-tracing.robot
Resource        ../resources/SQD65/sqd65_keywords.robot
Resource        ../../resources/Common/commissioning.robot
Resource        ../../resources/Common/tshark.robot
Resource        ../../resources/Common/wts_ue.robot

Suite Setup       Suite Setup CB013024
Suite Teardown    Suite Teardown CB013024

*** Variables ***
${LOGS_COLLECTED}                     False
&{SCF}                                &{EMPTY}

*** Test Cases ***

CB013024_A_ET_TC1_interBand_2CC_BCS0_CA_n25A-n41A
    [Documentation]    CB013024_A_ET_TC1_interBand_2CC_BCS0_CA_n25A-n41A
    ...       :Author: Anja Becher
    [Tags]    t1
    [Setup]   Perform Preconditions of Test Scenario CB013024

    Activate SCF And Bring TL onAir TMO
    Check Wts In Active State

    Run Keyword And Warn On Failure         prepare for dcap tracing
    Run Keyword And Warn On Failure         dcap tracing start

    Log To Console    \nwaiting for new measurement period to start
    Wait For Next Measurement Interval

    Start Wireshark Trace
    Register UE  ue_id=8  nwslice=8
    Setup PDU Session  ue_id=8

    Start Traffic TMO  run=dl   ue_id=8
    Sleep   10s   reason=wait for stable traffic
    Get UE NR Throughput Pusch And Pdsch   ue_id=8
    Sleep   3s   reason=wait to stop traffic

    Stop Traffic  ue_id=8
    Release Pdu Session And Deregister                  ue_id=8
    Stop Wireshark Trace    wireshark_store=${resultDir}/wireshark_t1.pcap
    wts_ue.Save Current Egate Console Log    ${resultDir}

    Run Keyword And Warn On Failure         dcap tracing stop
    Log To Console    \nwaiting for measurement period to stop
    Wait For Next Measurement Interval

    Run Keyword And Continue On Failure         Verify Egate Logs TMO
    Run Keyword And Continue On Failure         Verify Counter CB013024 TMO

    [Teardown]   Perform Postconditions Of Test Scenario CB013024


*** Keywords ***

Suite Setup CB013024
    [Documentation]    [PRIVATE]    Prepare TL for CB013024
    ...       :Autor: Shruthi Shivaprasad
    Create Test Suite Folders
    Get Test Variables And Upload Start SCF
    UTE Cloud Workaround
    Check TL Infos
    ${current_SCF_gnb}   gnb.Store Current SCF From gNB
    gnb.Store Current Swconfig From gNB
    wts_ue.Store Current Swconfig From Airphone
    Store Current WTS Config
