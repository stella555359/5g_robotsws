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
...            CB008379-D_a
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
...         [07.02.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_BO_AP_KL_SANSA_L1B_ECPRI_CMWV_TDD

Suite Setup     Run keywords
...     Run Setup
...     AND    Set actNonVoNRGBRService parameter for both cells

*** Variables ***
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim_inter_freq.lua
${yaml_enable_intraho}=     ${CURDIR}/../resources/yaml_config/intra_gnb_ho.yaml

*** Test Cases ***
CB008379-D-a_TDD Successful Inter-frequency Intra-gNB handover with GBR bearers
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful inter-frequency intra-gNB handover with traffic verification
    ...     for GBR bearers with 5QI: 71,72,76,128,212,255
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIB
    ...	 - NRCELL-1 simulated on AHLOA radio module - NR_BAND: n71
    ...	 - NRCELL-2 simulated on AHLOA radio module - NR_BAND: n71
    ...  - NRCELL-1 and NRCELL-2 have different frequencies
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for all cells
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
    ...  - HARDWARE ID:  gNB(ABIO + ASIB) with simulated AHLOA radio module - NR_BAND: n71
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_IF_NTW_1188; 5G_RAN_CP_12360506; 5G_CP_MM_2997; CB_FIM_4085
    ...
    ...  == REQUIRED LOGS ==
    ...    UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...     - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>
    ...
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...     - USCB008379-D1#B1: Successful Intra-frequency Intra-DU Intra-gNB handover with GBR bearers
    ...         - Alternate Scenario: User Scenario 5GC000706-B#B4: Successful Inter-frequency Intra-DU Intra-gNB handover
    ...           based on A3/A5 measurements - 5G_RAN_USR_RRM_1481
    ...
    ...  == HISTORY ==
    ...     [07.02.2022]  - Created TC

    [Tags]  DA2

    Prepare test environment DA2

    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE1 and 5QI71
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE2 and 5QI72
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE3 and 5QI76
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE4 and 5QI128
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE5 and 5QI212
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell inter-frequency XN Handover with GBR for UE6 and 5QI254

*** Keywords ***
Prepare test environment DA2
    Configure       ${yaml_enable_intraho}
    Set actNonVoNRGBRService parameter for both cells
