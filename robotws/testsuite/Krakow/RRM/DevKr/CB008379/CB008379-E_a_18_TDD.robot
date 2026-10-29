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
...            CB008379-E_a
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
...         [06.04.2022] - Create Test Suite

Resource    ./resources/CB008379-common_keywords.robot

Force Tags    CONFIGURED    PY36    RAN_5G    RAN_5G_TDD    SBTS00    SBTS23R4    SKIPRUN
    ...    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD

Suite Setup       Run Setup     admission_control=${True}
*** Variables ***
${LUA_CFG}=                 ${CURDIR}/config/SA_TDD_2c_1gNBSim.lua
${yaml_enable_intraho}=     ${CURDIR}/../resources/yaml_config/inter_gnb_intra_freq_ho.yaml

${wait_until_kw_succ_rep}           3x
${wait_until_kw_succ_time}          3s

*** Test Cases ***
CB008379-E-a_18_TDD GBR load reporting - incoming HO rejected by too high requested GFBR value and online GFBR param change
    [Documentation]
    ...  == DESCRIPTION ==
    ...  == Info==
    ...     The purpose of test is to perform unsuccessful intra-frequency inter-gNB handover with traffic verification
    ...     for GBR bearers with 5QI: 2,3,4,71,72,76,128,212,254 due to too high requested GFBR value.
    ...
    ...  == Precondition: ==
    ...  - gNB2 classical - real hardware - ABIO + ASIB
    ...	 - NRCELL-1 simulated on AHLOA radio module - NR_BAND: n78
    ...	 - NRCELL-2 simulated on AHLOA radio module - NR_BAND: n78
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
    ...  - NRCELL-1.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-1.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-1.maxGBRTrafficLimit = 90 %
    ...  - NRCELL-2.maxNumOfGBRBearersSA = 10
    ...  - NRCELL-2.actGBRAdmissionControl = 2 (GBRService)
    ...  - NRCELL-2.maxGBRTrafficLimit = 90 %
    ...  - NRDRB.maxDataRateGbrDl = 14 Mb/s
    ...  - NRDRB.maxDataRateGbrUl = 14 Mb/s
    ...  == TESTING TOOLS ==
    ...  - AirPhone, EPCSIM, UTE
    ...
    ...  == TEST ENVIRONMENT ==
    ...  - gNB classicBTS in SA mode
    ...  - HARDWARE ID:  gNB(ABIO + ASIL) with simulated AEQE radio module - NR_BAND: n78
    ...
    ...  == REQUIREMENTS COVERAGE ==
    ...  - 5G_CP_IF_NTW_4978
    ...
    ...  == REQUIRED LOGS ==
    ...  UU, NGAP, NRRRC, PCAP
    ...
    ...  == CONTACTS ==
    ...  - Gabriela Stasiuk <gabriela.stasiuk@nokia.com>
    ...  == REFERENCES ==
    ...  - Related CFAM US:
    ...  - CB008379 CFAM-65770 - US1 Unsuccessful PDU Session Resource Setup due to guaranteedFlowBitRate exceeded
    ...
    ...  == HISTORY ==
    ...  - [06.04.2022]  - Created TC

    [Tags]  E-a_18

    Prepare test environment E-a_18

    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE1, UE2 and 5QI2
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE3, UE4 and 5QI3
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE5, UE6 and 5QI4

    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE7, UE8 and 5QI71
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE9, UE10 and 5QI72
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE11, UE12 and 5QI76

    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE13, UE14 and 5QI128
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE15, UE16 and 5QI212
    Run Keyword And Continue On Failure
    ...     Repeat incoming Intra-frequency HO rejected by too high req GFBR value and online GFBR change for UE17, UE18 and 5QI254

*** Keywords ***
Prepare test environment E-a_18
    Configure       ${yaml_enable_intraho}

