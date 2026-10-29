*** Settings ***
Documentation
...      == COPYRIGHT ==
...         Nokia Networks
...
...      == INTRODUCTION ==
...         CB008379: GBR Services for SA
...
...      == TEST SET NAME ==
...         CB008379
...
...      == TESTING SPLIT==
...            CB008379-G-d
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Tomasz Pyrek <michal.szymakowski@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [19.04.2022] - Create Test Suite

Force Tags    SKIPRUN
    ...    CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
    ...    CONFIGS_Krakow/CB008379/CB008379_G_d_bbool.yml

*** Variables ***
${lua}=  ${CURDIR}/config/SA_TDD_2c_FDD_2c_1eNBsim.lua

*** Test Cases ***
CB008379-G-d Admission control with 5GC002426
    [Tags]    MANUAL
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...  Purpose of this  test is to verify interaction with 5GC002426. After exceeding maximum number of configured GBR
    ...  in the pool, next attempts to setup new GBR should be rejected.
    ...  On gNB there are 2 bbpools configured with cells 3 and 4.
    ...  Parameter maxNumOfGBRL2Pool in vendor file must be changed to '5'.
    ...  This will limit pools size for test purposes.
    ...  This test will not be added to CRT.
    ...  Test scenario:
    ...      Attach and Setup initial PDU session for UEs 1-5 for NRCEL-3
    ...      Modify pdu session with addition of new QoS flow with 5QI-2 for UEs 1-5
    ...      Attach and Setup initial PDU session for UEs 11-15 for NRCEL-4
    ...      Modify pdu session with addition of new QoS flow with 5QI-2 for UEs 11-15
    ...      Attach and Setup initial PDU session for UE-6 for NRCEL-4
    ...      Try modify pdu session with addition of new QoS flow with 5QI-2 for UE-6
    ...      Verify that modification of QoS flow for UE-6 was rejected
    ...      Detach UE-15
    ...      Try modify pdu session with addition of new QoS flow with 5QI-2 for UE-6
    ...      Verify that modification of QoS flow for UE-6 was successful
    ...      Detach all UEs
    ...  To verify properly all GBRs introduced by this feature test scenario needs to be executed also with setup of
    ...  the following QoS Flows - [2, 4, 71, 128]
    ...  == Precondition: ==
    ...  - gNB2 is configured with 5QI-2, 4, 71, 128
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - NRCELL-3.actNonVoNRGbrService = true
    ...  - NRCELL-3.actGBRAdmissionControl = GBRService
    ...  - NRCELL-4.actNonVoNRGbrService = true
    ...  - NRCELL-4.actGBRAdmissionControl = GBRService
    ...  - maxNumOfGBRL2Pool = 5 (parameter in vendor file)
    ...  == TESTING TOOLS ==
    ...  - AirPhone, 5GCSIM, UTE
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIB) with 2 simulated AHFII radio module - NR_BAND: n66
    ...  == REQUIREMENTS COVERAGE ==
    ...  CB_FIM_4239
    ...  == REQUIRED LOGS ==
    ...  NGAP, NR-RRC
    ...  == CONTACTS ==
    ...  Maciej Madej <maciej.madej@nokia.com>
    ...  == REFERENCES ==
    ...  CB008379 CFAM
    ...  == HISTORY ==
    ...  [19.04.2022] - Create Test Case

    No operation
