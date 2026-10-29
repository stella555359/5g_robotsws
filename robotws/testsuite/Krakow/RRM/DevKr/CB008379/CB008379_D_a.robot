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

Force Tags    CONFIGURED    CRT    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup     Run Setup

*** Variables ***
${SKIP_COUNTERS}=           ${FALSE}
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${yaml_enable_intraho}=     ${CURDIR}/../resources/yaml_config/intra_gnb_ho.yaml

*** Test Cases ***
CB008379-D-a_TDD Successful Intra-frequency Intra-gNB handover with GBR bearers
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform successful intra-frequency intra-gNB handover with traffic
    ...     verification for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIB
    ...	 - NRCELL-1 simulated on AHLOA radio module - NR_BAND: n71
    ...	 - NRCELL-2 simulated on AHLOA radio module - NR_BAND: n71
    ...  - NRCELL-1 and NRCELL-2 have the same frequencies
    ...  - UE - Airphone simulator
    ...  - gNB2 up and running with two SA cell OnAir
    ...  - Both cell1 and cell2 have NRCELL/NRREL object, which indicates relation to neighbor cell
    ...  - MRBTS/NRBTS/NRCELL/a3MeasEnabled is set to 'rsrp' for all cells
    ...  - NRBTS/actIntraFreqHoSA is set to 'true'
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
    ...  - 5G_CP_IF_NTW_1188; 5G_RAN_CP_12360506; 5G_CP_MM_2997; CB_FIM_4086
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
    ...
    ...  == HISTORY ==
    ...     [07.02.2022]  - Created TC

    [Tags]  DA1
    [Setup]     Prepare test environment DA1

    Omit when SKIP_COUNTERS present
    ...         start collecting counters

    Log to console      1/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE1 and 5QI2
    # successfull HO is not counted as drb release nor setup
    #    NRPMQAP-2/3/4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    #    NRPMQAP-5:     AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 1, QFI_SETUP_SUCC 1, QFI_REL 1, QFI_REL_NORMAL 0
    Log to console      2/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE2 and 5QI3
    Log to console      3/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE3 and 5QI4
    Log to console      4/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE4 and 5QI71
    Log to console      5/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE5 and 5QI72
    Log to console      6/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE6 and 5QI76
    Log to console      7/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE7 and 5QI128
    Log to console      8/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE8 and 5QI212
    Log to console      9/9
    Run Keyword And Continue On Failure
    ...     Repeat Successful intra-gNB inter-cell intra-frequency XN Handover with GBR for UE9 and 5QI254

    Omit when SKIP_COUNTERS present
    ...  Wait until aggreagted PM counters file is ready and saved
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-1: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-2: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-3: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-4: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 3, QFI_SETUP_SUCC 3, QFI_REL 3, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-5: AVE_NUMBER_OF_SA_RRC >0, QFI_SETUP_ATT 9, QFI_SETUP_SUCC 9, QFI_REL 9, QFI_REL_NORMAL 0
    Omit when SKIP_COUNTERS present
    ...  Run Keyword And Continue On Failure
    ...  Check counters NRPMQAP-6: AVE_NUMBER_OF_SA_RRC 0, QFI_SETUP_ATT 0, QFI_SETUP_SUCC 0, QFI_REL 0, QFI_REL_NORMAL 0


*** Keywords ***
Prepare test environment DA1
    Configure       ${yaml_enable_intraho}
    Set actNonVoNRGBRService parameter for both cells
