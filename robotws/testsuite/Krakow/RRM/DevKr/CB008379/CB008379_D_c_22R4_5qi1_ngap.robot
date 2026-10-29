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
...         CB008379-D_c
...
...      == AUTHORS ==
...       - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...       - Cezary Dudek <cezary.dudek@nokia.com>
...       - Marek Kieltyka <marek.kieltyka@nokia.com>
...       - Karolina Sroczyk <karolina.sroczyk@nokia.com>
...       - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
...       - Grzegorz Szymik <grzegorz.szymik@nokia.com>
...       - Michal Szymakowski <michal.szymakowski@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...
...      == MAINTAINER ==
...       - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
...
...      == REFERENCES ==
...         CB008379 CFAM
...
...      == HISTORY ==
...         [27.05.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup
...     Run Setup

*** Variables ***
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim_inter_freq.lua
${yaml_enable_interho}=     ${CURDIR}/../resources/yaml_config/inter_gnb_ho.yaml
${yaml_enable_ngho}=        ${CURDIR}/../resources/yaml_config/NG_handover.yaml

*** Test Cases ***
CB008379-D-c Successful inter-gNB inter-freq A3 or A5 based handover with GBR bearer Xn and NGAP CRT 5QI1 only
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful inter-frequency inter-gNB XN and NG handover with traffic verification
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...	 - NRCELL-1 simulated on AEQA radio module - NR_BAND: n78
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with one SA cell OnAir
    ...  - simulated gNB3 is up and running with one cell
    ...  - MRBTS-1/NRBTS-1/NRADJGNB-0 is configured for adjacent gNB3
    ...  - MRBTS-1/NRBTS-1/NRADJNRCELL-1 is configured for adjacent gNB3 Cell1
    ...  - Neighbour gNB3 has Ng connection to the AMF that the UE1 is connected to
    ...  - gNB2 Cell1 has NRCELL/NRREL object, which indicates relation to gNB2 neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrpAndRsrq'
    ...  - MRBTS/NRBTS/NRCELL/a5MeasEnabled is set to 'rsrpAndRsrq'
    ...  - NRBTS/actInterFreqHoSA is set to 'true'
    ...  - GBR Service for SA feature is enabled NRBTS/NRCELL.actNonVoNRGBRService
    ...  - NRBTS/NRCELL.actCDrx = disabled
    ...  - RLC mode = RLC AM
    ...  - PDCP SN size = 18 bit
    ...
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ASIL + ABIO) with simulated AEQA radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...    REQUIREMENTS IN SCOPE:  5G_RAN_CP_12360506; 5G_CP_MM_2997
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCB008379-D1#B4: Successful Intra-frequency Inter-gNB handover with GBR bearers
    ...			- 5GC000706-B#B6 Successful Inter-frequency Inter-gNB handover based on A3/A5 measurements - 5G_RAN_USR_RRM_1483
    ...			- 5GC000705-A#EC10 Inter-gNB NG based Handover based on A3/A5 measurements without indirect DL data forwarding - 5G_RAN_USR_RRM_14577
    ...
    ...  == HISTORY ==
    ...     [25.05.2022]  - Created TC

    [Tags]  DC
    [Setup]     Prepare test environment DC_CRT

    Log to console      Change handover to NG based
    Configure       ${yaml_enable_ngho}
    Set NG based handover for simulated gNB3
    Set indirect data forwarding for AMF1 to on
    Configure  {'MOC': 'NRCELL', 'ID': '1', 'actVonr': 'true', 'actNonVoNRGBRService': 'false'}

    Log to console      6/9 - NG HO 5QI3
    Repeat Successful intra-frequency inter-gnb NG handover from simulated gNB3 to gNB2 with 5QI1 for UE6
    Fail


    [Teardown]   Cleanup after test DC

*** Keywords ***
Prepare test environment DC_CRT
    Configure       ${yaml_enable_interho}
    Set GBR data forwarding for XN Handover to on for simulated gNB3
    Set actNonVoNRGBRService flag to True

Cleanup after test DC
    Detach and kill UEs from 1 to 9
